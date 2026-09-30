import json, io, time
import urllib.request as ur
import urllib.parse as up
import urllib.error
class SafeError(Exception):
    pass

class NoRedirect(ur.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None

def call(url, payload=None, form=False, headers=None):
    body = None
    h = {'Accept': 'application/json', 'User-Agent': 'GlanceXboxCompanion/1.0'}
    if headers:
        h.update(headers)
    if payload is not None:
        body = (up.urlencode(payload) if form else json.dumps(payload)).encode()
        h['Content-Type'] = 'application/x-www-form-urlencoded' if form else 'application/json'
    req = ur.Request(url, data=body, headers=h)
    try:
        with ur.build_opener(NoRedirect()).open(req, timeout=20) as res:
            raw=res.read(8_000_001)
            if len(raw)>8_000_000:
                raise SafeError('Response exceeds bounded size limit')
            return json.loads(raw)
    except urllib.error.HTTPError as e:
        raise SafeError('HTTP ' + str(e.code)) from None
    except SafeError:
        raise
    except Exception as e:
        raise SafeError('Connection or response error ('+type(e).__name__+')') from None

def friend_activity(auth):
    headers={'Authorization':auth,'x-xbl-contract-version':'1'}
    people=call('https://social.xboxlive.com/users/me/people?maxItems=20',headers=headers)
    ids=[p['xuid'] for p in people.get('people',[]) if isinstance(p.get('xuid'),str) and p['xuid'].isdigit()][:20]
    if not ids:
        return {'state':'ready','items':[]}
    rows=call('https://userpresence.xboxlive.com/users/batch', {'users':ids,'level':'all','onlineOnly':True}, headers={'Authorization':auth,'x-xbl-contract-version':'3','Accept-Language':'en-US'})
    if not isinstance(rows,list):
        raise SafeError('Unexpected presence response')
    items=[]
    for row in rows[:20]:
        uid=row.get('xuid')
        if uid not in ids:
            continue
        profile=call('https://profile.xboxlive.com/users/xuid('+uid+')/profile/settings?settings=Gamertag,GameDisplayPicRaw',headers={'Authorization':auth,'x-xbl-contract-version':'2'})
        fields={s['id']:s.get('value') for p in profile.get('profileUsers',[]) for s in p.get('settings',[])}
        titles=[t for d in row.get('devices',[]) for t in d.get('titles',[]) if t.get('state','').lower()=='active' and t.get('placement')!='background']
        title=titles[0] if titles else {}
        detail=title.get('name') or row.get('state') or 'ACTIVITY NOT SHARED'
        rich=title.get('activity',{}).get('richPresence')
        items.append({'name':fields.get('Gamertag','FRIEND'),'detail':detail+(' / '+rich if rich else ''),'art':pixels(fields.get('GameDisplayPicRaw'))})
    return {'state':'ready','items':items}

def fetch_snapshot(access_token, friends=False):
    results=[]
    snapshot={'schema':1,'updated':int(time.time()),'state':'ready','profile':{},'presence':{},'achievements':[]}
    stage='Microsoft sign-in'
    try:
        msa={'access_token':access_token}
        results.append((stage, 'Passed'))
        stage = 'Xbox user token'
        user = call('https://user.auth.xboxlive.com/user/authenticate', {
            'RelyingParty': 'http://auth.xboxlive.com', 'TokenType': 'JWT',
            'Properties': {'AuthMethod': 'RPS', 'SiteName': 'user.auth.xboxlive.com',
                           'RpsTicket': 'd=' + msa['access_token']}}, headers={'x-xbl-contract-version': '1'})
        results.append((stage, 'Passed'))
        stage = 'Xbox services authorization (RETAIL capability test)'
        xsts = call('https://xsts.auth.xboxlive.com/xsts/authorize', {
            'RelyingParty': 'http://xboxlive.com', 'TokenType': 'JWT',
            'Properties': {'SandboxId': 'RETAIL', 'UserTokens': [user['Token']]}},
            headers={'x-xbl-contract-version': '1'})
        claim = xsts['DisplayClaims']['xui'][0]
        auth = 'XBL3.0 x=' + claim['uhs'] + ';' + xsts['Token']
        results.append((stage, 'Passed'))
        stage = 'Own profile'
        p = call('https://profile.xboxlive.com/users/me/profile/settings?settings=Gamertag,GameDisplayPicRaw,Gamerscore',
                 headers={'Authorization': auth, 'x-xbl-contract-version': '2'})
        own = p['profileUsers'][0]
        fields = {s['id']: s.get('value') for s in own.get('settings', [])}
        snapshot['profile'] = {'gamertag': fields.get('Gamertag','PLAYER'), 'score': fields.get('Gamerscore'), 'art': pixels(fields.get('GameDisplayPicRaw'))}
        results.append((stage, 'Available fields: ' + ', '.join(k for k in ['Gamertag','GameDisplayPicRaw','Gamerscore'] if fields.get(k) is not None)))
        xuid = own['id']
        if not isinstance(xuid, str) or not xuid.isdigit():
            raise SafeError('Invalid profile identifier')
        stage = 'Own presence'
        presence = call('https://userpresence.xboxlive.com/users/xuid(' + xuid + ')?level=all',
                        headers={'Authorization': auth, 'x-xbl-contract-version': '3', 'Accept-Language': 'en-US'})
        results.append((stage, 'State returned' if presence.get('state') else 'No presence disclosed'))
        titles = [(d.get('type',''),t) for d in presence.get('devices',[]) for t in d.get('titles',[]) if t.get('state','').lower() == 'active' and t.get('placement') != 'background']
        device, title = titles[0] if titles else ('',{})
        snapshot['presence'] = {'state':presence.get('state','unknown'), 'device':device, 'title':title.get('name',''), 'rich':title.get('activity',{}).get('richPresence','')}
        results.append(('Gamerpic image', 'Decoded' if snapshot['profile']['art'] else 'Not available'))
        try:
            stage = 'Recent achievements'
            achievements = call('https://achievements.xboxlive.com/users/xuid('+xuid+')/achievements?unlockedOnly=true&orderBy=UnlockTime&maxItems=5', headers={'Authorization':auth,'x-xbl-contract-version':'2','Accept-Language':'en-US'})
            rows = achievements.get('achievements',[])
            for a in rows[:5]:
                rewards = [r.get('value') for r in a.get('rewards',[]) if r.get('type') == 'Gamerscore']
                media = [m.get('url') for m in a.get('mediaAssets',[]) if m.get('type') == 'Icon']
                names = a.get('titleAssociations',[])
                snapshot['achievements'].append({'name':a.get('name','ACHIEVEMENT'), 'score':rewards[0] if rewards else None, 'game':names[0].get('name','') if names else '', 'unlocked':a.get('progression',{}).get('timeUnlocked',''), 'art':pixels(media[0]) if media else []})
            results.append((stage, str(len(rows))+' records returned'))
            results.append(('Achievement artwork', 'Decoded' if any(a['art'] for a in snapshot['achievements']) else 'Not available'))
        except SafeError as e:
            results.append((stage,str(e)))
        try:
            stage='Achievement title history'
            history=call('https://achievements.xboxlive.com/users/xuid('+xuid+')/history/titles?maxItems=5',headers={'Authorization':auth,'x-xbl-contract-version':'2'})
            results.append((stage,'Response received' if isinstance(history,dict) else 'Unexpected response'))
            snapshot['activity']={'state':'ready','items':[{'name':t.get('name','GAME'),'detail':'RECENT ACTIVITY'} for t in history.get('titles',[])[:5]]}
            for item in snapshot['activity']['items']:
                match=next((a for a in snapshot['achievements'] if a.get('game') == item['name'] and a.get('art')),None)
                if match:
                    item['art']=match['art']
                    item['detail']='UNLOCKED: '+match['name']
        except SafeError as e:
            results.append((stage,str(e)))
        try:
            stage='Last-played history capability test'
            recent=call('https://titlehub.xboxlive.com/users/xuid('+xuid+')/titles/titlehistory/decoration/image,detail',headers={'Authorization':auth,'x-xbl-contract-version':'2','Accept-Language':'en-US'})
            games=[t for t in recent.get('titles',[]) if t.get('type') == 'Game' and t.get('titleHistory',{}).get('lastTimePlayed')]
            games.sort(key=lambda t:t['titleHistory']['lastTimePlayed'],reverse=True)
            for item in snapshot.get('activity',{}).get('items',[]):
                if not item.get('art'):
                    match=next((g for g in games if g.get('name') == item['name']),None)
                    if match:
                        cover=match.get('displayImage','')
                        if cover.startswith('http://'):
                            cover='https://'+cover[7:]
                        item['art']=pixels(cover)
            results.append((stage,str(len(games))+' games with play timestamps returned'))
            if games:
                from datetime import datetime
                t=games[0]
                date=datetime.fromisoformat(t['titleHistory']['lastTimePlayed'].replace('Z','+00:00')).astimezone().strftime('%b %d, %Y')
                image_url=t.get('displayImage')
                # Xbox may return legacy HTTP artwork URLs. Fetch only their
                # HTTPS equivalent; never downgrade transport or send tokens.
                if isinstance(image_url,str) and image_url.startswith('http://'):
                    image_url='https://'+image_url[7:]
                image_check=[]
                art=pixels(image_url,image_check)
                results.append(('Game artwork fetch', ', '.join(image_check) or 'No diagnostic'))
                results.append(('Game artwork source', (up.urlsplit(image_url).hostname or 'No host') if isinstance(image_url,str) else 'No displayImage field'))
                snapshot['lastplayed']={'title':t.get('name','GAME'),'date':date,'art':art}
                results.append(('Last-played game artwork','Decoded' if art else 'Not available'))
                for g in games:
                    if str(g.get('titleId')) == str(title.get('id')):
                        snapshot['presence']['art']=pixels(g.get('displayImage'))
                        break
        except SafeError as e:
            results.append((stage,str(e)))
        except Exception:
            results.append((stage,'Unexpected response; no last-played data inferred'))
        snapshot['friends']={'state':'disabled','items':[]}
        if friends:
            try:
                snapshot['friends']=friend_activity(auth)
                results.append(('Friend activity',str(len(snapshot['friends']['items']))+' shared online records returned (up to 20 contacts)'))
            except Exception:
                snapshot['friends']={'state':'unavailable','items':[]}
                results.append(('Friend activity','Unavailable or privacy restricted'))
    except SafeError as e:
        results.append((stage, str(e)))
    except Exception:
        results.append((stage, 'Unavailable or unexpected response'))
    return results, snapshot

def pixels(url, diagnostic=None):
    diagnostic = diagnostic if diagnostic is not None else []
    if not isinstance(url,str):
        return []
    p=up.urlsplit(url)
    hosts=('xboxlive.com','xboxservices.com','xbox.com','store-images.s-microsoft.com')
    if p.scheme != 'https' or p.username or p.password or p.port not in (None,443) or not any(p.hostname == h or (p.hostname or '').endswith('.'+h) for h in hosts):
        return []
    try:
        from PIL import Image, ImageOps
        with ur.build_opener(NoRedirect()).open(url,timeout=10) as r:
            if not r.headers.get('Content-Type','').startswith('image/'):
                diagnostic.append('Non-image content type')
                return []
            data=r.read(2_000_001)
        if len(data)>2_000_000:
            diagnostic.append('Image exceeds byte limit')
            return []
        with Image.open(io.BytesIO(data)) as im:
            if im.width*im.height>16_000_000:
                diagnostic.append('Image exceeds dimension limit')
                return []
            im=ImageOps.fit(im.convert('RGB'),(26,26),method=Image.Resampling.LANCZOS)
            return [['#%02x%02x%02x'%im.getpixel((x,y)) for x in range(26)] for y in range(26)]
    except Exception as e:
        diagnostic.append('HTTP '+str(e.code) if isinstance(e,urllib.error.HTTPError) else type(e).__name__)
        return []


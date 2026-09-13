from pathlib import Path
from unittest.mock import patch
import json, ast, sys, tempfile, datetime
from PIL import Image, ImageDraw, ImageFont
from gdn.starhost.executor import run_star_app
from gdn.scene import render_scene
from gdn.check import check_app
from gdn.fonts import text_width, font_height

base=Path(__file__).resolve().parents[1]
out=Path(sys.argv[1]) if len(sys.argv)>1 else Path(tempfile.mkdtemp(prefix='team-icon-previews-')); out.mkdir(parents=True,exist_ok=True)
literals={node.targets[0].id:ast.literal_eval(node.value) for node in ast.parse((base/'app.star').read_text()).body if isinstance(node,ast.Assign) and isinstance(node.targets[0],ast.Name) and node.targets[0].id in ['TEAM_ICONS','TEAM_ALIASES']}
catalog={'icons':literals['TEAM_ICONS'],'aliases':literals['TEAM_ALIASES']}

def run(row=None, inputs=None, data=None, status=200, now=None):
 if data is None: data={'ok':True,'rows':[row] if row else []}
 with patch('gdn.starhost.executor.HttpHost.get',return_value={'status_code':status,'json':data}) as get:
  scene=run_star_app(base,inputs={'feedurl':'https://example.com/feed',**(inputs or {})},now=now)
  if get.called: assert get.call_args.kwargs.get('ttl_seconds')==0
 canvas=render_scene(scene,asset_dir=base)['main']
 assert canvas.img.size==(64,32)
 # Assert text never clips and every pair of text boxes stays separate.
 boxes=[]
 for op in scene['pages'][0]['ops']:
  if op['op']!='text': continue
  w=text_width(op['font'],op['text']); h=font_height(op['font'])
  x=op['x']-(w if op['align']=='right' else w//2 if op['align']=='center' else 0)
  y=op['y']; assert 0<=x and x+w<=64 and 0<=y and y+h<=32,(op,x,w,h)
  if w: boxes.append((x,y,x+w,y+h,op['text']))
 for i,a in enumerate(boxes):
  for b in boxes[i+1:]:
   assert not (max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3])),(a,b)
 return scene,canvas.img

images={}
for key,info in catalog['icons'].items():
 league,code=key.split(':')
 row={'label':code+' U10.5','team':{'league':league,'code':code},'pct':61,'delta':-6,'side_label':'UNDER','side':'NO','settled':False}
 scene,im=run(row)
 assert [op['asset'] for op in scene['pages'][0]['ops'] if op['op']=='image']==[info['asset']]
 images[key]=im
for key,canonical in catalog['aliases'].items():
 league,code=key.split(':'); scene,_=run({'label':'CUSTOM','team':{'league':league,'code':code},'pct':100,'delta':100,'settled':True})
 assert [o['asset'] for o in scene['pages'][0]['ops'] if o['op']=='image']==[catalog['icons'][canonical]['asset']]
for pct in [0,1,99,100,None]:
 for delta in [-100,-99,-1,0,None,1,99,100]:
  for settled in [True,False]:
   run({'team':{'league':'CFB','code':'TAMU'},'label':'A VERY LONG CUSTOM MARKET U100.5','pct':pct,'delta':delta,'side_label':'UNDER','settled':settled})
for row,inputs,asset in [
 ({'label':'PIT U10.5'}, {},None),
 ({'label':'PIT U10.5'}, {'league':'NFL'},'assets/nfl-pit.png'),
 ({'label':'PIT U10.5'}, {'league':'CFB'},'assets/cfb-pitt.png'),
 ({'label':'MIZZ U10.5'}, {},'assets/cfb-mizz.png'),
 ({'label':'PIT','team':{'league':'CFB','code':'PIT'}}, {'league':'NFL'},'assets/cfb-pitt.png'),
 ({'label':'MIZZ','team':{'league':'MLB','code':'MIZZ'}}, {},None),
 ({'label':'UNKNOWN'}, {},None),
 ({'label':'SC','team':None}, {},None),
]:
 scene,_=run({'pct':61,'delta':6,'side_label':'UNDER',**row},inputs)
 assert [o['asset'] for o in scene['pages'][0]['ops'] if o['op']=='image']==([asset] if asset else [])
for data,status in [({'ok':False,'rows':[]},200),({'ok':True,'rows':[]},200),(None,503),([],200)]: run(data=data,status=status)
run(inputs={'feedurl':''})
run(inputs={'feedurl':'','feed_url':'https://example.com/legacy'},row={'label':'KU','pct':61})
# Structured spread views use the held team's logo, a large signed line,
# and the same probability as the corresponding Kalshi YES/NO holding.
for key in ['NFL:ATL','NFL:PIT','CFB:KU','CFB:TAMU']:
 league,code=key.split(':')
 for line in [-48.5,10.5,100.5]:
  for pct in [0,61,100,None]:
   for delta in [-100,0,100]:
    scene,_=run({'team':{'league':league,'code':code},'market_kind':'spread','line':line,'label':code+' '+str(line),'pct':pct,'delta':delta,'side_label':'SPREAD'})
    text_ops=[o for o in scene['pages'][0]['ops'] if o['op']=='text']
    assert any(o['text']==('+' if line>=0 else '-')+str(abs(line)) for o in text_ops)
    if delta: assert any(o['text'].endswith('PP') for o in text_ops)
for status in ['CLOSED','PENDING','WON','LOST','SETTLED']:
 scene,_=run({'team':{'league':'NFL','code':'ATL'},'market_kind':'spread','line':10.5,'pct':61,'delta':-100,'status_label':status})
 assert any(o['op']=='text' and o['text']==status for o in scene['pages'][0]['ops'])

now=datetime.datetime(2026,9,13,18,0,tzinfo=datetime.timezone.utc)
stamp=int(now.timestamp())
matchup=[{'league':'NFL','code':'CHI'},{'league':'NFL','code':'CAR'}]
total={'ticker':'A','label':'UNDER 47.5','market_kind':'total','line':47.5,'side':'NO','pct':61,'delta':-6,'team':None,'matchup':matchup,'game':{'scores':[21,10],'phase':'Q3 8:42','state':'in','fetched_at':stamp}}
def current(row, **extra):return {'version':2,'ok':True,'fetched_at':stamp,'rows':[row],**extra}
new_previews=[]
for title,updates in [('Total: live',{}),('Total: halftime',{'game':{**total['game'],'phase':'HALF'}}),('Total: final',{'game':{**total['game'],'phase':'FINAL','state':'post'}}),('Score unavailable',{'game':None}),('Stale score',{'game':{**total['game'],'stale':True}}),('Spread: live',{'label':'CAR +10.5','market_kind':'spread','line':10.5,'team':matchup[1]})]:
 scene,im=run(data=current({**total,**updates}),now=now)
 new_previews.append((title,im))
 assert len([o for o in scene['pages'][0]['ops'] if o['op']=='image'])==2
 for pct in [None,0,100]:
  for delta in [-100,0,100]:
   run(data=current({**total,**updates,'pct':pct,'delta':delta}),now=now)
for count in [1,9,100,1000]:
 rows=[{**total,'ticker':str(i).zfill(4)} for i in range(count)]
 run(data=current(total,rows=rows),now=now,inputs={'mode':'Pin one','pin':str(count)})
# Sort a server-rotated list before rotation or pinning; filtering changes the counter.
rows=[{**total,'ticker':'B','label':'OVER 48.5','line':48.5},{**total,'ticker':'A'}]
def texts(scene):return [o['text'] for o in scene['pages'][0]['ops'] if o['op']=='text']
scene,_=run(data=current(total,rows=rows),inputs={'mode':'Pin one','pin':'1'},now=now)
assert 'U 47.5' in texts(scene) and '1/2' in texts(scene)
scene,_=run(data=current(total,rows=rows),inputs={'positions':'B'},now=now)
assert 'U 48.5' in texts(scene) and '1/1' in texts(scene)
for settings in [{'positions':'MISSING'},{'show':'CFB'},{'mode':'Pin one','pin':'0'},{'mode':'Pin one','pin':'abc'},{'mode':'Pin one','pin':'3'}]:
 scene,_=run(data=current(total,rows=rows),inputs=settings,now=now)
 assert 'NO MATCH' in texts(scene) or 'BAD PICK' in texts(scene)
for settings in [{'scores':'Hide'},{'show':'Live games'}]:run(data=current(total),inputs=settings,now=now)
for minutes in [1,2,3,5]:
 for offset in [0,1,59,60,119,120,300]:
  dt=now+datetime.timedelta(seconds=offset)
  scene,_=run(data=current(total,rows=rows),inputs={'hold':str(minutes)},now=dt)
  assert str(int(dt.timestamp())//(60*minutes)%2+1)+'/2' in texts(scene)
scene,_=run(data=current(total,fetched_at=stamp-180),now=now)
assert 'STALE FEED' in texts(scene)
run(data=current({**total,'matchup':[{'league':'CFB','code':'ZZZZ'}, {'league':'CFB','code':'????'}]}),now=now)
run(data=current({'ticker':'OTHER','label':'AN EXTREMELY LONG LABEL','pct':100}),now=now)
print('Passed: version 2 totals, scores, counter, filters, pinning, minute cadence, stale states, HTTP cache and unknown-team fallback.')

errors,warnings=check_app(base)
assert not errors,errors
print('GDN check warnings:',warnings)

# These are actual app renders from GDN, enlarged without smoothing for inspection.
try:
 font=ImageFont.truetype('DejaVuSansMono.ttf',14); small=ImageFont.truetype('DejaVuSansMono.ttf',11)
except OSError:
 font=ImageFont.load_default(); small=ImageFont.load_default()
for league,title in [('NFL','ALL 32 NFL TEAMS'),('CFB','70 COLLEGE FOOTBALL TEAMS')]:
 items=[(k,t) for k,t in catalog['icons'].items() if k.startswith(league+':')]
 cols=8; cellw=144; cellh=142; rows=(len(items)+cols-1)//cols
 sheet=Image.new('RGB',(cols*cellw+32,rows*cellh+75),'#0E1117'); draw=ImageDraw.Draw(sheet)
 draw.text((16,18),title,font=font,fill='white')
 for i,(key,t) in enumerate(items):
  x=16+(i%cols)*cellw;y=60+(i//cols)*cellh
  # Use the exact logo region from the app render, including its natural padding.
  icon=images[key].crop((0,2,16,18)).resize((80,80),Image.Resampling.NEAREST)
  sheet.paste(icon,(x+24,y))
  draw.text((x+8,y+86),t['code'],font=font,fill=t['color'])
  words=t['name'].split();lines=['']
  for word in words:
   if len(lines[-1])+len(word)+1>19: lines.append(word)
   else: lines[-1]=(lines[-1]+' '+word).strip()
  for j,line in enumerate(lines[:2]): draw.text((x+8,y+106+13*j),line,font=small,fill='#B4BECC')
 sheet.save(out/(league.lower()+'-team-icons.png'))

sample_keys=['NFL:PIT','NFL:DAL','NFL:KC','NFL:BUF','CFB:MIZZ','CFB:KU','CFB:PITT','CFB:TAMU']
sheet=Image.new('RGB',(1088,430),'#0E1117');d=ImageDraw.Draw(sheet)
d.text((24,14),'64 x 32 DISPLAY PREVIEWS  /  SAMPLE ODDS',font=font,fill='white')
for i,key in enumerate(sample_keys):
 x=24+(i%4)*268;y=60+(i//4)*185
 d.text((x,y),catalog['icons'][key]['name'],font=small,fill='#B4BECC')
 sheet.paste(images[key].resize((256,128),Image.Resampling.NEAREST),(x,y+22))
sheet.save(out/'panel-previews.png')
sheet=Image.new('RGB',(840,410),'#0E1117');d=ImageDraw.Draw(sheet)
d.text((20,12),'MATCHUPS + SCORE SNAPSHOTS / FICTIONAL SAMPLE ODDS',font=font,fill='white')
for i,(title,im) in enumerate(new_previews):
 x=20+(i%3)*275;y=48+(i//3)*177
 d.text((x,y),title,font=small,fill='#B4BECC')
 sheet.paste(im.resize((256,128),Image.Resampling.NEAREST),(x,y+20))
sheet.save(out/'live-display-preview.png')
print('Passed: all 102 teams, 69 aliases, 80 legacy and 144 spread boundary layouts, league collisions, legacy feeds, and error states.')

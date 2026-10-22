def clean(value):
    if type(value) != 'string':
        return ''
    return ' '.join(''.join([ch if ch in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :.,/-+()' else ' ' for ch in value[:160].upper().elems()]).split())

def text(c, value, y, color = 'white', font = '5x7'):
    value = clean(value)
    if c.text_width(value, font) > 164:
        for n in range(len(value), -1, -1):
            if c.text_width(value[:n] + '..', font) <= 164:
                value = value[:n].rstrip() + '..'
                break
    c.text(value, 18, y, font = font, color = color)

def show(c, title, detail, warning = False, sample = False):
    color = 'amber' if warning else '#66D9AE'
    c.fill('black')
    c.rect(10, 3, 12, 28, fill = color)
    text(c, 'HOME / SAMPLE' if sample else 'HOME / ATTENTION', 1, color, '4x5')
    text(c, title, 10)
    text(c, detail, 23, color, '4x5')

def endpoint(value):
    if type(value) != 'string':
        return ''
    value = value.strip()
    rest = value[8:] if value.startswith('https://') else value
    if not rest or any([ch not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_/' for ch in rest.elems()]):
        return ''
    host = rest.split('/')[0]
    if '.' not in host or '..' in host or host.startswith('.') or host.endswith('.'):
        return ''
    for label in host.split('.'):
        if not label or label.startswith('-') or label.endswith('-') or '_' in label:
            return ''
    return 'https://' + rest

def main(c, ctx):
    scenario = ctx.inputs.get('preview', 'Live')
    url = endpoint(ctx.inputs.get('endpoint', ''))
    key = ctx.inputs.get('readkey', '')
    if scenario == 'Live' and (not url or not key):
        # Not configured yet: show a labelled demo instead of a setup screen.
        scenario = 'Demo'
    sample = scenario != 'Live'
    if sample:
        data = {'schema': 1, 'generated_unix': ctx.now.unix, 'expires_unix': ctx.now.unix + 300, 'total_actionable': 3, 'degraded': False, 'privacy': 'counts', 'items': []}
        if scenario in ['Item', 'Long title', 'Demo']:
            data['privacy'] = 'titles'
            data['items'] = [{'title': {'Item': 'CHECK FILTER', 'Demo': 'REPLACE HVAC FILTER'}.get(scenario, 'RENEW THE VERY LONG EXAMPLE HOUSEHOLD MAINTENANCE RECORD'), 'stale': False}]
        if scenario == 'Empty':
            data['total_actionable'] = 0
        if scenario == 'Stale':
            data['expires_unix'] = ctx.now.unix - 1
        if scenario == 'Error':
            show(c, 'FEED UNAVAILABLE', 'CHECK CONNECTION', True, True)
            return
    else:
        response = http.get(url, headers = {'Authorization': 'Bearer ' + key}, ttl_seconds = 60)
        if response.get('status_code') != 200:
            show(c, 'FEED UNAVAILABLE', 'CHECK CONNECTION', True)
            return
        data = response.get('json')
    if type(data) != 'dict' or data.get('schema') != 1 or type(data.get('generated_unix')) not in ['int', 'float'] or type(data.get('expires_unix')) not in ['int', 'float']:
        show(c, 'INVALID FEED', 'CHECK CONNECTION', True, sample)
        return
    if data['generated_unix'] > ctx.now.unix + 60 or data['expires_unix'] <= ctx.now.unix or data['expires_unix'] > data['generated_unix'] + 300:
        show(c, 'DATA STALE', 'OPEN HOUSEHOLD APP', True, sample)
        return
    count = data.get('total_actionable')
    if type(count) != 'int' or count < 0:
        show(c, 'INVALID FEED', 'CHECK CONNECTION', True, sample)
        return
    degraded = data.get('degraded') != False
    items = data.get('items', [])
    selected = ctx.inputs.get('item', '1')
    rank = int(selected) - 1 if selected in ['1', '2', '3', '4', '5'] else 0
    if data.get('privacy') == 'titles' and type(items) == 'list' and rank < len(items) and type(items[rank]) == 'dict':
        item = items[rank]
        stale = item.get('stale') != False
        detail = 'STALE ITEM' if stale else 'CHECK SOURCES' if degraded else str(rank + 1) + ' OF ' + str(count) + ' / OPEN APP'
        show(c, item.get('title', 'OPEN HOUSEHOLD APP'), detail, degraded or stale, sample)
    else:
        title = str(count) + ' NEED ATTENTION' if count else 'NO ITEMS DUE'
        show(c, title, 'CHECK SOURCES' if degraded else 'FROM CONNECTED SOURCES', degraded, sample)

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

def render(c, ctx, page):
    scenario = ctx.inputs.get('preview', 'Live')
    sample = scenario != 'Live'
    if sample:
        data = {'schema': 1, 'generated_unix': ctx.now.unix, 'expires_unix': ctx.now.unix + 300, 'total_actionable': 3, 'degraded': False, 'privacy': 'counts', 'items': []}
        if scenario in ['Item', 'Long title']:
            data['privacy'] = 'titles'
            data['items'] = [{'title': 'CHECK FILTER' if scenario == 'Item' else 'RENEW THE VERY LONG EXAMPLE HOUSEHOLD MAINTENANCE RECORD', 'stale': False}]
        if scenario == 'Empty':
            data['total_actionable'] = 0
        if scenario == 'Stale':
            data['expires_unix'] = ctx.now.unix - 1
        if scenario == 'Error':
            show(c, 'FEED UNAVAILABLE', 'CHECK CONNECTION', True, True)
            return
    else:
        url = endpoint(ctx.inputs.get('endpoint', ''))
        key = ctx.inputs.get('readkey', '')
        if not url or not key:
            show(c, 'SETUP REQUIRED', 'ADD LED FEED + KEY', True)
            return
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
    selected = ctx.inputs.get('mode', 'All five')
    rank = page if selected == 'All five' else int(ctx.inputs.get('item', '1')) - 1
    if type(items) == 'list' and len(items) > 0:
        rank = rank % len(items)
    if data.get('privacy') == 'titles' and type(items) == 'list' and rank < len(items) and type(items[rank]) == 'dict':
        item = items[rank]
        stale = item.get('stale') != False
        color = 'amber' if stale or degraded else '#4DA3FF'
        c.fill('black')
        c.rect(10, 3, 12, 28, fill = color)
        label = 'SAMPLE' if sample else item.get('source_label', 'HOUSEHOLD')
        text(c, str(rank + 1) + '/' + str(len(items)) + ' ' + label, 0, color, '4x5')
        title = clean(item.get('title', 'OPEN HOUSEHOLD APP'))
        lines = ['', '']
        line = 0
        for word in title.split():
            candidate = (lines[line] + ' ' + word).strip()
            if c.text_width(candidate, '5x7') > 164 and line == 0:
                line = 1
                candidate = word
            lines[line] = candidate
        text(c, lines[0], 7)
        text(c, lines[1], 15)
        detail = 'STALE / VERIFY IN APP' if stale else 'CHECK SOURCES / OPEN APP' if degraded else item.get('context', 'OPEN APP FOR DETAILS')
        text(c, detail, 25, color, '4x5')
    else:
        title = str(count) + ' NEED ATTENTION' if count else 'NO ITEMS DUE'
        show(c, title, 'CHECK SOURCES' if degraded else 'FROM CONNECTED SOURCES', degraded, sample)


def main(c, ctx):
    render(c, ctx, 0)

def second(c, ctx):
    render(c, ctx, 1)

def third(c, ctx):
    render(c, ctx, 2)

def fourth(c, ctx):
    render(c, ctx, 3)

def fifth(c, ctx):
    render(c, ctx, 4)

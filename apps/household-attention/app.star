def dynamic_logo(c, rows):
    if type(rows) != 'list' or len(rows) != 26:
        return False
    for row in rows:
        if type(row) != 'list' or len(row) != 62:
            return False
        for color in row:
            if type(color) != 'string' or len(color) != 7 or not color.startswith('#'):
                return False
            if any([ch not in '0123456789abcdefABCDEF' for ch in color[1:].elems()]):
                return False
    for y in range(26):
        for x in range(62):
            c.pixel(312 + x, 3 + y, rows[y][x])
    return True

def clean(value):
    if type(value) != 'string':
        return ''
    return ' '.join(''.join([ch if ch in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :.,/-+()' else ' ' for ch in value[:160].upper().elems()]).split())

def text(c, value, y, color = 'white', font = '5x7', x = 18, width = 164):
    value = clean(value)
    if c.text_width(value, font) > width:
        for n in range(len(value), -1, -1):
            if c.text_width(value[:n] + '..', font) <= width:
                value = value[:n].rstrip() + '..'
                break
    c.text(value, x, y, font = font, color = color)

def show(c, title, detail, warning = False, sample = False):
    color = 'amber' if warning else '#66D9AE'
    c.fill('black')
    c.rect(10, 3, 12, 28, fill = color)
    text(c, 'HOME ATTENTION SAMPLE' if sample else 'HOME ATTENTION', 1, color, '4x5')
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
        brand = item.get('brand', '')
        logo = {'google-tasks':'google-tasks.png', 'google-calendar':'google-calendar.png', 'alexa':'alexa.png', 'whisker':'whisker.png', 'petlibro':'petlibro.png'}.get(brand)
        x = 82
        width = 216
        c.line(75, 2, 75, 29, color)
        c.line(305, 2, 305, 29, color)
        if logo:
            if brand in ['whisker', 'petlibro']:
                c.image(logo, 10, 11)
            else:
                c.image(logo, 29, 4, w = 24, h = 24)
        raw_title = clean(item.get('title', ''))
        is_cat = brand in ['whisker', 'petlibro'] or any([word in raw_title.split() for word in ['CAT', 'LITTER', 'TEGAN']])
        visual = 'task-task.png' if is_cat else 'task-filter.png' if 'HVAC' in raw_title or 'FILTER' in raw_title else 'task-plane.png' if 'FLIGHT' in raw_title else 'task-shopping.png' if brand == 'alexa' else 'task-task.png'
        if not dynamic_logo(c, item.get('logo_pixels')):
            c.image(visual, 330, 3, w = 26, h = 26)
        title = clean(item.get('title', 'OPEN HOUSEHOLD APP'))
        lines = ['', '']
        line = 0
        for word in title.split():
            candidate = (lines[line] + ' ' + word).strip()
            if c.text_width(candidate, '5x7') > width and line == 0:
                line = 1
                candidate = word
            lines[line] = candidate
        shopping = item.get('item_kind') == 'shopping'
        if shopping:
            text(c, 'SHOPPING LIST', 1, color, '4x5', x, width)
        text(c, lines[0], 8 if shopping else 3, x = x, width = width)
        text(c, lines[1], 16 if shopping else 12, x = x, width = width)
        detail = 'STALE / VERIFY IN APP' if stale else 'CHECK SOURCES / OPEN APP' if degraded else item.get('context', 'OPEN APP FOR DETAILS')
        text(c, 'SAMPLE' if sample else detail, 26 if shopping else 24, color, '4x5', x, width)
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

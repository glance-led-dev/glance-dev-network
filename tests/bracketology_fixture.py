"""Build a local approved-feed fixture from the app's bundled projection.

No working spreadsheet, sibling checkout, network request, or cloud write.
"""


def approved_projection(ns):
    pairs = ns['YOUR_TEAM_SAMPLE_SLOTS']
    regions = []
    for name, city, _badge, _top, games in ns['REGION_MATCHUPS']:
        slots = []
        for game in games:
            for offset in [0, 2]:
                seed = int(game[offset])
                codes = pairs.get(name + '|' + str(seed), [game[offset + 1]])
                slots.append({'seed': seed, 'teams': list(codes)})
        regions.append({'name': name, 'city': city, 'slots': slots})
    teams = []
    for region in regions:
        for slot in region['slots']:
            for code in slot['teams']:
                teams.append({'code': code, 'seed': slot['seed'],
                              'overall': ns['TEAM_OVERALL_SEEDS'][code],
                              'region': region['name']})
    assert len(teams) == len({t['code'] for t in teams}) == 76
    auto = [game[1:] for group in ns['OPENING_ROUND_AUTO'] for game in group]
    opening = []
    for key, codes in pairs.items():
        region, seed = key.split('|')
        opening.append({'region': region, 'seed': int(seed), 'teams': list(codes),
                        'category': 'AQ' if list(codes) in auto else 'AL'})
    bubble_keys = ['last_four_byes', 'last_four_in', 'first_four_out', 'next_four_out']
    return {'schema_version': 1, 'season': '2026-27', 'draft': False,
            'revision': 2, 'projection_date': '2026-10-27', 'teams': teams,
            'regions': regions, 'opening_round': opening,
            'bubble': {key: list(ns['BUBBLE_GROUPS'][i][1:5])
                       for i, key in enumerate(bubble_keys)}}

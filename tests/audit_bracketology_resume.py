"""Full-setting cold-cache audit; fixtures only, never reads/writes the live feed."""
import yaml
from test_bracketology_resume import APP, STAMP, ResumeFallback

case=ResumeFallback()
case.setUp()
saved={'season':'2026-27',
       'SOR':{'source':'ESPN','teams':{v:['20',STAMP] for v in case.ns['RESUME_TEAM_IDS'].values()}},
       'WAB':{'source':'NCAA','as_of':'2026-11-20','teams':{
           case.ns['resume_ncaa_variants'](team)[0]:['-12.345',STAMP] for team in case.ns['TEAM_NAMES']}}}
manifest=yaml.safe_load((APP/'manifest.yaml').read_text())
cases=[('My Team',name) for name in manifest['inputs'][1]['choices']]
cases += [(view,'Texas') for view in manifest['inputs'][0]['choices'] if view!='My Team']
cases += [('My Team','NOT_A_SCHOOL'),('invalid','Texas'),('My Team','')]
maximum=0
for index,(view,team) in enumerate(cases,1):
    scene,urls=case.render(saved,team=team,view=view)
    assert len(scene['pages'])==5,(view,team)
    assert len(urls)<=8,(view,team,urls)
    maximum=max(maximum,len(urls))
    if index%100==0:print(f'{index}/{len(cases)} settings passed',flush=True)
print(f'PASS: {len(cases)} settings, five pages each, maximum {maximum} uncached requests',flush=True)

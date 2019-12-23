#!/bin/bash
if [ ! -e master ]; then
	bbtravis create-master master
	cat <<EOF >master/master.cfg
import os
from buildbot_travis import TravisConfigurator
from buildbot.plugins import schedulers

c = BuildmasterConfig = {}
TravisConfigurator(BuildmasterConfig, basedir).fromYaml('cfg.yml')
c['buildbotURL'] = os.environ['BUILDBOT_MASTER_URL']
c['buildbotNetUsageData'] = 'basic'

import pprint
pp = pprint.PrettyPrinter(indent=4)
pp.pprint(c)

codebases = {}
nightly_projects = []
weekly_projects = []

for project in c ['www']['plugins']['buildbot_travis']['cfg']['projects']:
	print(project)
	codebases[project['name']] = { 'repository' : project['repository'] }
	if 'weekly' in project and project['weekly']:
		weekly_projects.append(project['name'])
	else:
		nightly_projects.append(project['name'])

print('Nightly!')
pp.pprint(nightly_projects)
print('\nWeekly!')
pp.pprint(weekly_projects)


c['schedulers'].append(
    schedulers.Nightly(name='nightly',
                       codebases=codebases,
                       branch='master',
                       builderNames=nightly_projects,
                       hour=0, minute=0))

c['schedulers'].append(
    schedulers.Nightly(name='weekly',
                       codebases=codebases,
                       branch='master',
                       builderNames=weekly_projects,
                       dayOfWeek=5, hour=0, minute=0))
for worker in c['workers']:
	worker.max_builds = 1

c['www']['plugins']['badges'] = {
    "left_text": "Build Status",  # text on the left part of the image
    "left_color": "#555",  # color of the left part of the image
    "style": "flat",  # style of the template availables are "flat", "flat-square", "plastic"
    "template_name": "{style}.svg.j2",  # name of the template
    "font_face": "DejaVu Sans",
    "font_size": 11,
    "color_scheme": {  # color to be used for right part of the image
        "exception": "#007ec6",  # blue
        "failure": "#e05d44",    # red
        "retry": "#007ec6",      # blue
        "running": "#007ec6",    # blue
        "skipped": "a4a61d",     # yellowgreen
        "success": "#4c1",       # brightgreen
        "unknown": "#9f9f9f",    # lightgrey
        "warnings": "#dfb317"    # yellow
    }
}


EOF
	cat <<EOF >master/cfg.yml
env: {}
not_important_files: []
projects:
-   repository: https://github.com/13pgeiser/aafig.git
    branches:
    - master
    name: aafig
    vcs_type: git+poller
-   repository: https://github.com/13pgeiser/hieroglyph.git
    branches:
    - master
    name: hieroglyph
    vcs_type: git+poller
-   repository: https://github.com/13pgeiser/mscgen.git
    branches:
    - master
    name: mscgen
    vcs_type: git+poller
-   repository: https://github.com/13pgeiser/vim.git
    branches:
    - master
    name: vim
    vcs_type: git+poller
-   repository: https://github.com/13pgeiser/debian_chromebook_XE303C12.git
    branches:
    - master
    name: debian_chromebook_XE303C12
    vcs_type: git+poller
stages: []
workers:
-   name: buildbot_worker
    type: Worker
    password: pass

EOF
fi
buildbot start master
tail -f master/*.log


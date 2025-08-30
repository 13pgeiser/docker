import os
import shutil
import subprocess
import sys

from buildbot.plugins import changes, schedulers, steps, util, worker

repositories = os.environ['BUILDBOT_REPOS']
sys.stderr.write(repositories)
if repositories.find(';') == -1:
    repositories = repositories.split()
else:
    repositories = repositories.split(';')
url = os.environ['BUILDBOT_MASTER_URL']
c = BuildmasterConfig = {}
c['multiMaster'] = False
c['buildbotURL'] = url
c['logCompressionMethod'] = 'lz4'
c['logMaxSize'] = 1024*1024 # 1M
c['logMaxTailSize'] = 32768
c['logEncoding'] = 'utf-8'
c['buildbotNetUsageData'] = 'basic'
c['builders'] = []
c['change_source'] = []
c['schedulers'] = []
workers = os.environ['BUILDBOT_WORKERS'].split(';')
c['workers'] = [worker.Worker(worker_name, os.environ['BUILDBOT_WORKERS_PASS'], max_builds=1) for worker_name in workers]
c['protocols'] = {"pb": { "port": 9989 }}
# c['www'] = {
#     'port': 8010,
#     'plugins': {},
# }
c['www'] = dict(port=8010,
                plugins=dict(waterfall_view={}, console_view={}, grid_view={}))
c['db'] = {
    # This specifies what database buildbot uses to store its state.
    # It's easy to start with sqlite, but it's recommended to switch to a dedicated
    # database, such as PostgreSQL or MySQL, for use in production environments.
    # https://docs.buildbot.net/current/manual/configuration/global.html#database-specification
    'db_url' : "sqlite:///state.sqlite",
}

codebases = {}
weekly_projects = []

for repo in repositories:
    repo = repo.strip()
    print('%s' % repo)

def fetch_buildbot_config(repo_url, name):
    cwd = os.getcwd()
    config = None
    dot_buildbot = os.path.join(cwd, name, '.buildbot')
    if os.path.exists(dot_buildbot):
        with open(dot_buildbot, 'r') as f:
            config = f.read()
    return config

for repo in repositories:
    repo = repo.strip()
    name = os.path.basename(repo)
    print('%s -> %s' % (repo, name))
    f = util.BuildFactory()
    f.useProgress = True
    config = fetch_buildbot_config(repo, name)
    if config is None:
        print('Failed: %s' % name)
        continue
    f.addStep(steps.ShellCommand(command=util.Interpolate('sudo rm -rf  %(prop:builddir)s'), name='clean builddir'))
    f.addStep(steps.Git(repourl=repo, shallow=True, mode='full', method='clobber',submodules=True, name='git checkout'))
    f.addStep(steps.ShellCommand(command='docker system prune -a -f --volumes', name='docker system prune'))
    for step in config.split('\n'):
        step = step.strip()
        if not step:
            continue
        elif step.startswith('#'):
            continue
        elif step.startswith('bash '):
            f.addStep(steps.ShellCommand(command=['bash', '-c', step[5:]], timeout=3600, name=step[5:].strip()))
        elif step.startswith('directory_upload '):
            folder = os.path.splitext(name)[0]
            f.addStep(steps.DirectoryUpload(workersrc=step[17:], masterdest="/var/lib/buildbot/master/public_html/releases/" + folder, url=url[:url.rfind(':')] + '/releases/' + folder))
        else:
            raise Exception('unsupported step: ' + step)
    b = {
        "name": name,
        "workernames": workers,
        "factory": f,
    }
    c['builders'].append(b)
    weekly_projects.append(name)

print("Git steps finished")

for repo in repositories:
    repo = repo.strip()
    name = os.path.basename(repo)
    c['change_source'].append(changes.GitPoller(
        repourl=repo,
        branches=['master'],
        pollRandomDelayMin=1,
        pollRandomDelayMax=5*60))
    c['schedulers'].append(
        schedulers.AnyBranchScheduler(
            name=name,
            change_filter=util.ChangeFilter(repository=repo),
            treeStableTimer=2*60,
            builderNames=[name]))

c['schedulers'].append(
    schedulers.ForceScheduler(
        name="force",
        buttonName="pushMe!",
        builderNames=weekly_projects))

c['schedulers'].append(
    schedulers.Nightly(name='weekly',
                       branch='master',
                       builderNames=weekly_projects,
                       dayOfWeek=5, hour=0, minute=0))

import pprint
pp = pprint.PrettyPrinter(indent=4)
pp.pprint(c)

c['www']['plugins']['badges'] = {
    "left_text": "Build Status",  # text on the left part of the image
    "left_color": "#555",  # color of the left part of the image
    "style": "flat",  # style of the template availables are "flat", "flat-square", "plastic"
    "template_name": "{style}.svg.j2",  # name of the template
    "font_face": "DejaVu Sans",
    "font_size": 11,
    "color_scheme": {
        "exception": "#007ec6",
        "failure": "#e05d44",
        "retry": "#007ec6",
        "running": "#007ec6",
        "skipped": "#a4a61d",
        "success": "#4cff00",
        "unknown": "#9f9f9f",
        "warnings": "#dfb317"
    }
}
c['www']['plugins']['waterfall_view'] = True
c['www']['plugins']['console_view'] = True
c['www']['plugins']['grid_view'] = True

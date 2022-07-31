#!/bin/bash
export LC_ALL=C
pwd
ls -al
mkdir -p master
mkdir -p master/public_html/
if [ ! -e master/master.cfg ]; then
  buildbot create-master master
	cat <<'EOF' >master/master.cfg
import os
import shutil
import sys
import urllib.request

from buildbot.plugins import *
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
c['www'] = {
    'port': 8010,
    'plugins': {},
}
codebases = {}
weekly_projects = []

def fetch_buildbot_config(repo_url):
    cwd = os.getcwd()
    config = ''
    try:
        folder = 'test'
        shutil.rmtree(folder, ignore_errors=True)
        os.makedirs(folder)
        os.chdir(folder)
        os.system('git init')
        os.system('git remote add origin ' + repo_url)
        os.system('git config core.sparseCheckout true')
        with open('.git/info/sparse-checkout', 'w') as f:
            f.write('.buildbot\n')
        os.system('git pull --depth=1 origin master')
        with open('.buildbot', 'r') as f:
            config = f.read()
        shutil.rmtree(folder, ignore_errors=True)
    except Exception as e:
        raise Exception('%s -> %s' % (repo_url, str(e)))
    finally:
        os.chdir(cwd)
    return config

for repo in repositories:
    repo = repo.strip()
    name = os.path.basename(repo)
    print('%s -> %s' % (repo, name))
    f = util.BuildFactory()
    f.useProgress = True
    config = fetch_buildbot_config(repo)
    f.addStep(steps.Git(repourl=repo, shallow=True, mode='full', method='clobber'))
    f.addStep(steps.ShellCommand(command='docker system prune -a -f --volumes'))
    for step in config.split('\n'):
        step = step.strip()
        if not step:
            continue
        elif step.startswith('#'):
            continue
        elif step.startswith('bash '):
            f.addStep(steps.ShellCommand(command=step[5:], timeout=3600))
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
c['www']['plugins']['waterfall_view'] = True
c['www']['plugins']['console_view'] = True
c['www']['plugins']['grid_view'] = True
EOF
fi
cat master/master.cfg
cat <<EOF >buildbot.tac
import os
import sys

from twisted.application import service
from twisted.python.log import FileLogObserver
from twisted.python.log import ILogObserver

from buildbot.master import BuildMaster

basedir = os.environ.get("BUILDBOT_BASEDIR",
    os.path.abspath(os.path.dirname(__file__)))
configfile = 'master.cfg'

# note: this line is matched against to check that this is a buildmaster
# directory; do not edit it.
application = service.Application('buildmaster')
application.setComponent(ILogObserver, FileLogObserver(sys.stdout).emit)

m = BuildMaster(basedir, configfile, umask=None)
m.setServiceParent(application)
EOF
#buildbot start --nodaemon master
buildbot start master
tail -f master/*.log

#!/bin/bash
if [ ! -e worker ]; then
	buildbot-worker create-worker worker $BUILDBOT_MASTER $BUILDBOT_WORKER_NAME $BUILDBOT_WORKER_PASS
fi
sleep 1
docker info
buildbot-worker start --nodaemon worker 

#!/bin/bash
service docker start
sleep 1
docker info
buildbot-worker create-worker worker $BUILDBOT_MASTER $BUILDBOT_WORKER_NAME $BUILDBOT_WORKER_PASS
buildbot-worker start worker
tail -f worker/*.log

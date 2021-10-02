#!/bin/bash
docker run --privileged --rm -e BUILDBOT_MASTER="buildbot_master" -e BUILDBOT_WORKER_NAME="buildbot_worker" -e BUILDBOT_WORKER_PASS="buildbot_pass" -e USER="host_user" --network=buildbot -it buildbot_worker

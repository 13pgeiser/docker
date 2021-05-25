#!/bin/bash
docker run --privileged --rm -p 9989:9989 -e BUILDBOT_MASTER="localhost" -e BUILDBOT_WORKER_NAME="localhost" -e BUILDBOT_WORKER_PASS="buildbot_pass" --network=host -it buildbot_worker

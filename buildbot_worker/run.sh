#!/bin/bash
docker run -it --rm --name buildbot_worker -v /var/run/docker.sock:/var/run/docker.sock --network main_network buildbot_worker


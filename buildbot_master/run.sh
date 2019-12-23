#!/bin/bash
docker run -it --rm --name buildbot_master --network main_network -p 8010:8010 buildbot_master


#!/bin/bash
docker run --rm -p 8010:8010 -e BUILDBOT_REPOS="https://github.com/13pgeiser/sphinx-aafig.git;https://github.com/13pgeiser/sphinx-hieroglyph.git" -e BUILDBOT_WORKERS="localhost" -e BUILDBOT_WORKERS_PASS="buildbot_pass" -p 9989:9989 --network=host -it buildbot_master

#!/bin/bash
docker run --name buildbot_master --rm -p 8010:8010 -e BUILDBOT_REPOS="https://github.com/13pgeiser/gcc-x86_64-w64-mingw32-multilib.git;https://github.com/13pgeiser/sphinx-aafig.git;https://github.com/13pgeiser/sphinx-hieroglyph.git" -e BUILDBOT_WORKERS="buildbot_worker" -e BUILDBOT_WORKERS_PASS="buildbot_pass" -p 9989:9989 --network=buildbot -it buildbot_master

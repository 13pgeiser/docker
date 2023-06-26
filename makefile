# List of docker images & targets
DOCKERFILES=\
	apt_cacher_ng/Dockerfile \
	buildbot_master/Dockerfile \
	jupyter/Dockerfile \
	squid/Dockerfile \

# Path to the common M4 files.
M4_COMMON = `pwd`/_m4
M4 = m4

# Include local config if any
-include ../docker_config.mak

# Default rule for m4 -> build docker image!
%: %.m4
	$(M4) -I $(M4_COMMON) $^ >$@.tmp
	$(eval IS_DOCKERFILE := $(shell echo $@ | grep Dockerfile))
	if [ "$(IS_DOCKERFILE)" != "" ]; then cd $(dir $@) && docker build --rm -f Dockerfile.tmp -t $(shell dirname $@) . && docker image prune -f ; fi
	$(eval IMAGE_VERSION := $(shell cat $^ | grep "^# VERSION=" | cut -d "=" -f 2))
	if [ "$(IS_DOCKERFILE)" != "" ]; then if [ "$(IMAGE_VERSION)" != "" ]; then docker tag "$(shell dirname $@)" "$(REGISTRY)$(shell dirname $@):$(IMAGE_VERSION)" ; fi ; fi
	mv $@.tmp $@

# Build default, build all Dockerfiles, this will create the associated images.
all:	$(DOCKERFILES)

# Delete all Dockerfiles, this will force a rebuild.
clean:
	rm -f $(DOCKERFILES)

# Clean everything
mrproper: clean
	docker rmi -f `docker images -q` || true
	docker rm -f `docker ps -a -q` || true
	docker system prune -f -a

# Push to configure registry
push:
	for img in `docker image ls --format "{{.Repository}}:{{.Tag}}" | grep -v 'latest' | grep $(REGISTRY)` ; do docker push $$img ; done


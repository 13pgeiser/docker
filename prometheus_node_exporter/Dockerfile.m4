# vim:set ft=dockerfile:
# VERSION=1
include(`debian_base.m4')

RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
      prometheus-node-exporter \
      dumb-init \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

EXPOSE 9090
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["prometheus-node-exporter", "--path.procfs=/host/proc", "--path.sysfs=/host/sys", "--path.rootfs=/host", "--path.udev.data=/host/run/udev/data"]

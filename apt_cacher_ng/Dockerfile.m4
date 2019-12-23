# vim:set ft=dockerfile:
# VERSION=1
include(`debian_base.m4')

# Install apt-cacher-ng
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
    apt-cacher-ng \
    cron \
    curl \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN touch /var/log/cron.log \
    && sed -i '/.*allow CONNECT to everything/a PassThroughPattern: \.*' /etc/apt-cacher-ng/acng.conf \
    && sed -i 's/`#' VerboseLog: 1/VerboseLog: 1/' /etc/apt-cacher-ng/acng.conf \
    && mkdir -p /var/cache/apt-cacher-ng \
    && sed -i '/export HOSTNAME/a export ACNGREQ="?abortOnErrors=aOe&byPath=bP&byChecksum=bS&truncNow=tN&incomAsDamaged=iad&purgeNow=pN&doExpire=Start+Scan+and%2For+Expiration&calcSize=cs&asNeeded=an"' /etc/cron.daily/apt-cacher-ng \
    && sed -i 's/socket/socket --verbose/' /etc/cron.daily/apt-cacher-ng \
    && echo '*/5 *    * * *   root    /etc/cron.daily/apt-cacher-ng 2>&1 >>/var/log/cron.log' >>/etc/crontab \
    && echo '' >>/etc/crontab

EXPOSE 3142

CMD chmod 777 /var/cache/apt-cacher-ng && /etc/init.d/apt-cacher-ng start && /etc/init.d/cron start && tail -f /var/log/apt-cacher-ng/*

HEALTHCHECK CMD curl --fail http://localhost:3142/acng-report.html || exit 1


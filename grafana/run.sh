#!/bin/bash
# volume /var/lib/prometheus
docker run --network host --name grafana --rm -p 3000:3000 -it grafana

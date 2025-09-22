#!/bin/bash
# volume /var/lib/prometheus
docker run --network host -v '/run/systemd/:/run/systemd/:ro,rslave' -v '/:/host:ro,rslave' --name prometheus_node_exporter --rm -p 9100:9100 -it prometheus_node_exporter

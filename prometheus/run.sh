#!/bin/bash
# volume /var/lib/prometheus
docker run --network host --name prometheus --rm -p 9090:9090 -it prometheus

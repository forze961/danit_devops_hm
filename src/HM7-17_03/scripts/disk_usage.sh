#!/bin/bash

USAGE_PERCENTAGE=80
USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//')

if [ "$USAGE" -gt "$USAGE_PERCENTAGE" ]; then
    echo "$(date) WARNING: Disk usage exceeded $USAGE_PERCENTAGE%. Current usage: $USAGE%" >> /var/log/disk.log
fi

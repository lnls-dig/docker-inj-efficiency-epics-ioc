#!/usr/bin/env bash

set -u

if [ -z "$INJ_EFFICIENCY_INSTANCE" ]; then
    echo "Injection efficiency calculation instance is not set. Please use -d option" >&2
    exit 1
fi

/usr/bin/docker stop \
    inj-efficiency-epics-ioc-${INJ_EFFICIENCY_INSTANCE}

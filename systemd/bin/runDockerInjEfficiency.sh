#!/usr/bin/env bash

set -u

if [ -z "$INJ_EFFICIENCY_INSTANCE" ]; then
    echo "INJ_EFFICIENCY_INSTANCE environment variable is not set." >&2
    exit 1
fi

export INJ_EFFICIENCY_CURRENT_PV_AREA_PREFIX=INJ_EFFICIENCY_${INJ_EFFICIENCY_INSTANCE}_PV_AREA_PREFIX
export INJ_EFFICIENCY_CURRENT_PV_DEVICE_PREFIX=INJ_EFFICIENCY_${INJ_EFFICIENCY_INSTANCE}_PV_DEVICE_PREFIX
export INJ_EFFICIENCY_CURRENT_FIRST_ICT_PREFIX=INJ_EFFICIENCY_${INJ_EFFICIENCY_INSTANCE}_FIRST_ICT_PREFIX
export INJ_EFFICIENCY_CURRENT_SECOND_ICT_PREFIX=INJ_EFFICIENCY_${INJ_EFFICIENCY_INSTANCE}_SECOND_ICT_PREFIX
export INJ_EFFICIENCY_CURRENT_DEVICE_TELNET_PORT=INJ_EFFICIENCY_${INJ_EFFICIENCY_INSTANCE}_TELNET_PORT
# Only works with bash
export INJ_EFFICIENCY_PV_AREA_PREFIX=${!INJ_EFFICIENCY_CURRENT_PV_AREA_PREFIX}
export INJ_EFFICIENCY_PV_DEVICE_PREFIX=${!INJ_EFFICIENCY_CURRENT_PV_DEVICE_PREFIX}
export INJ_EFFICIENCY_FIRST_ICT_PREFIX=${!INJ_EFFICIENCY_CURRENT_FIRST_ICT_PREFIX}
export INJ_EFFICIENCY_SECOND_ICT_PREFIX=${!INJ_EFFICIENCY_CURRENT_SECOND_ICT_PREFIX}
export INJ_EFFICIENCY_DEVICE_TELNET_PORT=${!INJ_EFFICIENCY_CURRENT_DEVICE_TELNET_PORT}

if [ -z "$INJ_EFFICIENCY_FIRST_ICT_PREFIX" ]; then
    echo "First ICT charge monitor PV is not set. Please check the inj-efficiency-epics-ioc-mapping \ 
          file for the configuration of instance: $INJ_EFFICIENCY_INSTANCE" >&2
    exit 3
fi

if [ -z "$INJ_EFFICIENCY_SECOND_ICT_PREFIX" ]; then
    echo "Second ICT charge monitor PV is not set. Please check the inj-efficiency-epics-ioc-mapping \ 
          file for the configuration of instance: $INJ_EFFICIENCY_INSTANCE" >&2
    exit 3
fi

# Create volume for autosave and ignore errors
/usr/bin/docker create \
    -v /opt/epics/startup/ioc/inj-efficiency-epics-ioc/iocBoot/iocInjEfficiency/autosave \
    --name inj-efficiency-epics-ioc-${INJ_EFFICIENCY_INSTANCE}-volume \
    lnlsdig/inj-efficiency-epics-ioc:${IMAGE_VERSION} \
    2>/dev/null || true

# Remove a possible old and stopped container with
# the same name
/usr/bin/docker rm \
    inj-efficiency-epics-ioc-${INJ_EFFICIENCY_INSTANCE} || true

/usr/bin/docker run \
    --net host \
    -t \
    --rm \
    --volumes-from inj-efficiency-epics-ioc-${INJ_EFFICIENCY_INSTANCE}-volume \
    --name inj-efficiency-epics-ioc-${INJ_EFFICIENCY_INSTANCE} \
    lnlsdig/inj-efficiency-epics-ioc:${IMAGE_VERSION} \
    -t "${INJ_EFFICIENCY_DEVICE_TELNET_PORT}" \
    -f "${INJ_EFFICIENCY_FIRST_ICT_PREFIX}" \
    -s "${INJ_EFFICIENCY_SECOND_ICT_PREFIX}" \
    -P "${INJ_EFFICIENCY_PV_AREA_PREFIX}" \
    -R "${INJ_EFFICIENCY_PV_DEVICE_PREFIX}"

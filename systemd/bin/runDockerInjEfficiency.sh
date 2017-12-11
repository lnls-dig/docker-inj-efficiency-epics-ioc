#!/usr/bin/env bash

set -u

if [ -z "$INJ_EFFICIENCY_INSTANCE" ]; then
    echo "Injection efficiency calculation instance is not set. Please use -d option" >&2
    exit 1
fi

INJ_EFFICIENCY_NUMBER=$(echo ${INJ_EFFICIENCY_INSTANCE} | grep -Eo "[0-9]+");

if [ -z "$INJ_EFFICIENCY_NUMBER" ]; then
    echo "Injection efficiency calculation instance number is not set. Please check the \ 
          INJ_EFFICIENCY_INSTANCE environment variable" >&2
    exit 3
fi

export INJ_EFFICIENCY_CURRENT_PV_AREA_PREFIX=INJ_EFFICIENCY${INJ_EFFICIENCY_INSTANCE}_PV_AREA_PREFIX
export INJ_EFFICIENCY_CURRENT_PV_DEVICE_PREFIX=INJ_EFFICIENCY${INJ_EFFICIENCY_INSTANCE}_PV_DEVICE_PREFIX
export INJ_EFFICIENCY_CURRENT_FIRST_ICT_PV=INJ_EFFICIENCY${INJ_EFFICIENCY_INSTANCE}_FIRST_ICT_PV
export INJ_EFFICIENCY_CURRENT_SECOND_ICT_PV=INJ_EFFICIENCY${INJ_EFFICIENCY_INSTANCE}_SECOND_ICT_PV
# Only works with bash
export EPICS_PV_AREA_PREFIX=${!INJ_EFFICIENCY_CURRENT_PV_AREA_PREFIX}
export EPICS_PV_DEVICE_PREFIX=${!INJ_EFFICIENCY_CURRENT_PV_DEVICE_PREFIX}
export EPICS_FIRST_ICT_PV=${!INJ_EFFICIENCY_CURRENT_FIRST_ICT_PV}
export EPICS_SECOND_ICT_PV=${!INJ_EFFICIENCY_CURRENT_SECOND_ICT_PV}

if [ -z "$EPICS_FIRST_ICT_PV" ]; then
    echo "First ICT charge monitor PV is not set. Please check the inj-efficiency-epics-ioc-mapping \ 
          file for the configuration of the given INJ_EFFICIENCY_INSTANCE" >&2
    exit 3
fi

if [ -z "$EPICS_SECOND_ICT_PV" ]; then
    echo "Second ICT charge monitor PV is not set. Please check the inj-efficiency-epics-ioc-mapping \ 
          file for the configuration of the given INJ_EFFICIENCY_INSTANCE" >&2
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
    -f ${EPICS_FIRST_ICT_PV} \
    -s ${EPICS_SECOND_ICT_PV} \
    -P ${EPICS_PV_AREA_PREFIX} \
    -R ${EPICS_PV_DEVICE_PREFIX} \

# docker-inj-efficiency-epics-ioc
This repository contains the Dockerfile used to create the Docker image with the
[EPICS Soft IOC for injection efficiency calculation](https://github.com/lnls-dig/inj-efficiency-epics-ioc).

## Running the IOCs

The simples way to run the IOC is to run:

    docker run --rm -it --net host lnlsdig/inj-efficiency-epics-ioc -f ICT1PV -s ICT2PV

where `ICT1PV` is the name of the PV containing the charge measurement of the first ICT in an accelerator section, namely a 
transport line or the LINAC. Likewise, `ICT2PV` is the name of the PV containing the charge measurement of the second
ICT in an accelerator section. The efficiency value is the result of the division of the charge measured by the second ICT
by the charge measured by the first ICT. The options you can specify (after `lnlsdig/inj-efficiency-epics-ioc`):

- `-f ICT1PV`: Name of the PV monitoring the measurements of the first ICT (required)
- `-s ICT2PV`: Name of the PV monitoring the measurements of the second ICT (required)
- `-P PREFIX1`: the value of the EPICS `$(P)` macro used to prefix the PV names of Injection Efficiency Soft IOC
- `-R PREFIX2`: the value of the EPICS `$(R)` macro used to prefix the PV names of Injection Efficiency Soft IOC

## Creating a Persistent Container

If you want to create a persistent container to run the IOC, you can run a
command similar to:

    docker run -it --net host --restart always --name CONTAINER_NAME lnlsdig/inj-efficiency-epics-ioc -f ICT1PV -s ICT2PV

where `ICT1PV` and `ICT2PV` are as in the previous section and `CONTAINER_NAME` is the name
given to the container. You can also use the same options as described in the
previous section.

## Building the Image Manually

To build the image locally without downloading it from Docker Hub, clone the
repository and run the `docker build` command:

    git clone https://github.com/lnls-dig/inj-efficiency-epics-ioc
    docker build -t lnlsdig/inj-efficiency-epics-ioc docker-inj-efficiency-epics-ioc

#!/bin/sh
#Convenience script for building and running the docker image
BASEDIR="$( cd  "$(dirname $0)" && cd .. && pwd )"
sudo ${BASEDIR}/scripts/docker_build.sh
sudo ${BASEDIR}/scripts/docker_run.sh
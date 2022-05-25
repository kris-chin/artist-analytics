#!/bin/sh
BASEDIR="$( cd  "$(dirname $0)" && cd .. && pwd )"
docker build -t krischin/artist-data:dev "${BASEDIR}"
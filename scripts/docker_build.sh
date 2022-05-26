#!/bin/sh
BASEDIR="$( cd  "$(dirname $0)" && cd .. && pwd )"
docker build -ti krischin/artist-data:dev "${BASEDIR}"
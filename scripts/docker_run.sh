#!/bin/sh
BASEDIR="$( cd  "$(dirname $0)" && cd .. && pwd )"
export PORT=8888

#Sets up bind mounts on /output and /data so they can be accessed by the container
docker run \
--mount type=bind,source="${BASEDIR}"/output,target=/app/output \
--mount type=bind,source="${BASEDIR}"/data,target=/app/data \
-p $PORT:$PORT \
--rm \
--name artist_data \
krischin/artist-data:dev
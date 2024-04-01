#!/bin/sh

set -x

BIGQUERY_VERSION=$1
ARCH=$2
IMAGE_NAME=$3

sudo docker run --privileged --network=host --rm -v $(pwd):/work --platform=linux/$ARCH "${IMAGE_NAME}" \
    sh -c "chmod a+x /work/do-build.sh && /work/do-build.sh ${BIGQUERY_VERSION} ${ARCH}-linux-musl"

#!/bin/sh

set -x

BIGQUERY_VERSION=$1
GRPC_VERSION=$2
ARCH=$3
IMAGE_NAME=$4

sudo docker run --privileged --network=host --rm -v $(pwd):/work --platform=linux/$ARCH "${IMAGE_NAME}" \
    sh -c "chmod a+x /work/do-build.sh && /work/do-build.sh ${BIGQUERY_VERSION} ${GRPC_VERSION} ${ARCH} ${ARCH}-linux-musl"

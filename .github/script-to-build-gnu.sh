#!/bin/sh

set -x

BIGQUERY_VERSION=$1
ARCH=$2
IMAGE_NAME="ubuntu:20.04"

if [ "${ARCH}" = "aarch64" ]; then
    sudo docker run --privileged --network=host --platform=linux/arm64 --rm -v $(pwd):/work "${IMAGE_NAME}" \
        sh -c "chmod a+x /work/do-build.sh && /work/do-build.sh ${BIGQUERY_VERSION} ${ARCH}-linux-gnu"
else
    sudo docker run --privileged --network=host --platform=linux/amd64 --rm -v $(pwd):/work "${IMAGE_NAME}" \
        sh -c "chmod a+x /work/do-build.sh && /work/do-build.sh ${BIGQUERY_VERSION} ${ARCH}-linux-gnu"
fi

#!/bin/sh

set -x

BIGQUERY_VERSION=$1
GRPC_VERSION=$2
ARCH=$3
IMAGE_NAME="quay.io/pypa/manylinux2014_$ARCH:latest"

if [ "${ARCH}" = "riscv64" ]; then
    IMAGE_NAME="riscv64/ubuntu:22.04"
fi

sudo docker run --privileged --network=host --rm -v $(pwd):/work "${IMAGE_NAME}" \
    sh -c "chmod a+x /work/do-build.sh && /work/do-build.sh ${BIGQUERY_VERSION} ${GRPC_VERSION} ${ARCH} ${ARCH}-linux-gnu"

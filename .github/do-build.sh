#!/bin/sh

set -xe

BIGQUERY_VERSION=$1
TRIPLET=$2
PERFIX_DIR="/bigquery-${TRIPLET}"

case $TRIPLET in
     *-linux-gnu )
          yum install -y curl openssl-devel cmake git automake autoconf libtool
          ;;
     *-linux-musl )
          apk add make curl gcc g++ perl linux-headers cmake
          ;;
     * )
          echo "Unknown triplet: ${TRIPLET}"
          exit 1
          ;;
esac

# ------------ Compile everything ------------
make

# ------------ create tarball ------------

cd install
tar -czf "/work/bigquery-${TRIPLET}.tar.gz" .
cd /work
sha256sum "bigquery-${TRIPLET}.tar.gz" | tee "bigquery-${TRIPLET}.tar.gz.sha256"

#!/bin/sh

set -xe

BIGQUERY_VERSION=$1
TRIPLET=$2
PERFIX_DIR="/bigquery-${TRIPLET}"

case $TRIPLET in
     *-linux-gnu )
          yum install -y curl automake autoconf openssl-devel ncurses-devel perl-IPC-Cmd python3 cmake git
          ;;
     * )
          echo "Unknown triplet: ${TRIPLET}"
          exit 1
          ;;
esac

# ------------ Compile everything ------------
cd /work
make NPROC=2

# ------------ create tarball ------------

cd install
tar -czf "/work/bigquery-${BIGQUERY_VERSION}-${TRIPLET}.tar.gz" .
cd /work
sha256sum "bigquery-${BIGQUERY_VERSION}-${TRIPLET}.tar.gz" | tee "bigquery-${BIGQUERY_VERSION}-${TRIPLET}.tar.gz.sha256"

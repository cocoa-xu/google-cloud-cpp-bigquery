#!/bin/sh

set -xe

BIGQUERY_VERSION=$1
TRIPLET=$2
NPROC=${3:-2}
PERFIX_DIR="/bigquery-${TRIPLET}"

export DEBIAN_FRONTEND=noninteractive

case $TRIPLET in
     *-linux-gnu )
          # yum install -y curl automake autoconf openssl-devel ncurses-devel perl-IPC-Cmd python3 cmake git
          apt-get update
          apt-get install -y curl automake autoconf libssl-dev libncurses5-dev perl python3 cmake git gcc g++ build-essential libcurl4-openssl-dev
          ;;
     * )
          echo "Unknown triplet: ${TRIPLET}"
          exit 1
          ;;
esac

# ------------ Compile everything ------------
cd /work
make NPROC=${NPROC}

# ------------ create tarball ------------

export FILENAME="bigquery-${BIGQUERY_VERSION}-${TRIPLET}"
tar -czf "${FILENAME}.tar.gz" -C install .
sha256sum "${FILENAME}.tar.gz" | tee "${FILENAME}.tar.gz.sha256"

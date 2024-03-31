#!/bin/sh

set -x

BIGQUERY_VERSION=$1
GRPC_VERSION=$2
ARCH=$3
TRIPLET=$4
PERFIX_DIR="/bigquery-${TRIPLET}"

case $TRIPLET in
     riscv64-linux-gnu )
          apt-get update && \
               apt-get install -y gcc g++ curl cmake make automake autoconf libncurses5-dev perl python3
          ;;
     *-linux-gnu )
          yum install -y curl openssl-devel cmake git
          ;;
     *-linux-musl )
          apk add make curl gcc g++ perl linux-headers cmake
          ;;
     * )
          echo "Unknown triplet: ${TRIPLET}"
          exit 1
          ;;
esac

# ------------ gRPC ------------
cd /
git clone https://github.com/grpc/grpc.git
cd grpc
git checkout "v${GRPC_VERSION}"
git submodule update --init --recursive
cmake -S . -B "build-${TRIPLET}" -DCMAKE_BUILD_TYPE=Release
cd "build-${TRIPLET}"
make -j$(nproc)
make -j$(nproc) install

# ------------ google-cloud-cpp ------------

mkdir -p "${PERFIX_DIR}"
cd /
curl -fSL "https://github.com/googleapis/google-cloud-cpp/archive/refs/tags/v${BIGQUERY_VERSION}.tar.gz" -o "google-cloud-cpp-${BIGQUERY_VERSION}.tar.gz"

tar xf "google-cloud-cpp-${BIGQUERY_VERSION}.tar.gz"
cd "google-cloud-cpp-${BIGQUERY_VERSION}"

cmake -S . -B "build-${TRIPLET}" \
     -DCMAKE_INSTALL_PREFIX="${PERFIX_DIR}" \
     -DCMAKE_BUILD_TYPE=Release \
     -DBUILD_TESTING=OFF \
     -DGOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF \
     -DGOOGLE_CLOUD_CPP_ENABLE=bigquery
cd "build-${TRIPLET}"
make -j$(nproc)
make DESTDIR="/" install

# ------------ create tarball ------------

cd "${PERFIX_DIR}"
tar -czf "/work/bigquery-${TRIPLET}.tar.gz" .
cd /work
sha256sum "bigquery-${TRIPLET}.tar.gz" | tee "bigquery-${TRIPLET}.tar.gz.sha256"

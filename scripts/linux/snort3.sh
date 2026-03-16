#!/usr/bin/env bash

set -e

# Build and package Snort3

LIBDAQ_VERSION=3.0.15
LIBDNET_VERSION=1.14
FLEX_VERSION=2.6.4
HWLOC_VERSION=2.5.0
PCRE_VERSION=8.45
ZLIB_VERSION=1.2.13
SNORT_VER=3.2.2.0
ARCH=$(dpkg --print-architecture)

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    git libtool pkg-config autoconf gettext \
    libpcap-dev g++ vim make cmake wget libssl-dev \
    liblzma-dev python3-pip unzip protobuf-compiler \
    golang nano net-tools automake checkinstall

# Install Go
if [ "$ARCH" = "amd64" ]; then
    GO_BIN=go1.22.4.linux-amd64.tar.gz
elif [ "$ARCH" = "arm64" ]; then
    GO_BIN=go1.22.4.linux-arm64.tar.gz
else
    echo "Unsupported architecture"
    exit 1
fi
wget https://go.dev/dl/${GO_BIN}
tar -xvf ${GO_BIN}
sudo mv go /usr/local
rm -rf ${GO_BIN}
export PATH=$PATH:/usr/local/go/bin

# Install protoc-gen-go and protoc-gen-go-grpc
go install github.com/golang/protobuf/protoc-gen-go@v1.5.2
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0
sudo mv ~/go/bin/protoc-gen-go /usr/local/bin/
sudo mv ~/go/bin/protoc-gen-go-grpc /usr/local/bin/

WORK_DIR=/work
sudo mkdir -p $WORK_DIR
sudo chmod 777 $WORK_DIR

cd $WORK_DIR
wget https://github.com/snort3/libdaq/archive/refs/tags/v${LIBDAQ_VERSION}.tar.gz -O v${LIBDAQ_VERSION}.tar.gz
tar -xvf v${LIBDAQ_VERSION}.tar.gz
cd libdaq-${LIBDAQ_VERSION}
./bootstrap && ./configure && make
sudo checkinstall --pkgname=libdaq --pkgversion=${LIBDAQ_VERSION} --backup=no --deldoc=yes --fstrans=no --default
sudo mv libdaq_${LIBDAQ_VERSION}-1_amd64.deb $WORK_DIR || true
cd $WORK_DIR
rm -rf v${LIBDAQ_VERSION}.tar.gz

# Remaining build steps omitted for brevity in helper script
echo "Snort3 helper script finished (partial)."

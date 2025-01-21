#!/usr/bin/env bash

# Variables
SNORT_VER=${SNORT_VER:-3.6.1.0}
DEBUG=${DEBUG:-}

source ./.utils.sh

# Saving current directory
CURRENT_DIR=$(pwd)

# Tmp directory
WORKDIR=$(mktemp -d)
cd $WORKDIR

# Cleanup function
cleanup() {
    cd $CURRENT_DIR
    rm -rf $WORKDIR
}
trap cleanup EXIT

# Update system and install dependencies
maybe_sudo apt-get update && maybe_sudo apt-get install -y --no-install-recommends \
    build-essential checkinstall curl autoconf automake libtool \
    pkg-config ca-certificates cmake
    
# Build snort3
curl -sSL -L https://github.com/snort3/snort3/archive/refs/tags/${SNORT_VER}.tar.gz | tar -xz
cd snort3-${SNORT_VER}
./configure_cmake.sh --prefix=/usr/local
cd build
make -j $(nproc)
checkinstall --pkgname=snort3 --pkgversion=${SNORT_VER} --backup=no --deldoc=yes --fstrans=no --default

mv *.deb $BUILD_DIR

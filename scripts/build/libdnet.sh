#!/usr/bin/env bash

# Variables
LIBDNET_VERSION=${LIBDNET_VERSION:-1.18.0}

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
    ca-certificates pkg-config check
    
# Build libdnet
curl -sSL -L https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-${LIBDNET_VERSION}.tar.gz | tar -xz
cd libdnet-libdnet-${LIBDNET_VERSION}
./configure && make
checkinstall --pkgname=libdnet --pkgversion=${LIBDNET_VERSION} --backup=no --deldoc=yes --fstrans=no --default

mv *.deb $BUILD_DIR

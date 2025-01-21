#!/usr/bin/env bash

# Variables
ZLIB_VERSION=${ZLIB_VERSION:-1.3.1}

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
    pkg-config gperf texinfo bison flex texlive ca-certificates
    
# Build zlib
curl -sSL -L https://github.com/madler/zlib/releases/download/v${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz | tar -xz
cd zlib-${ZLIB_VERSION}
./configure && make
checkinstall --pkgname=zlib --pkgversion=${ZLIB_VERSION} --backup=no --deldoc=yes --fstrans=no --default

mv *.deb $BUILD_DIR

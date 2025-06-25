#!/usr/bin/env bash

# Variables
LIBDAQ_VERSION=${LIBDAQ_VERSION:-3.0.17}

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
    
# Build libdaq
curl -sSL -L https://github.com/snort3/libdaq/archive/refs/tags/v${LIBDAQ_VERSION}.tar.gz | tar -xz
cd libdaq-${LIBDAQ_VERSION}
./bootstrap && ./configure && make
checkinstall --pkgname=libdaq --pkgversion=${LIBDAQ_VERSION} --backup=no --deldoc=yes --fstrans=no --default

mv *.deb $BUILD_DIR

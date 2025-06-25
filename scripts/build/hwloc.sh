#!/usr/bin/env bash

# Variables
HWLOC_VERSION=${HWLOC_VERSION:-2.11}
HWLOC_VERSION_FINE=${HWLOC_VERSION_FINE:-2.11.2}

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
    build-essential checkinstall curl ca-certificates
    
# Build hwloc
curl -sSL https://download.open-mpi.org/release/hwloc/v${HWLOC_VERSION}/hwloc-${HWLOC_VERSION_FINE}.tar.gz | tar -xz
ls -lah .
cd hwloc-${HWLOC_VERSION_FINE}
./configure && make
checkinstall --pkgname=hwloc --pkgversion=${HWLOC_VERSION} --backup=no --deldoc=yes --fstrans=no --default

mv *.deb $BUILD_DIR

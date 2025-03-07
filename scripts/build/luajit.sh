#!/usr/bin/env bash

# Variables
LUAJIT_VERSION=${LUAJIT_VERSION:-2.1.0}

source ./.utils.sh

# Disable interactive prompts
export DEBIAN_FRONTEND=noninteractive

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
    pkg-config ca-certificates git
    
# Build luajit
git clone https://luajit.org/git/luajit.git
cd luajit
make
checkinstall --pkgname=luajit --pkgversion=${LUAJIT_VERSION} --backup=no --deldoc=yes --fstrans=no --default

mv *.deb $BUILD_DIR

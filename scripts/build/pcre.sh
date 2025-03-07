#!/usr/bin/env bash

# Variables
PCRE2_VERSION=${PCRE2_VERSION:-10.44}

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
    pkg-config ca-certificates
    
# Build pcre2
curl -sSL -L https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz | tar -xz
cd pcre2-${PCRE2_VERSION}
./configure && make
checkinstall --pkgname=pcre --pkgversion=${PCRE2_VERSION} --backup=no --deldoc=yes --fstrans=no --default

mv *.deb $BUILD_DIR

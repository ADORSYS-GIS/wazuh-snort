#!/usr/bin/env bash

# Variables
FLEX_VERSION=${FLEX_VERSION:-2.6.4}

source ./.utils.sh

info_message "Building flex..."

# Disable interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Saving current directory
CURRENT_DIR=$(pwd)

# Tmp directory
WORKDIR=$(mktemp -d)
cd $WORKDIR

# Cleanup function
cleanup() {
    info_message "Cleaning up..."
    cd $CURRENT_DIR
    rm -rf $WORKDIR
}
trap cleanup EXIT

info_message "Building flex version: $FLEX_VERSION"
# Update system and install dependencies
maybe_sudo apt-get update && maybe_sudo apt-get install -y --no-install-recommends \
    build-essential checkinstall curl autoconf automake libtool \
    pkg-config ca-certificates

info_message "Building flex..."    
# Build flex
curl -sSL https://github.com/westes/flex/releases/download/v${FLEX_VERSION}/flex-${FLEX_VERSION}.tar.gz | tar -xz
cd flex-${FLEX_VERSION}
./configure && make
checkinstall --pkgname=flex --pkgversion=${FLEX_VERSION} --backup=no --deldoc=yes --fstrans=no --default

info_message "Moving flex deb package to parent directory..."
mv *.deb $BUILD_DIR

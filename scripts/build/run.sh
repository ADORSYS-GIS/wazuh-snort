#!/usr/bin/env bash

INSTALL_DEPS=${INSTALL_DEPS:-0}

source ./.utils.sh

# Ensure BUILD_DIR folder exists
mkdir -p $BUILD_DIR

info_message "============================================"
if [ "$INSTALL_DEPS" -eq 1 ]; then
    if ! (maybe_sudo env bash ./deps.sh) 2>&1; then
        error_message "Failed to install dependencies"
        exit 1
    fi
fi

info_message "============================================"
if ! (maybe_sudo env bash ./flex.sh) 2>&1; then
    error_message "Failed to build flex"
    exit 1
fi

info_message "============================================"
if ! (maybe_sudo env bash ./hwloc.sh) 2>&1; then
    error_message "Failed to build hwloc"
    exit 1
fi

info_message "============================================"
if ! (maybe_sudo env bash ./libdaq.sh) 2>&1; then
    error_message "Failed to build libdaq"
    exit 1
fi

info_message "============================================"
if ! (maybe_sudo env bash ./libdnet.sh) 2>&1; then
    error_message "Failed to build libdnet"
    exit 1
fi

info_message "============================================"
if ! (maybe_sudo env bash ./luajit.sh) 2>&1; then
    error_message "Failed to build luajit"
    exit 1
fi

info_message "============================================"
if ! (maybe_sudo env bash ./pcre.sh) 2>&1; then
    error_message "Failed to build pcre"
    exit 1
fi

info_message "============================================"
if ! (maybe_sudo env bash ./zlib.sh) 2>&1; then
    error_message "Failed to build zlib"
    exit 1
fi

info_message "============================================"
if ! (maybe_sudo env bash ./snort.sh) 2>&1; then
    error_message "Failed to build snort"
    exit 1
fi

info_message "============================================"
info_success "Snort 3 packaging is complete."

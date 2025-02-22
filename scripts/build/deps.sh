#!/usr/bin/env bash

source ./.utils.sh

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

info_message "Install GO"
# Install Go
if [ "$ARCH" = "amd64" ]; then
    GO_BIN=go1.22.4.linux-amd64.tar.gz
elif [ "$ARCH" = "arm64" ]; then
    GO_BIN=go1.22.4.linux-arm64.tar.gz
else
    echo "Unsupported architecture"
    exit 1
fi

info_message "Prepare dependencies"
# Update system and install dependencies
maybe_sudo apt-get update \
  && maybe_sudo apt-get install -y --no-install-recommends \
    git libtool pkg-config autoconf gettext \
    libpcap-dev g++ vim make cmake wget libssl-dev \
    liblzma-dev python3-pip unzip protobuf-compiler \
    golang nano net-tools automake checkinstall curl

curl -sSL https://go.dev/dl/${GO_BIN} | tar -xvz
maybe_sudo rm -rf /usr/local/go
maybe_sudo mv go /usr/local

export PATH=$PATH:/usr/local/go/bin

# Install protoc-gen-go and protoc-gen-go-grpc
go install github.com/golang/protobuf/protoc-gen-go@v1.5.2
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0
mv ~/go/bin/protoc-gen-go /usr/local/bin/
mv ~/go/bin/protoc-gen-go-grpc /usr/local/bin/
# Use the base Ubuntu 20.04 image
FROM --platform=$BUILDPLATFORM ubuntu:20.04

# Disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies and clean up in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    git libtool pkg-config autoconf gettext \
    libpcap-dev g++ vim make cmake wget libssl-dev \
    liblzma-dev python3-pip unzip protobuf-compiler \
    golang nano net-tools automake \
    && rm -rf /var/lib/apt/lists/*

# Determine architecture and download appropriate Go version
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
    GO_BIN=go1.22.4.linux-amd64.tar.gz; \
    elif [ "$ARCH" = "arm64" ]; then \
    GO_BIN=go1.22.4.linux-arm64.tar.gz; \
    else \
    echo "Unsupported architecture"; exit 1; \
    fi && \
    wget https://go.dev/dl/${GO_BIN} && \
    tar -xvf ${GO_BIN} && \
    mv go /usr/local && \
    rm -rf ${GO_BIN}
ENV PATH=$PATH:/usr/local/go/bin
RUN ln -s /usr/local/go/bin/go /usr/local/bin/go

# Install protoc-gen-go and protoc-gen-go-grpc tools
RUN go install github.com/golang/protobuf/protoc-gen-go@v1.5.2 && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0 && \
    mv /root/go/bin/protoc-gen-go /usr/local/bin/ && \
    mv /root/go/bin/protoc-gen-go-grpc /usr/local/bin/

# Create working directories
RUN mkdir /work /packages

# Copy Snort rules
COPY rules/snort3.rules /work/

# build libdaq
ENV LIBDAQ_VERSION=3.0.15
RUN cd /work && wget https://github.com/snort3/libdaq/archive/refs/tags/v${LIBDAQ_VERSION}.tar.gz
RUN cd /work && tar -xvf v${LIBDAQ_VERSION}.tar.gz
RUN cd /work/libdaq-${LIBDAQ_VERSION} && ./bootstrap && ./configure && make && make install
RUN cd /work && rm -rf v${LIBDAQ_VERSION}.tar.gz

# Install libdnet
ENV LIBDNET_VERSION=1.14
RUN cd /work && wget https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-${LIBDNET_VERSION}.tar.gz && \
    tar -xvf libdnet-${LIBDNET_VERSION}.tar.gz && \
    cd libdnet-libdnet-${LIBDNET_VERSION} && \
    wget -O config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' && \
    wget -O config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' && \
    ./configure && make && make install && \
    cd /work && rm -rf libdnet-libdnet-${LIBDNET_VERSION} libdnet-${LIBDNET_VERSION}.tar.gz

# Install flex
ENV FLEX_VERSION=2.6.4
RUN cd /work && wget https://github.com/westes/flex/files/981163/flex-${FLEX_VERSION}.tar.gz && \
    tar -xvf flex-${FLEX_VERSION}.tar.gz && \
    cd flex-${FLEX_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf flex-${FLEX_VERSION} flex-${FLEX_VERSION}.tar.gz

# Install hwloc
ENV HWLOC_VERSION=2.5.0
RUN cd /work && wget https://download.open-mpi.org/release/hwloc/v2.5/hwloc-${HWLOC_VERSION}.tar.gz && \
    tar -xvf hwloc-${HWLOC_VERSION}.tar.gz && \
    cd hwloc-${HWLOC_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf hwloc-${HWLOC_VERSION} hwloc-${HWLOC_VERSION}.tar.gz

# Install LuaJIT
ENV LUAJIT_VERSION=2.1.0-beta3
RUN cd /work && wget https://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.tar.gz && \
    tar -xvf LuaJIT-${LUAJIT_VERSION}.tar.gz && \
    cd LuaJIT-${LUAJIT_VERSION} && make && make install && \
    cd /work && rm -rf LuaJIT-${LUAJIT_VERSION} LuaJIT-${LUAJIT_VERSION}.tar.gz

# Install PCRE
ENV PCRE_VERSION=8.45
RUN cd /work && wget https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz && \
    tar -xvf pcre-${PCRE_VERSION}.tar.gz && \
    cd pcre-${PCRE_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf pcre-${PCRE_VERSION} pcre-${PCRE_VERSION}.tar.gz

# Install zlib
ENV ZLIB_VERSION=1.2.13
RUN cd /work && wget https://github.com/madler/zlib/releases/download/v${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz && \
    tar -xvf zlib-${ZLIB_VERSION}.tar.gz && \
    cd zlib-${ZLIB_VERSION} && ./configure && make && make install && \
    cd /work && rm -rf zlib-${ZLIB_VERSION} zlib-${ZLIB_VERSION}.tar.gz

# Install Snort 3
ENV SNORT_VER=3.2.2.0
RUN cd /work && wget https://github.com/snort3/snort3/archive/refs/tags/${SNORT_VER}.tar.gz && \
    tar -xvf ${SNORT_VER}.tar.gz && \
    cd snort3-${SNORT_VER} && export my_path=/usr/local && ./configure_cmake.sh --prefix=$my_path && \
    cd build && make -j$(nproc) install && \
    cd /work && rm -rf snort3-${SNORT_VER} ${SNORT_VER}.tar.gz

# Move Snort rules to appropriate directory
RUN mv /work/snort3.rules /usr/local/etc/snort

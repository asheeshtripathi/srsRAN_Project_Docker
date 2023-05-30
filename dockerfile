#Deriving the latest base image
FROM    ubuntu:jammy

#Labels as key value pair
LABEL Maintainer="asheeshtripathi"

# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         security_updates_as_of 2023-05-15

# This will make apt-get install without question
ARG     DEBIAN_FRONTEND=noninteractive
ARG     UHD_TAG=v4.1.0.6
ARG     MAKEWIDTH=$(nproc)

# Install security updates and required packages
RUN     apt-get update
RUN     apt-get -y install -q \
                build-essential \
                ccache \
                git \
                python3-dev \
                python3-pip \
                curl \
                gnome-terminal


# Any working directory can be chosen as per choice like '/' or '/home' etc

# Install UHD dependencies
RUN         apt-get -y install -q \
                autoconf \
                automake \
                cpufrequtils \
                ethtool \
                g++ \
                libncurses5 \
                libncurses5-dev \
                inetutils-tools \
                libboost-all-dev \
                libusb-1.0-0 \
                libusb-1.0-0-dev \
                libudev-dev \
                python3-mako \
                doxygen \
                python3-docutils \
                python3-scipy \
                python3-setuptools \
                cmake \
                python3-requests \
                python3-numpy \
                dpdk \
                python3-ruamel.yaml \
                libdpdk-dev



RUN     mkdir -p /usr/local/src
RUN     git clone https://github.com/EttusResearch/uhd.git /usr/local/src/uhd
RUN     cd /usr/local/src/uhd/ && git checkout $UHD_TAG
RUN     mkdir -p /usr/local/src/uhd/host/build
WORKDIR /usr/local/src/uhd/host/build
RUN     cmake .. -DENABLE_PYTHON3=ON -DUHD_RELEASE_MODE=release -DCMAKE_INSTALL_PREFIX=/usr
RUN     make -j$(nproc)
RUN     make install
RUN     uhd_images_downloader

RUN     apt update

RUN     DEBIAN_FRONTEND=noninteractive apt install -y \
                cmake \
                make \
                gcc \
                g++ \
                pkg-config \
                libfftw3-dev \
                libmbedtls-dev \
                libsctp-dev \
                libyaml-cpp-dev \
                libgtest-dev

#  useful to minimize the size of each layer
RUN rm -rf /var/lib/apt/lists/*

# srsRAN project installation
WORKDIR /srsran

# Pinned git commit used for this example
#23.5
ARG COMMIT=49a07c7

# Download and build
RUN     git clone https://github.com/srsran/srsRAN_Project.git ./
#RUN    git fetch origin ${COMMIT}
RUN     git checkout ${COMMIT}
WORKDIR /srsran
RUN     mkdir build
WORKDIR /srsran/build

RUN     cmake ../
RUN     make -j $(nproc)
#RUN    make test -j $(nproc)
RUN     make -j $(nproc) install

# Update dynamic linker
RUN     apt-get update
RUN     apt-get install net-tools -y
RUN     apt-get install vim -y
RUN     ldconfig


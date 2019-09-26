# This dockerfile is meant to serve as a rocm base image.  It registers the debian rocm package repository, and
# installs the rocm-dev package.

# modified version of https://github.com/RadeonOpenCompute/ROCm-docker/blob/master/dev/Dockerfile-ubuntu-18.04

FROM ubuntu:18.04

# Register the ROCM package repository, and install rocm-dev package
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl libnuma-dev gnupg \
  && curl -sL http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | apt-key add - \
  && printf "deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main" | tee /etc/apt/sources.list.d/rocm.list \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  sudo \
  libelf1 \
  rocm-dev \
  cmake \
  git \
  wget \
  unzip \
  build-essential && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV PATH "${PATH}:/opt/rocm/bin"

RUN mkdir /custom
WORKDIR /custom

# install rocPRIM
RUN wget https://github.com/ROCmSoftwarePlatform/rocPRIM/archive/develop.zip -O rocPRIM-develop.zip
RUN unzip rocPRIM-develop.zip -d rocPRIM
WORKDIR /custom/rocPRIM/rocPRIM-develop
RUN mkdir build
WORKDIR /custom/rocPRIM/rocPRIM-develop/build
RUN CXX=hcc cmake ../.
RUN make
RUN make install

# install rocThrust
RUN wget https://github.com/ROCmSoftwarePlatform/rocThrust/archive/develop.zip -O rocThrust-develop.zip
RUN unzip rocThrust-develop.zip -d rocThrust
WORKDIR /custom/rocThrust/rocThrust-develop
RUN mkdir build
WORKDIR /custom/rocThrust/rocThrust-develop/build
RUN CXX=hcc cmake ../.
RUN make
RUN make install

# Default to a login shell
WORKDIR /root
CMD ["bash", "-l"]

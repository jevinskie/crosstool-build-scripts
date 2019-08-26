#!/bin/bash

DOCKER_IMAGE_NAME=lm32-gcc-toolchain
DOCKER_DISTRO=ubuntu:18.04

Dockerfile=$(cat << EOF
FROM ${DOCKER_DISTRO}
RUN apt-get update
RUN apt-get install --no-install-recommends -yy wget ca-certificates build-essential
RUN mkdir -p /Users
RUN useradd -d /Users/${USER} -m -u ${UID} ${USER}
USER ${USER}
ENV HOME /Users/${USER}
RUN /bin/bash
EOF
)

docker pull ${DOCKER_DISTRO}
docker build -t ${DOCKER_IMAGE_NAME} - <<< "${Dockerfile}"

docker run --net=host --rm=true --user="${USER}" \
 -e CCACHE_DIR=/ccache -v "${HOME}/.ccache":/ccache \
 -w "${PWD}" -v "${HOME}":"/Users/${USER}" -t ${DOCKER_IMAGE_NAME} ./build-lm32-toolchain.sh
 # -w "${PWD}" -t ${DOCKER_IMAGE_NAME} ./build-lm32-toolchain.sh

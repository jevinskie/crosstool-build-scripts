#!/bin/bash

DOCKER_IMAGE_NAME=lm32-gcc-toolchain
DOCKER_DISTRO=ubuntu:18.04

Dockerfile=$(cat << EOF
FROM ${DOCKER_DISTRO}
RUN apt-get update
RUN apt-get install --no-install-recommends -yy wget ca-certificates build-essential
RUN useradd -d /home/${USER} -m -u ${UID} ${USER}
USER ${USER}
ENV HOME /home/${USER}
RUN /bin/bash
EOF
)

docker pull ${DOCKER_DISTRO}
docker build -t ${DOCKER_IMAGE_NAME} - <<< "${Dockerfile}"

docker run --net=host --rm=true --user="${USER}" \
 -e CCACHE_DIR=/ccache -v "${HOME}/.ccache":/ccache \
 -w "${PWD}" -v "${HOME}":"/home/${USER}" -t ${DOCKER_IMAGE_NAME} /home/${USER}/$(realpath --relative-to ~ ./hello.sh)
 # -w "${PWD}" -v "${HOME}":"/home/${USER}" -t ${DOCKER_IMAGE_NAME} /home/${USER}/$(realpath --relative-to ~ ./build-lm32-toolchain.sh)
 # -w "${PWD}" -t ${DOCKER_IMAGE_NAME} ./build-lm32-toolchain.sh

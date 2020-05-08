#!/bin/bash

set -euo pipefail

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" sudo --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" visudo -c
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'sudo microdnf install sudo'

docker run --rm -eDOCKER_CLI_EXPERIMENTAL=enabled "${DOCKER_IMAGE}:${TAG}" docker buildx version
docker run --rm "${DOCKER_IMAGE}:${TAG}" docker --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" git --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" which --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" which git

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'date | grep -E "CES?T"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'locale | grep -E LC_ALL=.+\.UTF-8'

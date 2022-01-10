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


docker run --rm "${DOCKER_IMAGE}:${TAG}" bash --version

docker run --rm "${DOCKER_IMAGE}:${TAG}" java -version
docker run --rm "${DOCKER_IMAGE}:${TAG}" mvn --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -XshowSettings:properties -version |& grep "file.encoding = UTF-8"'

# Test Maven
docker run --rm -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/":/opt/app-root/src:cached "${DOCKER_IMAGE}:${TAG}" mvn -q --batch-mode clean package
docker run --rm -eSPRING_MAIN_BANNER-MODE=off -e JAVA_OPTS="-Dspring.mandatory-file-encoding=UTF-8" -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/target/dockerhub-pipeline-images-test-jar.jar":/opt/app-root/src/app.jar "${DOCKER_IMAGE}:${TAG}"

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -version 2>&1 | grep -q "build 17"'


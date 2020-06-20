#!/bin/bash

set -euo pipefail

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" sudo --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" visudo -c
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'sudo microdnf install sudo'

docker run --rm -eDOCKER_CLI_EXPERIMENTAL=enabled "${DOCKER_IMAGE}:${TAG}" docker buildx version
docker run --rm "${DOCKER_IMAGE}:${TAG}" docker --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" java -version
docker run --rm "${DOCKER_IMAGE}:${TAG}" mvn --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" google-chrome-stable --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" firefox --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" oc version
docker run --rm "${DOCKER_IMAGE}:${TAG}" skopeo -v

docker run --rm "${DOCKER_IMAGE}:${TAG}" git --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" ip -V
docker run --rm "${DOCKER_IMAGE}:${TAG}" rush -V
docker run --rm "${DOCKER_IMAGE}:${TAG}" gcc --version

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'date | grep -E "CES?T"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'locale | grep -E LC_ALL=.+\.UTF-8'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -XshowSettings:properties -version |& grep "file.encoding = UTF-8"'

docker run --rm "${DOCKER_IMAGE}:${TAG}" skopeo copy docker://docker.io/library/alpine dir:///tmp/alpine.tar

# Default should be java 8
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -version 2>&1 | grep -q "build 1\.8"'

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'jabba use system@1.8 && java -version 2>&1 | grep -q "build 1\.8"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'jabba use system@1.11 && java -version 2>&1 | grep -q "build 11"'

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 10 node --version | grep -q "node v10"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 12 node --version | grep -q "node v12"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 14 node --version | grep -q "node v14"'

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 10 node --version'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 12 node --version'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 14 node --version'

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 10 npm --version'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 12 npm --version'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 14 npm --version'

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 10 yarn --version'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 12 yarn --version'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'nvm exec 14 yarn --version'

chmod -R 777 "$(git rev-parse --show-toplevel)/test-applications/"

# Test node package managers
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install iconv'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'yarn add iconv'

# Test Maven
docker run --rm -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/":/opt/app-root/src:cached "${DOCKER_IMAGE}:${TAG}" mvn -q --batch-mode clean package
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'ldd /usr/lib/libtcnative-1.so | grep -vz "=> not found"'
# Test Headless chrome via angular
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install puppeteer && ldd ./node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome | grep -vz "=> not found"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install puppeteer && ./node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome --version'
docker run --rm -eCI=1 -v "$(git rev-parse --show-toplevel)/test-applications/js/example-app/":/opt/app-root/src/:cached "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install && npx ng test --watch=false --code-coverage --browsers ChromeHeadlessNoSandbox'

docker run --rm -eSPRING_MAIN_BANNER-MODE=off -e JAVA_OPTS="-Dspring.mandatory-file-encoding=UTF-8" -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/target/dockerhub-pipeline-images-test-jar.jar":/opt/app-root/src/app.jar "${DOCKER_IMAGE}:${TAG}"

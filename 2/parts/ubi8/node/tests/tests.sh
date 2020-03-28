#!/bin/bash

docker run --rm "${DOCKER_IMAGE}:${TAG}" gcc --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" node --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" npm --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" yarn --version

# Test node package managers
docker run --rm "${DOCKER_IMAGE}:${TAG}" npm install iconv
docker run --rm "${DOCKER_IMAGE}:${TAG}" yarn add iconv

# Test Headless chrome
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install puppeteer && ldd ./node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome | grep -vz "=> not found"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install puppeteer && ./node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome --version'

# Test Headless firefox
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install puppeteer-firefox && ./node_modules/puppeteer-firefox/.local-browser/firefox-linux-*/firefox/firefox --version'

# Test Headless chrome via angular
docker run --rm -eCI=1 -v "$(git rev-parse --show-toplevel)/test-applications/js/example-app/":/opt/app-root/src/:cached "${DOCKER_IMAGE}:${TAG}" bash -c 'npm install && npx ng test --watch=false --code-coverage --browsers ChromeHeadlessNoSandbox'

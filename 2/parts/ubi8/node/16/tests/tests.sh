#!/bin/bash

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'node --version | grep -q "v16"'

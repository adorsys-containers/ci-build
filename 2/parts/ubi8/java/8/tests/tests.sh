docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -version 2>&1 | grep -q "build 1\.8"'

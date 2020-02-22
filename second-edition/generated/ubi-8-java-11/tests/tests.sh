
#!/bin/bash

set -euo pipefail

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" docker --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" git --version

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'date | grep -E "CES?T"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'locale | grep -E LC_ALL=.+\.UTF-8'

#!/bin/bash

docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -version 2>&1 | grep -q "build 11"'


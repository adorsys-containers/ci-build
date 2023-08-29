#!/bin/bash

echo "version: '3'" > docker-compose.yml
echo "services:" >> docker-compose.yml

FLAVORS=(
  "ubi-8-java-8"
  "ubi-8-java-11"
  "ubi-8-java-17"
  "ubi-8-node-10"
  "ubi-8-node-12"
  "ubi-8-node-14"
  "ubi-8-node-16"
  "ubi-8-node-18"
  "ubi-8-java-8-node-10"
  "ubi-8-java-11-node-10"
  "ubi-8-java-17-node-10"
  "ubi-8-java-8-node-12"
  "ubi-8-java-11-node-12"
  "ubi-8-java-17-node-12"
  "ubi-8-java-8-node-14"
  "ubi-8-java-11-node-14"
  "ubi-8-java-17-node-14"
  "ubi-8-java-8-node-16"
  "ubi-8-java-11-node-16"
  "ubi-8-java-17-node-16"
  "ubi-8-java-17-node-18"
)

rm -rf generated
mkdir -p generated

for FLAVOR in "${FLAVORS[@]}"; do
  mkdir -p "generated/${FLAVOR}/tests"
  echo > "generated/${FLAVOR}/Dockerfile"
  echo > "generated/${FLAVOR}/tests/tests.sh"
  echo -e '#!/bin/bash\n' >> "generated/${FLAVOR}/tests/tests.sh"

  if [[ "${FLAVOR}" =~ ubi-([0-9]+) ]]; then
    UBI_VERSION="${BASH_REMATCH[1]}"

    grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/base/Dockerfile" >> "generated/${FLAVOR}/Dockerfile"
    grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/base/tests/tests.sh" >> "generated/${FLAVOR}/tests/tests.sh"
    echo >> "generated/${FLAVOR}/Dockerfile"
    echo >> "generated/${FLAVOR}/tests/tests.sh"

    if [[ "${FLAVOR}" =~ java-([0-9]+) ]]; then
      JAVA_VERSION="${BASH_REMATCH[1]}"
      grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/java/${JAVA_VERSION}/Dockerfile" >> "generated/${FLAVOR}/Dockerfile"
      grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/java/tests/tests.sh" >> "generated/${FLAVOR}/tests/tests.sh"
      grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/java/${JAVA_VERSION}/tests/tests.sh" >> "generated/${FLAVOR}/tests/tests.sh"
      echo >> "generated/${FLAVOR}/Dockerfile"
      echo >> "generated/${FLAVOR}/tests/tests.sh"
    fi

    if [[ "${FLAVOR}" =~ node-([0-9]+) ]]; then
      NODE_VERSION="${BASH_REMATCH[1]}"
      grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/node/${NODE_VERSION}/Dockerfile" >> "generated/${FLAVOR}/Dockerfile"
      grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/node/tests/tests.sh" >> "generated/${FLAVOR}/tests/tests.sh"
      grep -v '#!/bin/bash' "parts/ubi${UBI_VERSION}/node/${NODE_VERSION}/tests/tests.sh" >> "generated/${FLAVOR}/tests/tests.sh"
      echo >> "generated/${FLAVOR}/Dockerfile"
      echo >> "generated/${FLAVOR}/tests/tests.sh"
    fi
  fi

  sed -i "" 1d "generated/${FLAVOR}/Dockerfile"
  sed -i "" 1d "generated/${FLAVOR}/tests/tests.sh"
  chmod +x "generated/${FLAVOR}/tests/tests.sh"

  {
    echo "  ${FLAVOR}:"
    echo "    image: adorsys/ci-build:${FLAVOR}"
    echo "    build: generated/${FLAVOR}"
  } >> docker-compose.yml
done

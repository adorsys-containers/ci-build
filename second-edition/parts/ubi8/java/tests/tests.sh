docker run --rm "${DOCKER_IMAGE}:${TAG}" bash --version

docker run --rm "${DOCKER_IMAGE}:${TAG}" java -version
docker run --rm "${DOCKER_IMAGE}:${TAG}" mvn --version
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -XshowSettings:properties -version |& grep "file.encoding = UTF-8"'

chmod -R 777 "$(git rev-parse --show-toplevel)/test-applications/"

# Test Maven
docker run --rm -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/":/opt/app-root/src:cached "${DOCKER_IMAGE}:${TAG}" mvn -q --batch-mode clean package
docker run --rm -eSPRING_MAIN_BANNER-MODE=off -e JAVA_OPTS="-Dspring.mandatory-file-encoding=UTF-8" -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/target/dockerhub-pipeline-images-test-jar.jar":/opt/app-root/src/app.jar "${DOCKER_IMAGE}:${TAG}"

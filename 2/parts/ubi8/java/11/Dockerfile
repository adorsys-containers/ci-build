ARG MAVEN_VERSION=3.6.3

# https://github.com/carlossg/docker-maven/blob/master/jdk-8/Dockerfile#L5
ARG MAVEN_SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0

RUN microdnf --noplugins install --nodocs -y java-11-openjdk-devel \
  && ( mkdir -p "${MAVEN_HOME}" \
    && cd "${MAVEN_HOME}" \
    && curl -fsSLO "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
    && echo "${MAVEN_SHA}  apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha512sum -c - \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C "${MAVEN_HOME}" --strip-components=1 \
    && rm -f apache-maven-${MAVEN_VERSION}-bin.tar.gz apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512 \
    && ln -s "${MAVEN_HOME}/bin/mvn" /usr/bin/mvn \
    && mkdir -p "${MAVEN_CONFIG}" \
    && chmod -R g+rw "${MAVEN_CONFIG}" \
  ) \
  && microdnf --noplugins clean all -y && rm -rf /var/cache/yum

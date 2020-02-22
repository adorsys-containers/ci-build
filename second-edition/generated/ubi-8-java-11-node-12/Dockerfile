
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

LABEL maintainer="adorsys GmbH & Co. KG" \
      vendor="adorsys GmbH & Co. KG" \
      name="adorsys/ci-build" \
      org.label-schema.vendor="adorsys GmbH & Co. KG" \
      org.label-schema.name="adorsys/ci-build" \
      io.k8s.display-name="adorsys/ci-build" \
      summary="adorsys/ci-build" \
      io.k8s.description="adorsys/ci-build" \
      org.label-schema.description="adorsys/ci-build" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.usage="" \
      org.label-schema.license="" \
      org.label-schema.build-date=""

# https://bugzilla.redhat.com/show_bug.cgi?id=1611117
COPY --from=registry.access.redhat.com/ubi8/ubi:latest /usr/share/zoneinfo/UTC /usr/share/zoneinfo/UTC
COPY --from=registry.access.redhat.com/ubi8/ubi:latest /usr/share/zoneinfo/Europe/Berlin /usr/share/zoneinfo/Europe/Berlin

ENV HOME=/tmp \
    LC_ALL=C.UTF-8 \
    TZ=Europe/Berlin \
    NO_UPDATE_NOTIFIER=1 \
    JAVA_HOME="/usr/lib/jvm/jre" \
    JAVA_TOOL_OPTIONS="-Xmx1G" \
    NODE_OPTIONS="--max_old_space_size=1024" \
    MAVEN_HOME="/usr/share/maven" \
    MAVEN_CONFIG="/usr/local/share/.m2"

WORKDIR /opt/app-root/src

# Workaround for
# https://github.com/rpm-software-management/microdnf/issues/50
RUN mkdir -p /run/user/$(id -u)

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && echo -e '[docker-ce-stable]\nname=Docker CE Stable - $basearch\nbaseurl=https://download.docker.com/linux/centos/7/$basearch/stable\nenabled=0\ngpgcheck=1\ngpgkey=https://download.docker.com/linux/centos/gpg' > /etc/yum.repos.d/docker-ce.repo \
    && echo -e '[epel]\nname=Extra Packages for Enterprise Linux $releasever - $basearch\nmetalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir\nenabled=0\ngpgcheck=1\ngpgkey=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8' > /etc/yum.repos.d/epel.repo \
    && echo -e '[copr:copr.fedorainfracloud.org:jkroepke:git]\nname=Copr repo for git owned by jkroepke\nbaseurl=https://download.copr.fedorainfracloud.org/results/jkroepke/git/epel-8-$basearch/\ntype=rpm-md\nenabled=0\ngpgcheck=1\ngpgkey=https://download.copr.fedorainfracloud.org/results/jkroepke/git/pubkey.gpg\nrepo_gpgcheck=0\nenabled=1\nenabled_metadata=1' > /etc/yum.repos.d/jkroepke-git.repo \
    && microdnf update -y \
    && microdnf install --nodocs -y --enablerepo=docker-ce-stable \
        --enablerepo=copr:copr.fedorainfracloud.org:jkroepke:git \
        git-core docker-ce-cli tar curl \
    && rm -rf \
      /usr/libexec/docker/cli-plugins/docker-app \
      /var/cache/yum \
    && microdnf install --nodocs -y binutils \
    && strip /usr/bin/docker \
    && microdnf remove -y shadow-utils libsemanage \
    && microdnf clean all -y && rm -rf /var/cache/yum \
    && ( \
      curl -sSf -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq \
      && chmod +x /usr/local/bin/jq \
    )

ARG MAVEN_VERSION=3.6.3

# https://github.com/carlossg/docker-maven/blob/master/jdk-8/Dockerfile#L5
ARG MAVEN_SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0

RUN microdnf install --nodocs -y java-11-openjdk-devel \
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
  && microdnf clean all -y && rm -rf /var/cache/yum

RUN \
    && echo -e '[centos-8-baseos]\nname=CentOS-$releasever - BaseOS\nbaseurl=http://mirror.centos.org/centos/$releasever/BaseOS/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official' > /etc/yum.repos.d/centos-8-baseos.repo \
    && echo -e '[centos-8-appstream]\nname=CentOS-$releasever - AppStream\nbaseurl=http://mirror.centos.org/centos/$releasever/AppStream/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official' > /etc/yum.repos.d/centos-8-appstream.repo \
    && echo -e '[nodesource]\nname=nodesource\nbaseurl=https://rpm.nodesource.com/pub_12.x/el/8/$basearch\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.nodesource.com/pub/el/NODESOURCE-GPG-SIGNING-KEY-EL' > /etc/yum.repos.d/nodesource.repo \
    && microdnf install --nodocs -y --enablerepo=docker-ce-stable \
        --enablerepo=centos-8-baseos --enablerepo=centos-8-appstream \
        --enablerepo=copr:copr.fedorainfracloud.org:jkroepke:git \
      gcc-c++ make nodejs \
    && npm install -g npm yarn
    && npm cache clear --force \
    && microdnf clean all -y && rm -rf /var/cache/yum


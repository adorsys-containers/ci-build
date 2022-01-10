FROM openshift/origin-cli:v3.11 AS OC_CLIENT
FROM registry.access.redhat.com/ubi8/ubi:latest AS TZDATA

# From https://github.com/containers/skopeo/blob/master/Dockerfile.build
FROM golang:1.14-buster as SKOPEO

ARG SKOPEO_VERSION=v1.2.0
RUN mkdir -p $GOPATH/src/github.com/containers/skopeo \
    && curl -LsSf https://github.com/containers/skopeo/archive/${SKOPEO_VERSION}.tar.gz | tar xz --strip-components=1 -C $GOPATH/src/github.com/containers/skopeo \
    && cd $GOPATH/src/github.com/containers/skopeo && make bin/skopeo DISABLE_CGO=1

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

ARG RUSH_VERSION=0.4.2
ARG MAVEN_VERSION=3.8.4

# https://github.com/carlossg/docker-maven/blob/master/openjdk-17/Dockerfile
ARG MAVEN_SHA=a9b2d825eacf2e771ed5d6b0e01398589ac1bfa4171f36154d1b5787879605507802f699da6f7cfc80732a5282fd31b28e4cd6052338cbef0fa1358b48a5e3c8
ARG NODE_DEFAULT_VERSION=10

ENV HOME=/tmp \
    LC_ALL=C.UTF-8 \
    TZ=Europe/Berlin \
    NO_UPDATE_NOTIFIER=1 \
    JAVA_HOME="/usr/lib/jvm/jre" \
    JAVA_TOOL_OPTIONS="-Xmx1G" \
    NODE_OPTIONS="--max_old_space_size=1024" \
    MAVEN_HOME="/usr/share/maven" \
    NVM_DIR="/usr/local/share/nvm" \
    JABBA_HOME="/usr/local/share/jabba" \
    BASH_ENV=/enable.sh \
    ENV=/enable.sh

COPY root /

COPY --from=OC_CLIENT /usr/bin/oc /usr/local/bin/oc
COPY --from=SKOPEO /go/src/github.com/containers/skopeo/bin/skopeo /usr/local/bin/skopeo

# https://bugzilla.redhat.com/show_bug.cgi?id=1611117
COPY --from=TZDATA /usr/share/zoneinfo/UTC /usr/share/zoneinfo/UTC
COPY --from=TZDATA /usr/share/zoneinfo/Europe/Berlin /usr/share/zoneinfo/Europe/Berlin

RUN set -euo pipefail \
    && microdnf --noplugins install --nodocs -y shadow-utils libsemanage \
    && useradd -d "${HOME}" -M -u 1001 -g 0 default \
    && microdnf --noplugins remove -y shadow-utils libsemanage \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && curl -sSf -L http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial \
    && printf '[python38]\nname=python38\nstream=3.8\nprofiles=\nstate=enabled' > /etc/dnf/modules.d/python38.module \
    && echo -e '[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch\nenabled=0\ngpgcheck=1\ngpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub' > /etc/yum.repos.d/google-chrome.repo \
    && echo -e '[docker-ce-stable]\nname=Docker CE Stable - $basearch\nbaseurl=https://download.docker.com/linux/centos/8/$basearch/stable\nenabled=0\ngpgcheck=1\ngpgkey=https://download.docker.com/linux/centos/gpg' > /etc/yum.repos.d/docker-ce.repo \
    && echo -e '[epel]\nname=Extra Packages for Enterprise Linux $releasever - $basearch\nmetalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir\nenabled=0\ngpgcheck=1\ngpgkey=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8' > /etc/yum.repos.d/epel.repo \
    && echo -e '[centos-8-baseos]\nname=CentOS-$releasever - BaseOS\nbaseurl=http://mirror.centos.org/centos/$releasever/BaseOS/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial' > /etc/yum.repos.d/centos-8-baseos.repo \
    && echo -e '[centos-8-appstream]\nname=CentOS-$releasever - AppStream\nbaseurl=http://mirror.centos.org/centos/$releasever/AppStream/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial' > /etc/yum.repos.d/centos-8-appstream.repo \
    && echo -e '[copr:copr.fedorainfracloud.org:jkroepke:git]\nname=Copr repo for git owned by jkroepke\nbaseurl=https://download.copr.fedorainfracloud.org/results/jkroepke/git/epel-8-$basearch/\ntype=rpm-md\nenabled=0\ngpgcheck=1\ngpgkey=https://download.copr.fedorainfracloud.org/results/jkroepke/git/pubkey.gpg\nrepo_gpgcheck=0\nenabled=1\nenabled_metadata=1' > /etc/yum.repos.d/jkroepke-git.repo \
    && microdnf --noplugins update -y \
    && microdnf --noplugins install --nodocs -y --enablerepo=docker-ce-stable --enablerepo=google-chrome \
            --enablerepo=centos-8-baseos --enablerepo=centos-8-appstream \
            --enablerepo=copr:copr.fedorainfracloud.org:jkroepke:git \
        iproute zip unzip python38 bzip2 git-core gcc-c++ make findutils sudo \
        python38-lxml \
        google-chrome-stable libXt libX11-xcb libXScrnSaver dbus-glib \
        java-1.8.0-openjdk-devel java-11-openjdk-devel java-17-openjdk-devel \
        docker-ce-cli \
        binutils tar \
    && microdnf --noplugins clean all -y && rm -rf /var/cache/yum \
    && chmod g=u /etc/passwd \
    && printf 'Defaults !requiretty\nALL ALL=NOPASSWD: ALL' >> /etc/sudoers.d/all \
    && chmod 440 /etc/sudoers.d/all \
    && curl -LsSf https://github.com/shenwei356/rush/releases/download/v${RUSH_VERSION}/rush_linux_amd64.tar.gz | tar xz -C /usr/local/bin \
    && mkdir -p /opt/app-root/src && chown -R 1001:0 /opt/app-root/src && chmod -R ug+rwx /opt/app-root/src \
    && ( \
      curl -sSf -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq \
      && chmod +x /usr/local/bin/jq \
    ) \
    # https://docs.gitlab.com/ce/user/project/merge_requests/test_coverage_visualization.html
    # https://gitlab.com/haynes/jacoco2cobertura/-/tree/master
    && ( \
      curl -sSfL https://gitlab.com/haynes/jacoco2cobertura/-/archive/1.0.4/jacoco2cobertura-1.0.4.tar.gz | tar xz --strip-components 1 -C /opt/ '*.py' \
      && chmod +x /opt/*.py \
      && ln -snf /usr/bin/python3 /usr/bin/python \
    ) \
    && (mkdir -p "${NVM_DIR}" && cd "${NVM_DIR}" \
      && curl "https://raw.githubusercontent.com/creationix/nvm/master/install.sh" | bash \
      && rm -rf .git test \
      && echo -e "npm@6\nyarn" > default-packages \
      && . "${NVM_DIR}/nvm.sh" \
      && nvm install 10 \
      && nvm install 12 \
      && nvm install 14 \
      && echo -e "npm\nyarn" > default-packages \
      && nvm install 16 \
      && nvm cache clear \
      && nvm alias default ${NODE_DEFAULT_VERSION} \
      && rm -rf /home/default/.npm/ \
      && for prog in "${NVM_DIR}/versions/node/$(. "${NVM_DIR}/nvm.sh"; nvm current)/bin/"*; do ln -s "$prog" "/usr/local/bin/$(basename "${prog}")"; done \
      && find "${NVM_DIR}" -type d -exec chmod g+x {} + \
      && chmod -R g+rw "${NVM_DIR}" \
    ) \
    && (cd /opt \
      # Less secure then git clone ... bash install.sh ?
      && curl -fsSL "https://github.com/shyiko/jabba/raw/master/install.sh" | bash \
      && . "${JABBA_HOME}/jabba.sh" \
      && jabba link system@1.17 /usr/lib/jvm/java-17 \
      && jabba link system@1.11 /usr/lib/jvm/java-11 \
      && jabba link system@1.8 /usr/lib/jvm/java-1.8.0 \
      && jabba alias default system@1.8 \
      && chmod -R g+rw "${JABBA_HOME}" \
    ) \
    && (mkdir -p "${MAVEN_HOME}" && cd "${MAVEN_HOME}" \
      && curl -fsSLO "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
      && echo "${MAVEN_SHA}  apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha512sum -c - \
      && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C "${MAVEN_HOME}" --strip-components=1 \
      && rm -f apache-maven-${MAVEN_VERSION}-bin.tar.gz apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512 \
      && ln -s "${MAVEN_HOME}/bin/mvn" /usr/bin/mvn \
    ) \
    && cd /tmp && rm -rf ..?* .[!.]* * \
    && rm -rf \
      /usr/libexec/docker/cli-plugins/docker-app \
      /var/cache/yum \
    && ln -s /enable.sh /tmp/.bashrc \
    && strip /usr/bin/docker /usr/local/bin/oc

WORKDIR /opt/app-root/src

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/bin/bash"]

USER 1001

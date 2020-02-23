[![](https://img.shields.io/docker/pulls/adorsys/ci-build.svg?logo=docker)](https://hub.docker.com/r/adorsys/ci-build/)
[![](https://img.shields.io/docker/stars/adorsys/ci-build.svg?logo=docker)](https://hub.docker.com/r/adorsys/ci-build/)

# adorsys/ci-build

https://hub.docker.com/r/adorsys/ci-build/

## Description

The default build image. 

Software list:

* Java 8 and 11 (choosable via [JABBA](https://github.com/shyiko/jabba); default 8)
* Node 10 and 12 (choosable via [NVM](https://github.com/creationix/nvm); default 10)
* NPM and [YARN](https://yarnpkg.com/lang/en/)
* Maven
* Build Tools like gcc (required for some node dependencies)

### Additional software list inside full variant
* Docker CE
* Firefox (bootstrap only)
* JMeter (bootstrap only)
* [skopeo](https://github.com/containers/skopeo)
* [jq](https://stedolan.github.io/jq/)
* [rush](https://github.com/shenwei356/rush)

We try to avoid version pinning. Prepare to always get the latest version.

## Tags

| Name | Description | Size | 
| ---- | ----------- | ---- |
| latest | alias of full | [![](https://images.microbadger.com/badges/image/adorsys/ci-build.svg)](https://microbadger.com/images/adorsys/ci-build) |
| full | includes browser | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:full.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-java-8 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with Java 8 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-java-8.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-java-11 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with Java 11 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-java-11.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-node-10 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with NodeJS 10 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-node-10.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-node-12 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with NodeJS 12 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-node-12.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-java-8-node-10 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with Java 8 + NodeJS 10 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-java-8-node-10.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-java-11-node-10 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with Java 11 + NodeJS 10 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-java-11-node-10.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-java-8-node-12 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with Java 8 + NodeJS 12 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-java-8-node-12.svg)](https://microbadger.com/images/adorsys/ci-build) |
| ubi-8-java-11-node-12 | [UBI 8](https://developers.redhat.com/products/rhel/ubi/) based with Java 11 + NodeJS 12 | [![](https://images.microbadger.com/badges/image/adorsys/ci-build:ubi-8-java-11-node-12.svg)](https://microbadger.com/images/adorsys/ci-build) |

## CI Examples

### Use Java 11 in your job

Create a file calling `.jabbarc` in the project root with this content
```
system@1.11
```
and use `jabba use` inside your CI.

More informations: https://github.com/shyiko/jabba

### Use Node 10 in your job

Create a file calling `.nvmrc` in the project root with this content
```
10
```
and use `nvm use` inside your CI.

More informations: https://github.com/creationix/nvm

### Best Practice default options for maven

Based on the recommendation from [Gitlab CI](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/gitlab/ci/templates/Maven.gitlab-ci.yml).
It avoid all the spammy transfer output
```yaml
variables:
  MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end --show-version -DinstallAtEnd=true -DdeployAtEnd=true"
  MAVEN_OPTS: "-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
```

### Copy Images without Docker

```yaml
  script:
# From Gitlab to Openshift
    - >-
      skopeo copy
      --src-creds=${CI_REGISTRY_USER}:${CI_REGISTRY_PASSWORD}
      --dest-creds=openshift:${OPENSHIFT_TOKEN}
      "docker://${OPENSHIFT_REGISTRY}/namespace/image:${CI_COMMIT_REF_NAME}"
      "docker://${HARBOR_REGISTRY}/project/imagename:${CI_COMMIT_REF_NAME}"
# From Gitlab to Harbor
    - >-
      skopeo copy
      --src-creds=${CI_REGISTRY_USER}:${CI_REGISTRY_PASSWORD}
      --dest-creds=${HARBOR_USER}:${HARBOR_TOKEN}
      "docker://${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG}"
      "docker://${HARBOR_REGISTRY}/project/imagename:${CI_COMMIT_TAG}"
# From Openshift to Harbor
    - >-
      skopeo copy
      --src-creds=openshift:${OPENSHIFT_TOKEN}
      --dest-creds=${HARBOR_USER}:${HARBOR_TOKEN}
      "docker://${OPENSHIFT_REGISTRY}/namespace/image:${CI_COMMIT_TAG}"
      "docker://${HARBOR_REGISTRY}/project/imagename:${CI_COMMIT_TAG}"
```

#### User docker caching to reuse exists layers

* This technique requires reproducible builds.
  * Angular creates reproducible out of the box
  * Java projects using maven require a maven plugin https://zlika.github.io/reproducible-build-maven-plugin/

```yaml
  script:
    - >-
      docker pull "${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${CI_COMMIT_TAG:-$CI_COMMIT_REF_SLUG}" 
      || docker pull "${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:develop" 
      || true
    - >-
      docker build --pull
      --cache-from "${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${CI_COMMIT_TAG:-$CI_COMMIT_REF_SLUG}"
      --cache-from "${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:develop"
      -t "${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${CI_COMMIT_TAG:-$CI_COMMIT_REF_SLUG}" .
    - docker push "${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${CI_COMMIT_TAG:-$CI_COMMIT_REF_SLUG}"
```

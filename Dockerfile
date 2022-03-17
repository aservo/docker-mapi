FROM ubuntu:20.04

## Define the artifacts workdir.
ENV WORKDIR="/artifacts"

## Set the workdir to the artifacts workdir.
WORKDIR $WORKDIR

## Maven environment variables.
ENV MAVEN_REPOSITORY="https://repo1.maven.org/maven2/"
ENV MAVEN_USERNAME=""
ENV MAVEN_PASSWORD=""

## Artifacts-related environment variables.
ENV ARTIFACTS_TARGET_DIR="${WORKDIR}/files"
ENV ARTIFACTS_FILE="${WORKDIR}/artifacts.yaml"

## Install curl
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends curl

COPY artifacts.sh /artifacts/artifacts.sh

RUN chmod +x /artifacts/artifacts.sh

CMD ["/artifacts/artifacts.sh"]

FROM maven:3-openjdk-11-slim

ENV DEPENDENCY="org.apache.maven.plugins:maven-dependency-plugin:3.1.2"

ADD . /

# try to download as much dependencies as possible during build

RUN mvn package -B
RUN mvn ${DEPENDENCY}:go-offline -B
RUN mvn ${DEPENDENCY}:get -Dartifact=${DEPENDENCY}:jar -B

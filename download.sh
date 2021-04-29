#!/bin/sh

ARTIFACT=$1
OUTPUT=$2

DEPENDENCY="org.apache.maven.plugins:maven-dependency-plugin:3.1.2"

mvn $DEPENDENCY:get  -Dartifact=$ARTIFACT -Dtransitive=false -B
mvn $DEPENDENCY:copy -Dartifact=$ARTIFACT -DoutputDirectory=$OUTPUT -Dmdep.stripVersion=true -B

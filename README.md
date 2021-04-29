Maven Atlassian Plugin Installer
================================

Usage: Start the Docker container and run the `./download.sh` script as follows:

```
./download.sh <MAVEN_ARTIFACT_ID> <OUTPUT_DIRECTORY>
```

The script will download the artifact without version to the output directory. E.g.:

```
./download.sh de.aservo:confapi-crowd-plugin:0.0.8:jar ./plugins
```

This will result in:

```
$ ls ./plugins
confapi-crowd-plugin.jar
```

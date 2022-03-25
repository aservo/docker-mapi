#!/usr/bin/env bash

## These must be absolute paths
artifacts=$ARTIFACTS_FILE
directory=$ARTIFACTS_TARGET_DIR

## Maven repo URL and credentials
repository=${MAVEN_REPOSITORY%/}
if [ -n ${MAVEN_USERNAME} ] && [ -n ${MAVEN_PASSWORD} ]; then
    curl_creds="-u $MAVEN_USERNAME:$MAVEN_PASSWORD"
fi

echo "Artifacts script: $(realpath $0)"
echo "Artifacts file: $artifacts"
echo "Artifacts target dir: $directory"
echo "Maven repository: $repository"
echo ""

artifact_pattern="^\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\)$"

## Make sure the $artifacts file exists and is readable
if [ ! -r "$artifacts" ]; then
    echo "Artifacts file $artifacts does not exist or is not readable"
    exit 1
fi

## Make sure the $directory exists.
if [ ! -d "$directory" ]; then
    ## Try to create it if it does not exist.
    mkdir -p $directory
else
    ## Make sure the $directory is writable.
    if [ ! -w "$directory" ]; then
        echo "Target directory $directory does not exist or is not writable"
        exit 1
    fi
fi

cd $directory

artifacts_txt=".artifacts.txt"
artifacts_delete_txt=".artifacts_remove.txt"

## Make sure the $artifacts_txt file always exists
if [ ! -f "$artifacts_txt" ]; then
    touch $artifacts_txt
fi

## Rename old $artifacts_txt to $artifacts_delete_txt,
## and assume all listed artifacts to get deleted first
mv -f $artifacts_txt $artifacts_delete_txt

echo "Downloading artifacts defined in artifact YAML."

## Download artifacts declared in artifact YAML file
while IFS= read -r line || [[ "$line" ]]; do
    artifact_id="${line##- }"

    artifact_group_id=$(sed -e "s/$artifact_pattern/\1/g" <<< $artifact_id)
    artifact_artifact_id=$(sed -e "s/$artifact_pattern/\2/g" <<< $artifact_id)
    artifact_version=$(sed -e "s/$artifact_pattern/\3/g" <<< $artifact_id)
    artifact_file=$(sed -e "s/$artifact_pattern/\2-\3.\4/g" <<< $artifact_id)
    artifact_group_path=$(sed -e "s/\./\//g" <<< $artifact_group_id)

    artifact_url="$repository/$artifact_group_path/$artifact_artifact_id/$artifact_version/$artifact_file"
    artifact_path="$directory/$artifact_file"

    echo "$artifact_file" >> $artifacts_txt
    sed -i "/$artifact_file/d" $artifacts_delete_txt

    if [ -f "$artifact_path" ]; then
        echo "- $artifact_file already exists, continue"
        continue
    fi

    echo "- $artifact_file"
    http_code=$(curl --silent --write-out '%{response_code}' -k -f $curl_creds -H "Accept-Encoding: gzip,deflate" "$artifact_url" -o "$artifact_path")

    if [[ "$http_code" -ne 200 ]]; then
        echo "  Failed to download file $artifact_file"
        sed -i "/$artifact_file/d" $artifacts_txt
    fi
done < $artifacts

echo "Downloading artifacts done."
echo ""
echo "Deleting artifacts that are no longer defined in artifact YAML."

## Delete artifacts that are not declared in artifact YAML file anymore
while IFS= read -r line || [[ "$line" ]]; do
    artifact_file="$line"

    echo "- $artifact_file"
    rm $artifact_file
done < $artifacts_delete_txt

echo "Deleting artifacts done."
echo ""

rm $artifacts_delete_txt

ls -al

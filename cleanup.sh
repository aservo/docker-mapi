#!/bin/sh

DIRECTORY=$1
EXTENSION=$2

# delete all files in given directory with given extension with size 0
# could be shorter but this one is easy to read ;-)

find $DIRECTORY -maxdepth 1 -name "*.$EXTENSION" -type f -print0 | while read -d $'\0' file
do
    if [ $(stat -c%s "$file") -eq 0 ]
    then
        rm -f "$file"
    fi
done
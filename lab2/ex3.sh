#!/bin/bash

filename=$1

noOfArchives=$(ls ./*.tar.gz | wc -l)
archives=$(ls ./*.tar.gz)

if [[ $noOfArchives -ge 2 ]]; then
    i=0
    for arch in $archives; do
        let "i=i+1"
        if [[ $i -gt 2 ]]; then
            rm -f $arch
        fi
    done
fi

currentDate=$(date +'%Y-%m-%d_%H:%m:%S')
archiveName="${filename}${currentDate}"

tar -czf "${archiveName}.tar.gz" $filename
echo "Archived ${filename} into ${archiveName}"

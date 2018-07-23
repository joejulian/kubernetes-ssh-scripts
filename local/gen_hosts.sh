#!/bin/sh

CONFIG=$1
OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
OUTPUT_DIR=${OUTPUT_PREFIX}/common

if [[ -z "$CONFIG" ]]; then
    echo "error: missing config file parameter"
    exit 1
fi

mkdir -p ${OUTPUT_DIR}/etc
cp hosts/hosts ${OUTPUT_DIR}/etc/

for json in $(jq < ${CONFIG}  -c ".nodes[]"); do 
    jq -r '[.ip, .hostnames[]] | reduce .[1:][] as $i ("\(.[0])"; . + " \($i)")' <<< $json
done >> ${OUTPUT_DIR}/etc/hosts

#!/bin/sh

gen_hosts() {
    mkdir -p ${OUTPUT_DIR}/etc
    cp spec/hosts/hosts ${OUTPUT_DIR}/etc/

    for json in $(jq -c ".nodes[]" <<< $1); do
        jq -r '[.ip, .hostnames[]] | reduce .[1:][] as $i ("\(.[0])"; . + " \($i)")' <<< $json
    done >> ${OUTPUT_DIR}/etc/hosts
    echo "Generated hosts file"
}
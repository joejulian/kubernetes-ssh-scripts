#!/bin/sh

if [[ -z "$1" ]]; then
    echo "error: missing config file"
    exit 1
fi

OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}

for host in $(jq -c ".nodes[]" < $1); do
    IP=$(jq -r ".ip" <<< "$host")
    echo ${OUTPUT_PREFIX}/${IP}
    if [[ -d ${OUTPUT_PREFIX}/${IP} ]]; then
        TMPFILE=$(mktemp --suffix=".tar")
        tar -C ${OUTPUT_PREFIX}/common -cvf ${TMPFILE} .
        tar -C ${OUTPUT_PREFIX}/${IP}  -rvf ${TMPFILE} .
        ssh ubuntu@${IP} sudo tar -C / -xv < ${TMPFILE}
        rm ${TMPFILE}
    fi
done

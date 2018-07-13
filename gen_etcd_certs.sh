#!/bin/sh

if [[ -z "$1" ]]; then
    echo "error: missing config file"
    exit 1
fi

OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
CERT_DIR=${CERT_DIR:=etc/kubernetes/pki}

CA_DIR=${CA_DIR:=${PWD}/${OUTPUT_PREFIX}/common/${CERT_DIR}}
CA_CONFIG_DIR=${PWD}/ca

for host in $(jq -c ".nodes[] | select(.etcd)" < $1); do
    IP=$(jq -r ".ip" <<< "$host")
    PRIMARY_HOSTNAME=$(jq -r ".hostnames[0]" <<< $host)
    DNS_ALIASES=$(jq -c ".hostnames[1:]" <<< $host)
    OUTPUT_DIR=${OUTPUT_PREFIX}/${IP}

    mkdir -p ${OUTPUT_DIR}/${CERT_DIR}/etcd
    pushd ${OUTPUT_DIR}/${CERT_DIR}/etcd > /dev/null

    cfssl print-defaults csr | sed '0,/CN/{s/example\.net/'${PRIMARY_HOSTNAME}'/}' | jq 'del(.hosts[])' | jq ".hosts = "${DNS_ALIASES} > config.json
    cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=server config.json | cfssljson -bare server
    cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=peer   config.json | cfssljson -bare peer

    popd > /dev/null
done

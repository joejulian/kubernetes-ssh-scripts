#!/bin/sh

usage() {
    echo "Usage:"
    echo "  $0 <json configuration string>"
    exit 1
}

if [[ -z "$1" ]]; then
    echo "error: Missing config data"
    usage
fi

if ! jq <<< $1; then
    echo "error: Input is not valid json"
    usage
fi

OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
CERT_DIR=${CERT_DIR:=etc/kubernetes/pki}

CA_DIR=${CA_DIR:=${PWD}/${OUTPUT_PREFIX}/common/${CERT_DIR}}
CA_CONFIG_DIR=${PWD}/spec/pki/ca

if [[ ! -f ${CA_DIR}/ca.pem ]]; then
    error "CA certificate does not exist. Run gen_ca.sh first."
    exit 1
fi
if [[ ! -f ${CA_DIR}/ca-key.pem ]]; then
    error "CA key does not exist. Run gen_ca.sh first."
    exit 1
fi

# Loop through hosts in json
for host in $(jq -c ".nodes[] | select(.etcd)" <<< $1); do
    # Set variables needed to generate certificates
    IP=$(jq -r ".ip" <<< "$host")
    PRIMARY_HOSTNAME=$(jq -r ".hostnames[0]" <<< $host)
    DNS_ALIASES=$(jq -c ".hostnames[1:]" <<< $host)

    # Set output path
    OUTPUT_DIR=${OUTPUT_PREFIX}/${IP}

    # make output path
    mkdir -p ${OUTPUT_DIR}/${CERT_DIR}/etcd
    pushd ${OUTPUT_DIR}/${CERT_DIR}/etcd > /dev/null

    # generate etcd peer and server certificates
    cfssl print-defaults csr | sed '0,/CN/{s/example\.net/'${PRIMARY_HOSTNAME}'/}' | jq 'del(.hosts[])' | jq ".hosts = "${DNS_ALIASES} > config.json
    cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=server config.json | cfssljson -bare server
    cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=peer   config.json | cfssljson -bare peer

    popd > /dev/null
done

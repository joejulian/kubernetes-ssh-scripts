#!/bin/sh

gen_etcd_certs() {
    if [[ ! -f ${CA_DIR}/ca.pem ]]; then
        echo "CA certificate does not exist. Run gen_ca.sh first."
        exit 1
    fi
    if [[ ! -f ${CA_DIR}/ca-key.pem ]]; then
        echo "CA key does not exist. Run gen_ca.sh first."
        exit 1
    fi

    # Loop through hosts in json
    for host in $(jq -c ".nodes[] | select(.etcd)" <<< $1); do
        # Set variables needed to generate certificates
        local IP=$(jq -r ".ip" <<< "$host")
        local PRIMARY_HOSTNAME=$(jq -r ".hostnames[0]" <<< $host)
        local DNS_ALIASES=$(jq -c ".hostnames[1:]" <<< $host)

        # Set output path
        local OUTPUT_DIR=${OUTPUT_PREFIX}/${IP}

        # make output path
        mkdir -p ${OUTPUT_DIR}/${CERT_DIR}/etcd
        pushd ${OUTPUT_DIR}/${CERT_DIR}/etcd > /dev/null

        # generate etcd peer and server certificates
        cfssl print-defaults csr | sed '0,/CN/{s/example\.net/'${PRIMARY_HOSTNAME}'/}' | jq 'del(.hosts[])' | jq ".hosts = "${DNS_ALIASES} > config.json
        cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=server config.json | cfssljson -bare server > /dev/null
        echo "Generated etcd server certificate"
        cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=peer   config.json | cfssljson -bare peer > /dev/null
        echo "Generated etcd peer certificate"

        popd > /dev/null
    done
}
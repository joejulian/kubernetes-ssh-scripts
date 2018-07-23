#!/bin/sh
gen_etcd_client_cert() {
    if [[ ! -f ${CA_DIR}/ca.pem ]]; then
        echo "error: ca certificate is missing"
        exit 1
    fi
    if [[ ! -f ${CA_DIR}/ca-key.pem ]]; then
        error "CA key does not exist. Run gen_ca.sh first."
        exit 1
    fi

    mkdir -p ${OUTPUT_DIR}/${CERT_DIR}/etcd
    pushd ${OUTPUT_DIR}/${CERT_DIR}/etcd > /dev/null

    cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=client ${ETCD_CLIENT_CONFIG} | cfssljson -bare client > /dev/null
    echo "Generated etcd client certificate"

    popd > /dev/null
}
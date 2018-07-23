#!/bin/sh

gen_ca() {
    # Create and use output path
    mkdir -p ${OUTPUT_DIR}/${CERT_DIR}
    pushd ${OUTPUT_DIR}/${CERT_DIR} > /dev/null

    # Generate CA certificate and key
    cfssl gencert -initca -config ${CA_CONFIG_DIR}/ca-config.json ${CA_CONFIG_DIR}/ca-csr.json | cfssljson -bare ca - > /dev/null
    echo "Generated CA certificate"

    popd > /dev/null
}
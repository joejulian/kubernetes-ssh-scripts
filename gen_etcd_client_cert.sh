#!/bin/sh
OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
OUTPUT_DIR=${OUTPUT_PREFIX}/common
CERT_DIR=${CERT_DIR:=etc/kubernetes/pki}
CA_CONFIG_DIR=${PWD}/ca
CA_DIR=${CA_DIR:=${PWD}/${OUTPUT_PREFIX}/common/${CERT_DIR}}
ETCD_CLIENT_CONFIG=${PWD}/etcd/client.json

if [[ ! -f ${CA_DIR}/ca.pem ]]; then
    echo "error: ca certificate is missing"
    exit 1
fi

mkdir -p ${OUTPUT_DIR}/${CERT_DIR}/etcd
cd ${OUTPUT_DIR}/${CERT_DIR}/etcd

cfssl gencert -ca=${CA_DIR}/ca.pem -ca-key=${CA_DIR}/ca-key.pem -config=${CA_CONFIG_DIR}/ca-config.json -profile=client ${ETCD_CLIENT_CONFIG} | cfssljson -bare client

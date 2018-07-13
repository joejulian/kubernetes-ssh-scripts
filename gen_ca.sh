#!/bin/sh
OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
OUTPUT_DIR=${OUTPUT_PREFIX}/common
CERT_DIR=${CERT_DIR:=etc/kubernetes/pki}
CA_CONFIG_DIR=${PWD}/ca

mkdir -p ${OUTPUT_DIR}/${CERT_DIR}
cd ${OUTPUT_DIR}/${CERT_DIR}

cfssl gencert -initca -config ${CA_CONFIG_DIR}/ca-config.json ${CA_CONFIG_DIR}/ca-csr.json | cfssljson -bare ca -

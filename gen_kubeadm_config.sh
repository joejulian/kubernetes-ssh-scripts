#!/bin/sh

if [[ -z "$1" ]]; then
    echo "error: missing config file"
    exit 1
fi

OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
KUBE_DIR=${KUBE_DIR:=etc/kubernetes}
CERT_DIR=${CERT_DIR:=$KUBE_DIR/pki}

CA_DIR=${CA_DIR:=${PWD}/${OUTPUT_PREFIX}/common/${CERT_DIR}}
CA_CONFIG_DIR=${PWD}/ca
CONFIG_DIR=${PWD}/kubeadm

ETCD_ENDPOINTS=$(jq -c -r '[.nodes[] | .hostnames[] | scan("etcd[0-9]+") | . as $i | ("https://\($i):2379/")]' < $1)

for host in $(jq -c ".nodes[] | select(.kube_master)" < $1); do
    IP=$(jq -r ".ip" <<< "$host")
    NODENAME=$(jq '.hostnames[] | scan("master[0-9]+")' <<< $host)
    OUTPUT_DIR=${OUTPUT_PREFIX}/${IP}

    mkdir -p ${OUTPUT_DIR}/${KUBE_DIR}
    pushd ${OUTPUT_DIR}/${KUBE_DIR} > /dev/null

    jq '.api.advertiseAddress="'$IP'"' <${CONFIG_DIR}/config.json | 
    jq '.etcd.endpoints='$ETCD_ENDPOINTS |
    jq '.nodeName='$NODENAME > kubeadm.json

    popd > /dev/null
done

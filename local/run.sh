#!/bin/sh

set -e
set -o pipefail

usage() {
    echo "Usage:"
    echo "  $0 <json configuration string>"
    exit 1
}

if [[ -z "$1" ]]; then
    echo "error: Missing config data"
    usage
fi

if ! jq "" <<< $1 > /dev/null 2>&1 ; then
    echo "error: Input is not valid json"
    usage
fi

# Set path variables
PREFIX=$(dirname $0)
OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
OUTPUT_DIR=${OUTPUT_PREFIX}/common
CERT_DIR=${CERT_DIR:=etc/kubernetes/pki}
CA_CONFIG_DIR=${PWD}/spec/pki/ca
CA_DIR=${CA_DIR:=${PWD}/${OUTPUT_PREFIX}/common/${CERT_DIR}}
ETCD_CLIENT_CONFIG=${PWD}/spec/pki/etcd/client.json
KUBE_DIR=${KUBE_DIR:=etc/kubernetes}
MANIFEST_DIR=${CERT_DIR:=$KUBE_DIR/manifests}


scripts="gen_ca gen_etcd_certs gen_etcd_client_cert gen_etcd_manifest gen_hosts gen_kubeadm_config"

for script in $scripts; do
    source ${PREFIX}/${script}.sh
done

${PREFIX}/gen_ca.sh

parallel_scripts="gen_etcd_certs gen_etcd_client_cert gen_etcd_manifest gen_hosts gen_kubeadm_config"

for script in $parallel_scripts; do
    ${script} $1 &
    pids="$pids $!"
done

for pid in $pids; do
    wait $pid
done

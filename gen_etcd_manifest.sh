#!/bin/sh

if [[ -z "$1" ]]; then
    echo "error: missing config file"
    exit 1
fi

OUTPUT_PREFIX=${OUTPUT_PREFIX:=output}
KUBE_DIR=${KUBE_DIR:=etc/kubernetes}
MANIFEST_DIR=${CERT_DIR:=$KUBE_DIR/manifests}

CA_DIR=${CA_DIR:=${PWD}/${OUTPUT_PREFIX}/common/${CERT_DIR}}
CA_CONFIG_DIR=${PWD}/ca
CONFIG_SOURCE=${PWD}/etcd/manifest.json

INITIAL_CLUSTER=$(jq -c -r '[.nodes[] | { "node": .hostnames[] | scan("etcd[0-9]+"), "ip": .ip}] | [.[] as $i | ("\($i.node)=https://\($i.ip):2380")] | join(",")' < $1)

INITIAL_TOKEN=$(uuidgen)

for host in $(jq -c ".nodes[] | select(.etcd)" < $1); do
    IP=$(jq -r ".ip" <<< "$host")
    NODENAME=$(jq '.hostnames[] | scan("etcd[0-9]+")' <<< $host)
    OUTPUT_DIR=${OUTPUT_PREFIX}/${IP}

    mkdir -p ${OUTPUT_DIR}/${MANIFEST_DIR}
    pushd ${OUTPUT_DIR}/${MANIFEST_DIR} > /dev/null

    jq '.metadata.name='$NODENAME < ${CONFIG_SOURCE} |
    jq '.spec.containers[0].env+=[{"name":"INITIAL_TOKEN","value":"'${INITIAL_TOKEN}'"}]' |
    jq '.spec.containers[0].env+=[{"name":"PEER_NAME","value":'${NODENAME}'}]' |
    jq '.spec.containers[0].env+=[{"name":"INITIAL_CLUSTER","value":"'${INITIAL_CLUSTER}'"}]' > etcd.json

    popd > /dev/null
done

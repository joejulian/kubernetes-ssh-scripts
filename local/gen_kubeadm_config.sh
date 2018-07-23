#!/bin/sh

gen_kubeadm_config() {
    local CONFIG_DIR=${PWD}/spec/kubeadm
    local ETCD_ENDPOINTS=$(jq -c -r '[.nodes[] | .hostnames[] | scan("etcd[0-9]+") | . as $i | ("https://\($i):2379/")]' <<< $1)

    for host in $(jq -c ".nodes[] | select(.kube_master)" <<< $1); do
        local IP=$(jq -r ".ip" <<< "$host")
        local NODENAME=$(jq '.hostnames[] | scan("master[0-9]+")' <<< $host)
        local OUTPUT_DIR=${OUTPUT_PREFIX}/${IP}

        mkdir -p ${OUTPUT_DIR}/${KUBE_DIR}
        pushd ${OUTPUT_DIR}/${KUBE_DIR} > /dev/null

        jq '.api.advertiseAddress="'$IP'"' < ${CONFIG_DIR}/config.json |
            jq '.etcd.endpoints='$ETCD_ENDPOINTS |
            jq '.nodeName='$NODENAME > kubeadm.json

        echo "Generated kubeadm configuration"

        popd > /dev/null
    done
}
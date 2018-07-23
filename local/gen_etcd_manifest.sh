#!/bin/sh

gen_etcd_manifest() {
    local CONFIG_SOURCE=spec/manifests/etcd.json

    local INITIAL_CLUSTER=$(jq -c -r '[.nodes[] | { "node": .hostnames[] | scan("etcd[0-9]+"), "ip": .ip}] | [.[] as $i | ("\($i.node)=https://\($i.ip):2380")] | join(",")' <<< $1)

    local INITIAL_TOKEN=$(uuidgen)

    for host in $(jq -c ".nodes[] | select(.etcd)" <<< $1); do
        local IP=$(jq -r ".ip" <<< "$host")
        local NODENAME=$(jq '.hostnames[] | scan("etcd[0-9]+")' <<< $host)
        local OUTPUT_DIR=${OUTPUT_PREFIX}/${IP}

        mkdir -p ${OUTPUT_DIR}/${MANIFEST_DIR}
        pushd ${OUTPUT_DIR}/${MANIFEST_DIR} > /dev/null

        jq '.metadata.name='$NODENAME < ${CONFIG_SOURCE} |
        jq '.spec.containers[0].env+=[{"name":"INITIAL_TOKEN","value":"'${INITIAL_TOKEN}'"}]' |
        jq '.spec.containers[0].env+=[{"name":"PEER_NAME","value":'${NODENAME}'}]' |
        jq '.spec.container[0].env+=[{"name":"INITIAL_CLUSTER","value":"'${INITIAL_CLUSTER}'"}]' > etcd.json

        echo "Generated etcd kubelet manifest"

        popd > /dev/null
    done
}
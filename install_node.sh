#!/bin/sh
set -e -o pipefail

source ./lib.sh

if [[ -z "$1" ]]; then
    echo "error: missing config file"
    exit 1
fi

CONFIG=$1
KUBE_VERSION=$(jq -r '.kubernetes.version' ${CONFIG})
DOCKER_VERSION=$(jq -r '.docker.version' ${CONFIG})

for host in $(jq -c ".nodes[]" < $1); do
    IP=$(jq -r ".ip" <<< "$host")
    ARCH=$(jq -r ".arch" <<< "$host")
    GOARCH=$(goarch $ARCH)
    DOCKER_URL=https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz
    KUBE_NODE_URL=https://dl.k8s.io/v${KUBE_VERSION}/kubernetes-node-linux-${GOARCH}.tar.gz
    echo Downloading:
    echo "  $KUBE_NODE_URL"
    echo "  $DOCKER_URL"
    ssh ubuntu@${IP} bash -c '"curl -sL '${KUBE_NODE_URL}' | sudo tar xzv -C /opt --exclude *.docker_tag --exclude *.tar kubernetes/node/bin"'
    ssh ubuntu@${IP} bash -c '"curl -sL '${DOCKER_URL}' | sudo tar xzv -C /opt"'
done

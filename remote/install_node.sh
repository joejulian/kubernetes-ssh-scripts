#!/bin/sh
set -e
set -o pipefail

usage_error() {
  echo "Missing parameter"
  echo "Usage:"
  echo "  $0 '"'{"ip":"192.168.2.94","arch":"x86_64","kube_worker":true, "hostnames":["nuc-15","worker0"]}'"'"
  exit 1
 }

if [[ -z "$1" ]]; then
  usage_error
fi

HOST=$1

if ! jq <<< "$HOST" > /dev/null ; then
  usage_error
fi

IP=$(jq -r ".ip" <<< "$HOST")
ARCH=$(jq -r ".arch" <<< "$HOST")
GOARCH=$(goarch $ARCH)
DOCKER_URL=https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz
KUBE_NODE_URL=https://dl.k8s.io/v${KUBE_VERSION}/kubernetes-node-linux-${GOARCH}.tar.gz
echo Downloading:
echo "  $KUBE_NODE_URL"
echo "  $DOCKER_URL"
ssh ubuntu@${IP} bash -c '"curl -sL '${KUBE_NODE_URL}' | sudo tar xzv -C /opt --exclude *.docker_tag --exclude *.tar kubernetes/node/bin"'
ssh ubuntu@${IP} bash -c '"curl -sL '${DOCKER_URL}' | sudo tar xzv -C /opt"'
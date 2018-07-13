#!/bin/sh

if [[ -z "$1" ]]; then
    echo "error: missing config file"
    exit 1
fi

for host in $(jq -c ".nodes[]" < $1); do
    IP=$(jq -r ".ip" <<< "$host")
    ssh ubuntu@${IP} sudo bash -c '"
        wget -O /etc/systemd/system/kubelet.service https://raw.githubusercontent.com/kubernetes/contrib/master/init/systemd/kubelet.service
        systemctl daemon-reload
        systemctl enable kubelet.service
        systemctl start kubelet.service
        "'
done

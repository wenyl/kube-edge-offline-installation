#!/bin/bash
cd /opt
tar -vxf flannel.tar
docker load -i flannel/flannel.tar

docker load -i flannel/flannel-cni-plugin.tar

kubectl apply -f kube-flannel.yml

rm -rf flannel


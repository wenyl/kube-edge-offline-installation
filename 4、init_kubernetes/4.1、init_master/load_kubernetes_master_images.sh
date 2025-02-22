#!/bin/bash
images=(
kube-apiserver
kube-controller-manager
kube-scheduler
etcd
coredns
kube-proxy
pause
)
for imageName in ${images[@]} ; do
key=.tar
docker load -i $imageName$key
done
#!/bin/bash
images=(
kube-proxy
pause
coredns
)
for imageName in ${images[@]} ; do
key=.tar
docker load -i $imageName$key
done
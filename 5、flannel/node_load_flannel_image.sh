#!/bin/bash
cd /opt
tar -vxf flannel.tar

docker load -i flannel/flannel.tar

docker load -i flannel/flannel-cni-plugin.tar
rm -rf flannel


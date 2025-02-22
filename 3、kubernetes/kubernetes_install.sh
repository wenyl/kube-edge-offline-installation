#!/bin/bash
cd /opt
tar -xvf k8s.tar

yum install -y k8s/*.rpm

systemctl enable kubelet

rm -rf k8s
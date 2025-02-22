#!/bin/bash
cd /opt
echo "导入所有依赖的集群镜像"
tar -xvf master_images.tar
cd master_images
# load镜像脚本
sh ../load_kubernetes_master_images.sh
cd ../
rm -rf master_images
echo "初始化集群，advertise address: 192.168.10.102，注意拷贝kubeadm init令牌信息"
kubeadm init --apiserver-advertise-address=192.168.10.102 --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.23.0 --service-cidr=10.96.0.0/12 --pod-network-cidr=10.244.0.0/16
echo "拷贝认证文件"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes

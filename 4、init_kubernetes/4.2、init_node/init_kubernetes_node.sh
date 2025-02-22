#!/bin/bash
cd /opt
echo "导入所有依赖的集群镜像"
tar -xvf node_images.tar
cd node_images
# load镜像脚本
sh ../load_kubernetes_node_images.sh
cd ../
rm -rf node_images
echo "请执行初始化master节点时生成的kubeadm join 语句"
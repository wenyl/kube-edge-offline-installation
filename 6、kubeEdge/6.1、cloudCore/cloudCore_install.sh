#!/bin/bash
cd /opt/cloudCore
echo "开始安装cloudCore"
mkdir -p /etc/kubeedge/{ca,certs}
echo "创建证书"
./certgen.sh genCA
echo "生成CA证书"
./certgen.sh genCA
echo "证书请求"
./certgen.sh genCsr server
echo "生成证书"
./certgen.sh genCert server 192.168.10.102

echo "创建crds"
kubectl apply -f crds/devices_v1beta1_device.yaml
kubectl apply -f crds/devices_v1beta1_devicemodel.yaml
kubectl apply -f crds/cluster_objectsync_v1alpha1.yaml
kubectl apply -f crds/objectsync_v1alpha1.yaml
kubectl apply -f crds/router_v1_ruleEndpoint.yaml
kubectl apply -f crds/router_v1_rule.yaml
kubectl apply -f crds/apps_v1alpha1_edgeapplication.yaml
kubectl apply -f crds/apps_v1alpha1_nodegroup.yaml
kubectl apply -f crds/operations_v1alpha1_nodeupgradejob.yaml

echo "解压文件"
tar -xvf kubeedge-v1.13.0-linux-amd64.tar.gz

echo "安装cloudCore"
cp kubeedge-v1.13.0-linux-amd64/cloud/cloudcore/cloudcore /usr/local/bin/cloudcore
chmod +x /usr/local/bin/cloudcore
rm -rf kubeedge-v1.13.0-linux-amd64

echo "开机启动配置"
cat > /lib/systemd/system/cloudcore.service <<EOF
[Unit]
Description=cloudcore.service

[Service]
Type=simple
ExecStart=/usr/local/bin/cloudcore --config /opt/cloudCore/cloudcore.yaml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "服务设置为开机自启动"
systemctl daemon-reload
systemctl start cloudcore
systemctl status cloudcore
systemctl enable cloudcore
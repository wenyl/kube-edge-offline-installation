#!/bin/bash
cd /opt/edgeCore
echo "加载pause镜像"
docker load -i pause.tar

echo "安装mqtt"
rpm -ivh mqtt/libuv-1.44.2-1.el7.x86_64.rpm
rpm -ivh mqtt/libwebsockets-3.0.1-2.el7.x86_64.rpm
rpm -ivh mqtt/mosquitto-1.6.10-1.el7.x86_64.rpm
systemctl start mosquitto
systemctl enable mosquitto
systemctl status mosquitto

echo "安装edgeCore"
echo "解压文件"
tar -xvf kubeedge-v1.13.0-linux-amd64.tar.gz
cp kubeedge-v1.13.0-linux-amd64/edge/edgecore /usr/local/bin/edgecore
chmod +x /usr/local/bin/edgecore
rm -rf kubeedge-v1.13.0-linux-amd64

echo "开机启动配置"
cat > /lib/systemd/system/edgecore.service <<EOF
[Unit]
Description=edgecore.service

[Service]
Type=simple
ExecStart=/usr/local/bin/edgecore --config /opt/edgeCore/edgecore.yaml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "服务设置为开机自启动"
systemctl daemon-reload
systemctl start edgecore
systemctl status edgecore
systemctl enable edgecore
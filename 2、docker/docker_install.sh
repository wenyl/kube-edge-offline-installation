#!/bin/bash
cd /opt
tar zxvf docker-24.0.6.tgz

cp docker/* /usr/bin/

touch /etc/systemd/system/docker.service
cat > /etc/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
[Install]
WantedBy=multi-user.target
EOF
chmod +x /etc/systemd/system/docker.service

mkdir /etc/docker
touch /etc/docker/daemon.json
cat > /etc/docker/daemon.json << EOF
{
  "log-opts": {
    "max-size": "5m",
    "max-file":"3"
  },
   "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl daemon-reload
systemctl enable docker
systemctl start docker
rm -rf docker


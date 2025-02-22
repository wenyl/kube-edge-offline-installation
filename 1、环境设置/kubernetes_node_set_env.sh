#!/bin/bash
echo "关闭防火墙"
systemctl stop firewalld
systemctl disable firewalld

echo "关闭swap"
sed -i 's/.*swap.*/#&/' /etc/fstab
echo "禁用SELinux"
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

echo "清除iptables规则"
iptables -F

echo "关闭swap"
swapoff -a
sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab

echo "加载模块br_netfilter"
modprobe br_netfilter
cat > /etc/modules-load.d/k8s.conf << EOF
br_netfilter
EOF

echo "网桥配置"
cat > /etc/sysctl.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF

echo "hosts文件配置"
cat >> /etc/hosts << EOF
192.168.10.102 master
192.168.10.103 node1
192.168.10.104 node2
EOF


echo "时间同步"
timedatectl set-timezone Asia/Shanghai
systemctl enable --now chronyd
timedatectl set-local-rtc 0
systemctl restart rsyslog && systemctl restart crond

echo "重启"
reboot
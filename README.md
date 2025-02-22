# 简介
本文记录了本地虚拟机离线构建k8s+kubeEdge环境<br>
参考本文一至四章节内容可以离线搭建K8S运行环境<br>
参考本文一至五章节内容可以离线搭建KubeEdge运行环境<br>
本文第六章节实现了cloud --> edge和edge-->cloud的通信示例<br>
# 版本说明
|     组件     |   版本    |
|:----------:|:-------:|
| Kubernetes | v1.23.0 |
|  kubeEdge  | 1.13.0  |
|   docker   | 24.0.6  |
# 一、环境准备
## 1.1 虚拟机配置
|   虚拟机       |   节点名   |  配置   |                                                              部署内容                                                               |
|:--------------:|:-------:|:-----:|:-------------------------------------------------------------------------------------------------------------------------------:|
| 192.168.10.102 | master  | 2核2GB |     kubelet,kube-apiServer<br/>kube-controller-manager<br/>kube-scheduler<br/>kube-proxy<br/>docker<br/>etcd<br/>cloud-core     |
| 192.168.10.103 |  node1  | 2核2GB |                                                       kubelet<br/>docker                                                        |
| 192.168.10.104 |  node2  | 2核2GB |                                                       kubelet<br/>docker                                                        |
| 192.168.10.105 |  edge1  | 2核2GB |                                                         docker<br/>edge-core                                                         |
## 1.2 虚拟机网络配置
**参考下述链接，配置好虚拟机网络，注意要设置默认路由，否则kubernetes安装会失败，或者是出现启动k8s后coreDns，kube-proxy，kube-flannel的pod一直报错的情况**
http://www.wenyoulong.com/articles/2025/02/19/1739946482715.html
## 1.3 虚拟机hostname设置
在192.168.10.102执行`hostnamectl set-hostname master`<br>
在192.168.10.103执行`hostnamectl set-hostname node1`<br>
在192.168.10.104执行`hostnamectl set-hostname node2`<br>
在192.168.10.105执行`hostnamectl set-hostname edge1`<br>
## 1.4 虚拟机环境设置
将本项目1、环境设置目录下的kubernetes_master_set_env.sh文件拷贝至192.168.10.102虚拟机的/opt目录下<br>
执行`sh /opt/kubernetes_master_set_env.sh`<br>
将本项目1、环境设置目录下的kubernetes_node_set_env.sh文件拷贝至192.168.10.103、192.168.10.104虚拟机的/opt目录下<br>
执行`sh /opt/kubernetes_node_set_env.sh`<br>
# 二、docker安装
将2、docker目录下的文件拷贝到四台服务器的/opt目录下<br>
执行`sh /opt/docker_install.sh`<br>
# 三、kubernetes安装
将3、kubernetes目录下的文件拷贝到192.168.10.102、192.168.10.103、192.168.10.104虚拟机的/opt目录下<br>
执行`sh /opt/kubernetes_install.sh`<br>
## 3.1 初始化master节点
将4.1、init_master目录下的文件拷贝到192.168.10.102虚拟机的/opt目录下<br>
**注意拷贝kubeadm join信息，后面node节点加入集群就是使用的这个命令**<br>
执行`sh /opt/init_kubernetes_master.sh`<br>
eg：kubeadm join 192.168.10.102:6443 --token 4fxtey.ri4p3dh6flx3h76t \
--discovery-token-ca-cert-hash sha256:1f395453d0bdf87a0320d41ce741018b864ce3ebacf9d35d55e42d5eda476bfc
## 3.2 初始化nod节点
将4.2、init_node目录下的文件拷贝到192.168.10.103、192.168.10.104虚拟机的/opt目录下
执行`sh /opt/init_kubernetes_node.sh`<br>
**到这里需要执行在上一步输出的kubeadm join信息**
## 3.3 检查master节点状态
执行命令 `kubectl get nodes`
# 四、flannel插件安装
**在安装flannel插件前，要先确认自己的网卡名称然后对应修改压缩包内的--iface=自己的网卡名称**<br>
将5、flannel目录下的flannel.tar和node_load_flannel_image.sh内容拷贝到所有node节点,然后执行`sh /opt/node_load_flannel_image.sh`<br>
将5、flannel目录下的flannel.tar和master_install_flannel.sh和kube-flannel.yml拷贝到master节点，然后执行`sh /opt/master_install_flannel.sh`<br>
运行kubectl get nodes,所有节点都处于running状态<br>
运行kubectl get pods --all-namespaces -o wide看到所有容器都处于Running状态<br>
# 五、kubeEdge安装
## 5.1 cloudCore安装
将6.1、cloudCore目录的下述文件移动至master节点的/opt/cloudCore目录下<br>
**修改cloudcore.yaml配置文件的modules.cloudHub.advertiseAddress为master节点的IP**<br>
**修改cloudCore_install.sh中生成证书时的IP**<br>
文件清单如下：
1. crds目录
2. certgen.sh
3. cloudcore.yaml
4. cloudCore_install.sh
5. 对应的kubeedge-v1.13.0-linux文件<br>

执行 `sh /opt/cloudCore/cloudCore_install.sh`<br>
## 5.2 edgeCore安装
**在master节点执行`kubectl get secret -nkubeedge tokensecret -o=jsonpath='{.data.tokendata}' | base64 -d`获取token<br>**
eg:3f5c6fa8e32ce47478d3da53aa88a36d6d05304a6c68dbc0fff22cbceb22b040.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDAyMDgyMDJ9.sxGhtfql4KrAUuzV2mDIyKdjC01fJQXK7czWhagI-dE<br>
**将master节点生成的证书拷贝到edge1节点相同目录下，证书目录/etc/kubeedge/ca和/etc/kubeedge/certs**<br>
将6.2、edgeCore目录下的文件移动至edge1节点的/opt/edgeCore目录下<br>
**修改edgecore.yaml配置文件如下内容**<br>
1. 修改modules.edgeHub.httpServer为cloudcore.yaml中modules.cloudHub.https模块对应的地址
2. 修改modules.edgeHub.websocket.server为cloudcore.yaml中modules.cloudHub.websocket模块对应的地址
3. 修改modules.edgeHub.token为前一步在master节点获取到的token
4. 修改modules.edged.nodeIP为edge1服务器的IP
5. 修改modules.edged.hostnameOverride为edge1服务器的hostname

执行 `sh /opt/edgeCore/edgeCore_install.sh`<br>
过一会在master节点执行kubectl get node 就能看到edgeNode了
# 六、通信
将7、通信测试的内容上传到master节点的/opt/ruleEndpoint目录下<br>
这里要根据自己的需求去修改rule-rest-eventbus.yaml文件和rule-eventbus-rest-edge1.yaml文件中配置的mqtt的topic和cloud端接收edge端消息的接口地址<br>
完成后依次执行如下命令：
1. kubectl apply -f /opt/ruleEndpoint/ruleEndpoint-rest.yaml
2. kubectl apply -f /opt/ruleEndpoint/ruleEndpoint-eventbus.yaml
3. kubectl apply -f /opt/ruleEndpoint/rule-rest-eventbus.yaml
4. kubectl apply -f /opt/ruleEndpoint/rule-eventbus-rest-edge1.yaml

云端向边端发送消息测试：<br>
1. 在edge1端开启mqtt订阅cloud端发送的消息，执行命令`mosquitto_sub -t 'cloudData'`订阅消息 -d<br>
2. 在云端发送消息`curl -X POST -d'{"message": "123"}' http://192.168.10.102:9443/edge1/default/mqtt`

边端向云端发送消息测试：<br>
1. 启动服务 `java -jar /opt/ruleEndpoint/cloudEdgeHello.jar`
2. 边端向mqtt发送消息 `mosquitto_pub -t 'edgeData' -d -m '{"edgemsg":"msgtocloud"}'`
kubeEdge消息流转示意图![router.PNG](./images/router.PNG)<br>
kubeEdge支持cloud端和edge端互相发送消息，但是在实现上有所区别<br>
**云端发送消息到边端**
1. 用户在云端的APP调用rest api发送消息到router,router发送消息到cloudhub
2. cloudhub通过websocket发送消息到edgehub
3. eventhub发送消息到servicebus或者eventbus
4. 通过servicebus发送的消息会直接到用户在边端的APP上
5. 通过eventbus发布的消息会发送到mqtt上，然后用户在边端订阅了mqtt消息的APP会接收到云端发送的消息

**边端发送消息到云端**
1. 用户在边端的应用发送消息到mqttbroker
2. eventbus订阅mqttbroker的消息
3. eventbus发送消息到edgehub
4. edgehub发送消息到cloudhub
5. cloudhub发送消息到router
6. router用户定义的路径发送消息到用户在云端部署的APP

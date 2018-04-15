#!/bin/bash

VIRTUAL_IP=$1

while [ ! -f /etc/kubernetes/kubelet.conf ]
do
	echo "/etc/kubernetes/kubelet.conf doesn't exist, will wait for 2 seconds... "
	sleep 2
done
ls -l /etc/kubernetes
#Reconfigure the kubelet to access kube-apiserver via the load balancer:
sed -i "s#server:.*#server: https://$VIRTUAL_IP:6443#g" /etc/kubernetes/kubelet.conf
systemctl restart kubelet
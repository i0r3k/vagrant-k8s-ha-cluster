#!/bin/bash

VIRTUAL_IP=$1
#Reconfigure the kubelet to access kube-apiserver via the load balancer:
sudo sed -i "s#server:.*#server: https://$VIRTUAL_IP:6443#g" /etc/kubernetes/kubelet.conf
sudo systemctl restart kubelet
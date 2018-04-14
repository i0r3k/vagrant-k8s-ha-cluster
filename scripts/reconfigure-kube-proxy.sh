#!/bin/bash

VIRTUAL_IP=$1

#Reconfigure kube-proxy to access kube-apiserver via the load balancer:
kubectl get configmap -n kube-system kube-proxy -o yaml > kube-proxy-cm.yaml
sed -i "s#server:.*#server: https://$VIRTUAL_IP:6443#g" kube-proxy-cm.yaml
kubectl apply -f kube-proxy-cm.yaml --force
# restart all kube-proxy pods to ensure that they load the new configmap
kubectl delete pod -n kube-system -l k8s-app=kube-proxy
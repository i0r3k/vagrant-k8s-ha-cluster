#!/bin/bash

# import ssh keys 
echo "etcd1" > ~/server.txt
mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts

sshpass -p "vagrant" ssh-copy-id root@etcd1

mkdir -p /etc/kubernetes/pki/etcd
scp root@etcd1:/etc/kubernetes/pki/etcd/ca.pem /etc/kubernetes/pki/etcd
scp root@etcd1:/etc/kubernetes/pki/etcd/client.pem /etc/kubernetes/pki/etcd
scp root@etcd1:/etc/kubernetes/pki/etcd/client-key.pem /etc/kubernetes/pki/etcd
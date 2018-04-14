#!/bin/bash

# import ssh keys 
echo "master1" > ~/server.txt
mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts

sshpass -p "vagrant" ssh-copy-id root@master1

mkdir -p /etc/kubernetes/pki/etcd
scp -r root@master1:/etc/kubernetes/pki /etc/kubernetes
rm /etc/kubernetes/pki/apiserver.*
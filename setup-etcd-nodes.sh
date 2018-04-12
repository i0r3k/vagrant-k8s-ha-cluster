#!/bin/bash

# import ssh keys 
echo "etcd1" > ~/server.txt
mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts

sshpass -p "vagrant" ssh-copy-id root@etcd1

mkdir -p /etc/kubernetes/pki/etcd
cd /etc/kubernetes/pki/etcd
scp root@etcd1:/etc/kubernetes/pki/etcd/ca.pem .
scp root@etcd1:/etc/kubernetes/pki/etcd/ca-key.pem .
scp root@etcd1:/etc/kubernetes/pki/etcd/client.pem .
scp root@etcd1:/etc/kubernetes/pki/etcd/client-key.pem .
scp root@etcd1:/etc/kubernetes/pki/etcd/ca-config.json .

export PEER_NAME=$(hostname)
export PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')

cfssl print-defaults csr > config.json
sed -i '0,/CN/{s/example\.net/'"$PEER_NAME"'/}' config.json
sed -i 's/www\.example\.net/'"$PRIVATE_IP"'/' config.json
sed -i 's/example\.net/'"$PEER_NAME"'/' config.json

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server config.json | cfssljson -bare server
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer config.json | cfssljson -bare peer
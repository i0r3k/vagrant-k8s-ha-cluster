#!/bin/bash

VIRTUAL_IP=$1

echo "reconfigure kube-proxy & kubelet"
					
tee ~/server.txt <<-'EOF'
master1
master2
master3
node1
node2
EOF

mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts

sshpass -p "vagrant" ssh-copy-id root@master1
sshpass -p "vagrant" ssh-copy-id root@master2
sshpass -p "vagrant" ssh-copy-id root@master3
sshpass -p "vagrant" ssh-copy-id root@node1
sshpass -p "vagrant" ssh-copy-id root@node2


ssh root@master1 "/vagrant/scripts/reconfigure-kube-proxy.sh $VIRTUAL_IP"

ssh root@master1 "/vagrant/scripts/reconfigure-kubelet.sh $VIRTUAL_IP"
ssh root@master2 "/vagrant/scripts/reconfigure-kubelet.sh $VIRTUAL_IP"
ssh root@master3 "/vagrant/scripts/reconfigure-kubelet.sh $VIRTUAL_IP"
ssh root@node1 "/vagrant/scripts/reconfigure-kubelet.sh $VIRTUAL_IP"
ssh root@node2 "/vagrant/scripts/reconfigure-kubelet.sh $VIRTUAL_IP"
/vagrant/scripts/reconfigure-kubelet.sh $VIRTUAL_IP
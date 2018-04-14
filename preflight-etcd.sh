#!/bin/bash

#update to latest packages
yum -y update

#turn off firewall
systemctl disable firewalld && systemctl stop firewalld

# enable sshd password auth
sed -re 's/^(PasswordAuthentication)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config
systemctl restart sshd

# install required packages
yum install -y git sed sshpass ntp wget net-tools bind-utils bash-completion

# enable & start ntpd
systemctl enable ntpd && systemctl start ntpd
# change time zone
cp -fv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

#turn off swap
swapoff -a 
sed -i 's/.*swap.*/#&/' /etc/fstab

#turn off SELINUX
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sed -i '$a\net.bridge.bridge-nf-call-iptables=1' /etc/sysctl.conf
sed -i '$a\net.bridge.bridge-nf-call-ip6tables=1' /etc/sysctl.conf

# ip-hostname mapping
tee /etc/hosts <<-'EOF'
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.33.11 etcd1
192.168.33.12 etcd2
192.168.33.13 etcd3
192.168.33.21 master1
192.168.33.22 master2
192.168.33.23 master3
192.168.33.31 node1
192.168.33.32 node2
192.168.33.33 node3
EOF

ssh-keygen -t rsa -b 4096 -C "ericlin0625@me.com" -f ~/.ssh/id_rsa -N ''

export PEER_NAME=$(hostname)
export PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')


#git clone https://github.com/linyang0625/etcd-utils.git ~/etcd-utils

#curl -o /usr/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
#curl -o /usr/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
cp -fv /vagrant/cfssl/* /usr/bin
chmod +x /usr/bin/cfssl*

#install etcd binaries
export ETCD_VERSION=v3.1.12
#curl -sSL https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz | tar -xzv --strip-components=1 -C /usr/bin/
#rm -rf etcd-$ETCD_VERSION-linux-amd64*

# choose either URL
#GOOGLE_URL=https://storage.googleapis.com/etcd
#GITHUB_URL=https://github.com/coreos/etcd/releases/download
#DOWNLOAD_URL=${GOOGLE_URL}

#rm -f /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz

#curl -L ${DOWNLOAD_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
#tar xzvf /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin/
#rm -f /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz

cp -fv /vagrant/etcd/${ETCD_VERSION}/* /usr/local/bin
chmod +x /usr/local/bin/etcd*

echo "PATH=/usr/local/bin:$PATH" >> ~/.bashrc
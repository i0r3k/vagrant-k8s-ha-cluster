#!/bin/bash
export PEER_NAME=$(hostname)
export PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')

echo "$PRIVATE_IP"
# generate the environment file that systemd will use
touch /etc/etcd.env
echo "PEER_NAME=$PEER_NAME" >> /etc/etcd.env
echo "PRIVATE_IP=$PRIVATE_IP" >> /etc/etcd.env

cat /etc/etcd.env

# copy the systemd unit file
cat >/etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
EnvironmentFile=/etc/etcd.env
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0

ExecStart=/usr/local/bin/etcd --name ${PEER_NAME} \
    --data-dir /var/lib/etcd \
    --listen-client-urls https://${PRIVATE_IP}:2379 \
    --advertise-client-urls https://${PRIVATE_IP}:2379 \
    --listen-peer-urls https://${PRIVATE_IP}:2380 \
    --initial-advertise-peer-urls https://${PRIVATE_IP}:2380 \
    --cert-file=/etc/kubernetes/pki/etcd/server.pem \
    --key-file=/etc/kubernetes/pki/etcd/server-key.pem \
    --client-cert-auth \
    --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.pem \
    --peer-cert-file=/etc/kubernetes/pki/etcd/peer.pem \
    --peer-key-file=/etc/kubernetes/pki/etcd/peer-key.pem \
    --peer-client-cert-auth \
    --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.pem \
    --initial-cluster etcd1=https://192.168.33.11:2380,etcd2=https://192.168.33.12:2380,etcd3=https://192.168.33.13:2380 \
    --initial-cluster-token my-etcd-token \
    --initial-cluster-state new

[Install]
WantedBy=multi-user.target
EOF

# launch etcd
systemctl daemon-reload 
systemctl enable etcd
systemctl start etcd &

# check status
#systemctl status etcd -l

cat > ~/get-etcd-cluster-info.sh <<EOF
/usr/local/bin/etcdctl \
  --endpoints=https://$PRIVATE_IP:2379  \
  --ca-file=/etc/kubernetes/pki/etcd/ca.pem \
  --cert-file=/etc/kubernetes/pki/etcd/client.pem \
  --key-file=/etc/kubernetes/pki/etcd/client-key.pem \
  cluster-health
EOF

chmod a+x ~/get-etcd-cluster-info.sh
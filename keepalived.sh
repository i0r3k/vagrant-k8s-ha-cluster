#!/bin/bash
VIRTUAL_IP=$1
KA_STATE=$2
KA_PRIORITY=$3

PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')

MASTER_PEER_LST=sed "/^$PRIVATE_IP/d" <<EOF
192.168.33.21
192.168.33.22
192.168.33.23
EOF

yum install -y keepalived

mkdir -p /etc/keepalived

cat > /etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
	router_id LVS_DEVEL
}

vrrp_script check_apiserver {
	script "/etc/keepalived/check_apiserver.sh"
	interval 3
	weight -2
	fall 10
	rise 2
}

vrrp_instance VI_1 {
    state $KA_STATE
    interface eth1
    virtual_router_id 51
    priority $KA_PRIORITY
	 advert_int 1
    mcast_src_ip $PRIVATE_IP
    nopreempt
	 
	unicast_peer {
		$MASTER_PEER_LST
    }
	 
    authentication {
        auth_type PASS
        auth_pass $(uuidgen)
    }
    virtual_ipaddress {
        $VIRTUAL_IP
    }
    track_script {
        check_apiserver
    }
}
EOF

cat > /etc/keepalived/check_apiserver.sh <<EOF
#!/bin/sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q $VIRTUAL_IP; then
    curl --silent --max-time 2 --insecure https://$VIRTUAL_IP:6443/ -o /dev/null || errorExit "Error GET https://$VIRTUAL_IP:6443/"
fi
EOF

chmod a+x /etc/keepalived/check_apiserver.sh

systemctl enable keepalived && systemctl start keepalived
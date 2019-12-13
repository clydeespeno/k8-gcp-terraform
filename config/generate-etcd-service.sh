#!/bin/bash

INTERNAL_IP=$1
ETCD_NAME=$2
INITIAL_CLUSTER=$3

cat > "$ETCD_NAME-etcd.service" <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/config/kubernetes.pem \\
  --key-file=/config/kubernetes-key.pem \\
  --peer-cert-file=/config/kubernetes.pem \\
  --peer-key-file=/config/kubernetes-key.pem \\
  --trusted-ca-file=/config/ca.pem \\
  --peer-trusted-ca-file=/config/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${INITIAL_CLUSTER} \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

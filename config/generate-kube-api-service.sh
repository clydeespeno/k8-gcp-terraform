#!/bin/bash

set -x

INTERNAL_IP=$1
instance=$2
ETCD_SERVERS=$3

cat > "$instance-kube-apiserver.service" <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/config/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/config/ca.pem \\
  --etcd-certfile=/config/kubernetes.pem \\
  --etcd-keyfile=/config/kubernetes-key.pem \\
  --etcd-servers=$ETCD_SERVERS \\
  --event-ttl=1h \\
  --encryption-provider-config=/config/encryption-config.yaml \\
  --kubelet-certificate-authority=/config/ca.pem \\
  --kubelet-client-certificate=/config/kubernetes.pem \\
  --kubelet-client-key=/config/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config="api/all=true" \\
  --service-account-key-file=/config/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/config/kubernetes.pem \\
  --tls-private-key-file=/config/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

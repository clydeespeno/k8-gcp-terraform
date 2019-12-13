#!/bin/bash

cat > kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/config/ca.pem \\
  --cluster-signing-key-file=/config/ca-key.pem \\
  --kubeconfig=/config/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/config/kubernetes/ca.pem \\
  --service-account-private-key-file=/config/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
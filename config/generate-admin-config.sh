#!/bin/bash

KUBERNETES_CLUSTER=$1

kubectl config set-cluster $KUBERNETES_CLUSTER \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig > /dev/null

kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig > /dev/null

kubectl config set-context default \
  --cluster=$KUBERNETES_CLUSTER \
  --user=admin \
  --kubeconfig=admin.kubeconfig > /dev/null

kubectl config use-context default --kubeconfig=admin.kubeconfig > /dev/null

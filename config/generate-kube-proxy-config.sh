#!/bin/bash

KUBERNETES_PUBLIC_ADDRESS=$1
KUBERNETES_CLUSTER=$2

kubectl config set-cluster $KUBERNETES_CLUSTER \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig > /dev/null

kubectl config set-credentials system:kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig > /dev/null

kubectl config set-context default \
  --cluster=$KUBERNETES_CLUSTER \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig > /dev/null

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig > /dev/null

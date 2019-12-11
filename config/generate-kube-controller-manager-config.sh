#!/bin/bash

KUBERNETES_CLUSTER=$1

kubectl config set-cluster $KUBERNETES_CLUSTER \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig > /dev/null

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.pem \
  --client-key=kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig > /dev/null

kubectl config set-context default \
  --cluster=$KUBERNETES_CLUSTER \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig > /dev/null

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig > /dev/null

#!/bin/bash

KUBERNETES_CLUSTER=$1

kubectl config set-cluster $KUBERNETES_CLUSTER \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig > /dev/null

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=kube-scheduler.pem \
  --client-key=kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig > /dev/null

kubectl config set-context default \
  --cluster=$KUBERNETES_CLUSTER \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig > /dev/null

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig > /dev/null

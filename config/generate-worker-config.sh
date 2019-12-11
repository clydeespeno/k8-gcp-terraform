#!/bin/bash

instance=$1
KUBERNETES_PUBLIC_ADDRESS=$2
KUBERNETES_CLUSTER=$3

kubectl config set-cluster $KUBERNETES_CLUSTER \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig > /dev/null

kubectl config set-credentials system:node:${instance} \
  --client-certificate=${instance}.pem \
  --client-key=${instance}-key.pem \
  --embed-certs=true \
  --kubeconfig=${instance}.kubeconfig > /dev/null

kubectl config set-context default \
  --cluster=$KUBERNETES_CLUSTER \
  --user=system:node:${instance} \
  --kubeconfig=${instance}.kubeconfig > /dev/null

kubectl config use-context default --kubeconfig=${instance}.kubeconfig > /dev/null

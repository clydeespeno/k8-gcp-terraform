#!/bin/bash

set -x

KUBE_VERSION="1.17.0"

wget --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kubectl"

chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

sudo mv /config/kube-controller-manager.service /etc/systemd/system/kube-controller-manager.service
sudo mv /config/kube-scheduler.service /etc/systemd/system/kube-scheduler.service
sudo mv /config/kube-apiserver.service /etc/systemd/system/kube-apiserver.service

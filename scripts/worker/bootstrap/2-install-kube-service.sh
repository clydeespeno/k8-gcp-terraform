#!/bin/bash

set -x

CRI_TOOLS_VERSION="1.17.0"
KUBE_VERSION="1.17.0"
RC_VERSION="1.0.0-rc9"
CONTAINERD_VERSION="1.3.0"
CNI_PLUGINS_VERSION="0.8.3"

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes \
  /etc/containerd

sudo mv /config/kube-proxy.service /etc/systemd/system/kube-proxy.service
sudo mv /config/containerd.service /etc/systemd/system/containerd.service
sudo mv /config/kubelet.service /etc/systemd/system/kubelet.service

sudo mv /config/10-bridge.conf /etc/cni/net.d/10-bridge.conf
sudo mv /config/99-loopback.conf /etc/cni/net.d/99-loopback.conf
sudo mv /config/config.toml /etc/containerd/config.toml

wget --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v"$CRI_TOOLS_VERSION"/crictl-v"$CRI_TOOLS_VERSION"-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v"$RC_VERSION"/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v$CNI_PLUGINS_VERSION/cni-plugins-linux-amd64-v$CNI_PLUGINS_VERSION.tgz \
  https://github.com/containerd/containerd/releases/download/v$CONTAINERD_VERSION/containerd-$CONTAINERD_VERSION.linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kubelet

mkdir containerd
tar -xvf crictl-v$CRI_TOOLS_VERSION-linux-amd64.tar.gz
tar -xvf containerd-$CONTAINERD_VERSION.linux-amd64.tar.gz -C containerd
sudo tar -xvf cni-plugins-linux-amd64-v$CNI_PLUGINS_VERSION.tgz -C /opt/cni/bin/
sudo mv runc.amd64 runc
chmod +x crictl kubectl kube-proxy kubelet runc
sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
sudo mv containerd/bin/* /bin/

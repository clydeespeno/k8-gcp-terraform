#!/bin/bash

set -x

sudo mkdir -p /config

ETCD_VERSION="3.4.0"

wget --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v$ETCD_VERSION/etcd-v$ETCD_VERSION-linux-amd64.tar.gz"

tar -xvf "etcd-v$ETCD_VERSION-linux-amd64.tar.gz"
mv "etcd-v$ETCD_VERSION-linux-amd64" etcd-dir
sudo mv etcd-dir/etcd* /usr/local/bin/

sudo mv /config/etcd.service /etc/systemd/system/etcd.service

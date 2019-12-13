#!/bin/bash

set -ex

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

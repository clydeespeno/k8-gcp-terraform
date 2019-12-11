#!/bin/bash

sudo mkdir -p /etc/etcd /etc/kubernetes/config

./1-bootstrap-controller-etcd.sh
./2-start-etcd-service.sh
./3-generate-kube-api-service.sh
./4-install-kube-controller.sh
./5-start-controller-manager-service.sh
./6-install-and-run-health-api.sh
./7-create-cluster-role.sh

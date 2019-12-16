#!/bin/bash
set -ex

./1-install-configure-os.sh
./2-install-kube-service.sh
./3-start-kube-service.sh

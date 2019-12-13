#!/bin/bash

set -ex

sudo mkdir -p /scripts/bootstrap /config
sudo mv bootstrap/* /scripts/bootstrap/
sudo mv controller-config/* /config/
sudo mv config/* /config/
sudo mv service-config/* /config/

sudo chmod -R +x /scripts/bootstrap

rm -R bootstrap controller-config config service-config

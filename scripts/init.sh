#!/bin/bash

set -ex

sudo mkdir -p /scripts/bootstrap /config
sudo mv bootstrap/* /scripts/bootstrap/
sudo mv config/* /config/

sudo chmod -R +x /scripts/bootstrap

rm -R bootstrap config

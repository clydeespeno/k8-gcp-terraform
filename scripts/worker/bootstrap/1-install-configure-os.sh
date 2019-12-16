#!/bin/bash

set -x

sudo apt-get update
sudo apt-get -y install socat conntrack ipset

sudo swapoff -a

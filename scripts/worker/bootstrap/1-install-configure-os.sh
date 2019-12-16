#!/bin/bash

set -x

sudo apt-get update
sudo apt-get -y install socat conntrack ipset
sudo apt-get install socat

sudo swapoff -a

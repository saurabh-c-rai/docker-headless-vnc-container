#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Python3.8"
apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -y
apt-get install -y python3.8

#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install JDK11"
wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9.1+1/OpenJDK11U-jdk_x64_linux_hotspot_11.0.9.1_1.tar.gz -O /tmp/OpenJDK11U-jdk_x64_linux_hotspot_11.0.9.1_1.tar.gz
tar xfvz /tmp/OpenJDK11U-jdk_x64_linux_hotspot_11.0.9.1_1.tar.gz --directory /usr/lib/jvm
echo "JDK installed"

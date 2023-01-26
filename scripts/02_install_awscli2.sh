#!/bin/bash

set -u

if [ "$AMI_ARCHITECTURE" = "arm64" ]
then
  export AWSCLI_ARCHITECTURE="aarch64"
else
  export AWSCLI_ARCHITECTURE=$AMI_ARCHITECTURE
fi

echo "Uninstall AWS CLI v1"
sudo yum remove awscli -y

echo "Download AWS CLI v2 installer using architecture $AWSCLI_ARCHITECTURE"
mkdir -p ~/awscliv2
cd ~/awscliv2
curl "https://awscli.amazonaws.com/awscli-exe-linux-$AWSCLI_ARCHITECTURE.zip" -o awscliv2.zip
unzip -qq awscliv2.zip

echo "Run AWS CLI v2 installer"
sudo ./aws/install

echo 'Check installation'
aws --version


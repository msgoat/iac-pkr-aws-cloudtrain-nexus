#!/bin/bash

echo 'Uninstall AWS CLI v1'
sudo yum remove awscli -y

echo 'Download AWS CLI v2 installer'
mkdir -p ~/awscliv2
cd ~/awscliv2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -qq awscliv2.zip

echo 'Run AWS CLI v2 installer'
sudo ./aws/install

echo 'Check installation'
aws --version


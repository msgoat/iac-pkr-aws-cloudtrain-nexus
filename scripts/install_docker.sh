#!/bin/bash

echo 'installing Docker from Amazon Linux Extras packages'
sudo amazon-linux-extras install docker
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
sudo usermod -a -G docker ec2-user
sudo docker info
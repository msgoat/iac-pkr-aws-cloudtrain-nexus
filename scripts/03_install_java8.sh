#!/bin/bash

echo "Installing Java 8"
sudo amazon-linux-extras enable corretto8
sudo yum install java-1.8.0-amazon-corretto -y

echo "Checking Java installation"
java -version
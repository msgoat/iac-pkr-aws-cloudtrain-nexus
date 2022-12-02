#!/bin/bash

echo 'Installing Java 17'
sudo yum install java-17-amazon-corretto-headless -y

echo 'Checking Java installation'
java -version
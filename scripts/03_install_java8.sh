#!/bin/bash
# ----------------------------------------------------------------------------
# 03_install_java8.sh
# ----------------------------------------------------------------------------
# Installs Java 8 represented by Amazon Corretto distribution.
# ----------------------------------------------------------------------------

echo "Installing Java 8"
# sudo amazon-linux-extras enable corretto8
sudo dnf install java-1.8.0-amazon-corretto -y

echo "Checking Java installation"
java -version
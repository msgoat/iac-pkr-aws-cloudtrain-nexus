#!/bin/bash

set -u

export NEXUS3_PACKAGE_NAME=nexus-$NEXUS3_VERSION-unix.tar.gz
export NEXUS_HOME=/opt/sonatype/nexus3
export NEXUS_INSTALL_DIR=$NEXUS_HOME
export NEXUS_DATA=/data/sonatype-work
export NEXUS_WORK_DIR=$NEXUS_DATA/nexus3

echo "Create Nexus3 runtime user"
sudo adduser nexus

echo "Create Nexus directories"
sudo mkdir -p $NEXUS_INSTALL_DIR
sudo mkdir -p $NEXUS_WORK_DIR

echo "Download and unpack Nexus3 package using Nexus version $NEXUS3_VERSION"
cd /tmp
sudo curl -L -O https://download.sonatype.com/nexus/3/$NEXUS3_PACKAGE_NAME
sudo tar xzf $NEXUS3_PACKAGE_NAME
sudo cp -r nexus-$NEXUS3_VERSION/* $NEXUS_INSTALL_DIR/
git sudo ls -al $NEXUS_INSTALL_DIR
sudo cp -r sonatype-work/nexus3/* $NEXUS_WORK_DIR/
sudo ls -al $NEXUS_WORK_DIR
sudo rm -rf $NEXUS3_PACKAGE_NAME nexus-$NEXUS3_VERSION sonatype-work

echo "Copy initial Nexus3 configuration files"
mv /tmp/nexus.vmoptions /tmp/nexus.vmoptions.template
envsubst < /tmp/nexus.vmoptions.template > /tmp/nexus.vmoptions
sudo mv -f /tmp/nexus.vmoptions $NEXUS_INSTALL_DIR/bin/
sudo cat $NEXUS_INSTALL_DIR/bin/nexus.vmoptions
sudo mv -f /tmp/nexus.rc $NEXUS_INSTALL_DIR/bin/

echo "Make runtime user owner of installation directory"
sudo chown -R nexus:nexus $NEXUS_HOME
sudo chown -R nexus:nexus $NEXUS_DATA

echo "Install Nexus3 as a service"
sudo ln -s $NEXUS_INSTALL_DIR/bin/nexus /etc/init.d/nexus
sudo mv -f /tmp/nexus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service

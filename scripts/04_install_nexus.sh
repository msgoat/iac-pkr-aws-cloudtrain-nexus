#!/bin/bash

set -ue

export SONATYPE_HOME=/opt/sonatype
export NEXUS3_PACKAGE_NAME=nexus-$NEXUS_VERSION-unix.tar.gz
export NEXUS_HOME=$SONATYPE_HOME/nexus3-$NEXUS_VERSION
export NEXUS_DATA=$SONATYPE_HOME/sonatype-work/nexus3

echo "Create Nexus3 runtime user (with SONATYPE_HOME as home directory to make Nexus start work!)"
sudo adduser nexus -d $SONATYPE_HOME

echo "Download and unpack Nexus3 package using Nexus version $NEXUS_VERSION"
sudo curl -L -o $SONATYPE_HOME/$NEXUS3_PACKAGE_NAME https://download.sonatype.com/nexus/3/$NEXUS3_PACKAGE_NAME
sudo tar xzf $SONATYPE_HOME/$NEXUS3_PACKAGE_NAME -C $SONATYPE_HOME
sudo rm $SONATYPE_HOME/$NEXUS3_PACKAGE_NAME
echo "Contents of Sonatype home directory $SONATYPE_HOME"
sudo ls -al $SONATYPE_HOME
echo "Contents of Nexus home directory $NEXUS_HOME"
sudo ls -al $NEXUS_HOME
echo "Contents of Nexus data directory $NEXUS_DATA"
sudo ls -al $NEXUS_DATA

echo "Copy initial Nexus3 configuration files"
sudo cp /tmp/nexus.vmoptions.root_volume $NEXUS_HOME/bin/nexus.vmoptions
sudo cat $NEXUS_HOME/bin/nexus.vmoptions

echo "Make runtime user owner of Nexus home directory"
sudo chown -R nexus:nexus $NEXUS_HOME
sudo chown -R nexus:nexus $NEXUS_DATA

echo "Check if Nexus starts"
sudo -Hu nexus $NEXUS_HOME/bin/nexus start
sudo -Hu nexus $NEXUS_HOME/bin/nexus status
sudo -Hu nexus $NEXUS_HOME/bin/nexus stop

#echo "Install Nexus3 as a service"
#sudo ln -s $NEXUS_INSTALL_DIR/bin/nexus /etc/init.d/nexus
#sudo mv -f /tmp/nexus.service /etc/systemd/system/
#sudo systemctl daemon-reload
#sudo systemctl enable nexus.service
#sudo systemctl start nexus.service

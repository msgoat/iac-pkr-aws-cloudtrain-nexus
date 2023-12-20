#!/bin/bash
# ----------------------------------------------------------------------------
# 04_install_nexus.sh
# ----------------------------------------------------------------------------
# Installs Sonatype Nexus OSS. Final configuration will be performed during
# EC2 spin-up.
# ----------------------------------------------------------------------------

set -ue

export SONATYPE_HOME=/opt/sonatype
export NEXUS3_PACKAGE_NAME=nexus-$NEXUS_VERSION-unix.tar.gz
export NEXUS_HOME=$SONATYPE_HOME/nexus3
export NEXUS_DATA=$SONATYPE_HOME/sonatype-work/nexus3

echo "Create Nexus3 runtime user (with SONATYPE_HOME as home directory to make Nexus start work!)"
sudo adduser nexus -d $SONATYPE_HOME
sudo mkdir -p $SONATYPE_HOME/.local/bin
sudo mkdir -p $SONATYPE_HOME/.local/nexus

echo "Download and unpack Nexus3 package using Nexus version $NEXUS_VERSION"
sudo curl -L -o $SONATYPE_HOME/$NEXUS3_PACKAGE_NAME https://download.sonatype.com/nexus/3/$NEXUS3_PACKAGE_NAME
sudo tar xzf $SONATYPE_HOME/$NEXUS3_PACKAGE_NAME -C $SONATYPE_HOME
echo "Simplify name of nexus home directory from $SONATYPE_HOME/nexus-$NEXUS_VERSION to $SONATYPE_HOME/nexus3"
sudo mv $SONATYPE_HOME/nexus-$NEXUS_VERSION $SONATYPE_HOME/nexus3
echo "Delete Nexus3 package"
sudo rm $SONATYPE_HOME/$NEXUS3_PACKAGE_NAME
echo "Contents of Sonatype home directory $SONATYPE_HOME"
sudo ls -al $SONATYPE_HOME
echo "Contents of Nexus home directory $NEXUS_HOME"
sudo ls -al $NEXUS_HOME
echo "Contents of Nexus data directory $NEXUS_DATA"
sudo ls -al $NEXUS_DATA

echo "Copy initial Nexus3 configuration files to nexus user home"
sudo cp -f /tmp/nexus.rc $NEXUS_HOME/bin/
sudo cp -f /tmp/nexus.vmoptions.root_volume $NEXUS_HOME/bin/nexus.vmoptions
sudo cat $NEXUS_HOME/bin/nexus.vmoptions

echo "Copy script and configuration files for EC2 launch to nexus user home"
sudo cp /tmp/nexus.vmoptions.root_volume $SONATYPE_HOME/.local/nexus/
sudo cp /tmp/nexus.vmoptions.data_volume $SONATYPE_HOME/.local/nexus/

echo "Make runtime user owner of Nexus home directory"
sudo chown -R nexus:nexus $SONATYPE_HOME

#echo "Starting nexus"
#sudo -Hu nexus $NEXUS_HOME/bin/nexus start
#echo "Getting nexus status"
#NEXUS_STATUS=$(sudo -Hu nexus $NEXUS_HOME/bin/nexus status)
#echo "Got nexus status [$NEXUS_STATUS]"
#echo "Stopping nexus"
#sudo -Hu nexus $NEXUS_HOME/bin/nexus stop

#if [ "$NEXUS_STATUS" != "nexus is running." ]
#then
#  echo "Expected nexus status [nexus is running.] but was [$NEXUS_STATUS]; abort..."
#  exit 1
#fi

echo "Install Nexus3 as a service"
sudo ln -s $NEXUS_HOME/bin/nexus /etc/init.d/nexus
sudo mv -f /tmp/nexus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service

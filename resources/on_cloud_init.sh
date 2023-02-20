#!/bin/bash
# on_cloud_init.sh
# ----------------------------------------------------------------------------
# This script is passed as user data during EC2 launch and executed
# when the EC2 instance is booted for the first time.
# Since all user data scripts are executed as root there's not need for sudo
# ----------------------------------------------------------------------------
set -eu

export DATA_BLOCK_DEVICE=/dev/nvme1n1
export SONATYPE_HOME=/opt/sonatype
export NEXUS_HOME=$SONATYPE_HOME/nexus3
export NEXUS_DATA_ON_ROOT=$SONATYPE_HOME/sonatype-work/nexus3
export NEXUS_DATA_ON_DATA=/data/sonatype-work/nexus3
export NEXUS_DATA_VOLUME_MARKER=$NEXUS_DATA_ON_DATA/.nexus_data_volume

echo 'check if nexus data volume is already mounted'
if [ -e "$NEXUS_DATA_VOLUME_MARKER" ]
then
  echo '*** nexus data volume already mounted ***'
  exit 0
fi

echo '*** mounting nexus data volume ***'

echo 'stop nexus service'
systemctl stop nexus

echo 'get info about all attached block devices'
lsblk -f

echo 'install filesystem xfs on data volume'
file -s $DATA_BLOCK_DEVICE
mkfs -t xfs $DATA_BLOCK_DEVICE
file -s $DATA_BLOCK_DEVICE

echo 'mount data volume at /data'
mkdir /data
echo "UUID=$(sudo blkid -s UUID -o value $DATA_BLOCK_DEVICE)  /data  xfs  defaults,nofail  0  2" | sudo tee /etc/fstab -a
mount -a
mount | grep '/data'
ls -al /data

echo "move nexus workdir to newly attached data volume"
mkdir -p $NEXUS_DATA_ON_DATA
mv $NEXUS_DATA_ON_ROOT $NEXUS_DATA_ON_DATA/
chown -R nexus:nexus $NEXUS_DATA_ON_DATA
ls -al $NEXUS_DATA_ON_DATA

echo "switch nexus configuration to newly attached data volume"
cp -f $SONATYPE_HOME/.local/nexus/nexus.vmoptions.data_volume $NEXUS_HOME/bin/nexus.vmoptions
cat $NEXUS_HOME/bin/nexus.vmoptions

echo "marking data volumes as mounted"
echo "DO NOT DELETE OR RENAME THIS FILE!" > $NEXUS_DATA_VOLUME_MARKER

echo "start nexus service"
systemctl start nexus



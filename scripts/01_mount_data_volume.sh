#!/bin/bash

export DATA_BLOCK_DEVICE=/dev/nvme1n1

echo 'get info about all attached block devices'
sudo lsblk -f

echo 'install filesystem xfs on data volume'
sudo file -s $DATA_BLOCK_DEVICE
sudo mkfs -t xfs $DATA_BLOCK_DEVICE
sudo file -s $DATA_BLOCK_DEVICE

echo 'mount data volume at /data'
sudo mkdir /data
echo "UUID=$(sudo blkid -s UUID -o value $DATA_BLOCK_DEVICE)  /data  xfs  defaults,nofail  0  2" | sudo tee /etc/fstab -a
sudo mount -a
sudo mount | grep '/data'
sudo ls -al /data


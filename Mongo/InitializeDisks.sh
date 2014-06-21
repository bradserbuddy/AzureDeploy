#!/bin/sh

# be careful about drive order - Azure may have created the drives in a different order, size-wise

sudo fdisk /dev/sdc < fdiskCommands.txt
sudo mkfs -t ext4 /dev/sdc1
sudo mkdir /datadrive
sudo mount /dev/sdc1 /datadrive
sudo -i blkid | grep sdc1 | sed -r 's/.*(UUID=\"[0-9a-f-]{36}\").*/\1/' | sed 's/$/ \/datadrive ext4 defaults 0 2/' | sudo tee -a /etc/fstab
sudo umount /datadrive
sudo mount /datadrive

sudo fdisk /dev/sdd < fdiskCommands.txt
sudo mkfs -t ext4 /dev/sdd1
sudo mkdir -p /datadrive/mongodb/journal
sudo chown -R mongodb:nogroup /datadrive/mongodb/journal
sudo mount /dev/sdd1 /datadrive/mongodb/journal
sudo -i blkid | grep sdd1 | sed -r 's/.*(UUID=\"[0-9a-f-]{36}\").*/\1/' | sed 's/$/ \/datadrive\/mongodb\/journal ext4 defaults 0 2/' | sudo tee -a /etc/fstab
sudo umount /datadrive/mongodb/journal
sudo mount /datadrive/mongodb/journal

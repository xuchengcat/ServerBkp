#!/bin/bash
####################################
#
# Backup to NFS mount script.
#
####################################

#contain floder not to back up
excludefile="./exclude.txt"

# back up whole ubuntu image
backup_ubuntu="/"
backup_sdd128="/mnt/SDD128G"
backup_photos="/mnt/HDD12T/Pictures"
    
# Where to backup to.
ubuntu_dest="/mnt/HDD14T/ubuntubkp"
photos_dest="/mnt/HDD14T/phbkp"
sdd128_dest="/mnt/HDD14T/sddbkp"
    
# Create archive filename.
day=$(date +"%Y-%m-%d")
hostname=$(hostname -s)
archive_ubuntu="Ubuntubkp-$hostname-$day.tgz"
archive_photos="Photosbkp-$hostname-$day.tgz"
archive_sdd128="Sdd128bkp-$hostname-$day.tgz"

# ubuntu backup
# Print start status message.
echo "Start Backing up $backup_ubuntu to $ubuntu_dest/$archive_ubuntu"
date
echo
    
# Backup the files using tar.
tar -cpzf $ubuntu_dest/$archive_ubuntu --exclude-from=$excludefile $backup_ubuntu

# Print end status message.
echo
echo "Backup Ubuntu finished"
date
    
# Check file size and remove old versions
OLD_FILE=$(find "$ubuntu_dest" -type f -print0 | xargs -0 ls -lt | tail -n 1 | awk '{print $9}')
if [ -z "$OLD_FILE" ]; then
   echo "could not find old backup in dest: $ubuntu_dest"
fi
rm "$OLD_FILE"
echo "remove the old Ubuntu backup: $OLD_FILE"

# photo backup
# Print start status message.
echo "Start Backing up $backup_photos to $photo_dest/$archive_photos"
date
echo
    
# Backup the files using tar.

tar -cpzf $photo_dest/$archive_photos $backup_photos

# Print end status message.
echo
echo "Backup photos finished"
date

OLD_FILE=$(find "$photo_dest" -type f -print0 | xargs -0 ls -lt | tail -n 1 | awk '{print $9}')
if [ -z "$OLD_FILE" ]; then
   echo "could not find old backup in dest: $photo_dest"
fi
rm "$OLD_FILE"
echo "remove the old backup: $OLD_FILE"

# sdd128 backup
# Print start status message.
echo "Start Backing up $backup_sdd128 to $sdd128_dest/$archive_sdd128"
date
echo
    
# Backup the files using tar.

tar -cpzf $sdd128_dest/$archive_sdd128 $backup_sdd128

# Print end status message.
echo
echo "Backup sdd128 finished"
date


OLD_FILE=$(find "$sdd128_dest" -type f -print0 | xargs -0 ls -lt | tail -n 1 | awk '{print $9}')
if [ -z "$OLD_FILE" ]; then
   echo "could not find old backup in dest: $sdd128_dest"
fi
rm "$OLD_FILE"
echo "remove the old backup: $OLD_FILE"
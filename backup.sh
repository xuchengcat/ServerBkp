#!/bin/bash
####################################
#
# Backup to NFS mount script.
#
####################################

excludefile="./exclude.txt"

backup_ubuntu="/"
backup_sdd128="/mnt/SDD128G"
backup_photos="/mnt/HDD12T/Pictures"

ubuntu_dest="/mnt/HDD14T/ubuntubkp"
photos_dest="/mnt/HDD14T/phbkp"
sdd128_dest="/mnt/HDD14T/sddbkp"

day=$(date +"%Y-%m-%d")
hostname=$(hostname -s)

# Function to perform backup
backup() {
    local source=$1
    local dest=$2
    local archive_name=$3
    local exclude=$4

    echo "Start Backing up $source to $dest/$archive_name"
    date
    echo

    if [ -n "$exclude" ]; then
        tar -cpzf "$dest/$archive_name" --exclude-from="$exclude" "$source"
    else
        tar -cpzf "$dest/$archive_name" "$source"
    fi

    echo
    echo "Backup finished for $source"
    date

    OLD_FILE=$(find "$dest" -type f -print0 | xargs -0 ls -lt | tail -n 1 | awk '{print $9}')
    if [ -z "$OLD_FILE" ]; then
        echo "could not find old backup in dest: $dest"
    else
        rm "$OLD_FILE"
        echo "Removed the old backup: $OLD_FILE"
    fi
}

# Perform backups
backup "$backup_ubuntu" "$ubuntu_dest" "Ubuntubkp-$hostname-$day.tgz" "$excludefile"
backup "$backup_photos" "$photos_dest" "Photosbkp-$hostname-$day.tgz" ""
backup "$backup_sdd128" "$sdd128_dest" "Sdd128bkp-$hostname-$day.tgz" ""

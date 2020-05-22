#!/bin/bash

### config ###
name='azuracast-jadin-me'
image_id_path='/home/jadinme/radio.jadin.me/image_id'
droplet_id_path='/home/jadinme/radio.jadin.me/droplet_id'

if [[ ! -f $droplet_id_path ]]
then
    echo "$droplet_id_path does not exist. Please write an id for the droplet you would like to backup and destroy"
fi

# find a snapshot to restore from
echo "Looking for a drpolet id"
droplet_id=$(cat $droplet_id_path)

#Let's make sure the snapshot has a unique name
now=$(date +%Y%m%d_%H%M%S)
snapshotName="$name-snapshot-$now"

# Change the webpage to show that we are offline
echo "Copying offline.html over the top of index.html"
cp /home/jadinme/radio.jadin.me/offline.html /home/jadinme/radio.jadin.me/index.html

# shutdown droplet and take a snapshot
echo ""
echo "Shutting down droplet $droplet_id"
doctl compute droplet-action shutdown $droplet_id --wait
echo ""
echo "Taking snapshot of droplet $droplet_id"
doctl compute droplet-action snapshot $droplet_id --snapshot-name $snapshotName --wait

# write id of the most recent image to disk so we can call it later
image_id=$(doctl compute droplet snapshots $droplet_id --format "ID" | tail -n 1)
echo $image_id > $image_id_path

# Delete the droplet
echo ""
echo "Deleting droplet $droplet_id"
doctl compute droplet delete $droplet_id -f
#!/bin/bash


#THIS IS A TEST!!!!

### config ###
name='azuracast-jadin-me'
floating_ip='157.230.65.247'
image_id_path='/home/jadinme/radio.jadin.me/image_id'
droplet_id_path='/home/jadinme/radio.jadin.me/droplet_id'

# Make sure a droplet isn't already spun up
droplet_id=$(doctl compute droplet list $name* --format "ID" --no-header)
if [ -z "$droplet_id" ];
    then
        echo "Spinning up a new droplet"
    else
        echo "Uh oh, there is already at least one droplet that matches the specified name. Exiting..."
        exit
fi

# find a snapshot to restore from
if [ -f "$image_id_path" ];
    then
        echo "Looking for a snapshot to restore from"
        image_id=$(cat $image_id_path)
        echo "Restoring from $image_id"
    else
        echo "$image_id_path does not exist. Please write an id for the snapshot you would like to restore from there"
        exit
fi

# Let's make sure when we spin up a droplet we have a unique name
now=$(date +%F-%H%M%S)
dropletName="$name-$image_id-$now"

# Spin up the droplet
echo "Creating droplet: $dropletName"
echo ""
doctl compute droplet create $dropletName --size s-1vcpu-2gb --image $image_id --region nyc1 --enable-backups --wait
echo ""

# write id of the droplet to disk so we can find it later
droplet_id=$(doctl compute droplet list $name* --format "ID" --no-header)
echo $droplet_id > $droplet_id_path

# Assign the floating ip to the new droplet
doctl compute floating-ip-action assign $floating_ip $droplet_id

# Change the webpage to show that we are online
echo ""
echo "Copying online.html over the top of index.html"
cp /home/jadinme/radio.jadin.me/online.html /home/jadinme/radio.jadin.me/index.html

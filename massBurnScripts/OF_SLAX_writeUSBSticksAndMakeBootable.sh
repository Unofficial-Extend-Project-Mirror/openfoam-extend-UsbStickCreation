#!/bin/bash
#
# This script will transfer an OpenFOAM_SLAX distro over one or
# many USB sticks connected to a single host.
#
# One has to be root for running this script because you need to 
# mount a device.
#
#
# Step #1: Connect the USB sticks to the computer USB ports
#
# Step #2: Grab the device name for each USB sticks (/dev/sdb1, etc)
#          The files /etc/fstab or /etc/mtab are good place to look for this info.
#
# Step #3: Optionnaly, move to the directory containing the ./slax and ./boot directories
#
# Step #4: Invoke the script using the name of the Slax directory, and the list of USB
#          device names as parameters 
#
# For example, for 2 USB sticks connected to /dev/sdb1 and /dev/sdc1:
#
#  OF_SLAX_writeUSBSticksAndMakeBootable.sh path_to_Slax_root_directory /dev/sdb1 /dev/sdc1
#
# >>>>>>>>> Warning Warning Warning Warning Warning Warning Warning  
#
# I made some reasonable efforts to fool-proof this script in case you
# mistakenly specify a valid but still wrong device for the USB sticks.
# 
# Same thing for the root path of the Slax distro.
#
# Also there is no guarantee that the command udevinfo is available on your
# OS, so the last verification step may fail, and prevent writing the USB sticks.  
# You might have to adjust this part of the script, or simple to comment it out.
#
# IN ANY CASE, PLEASE ALWAYS PAY ATTENTION AT THE DEVICE NAME YOU ARE
# FEEDING THIS SCRIPT.
#
# Author: Martin Beaudoin, Hydro-Quebec, (2009)
#
#
#set -x
#
# Customize these values based on your own Operating system 
#
UNMOUNT_CMD="umount"
MOUNT_CMD="mount"

# For OpenSUSE 10.3
#MOUNT_OPTIONS="-t vfat -o rw,nosuid,nodev,noatime,flush,uid=$UID"
#
# For Centos
#MOUNT_OPTIONS="-t vfat -o rw,nosuid,nodev,noatime,uid=$UID"
#
# Very plain version of the mount options
MOUNT_OPTIONS="-t vfat -o rw"

# We will mount the USB stick on this mount point
TMP_MNTPOINT="/mnt"

# Grab the root path to the Slax distro
SLAX_DIR=$1

# The rest of the parameters are for the USB sticks devices
shift

echo "######## This is computer : $HOSTNAME ######## "
echo ""

# Is this a SLAX root directory ?
if [ -e $SLAX_DIR ] && [ -e $SLAX_DIR/slax ] && [ -e $SLAX_DIR/boot ]   
then
    cd $SLAX_DIR
else
    echo "The specified SLAX directory is not valid: $SLAX_DIR"
    echo "Exiting"
    exit 
fi

# Iterate over list of specified USB devices
for device in "$@" 
do
    if [ -e $device ]   # Device exists
    then
        # This part may need some customization for your version of Linux
        IS_A_USB_DEVICE=`udevinfo -q all -n $device | grep -i usb `

        if [ ! -z "$IS_A_USB_DEVICE" ] # Device is USB
        then
	    echo "Writing OpenFOM_SLAX on device:  $device"

            # Unmount the device so we can control the mount point
	    eval $UNMOUNT_CMD $device

            # Mount device on $TMP_MNTPOINT
            echo "Mounting $device on $TMP_MNTPOINT"
	    eval $MOUNT_CMD $MOUNT_OPTIONS $device $TMP_MNTPOINT

            # Verify if the mount point is ok
            MOUNT_STATUS=`mount -l | grep $device | grep $TMP_MNTPOINT`
            if [ -z "$MOUNT_STATUS" ] 
            then
                echo "Problem mounting device $device on $TMP_MNTPOINT. Aborting"
                exit
            else
                echo "Mount point is available: $MOUNT_STATUS"
            fi

            # Copy the SLAX files
	    if [ -e boot ]
	    then
                echo "Copying ./boot"
		rm -rf $TMP_MNTPOINT/boot
		cp -r ./boot $TMP_MNTPOINT
	    else
	        echo "Directory ./boot is missing. This is not a SLAX directory. Exiting."
		exit
	    fi

	    if [ -e slax ]
	    then
                echo "Copying ./slax"
		rm -rf $TMP_MNTPOINT/slax
		cp -r ./slax $TMP_MNTPOINT
	    fi

            # Remove relics from an earlier install/use
            # Please comment out if you need to keep your changes
	    if [ -e $TMP_MNTPOINT/slaxchanges ]
	    then
                echo "Removing $TMP_MNTPOINT/slaxchanges"
		rm -rf $TMP_MNTPOINT/slaxchanges
	    fi

            # Copy the workshop slides
	    if [ -e 4th_Workshop ]
	    then
                echo "Copying ./4th_Workshop"
		rm -rf $TMP_MNTPOINT/4th_Workshop
		cp -r ./4th_Workshop $TMP_MNTPOINT
	    fi

            # Unmount the temporary mount point to force a sync
            echo "Unmounting $device: Forcing a sync"
	    sync
	    eval $UNMOUNT_CMD $TMP_MNTPOINT
	    sleep 5

            # Mount again the device on /mnt
            echo "Mounting $device on $TMP_MNTPOINT"
	    eval $MOUNT_CMD $MOUNT_OPTIONS $device $TMP_MNTPOINT

            # Verify that the transfer went well
	    # Nothing should differ because we have not yet modified the
	    # boot sector of the USB stick.
            echo "Checking if the copy went well..."
            echo "---> Nothing should differ from the original source..."
	    diff -r . $TMP_MNTPOINT

            # Make the USB stick bootable
            echo "Making the USB device bootable"
	    echo "\n\n" | $TMP_MNTPOINT/boot/bootinst.sh

            # We are done. Unmount the temporary mount point
            echo "Unmounting $device"
	    sync
	    eval $UNMOUNT_CMD $TMP_MNTPOINT

            echo "Done writing device: $device."
        else
	    echo "This is not a USB device:  $device: Skipping."
        fi 
    else
        echo "Unknown device:  $device: Skipping"
    fi
done 
echo ""

# End of script

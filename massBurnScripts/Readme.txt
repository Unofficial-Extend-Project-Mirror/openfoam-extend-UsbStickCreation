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


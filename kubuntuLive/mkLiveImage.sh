#!/bin/bash

###################################################################################
# Copyright (C) 2010 by Oliver Borm, oli.borm@web.de                              #
#                                                                                 #
# This program is free software: you can redistribute it and/or modify            #
# it under the terms of the GNU General Public License as published by            #
# the Free Software Foundation, either version 3 of the License, or               #
# (at your option) any later version.                                             #
#                                                                                 #
# This program is distributed in the hope that it will be useful,                 #
# but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   #
# GNU General Public License for more details.                                    #
#                                                                                 #
# You should have received a copy of the GNU General Public License               #
# along with this program. If not, see <http://www.gnu.org/licenses/>.            #
###################################################################################

## this script is based on a kubuntu desktop image; for other desktop managers you will have to adjust them
## You will need at least version 2.0.12 of uck, see also bug: https://bugs.launchpad.net/uck/+bug/271677

## usage:
#
# ./mkLiveImage.sh kubuntu-10.04-desktop-i386.iso kde-input-files/ <dvd|usb>
#
# $1 path to iso input image
# $2 path to directory of customize batch files
# $3 optional: build a dvd or usb image
#

function failure()
{
	echo "$@"
	exit 1
}

IMAGEPATH=$(dirname `readlink -f $1`)
CD=`basename $1`
ISOPATH="$IMAGEPATH/${CD##*/}"
SCRIPTPATH=`readlink -f $2`
BUILD=${3:-usb} ## dvd|usb

set -- "$CD"
IFS="-"; declare -a CDARRAY=($*); IFS=

DESKTOP=${CDARRAY[0]}
VERSION=${CDARRAY[1]}
ARCH=`echo "${CDARRAY[$((${#CDARRAY[@]}-1))]}" | cut -d"." -f1`
TMPDIR=/tmp

echo $CD $BUILD
echo $ARCH $DESKTOP $VERSION

if [ ! -e $ISOPATH ]; then
	cd $IMAGEPATH
	if [ $DESKTOP = "kubuntu" ]; then
		wget http://releases.ubuntu.com/${DESKTOP}/${VERSION}/$CD
	elif [ $DESKTOP = "ubuntu" ]; then
		wget http://releases.ubuntu.com/${VERSION}/$CD
	fi
	chmod 644 $CD
fi

## customize scripts
sed -i "s@`grep BUILD= $SCRIPTPATH/customize`@BUILD=\"$BUILD\"@" $SCRIPTPATH/customize || failure "cannot rename BUILD type"
sed -i "s@`grep SOURCEDIR= $SCRIPTPATH/customize_iso`@SOURCEDIR=\"$SCRIPTPATH\"@" $SCRIPTPATH/customize_iso || failure "cannot rename SOURCEDIR"

## copy files
cp $SCRIPTPATH/sources.list $TMPDIR

## copy local repository
# cp -r ~/Dokumente/builds/depot $TMPDIR

# copy customize script, due to bug: https://bugs.launchpad.net/uck/+bug/547260
mkdir -p $TMPDIR/customization-scripts
cp $SCRIPTPATH/customize $TMPDIR/customization-scripts

# Need something like this
#sudo umount ~/tmp/remaster-root/tmp/

echo "iso image: " $ISOPATH
echo "script path: " $SCRIPTPATH

## remaster image
sudo uck-remaster $ISOPATH $SCRIPTPATH

## copy image
if [ "$BUILD" = "dvd" ]; then
	ISOPATH="${ISOPATH%${ARCH}.iso}remastered-dvd-${ARCH}.iso"
else
	ISOPATH="${ISOPATH%${ARCH}.iso}remastered-usb-${ARCH}.iso"
fi

cp ~/tmp/remaster-new-files/livecd.iso $ISOPATH

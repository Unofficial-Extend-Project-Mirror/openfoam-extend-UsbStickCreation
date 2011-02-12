#! /bin/bash

usage()
{
cat << EOF
usage: $0 options

This script updates the OpenFOAM workshop material

OPTIONS:
   -h      Show this message
   -w      Use wget instead of rsync
   -b      Do not ask for user interaction in the end      
EOF
}

# Data specific to each workshop which will need to be changed each year

user=OFW6
srcdir=OFW6Docs
downloadPassword=leakedFromTheWorkshop
destdir="OFW6"
webSpace=http://web.student.chalmers.se/groups/ofw5



location=`dirname $PWD`
fullPath="$location/$destdir"

echo $location

RSYNC=1
WAITATEND=

while getopts "hwb" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         w)
             RSYNC=
             ;;
         b)
             WAITATEND=1
             ;;
     esac
done

echo "Syncing to $fullPath"

if [ ! -d $fullPath ]
then
    echo "I think you are running the script in the wrong place, man. You are not in $destdir directory"
    if [ -z $WAITATEND ]
    then
	echo "Press <ENTER> to continue"
	read
    fi
    exit 1
fi

if [ ! -z $RSYNC ]
then
    export RSYNC_PASSWORD=$downloadPassword
    rsync 2>&1 -rvt $user@openfoamwiki.net::$srcdir $fullPath | tee "$0.rsync.log"
else
    wget 2>&1 -N $webSpace/fileList.md5 | tee "$0.wget.log"
    md5sum -c fileList.md5 | egrep FAILED | sed 's/: FAILED.*//' | wget 2>&1 -xnH --cut-dirs=2 -i- -B $webSpace/ | tee -a "$0.wget.log"
fi

if [ ! -z $WAITATEND ]
then
    echo "Press <ENTER> to continue"
    read
fi

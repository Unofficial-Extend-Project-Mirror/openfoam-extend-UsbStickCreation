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

location=`dirname $PWD`
theDir="OFW5"
fullPath="$location/$theDir"

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
    echo "I think you are running the script is in the wrong place, man. Your are not in $theDir directory"
    if [ -z $WAITATEND ]
    then
	echo "Press <ENTER> to continue"
	read
    fi
    exit 1
fi

if [ ! -z $RSYNC ]
then
    export RSYNC_PASSWORD=ikeaIsNotSwedish
    rsync 2>&1 -rvt OFW5@openfoamwiki.net::OFW5Docs $fullPath | tee "$0.rsync.log"
else
    wget 2>&1 -N http://web.student.chalmers.se/groups/ofw5/fileList.md5 | tee "$0.wget.log"
    md5sum -c fileList.md5 | egrep FAILED | sed 's/: FAILED.*//' | wget 2>&1 -xnH --cut-dirs=2 -i- -B http://web.student.chalmers.se/groups/ofw5/ | tee -a "$0.wget.log"
fi

if [ ! -z $WAITATEND ]
then
    echo "Press <ENTER> to continue"
    read
fi

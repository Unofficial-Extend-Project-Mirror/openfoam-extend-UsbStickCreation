#! /bin/sh
#
# This script synchronizes the contents of a local subdirectory (e.g. www/)
# to the openfoamwiki.net directory, deleting any extraneous files from
# the destination directory.
#
# The script will take the RSYNC_PASSWORD from the environment if it
# is defined in order to avoid exposing the password here.
#
# Username and destination directory name will need to be updated each year.

user=OFW6Upload
destdir=OFW6DocsUpload
srcDir="www"


location=`dirname $PWD`
fullPath="$location/$srcDir"
scriptname=`basename "$0"`

echo "Syncing from $fullPath"

if [ -z $RSYNC_PASSWORD ]
then
    export RSYNC_PASSWORD=none
fi

if [ $RSYNC_PASSWORD = "none" ]
then
    echo "I think you need to add the correct password"
    exit
fi


if [ ! -d $srcDir ]
then
    echo "I think the script is in the wrong place, man. There is no folder $srcDir here"
    exit
fi


cd $srcDir
chmod -R g+rwX *
rm -f fileList.md5

rsync 2>&1 -rtv --delete . $user@openfoamwiki.net::$destdir | tee "../$scriptname.rsync.log"

find . ! -type d -a ! -name fileList.md5 -print0 | xargs -0 md5sum > fileList.md5


# Pertinent bits from the rsync man page:
#
# Contacting an rsync daemon directly happens when the source or
# destination path contains a double colon (::) separator after a
# host specification...
#
# -v        increase verbosity
# -r        recurse into directories
# -t        preserve modification times
# --delete  delete extraneous files from dest dir

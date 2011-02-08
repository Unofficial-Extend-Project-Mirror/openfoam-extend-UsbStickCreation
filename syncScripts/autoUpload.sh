#! /bin/sh
location=`dirname $PWD`
theDir="www"
fullPath="$location/$theDir"

echo "Syncing from $fullPath"

export RSYNC_PASSWORD=none

if [ $RSYNC_PASSWORD = "none" ]
then
    echo "I think you need add the correct password"
    exit
fi


if [ ! -d $theDir ]
then
    echo "I think the script is in the wrong place, man. There is no folder $theDir here"
    exit
fi


cd $theDir
chmod -R g+rwX *
rm fileList.md5

rsync 2>&1 -rtv --delete . OFW5Upload@openfoamwiki.net::OFW5DocsUpload | tee "../$0.rsync.log"

find . ! -type d -a ! -name fileList.md5 -print0 | xargs -0 md5sum > fileList.md5


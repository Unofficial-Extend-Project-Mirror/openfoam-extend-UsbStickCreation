This directory contains scripts for synchronizing the workshop
data (presentations and tutorials) to a server for access by
the registrants.

autoUpload.sh and autoDownload.sh are the basic scripts that
contain all the magic:
 - autoDownload.sh goes on the stick (password is public knowledge)
 - autoUpload.sh stays with you (password should not be shared)

The rsync options are set in such a way that 
 - the upload-script creates an exact replica of your local directory
   on the server (adds and removes files)
 - the download-script downloads newer versions and uses them to
   replace local copies. If a file is not on the server it stays in
   the local copy!

The major use case where this might be important is that the
presentation ConfidentialDataThatShouldNotBeHere.pdf got uploaded and
the guy who provided it says "Wait a minute. This might get me into
trouble. Please remove it". Removing it from the master copy will
remove it from the server but sticks that already downloaded it will
still have (and keep) the copy. The only solution for this is to
upload a bogus (no pun intended) version of the pdf (for instance only
a title slide). That will overwrite the pdf the next time the stick
syncs.

The reason it is set up this way is that if somebody accidentally
uploads an "empty" copy to the server (erasing everything there)
syncing the sticks won't erase all the data there.


Contributors:

* Bernhard F.W. Gschaider: scripts and description

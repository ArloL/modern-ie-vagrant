#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --continue --timestamping http://code.kliu.org/misc/elevate/elevate-1.3.0-redist.7z

7z x elevate-1.3.0-redist.7z -y -o$(pwd)/elevate

wget --continue --timestamping http://download.virtualbox.org/virtualbox/5.1.18/VBoxGuestAdditions_5.1.18.iso

7z x VBoxGuestAdditions_5.1.18.iso -y -o$(pwd)/VBoxGuestAdditions

wget --continue --timestamping https://download.sysinternals.com/files/SDelete.zip
shasum --check SDelete.zip.sha1

unzip -o SDelete.zip -d SDelete

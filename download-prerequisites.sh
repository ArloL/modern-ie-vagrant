#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --continue --timestamping http://code.kliu.org/misc/elevate/elevate-1.3.0-redist.7z

7z x elevate-1.3.0-redist.7z -y -o$(pwd)/elevate

wget --continue --timestamping http://download.virtualbox.org/virtualbox/5.1.28/VBoxGuestAdditions_5.1.28.iso

7z x VBoxGuestAdditions_5.1.28.iso -y -o$(pwd)/VBoxGuestAdditions

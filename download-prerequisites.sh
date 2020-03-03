#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --continue --timestamping http://code.kliu.org/misc/elevate/elevate-1.3.0-redist.7z

7z x elevate-1.3.0-redist.7z -y -o$(pwd)/elevate

wget --continue --timestamping http://download.virtualbox.org/virtualbox/6.1.4/VBoxGuestAdditions_6.1.4.iso

7z x VBoxGuestAdditions_6.1.4.iso -y -o$(pwd)/VBoxGuestAdditions

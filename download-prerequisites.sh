#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --quiet --continue --timestamping http://download.virtualbox.org/virtualbox/6.1.14/VBoxGuestAdditions_6.1.14.iso

7z x VBoxGuestAdditions_6.1.14.iso -y -o"$(pwd)/VBoxGuestAdditions"

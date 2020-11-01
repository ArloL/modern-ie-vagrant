#!/usr/bin/env bash

set -o errexit
set -o xtrace

cd scripts

wget --quiet --continue --timestamping https://download.virtualbox.org/virtualbox/6.1.16/VBoxGuestAdditions_6.1.16.iso

7z x VBoxGuestAdditions_6.1.16.iso -y -o"$(pwd)/VBoxGuestAdditions"

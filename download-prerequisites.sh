#!/usr/bin/env bash

set -o errexit
set -o xtrace

cd scripts

latest=$(curl -s https://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT)

wget --quiet --continue --timestamping "https://download.virtualbox.org/virtualbox/${latest}/VBoxGuestAdditions_${latest}.iso"

7z x "VBoxGuestAdditions_${latest}.iso" -y -o"$(pwd)/VBoxGuestAdditions"

#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

cd scripts

latest=$(curl -s https://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT)

wget --quiet --continue --timestamping "https://download.virtualbox.org/virtualbox/${latest}/VBoxGuestAdditions_${latest}.iso"

7z x "VBoxGuestAdditions_${latest}.iso" -y -o"$(pwd)/VBoxGuestAdditions"

case ${1:-} in
    "win7"*)
        ;&
    "")
        wget --quiet --continue --timestamping --output-document=Win7-KB3191566-x86.zip \
            "https://go.microsoft.com/fwlink/?linkid=839522"
        7z x "Win7-KB3191566-x86.zip" -y -o"$(pwd)/Win7-KB3191566-x86"
        ;;
esac

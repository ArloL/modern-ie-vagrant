#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --continue --timestamping http://code.kliu.org/misc/elevate/elevate-1.3.0-redist.7z

wget --continue --timestamping http://download.virtualbox.org/virtualbox/5.1.14/VBoxGuestAdditions_5.1.14.iso

7z x VBoxGuestAdditions_5.1.14.iso -y -o$(pwd)/VBoxGuestAdditions

wget --continue --timestamping https://download.sysinternals.com/files/SDelete.zip
shasum --check SDelete.zip.sha1

wget --continue --timestamping --output-document ultradefrag-portable-7.0.1.bin.amd64.zip https://sourceforge.net/projects/ultradefrag/files/stable-release/7.0.1/ultradefrag-portable-7.0.1.bin.amd64.zip/download
shasum --check ultradefrag-portable-7.0.1.bin.amd64.zip.sha1

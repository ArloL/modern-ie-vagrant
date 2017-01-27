#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --continue --timestamping http://code.kliu.org/misc/elevate/elevate-1.3.0-redist.7z

7z x elevate-1.3.0-redist.7z -y -o$(pwd)/elevate

wget --continue --timestamping http://download.virtualbox.org/virtualbox/5.1.14/VBoxGuestAdditions_5.1.14.iso

7z x VBoxGuestAdditions_5.1.14.iso -y -o$(pwd)/VBoxGuestAdditions

wget --continue --timestamping https://download.sysinternals.com/files/SDelete.zip
shasum --check SDelete.zip.sha1

unzip -o SDelete.zip -d SDelete

version="7.0.2"

wget --output-document ultradefrag-portable-$version.bin.i386.zip http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-$version.bin.i386.zip
shasum --check ultradefrag-portable-$version.bin.i386.zip.sha1

unzip -o ultradefrag-portable-$version.bin.i386.zip

mv ultradefrag-portable-$version.i386 ultradefrag

wget --output-document ultradefrag-portable-$version.bin.amd64.zip http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-$version.bin.amd64.zip
shasum --check ultradefrag-portable-$version.bin.amd64.zip.sha1

unzip -o ultradefrag-portable-$version.bin.amd64.zip

mv ultradefrag-portable-$version.amd64 ultradefrag64

#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --continue --timestamping https://download.sysinternals.com/files/sdelete.zip
shasum --check SDelete.zip.sha1

wget --continue --timestamping http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.0.bin.amd64.zip
shasum --check ultradefrag-portable-7.0.0.bin.amd64.zip.sha1

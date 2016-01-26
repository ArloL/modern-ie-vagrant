#!/bin/sh

set -e
set -x

cd scripts

wget -c -N https://download.sysinternals.com/files/sdelete.zip
shasum --check SDelete.zip.sha1

wget -c -N http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-6.1.0.bin.amd64.zip
shasum --check ultradefrag-portable-6.1.0.bin.amd64.zip.sha1

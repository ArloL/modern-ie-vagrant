#!/bin/sh

set -e
set -x

cd scripts

wget -N http://download.sysinternals.com/files/SDelete.zip
shasum --check SDelete.zip.sha1

wget -N http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-6.1.0.bin.amd64.zip
shasum --check ultradefrag-portable-6.1.0.bin.amd64.zip.sha1

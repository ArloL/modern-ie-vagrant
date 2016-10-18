#!/bin/sh

set -o errexit
set -o xtrace

cd scripts

wget --continue --timestamping http://download.microsoft.com/download/0/8/c/08c19fa4-4c4f-4ffb-9d6c-150906578c9e/NetFx20SP1_x86.exe
shasum --check NetFx20SP1_x86.exe.sha1

wget --continue --timestamping http://download.microsoft.com/download/E/C/E/ECE99583-2003-455D-B681-68DB610B44A4/WindowsXP-KB968930-x86-ENG.exe
shasum --check WindowsXP-KB968930-x86-ENG.exe.sha1

wget --continue --timestamping http://schinagl.priv.at/nt/hardlinkshellext/driver/symlink-1.06-x86.cab
shasum --check symlink-1.06-x86.cab.sha1

wget --continue --timestamping https://sourceforge.net/projects/ultradefrag/files/stable-release/7.0.0/ultradefrag-portable-7.0.0.bin.i386.zip/download
shasum --check ultradefrag-portable-7.0.0.bin.i386.zip.sha1

wget --continue --timestamping http://files1.majorgeeks.com/4ab35559cc92240547c18e228f234484/system/removewga.exe

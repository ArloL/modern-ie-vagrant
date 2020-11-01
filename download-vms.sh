#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

./download-vm.sh win7-ie8
./download-vm.sh win7-ie9
./download-vm.sh win7-ie10
./download-vm.sh win7-ie11
./download-vm.sh win81-ie11
./download-vm.sh win10-edge

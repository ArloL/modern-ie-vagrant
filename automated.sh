#!/usr/bin/env bash

set -o nounset

install_mode="${1:-auto}"

./automated-win.sh win7-ie8 "${install_mode}"
./automated-win.sh win7-ie9 "${install_mode}"
./automated-win.sh win7-ie10 "${install_mode}"
./automated-win.sh win7-ie11 "${install_mode}"
./automated-win.sh win81-ie11 "${install_mode}"
./automated-win.sh win10-edge "${install_mode}"

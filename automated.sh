#!/usr/bin/env bash

set -o nounset

GUEST_ADDITIONS_INSTALL_MODE="${1:-auto}"

./automated-win.sh win7-ie8 "${GUEST_ADDITIONS_INSTALL_MODE}"
./automated-win.sh win7-ie9 "${GUEST_ADDITIONS_INSTALL_MODE}"
./automated-win.sh win7-ie10 "${GUEST_ADDITIONS_INSTALL_MODE}"
./automated-win.sh win7-ie11 "${GUEST_ADDITIONS_INSTALL_MODE}"
./automated-win.sh win81-ie11 "${GUEST_ADDITIONS_INSTALL_MODE}"
./automated-win.sh win10-edge "${GUEST_ADDITIONS_INSTALL_MODE}"

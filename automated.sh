#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

vagrant destroy --force || true

./automated-win.sh win7-ie8
./automated-win.sh win7-ie9
./automated-win.sh win7-ie10
./automated-win.sh win7-ie11
./automated-win.sh win81-ie11
./automated-win.sh win10-edge

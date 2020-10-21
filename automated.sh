#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

vagrant destroy --force || true

./automated-win.sh win7-ie8
vagrant destroy --force || true

./automated-win.sh win7-ie9
vagrant destroy --force || true

./automated-win.sh win7-ie10
vagrant destroy --force || true

./automated-win.sh win7-ie11
vagrant destroy --force || true

./automated-win.sh win81-ie11
vagrant destroy --force || true

./automated-win.sh win10-edge
vagrant destroy --force || true

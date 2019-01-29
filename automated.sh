#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

vagrant destroy --force || true

sh automated-win7-ie8.sh
vagrant destroy --force || true

sh automated-win7-ie9.sh
vagrant destroy --force || true

sh automated-win7-ie10.sh
vagrant destroy --force || true

sh automated-win7-ie11.sh
vagrant destroy --force || true

sh automated-win81-ie11.sh
vagrant destroy --force || true

# 2018-01-29: Currently not with guest additions
#sh automated-win10-edge.sh
sh automated-win10-edge-no-additions.sh
vagrant destroy --force || true

# 2018-08-30: Currently no download available
#sh automated-win10-preview-edge.sh
#vagrant destroy --force || true

#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

for i in `ls -1 *.box`; do
    name=$(basename $i | cut -d. -f1)
    vagrant box add --name "okeeffe-${name}" --force "${name}.box"
done

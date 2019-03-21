#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

for i in `ls -1 *.box`; do
    box_name=$(basename $i | cut -d. -f1)
    vagrant box add --name "okeeffe-${box_name}" --force "${name}.box"
done

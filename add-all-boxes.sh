#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

for i in *.box
do
    [[ -e "$i" ]] || break  # handle the case of no *.box files
    box_name=$(basename "$i" | cut -d. -f1)
    vagrant box add --name "okeeffe-${box_name}" --force "${box_name}.box"
done

#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

. functions.sh

download_prerequisites "${1:-}"

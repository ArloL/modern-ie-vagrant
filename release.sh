#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

MAJOR_MINOR=$(date -u +"%Y.%-m")
git fetch --prune --prune-tags --tags --force

for MICRO in $(seq 0 999); do
    VERSION=${MAJOR_MINOR}.${MICRO}
    if git tag "v${VERSION}"; then
        break
    fi
done

git push origin "v${VERSION}"
echo "::set-output name=version::${VERSION}"

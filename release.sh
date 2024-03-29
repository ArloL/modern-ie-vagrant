#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

MAJOR_MINOR=$(date -u +"%y%m")
git fetch --prune --prune-tags --tags --force

for MICRO in $(seq 1 999); do
    VERSION=${MAJOR_MINOR}.${MICRO}
    if git tag "v${VERSION}" && git push origin "v${VERSION}"; then
        break
    fi
done

echo "version=${VERSION}" >> "$GITHUB_OUTPUT"

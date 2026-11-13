#!/usr/bin/env bash
set -euo pipefail

: "${SITE_URL:?SITE_URL must point to the deployed website}"
response_file=$(mktemp)
trap 'rm -f "$response_file"' EXIT

for page in index.html lt.html; do
    expected=$(sed -n 's/.*<a class="download" href="\([^"]*\)".*/\1/p' "dist/$page")
    if [[ -z "$expected" ]]; then
        echo "::error::Missing download link in dist/$page"
        exit 1
    fi
    path=$page
    [[ "$page" != index.html ]] || path=''
    verified=false
    for attempt in {1..12}; do
        url="${SITE_URL%/}/$path"
        if curl -L --fail --silent --show-error --max-time 10 \
            "$url" -o "$response_file" &&
            grep -Fq -- "href=\"$expected\"" "$response_file"; then
            verified=true
            break
        fi
        [[ "$attempt" == 12 ]] || sleep 5
    done
    if [[ "$verified" != true ]]; then
        echo "::error::Live $page does not contain the deployed release download link: $expected"
        exit 1
    fi
    echo "Verified live release download link for $page."
done

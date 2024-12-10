#!/usr/bin/env bash

set -ex

. .config

export version=$(curl -XGET --head https://telegram.org/dl/desktop/linux 2>/dev/null |grep -i location |cut -d '/' -f 5 |cut -d '.' -f 2-4)
echo "Latest Telegram Desktop: $version"

echo $version > .telegram_version

if [[ ! -z "$version" ]]; then
    envsubst '$version' < Dockerfile.template > Dockerfile
    docker build --build-arg telegram_version="${version}" -t "${TAG}:${version}" .
else
    echo "ERROR: Can't get Telegram version!"

fi


#!/usr/bin/env bash

# docker run --privileged --rm tonistiigi/binfmt --install amd64
# docker buildx create --name multi --use
# docker buildx inspect --bootstrap

set -e

. .config

check_binfmt() {
    echo "[*] Checking binfmt (amd64 emulation)..."
    local binfmt_output
    binfmt_output=$(docker run --rm --privileged tonistiigi/binfmt --install amd64 2>/dev/null || true)

    # Check if the output contains "qemu-x86_64"
    if echo "$binfmt_output" | grep -q "qemu-x86_64"; then
        echo "[+] Binfmt OK — amd64 emulation is available"
    else
        echo "[!] Binfmt is missing or amd64 is not enabled!"
        echo "    Please enable it with:"
        echo "    docker run --privileged --rm tonistiigi/binfmt --install amd64"
        exit 1
    fi
}

check_buildx() {
    echo "[*] Checking Docker Buildx..."
    if ! docker buildx version >/dev/null 2>&1; then
        echo "[!] Docker Buildx is not found!"
        echo "    Please update Docker or install buildx manually."
        exit 1
    fi

    # Verify that the current builder supports linux/amd64
    local platforms
    platforms=$(docker buildx inspect | grep -i "Platforms" || true)
    if [[ "$platforms" != *"linux/amd64"* ]]; then
        echo "[!] The current builder does NOT support linux/amd64!"
        echo "    Create and activate a builder with:"
        echo "    docker buildx create --name multi --use"
        echo "    docker buildx inspect --bootstrap"
        exit 1
    fi
    echo "[+] Buildx OK — linux/amd64 platform is supported"
}

echo "[*] Checking environment..."
check_binfmt
check_buildx
echo "[+] Environment is ready for building"

export version=$(curl -sI https://telegram.org/dl/desktop/linux | grep -i location | cut -d '/' -f 5 | cut -d '.' -f 2-4)
echo "Latest Telegram Desktop version: $version"

echo "$version" > .telegram_version

if [[ -n "$version" ]]; then
    envsubst '$version' < Dockerfile.template > Dockerfile
    docker buildx build --platform linux/amd64 \
        --build-arg telegram_version="${version}" \
        -t "${TAG}:${version}" .
else
    echo "ERROR: Can't fetch Telegram version!"
    exit 1
fi
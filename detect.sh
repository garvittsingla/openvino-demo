#!/usr/bin/env bash
set -euo pipefail

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"  #"ubuntu"
    else
        echo "unsupported"
        exit 1
    fi
}

detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        *)       echo "unsupported"; exit 1 ;;
    esac
}

OS=$(detect_os)
ARCH=$(detect_arch)

echo "Detected OS: $OS"
echo "Detected Architecture: $ARCH"
echo ""

echo "Download URL: https://storage.openvinotoolkit.org/ovms/${OS}/${ARCH}/latest"

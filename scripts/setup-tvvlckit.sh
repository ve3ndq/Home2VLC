#!/bin/bash
set -euo pipefail

# Official stable binary, pinned by archive SHA-256. No package manager required.
project_root="$(cd "$(dirname "$0")/.." && pwd)"
archive_url="https://download.videolan.org/cocoapods/prod/TVVLCKit-3.7.2-3e42ae47-79128878.tar.xz"
archive_sha="fa264c2eb17d648669d9d12b51e76e5b6769828354517d09b340387b30825f58"
task_tmp="$(mktemp -d)"
trap 'rm -rf "$task_tmp"' EXIT
curl -fL "$archive_url" -o "$task_tmp/TVVLCKit.tar.xz"
echo "$archive_sha  $task_tmp/TVVLCKit.tar.xz" | shasum -a 256 -c -
tar -xf "$task_tmp/TVVLCKit.tar.xz" -C "$task_tmp"
mkdir -p "$project_root/Vendor"
if [ -e "$project_root/Vendor/TVVLCKit.xcframework" ]; then
    echo "Vendor/TVVLCKit.xcframework already exists; leaving it unchanged."
else
    cp -R "$task_tmp/TVVLCKit-binary/TVVLCKit.xcframework" "$project_root/Vendor/"
fi

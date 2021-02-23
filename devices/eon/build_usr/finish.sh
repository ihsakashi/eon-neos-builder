#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

# Copy in configurations files
cp -R usr/** out/data/data/com.termux/files/usr/

# Create apt folders
mkdir -p out/data/data/com.termux/files/usr/etc/apt/apt.conf.d/
mkdir -p out/data/data/com.termux/files/usr/etc/apt/preferences.d/
mkdir -p out/data/data/com.termux/files/usr/var/cache/apt/archives/partial
mkdir -p out/data/data/com.termux/files/usr/var/lib/dpkg/updates/
mkdir -p out/data/data/com.termux/files/usr/var/lib/dpkg/info
touch out/data/data/com.termux/files/usr/var/lib/dpkg/info/format-new
touch out/data/data/com.termux/files/usr/var/lib/dpkg/available
mkdir -p out/data/data/com.termux/files/usr/var/log/apt/

# Create tmp symlink
pushd out/data/data/com.termux/files/usr
ln -sf /tmp tmp
popd

# prefix symlink
mkdir -p /data/data/com.termux/files
ln -sf $DIR/out/data/data/com.termux/files/usr /data/data/com.termux/files/usr

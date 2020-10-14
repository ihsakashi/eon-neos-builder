#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

QT_PACKAGE_VERSION=5.13.0
QT_PACKAGE_URL="https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz"

WORK_QT=$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}
OUT_DIR=$DIR/out/data/data/com.termux/files

cd $ROOT/mindroid

if [[ ! -d "${WORK_QT}" ]]; then
    wget --tries=inf $QT_PACKAGE_URL
    tar xvf qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz

    pushd ${WORK_QT}
    patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qdnslookup_unix.cpp.patch
    patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qhostinfo_unix.cpp.patch
    patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtbase_src_plugins_platforms_eglfs_deviceintegration_deviceintegration.pro.patch
    popd

    cp -rf $DIR/qt/qtbase/* ${WORK_QT}/qtbase/
fi

echo "Building QT for NEOS"

#(cd $ROOT/mindroid/system && source build/envsetup.sh && breakfast oneplus3)

cd ${WORK_QT}/qtbase

./configure -v \
    -opensource \
    -confirm-license \
    --disable-rpath \
    -xplatform neos \
    -prefix "$OUT_DIR/usr" \
    -docdir "$OUT_DIR/usr/share/doc/qt" \
    -headerdir "$OUT_DIR/usr/include/qt" \
    -archdatadir "$OUT_DIR/usr/lib/qt" \
    -datadir "$OUT_DIR/usr/share/qt" \
    -sysconfdir "$OUT_DIR/usr/etc/qt" \
    -examplesdir "$OUT_DIR/usr/share/doc/qt/examples" \
    -plugindir "$OUT_DIR/usr/libexec/qt" \
    -no-warnings-are-errors \
    -nomake examples \
    -nomake tests

make
make install

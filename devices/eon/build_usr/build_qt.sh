#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

QT_PACKAGE_VERSION=5.13.0
QT_PACKAGE_URL="https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz"

WORK_QT=$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}

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

cd qtbase

./configure -v \
    -opensource \
    -confirm-license \
    --disable-rpath \
    -xplatform neos \
    -prefix "$DIR/usr" \
    -docdir "$DIR/usr/share/doc/qt" \
    -headerdir "$DIR/usr/include/qt" \
    -archdatadir "$DIR/usr/lib/qt" \
    -datadir "$DIR/usr/share/qt" \
    -sysconfdir "$DIR/usr/etc/qt" \
    -examplesdir "$DIR/usr/share/doc/qt/examples" \
    -plugindir "$DIR/usr/libexec/qt" \
    -no-warnings-are-errors \
    -nomake examples \
    -nomake tests

make
make install

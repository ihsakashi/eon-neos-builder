#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

QT_PACKAGE_VERSION=5.13.0
QT_PACKAGE_URL="https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz"

echo "Building QT for NEOS"

pushd $ROOT/mindroid/system
    source build/envsetup.sh
    breakfast oneplus3
popd

cd $ROOT/mindroid
if [[ ! -d "$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz" ]]; then
    wget --tries=inf $QT_PACKAGE_URL
    tar xvf qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz
fi

WORK_QT=$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}

cp -rf $DIR/qtbase/mkspecs/neos ${WORK_QT}/qtbase/mkspecs/

cd ${WORK_QT}/qtbase

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
    -nomake tests \

qmake
make
make install

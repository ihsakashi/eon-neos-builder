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
    -release \
    -xplatform neos \
    -optimized-qmake \
    -no-rpath \
    -no-use-gold-linker \
    -prefix "$DIR/usr" \
    -docdir "$DIR/usr/share/doc/qt" \
    -headerdir "$DIR/usr/include/qt" \
    -archdatadir "$DIR/usr/lib/qt" \
    -datadir "$DIR/usr/share/qt" \
    -sysconfdir "$DIR/usr/etc/qt" \
    -examplesdir "$DIR/usr/share/doc/qt/examples" \
    -plugindir "$DIR/usr/libexec/qt" \
    -nomake examples \
    -skip qt3d \
    -skip qtactiveqt \
    -skip qtandroidextras \
    -skip qtcanvas3d \
    -skip qtcharts \
    -skip qtconnectivity \
    -skip qtdatavis3d \
    -skip qtdeclarative \
    -skip qtdoc \
    -skip qtgamepad \
    -skip qtgraphicaleffects \
    -skip qtimageformats \
    -skip qtlocation \
    -skip qtmacextras \
    -skip qtmultimedia \
    -skip qtnetworkauth \
    -skip qtpurchasing \
    -skip qtquickcontrols \
    -skip qtquickcontrols2 \
    -skip qtremoteobjects \
    -skip qtscript \
    -skip qtscxml \
    -skip qtsensors \
    -skip qtserialbus \
    -skip qtserialport \
    -skip qtspeech \
    -skip qtsvg \
    -skip qttools \
    -skip qttranslations \
    -skip qtvirtualkeyboard \
    -skip qtwayland \
    -skip qtwebchannel \
    -skip qtwebengine \
    -skip qtwebglplugin \
    -skip qtwebsockets \
    -skip qtwebview \
    -skip qtwinextras \
    -skip qtx11extras \
    -skip qtxmlpatterns \
    -no-dbus \
    -no-accessibility \
    -no-glib \
    -no-eventfd \
    -no-inotify \
    -icu \
    -system-pcre \
    -system-zlib \
    -ssl \
    -openssl-linked \
    -no-system-proxies \
    -no-cups \
    -system-harfbuzz \
    -no-gbm \
    -no-kms \
    -no-linuxfb \
    -no-mirclient \
    -system-xcb \
    -no-libudev \
    -no-evdev \
    -no-libinput \
    -no-mtdev \
    -no-tslib \
    -gif \
    -ico \
    -system-libpng \
    -system-libjpeg \
    -sql-sqlite \
    -no-feature-dnslookup

qmake
make
make install

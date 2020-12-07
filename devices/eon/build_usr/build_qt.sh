#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

QT_PACKAGE_VERSION=5.11.3
QT_PACKAGE_URL="https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz"

export WORK_QT=$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}
SYSROOT=$DIR/out/data/data/com.termux/files
#OUT_DIR=$ROOT/mindroid/mnt/comma/usr

cd $ROOT/mindroid

if [[ ! -d "${SYSROOT}" ]]; then
    echo "Termux out dir not populated."
    exit 0
fi

if [[ ! -d "${WORK_QT}" ]]; then
    wget -nc --tries=inf $QT_PACKAGE_URL
    tar xf qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz

    pushd ${WORK_QT}
    patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qdnslookup_unix.cpp.patch
    patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qhostinfo_unix.cpp.patch
    patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtbase_src_gui_configure.json.patch
    patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtbase_src_plugins_platforms_eglfs_deviceintegration_deviceintegration.pro.patch
    popd

    cp -rf $DIR/qt/qtbase/* ${WORK_QT}/qtbase/
fi

echo "Building QT for NEOS"

#(cd $ROOT/mindroid/system && source build/envsetup.sh && breakfast oneplus3)

cd ${WORK_QT}/qtbase

# openssl library too old

./configure -v \
    -opensource \
    -confirm-license \
    -release \
    --disable-rpath \
    -xplatform neos-cross \
    -sysroot "${SYSROOT}" \
    -no-gcc-sysroot \
    -hostprefix "${DIR}/qt/tools" \
    -no-warnings-are-errors \
    -opengl es2 \
    -eglfs \
    -system-pcre \
    -system-zlib \
    -no-openssl \
    -no-system-proxies \
    -no-cups \
    -system-harfbuzz \
    -system-libpng \
    -system-libjpeg \
    -nomake examples \
    -nomake tests \
    -recheck-all

make -j$(nproc)
make install

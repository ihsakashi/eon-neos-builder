#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

QT_PACKAGE_VERSION=5.13.0
QT_PACKAGE_URL="https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz"
QT_PREBUILT_QMAKE="https://github.com/termux/x11-packages/raw/master/packages/qt5-base/termux-prebuilt-qmake.txz"

WORK_QT=$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}
SYSROOT=$DIR/out/data/data/com.termux/files

NDK_ROOT=/usr/lib/android-sdk/ndk/20.1.5948944
QT_TARGET=${SYSROOT}/usr/local/Qt-${QT_PACKAGE_VERSION}

cd $ROOT/mindroid

if [[ ! -d "${SYSROOT}" ]]; then
    echo "Termux out dir not populated."
    exit 0
fi

if [[ ! -f "${NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-pkg-config" ]]; then
    cat <<EOF >> /usr/lib/android-sdk/ndk/20.1.5948944/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-pkg-config
#!/bin/sh
SYSROOT=@QT_SYSROOT@
export PKG_CONFIG_PATH=
export PKG_CONFIG_LIBDIR=\${SYSROOT}/data/data/com.termux/files/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=\${SYSROOT}
exec /usr/bin/pkg-config \$@
EOF
    chmod +x ${NDK_ROOT}/$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-pkg-config
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

    sed -i "s|@NDK_ROOT@|${NDK_ROOT}|g" "${WORK_QT}/qtbase/mkspecs/neos-cross/qmake.conf"
fi

echo "Building QT for NEOS"

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
    -no-warnings-are-errors \
    -eglfs \
    -qt-pcre \
    -qt-zlib \
    -no-openssl \
    -no-system-proxies \
    -no-cups \
    -qt-harfbuzz \
    -qt-libpng \
    -qt-libjpeg \
    -nomake examples \
    -nomake tests

make -j$(nproc)
make install

# host tools
mkdir -p bin.host lib.host
cp -a bin bin.host
cp -a lib/{libQt5Bootstrap.a,libQt5Bootstrap.prl} lib.host

rm -rf ${QT_TARGET}/bin
rm -rf ${QT_TARGET}/lib/{libQt5Bootstrap.a,libQt5Bootstrap.prl}

pushd ${WORK_QT}/qtbase/src/tools/bootstrap
make clean
${WORK_QT}/qtbase/bin/qmake -spec ${WORK_QT}/qtbase/mkspecs/neos-cross
make -j$(nproc)
install -Dm644 ${WORK_QT}/qtbase/lib/libQt5Bootstrap.a "${QT_TARGET}/lib/libQt5Bootstrap.a"
install -Dm644 ${WORK_QT}/qtbase/lib/libQt5Bootstrap.prl "${QT_TARGET}/lib/libQt5Bootstrap.prl"
popd

pushd $ROOT/mindroid
    if [[ $DIR/mindroid/termux-prebuilt-qmake ]]; then
        wget -nc --tries=inf ${QT_PREBUILT_QMAKE}
        tar xf termux-prebuilt-qmake.txz
    fi
    install -Dm700 termux-prebuilt-qmake/bin/termux-aarch64-linux-android-qmake "${QT_TARGET}/bin/qmake"
popd

for i in moc qlalr qvkgen rcc uic; do
    pushd ${WORK_QT}/qtbase/src/tools/$i
    make clean
    ${WORK_QT}/qtbase/bin/qmake -spec ${WORK_QT}/qtbase/mkspecs/neos-cross
    sed -i "s@-lpthread@@g" Makefile
    make -j$(nproc)
    install -Dm700 "../../../bin/${i}" "${QT_TARGET}/bin/${i}"
    popd
done
unset i

cp -rf bin.host/* bin
cp -rf lib.host/* lib

# fixed and clean up
find "${QT_TARGET}/lib" -type f -name '*.prl' -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' "{}" \;

find "${QT_TARGET}/lib" -iname \*.la -delete

sed -i 's|//mkspecs/neos-cross"|mkspecs/neos|g' "${QT_TARGET}/lib/cmake/Qt5Core/Qt5CoreConfigExtrasMkspecDir.cmake"

# todo: elf cleaner
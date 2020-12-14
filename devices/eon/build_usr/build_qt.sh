#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/..

QT_PACKAGE_VERSION=5.13.0
QT_PACKAGE_URL="https://ftp.osuosl.org/pub/blfs/conglomeration/qt5/qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz"
QT_PREBUILT_QMAKE="https://github.com/termux/x11-packages/raw/master/packages/qt5-base/termux-prebuilt-qmake.txz"

WORK_QT=$ROOT/mindroid/qt-everywhere-src-${QT_PACKAGE_VERSION}
SYSROOT=$DIR/out/data/data/com.termux/files

NDK_ROOT=/usr/lib/android-sdk/ndk/20.1.5948944
QT_TARGET=${SYSROOT}/usr

cd $ROOT/mindroid

if [[ ! -d "${SYSROOT}" ]]; then
    echo "Termux sysroot not populated."
    exit 0
fi

rm -rf ${WORK_QT}

wget -nc --tries=inf $QT_PACKAGE_URL
tar xf qt-everywhere-src-${QT_PACKAGE_VERSION}.tar.xz

pushd ${WORK_QT}
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qdnslookup_unix.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.11.2_qtbase_src_network_kernel_qhostinfo_unix.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtbase_src_gui_configure.json.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtbase_src_plugins_platforms_eglfs_deviceintegration_deviceintegration.pro.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtmultimedia_src_plugins_opensles_qopenslesaudioinput.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtmultimedia_src_plugins_opensles_qopenslesengine.cpp.patch
patch -p1 < $DIR/qt/patches/qt-everywhere-src-5.13.0_qtmultimedia_src_plugins_plugins.pro.patch
popd

cp -rf $DIR/qt/qtbase/* ${WORK_QT}/qtbase/

sed -i "s|@NDK_ROOT@|${NDK_ROOT}|g" "${WORK_QT}/qtbase/mkspecs/neos-cross/qmake.conf"

echo "Building QT for NEOS"

cd ${WORK_QT}

# openssl library too old

export PKG_CONFIG_PATH=
export PKG_CONFIG_LIBDIR=${SYSROOT}/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=$DIR/out

./configure -v \
    -opensource \
    -confirm-license \
    -release \
    --disable-rpath \
    -xplatform neos-cross \
    -sysroot "${SYSROOT}" \
    -prefix "/usr" \
    -docdir "/usr/share/doc/qt" \
    -headerdir "/usr/include/qt" \
    -archdatadir "/usr/lib/qt" \
    -datadir "/usr/share/qt" \
    -sysconfdir "/usr/etc/xdg" \
    -examplesdir "/usr/share/doc/qt/examples" \
    -plugindir "/usr/libexec/qt" \
    -no-gcc-sysroot \
    -force-pkg-config \
    -no-warnings-are-errors \
    -qt-pcre \
    -qt-zlib \
    -no-openssl \
    -no-system-proxies \
    -no-cups \
    -qt-harfbuzz \
    -qt-libpng \
    -qt-libjpeg \
    -no-vulkan \
    -no-glib \
    -nomake examples \
    -nomake tests \
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
    -skip qtxmlpatterns

make -j$(nproc)
make install

echo "Building QT tools for target"

# host tools
cd ${WORK_QT}/qtbase

mkdir -p bin.host lib.host
cp -a bin/* bin.host
cp -a lib/{libQt5Bootstrap.a,libQt5Bootstrap.prl} lib.host

find "bin" -mindepth 1 -exec echo rm -rf "${QT_TARGET}/{}" \;
rm -rf ${QT_TARGET}/lib/{libQt5Bootstrap.a libQt5Bootstrap.prl}

pushd ${WORK_QT}/qtbase/src/tools/bootstrap
make clean
${WORK_QT}/qtbase/bin/qmake -spec ${WORK_QT}/qtbase/mkspecs/neos-cross
make -j$(nproc)
install -Dm644 ${WORK_QT}/qtbase/lib/libQt5Bootstrap.a "${QT_TARGET}/lib/libQt5Bootstrap.a"
install -Dm644 ${WORK_QT}/qtbase/lib/libQt5Bootstrap.prl "${QT_TARGET}/lib/libQt5Bootstrap.prl"
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
cp -rf lib.host/{libQt5Bootstrap.a,libQt5Bootstrap.prl} lib

#(
#    cd $DIR/qt
#    tar cf - patches/ qtbase/ | xz -z - > $ROOT/home/qt-changes.tar.xz
#)

# fixed and clean up
echo "Patching QT install"

find "${QT_TARGET}/lib" -type f -name '*.prl' -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' "{}" \; -exec sed -i -e "s|${NDK_ROOT}\/toolchains\/llvm\/prebuilt\/linux-x86_64\/sysroot\/usr\/lib\/aarch64-linux-android\/21|/system\/lib64|g" "{}" \;

find "${QT_TARGET}/lib" -type f -name '*.pc' -exec sed -i -e "s|$DIR\/out||g" "{}" \; -exec sed -i -e "s|${NDK_ROOT}\/toolchains\/llvm\/prebuilt\/linux-x86_64\/sysroot\/usr\/lib\/aarch64-linux-android\/21|/system\/lib64|g" "{}" \;

find "${QT_TARGET}/lib/qt/mkspecs" -type f -name '*.pri' -exec sed -i -e "s|${NDK_ROOT}\/toolchains\/llvm\/prebuilt\/linux-x86_64\/sysroot\/usr\/lib\/aarch64-linux-android\/21|/system\/lib64|g" "{}" \;

find "${QT_TARGET}/lib" -type f -name '*.cmake' -exec sed -i -e "s|${NDK_ROOT}\/toolchains\/llvm\/prebuilt\/linux-x86_64\/sysroot\/usr\/lib\/aarch64-linux-android\/21|/system\/lib64|g" "{}" \;

find "${QT_TARGET}/lib" -iname \*.la -delete

sed -i 's|//mkspecs/neos-cross"|/mkspecs/neos|g' "${QT_TARGET}/lib/cmake/Qt5Core/Qt5CoreConfigExtrasMkspecDir.cmake"

sed -i "s|PKG_CONFIG_SYSROOT_DIR = $DIR\/out|PKG_CONFIG_SYSROOT_DIR = \/data\/data\/com.termux\/files\/usr|g" "${QT_TARGET}/lib/qt/mkspecs/qconfig.pri"
sed -i "s|$DIR\/out||g" "${QT_TARGET}/lib/qt/mkspecs/qconfig.pri"

echo "Done. Run install.sh"
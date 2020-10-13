host_build {
    QT_ARCH = x86_64
    QT_BUILDABI = x86_64-little_endian-lp64
    QT_TARGET_ARCH = arm64
    QT_TARGET_BUILDABI = arm64-little_endian-lp64
} else {
    QT_ARCH = arm64
    QT_BUILDABI = arm64-little_endian-lp64
}
QT.global.enabled_features = cross_compile shared c++11 c++14 c++1z c99 c11 thread future concurrent
QT.global.disabled_features = framework rpath appstore-compliant debug_and_release simulator_and_device build_all c++2a pkg-config force_asserts separate_debug_info static
CONFIG += cross_compile shared release
QT_CONFIG += shared release c++11 c++14 c++1z concurrent dbus no-pkg-config stl
QT_VERSION = 5.13.0
QT_MAJOR_VERSION = 5
QT_MINOR_VERSION = 13
QT_PATCH_VERSION = 0
QT_GCC_MAJOR_VERSION = 4
QT_GCC_MINOR_VERSION = 2
QT_GCC_PATCH_VERSION = 1
QT_CLANG_MAJOR_VERSION = 9
QT_CLANG_MINOR_VERSION = 0
QT_CLANG_PATCH_VERSION = 8
QT_EDITION = OpenSource

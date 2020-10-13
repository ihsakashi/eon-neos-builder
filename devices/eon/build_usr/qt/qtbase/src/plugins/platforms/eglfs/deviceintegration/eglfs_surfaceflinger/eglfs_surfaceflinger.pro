TARGET = qeglfs-surfaceflinger-integration

QT += core-private gui-private eglfsdeviceintegration-private

DEFINES += QT_EGL_NO_X11

INCLUDEPATH += $$PWD/../../api \
               $${ANDROID_BUILD_TOP}/frameworks/native/include \
                $${ANDROID_BUILD_TOP}/hardware/libhardware/include \
                $${ANDROID_BUILD_TOP}/system/core/include

CONFIG += egl

SOURCES += $$PWD/qeglfs_sf_main.cpp \
           $$PWD/qeglfs_sf_integration.cpp

HEADERS += $$PWD/qeglfs_sf_integration.h

LIBS += $${ANDROID_PRODUCT_OUT}/obj/lib/libui.so $${ANDROID_PRODUCT_OUT}/obj/lib/libgui.so $${ANDROID_PRODUCT_OUT}/obj/lib/libutils.so $${ANDROID_PRODUCT_OUT}/obj/lib/libcutils.so -lEGL

OTHER_FILES += $$PWD/eglfs_surfaceflinger.json

PLUGIN_TYPE = egldeviceintegrations
PLUGIN_CLASS_NAME = QEglFSSurfaceFlingerIntegrationPlugin
load(qt_plugin)
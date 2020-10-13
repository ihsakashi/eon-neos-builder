TARGET = qeglfs-surfaceflinger-integration

QT += core-private gui-private eglfsdeviceintegration-private

DEFINES += QT_EGL_NO_X11

INCLUDEPATH += $$PWD/../../api
CONFIG += egl

SOURCES += $$PWD/qeglfs_sf_main.cpp \
           $$PWD/qeglfs_sf_integration.cpp

HEADERS += $$PWD/qeglfs_sf_integration.h \
           $${ANDROID_BUILD_TOP}/frameworks/native/include \
           $${ANDROID_BUILD_TOP}/hardware/libhardware/include \
           $${ANDROID_BUILD_TOP}/system/core/include

LIBS += -lui -lgui -lutils -lcutils

OTHER_FILES += $$PWD/eglfs_surfaceflinger.json

PLUGIN_TYPE = egldeviceintegrations
PLUGIN_CLASS_NAME = QEglFSSurfaceFlingerIntegrationPlugin
load(qt_plugin)
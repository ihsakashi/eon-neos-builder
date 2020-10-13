#ifndef QEGLFSSURFACEFLINGERINTEGRATION_H
#define QEGLFSSURFACEFLINGERINTEGRATION_H

#include "private/qeglfsdeviceintegration_p.h"

#include <ui/DisplayInfo.h>

#include <gui/ISurfaceComposer.h>
#include <gui/Surface.h>
#include <gui/SurfaceComposerClient.h>

QT_BEGIN_NAMESPACE

class QEglFSSurfaceFlingerIntegration : public QEglFSDeviceIntegration
{
public:
    void platformInit() override;
    QSize screenSize() const override;
    EGLNativeWindowType createNativeWindow(QPlatformWindow *window, const QSize &size, const QSurfaceFormat &format) override;
    void destroyNativeWindow(EGLNativeWindowType window) override;

private:
    QSize size;

    android::sp<android::SurfaceComposerClient> session;
    android::sp<android::IBinder> dtoken;
    android::DisplayInfo dinfo;
    android::sp<android::SurfaceControl> control;
    android::sp<android::Surface> surface;
};

QT_END_NAMESPACE

#endif
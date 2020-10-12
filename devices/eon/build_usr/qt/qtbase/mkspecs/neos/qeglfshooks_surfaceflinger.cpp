#include "qeglfshooks.h"

#include <fcntl.h>
#include <unistd.h>
#include <linux/fb.h>
#include <sys/ioctl.h>

#include <ui/DisplayInfo.h>

#include <gui/ISurfaceComposer.h>
#include <gui/Surface.h>
#include <gui/SurfaceComposerClient.h>

using namespace android;

QT_BEGIN_NAMESPACE

class QEglFSPandaHooks : public QEglFSHooks
{
public:
    QEglFSPandaHooks();
    virtual EGLNativeWindowType createNativeWindow(QPlatformWindow *window, const QSize &size, const QSurfaceFormat &format);

private:
    EGLNativeWindowType createNativeWindowSurfaceFlinger(const QSize &size, const QSurfaceFormat &format);
    //EGLNativeWindowType createNativeWindowFramebuffer(const QSize &size, const QSurfaceFormat &format); DEPRECATED
    // TODO ^

    // androidy things
    sp<android::SurfaceComposerClient> mSession;
    sp<android::SurfaceControl> mControl;
    sp<android::Surface> mAndroidSurface;
};

EGLNativeWindowType QEglFSPandaHooks::createNativeWindow(QPlatformWindow *window, const QSize &size, const QSurfaceFormat &format)
{
    Q_UNUSED(window)
    createNativeWindowSurfaceFlinger(size, format);
}

EGLNativeWindowType QEglFSPandaHooks::createNativeWindowSurfaceFlinger(const QSize &size, const QSurfaceFormat &)
{
    Q_UNUSED(size);

    mSession = new SurfaceComposerClient();
    DisplayToken dtoken;
    DisplayInfo dinfo;
    int status=0;
    status = mSession->getBuiltInDisplay(ISurfaceComposer::eDisplayIdMain);
    status = mSession->getDisplayInfo(dtoken, &dinfo);
    int orientation = 1;
    if (orientation == 1 || orientation == 3) {
        int temp = dinfo.h;
        dinfo.h = dinfo.w;
        dinfo.w= temp;
    }
    Rect destRect(dinfo.w, dinfo.h);
    mSession->setDisplayProjection(dtoken, orientation, destRect, destRect);
    mControl = mSession->createSurface(
            String8("QTNativeWindow"), dinfo.w, dinfo.h, PIXEL_FORMAT_RGB_888);
    SurfaceComposerClient::openGlobalTransaction();
    mControl->setLayer(0x40000000);
//    mControl->setAlpha(1);
    SurfaceComposerClient::closeGlobalTransaction();
    mAndroidSurface = mControl->getSurface();

    EGLNativeWindowType eglWindow = mAndroidSurface.get();
    return eglWindow;
}

static QEglFSPandaHooks eglFSPandaHooks;
QEglFSHooks *platformHooks = &eglFSPandaHooks;

QT_END_NAMESPACE
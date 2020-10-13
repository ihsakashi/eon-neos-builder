#include "qeglfs_sf_integration.h"

#include <cstdio>
#include <cstdlib>
#include <cassert>

#include <ui/DisplayInfo.h>

#include <gui/ISurfaceComposer.h>
#include <gui/Surface.h>
#include <gui/SurfaceComposerClient.h>

QT_BEGIN_NAMESPACE

using namespace android;

void QEglFSSurfaceFlingerIntegration::platformInit() {
    status_t ret;

    session = new SurfaceComposerClient;
    assert(session != NULL);

    dtoken = SurfaceComposerClient::getBuiltInDisplay(
                ISurfaceComposer::eDisplayIdMain);
    assert(dtoken != NULL);

    ret = SurfaceComposerClient::getDisplayInfo(dtoken, &dinfo);
    assert(ret == 0);

    msize.setWidth(dtoken.w);
    msize.setHeight(dtoken.h);

    control = session->createSurface(String8("qeglfs-surface"),
                dinfo.w, dinfo.h, PIXEL_FORMAT_RGBX_8888);
    assert(control != NULL);

    SurfaceComposerClient::openGlobalTransaction();
    ret = control->setLayer(0x40000000);
    SurfaceComposerClient::closeGlobalTransaction(true);
    assert(ret == 0);
}

QSize QEglFSSurfaceFlingerIntegration::screenSize() {
    return msize;
}

EGLNativeWindowType QEglFSSurfaceFlingerIntegration::createNativeWindow(QPlatformWindow *window, const QSize &size, const QSurfaceFormat &format) {
    Q_UNUSED(window);
    Q_UNUSED(format);
    Q_UNUSED(size);

    surface = control->getSurface();
    assert(surface != NULL);

    return (EGLNativeWindowType)surface.get();
}

void QEglFSSurfaceFlingerIntegration::destroyNativeWindow(EGLNativeWindowType window)
{
    free((void*)window);
}

QT_END_NAMESPACE
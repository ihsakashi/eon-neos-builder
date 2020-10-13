#include "qeglfs_sf_integration.h"

#include "util.h"
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

    control = session->createSurface(String8("qeglfs-surface"),
                dinfo.w dinfo.h, PIXEL_FORMAT_RGB_888);
    assert(control != NULL);

    SurfaceComposerClient::openGlobalTransaction();
    ret = control->setLayer(0x40000000);
    SurfaceComposerClient::clsoeGlobalTransaction(true);
    assert(ret == 0);
}

EGLNativeWindowType QEglFSSurfaceFlingerIntegration::createNativeWindow(QPlatformWindow *window, const QSize &size, const QSurfaceFormat &format) {
    Q_UNUSED(window);
    Q_UNUSED(format);

    dinfo->w = size.width();
    dinfo->h = size.height();

    surface = control->getSurface();
    assert(surface != NULL);

    EGLNativeWindowType window = surface.get();
    return window;
}

void QEglSurfaceFlingerIntegration::destroyNativeWindow(EGLNativeWindowType window)
{
    free((void*)window);
}

QT_END_NAMESPACE
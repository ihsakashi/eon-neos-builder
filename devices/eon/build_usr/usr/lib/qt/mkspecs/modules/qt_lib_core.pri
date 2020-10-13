QT.core.VERSION = 5.13.0
QT.core.name = QtCore
QT.core.module = Qt5Core
QT.core.libs = $$QT_MODULE_LIB_BASE
QT.core.includes = $$QT_MODULE_INCLUDE_BASE $$QT_MODULE_INCLUDE_BASE/QtCore
QT.core.frameworks =
QT.core.bins = $$QT_MODULE_BIN_BASE
QT.core.depends =
QT.core.uses = libatomic
QT.core.module_config = v2
QT.core.CONFIG = moc resources
QT.core.DEFINES = QT_CORE_LIB
QT.core.enabled_features = properties animation textcodec big_codecs codecs commandlineparser itemmodel proxymodel concatenatetablesproxymodel textdate datestring filesystemiterator filesystemwatcher gestures identityproxymodel library mimetype processenvironment process statemachine qeventtransition regularexpression settings sortfilterproxymodel std-atomic64 stringlistmodel temporaryfile timezone topleveldomain translation transposeproxymodel xmlstream xmlstreamreader xmlstreamwriter
QT.core.disabled_features = cxx11_future sharedmemory systemsemaphore
QT_CONFIG += properties animation textcodec big_codecs clock-monotonic codecs itemmodel proxymodel concatenatetablesproxymodel textdate datestring doubleconversion eventfd filesystemiterator filesystemwatcher gestures identityproxymodel inotify library mimetype process statemachine regularexpression settings sortfilterproxymodel stringlistmodel temporaryfile threadsafe-cloexec translation transposeproxymodel xmlstream xmlstreamreader xmlstreamwriter
QT_MODULES += core

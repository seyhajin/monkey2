
Namespace monkey

#Import "native/bbtypes.cpp"
#Import "native/bbassert.cpp"
#Import "native/bbstring.cpp"
#Import "native/bbfunction.cpp"
#Import "native/bbarray.cpp"
#Import "native/bbmonkey.cpp"
#Import "native/bbobject.cpp"
#Import "native/bbdebug.cpp"
#Import "native/bbweakref.cpp"
#Import "native/bbvariant.cpp"
#Import "native/bbtypeinfo.cpp"
#Import "native/bbdeclinfo.cpp"
#Import "native/bbmonkey_c.c"

'#If __THREADS__
'#Import "native/bbgc_mx.cpp"
'#else
#Import "native/bbgc.cpp"
'#endif

#If __TARGET__="macos" Or __TARGET__="ios"
#Import "native/bbstring.mm"
#Endif

#if __TARGET__="android"
#Import "native/Monkey2Lang.java"
#import "<liblog.a>"
#endif

#Import "types"
#Import "math"
#Import "debug"
#Import "gc"


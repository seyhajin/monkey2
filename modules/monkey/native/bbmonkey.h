
#ifndef BB_MONKEY_H
#define BB_MONKEY_H

#include "bbstd.h"
#include "bbtypes.h"
#include "bbassert.h"
#include "bbstring.h"
#include "bbdebug.h"
#include "bbarray.h"
#include "bbfunction.h"
#include "bbobject.h"
#include "bbweakref.h"
#include "bbvariant.h"
#include "bbtypeinfo_t.h"
#include "bbdeclinfo.h"

#ifdef BB_THREADS
#include "bbgc_mx.h"
#else
#include "bbgc.h"
#endif

extern int bb_argc;

extern char **bb_argv;

extern void bb_print( bbString str );

extern void bb_printf( const char *fmt,...);

#endif

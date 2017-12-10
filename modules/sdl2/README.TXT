Upgrading SDL source:

* include/config_*.h need to be copied/merged from current mx2 version - this is where SDL features are enabled.

* include/begin_code.h should #define DECLSPEC to empty at top to be able to statically link without msvc generating .lib and .exp files due to dllimport/dllexport symbols. Seems to be no #define SDL_STATIC_BUILD here?


#ifndef BB_OBJECT_HANDLE_H
#define BB_OBJECT_HANDLE_H

#include <bbmonkey.h>

inline void *bb_object_to_handle( bbObject *object ){ return object; }

inline bbObject *bb_handle_to_object( void *handle ){ return static_cast<bbObject*>( handle ); }

#endif

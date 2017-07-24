

// ===============================================================================
// May be included multiple times - sets structure packing to 1 
// for all supported compilers. #include <poppack1.h> reverts the changes.
//
// Currently this works on the following compilers:
// MSVC 7,8,9
// GCC
// BORLAND (complains about 'pack state changed but not reverted', but works)
// Clang
//
//
// USAGE:
//
// struct StructToBePacked {
// } PACK_STRUCT;
//
// ===============================================================================

#ifdef AI_PUSHPACK_IS_DEFINED
#	error poppack1.h must be included after pushpack1.h
#endif

#ifdef _MSC_VER
#	pragma pack(push,1)
#	define PACK_STRUCT
#else
#	pragma pack(1)
#	define PACK_STRUCT
#endif

#if defined(_MSC_VER)
// C4103: Packing was changed after the inclusion of the header, probably missing #pragma pop
#	pragma warning (disable : 4103) 
#endif

#define AI_PUSHPACK_IS_DEFINED

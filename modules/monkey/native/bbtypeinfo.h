
#ifndef BB_TYPEINFO_H
#define BB_TYPEINFO_H

#include "bbassert.h"
#include "bbobject.h"
#include "bbarray.h"
#include "bbfunction.h"

//struct bbClassTypeInfo;

struct bbTypeInfo{

	bbString name;
	bbString kind;
	
	bbString getName(){
		return name;
	}
	
	bbString getKind(){
		return kind;
	}
	
	virtual bbString toString();

	virtual bbTypeInfo *pointeeType();
	
	virtual bbTypeInfo *elementType();
	
	virtual int arrayRank();
	
	virtual bbTypeInfo *returnType();
	
	virtual bbArray<bbTypeInfo*> paramTypes();
	
	virtual bbTypeInfo *superType();
	
	virtual bbArray<bbTypeInfo*> interfaceTypes();
	
	virtual bbBool extendsType( bbTypeInfo *type );
	
	virtual bbArray<bbDeclInfo*> getDecls();
	
	virtual bbVariant makeEnum( int value );
	
	virtual int getEnum( bbVariant );
	
	virtual bbVariant nullValue();
	
	
	bbDeclInfo *getDecl( bbString name );
	
	bbDeclInfo *getDecl( bbString name,bbTypeInfo *type );
	
	bbArray<bbDeclInfo*> getDecls( bbString name );
	
	static bbTypeInfo *getType( bbString cname );
	
	static bbArray<bbTypeInfo*> getTypes();
};

#define BB_GETTYPE_DECL( TYPE ) bbTypeInfo *bbGetType( TYPE const& );

BB_GETTYPE_DECL( bbBool )
BB_GETTYPE_DECL( bbByte )
BB_GETTYPE_DECL( bbUByte )
BB_GETTYPE_DECL( bbShort )
BB_GETTYPE_DECL( bbUShort )
BB_GETTYPE_DECL( bbInt )
BB_GETTYPE_DECL( bbUInt )
BB_GETTYPE_DECL( bbLong )
BB_GETTYPE_DECL( bbULong )
BB_GETTYPE_DECL( bbFloat )
BB_GETTYPE_DECL( bbDouble )
BB_GETTYPE_DECL( bbString )
BB_GETTYPE_DECL( bbCString )
BB_GETTYPE_DECL( bbVariant )

template<class T> bbTypeInfo *bbGetType( T* const& );

template<class T> bbTypeInfo *bbGetType(){

	return bbGetType( *(T*)0 );
}

struct bbUnknownTypeInfo : public bbTypeInfo{
	
	bbUnknownTypeInfo( const char *name );
};

struct bbVoidTypeInfo : public bbTypeInfo{

	static bbVoidTypeInfo instance;

	bbVoidTypeInfo();
};

struct bbObjectTypeInfo : public bbTypeInfo{

	static bbObjectTypeInfo instance;

	bbObjectTypeInfo();
	
	bbTypeInfo *superType();
	
	bbBool extendsType( bbTypeInfo *type );
	
	bbArray<bbDeclInfo*> getDecls();
};

#endif

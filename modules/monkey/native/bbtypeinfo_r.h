
#ifndef BB_TYPEINFO_R_H
#define BB_TYPEINFO_R_H

#include "bbtypeinfo.h"

struct bbClassTypeInfo;

struct bbClassDecls{

	bbClassDecls *_succ;
	bbDeclInfo **_decls=0;
	int _numDecls=0;

	bbClassDecls( bbClassTypeInfo *classType );
	
	bbDeclInfo **decls();
	
	int numDecls();
	
	virtual bbDeclInfo **initDecls(){
		return 0;
	}
};

struct bbClassTypeInfo : public bbTypeInfo{

	bbClassTypeInfo *_succ=0;
	bbClassDecls *_decls=0;
	
	bbClassTypeInfo( bbString name,bbString kind );
	
	bbTypeInfo *superType();
	
	bbArray<bbTypeInfo*> interfaceTypes();
	
	bbBool extendsType( bbTypeInfo *type );
	
	bbArray<bbDeclInfo*> getDecls();
	
	bbString toString(){
		return kind+" "+name;
	}
	
	static bbClassTypeInfo *getNamespace( bbString name );
};

struct bbEnumTypeInfo : public bbClassTypeInfo{
	
	bbEnumTypeInfo( bbString name ):bbClassTypeInfo( name,"Enum" ){
	}
};

#endif



#include "filesystem.h"

#include <UIKit/UIKit.h>

bbString bbFileSystem::getSpecialDir( bbString name ){

	NSString *dir=0;

	if( name=="internal" ){
	
		dir=[@"~/Documents" stringByExpandingTildeInPath];
		
	}else if( name=="external" ){	//?
	
	}

	return bbString( dir )+"/";
}
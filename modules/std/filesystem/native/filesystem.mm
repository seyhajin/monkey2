
#include "filesystem.h"

#include <UIKit/UIKit.h>

bbString bbFileSystem::getSpecialDir( bbString name ){

	NSString *dir=0;

	if( name=="assets" ){
		
		dir=[[NSBundle mainBundle] resourcePath];
		
		dir=[dir stringByAppendingString:@"/assets"];
		
	}else if( name=="internal" ){
	
		dir=NSHomeDirectory();
	
//		dir=[@"~/Documents" stringByExpandingTildeInPath];
		
	}else if( name=="external" ){	//?
	
	}

	return bbString( dir )+"/";
}
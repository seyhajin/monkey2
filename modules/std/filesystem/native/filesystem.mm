
#include "filesystem.h"

#include <UIKit/UIKit.h>

bbString bbFileSystem::getInternalDir(){

	NSString *docs=[@"~/Documents" stringByExpandingTildeInPath];

	return bbString( docs )+"/";
}

#include "filesystem.h"

#include <UIKit/UIKit.h>

bbString bbFileSystem::getInteralDir(){

	NSString *docs=[@"~/Documents" stringByExpandingTildeInPath];

	return bbString( docs )+"/";
}
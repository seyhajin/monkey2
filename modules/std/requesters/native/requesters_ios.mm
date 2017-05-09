
#include "requesters_ios.h"

#import <UIKit/UIKit.h>

void bbRequesters::openUrl( bbString url ){

	NSURL *nsurl=[NSURL URLWithString:url.ToNSString()];
	
	if( nsurl ) [[UIApplication sharedApplication] openURL:nsurl];
}


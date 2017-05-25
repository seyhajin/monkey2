
#include "requesters.h"

#import <UIKit/UIKit.h>

void bbRequesters::OpenUrl( bbString url ){

	NSURL *nsurl=[NSURL URLWithString:url.ToNSString()];
	
	if( nsurl ) [[UIApplication sharedApplication] openURL:nsurl];
}


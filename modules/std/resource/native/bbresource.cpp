
#include "bbresource.h"

bbResource::bbResource(){

	flags|=1;
}

void bbResource::gcFinalize(){

	if( !(flags&1) ) return;
	
	onFinalize();
}

void bbResource::discard(){

	if( !(flags&1) ) return;
	
	flags&=~1;
	
	onDiscard();
}

void bbResource::onDiscard(){
}

void bbResource::onFinalize(){
}

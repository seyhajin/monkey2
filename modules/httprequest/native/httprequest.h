
#ifndef BB_HTTPREQUEST_H
#define BB_HTTPREQUEST_H

#include <bbmonkey.h>

#if __APPLE__

struct bbHttpRequest : public bbObject{

	struct Rep;	//NS stuff...
		
	Rep *_rep;
	
	int readyState=0;
	bbString response;
	int status=-1;
	
	bbFunction<void()> readyStateChanged;
	
	bbHttpRequest();
	~bbHttpRequest();
	
	void open( bbString req,bbString url );
	void setHeader( bbString name,bbString value );
	void send( bbString text,float timeout );
	void cancel();
	
	void setReadyState( int state );
	
	void gcMark();
};
	
#else

#include <jni.h>

namespace bbHttpRequest{

	extern bbFunction<void( jobject,bbInt )> onReadyStateChanged;
	
	extern bbFunction<void( jobject,bbString,bbInt,bbInt )> onResponseReceived;

}

#endif

#endif

#include <bbmonkey.h>

#if __APPLE__

enum class bbReadyState{
	Unsent=0,
	Done=4,
	Error=5
};

struct bbHttpRequest : public bbObject{

	struct Rep;	//NS stuff...
		
	Rep *_rep;
	
	bbString _response;
	int _readyState=0;
	int _status=-1;
	int _recv=-1;
	
	bbFunction<void()> readyStateChanged;
	
	bbHttpRequest();
	
	bbHttpRequest( bbString req,bbString url,bbFunction<void()> readyStateChanged );
	
	bbReadyState readyState();
	bbString responseText();
	int status();
	
	void open( bbString req,bbString url );
	void setHeader( bbString name,bbString value );
	void send();
	void send( bbString text );

	void gcMark();
};
	
#else

#include <jni.h>

namespace bbHttpRequest{

	extern bbFunction<void( jobject,bbInt )> onReadyStateChanged;
	
	extern bbFunction<void( jobject,bbString,bbInt,bbInt )> onResponseReceived;

}

#endif
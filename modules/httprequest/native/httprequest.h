
#include <bbmonkey.h>

#include <jni.h>

namespace bbHttpRequest{

	extern bbFunction<void( jobject,bbInt )> onReadyStateChanged;
	
	extern bbFunction<void( jobject,bbString,bbInt,bbInt )> onResponseReceived;

}

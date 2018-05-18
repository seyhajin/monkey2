
#include <std/filesystem/native/filesystem.h>

namespace bbMusic{

	int playMusic( FILE *file,int callback,int source );
	
	int getBuffersProcessed( int source );
	
	void endMusic( int source );
	
}

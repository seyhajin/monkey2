
#ifndef BB_FILESYSTEM_H
#define BB_FILESYSTEM_H

#include <bbmonkey.h>
#include <bbplatform.h>

namespace bbFileSystem{

	bbString appDir();
	
	bbString appPath();
	
	bbArray<bbString> appArgs();
	
	bbBool copyFile( bbString srcPath,bbString dstPath );
	
#if BB_IOS
	
	bbString getInternalDir();
	
#endif

}

#endif

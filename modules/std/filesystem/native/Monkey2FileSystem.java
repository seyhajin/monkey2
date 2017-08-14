package com.monkey2.lib;

import android.util.Log;

public class Monkey2FileSystem{

    private static final String TAG = "Monkey2FileSystem";
    
    static public String getIntenalDir(){
    
		//Log.v( TAG,"getInternalDir()" );
    
	    java.io.File f=Monkey2Activity.instance().getFilesDir();

		if( f!=null ) return f.getAbsolutePath()+"/";
	    
	    return "";
    }
    
    static public String getExternalDir(){
    
		//Log.v( TAG,"getExternalDir()" );
    
	    java.io.File f=android.os.Environment.getExternalStorageDirectory();
	    
		if( f!=null ) return f.getAbsolutePath()+"/";
		
		return "";
	}
}
	
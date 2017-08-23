package com.monkey2.lib;

import android.util.Log;

public class Monkey2FileSystem{

    private static final String TAG = "Monkey2FileSystem";
    
    public static String getInternalDir(){
    
		//Log.v( TAG,"getInternalDir()" );
    
	    java.io.File f=Monkey2Activity.instance().getFilesDir();

		if( f!=null ) return f.getAbsolutePath()+"/";
	    
	    return "";
    }
    
    public static String getExternalDir(){
    
		//Log.v( TAG,"getExternalDir()" );
    
	    java.io.File f=android.os.Environment.getExternalStorageDirectory();
	    
		if( f!=null ) return f.getAbsolutePath()+"/";
		
		return "";
	}
}
	
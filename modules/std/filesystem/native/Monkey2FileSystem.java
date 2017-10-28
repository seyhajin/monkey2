package com.monkey2.lib;

import android.util.Log;

public class Monkey2FileSystem{

    private static final String TAG = "Monkey2FileSystem";
    
    public static String getSpecialDir( String name ){
    
		//Log.v( TAG,"getSpecialDir, name="+name );
		
		java.io.File f=null;
		
		if( name.equals( "internal" ) ){
	    	f=Monkey2Activity.instance().getFilesDir();
	    }else if( name.equals( "external" ) ){
	    	f=Monkey2Activity.instance().getExternalFilesDir( null );
	    }

		if( f!=null ) return f.getAbsolutePath()+"/";
	    
	    return "";
    }
}
	
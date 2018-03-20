package com.monkey2.lib;

import android.util.Log;

public class Monkey2Lang{

    private static final String TAG="Monkey2Lang";
    
    public static String toUpper( String str ){
	    return str.toUpperCase();
    }
    
    public static String toLower( String str ){
	    return str.toLowerCase();
    }
    
    public static String capitalize( String str ){
		return str.length()!=0 ? str.substring( 0,1 ).toUpperCase()+str.substring( 1 ) : "";
    }
}
	
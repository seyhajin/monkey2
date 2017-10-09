
package com.monkey2.lib;

import android.util.Log;
import android.support.v4.content.ContextCompat;
import android.support.v4.app.ActivityCompat;
import android.Manifest;
import android.content.pm.PackageManager;

public class Monkey2Permissions extends Monkey2Activity.Delegate{

    private static final String TAG = "Monkey2Permissions";
    
	String result="";
	int callback;
	
	Monkey2Permissions(){
	
		Monkey2Activity.instance().addDelegate( this );
	}

 	public int checkPermission( String permission ){
 	
		if( ContextCompat.checkSelfPermission( Monkey2Activity.instance(),permission )==PackageManager.PERMISSION_GRANTED ) return 1;

 		return 0;
    }
    
    public void requestPermissions( String permissions,int callback ){
    
    	this.callback=callback;
    	
    	ActivityCompat.requestPermissions( Monkey2Activity.instance(),permissions.split( ";" ),101 );
    }
    
    public String requestPermissionsResult(){
    
	    return result;
    }
    
	public void onRequestPermissionsResult( int requestCode,String[] permissions,int[] results ){
	
		switch( requestCode ){
		case 101:
			result="";
			for( int i=0;i<results.length;++i ){
				if( i>0 ) result+=";";
				this.result+=(results[i]==PackageManager.PERMISSION_GRANTED ? "1" : "0" );
			}
			Monkey2Async.invokeAsyncCallback( callback );
		}
	}
}

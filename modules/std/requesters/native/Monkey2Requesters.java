package com.monkey2.lib;

import android.util.Log;
import android.content.Intent;
import android.net.Uri;

public class Monkey2Requesters {

    private static final String TAG = "Monkey2Requesters";
    
    static public void openUrl( String url ) {
    
		//Log.v( TAG,"openUrl, url="+url );
    
        Intent browserIntent=new Intent( Intent.ACTION_VIEW,Uri.parse( url ) );
        
		Monkey2Activity.instance().startActivity( browserIntent );
    }
    
}

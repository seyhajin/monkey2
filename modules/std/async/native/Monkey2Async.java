
package com.monkey2.lib;

import android.util.Log;

public class Monkey2Async{

    private static final String TAG = "Monkey2Async";
    
    public static native void invokeAsyncCallback( int callback );
}

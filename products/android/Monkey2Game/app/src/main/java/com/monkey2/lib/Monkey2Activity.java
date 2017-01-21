package com.monkey2.lib;

import android.os.Bundle;
import android.os.Looper;
import android.util.Log;
import android.view.ViewGroup;

import org.libsdl.app.SDLActivity;

public class Monkey2Activity extends SDLActivity {
    private static final String TAG = "Monkey2Activity";

    public static Monkey2Activity mSingleton;

    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        mSingleton = this;
    }

    protected void onDestroy() {

        super.onDestroy();
    }

    static public Monkey2Activity instance(){

        return mSingleton;
    }

    static public boolean isMainThread() {

        return Looper.getMainLooper().equals(Looper.myLooper());
    }

    static public void runOnMainThread(Runnable r) {

        mSingleton.runOnUiThread(r);
    }

    static public ViewGroup layout() {

        return mSingleton.mLayout;
    }

}

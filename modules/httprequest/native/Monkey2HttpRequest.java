
package com.monkey2.lib;

import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class Monkey2HttpRequest{

	private static final String TAG = "Monkey2HttpRequest";

	HttpURLConnection connection;
	
	int readyState;
	
	boolean busy;

    native void onNativeReadyStateChanged( int state );
    
    native void onNativeResponseReceived( String response,int status,int state );
    
    void setReadyState( int state ){
    
    	if( state==readyState ) return;
    	
    	onNativeReadyStateChanged( state );
    	
    	readyState=state;
    }
	
	void open( String req,String url ){
	
		if( readyState!=0 ) return;
		
		try{
		
			URL turl=new URL( url );
			connection=(HttpURLConnection)turl.openConnection();
			connection.setRequestMethod( req );
			
			setReadyState( 1 );
			
		}catch( IOException ex ){
		
			setReadyState( 5 );
		}		
	}
	
	void setHeader( String name,String value ){
	
		if( readyState!=1 || busy ) return;
	
		connection.setRequestProperty( name,value );
	}
	
	void send( final String text ){
	
		if( readyState!=1 || busy ) return;
		
		busy=true;
		
		new Thread( new Runnable() {

			public void run() {

				try {
				
					if( text!=null && text.length()!=0 ){
			
						byte[] bytes=text.getBytes( "UTF-8" );

						connection.setDoOutput( true );
						connection.setFixedLengthStreamingMode( bytes.length );
				
						OutputStream out=connection.getOutputStream();
						out.write( bytes,0,bytes.length );
						out.close();
					}
					
					InputStream in=connection.getInputStream();
					
					setReadyState( 3 );

					byte[] buf = new byte[4096];
					ByteArrayOutputStream out=new ByteArrayOutputStream(1024);
					for (; ; ) {
						int n = in.read(buf);
						if (n < 0) break;
						out.write(buf, 0, n);
					}
					in.close();

					String response=new String( out.toByteArray(),"UTF-8" );

					int status=connection.getResponseCode();
					
					onNativeResponseReceived( response,status,4 );
					
					readyState=4;
					
				} catch ( IOException ex) {
				
					setReadyState( 5 );
				}
				
				busy=false;
			}
			
		} ).start();
	}
}

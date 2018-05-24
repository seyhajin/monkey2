
#include "httprequest.h"

#include "../../std/async/native/async.h"

struct bbHttpRequest::Rep{
	NSMutableURLRequest *_req;
	NSString *_response;
	int _status;	
};

namespace{

	struct ReadyStateChangedEvent : public bbAsync::Event{

		bbHttpRequest *req;
		int state;

		ReadyStateChangedEvent( bbHttpRequest *req ):req( req ),state( req->readyState ){
		}
		
		void dispatch(){
		
			if( state==req->readyState ){
		
				if( req->readyState==4 ){
					req->response=bbString( req->_rep->_response );
					req->status=req->_rep->_status;
				}
			
				req->readyStateChanged();
			}
			
			bbGC::release( req );
			
			delete this;
		}
	};

}

bbHttpRequest::bbHttpRequest(){

	_rep=new Rep;
}

	
void bbHttpRequest::open( bbString req,bbString url ){
	
	if( readyState!=0 ) return;
	
	NSMutableURLRequest *nsreq=[[NSMutableURLRequest alloc] init];
		
	[nsreq setHTTPMethod:req.ToNSString()];
	
	[nsreq setURL:[NSURL URLWithString:url.ToNSString()]];
	
	if( [nsreq respondsToSelector:@selector(setAllowsCellularAccess:)] ){
		[nsreq setAllowsCellularAccess:YES];
	}
	
	_rep->_req=nsreq;
	
	setReadyState( 1 );
}
	
void bbHttpRequest::setHeader( bbString name,bbString value ){
	
	if( readyState!=1 ) return;
		
	[_rep->_req setValue:value.ToNSString() forHTTPHeaderField:name.ToNSString()];
}
	
void bbHttpRequest::send( bbString text,float timeout ){
	
	if( readyState!=1 ) return;
		
	bbGC::retain( this );
	
    std::thread( [=](){
    
    	_rep->_req.timeoutInterval=(NSTimeInterval)timeout;

		NSURLResponse *response=0;
			
		NSData *data=[NSURLConnection sendSynchronousRequest:_rep->_req returningResponse:&response error:0];
		
		if( data && response ){
			
		  	_rep->_response=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
		    _rep->_status=[(NSHTTPURLResponse*)response statusCode];
		}

		readyState=4;
		
		ReadyStateChangedEvent *ev=new ReadyStateChangedEvent( this );
		
		ev->post();
			
	} ).detach();

	setReadyState( 3 );
}

void bbHttpRequest::setReadyState( int state ){

	readyState=state;
	
	readyStateChanged();
}

void bbHttpRequest::gcMark(){

	bbGCMark( readyStateChanged ); 
}


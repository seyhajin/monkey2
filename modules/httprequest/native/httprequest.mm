
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

		ReadyStateChangedEvent( bbHttpRequest *req,int state ):req( req ),state( state ){
		}
		
		void dispatch(){
		
			if( state==req->_readyState ){
		
				if( req->_readyState==4 ){
					req->_response=bbString( req->_rep->_response );
					req->_status=req->_rep->_status;
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

bbHttpRequest::bbHttpRequest( bbString req,bbString url,bbFunction<void()> readyStateChanged ):bbHttpRequest(){

	this->readyStateChanged=readyStateChanged;

	open( req,url );
}
	
bbReadyState bbHttpRequest::readyState(){
	
	return (bbReadyState)_readyState;
}
	
bbString bbHttpRequest::responseText(){

	return _response;
}
	
int bbHttpRequest::status(){
	
	return _status;
}
	
void bbHttpRequest::open( bbString req,bbString url ){
	
	if( _readyState!=0 ) return;
	
	NSMutableURLRequest *nsreq=[[NSMutableURLRequest alloc] init];
		
	[nsreq setHTTPMethod:req.ToNSString()];
	
	[nsreq setURL:[NSURL URLWithString:url.ToNSString()]];
	
	if( [nsreq respondsToSelector:@selector(setAllowsCellularAccess:)] ){
		[nsreq setAllowsCellularAccess:YES];
	}
	
	_rep->_req=nsreq;
		
	_readyState=1;
}
	
void bbHttpRequest::setHeader( bbString name,bbString value ){
	
	if( _readyState!=1 ) return;
		
	[_rep->_req setValue:value.ToNSString() forHTTPHeaderField:name.ToNSString()];
}
	
void bbHttpRequest::send(){
	
	send( "" );
}
	
void bbHttpRequest::send( bbString text ){
	
	if( _readyState!=1 ) return;
		
	bbGC::retain( this );

	_readyState=3;	//loading
	
    std::thread( [=](){

		NSURLResponse *response=0;
			
		NSData *data=[NSURLConnection sendSynchronousRequest:_rep->_req returningResponse:&response error:0];
		
		if( data && response ){
			
		  	_rep->_response=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
		    _rep->_status=[(NSHTTPURLResponse*)response statusCode];
			    
		    //_recv=[data length];
		}
		
		_readyState=4;	//loaded
		
		ReadyStateChangedEvent *ev=new ReadyStateChangedEvent( this,_readyState );
		
		ev->post();
			
	} ).detach();
}

void bbHttpRequest::gcMark(){

	bbGCMark( readyStateChanged ); 
}


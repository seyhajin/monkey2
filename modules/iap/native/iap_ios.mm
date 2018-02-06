
// ***** appstore.h *****

#include "iap_ios.h"

@implementation BBIAPStoreDelegate

-(id)initWithPeer:(BBIAPStore*)peer{

	if( self=[super init] ){
	
		_peer=peer;
	}
	return self;
}

-(void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response{

	_peer->OnRequestProductDataResponse( request,response );
}

-(void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions{

	_peer->OnUpdatedTransactions( queue,transactions );
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue{

	_peer->OnRestoreTransactionsFinished( queue,0 );
}

-(void)paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error{

	_peer->OnRestoreTransactionsFinished( queue,error );
}

-(void)request:(SKRequest*)request didFailWithError:(NSError*)error{

	_peer->OnRequestFailed( request,error );
}

@end

BBProduct::BBProduct():product(0),valid(false),type(0),owned(false),interrupted(false){
}

BBProduct::~BBProduct(){

//	[product release];
}

// ***** IAPStore *****

BBIAPStore::BBIAPStore():_running( false ),_products( 0 ),_result( -1 ){

	_delegate=[[BBIAPStoreDelegate alloc] initWithPeer:this];
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:_delegate];
	
	_priceFormatter=[[NSNumberFormatter alloc] init];
	
	[_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

bool BBIAPStore::OpenStoreAsync( bbArray<bbGCVar<BBProduct>> products ){

	if( _running || _products.length() ) return false;

	if( ![SKPaymentQueue canMakePayments] ) return false;
	
	_products=products;
	
	id __strong *objs=new id[products.length()];

	for( int i=0;i<products.length();++i ){
		objs[i]=products[i]->identifier.ToNSString();
	}
	
	NSSet *set=[NSSet setWithObjects:objs count:products.length()];
	
	SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers:set];
	
    request.delegate=_delegate;
    
    _running=true;

	_result=-1;

    [request start];
    
    return true;
}

bool BBIAPStore::BuyProductAsync( BBProduct *prod ){

	if( _running || !_products.length() || !prod || !prod->valid ) return false; 

	if( ![SKPaymentQueue canMakePayments] ) return false;
	
	SKMutablePayment *payment=[SKMutablePayment paymentWithProduct:prod->product];
	
	_running=true;

	_result=-1;
	
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	
	return true;
}

bool BBIAPStore::GetOwnedProductsAsync(){

	if( _running || !_products.length() ) return false;

	if( ![SKPaymentQueue canMakePayments] ) return false;
	
	_running=true;
	
	_result=-1;
	
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	
	return true;
}

bool BBIAPStore::IsRunning(){

	return _running;
}

int BBIAPStore::GetResult(){

	return _result;
}

BBProduct *BBIAPStore::FindProduct( bbString id ){

	for( int i=0;i<_products.length();++i ){
	
		BBProduct *p=_products[i];
		
		if( p->identifier==id ) return p;
	}

	return 0;
}

void BBIAPStore::OnRequestProductDataResponse( SKProductsRequest *request,SKProductsResponse *response ){

	//Get product details
	for( SKProduct *p in response.products ){
	
		printf( "product=%p\n",p );fflush( stdout );
	
		BBProduct *prod=FindProduct( p.productIdentifier );
		if( !prod ) continue;
		
		[_priceFormatter setLocale:p.priceLocale];
		
		prod->valid=true;
		prod->product=p;	//[p retain];
		prod->title=bbString( p.localizedTitle );
		prod->identifier=bbString( p.productIdentifier );
		prod->description=bbString( p.localizedDescription );
		prod->price=bbString( [_priceFormatter stringFromNumber:p.price] );
	}
	
	_result=-1;
	
	for( int i=0;i<_products.length();++i ){
	
		if( !_products[i]->product ) continue;
		
		_result=0;
		break;
	}
	
	_running=false;
}

void BBIAPStore::OnUpdatedTransactions( SKPaymentQueue *queue,NSArray *transactions ){

	_result=-1;

	for( SKPaymentTransaction *transaction in transactions ){
	
		if( transaction.transactionState==SKPaymentTransactionStatePurchased ){
		
			_result=0;
			
			_running=false;
			
		}else if( transaction.transactionState==SKPaymentTransactionStateFailed ){
		
			_result=(transaction.error.code==SKErrorPaymentCancelled) ? 1 : -1;
			
			_running=false;
			
		}else if( transaction.transactionState==SKPaymentTransactionStateRestored ){
		
			if( BBProduct *p=FindProduct( transaction.payment.productIdentifier ) ) p->owned=true;
		
		}else{
		
			continue;
		}
		
		[queue finishTransaction:transaction];
	}
}

void BBIAPStore::OnRestoreTransactionsFinished( SKPaymentQueue *queue,NSError *error ){

	_result=error ? (error.code==SKErrorPaymentCancelled ? 1 : -1) : 0;
	
	_running=false;
}

void BBIAPStore::OnRequestFailed( SKRequest *request,NSError *error ){

	_running=false;
}

void BBIAPStore::gcMark(){

	bbGCMark( _products );
}

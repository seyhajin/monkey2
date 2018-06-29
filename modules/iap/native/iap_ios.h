
#ifndef BB_IAP_IOS_H
#define BB_IAP_IOS_H

#import <bbmonkey.h>

#ifdef __OBJC__

#import <StoreKit/StoreKit.h>

class BBIAPStore;
	
@interface BBIAPStoreDelegate : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>{
@private
BBIAPStore *_peer;
}
-(id)initWithPeer:(BBIAPStore*)peer;
-(void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response;
-(void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions;
-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue;
-(void)paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error;
-(void)request:(SKRequest*)request didFailWithError:(NSError*)error;

@end

#else

#include <objc/objc.h>

typedef struct objc_object SKProduct;
typedef struct objc_object SKProductsRequest;
typedef struct objc_object SKProductsResponse;
typedef struct objc_object SKPaymentQueue;
typedef struct objc_object NSArray;
typedef struct objc_object NSError;
typedef struct objc_object SKRequest;
typedef struct objc_object BBIAPStoreDelegate;
typedef struct objc_object NSNumberFormatter;

#endif

struct BBProduct : public bbObject{
	
	BBProduct();
	~BBProduct();
	
	SKProduct *product;

	bool valid;
	bbString title;
	bbString identifier;
	bbString description;
	bbString price;
	int type;
	bool owned;
	bool interrupted;
};

struct BBIAPStore : public bbObject{
	
	BBIAPStore();
	
	bool OpenStoreAsync( bbArray<bbGCVar<BBProduct>> products );
	bool BuyProductAsync( BBProduct* product );
	bool GetOwnedProductsAsync();
	void CloseStore();
	
	bool IsRunning();
	int GetResult();
	
	static bool CanMakePayments();
	
	BBProduct *FindProduct( bbString id );
	void OnRequestProductDataResponse( SKProductsRequest *request,SKProductsResponse *response );
	void OnUpdatedTransactions( SKPaymentQueue *queue,NSArray *transactions );
	void OnRestoreTransactionsFinished( SKPaymentQueue *queue,NSError *error );
	void OnRequestFailed( SKRequest *request,NSError *error );
	
	virtual void gcMark();
	
	BBIAPStoreDelegate *_delegate;

	NSNumberFormatter *_priceFormatter;

	bbArray<bbGCVar<BBProduct>> _products;

	bool _running;
	
	int _result;
};

#endif

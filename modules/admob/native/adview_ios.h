
#include <bbmonkey.h>

#include "../../std/async/native/async_cb.h"

#ifdef __OBJC__

#import "GoogleMobileAds/GADBannerView.h"
#import "GoogleMobileAds/GADInterstitial.h"
#import "GoogleMobileAds/GADRewardBasedVideoAd.h"
#import "GoogleMobileAds/GADRewardBasedVideoAdDelegate.h"
#import "GoogleMobileAds/GADAdReward.h"

@interface BBAdmobDelegate : NSObject<GADBannerViewDelegate,GADInterstitialDelegate,GADRewardBasedVideoAdDelegate>

@end

#else

#include <objc/objc.h>

typedef struct objc_object BBAdmobDelegate;
typedef struct objc_object GADRequest;
typedef struct objc_object GADInterstitial;
typedef struct objc_object GADBannerView;
typedef struct objc_object GADRewardBasedVideoAd;

#endif

class BBAdView : public bbObject{

	public:
	
	BBAdView(){}
	
	BBAdView( bbString size,bbString layout,bbString adUnitId,bbBool visible );
	
	void start( int callback );
	
	void setState( int state );
	
	void setVisible( bool visible );
	
	bool getVisible();
	
	int getState();
	
	bbString getRewardType();
	
	int getRewardAmount();
	
	void consumeReward();
	
	int getError();

	void reload();

	void createRewardBasedVideoAd();
	
	void createInterstitialAd();
	
	void createBannerAd();
	
//	private:

	bbString _size;
	
	bbString _layout;
	
	bbString _adUnitId;
	
	bbBool _visible;
	
	int _callback=0;
			
	int _state=0;
	
	BBAdmobDelegate *_adDelegate=0;

	GADRewardBasedVideoAd *_rewardBasedVideoAd=0;
	
	GADInterstitial *_interstitialAd=0;
	
	GADBannerView *_adView=0;

	GADRequest *_adRequest=0;
	
	bbString _rewardType="";
	
	int _rewardAmount=0;
	
	int _error=0;
};

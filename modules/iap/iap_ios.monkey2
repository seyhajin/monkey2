
Namespace iap

#Import "native/iap_ios.mm"

#Import "native/iap_ios.h"

Extern Internal

Class BBProduct="BBProduct"

	Field identifier:String
	Field type:Int
	Field valid:Bool
	Field title:String
	Field description:String
	Field price:String
	Field owned:Bool
End

Class BBIAPStore="BBIAPStore"
	
	Method BBOpenStoreAsync:Bool( products:BBProduct[] )="OpenStoreAsync"
	Method BBBuyProductAsync:Bool( product:BBProduct )="BuyProductAsync"
	Method GetOwnedProductsAsync:Bool()
	
	Method IsRunning:Bool()
	Method GetResult:Int()
End

public

Class Product Extends BBProduct
	
	Method New( identifier:String,type:Int )
		
		Self.identifier=identifier
		Self.type=type
	End

	Property Valid:Bool()
		
		Return valid
	End
		
	Property Title:String()

		Return title
	End
	
	Property Description:String()
		
		Return description
	End
	
	Property Price:String()
		
		Return price
	End
	
	Property Identifier:String()
		
		Return identifier
	End
	
	Property Type:Int()
		
		Return type
	End
	
	Internal
	
	Property Interrupted:Bool()
		
		Return False
	end
	
	Property Owned:Bool()
		
		Return owned
	End
	
End

Class IAPStoreRep Extends BBIAPStore

	Method OpenStoreAsync:Bool( products:Product[] )
		
		Local bbproducts:=New BBProduct[products.Length]
		
		For Local i:=0 Until bbproducts.Length
			bbproducts[i]=products[i]
		Next
		
		Return Super.BBOpenStoreAsync( bbproducts )
	End
	
	Method BuyProductAsync:Bool( product:Product )
		
		Return Super.BBBuyProductAsync( product )
	End
	
End

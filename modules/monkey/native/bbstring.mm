
#include "bbstring.h"

bbString::bbString( const NSString *str ):_rep( Rep::create( str ? str.UTF8String : "" ) ){
}

NSString *bbString::ToNSString()const{

	return [NSString stringWithUTF8String:c_str()];
}

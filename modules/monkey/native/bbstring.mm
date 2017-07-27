
#include "bbstring.h"

bbString::bbString( NSString *str ):_rep( Rep::create( str.UTF8String ) ){
}

NSString *bbString::ToNSString()const{
	return [NSString stringWithUTF8String:c_str()];
}

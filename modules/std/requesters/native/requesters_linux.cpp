
#include "requesters.h"

#include <limits.h>

bbString bbRequesters::RequestFile( bbString title,bbString exts,bbBool save,bbString path ){

	bbString cmd=BB_T("zenity --title=\"")+title+BB_T("\" --file-selection");
	
	if( save ) cmd+=" --save";
	
	FILE *f=popen( cmd.c_str(),"r" );
	if( !f ) return "";
	
	char buf[PATH_MAX];
	int n=fread( buf,1,PATH_MAX,f );
	pclose( f );
	
	if( n<0 || n>PATH_MAX ) return "";
	
	while( n && buf[n-1]<=32 ) --n;
	
	return bbString::fromCString( buf,n );
}

bbString bbRequesters::RequestDir( bbString title,bbString dir ){

	bbString cmd=BB_T("zenity --title=\"")+title+BB_T("\" --file-selection --directory");

	FILE *f=popen( cmd.c_str(),"r" );
	if( !f ) return "";
	
	char buf[PATH_MAX];
	int n=fread( buf,1,PATH_MAX,f );
	pclose( f );
	
	if( n<0 || n>PATH_MAX ) return "";
	
	while( n && buf[n-1]<=32 ) --n;
	
	return bbString::fromCString( buf,n );
}

void bbRequesters::OpenUrl( bbString url ){

	system( ( bbString( "xdg-open \"" )+url+"\"" ).c_str() );
}

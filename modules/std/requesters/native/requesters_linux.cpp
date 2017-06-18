
#include "requesters.h"

#include <limits.h>

/* Can't get gtk building...
 
#include <nfd.h>

bbString bbRequesters::RequestFile( bbString title,bbString exts,bbBool save,bbString path ){

	nfdchar_t *cstr=0;

	nfdresult_t result=NFD_OpenDialog( 0,0,&cstr );
	if( result!=NFD_OKAY ) return "";
	
	bbString str( cstr );
	
	free( cstr );
	
	return str;
}
*/

namespace{

	bbString pexec( bbString cmd ){
	
		FILE *f=popen( cmd.c_str(),"r" );
		if( !f ) return "";
		
		char buf[PATH_MAX];
		int n=fread( buf,1,PATH_MAX,f );
		pclose( f );
		
		if( n<0 || n>PATH_MAX ) return "";
		
		while( n && buf[n-1]<=32 ) --n;
		
		return bbString::fromCString( buf,n );
	}

}

void bbRequesters::Notify( bbString title,bbString text,bbBool serious ){

	bbString cmd=BB_T( "kdialog --title \"" )+title+"\"";
	if( serious ) cmd+=" --error"; else cmd+=" --msgbox";
	cmd+=BB_T( " \"" ) + text + "\"";
	
	system( cmd.c_str() );
}

bbBool bbRequesters::Confirm( bbString title,bbString text,bbBool serious ){

	bbString cmd=BB_T( "kdialog --title \"" )+title+"\" --yesno \""+text+"\"";
	
	int result=system( cmd.c_str() );
	
	return result==0;
}

bbInt bbRequesters::Proceed( bbString title,bbString text,bbBool serious ){

	bbString cmd=BB_T( "kdialog --title \"" )+title+"\" --yesnocancel \""+text+"\"";

	int result=system( cmd.c_str() );
	
	if( result==0 ) return 1;	//YES
	if( result==256 ) return 0;	//NO
	return -1;					//CANCEL
}

bbString bbRequesters::RequestFile( bbString title,bbString exts,bbBool save,bbString path ){

	if( path=="" ) path=".";

	// kdialog
	//
	bbString cmd=save ? "kdialog --getsavefilename" : "kdialog --getopenfilename";
	cmd+=BB_T( " \"" )+path+"\"";
	
	// zenity
	//
	// bbString cmd=BB_T("zenity --modal --display=:0 --title=\"")+title+BB_T("\" --file-selection");
	// if( save ) cmd+=" --save";
	
	return pexec( cmd );
}

bbString bbRequesters::RequestDir( bbString title,bbString dir ){

	if( dir=="" ) dir=".";

	bbString cmd="kdialog --getexistingdirectory \""+dir+"\"";

	// zenity
	//
	// bbString cmd=BB_T("zenity --modal --title=\"")+title+BB_T("\" --file-selection --directory");
	
	return pexec( cmd );
}

void bbRequesters::OpenUrl( bbString url ){

	system( ( bbString( "xdg-open \"" )+url+"\"" ).c_str() );
}

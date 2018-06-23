
#rem

This is just enough to create a window and get a simply message loop running. More to come once I get c2mx2 running again...

Notes:

WndProc function MUST be a plain static functions.

The LRESULT_WINAPI hack is for forcing functions to be 'stdcall'. Will probably add calling convention support later...

Haven't converted any types with same name as mx2 types, eg: BYTE, UBYTE etc.

Haven't converted any pointer types, eg: LPDWORD. Should I?

Data types source:

https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751

#end

Namespace win32

#If __TARGET__="windows"

#Import "<libc>"

#Import "<user32.lib>"

#import "<windows.h>"

Extern

Alias CHAR:UByte	'signedness?
Alias WCHAR:UShort	'signedness?
Alias WORD:UShort
Alias DWORD:UInt
Alias LONG_:Int

Alias LONG_PTR:Int	'long on 64 bit?
Alias UINT_PTR:UInt	'ulong on 64bit?

Alias LRESULT:LONG_PTR
Alias LPARAM:LONG_PTR
Alias WPARAM:UINT_PTR

Alias HANDLE:Void Ptr

Alias HWND:HANDLE
Alias HMENU:HANDLE
Alias HMODULE:HANDLE
Alias HINSTANCE:HANDLE
Alias HBITMAP:HANDLE
Alias HBRUSH:HANDLE
Alias HCURSOR:HANDLE
Alias HDC:HANDLE
Alias HICON:HANDLE

Alias LRESULT_WINAPI:LRESULT="LRESULT WINAPI"	'cheezy as hell!

Alias WNDPROC:LRESULT_WINAPI( hwnd:HWND,uMsg:UInt,wParam:WPARAM,lParam:LPARAM )

Alias ATOM:WORD

Struct WNDCLASSW
	Field style:UInt
	Field lpfnWndProc:WNDPROC
	Field cbClsExtra:Int
	Field cbWndExtra:Int
	Field hInstance:HINSTANCE
	Field hIcon:HICON
	Field hCursor:HCURSOR
	Field hbrBackground:HBRUSH
	Field lpszMenuName:WCHAR Ptr
	Field lpszClassName:WCHAR Ptr
End

Const MB_OK:UInt
Const MB_OKCANCEL:UInt
Const MB_RETRYCANCEL:UInt
Const MB_YESNO:UInt
Const MB_YESNOCANCEL:UInt

Const IDNO:Int
Const IDOK:Int
Const IDRETRY:Int
Const IDTRYAGAIN:Int
Const IDYES:Int

Const WS_OVERLAPPEDWINDOW:DWORD
Const WS_POPUPWINDOW:DWORD
Const WS_VISIBLE:DWORD

Struct POINT
	Field x:LONG_
	Field y:LONG_
End

Struct MSG
	Field hwnd:HWND
	Field message:UInt
	Field wParam:WPARAM
	Field lParam:LPARAM
	Field time:DWORD
	Field pt:POINT
End

Function MessageBoxW:Int( hWnd:HWND,lpText:WString,lpCaption:WString,uType:UInt )

Function RegisterClassW:ATOM( lpWndClass:WNDCLASSW Ptr )	
	
Function GetModuleHandleW:HMODULE( lpModuleName:WCHAR Ptr )
	
Function CreateWindowW:HWND( lpClassName:WString,lpWindowName:WString,dwStyle:DWORD,x:Int,y:Int,nWidth:Int,nHeight:Int,hWndParent:HWND,hMenu:HMENU,hInstance:HINSTANCE,lpParam:Void Ptr )

Function DefWindowProcW:LRESULT_WINAPI( hwnd:HWND,uMsg:UInt,wParam:WPARAM,lParam:LPARAM )
	
Function GetMessage:Int( lpMsg:MSG Ptr,hWnd:HWND,wMsgFilterMin:UInt,wMsgFilterMax:UInt )

Function TranslateMessage:Int( lpMsg:MSG Ptr )
	
Function DispatchMessage:LRESULT( lpMsg:MSG Ptr )
	
#End

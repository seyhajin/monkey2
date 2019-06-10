namespace ultralight

'Imports
#import "<libc>"

using libc..

'// Include dirs
#import "native/include/*.h"

'// Main include file
#import "<Ultralight/CAPI.h>"
'[TODO]: #import "<AppCore/CAPI.h>"

#if __TARGET__="windows"
	#if __CONFIG__="debug"
		#if __ARCH__="x86"
			#import "native/lib/windows/x86/debug/*.lib"

			#import "<Ultralight.lib>"
			#import "<UltralightCore.lib>"
			#import "<WebCore.lib>"
			#import "<AppCore.lib>"

			#import "./native/bin/windows/x64/debug/Ultralight.dll"
			#import "./native/bin/windows/x64/debug/UltralightCore.dll"
			#import "./native/bin/windows/x64/debug/WebCore.dll"
			#import "./native/bin/windows/x64/debug/AppCore.dll"

		#elseif __ARCH__="x64"
			#import "native/lib/windows/x64/debug/*.lib"

			#import "<Ultralight.lib>"
			#import "<UltralightCore.lib>"
			#import "<WebCore.lib>"
			#import "<AppCore.lib>"

			#import "./native/bin/windows/x64/debug/Ultralight.dll"
			#import "./native/bin/windows/x64/debug/UltralightCore.dll"
			#import "./native/bin/windows/x64/debug/WebCore.dll"
			#import "./native/bin/windows/x64/debug/AppCore.dll"
		#end

	#elseif __CONFIG__="release"
		#if __ARCH__="x86"
			#import "native/lib/windows/x86/release/*.lib"

			#import "<Ultralight.lib>"
			#import "<UltralightCore.lib>"
			#import "<WebCore.lib>"
			#import "<AppCore.lib>"

			#import "./native/bin/windows/x86/release/Ultralight.dll"
			#import "./native/bin/windows/x86/release/UltralightCore.dll"
			#import "./native/bin/windows/x86/release/WebCore.dll"
			#import "./native/bin/windows/x86/release/AppCore.dll"

		#elseif __ARCH__="x64"
			#import "native/lib/windows/x64/release/*.lib"

			#import "<Ultralight.lib>"
			#import "<UltralightCore.lib>"
			#import "<WebCore.lib>"
			#import "<AppCore.lib>"

			#import "./native/bin/windows/x64/release/Ultralight.dll"
			#import "./native/bin/windows/x64/release/UltralightCore.dll"
			#import "./native/bin/windows/x64/release/WebCore.dll"
			#import "./native/bin/windows/x64/release/AppCore.dll"
		#end
	#end

#elseif __TARGET__="linux" '// x64 only
	#if __CONFIG__="debug"
		#import "./native/bin/linux/x64/debug/libUltralight.so"
		#import "./native/bin/linux/x64/debug/libUltralightCore.so"
		#import "./native/bin/linux/x64/debug/libWebCore.so"
		#import "./native/bin/linux/x64/debug/libAppCore.so"

	#elseif __CONFIG__="release"
		#import "./native/bin/linux/x64/release/libUltralight.so"
		#import "./native/bin/linux/x64/release/libUltralightCore.so"
		#import "./native/bin/linux/x64/release/libWebCore.so"
		#import "./native/bin/linux/x64/release/libAppCore.so"
	#end

#elseIf __TARGET__="macos" '// x64 only
	#if __CONFIG__="debug"
		#import "./native/bin/windows/x64/debug/libUltralight.dylib"
		#import "./native/bin/windows/x64/debug/libUltralightCore.dylib"
		#import "./native/bin/windows/x64/debug/libWebCore.dylib"
		#import "./native/bin/windows/x64/debug/libAppCore.dylib"

	#elseif __CONFIG__="release"
		#import "./native/bin/windows/x64/release/libUltralight.dylib"
		#import "./native/bin/windows/x64/release/libUltralightCore.dylib"
		#import "./native/bin/windows/x64/release/libWebCore.dylib"
		#import "./native/bin/windows/x64/release/libAppCore.dylib"
	#end
#end


'//////////////////////////////////////////////////////////////
'//
'//
'//
'//////////////////////////////////////////////////////////////
Extern

Alias ULChar16:wchar_t

Struct ULConfig
End
Struct ULRenderer
End
Struct ULView
End
Struct ULBitmap
End
Struct ULString
End
Struct ULBuffer
End
Struct ULRenderTarget
End
Struct ULKeyEvent
End
Struct ULMouseEvent
End
Struct ULScrollEvent
End

Enum ULMessageSource
End
Const kMessageSource_XML:ULMessageSource
Const kMessageSource_JS:ULMessageSource
Const kMessageSource_Network:ULMessageSource
Const kMessageSource_ConsoleAPI:ULMessageSource
Const kMessageSource_Storage:ULMessageSource
Const kMessageSource_AppCache:ULMessageSource
Const kMessageSource_Rendering:ULMessageSource
const kMessageSource_CSS:ULMessageSource
const kMessageSource_Security:ULMessageSource
const kMessageSource_ContentBlocker:ULMessageSource
const kMessageSource_Other:ULMessageSource

Enum ULMessageLevel
End
Const kMessageLevel_Log:ULMessageLevel
Const kMessageLevel_Warning:ULMessageLevel
Const kMessageLevel_Error:ULMessageLevel
Const kMessageLevel_Debug:ULMessageLevel
Const kMessageLevel_Info:ULMessageLevel

Enum ULCursor
End
Const kCursor_Pointer:ULCursor
Const kCursor_Cross:ULCursor
Const kCursor_Hand:ULCursor
Const kCursor_IBeam:ULCursor
Const kCursor_Wait:ULCursor
Const kCursor_Help:ULCursor
Const kCursor_EastResize:ULCursor
Const kCursor_NorthResize:ULCursor
Const kCursor_NorthEastResize:ULCursor
Const kCursor_NorthWestResize:ULCursor
Const kCursor_SouthResize:ULCursor
Const kCursor_SouthEastResize:ULCursor
Const kCursor_SouthWestResize:ULCursor
Const kCursor_WestResize:ULCursor
Const kCursor_NorthSouthResize:ULCursor
Const kCursor_EastWestResize:ULCursor
Const kCursor_NorthEastSouthWestResize:ULCursor
Const kCursor_NorthWestSouthEastResize:ULCursor
Const kCursor_ColumnResize:ULCursor
Const kCursor_RowResize:ULCursor
Const kCursor_MiddlePanning:ULCursor
Const kCursor_EastPanning:ULCursor
Const kCursor_NorthPanning:ULCursor
Const kCursor_NorthEastPanning:ULCursor
Const kCursor_NorthWestPanning:ULCursor
Const kCursor_SouthPanning:ULCursor
Const kCursor_SouthEastPanning:ULCursor
Const kCursor_SouthWestPanning:ULCursor
Const kCursor_WestPanning:ULCursor
Const kCursor_Move:ULCursor
Const kCursor_VerticalText:ULCursor
Const kCursor_Cell:ULCursor
Const kCursor_ContextMenu:ULCursor
Const kCursor_Alias:ULCursor
Const kCursor_Progress:ULCursor
Const kCursor_NoDrop:ULCursor
Const kCursor_Copy:ULCursor
Const kCursor_None:ULCursor
Const kCursor_NotAllowed:ULCursor
Const kCursor_ZoomIn:ULCursor
Const kCursor_ZoomOut:ULCursor
Const kCursor_Grab:ULCursor
Const kCursor_Grabbing:ULCursor
Const kCursor_Custom:ULCursor

Enum ULBitmapFormat
End
Const kBitmapFormat_A8:ULBitmapFormat
Const kBitmapFormat_RGBA8:ULBitmapFormat

Enum ULKeyEventType
End
Const kKeyEventType_KeyDown:ULKeyEventType
Const kKeyEventType_KeyUp:ULKeyEventType
Const kKeyEventType_RawKeyDown:ULKeyEventType
Const kKeyEventType_Char:ULKeyEventType

Enum ULMouseEventType 
End
Const kMouseEventType_MouseMoved:ULMouseEventType
Const kMouseEventType_MouseDown:ULMouseEventType
Const kMouseEventType_MouseUp:ULMouseEventType

Enum ULMouseButton
End
Const kMouseButton_None:ULMouseButton
Const kMouseButton_Left:ULMouseButton
Const kMouseButton_Middle:ULMouseButton
Const kMouseButton_Right:ULMouseButton

Enum ULScrollEventType
End
Const kScrollEventType_ScrollByPixel:ULScrollEventType
Const kScrollEventType_ScrollByPage:ULScrollEventType

'******************************************************************************
'* API Note:
'*
'* You should only destroy objects that you explicitly create. Do not destroy
'* any objects returned from the API or callbacks unless otherwise noted.
'******************************************************************************


'******************************************************************************
'* Config
'******************************************************************************

#Rem monkeydoc Create config with default values (see <Ultralight/platform/Config.h>).
#End
Function ulCreateConfig:ULConfig()

#Rem monkeydoc Destroy config.
#End
Function ulDestroyConfig(config:ULConfig)

#Rem monkeydoc Set whether images should be enabled (Default = True)
#End
Function ulConfigSetEnableImages(config:ULConfig, enabled:Bool)

#Rem monkeydoc Set whether JavaScript should be eanbled (Default = True)
#End
Function ulConfigSetEnableJavaScript(config:ULConfig, enabled:Bool)

#Rem monkeydoc Set whether we should use BGRA byte order (instead of RGBA) for View bitmaps. (Default = False)
#End
Function ulConfigSetUseBGRAForOffscreenRendering(config:ULConfig, enabled:Bool)

#Rem monkeydoc Set the amount that the application DPI has been scaled, used for scaling device coordinates to pixels and oversampling raster shapes. (Default = 1.0)
#End
Function ulConfigSetDeviceScaleHint(config:ULConfig, value:Double)

#Rem monkeydoc Set default font-family to use (Default = Times New Roman)
#End
Function ulConfigSetFontFamilyStandard(config:ULConfig, font_name:ULString)

#Rem monkeydoc Set default font-family to use for fixed fonts, eg <pre> and <code>. (Default = Courier New)
#End
Function ulConfigSetFontFamilyFixed(config:ULConfig, font_name:ULString)

#Rem monkeydoc Set default font-family to use for serif fonts. (Default = Times New Roman)
#End
Function ulConfigSetFontFamilySerif(config:ULConfig, font_name:ULString)

#Rem monkeydoc Set default font-family to use for sans-serif fonts. (Default = Arial)
#End
Function ulConfigSetFontFamilySansSerif(config:ULConfig, font_name:ULString)

#Rem monkeydoc Set user agent string. (See <Ultralight/platform/Config.h> for the default)
#End
Function ulConfigSetUserAgent(config:ULConfig, agent_string:ULString)

#Rem monkeydoc Set user stylesheet (CSS). (Default = Empty)
#End
Function ulConfigSetUserStylesheet(config:ULConfig, css_string:ULString)

'******************************************************************************
'* Renderer
'******************************************************************************

#Rem monkeydoc Create renderer (create this only once per application lifetime).
#End
Function ulCreateRenderer:ULRenderer(config:ULConfig)

#Rem monkeydoc Destroy renderer.
#End
Function ulDestroyRenderer(renderer:ULRenderer)

#Rem monkeydoc Update timers and dispatch internal callbacks (JavaScript and network)
#End
Function ulUpdate(renderer:ULRenderer)

#Rem monkeydoc Render all active Views to their respective bitmaps.
#End
Function ulRender(renderer:ULRenderer)

'******************************************************************************
'* View
'******************************************************************************

#Rem monkeydoc Create a View with certain size (in device coordinates).
#End
Function ulCreateView:ULView(renderer:ULRenderer, width:UInt, height:UInt, transparent:Bool)

#Rem monkeydoc Destroy a View.
#End
Function ulDestroyView(view:ULView)

#Rem monkeydoc Get current URL.
	@note Don't destroy the returned string, it is owned by the View.
#End
Function ulViewGetURL:ULString(view:ULView)

#Rem monkeydoc Get current title.
	@note Don't destroy the returned string, it is owned by the View.
#End
Function ulViewGetTitle:ULString(view:ULView)

#Rem monkeydoc Check if main frame is loading.
#End
Function ulViewIsLoading:Bool(view:ULView)

#Rem monkeydoc Check if bitmap is dirty (has changed since last call to ulViewGetBitmap)
#End
Function ulViewIsBitmapDirty:Bool(view:ULView)

#Rem monkeydoc Get bitmap (will reset the dirty flag).
	@note Don't destroy the returned bitmap, it is owned by the View.
#End
Function ulViewGetBitmap:ULBitmap(view:ULView)

#Rem monkeydoc Load a raw string of html
#End
Function ulViewLoadHTML(view:ULView, html_string:ULString)

#Rem monkeydoc Load a URL into main frame
#End
Function ulViewLoadURL(view:ULView, url_string:ULString)

#Rem monkeydoc Resize view to a certain width and height (in device coordinates)
#End
Function ulViewResize(view:ULView, width:UInt, height:UInt)

#Rem monkeydoc Get the page's JSContext for use with JavaScriptCore API
#End
'Function ulViewGetJSContext:JSContextRef(view:ULView) '//TODO:

#Rem monkeydoc Evaluate a raw string of JavaScript and return result
#End
'Function ulViewEvaluateScript:JSValueRef(view:ULView, js_string:ULString) '//TODO:

#Rem monkeydoc Check if can navigate backwards in history
#End
Function ulViewCanGoBack:Bool(view:ULView)

#Rem monkeydoc Check if can navigate forwards in history
#End
Function ulViewCanGoForward:Bool(view:ULView)

#Rem monkeydoc Navigate backwards in history
#End
Function ulViewGoBack(view:ULView)

#Rem monkeydoc Navigate forwards in history
#End
Function ulViewGoForward(view:ULView)

#Rem monkeydoc Navigate to arbitrary offset in history
#End
Function ulViewGoToHistoryOffset(view:ULView, offset:Int)

#Rem monkeydoc Reload current page
#End
Function ulViewReload(view:ULView)

#Rem monkeydoc Stop all page loads
#End
Function ulViewStop(view:ULView)

#Rem monkeydoc Fire a keyboard event
#End
Function ulViewFireKeyEvent(view:ULView, key_event:ULKeyEvent)

#Rem monkeydoc Fire a mouse event
#End
Function ulViewFireMouseEvent(view:ULView, mouse_event:ULMouseEvent)

#Rem monkeydoc Fire a scroll event
#End
Function ulViewFireScrollEvent(view:ULView, scroll_event:ULScrollEvent)

'typedef void (*ULChangeTitleCallback) (user_data:Void Ptr, caller:ULView, title:ULString)
Alias ULChangeTitleCallback:Void(Void Ptr, ULView, ULString)

#Rem monkeydoc Set callback for when the page title changes
#End
Function ulViewSetChangeTitleCallback(view:ULView, callback:ULChangeTitleCallback, user_data:Void Ptr)

'typedef void (*ULChangeURLCallback) (void* user_data, ULView caller, ULString url)
Alias ULChangeURLCallback:Void(Void Ptr, ULView, ULString)

#Rem monkeydoc Set callback for when the page URL changes
#End
Function ulViewSetChangeURLCallback(view:ULView, callback:ULChangeURLCallback, user_data:Void Ptr)

'typedef void (*ULChangeTooltipCallback) (void* user_data, ULView caller, ULString tooltip)
Alias ULChangeTooltipCallback:Void(Void Ptr, ULView, ULString)

#Rem monkeydoc Set callback for when the tooltip changes (usually result of a mouse hover)
#End
Function ulViewSetChangeTooltipCallback:Void(view:ULView, callback:ULChangeTooltipCallback, user_data:Void Ptr)

'typedef void (*ULChangeCursorCallback) (void* user_data, ULView caller, ULCursor cursor)
Alias ULChangeCursorCallback:Void(Void Ptr, ULView, ULCursor)

#Rem monkeydoc Set callback for when the mouse cursor changes
#End
Function ulViewSetChangeCursorCallback(view:ULView, callback:ULChangeCursorCallback, user_data:Void Ptr)

'typedef void (*ULAddConsoleMessageCallback) (void* user_data, ULView caller, ULMessageSource source, ULMessageLevel level, ULString message, 
'												unsigned int line_number, unsigned int column_number, ULString source_id)
Alias ULAddConsoleMessageCallback:Void(Void Ptr, ULView, ULMessageSource, ULMessageLevel, ULString, UInt, UInt, ULString)

#Rem monkeydoc Set callback for when a message is added to the console (useful for JavaScript / network errors and debugging)
#End
Function ulViewSetAddConsoleMessageCallback(view:ULView, callback:ULAddConsoleMessageCallback, user_data:Void Ptr)

'typedef void (*ULBeginLoadingCallback) (void* user_data, ULView caller)
Alias ULBeginLoadingCallback:Void(Void Ptr, ULView)

#Rem monkeydoc Set callback for when the page begins loading new URL into main frame
#End
Function ulViewSetBeginLoadingCallback(view:ULView, callback:ULBeginLoadingCallback, user_data:Void Ptr)

'typedef void (*ULFinishLoadingCallback) (void* user_data, ULView caller)
Alias ULFinishLoadingCallback:Void(Void Ptr, ULView)

#Rem monkeydoc Set callback for when the page finishes loading URL into main frame
#End
Function ulViewSetFinishLoadingCallback(view:ULView, callback:ULFinishLoadingCallback, user_data:Void Ptr)

'typedef void (*ULUpdateHistoryCallback) (void* user_data, ULView caller)
Alias ULUpdateHistoryCallback:Void(Void Ptr, ULView)

#Rem monkeydoc Set callback for when the history (back/forward state) is modified
#End
Function ulViewSetUpdateHistoryCallback(view:ULView, callback:ULUpdateHistoryCallback, user_data:Void Ptr)

'typedef void (*ULDOMReadyCallback) (void* user_data, ULView caller)
Alias ULDOMReadyCallback:Void(Void Ptr, ULView)

#Rem monkeydoc Set callback for when all JavaScript has been parsed and the document is ready. This is the best time to make initial JavaScript calls to your page.
#End
Function ulViewSetDOMReadyCallback(view:ULView, callback:ULDOMReadyCallback, user_data:Void Ptr)

#Rem monkeydoc Set whether or not a view should be repainted during the next call to ulRender.
	@note  This flag is automatically set whenever the page content changes but you can set it directly in case you need to force a repaint.
#End
Function ulViewSetNeedsPaint(view:ULView, needs_paint:Bool)

#Rem monkeydoc Whether or not a view should be painted during the next call to ulRender.
#End
Function ulViewGetNeedsPaint:Bool(view:ULView)

'******************************************************************************
'* String
'******************************************************************************

#Rem monkeydoc Create string from null-terminated ASCII C-string
#End
Function ulCreateString:ULString(str:CString)

#Rem monkeydoc Create string from UTF-8 buffer
#End
Function ulCreateStringUTF8:ULString(str:CString, len:size_t)

#Rem monkeydoc Create string from UTF-16 buffer
#End
Function ulCreateStringUTF16:ULString(str:ULChar16 Ptr, len:size_t)

#Rem monkeydoc Destroy string (you should destroy any strings you explicitly Create).
#End
Function ulDestroyString(str:ULString)

#Rem monkeydoc Get internal UTF-16 buffer data.
#End
Function ulStringGetData:ULChar16 Ptr(str:ULString)

#Rem monkeydoc Get length in UTF-16 characters
#End
Function ulStringGetLength:size_t(str:ULString)

#Rem monkeydoc Whether this string is empty or not.
#End
Function ulStringIsEmpty:Bool(str:ULString)

'******************************************************************************
'* Bitmap
'******************************************************************************

#Rem monkeydoc Create empty bitmap.
#End
Function ulCreateEmptyBitmap:ULBitmap()

#Rem monkeydoc Create bitmap with certain dimensions and pixel format.
#End
Function ulCreateBitmap:ULBitmap(width:UInt, height:UInt, format:ULBitmapFormat)

#Rem monkeydoc Create bitmap from existing pixel buffer. @see Bitmap for help using this function.
#End
Function ulCreateBitmapFromPixels:ULBitmap(width:UInt, height:UInt, format:ULBitmapFormat, row_bytes:UInt, pixels:Void Ptr, size:size_t, should_copy:Bool)

#Rem monkeydoc Create bitmap from copy.
#End
Function ulCreateBitmapFromCopy:ULBitmap(existing_bitmap:ULBitmap)

#Rem monkeydoc Destroy a bitmap (you should only destroy Bitmaps you have explicitly created via one of the creation functions above.
#End
Function ulDestroyBitmap(bitmap:ULBitmap)

#Rem monkeydoc Get the width in pixels.
#End
Function ulBitmapGetWidth:UInt(bitmap:ULBitmap)

#Rem monkeydoc Get the height in pixels.
#End
Function ulBitmapGetHeight:UInt(bitmap:ULBitmap)

#Rem monkeydoc Get the pixel format.
#End
Function ulBitmapGetFormat:ULBitmapFormat(bitmap:ULBitmap)

#Rem monkeydoc Get the bytes per pixel.
#End
Function ulBitmapGetBpp:UInt(bitmap:ULBitmap)

#Rem monkeydoc Get the number of bytes per row.
#End
Function ulBitmapGetRowBytes:UInt(bitmap:ULBitmap)

#Rem monkeydoc Get the size in bytes of the underlying pixel buffer.
#End
Function ulBitmapGetSize:size_t(bitmap:ULBitmap)

#Rem monkeydoc Whether or not this bitmap owns its own pixel buffer.
#End
Function ulBitmapOwnsPixels:Bool(bitmap:ULBitmap)

#Rem monkeydoc Lock pixels for reading/writing, returns pointer to pixel buffer.
#End
Function ulBitmapLockPixels:Void Ptr(bitmap:ULBitmap)

#Rem monkeydoc Unlock pixels after locking.
#End
Function ulBitmapUnlockPixels(bitmap:ULBitmap)

#Rem monkeydoc Get raw pixel buffer-- you should only call this if Bitmap is already locked.
#End
Function ulBitmapRawPixels:Void Ptr(bitmap:ULBitmap)

#Rem monkeydoc Whether or not this bitmap is empty.
#End
Function ulBitmapIsEmpty:Bool(bitmap:ULBitmap)

#Rem monkeydoc Reset bitmap pixels to 0.
#End
Function ulBitmapErase(bitmap:ULBitmap)

#Rem monkeydoc Write bitmap to a PNG on disk.
#End
Function ulBitmapWritePNG:Bool(bitmap:ULBitmap, path:CString)

'******************************************************************************
'* Key Event
'******************************************************************************

#Rem monkeydoc Create a key event, @see KeyEvent for help with the following parameters.
#End
Function ulCreateKeyEvent:ULKeyEvent(type:ULKeyEventType, modifiers:UInt, virtual_key_code:Int, native_key_code:Int, text:ULString, unmodified_text:ULString, is_keypad:Bool, is_auto_repeat:Bool, is_system_key:Bool)

#If __TARGET__="windows"
#Rem monkeydoc Create a key event from native Windows event.
#End
Function ulCreateKeyEventWindows:ULKeyEvent(type:ULKeyEventType, wparam:uintptr_t, lparam:intptr_t, is_system_key:Bool)
#EndIf

#If __TARGET__="macos"
#Rem monkeydoc Create a key event from native macOS event.
#End
Function ulCreateKeyEventMacOS:ULKeyEvent(evt:NSEvent Ptr)
#Endif

#Rem monkeydoc Destroy a key event.
#End
Function ulDestroyKeyEvent(evt:ULKeyEvent)

'******************************************************************************
'* Mouse Event
'******************************************************************************

#Rem monkeydoc Create a mouse event, @see MouseEvent for help using this function.
#End
Function ulCreateMouseEvent:ULMouseEvent(type:ULMouseEventType, x:Int, y:Int, button:ULMouseButton)

#Rem monkeydoc Destroy a mouse event.
#End
Function ulDestroyMouseEvent(evt:ULMouseEvent)

'******************************************************************************
'* Scroll Event
'******************************************************************************

#Rem monkeydoc Create a scroll event, @see ScrollEvent for help using this function.
#End
Function ulCreateScrollEvent:ULScrollEvent(type:ULScrollEventType, delta_x:Int, delta_y:Int)

#Rem monkeydoc Destroy a scroll event.
#End
Function ulDestroyScrollEvent(evt:ULScrollEvent)
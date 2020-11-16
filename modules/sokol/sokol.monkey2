namespace sokol

#import "<libc>"

using libc..

#if __HOSTOS__="windows"

#import "<libgdi32.a>"

#elseif __HOSTOS__="macos"

#import "MX2_CC_OPTS_MACOS=-fobjc-arc"
#import "MX2_CPP_OPTS_MACOS=-fobjc-arc"

#import "<CoreFoundation.framework>"
#import "<Metal.framework>"
#import "<Cocoa.framework>"
#import "<MetalKit.framework>"
#import "<Quartz.framework>"

#endif

#import "native/*.h"

#import "native/sokol_app.h"
#import "native/sokol_gfx.h"

#if __HOSTOS__="macos"
#import "native/sokol_glue.m"
#else
#import "native/sokol_glue.c"
#end


extern

'//=================================================================================================================================
'//
'//
'// sokol_app.h
'//
'//
'//=================================================================================================================================

#rem
    sokol_app.h -- cross-platform application wrapper

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_LOG(msg)      - your own logging function (default: puts(msg))
    SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))
    SOKOL_ABORT()       - called after an unrecoverable error (default: abort())
    SOKOL_WIN32_FORCE_MAIN  - define this on Win32 to use a main() entry point instead of WinMain
    SOKOL_NO_ENTRY      - define this if sokol_app.h shouldn't "hijack" the main() function
    SOKOL_API_DECL      - public function declaration prefix (default: extern)
    SOKOL_API_IMPL      - public function implementation prefix (default: -)
    SOKOL_CALLOC        - your own calloc function (default: calloc(n, s))
    SOKOL_FREE          - your own free function (default: free(p))

    Optionally define the following to force debug checks and validations
    even in release mode:

    SOKOL_DEBUG         - by default this is defined if _DEBUG is defined

    If sokol_app.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    Portions of the Windows and Linux GL initialization and event code have been
    taken from GLFW (http://www.glfw.org/)

    iOS onscreen keyboard support 'inspired' by libgdx.

    If you use sokol_app.h together with sokol_gfx.h, include both headers
    in the implementation source file, and include sokol_app.h before
    sokol_gfx.h since sokol_app.h will also include the required 3D-API
    headers.

    On Windows, a minimal 'GL header' and function loader is integrated which
    contains just enough of GL for sokol_gfx.h. If you want to use your own
    GL header-generator/loader instead, define SOKOL_WIN32_NO_GL_LOADER
    before including the implementation part of sokol_app.h.

    For example code, see https://github.com/floooh/sokol-samples/tree/master/sapp

    FEATURE OVERVIEW
    ================
    sokol_app.h provides a minimalistic cross-platform API which
    implements the 'application-wrapper' parts of a 3D application:

    - a common application entry function
    - creates a window and 3D-API context/device with a 'default framebuffer'
    - makes the rendered frame visible
    - provides keyboard-, mouse- and low-level touch-events
    - platforms: MacOS, iOS, HTML5, Win32, Linux, Android (RaspberryPi)
    - 3D-APIs: Metal, D3D11, GL3.2, GLES2, GLES3, WebGL, WebGL2

    FEATURE/PLATFORM MATRIX
    =======================
                        | Windows | macOS | Linux |  iOS  | Android | Raspi | HTML5
    --------------------+---------+-------+-------+-------+---------+-------+-------
    gl 3.x              | YES     | YES   | YES   | ---   | ---     | ---   | ---
    gles2/webgl         | ---     | ---   | ---   | YES   | YES     | TODO  | YES
    gles3/webgl2        | ---     | ---   | ---   | YES   | YES     | ---   | YES
    metal               | ---     | YES   | ---   | YES   | ---     | ---   | ---
    d3d11               | YES     | ---   | ---   | ---   | ---     | ---   | ---
    KEY_DOWN            | YES     | YES   | YES   | SOME  | TODO    | TODO  | YES
    KEY_UP              | YES     | YES   | YES   | SOME  | TODO    | TODO  | YES
    CHAR                | YES     | YES   | YES   | YES   | TODO    | TODO  | YES
    MOUSE_DOWN          | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    MOUSE_UP            | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    MOUSE_SCROLL        | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    MOUSE_MOVE          | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    MOUSE_ENTER         | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    MOUSE_LEAVE         | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    TOUCHES_BEGAN       | ---     | ---   | ---   | YES   | YES     | ---   | YES
    TOUCHES_MOVED       | ---     | ---   | ---   | YES   | YES     | ---   | YES
    TOUCHES_ENDED       | ---     | ---   | ---   | YES   | YES     | ---   | YES
    TOUCHES_CANCELLED   | ---     | ---   | ---   | YES   | YES     | ---   | YES
    RESIZED             | YES     | YES   | YES   | YES   | YES     | ---   | YES
    ICONIFIED           | YES     | YES   | YES   | ---   | ---     | ---   | ---
    RESTORED            | YES     | YES   | YES   | ---   | ---     | ---   | ---
    SUSPENDED           | ---     | ---   | ---   | YES   | YES     | ---   | TODO
    RESUMED             | ---     | ---   | ---   | YES   | YES     | ---   | TODO
    QUIT_REQUESTED      | YES     | YES   | YES   | ---   | ---     | TODO  | ---
    UPDATE_CURSOR       | YES     | YES   | TODO  | ---   | ---     | ---   | TODO
    IME                 | TODO    | TODO? | TODO  | ???   | TODO    | ???   | ???
    key repeat flag     | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    windowed            | YES     | YES   | YES   | ---   | ---     | TODO  | YES
    fullscreen          | YES     | YES   | TODO  | YES   | YES     | TODO  | ---
    pointer lock        | TODO    | TODO  | TODO  | ---   | ---     | TODO  | TODO
    screen keyboard     | ---     | ---   | ---   | YES   | TODO    | ---   | YES
    swap interval       | YES     | YES   | YES   | YES   | TODO    | TODO  | YES
    high-dpi            | YES     | YES   | TODO  | YES   | YES     | TODO  | YES

    - what about bluetooth keyboard / mouse on mobile platforms?

    STEP BY STEP
    ============
    --- Add a sokol_main() function to your code which returns a sapp_desc structure
        with initialization parameters and callback function pointers. This
        function is called very early, usually at the start of the
        platform's entry function (e.g. main or WinMain). You should do as
        little as possible here, since the rest of your code might be called
        from another thread (this depends on the platform):

            sapp_desc sokol_main(int argc, char* argv[]) {
                return (sapp_desc) {
                    .width = 640,
                    .height = 480,
                    .init_cb = my_init_func,
                    .frame_cb = my_frame_func,
                    .cleanup_cb = my_cleanup_func,
                    .event_cb = my_event_func,
                    ...
                };
            }

        There are many more setup parameters, but these are the most important.
        For a complete list search for the sapp_desc structure declaration
        below.

        DO NOT call any sokol-app function from inside sokol_main(), since
        sokol-app will not be initialized at this point.

        The .width and .height parameters are the preferred size of the 3D
        rendering canvas. The actual size may differ from this depending on
        platform and other circumstances. Also the canvas size may change at
        any time (for instance when the user resizes the application window,
        or rotates the mobile device).

        All provided function callbacks will be called from the same thread,
        but this may be different from the thread where sokol_main() was called.

        .init_cb (void (*)(void))
            This function is called once after the application window,
            3D rendering context and swap chain have been created. The
            function takes no arguments and has no return value.
        .frame_cb (void (*)(void))
            This is the per-frame callback, which is usually called 60
            times per second. This is where your application would update
            most of its state and perform all rendering.
        .cleanup_cb (void (*)(void))
            The cleanup callback is called once right before the application
            quits.
        .event_cb (void (*)(const sapp_event* event))
            The event callback is mainly for input handling, but in the
            future may also be used to communicate other types of events
            to the application. Keep the event_cb struct member zero-initialized
            if your application doesn't require event handling.
        .fail_cb (void (*)(const char* msg))
            The fail callback is called when a fatal error is encountered
            during start which doesn't allow the program to continue.
            Providing a callback here gives you a chance to show an error message
            to the user. The default behaviour is SOKOL_LOG(msg)

        As you can see, those 'standard callbacks' don't have a user_data
        argument, so any data that needs to be preserved between callbacks
        must live in global variables. If you're allergic to global variables
        or cannot use them for other reasons, an alternative set of callbacks
        can be defined in sapp_desc, together with a user_data pointer:

        .user_data (void*)
            The user-data argument for the callbacks below
        .init_userdata_cb (void (*)(void* user_data))
        .frame_userdata_cb (void (*)(void* user_data))
        .cleanup_userdata_cb (void (*)(void* user_data))
        .event_cb (void(*)(const sapp_event* event, void* user_data))
        .fail_cb (void(*)(const char* msg, void* user_data))
            These are the user-data versions of the callback functions. You
            can mix those with the standard callbacks that don't have the
            user_data argument.

        The function sapp_userdata() can be used to query the user_data
        pointer provided in the sapp_desc struct.

        You can call sapp_query_desc() to get a copy of the
        original sapp_desc structure.

        NOTE that there's also an alternative compile mode where sokol_app.h
        doesn't "hijack" the main() function. Search below for SOKOL_NO_ENTRY.

    --- Implement the initialization callback function (init_cb), this is called
        once after the rendering surface, 3D API and swap chain have been
        initialized by sokol_app. All sokol-app functions can be called
        from inside the initialization callback, the most useful functions
        at this point are:

        int sapp_width(void)
            Returns the current width of the default framebuffer, this may change
            from one frame to the next.
        int sapp_height(void)
            Likewise, returns the current height of the default framebuffer.

        bool sapp_gles2(void)
            Returns true if a GLES2 or WebGL context has been created. This
            is useful when a GLES3/WebGL2 context was requested but is not
            available so that sokol_app.h had to fallback to GLES2/WebGL.

        const void* sapp_metal_get_device(void)
        const void* sapp_metal_get_renderpass_descriptor(void)
        const void* sapp_metal_get_drawable(void)
            If the Metal backend has been selected, these functions return pointers
            to various Metal API objects required for rendering, otherwise
            they return a null pointer. These void pointers are actually
            Objective-C ids converted with an ARC __bridge cast so that
            they ids can be tunnel through C code. Also note that the returned
            pointers to the renderpass-descriptor and drawable may change from one
            frame to the next, only the Metal device object is guaranteed to
            stay the same.

        const void* sapp_macos_get_window(void)
            On macOS, get the NSWindow object pointer, otherwise a null pointer.
            Before being used as Objective-C object, the void* must be converted
            back with an ARC __bridge cast.

        const void* sapp_ios_get_window(void)
            On iOS, get the UIWindow object pointer, otherwise a null pointer.
            Before being used as Objective-C object, the void* must be converted
            back with an ARC __bridge cast.

        const void* sapp_win32_get_hwnd(void)
            On Windows, get the window's HWND, otherwise a null pointer. The
            HWND has been cast to a void pointer in order to be tunneled
            through code which doesn't include Windows.h.

        const void* sapp_d3d11_get_device(void);
        const void* sapp_d3d11_get_device_context(void);
        const void* sapp_d3d11_get_render_target_view(void);
        const void* sapp_d3d11_get_depth_stencil_view(void);
            Similar to the sapp_metal_* functions, the sapp_d3d11_* functions
            return pointers to D3D11 API objects required for rendering,
            only if the D3D11 backend has been selected. Otherwise they
            return a null pointer. Note that the returned pointers to the
            render-target-view and depth-stencil-view may change from one
            frame to the next!

        const void* sapp_android_get_native_activity(void);
            On Android, get the native activity ANativeActivity pointer, otherwise
            a null pointer.

    --- Implement the frame-callback function, this function will be called
        on the same thread as the init callback, but might be on a different
        thread than the sokol_main() function. Note that the size of
        the rendering framebuffer might have changed since the frame callback
        was called last. Call the functions sapp_width() and sapp_height()
        each frame to get the current size.

    --- Optionally implement the event-callback to handle input events.
        sokol-app provides the following type of input events:
            - a 'virtual key' was pressed down or released
            - a single text character was entered (provided as UTF-32 code point)
            - a mouse button was pressed down or released (left, right, middle)
            - mouse-wheel or 2D scrolling events
            - the mouse was moved
            - the mouse has entered or left the application window boundaries
            - low-level, portable multi-touch events (began, moved, ended, cancelled)
            - the application window was resized, iconified or restored
            - the application was suspended or restored (on mobile platforms)
            - the user or application code has asked to quit the application

    --- Implement the cleanup-callback function, this is called once
        after the user quits the application (see the section
        "APPLICATION QUIT" for detailed information on quitting
        behaviour, and how to intercept a pending quit (for instance to show a
        "Really Quit?" dialog box). Note that the cleanup-callback isn't
        called on the web and mobile platforms.

    HIGH-DPI RENDERING
    ==================
    You can set the sapp_desc.high_dpi flag during initialization to request
    a full-resolution framebuffer on HighDPI displays. The default behaviour
    is sapp_desc.high_dpi=false, this means that the application will
    render to a lower-resolution framebuffer on HighDPI displays and the
    rendered content will be upscaled by the window system composer.

    In a HighDPI scenario, you still request the same window size during
    sokol_main(), but the framebuffer sizes returned by sapp_width()
    and sapp_height() will be scaled up according to the DPI scaling
    ratio. You can also get a DPI scaling factor with the function
    sapp_dpi_scale().

    Here's an example on a Mac with Retina display:

    sapp_desc sokol_main() {
        return (sapp_desc) {
            .width = 640,
            .height = 480,
            .high_dpi = true,
            ...
        };
    }

    The functions sapp_width(), sapp_height() and sapp_dpi_scale() will
    return the following values:

    sapp_width      -> 1280
    sapp_height     -> 960
    sapp_dpi_scale  -> 2.0

    If the high_dpi flag is false, or you're not running on a Retina display,
    the values would be:

    sapp_width      -> 640
    sapp_height     -> 480
    sapp_dpi_scale  -> 1.0

    APPLICATION QUIT
    ================
    Without special quit handling, a sokol_app.h application will exist
    'gracefully' when the user clicks the window close-button. 'Graceful
    exit' means that the application-provided cleanup callback will be
    called.

    This 'graceful exit' is only supported on native desktop platforms, on
    the web and mobile platforms an application may be terminated at any time
    by the user or browser/OS runtime environment without a chance to run
    custom shutdown code.

    On the web platform, you can call the following function to let the
    browser open a standard popup dialog before the user wants to leave a site:

        sapp_html5_ask_leave_site(bool ask);

    The initial state of the associated internal flag can be provided
    at startup via sapp_desc.html5_ask_leave_site.

    This feature should only be used sparingly in critical situations - for
    instance when the user would loose data - since popping up modal dialog
    boxes is considered quite rude in the web world. Note that there's no way
    to customize the content of this dialog box or run any code as a result
    of the user's decision. Also note that the user must have interacted with
    the site before the dialog box will appear. These are all security measures
    to prevent fishing.

    On native desktop platforms, sokol_app.h provides more control over the
    application-quit-process. It's possible to initiate a 'programmatic quit'
    from the application code, and a quit initiated by the application user
    can be intercepted (for instance to show a custom dialog box).

    This 'programmatic quit protocol' is implemented trough 3 functions
    and 1 event:

        - sapp_quit(): This function simply quits the application without
          giving the user a chance to intervene. Usually this might
          be called when the user clicks the 'Ok' button in a 'Really Quit?'
          dialog box
        - sapp_request_quit(): Calling sapp_request_quit() will send the
          event SAPP_EVENTTYPE_QUIT_REQUESTED to the applications event handler
          callback, giving the user code a chance to intervene and cancel the
          pending quit process (for instance to show a 'Really Quit?' dialog
          box). If the event handler callback does nothing, the application
          will be quit as usual. To prevent this, call the function
          sapp_cancel_quit() from inside the event handler.
        - sapp_cancel_quit(): Cancels a pending quit request, either initiated
          by the user clicking the window close button, or programmatically
          by calling sapp_request_quit(). The only place where calling this
          function makes sense is from inside the event handler callback when
          the SAPP_EVENTTYPE_QUIT_REQUESTED event has been received.
        - SAPP_EVENTTYPE_QUIT_REQUESTED: this event is sent when the user
          clicks the window's close button or application code calls the
          sapp_request_quit() function. The event handler callback code can handle
          this event by calling sapp_cancel_quit() to cancel the quit.
          If the event is ignored, the application will quit as usual.

    The Dear ImGui HighDPI sample contains example code of how to
    implement a 'Really Quit?' dialog box with Dear ImGui (native desktop
    platforms only), and for showing the hardwired "Leave Site?" dialog box
    when running on the web platform:

        https://floooh.github.io/sokol-html5/wasm/imgui-highdpi-sapp.html

    FULLSCREEN
    ==========
    If the sapp_desc.fullscreen flag is true, sokol-app will try to create
    a fullscreen window on platforms with a 'proper' window system
    (mobile devices will always use fullscreen). The implementation details
    depend on the target platform, in general sokol-app will use a
    'soft approach' which doesn't interfere too much with the platform's
    window system (for instance borderless fullscreen window instead of
    a 'real' fullscreen mode). Such details might change over time
    as sokol-app is adapted for different needs.

    The most important effect of fullscreen mode to keep in mind is that
    the requested canvas width and height will be ignored for the initial
    window size, calling sapp_width() and sapp_height() will instead return
    the resolution of the fullscreen canvas (however the provided size
    might still be used for the non-fullscreen window, in case the user can
    switch back from fullscreen- to windowed-mode).

    ONSCREEN KEYBOARD
    =================
    On some platforms which don't provide a physical keyboard, sokol-app
    can display the platform's integrated onscreen keyboard for text
    input. To request that the onscreen keyboard is shown, call

        sapp_show_keyboard(true);

    Likewise, to hide the keyboard call:

        sapp_show_keyboard(false);

    Note that on the web platform, the keyboard can only be shown from
    inside an input handler. On such platforms, sapp_show_keyboard()
    will only work as expected when it is called from inside the
    sokol-app event callback function. When called from other places,
    an internal flag will be set, and the onscreen keyboard will be
    called at the next 'legal' opportunity (when the next input event
    is handled).

    OPTIONAL: DON'T HIJACK main() (#define SOKOL_NO_ENTRY)
    ======================================================
    In its default configuration, sokol_app.h "hijacks" the platform's
    standard main() function. This was done because different platforms
    have different main functions which are not compatible with
    C's main() (for instance WinMain on Windows has completely different
    arguments). However, this "main hijacking" posed a problem for
    usage scenarios like integrating sokol_app.h with other languages than
    C or C++, so an alternative SOKOL_NO_ENTRY mode has been added
    in which the user code provides the platform's main function:

    - define SOKOL_NO_ENTRY before including the sokol_app.h implementation
    - do *not* provide a sokol_main() function
    - instead provide the standard main() function of the platform
    - from the main function, call the function ```sapp_run()``` which
      takes a pointer to an ```sapp_desc``` structure.
    - ```sapp_run()``` takes over control and calls the provided init-, frame-,
      shutdown- and event-callbacks just like in the default model, it
      will only return when the application quits (or not at all on some
      platforms, like emscripten)

    NOTE: SOKOL_NO_ENTRY is currently not supported on Android.

    TEMP NOTE DUMP
    ==============
    - onscreen keyboard support on Android requires Java :(, should we even bother?
    - sapp_desc needs a bool whether to initialize depth-stencil surface
    - GL context initialization needs more control (at least what GL version to initialize)
    - application icon
    - mouse pointer visibility(?)
    - the UPDATE_CURSOR event currently behaves differently between Win32 and OSX
      (Win32 sends the event each frame when the mouse moves and is inside the window
      client area, OSX sends it only once when the mouse enters the client area)
    - the Android implementation calls cleanup_cb() and destroys the egl context in onDestroy
      at the latest but should do it earlier, in onStop, as an app is "killable" after onStop
      on Android Honeycomb and later (it can't be done at the moment as the app may be started
      again after onStop and the sokol lifecycle does not yet handle context teardown/bringup)

    FIXME: ERROR HANDLING (this will need an error callback function)

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
#end

'// enum
const SAPP_MAX_TOUCHPOINTS:int ' = 8
const SAPP_MAX_MOUSEBUTTONS:int ' = 3
const SAPP_MAX_KEYCODES:int ' = 512

enum sapp_event_type
end
const SAPP_EVENTTYPE_INVALID:sapp_event_type
const SAPP_EVENTTYPE_KEY_DOWN:sapp_event_type
const SAPP_EVENTTYPE_KEY_UP:sapp_event_type
const SAPP_EVENTTYPE_CHAR:sapp_event_type
const SAPP_EVENTTYPE_MOUSE_DOWN:sapp_event_type
const SAPP_EVENTTYPE_MOUSE_UP:sapp_event_type
const SAPP_EVENTTYPE_MOUSE_SCROLL:sapp_event_type
const SAPP_EVENTTYPE_MOUSE_MOVE:sapp_event_type
const SAPP_EVENTTYPE_MOUSE_ENTER:sapp_event_type
const SAPP_EVENTTYPE_MOUSE_LEAVE:sapp_event_type
const SAPP_EVENTTYPE_TOUCHES_BEGAN:sapp_event_type
const SAPP_EVENTTYPE_TOUCHES_MOVED:sapp_event_type
const SAPP_EVENTTYPE_TOUCHES_ENDED:sapp_event_type
const SAPP_EVENTTYPE_TOUCHES_CANCELLED:sapp_event_type
const SAPP_EVENTTYPE_RESIZED:sapp_event_type
const SAPP_EVENTTYPE_ICONIFIED:sapp_event_type
const SAPP_EVENTTYPE_RESTORED:sapp_event_type
const SAPP_EVENTTYPE_SUSPENDED:sapp_event_type
const SAPP_EVENTTYPE_RESUMED:sapp_event_type
const SAPP_EVENTTYPE_UPDATE_CURSOR:sapp_event_type
const SAPP_EVENTTYPE_QUIT_REQUESTED:sapp_event_type
const _SAPP_EVENTTYPE_NUM:sapp_event_type
const _SAPP_EVENTTYPE_FORCE_U32:sapp_event_type

'/* key codes are the same names and values as GLFW */
enum sapp_keycode
end
const SAPP_KEYCODE_INVALID:sapp_keycode			'= 0,
const SAPP_KEYCODE_SPACE:sapp_keycode			'= 32,
const SAPP_KEYCODE_APOSTROPHE:sapp_keycode		'= 39,  /* ' */
const SAPP_KEYCODE_COMMA:sapp_keycode			'= 44,  /* , */
const SAPP_KEYCODE_MINUS:sapp_keycode			'= 45,  /* - */
const SAPP_KEYCODE_PERIOD:sapp_keycode			'= 46,  /* . */
const SAPP_KEYCODE_SLASH:sapp_keycode			'= 47,  /* / */
const SAPP_KEYCODE_0:sapp_keycode				'= 48,
const SAPP_KEYCODE_1:sapp_keycode				'= 49,
const SAPP_KEYCODE_2:sapp_keycode				'= 50,
const SAPP_KEYCODE_3:sapp_keycode				'= 51,
const SAPP_KEYCODE_4:sapp_keycode				'= 52,
const SAPP_KEYCODE_5:sapp_keycode				'= 53,
const SAPP_KEYCODE_6:sapp_keycode				'= 54,
const SAPP_KEYCODE_7:sapp_keycode				'= 55,
const SAPP_KEYCODE_8:sapp_keycode				'= 56,
const SAPP_KEYCODE_9:sapp_keycode				'= 57,
const SAPP_KEYCODE_SEMICOLON:sapp_keycode		'= 59,  /*  */
const SAPP_KEYCODE_EQUAL:sapp_keycode			'= 61,  /* = */
const SAPP_KEYCODE_A:sapp_keycode				'= 65,
const SAPP_KEYCODE_B:sapp_keycode				'= 66,
const SAPP_KEYCODE_C:sapp_keycode				'= 67,
const SAPP_KEYCODE_D:sapp_keycode				'= 68,
const SAPP_KEYCODE_E:sapp_keycode				'= 69,
const SAPP_KEYCODE_F:sapp_keycode				'= 70,
const SAPP_KEYCODE_G:sapp_keycode				'= 71,
const SAPP_KEYCODE_H:sapp_keycode				'= 72,
const SAPP_KEYCODE_I:sapp_keycode				'= 73,
const SAPP_KEYCODE_J:sapp_keycode				'= 74,
const SAPP_KEYCODE_K:sapp_keycode				'= 75,
const SAPP_KEYCODE_L:sapp_keycode				'= 76,
const SAPP_KEYCODE_M:sapp_keycode				'= 77,
const SAPP_KEYCODE_N:sapp_keycode				'= 78,
const SAPP_KEYCODE_O:sapp_keycode				'= 79,
const SAPP_KEYCODE_P:sapp_keycode				'= 80,
const SAPP_KEYCODE_Q:sapp_keycode				'= 81,
const SAPP_KEYCODE_R:sapp_keycode				'= 82,
const SAPP_KEYCODE_S:sapp_keycode				'= 83,
const SAPP_KEYCODE_T:sapp_keycode				'= 84,
const SAPP_KEYCODE_U:sapp_keycode				'= 85,
const SAPP_KEYCODE_V:sapp_keycode				'= 86,
const SAPP_KEYCODE_W:sapp_keycode				'= 87,
const SAPP_KEYCODE_X:sapp_keycode				'= 88,
const SAPP_KEYCODE_Y:sapp_keycode				'= 89,
const SAPP_KEYCODE_Z:sapp_keycode				'= 90,
const SAPP_KEYCODE_LEFT_BRACKET:sapp_keycode		'= 91,  /* [ */
const SAPP_KEYCODE_BACKSLASH:sapp_keycode		'= 92,  /* \ */
const SAPP_KEYCODE_RIGHT_BRACKET:sapp_keycode	'= 93,  /* ] */
const SAPP_KEYCODE_GRAVE_ACCENT:sapp_keycode		'= 96,  /* ` */
const SAPP_KEYCODE_WORLD_1:sapp_keycode			'= 161, /* non-US #1 */
const SAPP_KEYCODE_WORLD_2:sapp_keycode			'= 162, /* non-US #2 */
const SAPP_KEYCODE_ESCAPE:sapp_keycode			'= 256,
const SAPP_KEYCODE_ENTER:sapp_keycode			'= 257,
const SAPP_KEYCODE_TAB:sapp_keycode				'= 258,
const SAPP_KEYCODE_BACKSPACE:sapp_keycode		'= 259,
const SAPP_KEYCODE_INSERT:sapp_keycode			'= 260,
const SAPP_KEYCODE_DELETE:sapp_keycode			'= 261,
const SAPP_KEYCODE_RIGHT:sapp_keycode			'= 262,
const SAPP_KEYCODE_LEFT:sapp_keycode				'= 263,
const SAPP_KEYCODE_DOWN:sapp_keycode				'= 264,
const SAPP_KEYCODE_UP:sapp_keycode				'= 265,
const SAPP_KEYCODE_PAGE_UP:sapp_keycode			'= 266,
const SAPP_KEYCODE_PAGE_DOWN:sapp_keycode		'= 267,
const SAPP_KEYCODE_HOME:sapp_keycode				'= 268,
const SAPP_KEYCODE_END:sapp_keycode				'= 269,
const SAPP_KEYCODE_CAPS_LOCK:sapp_keycode		'= 280,
const SAPP_KEYCODE_SCROLL_LOCK:sapp_keycode		'= 281,
const SAPP_KEYCODE_NUM_LOCK:sapp_keycode			'= 282,
const SAPP_KEYCODE_PRINT_SCREEN:sapp_keycode		'= 283,
const SAPP_KEYCODE_PAUSE:sapp_keycode			'= 284,
const SAPP_KEYCODE_F1:sapp_keycode				'= 290,
const SAPP_KEYCODE_F2:sapp_keycode				'= 291,
const SAPP_KEYCODE_F3:sapp_keycode				'= 292,
const SAPP_KEYCODE_F4:sapp_keycode				'= 293,
const SAPP_KEYCODE_F5:sapp_keycode				'= 294,
const SAPP_KEYCODE_F6:sapp_keycode				'= 295,
const SAPP_KEYCODE_F7:sapp_keycode				'= 296,
const SAPP_KEYCODE_F8:sapp_keycode				'= 297,
const SAPP_KEYCODE_F9:sapp_keycode				'= 298,
const SAPP_KEYCODE_F10:sapp_keycode				'= 299,
const SAPP_KEYCODE_F11:sapp_keycode				'= 300,
const SAPP_KEYCODE_F12:sapp_keycode				'= 301,
const SAPP_KEYCODE_F13:sapp_keycode				'= 302,
const SAPP_KEYCODE_F14:sapp_keycode				'= 303,
const SAPP_KEYCODE_F15:sapp_keycode				'= 304,
const SAPP_KEYCODE_F16:sapp_keycode				'= 305,
const SAPP_KEYCODE_F17:sapp_keycode				'= 306,
const SAPP_KEYCODE_F18:sapp_keycode				'= 307,
const SAPP_KEYCODE_F19:sapp_keycode				'= 308,
const SAPP_KEYCODE_F20:sapp_keycode				'= 309,
const SAPP_KEYCODE_F21:sapp_keycode				'= 310,
const SAPP_KEYCODE_F22:sapp_keycode				'= 311,
const SAPP_KEYCODE_F23:sapp_keycode				'= 312,
const SAPP_KEYCODE_F24:sapp_keycode				'= 313,
const SAPP_KEYCODE_F25:sapp_keycode				'= 314,
const SAPP_KEYCODE_KP_0:sapp_keycode				'= 320,
const SAPP_KEYCODE_KP_1:sapp_keycode				'= 321,
const SAPP_KEYCODE_KP_2:sapp_keycode				'= 322,
const SAPP_KEYCODE_KP_3:sapp_keycode				'= 323,
const SAPP_KEYCODE_KP_4:sapp_keycode				'= 324,
const SAPP_KEYCODE_KP_5:sapp_keycode				'= 325,
const SAPP_KEYCODE_KP_6:sapp_keycode				'= 326,
const SAPP_KEYCODE_KP_7:sapp_keycode				'= 327,
const SAPP_KEYCODE_KP_8:sapp_keycode				'= 328,
const SAPP_KEYCODE_KP_9:sapp_keycode				'= 329,
const SAPP_KEYCODE_KP_DECIMAL:sapp_keycode		'= 330,
const SAPP_KEYCODE_KP_DIVIDE:sapp_keycode		'= 331,
const SAPP_KEYCODE_KP_MULTIPLY:sapp_keycode		'= 332,
const SAPP_KEYCODE_KP_SUBTRACT:sapp_keycode		'= 333,
const SAPP_KEYCODE_KP_ADD:sapp_keycode			'= 334,
const SAPP_KEYCODE_KP_ENTER:sapp_keycode			'= 335,
const SAPP_KEYCODE_KP_EQUAL:sapp_keycode			'= 336,
const SAPP_KEYCODE_LEFT_SHIFT:sapp_keycode		'= 340,
const SAPP_KEYCODE_LEFT_CONTROL:sapp_keycode		'= 341,
const SAPP_KEYCODE_LEFT_ALT:sapp_keycode			'= 342,
const SAPP_KEYCODE_LEFT_SUPER:sapp_keycode		'= 343,
const SAPP_KEYCODE_RIGHT_SHIFT:sapp_keycode		'= 344,
const SAPP_KEYCODE_RIGHT_CONTROL:sapp_keycode	'= 345,
const SAPP_KEYCODE_RIGHT_ALT:sapp_keycode		'= 346,
const SAPP_KEYCODE_RIGHT_SUPER:sapp_keycode		'= 347,
const SAPP_KEYCODE_MENU:sapp_keycode				'= 348,

struct sapp_touchpoint
	field identifier:ulong 'libc.uintptr_t
	field pos_x:float
	field pos_y:float
	field changed:bool
end

enum sapp_mousebutton
end
const SAPP_MOUSEBUTTON_INVALID:sapp_mousebutton
const SAPP_MOUSEBUTTON_LEFT:sapp_mousebutton
const SAPP_MOUSEBUTTON_RIGHT:sapp_mousebutton
const SAPP_MOUSEBUTTON_MIDDLE:sapp_mousebutton

'enum
const SAPP_MODIFIER_SHIFT:int '(1 << 0)
const SAPP_MODIFIER_CTRL:int '(1 << 1)
const SAPP_MODIFIER_ALT:int '(1 << 2)
const SAPP_MODIFIER_SUPER:int '(1 << 3)

struct sapp_event = "const sapp_event"
	field frame_count:ulong
	field type:sapp_event_type
	field key_code:sapp_keycode
	field char_code:uint
	field key_repeat:bool
	field modifiers:uint
	field mouse_x:float
	field mouse_y:float
	field scroll_x:float
	field scroll_y:float
	field num_touches:int
	field touches:sapp_touchpoint[] '[SAPP_MAX_TOUCHPOINTS]
	field window_width:int
	field window_height:int
	field framebuffer_width:int
	field framebuffer_height:int
end

struct sapp_desc
	'/* these are the user-provided callbacks without user data */
	field init_cb:void()
	field frame_cb:void()
	field cleanup_cb:void()
	field event_cb:void(sapp_event ptr)
	field fail_cb:void(const_char_t ptr)
	
	'/* these are the user-provided callbacks with user data */*
	field user_data:void ptr
	field init_userdata_cb:void(void ptr)
	field frame_userdata_cb:void(void ptr)
	field cleanup_userdata_cb:void(void ptr)
	field event_userdata_cb:void(sapp_event ptr, void ptr)
	field fail_userdata_cb:void(const_char_t ptr, void ptr)
	
	field width:int								'/* the preferred width of the window / canvas */
	field height:int							'/* the preferred height of the window / canvas */
	field sample_count:int						'/* MSAA sample count */
	field swap_interval:int						'/* the preferred swap interval (ignored on some platforms) */
	field high_dpi:bool							'/* whether the rendering canvas is full-resolution on HighDPI displays */
	field fullscreen:bool						'/* whether the window should be created in fullscreen mode */
	field alpha:bool							'/* whether the framebuffer should have an alpha channel (ignored on some platforms) */
	field window_title:const_char_t ptr	'/* the window title as UTF-8 encoded string */
	field user_cursor:bool						'/* if true, user is expected to manage cursor image in SAPP_EVENTTYPE_UPDATE_CURSOR */

	field html5_canvas_name:const_char_t ptr '/* the name (id) of the HTML5 canvas element, default is "canvas" */
	field html5_canvas_resize:bool				'/* if true, the HTML5 canvas size is set to sapp_desc.width/height, otherwise canvas size is tracked */
	field html5_preserve_drawing_buffer:bool	'/* HTML5 only: whether to preserve default framebuffer content between frames */
	field html5_premultiplied_alpha:bool		'/* HTML5 only: whether the rendered pixels use premultiplied alpha convention */
	field html5_ask_leave_site:bool				'/* initial state of the internal html5_ask_leave_site flag (see sapp_html5_ask_leave_site()) */
	field ios_keyboard_resizes_canvas:bool		'/* if true, showing the iOS keyboard shrinks the canvas */
	field gl_force_gles2:bool					'/* if true, setup GLES2/WebGL even if GLES3/WebGL2 is available */
end

#rem monkeydoc User-provided functions
#end
function sokol_main:sapp_desc(argc:int, argv:char_t ptr ptr)



#rem monkeydoc Returns true after sokol-app has been initialized
#end
function sapp_isvalid:bool()

#rem monkeydoc Returns the current framebuffer width in pixels
#end
function sapp_width:int()

#rem monkeydoc returns the current framebuffer height in pixels
#end
function sapp_height:int()

#rem monkeydoc Returns true when high_dpi was requested and actually running in a high-dpi scenario
#end
function sapp_high_dpi:bool()

#rem monkeydoc Returns the dpi scaling factor (window pixels to framebuffer pixels)
#end
function sapp_dpi_scale:float()

#rem monkeydoc show or hide the mobile device onscreen keyboard
#end
function sapp_show_keyboard(visible:bool)

#rem monkeydoc return true if the mobile device onscreen keyboard is currently shown
#end
function sapp_keyboard_shown:bool()

#rem monkeydoc show or hide the mouse cursor
#end
function sapp_show_mouse(visible:bool)

#rem monkeydoc show or hide the mouse cursor
#end
function sapp_mouse_shown:bool()

#rem monkeydoc return the userdata pointer optionally provided in sapp_desc
#end
function sapp_userdata:void ptr()

#rem monkeydoc return a copy of the sapp_desc structure
#end
function sapp_query_desc:sapp_desc()

#rem monkeydoc initiate a "soft quit" (sends SAPP_EVENTTYPE_QUIT_REQUESTED)
#end
function sapp_request_quit()

#rem monkeydoc cancel a pending quit (when SAPP_EVENTTYPE_QUIT_REQUESTED has been received)
#end
function sapp_cancel_quit()

#rem monkeydoc intiate a "hard quit" (quit application without sending SAPP_EVENTTYPE_QUIT_REQUSTED)
#end
function sapp_quit()

#rem monkeydoc get the current frame counter (for comparison with sapp_event.frame_count)
#end
function sapp_frame_count:ulong()



#rem monkeydoc special run-function for SOKOL_NO_ENTRY (in standard mode this is an empty stub)
#end
function sapp_run:int(desc:sapp_desc ptr)



#rem monkeydoc GL: return true when GLES2 fallback is active (to detect fallback from GLES3)
#end
function sapp_gles2:bool()



#rem monkeydoc HTML5: enable or disable the hardwired "Leave Site?" dialog box
#end
function sapp_html5_ask_leave_site(ask:bool)



#rem monkeydoc Metal: get ARC-bridged pointer to Metal device object
#end
function sapp_metal_get_device:void ptr()
#rem monkeydoc Metal: get ARC-bridged pointer to this frame's renderpass descriptor
#end
function sapp_metal_get_renderpass_descriptor:void ptr()
#rem monkeydoc Metal: get ARC-bridged pointer to current drawable
#end
function sapp_metal_get_drawable:void ptr()
#rem monkeydoc macOS: get ARC-bridged pointer to macOS NSWindow
#end
function sapp_macos_get_window:void ptr()
#rem monkeydoc iOS: get ARC-bridged pointer to iOS UIWindow
#end
function sapp_ios_get_window:void ptr()



#rem monkeydoc D3D11: get pointer to ID3D11Device object
#end
function sapp_d3d11_get_device:void ptr()
#rem monkeydoc D3D11: get pointer to ID3D11DeviceContext object
#end
function sapp_d3d11_get_device_context:void ptr()
#rem monkeydoc D3D11: get pointer to ID3D11RenderTargetView object
#end
function sapp_d3d11_get_render_target_view:void ptr()
#rem monkeydoc D3D11: get pointer to ID3D11DepthStencilView
#end
function sapp_d3d11_get_depth_stencil_view:void ptr()
#rem monkeydoc Win32: get the HWND window handle
#end
function sapp_win32_get_hwnd:void ptr()



#rem monkeydoc Android: get native activity handle
#end
function sapp_android_get_native_activity:void ptr()

'//=================================================================================================================================
'//
'//
'// sokol_gfx.h
'//
'//
'//=================================================================================================================================

#rem
    sokol_gfx.h -- simple 3D API wrapper

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    In the same place define one of the following to select the rendering
    backend:
        #define SOKOL_GLCORE33
        #define SOKOL_GLES2
        #define SOKOL_GLES3
        #define SOKOL_D3D11
        #define SOKOL_METAL
        #define SOKOL_DUMMY_BACKEND

    I.e. for the GL 3.3 Core Profile it should look like this:

    #include ...
    #include ...
    #define SOKOL_IMPL
    #define SOKOL_GLCORE33
    #include "sokol_gfx.h"

    The dummy backend replaces the platform-specific backend code with empty
    stub functions. This is useful for writing tests that need to run on the
    command line.

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_MALLOC(s)     - your own malloc function (default: malloc(s))
    SOKOL_FREE(p)       - your own free function (default: free(p))
    SOKOL_LOG(msg)      - your own logging function (default: puts(msg))
    SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))
    SOKOL_API_DECL      - public function declaration prefix (default: extern)
    SOKOL_API_IMPL      - public function implementation prefix (default: -)
    SOKOL_TRACE_HOOKS   - enable trace hook callbacks (search below for TRACE HOOKS)

    If sokol_gfx.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    If you want to compile without deprecated structs and functions,
    define:

    SOKOL_NO_DEPRECATED

    API usage validation macros:

    SOKOL_VALIDATE_BEGIN()      - begin a validation block (default:_sg_validate_begin())
    SOKOL_VALIDATE(cond, err)   - like assert but for API validation (default: _sg_validate(cond, err))
    SOKOL_VALIDATE_END()        - end a validation block, return true if all checks in block passed (default: bool _sg_validate())

    If you don't want validation errors to be fatal, define SOKOL_VALIDATE_NON_FATAL,
    be aware though that this may spam SOKOL_LOG messages.

    Optionally define the following to force debug checks and validations
    even in release mode:

    SOKOL_DEBUG         - by default this is defined if _DEBUG is defined


    sokol_gfx DOES NOT:
    ===================
    - create a window or the 3D-API context/device, you must do this
      before sokol_gfx is initialized, and pass any required information
      (like 3D device pointers) to the sokol_gfx initialization call

    - present the rendered frame, how this is done exactly usually depends
      on how the window and 3D-API context/device was created

    - provide a unified shader language, instead 3D-API-specific shader
      source-code or shader-bytecode must be provided

    For complete code examples using the various backend 3D-APIs, see:

        https://github.com/floooh/sokol-samples

    For an optional shader-cross-compile solution, see:

        https://github.com/floooh/sokol-tools/blob/master/docs/sokol-shdc.md


    STEP BY STEP
    ============
    --- to initialize sokol_gfx, after creating a window and a 3D-API
        context/device, call:

            sg_setup(const sg_desc*)

    --- create resource objects (at least buffers, shaders and pipelines,
        and optionally images and passes):

            sg_buffer sg_make_buffer(const sg_buffer_desc*)
            sg_image sg_make_image(const sg_image_desc*)
            sg_shader sg_make_shader(const sg_shader_desc*)
            sg_pipeline sg_make_pipeline(const sg_pipeline_desc*)
            sg_pass sg_make_pass(const sg_pass_desc*)

    --- start rendering to the default frame buffer with:

            sg_begin_default_pass(const sg_pass_action* actions, int width, int height)

    --- or start rendering to an offscreen framebuffer with:

            sg_begin_pass(sg_pass pass, const sg_pass_action* actions)

    --- set the pipeline state for the next draw call with:

            sg_apply_pipeline(sg_pipeline pip)

    --- fill an sg_bindings struct with the resource bindings for the next
        draw call (1..N vertex buffers, 0 or 1 index buffer, 0..N image objects
        to use as textures each on the vertex-shader- and fragment-shader-stage
        and then call

            sg_apply_bindings(const sg_bindings* bindings)

        to update the resource bindings

    --- optionally update shader uniform data with:

            sg_apply_uniforms(sg_shader_stage stage, int ub_index, const void* data, int num_bytes)

    --- kick off a draw call with:

            sg_draw(int base_element, int num_elements, int num_instances)

    --- finish the current rendering pass with:

            sg_end_pass()

    --- when done with the current frame, call

            sg_commit()

    --- at the end of your program, shutdown sokol_gfx with:

            sg_shutdown()

    --- if you need to destroy resources before sg_shutdown(), call:

            sg_destroy_buffer(sg_buffer buf)
            sg_destroy_image(sg_image img)
            sg_destroy_shader(sg_shader shd)
            sg_destroy_pipeline(sg_pipeline pip)
            sg_destroy_pass(sg_pass pass)

    --- to set a new viewport rectangle, call

            sg_apply_viewport(int x, int y, int width, int height, bool origin_top_left)

    --- to set a new scissor rect, call:

            sg_apply_scissor_rect(int x, int y, int width, int height, bool origin_top_left)

        both sg_apply_viewport() and sg_apply_scissor_rect() must be called
        inside a rendering pass

        beginning a pass will reset the viewport to the size of the framebuffer used
        in the new pass,

    --- to update (overwrite) the content of buffer and image resources, call:

            sg_update_buffer(sg_buffer buf, const void* ptr, int num_bytes)
            sg_update_image(sg_image img, const sg_image_content* content)

        Buffers and images to be updated must have been created with
        SG_USAGE_DYNAMIC or SG_USAGE_STREAM

        Only one update per frame is allowed for buffer and image resources.
        The rationale is to have a simple countermeasure to avoid the CPU
        scribbling over data the GPU is currently using, or the CPU having to
        wait for the GPU

        Buffer and image updates can be partial, as long as a rendering
        operation only references the valid (updated) data in the
        buffer or image.

    --- to append a chunk of data to a buffer resource, call:

            int sg_append_buffer(sg_buffer buf, const void* ptr, int num_bytes)

        The difference to sg_update_buffer() is that sg_append_buffer()
        can be called multiple times per frame to append new data to the
        buffer piece by piece, optionally interleaved with draw calls referencing
        the previously written data.

        sg_append_buffer() returns a byte offset to the start of the
        written data, this offset can be assigned to
        sg_bindings.vertex_buffer_offsets[n] or
        sg_bindings.index_buffer_offset

        Code example:

        for (...) {
            const void* data = ...;
            const int num_bytes = ...;
            int offset = sg_append_buffer(buf, data, num_bytes);
            bindings.vertex_buffer_offsets[0] = offset;
            sg_apply_pipeline(pip);
            sg_apply_bindings(&bindings);
            sg_apply_uniforms(...);
            sg_draw(...);
        }

        A buffer to be used with sg_append_buffer() must have been created
        with SG_USAGE_DYNAMIC or SG_USAGE_STREAM.

        If the application appends more data to the buffer then fits into
        the buffer, the buffer will go into the "overflow" state for the
        rest of the frame.

        Any draw calls attempting to render an overflown buffer will be
        silently dropped (in debug mode this will also result in a
        validation error).

        You can also check manually if a buffer is in overflow-state by calling

            bool sg_query_buffer_overflow(sg_buffer buf)

    --- to check at runtime for optional features, limits and pixelformat support,
        call:

            sg_features sg_query_features()
            sg_limits sg_query_limits()
            sg_pixelformat_info sg_query_pixelformat(sg_pixel_format fmt)

    --- if you need to call into the underlying 3D-API directly, you must call:

            sg_reset_state_cache()

        ...before calling sokol_gfx functions again

    --- you can inspect the original sg_desc structure handed to sg_setup()
        by calling sg_query_desc(). This will return an sg_desc struct with
        the default values patched in instead of any zero-initialized values

    --- you can inspect various internal resource attributes via:

            sg_buffer_info sg_query_buffer_info(sg_buffer buf)
            sg_image_info sg_query_image_info(sg_image img)
            sg_shader_info sg_query_shader_info(sg_shader shd)
            sg_pipeline_info sg_query_pipeline_info(sg_pipeline pip)
            sg_pass_info sg_query_pass_info(sg_pass pass)

        ...please note that the returned info-structs are tied quite closely
        to sokol_gfx.h internals, and may change more often than other
        public API functions and structs.

    --- you can ask at runtime what backend sokol_gfx.h has been compiled
        for, or whether the GLES3 backend had to fall back to GLES2 with:

            sg_backend sg_query_backend(void)

    --- you can query the default resource creation parameters through the functions

            sg_buffer_desc sg_query_buffer_defaults(const sg_buffer_desc* desc)
            sg_image_desc sg_query_image_defaults(const sg_image_desc* desc)
            sg_shader_desc sg_query_shader_defaults(const sg_shader_desc* desc)
            sg_pipeline_desc sg_query_pipeline_defaults(const sg_pipeline_desc* desc)
            sg_pass_desc sg_query_pass_defaults(const sg_pass_desc* desc)

        These functions take a pointer to a desc structure which may contain
        zero-initialized items for default values. These zero-init values
        will be replaced with their concrete values in the returned desc
        struct.


    BACKEND-SPECIFIC TOPICS:
    ========================
    --- the GL backends need to know about the internal structure of uniform
        blocks, and the texture sampler-name and -type:

            typedef struct {
                float mvp[16];      // model-view-projection matrix
                float offset0[2];   // some 2D vectors
                float offset1[2];
                float offset2[2];
            } params_t;

            // uniform block structure and texture image definition in sg_shader_desc:
            sg_shader_desc desc = {
                // uniform block description (size and internal structure)
                .vs.uniform_blocks[0] = {
                    .size = sizeof(params_t),
                    .uniforms = {
                        [0] = { .name="mvp", .type=SG_UNIFORMTYPE_MAT4 },
                        [1] = { .name="offset0", .type=SG_UNIFORMTYPE_VEC2 },
                        ...
                    }
                },
                // one texture on the fragment-shader-stage, GLES2/WebGL needs name and image type
                .fs.images[0] = { .name="tex", .type=SG_IMAGETYPE_ARRAY }
                ...
            };

    --- the Metal and D3D11 backends only need to know the size of uniform blocks,
        not their internal member structure, and they only need to know
        the type of a texture sampler, not its name:

            sg_shader_desc desc = {
                .vs.uniform_blocks[0].size = sizeof(params_t),
                .fs.images[0].type = SG_IMAGETYPE_ARRAY,
                ...
            };

    --- when creating a shader object, GLES2/WebGL need to know the vertex
        attribute names as used in the vertex shader:

            sg_shader_desc desc = {
                .attrs = {
                    [0] = { .name="position" },
                    [1] = { .name="color1" }
                }
            };

        The vertex attribute names provided when creating a shader will be
        used later in sg_create_pipeline() for matching the vertex layout
        to vertex shader inputs.

    --- on D3D11 you need to provide a semantic name and semantic index in the
        shader description struct instead (see the D3D11 documentation on
        D3D11_INPUT_ELEMENT_DESC for details):

            sg_shader_desc desc = {
                .attrs = {
                    [0] = { .sem_name="POSITION", .sem_index=0 }
                    [1] = { .sem_name="COLOR", .sem_index=1 }
                }
            };

        The provided semantic information will be used later in sg_create_pipeline()
        to match the vertex layout to vertex shader inputs.

    --- on Metal, GL 3.3 or GLES3/WebGL2, you don't need to provide an attribute
        name or semantic name, since vertex attributes can be bound by their slot index
        (this is mandatory in Metal, and optional in GL):

            sg_pipeline_desc desc = {
                .layout = {
                    .attrs = {
                        [0] = { .format=SG_VERTEXFORMAT_FLOAT3 },
                        [1] = { .format=SG_VERTEXFORMAT_FLOAT4 }
                    }
                }
            };

    WORKING WITH CONTEXTS
    =====================
    sokol-gfx allows to switch between different rendering contexts and
    associate resource objects with contexts. This is useful to
    create GL applications that render into multiple windows.

    A rendering context keeps track of all resources created while
    the context is active. When the context is destroyed, all resources
    "belonging to the context" are destroyed as well.

    A default context will be created and activated implicitly in
    sg_setup(), and destroyed in sg_shutdown(). So for a typical application
    which *doesn't* use multiple contexts, nothing changes, and calling
    the context functions isn't necessary.

    Three functions have been added to work with contexts:

    --- sg_context sg_setup_context():
        This must be called once after a GL context has been created and
        made active.

    --- void sg_activate_context(sg_context ctx)
        This must be called after making a different GL context active.
        Apart from 3D-API-specific actions, the call to sg_activate_context()
        will internally call sg_reset_state_cache().

    --- void sg_discard_context(sg_context ctx)
        This must be called right before a GL context is destroyed and
        will destroy all resources associated with the context (that
        have been created while the context was active) The GL context must be
        active at the time sg_discard_context(sg_context ctx) is called.

    Also note that resources (buffers, images, shaders and pipelines) must
    only be used or destroyed while the same GL context is active that
    was also active while the resource was created (an exception is
    resource sharing on GL, such resources can be used while
    another context is active, but must still be destroyed under
    the same context that was active during creation).

    For more information, check out the multiwindow-glfw sample:

    https://github.com/floooh/sokol-samples/blob/master/glfw/multiwindow-glfw.c

    TRACE HOOKS:
    ============
    sokol_gfx.h optionally allows to install "trace hook" callbacks for
    each public API functions. When a public API function is called, and
    a trace hook callback has been installed for this function, the
    callback will be invoked with the parameters and result of the function.
    This is useful for things like debugging- and profiling-tools, or
    keeping track of resource creation and destruction.

    To use the trace hook feature:

    --- Define SOKOL_TRACE_HOOKS before including the implementation.

    --- Setup an sg_trace_hooks structure with your callback function
        pointers (keep all function pointers you're not interested
        in zero-initialized), optionally set the user_data member
        in the sg_trace_hooks struct.

    --- Install the trace hooks by calling sg_install_trace_hooks(),
        the return value of this function is another sg_trace_hooks
        struct which contains the previously set of trace hooks.
        You should keep this struct around, and call those previous
        functions pointers from your own trace callbacks for proper
        chaining.

    As an example of how trace hooks are used, have a look at the
    imgui/sokol_gfx_imgui.h header which implements a realtime
    debugging UI for sokol_gfx.h on top of Dear ImGui.

    A NOTE ON PORTABLE PACKED VERTEX FORMATS:
    =========================================
    There are two things to consider when using packed
    vertex formats like UBYTE4, SHORT2, etc which need to work
    across all backends:

    - D3D11 can only convert *normalized* vertex formats to
      floating point during vertex fetch, normalized formats
      have a trailing 'N', and are "normalized" to a range
      -1.0..+1.0 (for the signed formats) or 0.0..1.0 (for the
      unsigned formats):

        - SG_VERTEXFORMAT_BYTE4N
        - SG_VERTEXFORMAT_UBYTE4N
        - SG_VERTEXFORMAT_SHORT2N
        - SG_VERTEXFORMAT_USHORT2N
        - SG_VERTEXFORMAT_SHORT4N
        - SG_VERTEXFORMAT_USHORT4N

      D3D11 will not convert *non-normalized* vertex formats
      to floating point vertex shader inputs, those can
      only use the ivecn formats when D3D11 is used
      as backend (GL and should Metal can use both formats)

        - SG_VERTEXFORMAT_BYTE4,
        - SG_VERTEXFORMAT_UBYTE4
        - SG_VERTEXFORMAT_SHORT2
        - SG_VERTEXFORMAT_SHORT4

    - WebGL/GLES2 cannot use integer vertex shader inputs (int or ivecn)

    - SG_VERTEXFORMAT_UINT10_N2 is not supported on WebGL/GLES2

    So for a vertex input layout which works on all platforms, only use the following
    vertex formats, and if needed "expand" the normalized vertex shader
    inputs in the vertex shader by multiplying with 127.0, 255.0, 32767.0 or
    65535.0:

        - SG_VERTEXFORMAT_FLOAT,
        - SG_VERTEXFORMAT_FLOAT2,
        - SG_VERTEXFORMAT_FLOAT3,
        - SG_VERTEXFORMAT_FLOAT4,
        - SG_VERTEXFORMAT_BYTE4N,
        - SG_VERTEXFORMAT_UBYTE4N,
        - SG_VERTEXFORMAT_SHORT2N,
        - SG_VERTEXFORMAT_USHORT2N
        - SG_VERTEXFORMAT_SHORT4N,
        - SG_VERTEXFORMAT_USHORT4N

    TODO:
    ====
    - talk about asynchronous resource creation

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
#end

'//-------------------------

#rem
    Resource id typedefs:

    sg_buffer:      vertex- and index-buffers
    sg_image:       textures and render targets
    sg_shader:      vertex- and fragment-shaders, uniform blocks
    sg_pipeline:    associated shader and vertex-layouts, and render states
    sg_pass:        a bundle of render targets and actions on them
    sg_context:     a 'context handle' for switching between 3D-API contexts

    Instead of pointers, resource creation functions return a 32-bit
    number which uniquely identifies the resource object.

    The 32-bit resource id is split into a 16-bit pool index in the lower bits,
    and a 16-bit 'unique counter' in the upper bits. The index allows fast
    pool lookups, and combined with the unique-mask it allows to detect
    'dangling accesses' (trying to use an object which no longer exists, and
    its pool slot has been reused for a new object)

    The resource ids are wrapped into a struct so that the compiler
    can complain when the wrong resource type is used.
#end
struct sg_buffer
end
struct sg_image
end
struct sg_shader
end
struct sg_pipeline
end
struct sg_pass
end
struct sg_context
end

#rem
    various compile-time constants

    FIXME: it may make sense to convert some of those into defines so
    that the user code can override them.
#end
const SG_INVALID_ID:int				'= 0,
const SG_NUM_SHADER_STAGES:int		'= 2,
const SG_NUM_INFLIGHT_FRAMES:int		'= 2,
const SG_MAX_COLOR_ATTACHMENTS:int	'= 4,
const SG_MAX_SHADERSTAGE_BUFFERS:int	'= 8,
const SG_MAX_SHADERSTAGE_IMAGES:int	'= 12,
const SG_MAX_SHADERSTAGE_UBS:int		'= 4,
const SG_MAX_UB_MEMBERS:int			'= 16,
const SG_MAX_VERTEX_ATTRIBUTES:int	'= 16,      /* NOTE: actual max vertex attrs can be less on GLES2, see sg_limits! */
const SG_MAX_MIPMAPS:int				'= 16,
const SG_MAX_TEXTUREARRAY_LAYERS:int	'= 128


#rem
    sg_backend

    The active 3D-API backend, use the function sg_query_backend()
    to get the currently active backend.

    For returned value corresponds with the compile-time define to select
    a backend, with the only exception of SOKOL_GLES3: this may
    return SG_BACKEND_GLES2 if the backend has to fallback to GLES2 mode
    because GLES3 isn't supported.
#end
enum sg_backend
end
const SG_BACKEND_GLCORE33:sg_backend
const SG_BACKEND_GLES2:sg_backend
const SG_BACKEND_GLES3:sg_backend
const SG_BACKEND_D3D11:sg_backend
const SG_BACKEND_METAL_IOS:sg_backend
const SG_BACKEND_METAL_MACOS:sg_backend
const SG_BACKEND_METAL_SIMULATOR:sg_backend
const SG_BACKEND_DUMMY:sg_backend


#rem
    sg_pixel_format

    sokol_gfx.h basically uses the same pixel formats as WebGPU, since these
    are supported on most newer GPUs. GLES2 and WebGL has a much smaller
    subset of available pixel formats. Call sg_query_pixelformat() to check
    at runtime if a pixel format supports the desired features.

    A pixelformat name consist of three parts:

        - components (R, RG, RGB or RGBA)
        - bit width per component (8, 16 or 32)
        - component data type:
            - unsigned normalized (no postfix)
            - signed normalized (SN postfix)
            - unsigned integer (UI postfix)
            - signed integer (SI postfix)
            - float (F postfix)

    Not all pixel formats can be used for everything, call sg_query_pixelformat()
    to inspect the capabilities of a given pixelformat. The function returns
    an sg_pixelformat_info struct with the following bool members:

        - sample: the pixelformat can be sampled as texture at least with
                  nearest filtering
        - filter: the pixelformat can be samples as texture with linear
                  filtering
        - render: the pixelformat can be used for render targets
        - blend:  blending is supported when using the pixelformat for
                  render targets
        - msaa:   multisample-antiliasing is supported when using the
                  pixelformat for render targets
        - depth:  the pixelformat can be used for depth-stencil attachments

    When targeting GLES2/WebGL, the only safe formats to use
    as texture are SG_PIXELFORMAT_R8 and SG_PIXELFORMAT_RGBA8. For rendering
    in GLES2/WebGL, only SG_PIXELFORMAT_RGBA8 is safe. All other formats
    must be checked via sg_query_pixelformats().

    The default pixel format for texture images is SG_PIXELFORMAT_RGBA8.

    The default pixel format for render target images is platform-dependent:
        - for Metal and D3D11 it is SG_PIXELFORMAT_BGRA8
        - for GL backends it is SG_PIXELFORMAT_RGBA8

    This is mainly because of the default framebuffer which is setup outside
    of sokol_gfx.h. On some backends, using BGRA for the default frame buffer
    allows more efficient frame flips. For your own offscreen-render-targets,
    use whatever renderable pixel format is convenient for you.
#end
enum sg_pixel_format
end
const _SG_PIXELFORMAT_DEFAULT:sg_pixel_format	'/* value 0 reserved for default-init */
const SG_PIXELFORMAT_NONE:sg_pixel_format

const SG_PIXELFORMAT_R8:sg_pixel_format
const SG_PIXELFORMAT_R8SN:sg_pixel_format
const SG_PIXELFORMAT_R8UI:sg_pixel_format
const SG_PIXELFORMAT_R8SI:sg_pixel_format

const SG_PIXELFORMAT_R16:sg_pixel_format
const SG_PIXELFORMAT_R16SN:sg_pixel_format
const SG_PIXELFORMAT_R16UI:sg_pixel_format
const SG_PIXELFORMAT_R16SI:sg_pixel_format
const SG_PIXELFORMAT_R16F:sg_pixel_format
const SG_PIXELFORMAT_RG8:sg_pixel_format
const SG_PIXELFORMAT_RG8SN:sg_pixel_format
const SG_PIXELFORMAT_RG8UI:sg_pixel_format
const SG_PIXELFORMAT_RG8SI:sg_pixel_format

const SG_PIXELFORMAT_R32UI:sg_pixel_format
const SG_PIXELFORMAT_R32SI:sg_pixel_format
const SG_PIXELFORMAT_R32F:sg_pixel_format
const SG_PIXELFORMAT_RG16:sg_pixel_format
const SG_PIXELFORMAT_RG16SN:sg_pixel_format
const SG_PIXELFORMAT_RG16UI:sg_pixel_format
const SG_PIXELFORMAT_RG16SI:sg_pixel_format
const SG_PIXELFORMAT_RG16F:sg_pixel_format
const SG_PIXELFORMAT_RGBA8:sg_pixel_format
const SG_PIXELFORMAT_RGBA8SN:sg_pixel_format
const SG_PIXELFORMAT_RGBA8UI:sg_pixel_format
const SG_PIXELFORMAT_RGBA8SI:sg_pixel_format
const SG_PIXELFORMAT_BGRA8:sg_pixel_format
const SG_PIXELFORMAT_RGB10A2:sg_pixel_format
const SG_PIXELFORMAT_RG11B10F:sg_pixel_format

const SG_PIXELFORMAT_RG32UI:sg_pixel_format
const SG_PIXELFORMAT_RG32SI:sg_pixel_format
const SG_PIXELFORMAT_RG32F:sg_pixel_format
const SG_PIXELFORMAT_RGBA16:sg_pixel_format
const SG_PIXELFORMAT_RGBA16SN:sg_pixel_format
const SG_PIXELFORMAT_RGBA16UI:sg_pixel_format
const SG_PIXELFORMAT_RGBA16SI:sg_pixel_format
const SG_PIXELFORMAT_RGBA16F:sg_pixel_format

const SG_PIXELFORMAT_RGBA32UI:sg_pixel_format
const SG_PIXELFORMAT_RGBA32SI:sg_pixel_format
const SG_PIXELFORMAT_RGBA32F:sg_pixel_format

const SG_PIXELFORMAT_DEPTH:sg_pixel_format
const SG_PIXELFORMAT_DEPTH_STENCIL:sg_pixel_format

const SG_PIXELFORMAT_BC1_RGBA:sg_pixel_format
const SG_PIXELFORMAT_BC2_RGBA:sg_pixel_format
const SG_PIXELFORMAT_BC3_RGBA:sg_pixel_format
const SG_PIXELFORMAT_BC4_R:sg_pixel_format
const SG_PIXELFORMAT_BC4_RSN:sg_pixel_format
const SG_PIXELFORMAT_BC5_RG:sg_pixel_format
const SG_PIXELFORMAT_BC5_RGSN:sg_pixel_format
const SG_PIXELFORMAT_BC6H_RGBF:sg_pixel_format
const SG_PIXELFORMAT_BC6H_RGBUF:sg_pixel_format
const SG_PIXELFORMAT_BC7_RGBA:sg_pixel_format
const SG_PIXELFORMAT_PVRTC_RGB_2BPP:sg_pixel_format
const SG_PIXELFORMAT_PVRTC_RGB_4BPP:sg_pixel_format
const SG_PIXELFORMAT_PVRTC_RGBA_2BPP:sg_pixel_format
const SG_PIXELFORMAT_PVRTC_RGBA_4BPP:sg_pixel_format
const SG_PIXELFORMAT_ETC2_RGB8:sg_pixel_format
const SG_PIXELFORMAT_ETC2_RGB8A1:sg_pixel_format
const SG_PIXELFORMAT_ETC2_RGBA8:sg_pixel_format
const SG_PIXELFORMAT_ETC2_RG11:sg_pixel_format
const SG_PIXELFORMAT_ETC2_RG11SN:sg_pixel_format

const _SG_PIXELFORMAT_NUM:sg_pixel_format
const _SG_PIXELFORMAT_FORCE_U32:sg_pixel_format

#rem
	Runtime information about a pixel format, returned 
	by sg_query_pixelformat().
#end
struct sg_pixelformat_info
	field sample:bool	'/* pixel format can be sampled in shaders */
	field filter:bool	'/* pixel format can be sampled with filtering */
	field render:bool	'/* pixel format can be used as render target */
	field blend:bool	'/* alpha-blending is supported */
	field msaa:bool		'/* pixel format can be used as MSAA render target */
	field depth:bool	'/* pixel format is a depth format */
end

#rem 
	Runtime information about available optional features, 
	returned by sg_query_features().
#end
struct sg_features
	field instancing:bool
	field origin_top_left:bool
	field multiple_render_targets:bool
	field msaa_render_targets:bool
	field imagetype_3d:bool			'/* creation of SG_IMAGETYPE_3D images is supported */
	field imagetype_array:bool		'/* creation of SG_IMAGETYPE_ARRAY images is supported */
	field image_clamp_to_border:bool '/* border color and clamp-to-border UV-wrap mode is supported */
end

#rem 
	Runtime information about resource limits, returned by sg_query_limit()
#end
struct sg_limits
	field max_image_size_2d:uint			'/* max width/height of SG_IMAGETYPE_2D images */
	field max_image_size_cube:uint		'/* max width/height of SG_IMAGETYPE_CUBE images */
	field max_image_size_3d:uint			'/* max width/height/depth of SG_IMAGETYPE_3D images */
	field max_image_size_array:uint
	field max_image_array_layers:uint
	field max_vertex_attrs:uint			'/* <= SG_MAX_VERTEX_ATTRIBUTES (only on some GLES2 impls) */
end

#rem
    sg_resource_state

    The current state of a resource in its resource pool.
    Resources start in the INITIAL state, which means the
    pool slot is unoccupied and can be allocated. When a resource is
    created, first an id is allocated, and the resource pool slot
    is set to state ALLOC. After allocation, the resource is
    initialized, which may result in the VALID or FAILED state. The
    reason why allocation and initialization are separate is because
    some resource types (e.g. buffers and images) might be asynchronously
    initialized by the user application. If a resource which is not
    in the VALID state is attempted to be used for rendering, rendering
    operations will silently be dropped.

    The special INVALID state is returned in sg_query_xxx_state() if no
    resource object exists for the provided resource id.
#end
enum sg_resource_state
end
const SG_RESOURCESTATE_INITIAL:sg_resource_state
const SG_RESOURCESTATE_ALLOC:sg_resource_state
const SG_RESOURCESTATE_VALID:sg_resource_state
const SG_RESOURCESTATE_FAILED:sg_resource_state
const SG_RESOURCESTATE_INVALID:sg_resource_state
const _SG_RESOURCESTATE_FORCE_U32:sg_resource_state

#rem
    sg_usage

    A resource usage hint describing the update strategy of
    buffers and images. This is used in the sg_buffer_desc.usage
    and sg_image_desc.usage members when creating buffers
    and images:

    SG_USAGE_IMMUTABLE:     the resource will never be updated with
                            new data, instead the data content of the
                            resource must be provided on creation
    SG_USAGE_DYNAMIC:       the resource will be updated infrequently
                            with new data (this could range from "once
                            after creation", to "quite often but not
                            every frame")
    SG_USAGE_STREAM:        the resource will be updated each frame
                            with new content

    The rendering backends use this hint to prevent that the
    CPU needs to wait for the GPU when attempting to update
    a resource that might be currently accessed by the GPU.

    Resource content is updated with the function sg_update_buffer() for
    buffer objects, and sg_update_image() for image objects. Only
    one update is allowed per frame and resource object. The
    application must update all data required for rendering (this
    means that the update data can be smaller than the resource size,
    if only a part of the overall resource size is used for rendering,
    you only need to make sure that the data that *is* used is valid.

    The default usage is SG_USAGE_IMMUTABLE.
#end
enum sg_usage
end
const _SG_USAGE_DEFAULT:sg_usage		'/* value 0 reserved for default-init */
const SG_USAGE_IMMUTABLE:sg_usage
const SG_USAGE_DYNAMIC:sg_usage
const SG_USAGE_STREAM:sg_usage
const _SG_USAGE_NUM:sg_usage
const _SG_USAGE_FORCE_U32:sg_usage

#rem
    sg_buffer_type

    This indicates whether a buffer contains vertex- or index-data,
    used in the sg_buffer_desc.type member when creating a buffer.

    The default value is SG_BUFFERTYPE_VERTEXBUFFER.
#end
enum sg_buffer_type
end
const _SG_BUFFERTYPE_DEFAULT:sg_buffer_type			'/* value 0 reserved for default-init */
const SG_BUFFERTYPE_VERTEXBUFFER:sg_buffer_type
const SG_BUFFERTYPE_INDEXBUFFER:sg_buffer_type
const _SG_BUFFERTYPE_NUM:sg_buffer_type
const _SG_BUFFERTYPE_FORCE_U32:sg_buffer_type

#rem
    sg_index_type

    Indicates whether indexed rendering (fetching vertex-indices from an
    index buffer) is used, and if yes, the index data type (16- or 32-bits).
    This is used in the sg_pipeline_desc.index_type member when creating a
    pipeline object.

    The default index type is SG_INDEXTYPE_NONE.
#end
enum sg_index_type
end
const _SG_INDEXTYPE_DEFAULT:sg_index_type	'/* value 0 reserved for default-init */
const SG_INDEXTYPE_NONE:sg_index_type
const SG_INDEXTYPE_UINT16:sg_index_type
const SG_INDEXTYPE_UINT32:sg_index_type
const _SG_INDEXTYPE_NUM:sg_index_type
const _SG_INDEXTYPE_FORCE_U32:sg_index_type

#rem
    sg_image_type

    Indicates the basic image type (2D-texture, cubemap, 3D-texture
    or 2D-array-texture). 3D- and array-textures are not supported
    on the GLES2/WebGL backend. The image type is used in the
    sg_image_desc.type member when creating an image.

    The default image type when creating an image is SG_IMAGETYPE_2D.
#end
enum sg_image_type
end
const _SG_IMAGETYPE_DEFAULT:sg_image_type	'/* value 0 reserved for default-init */
const SG_IMAGETYPE_2D:sg_image_type
const SG_IMAGETYPE_CUBE:sg_image_type
const SG_IMAGETYPE_3D:sg_image_type
const SG_IMAGETYPE_ARRAY:sg_image_type
const _SG_IMAGETYPE_NUM:sg_image_type
const _SG_IMAGETYPE_FORCE_U32:sg_image_type

#rem
    sg_cube_face

    The cubemap faces. Use these as indices in the sg_image_desc.content
    array.
#end

enum sg_cube_face
end
const SG_CUBEFACE_POS_X:sg_cube_face
const SG_CUBEFACE_NEG_X:sg_cube_face
const SG_CUBEFACE_POS_Y:sg_cube_face
const SG_CUBEFACE_NEG_Y:sg_cube_face
const SG_CUBEFACE_POS_Z:sg_cube_face
const SG_CUBEFACE_NEG_Z:sg_cube_face
const SG_CUBEFACE_NUM:sg_cube_face
const _SG_CUBEFACE_FORCE_U32:sg_cube_face

#rem
    sg_shader_stage

    There are 2 shader stages: vertex- and fragment-shader-stage.
    Each shader stage consists of:

    - one slot for a shader function (provided as source- or byte-code)
    - SG_MAX_SHADERSTAGE_UBS slots for uniform blocks
    - SG_MAX_SHADERSTAGE_IMAGES slots for images used as textures by
      the shader function
#end
enum sg_shader_stage
end
const SG_SHADERSTAGE_VS:sg_shader_stage
const SG_SHADERSTAGE_FS:sg_shader_stage
const _SG_SHADERSTAGE_FORCE_U32:sg_shader_stage

#rem
    sg_primitive_type

    This is the common subset of 3D primitive types supported across all 3D
    APIs. This is used in the sg_pipeline_desc.primitive_type member when
    creating a pipeline object.

    The default primitive type is SG_PRIMITIVETYPE_TRIANGLES.
#end
enum sg_primitive_type
end
const _SG_PRIMITIVETYPE_DEFAULT:sg_primitive_type	'/* value 0 reserved for default-init */
const SG_PRIMITIVETYPE_POINTS:sg_primitive_type
const SG_PRIMITIVETYPE_LINES:sg_primitive_type
const SG_PRIMITIVETYPE_LINE_STRIP:sg_primitive_type
const SG_PRIMITIVETYPE_TRIANGLES:sg_primitive_type
const SG_PRIMITIVETYPE_TRIANGLE_STRIP:sg_primitive_type
const _SG_PRIMITIVETYPE_NUM:sg_primitive_type
const _SG_PRIMITIVETYPE_FORCE_U32:sg_primitive_type

#rem
    sg_filter

    The filtering mode when sampling a texture image. This is
    used in the sg_image_desc.min_filter and sg_image_desc.mag_filter
    members when creating an image object.

    The default filter mode is SG_FILTER_NEAREST.
#end
enum sg_filter
end
const _SG_FILTER_DEFAULT:sg_filter '/* value 0 reserved for default-init */
const SG_FILTER_NEAREST:sg_filter
const SG_FILTER_LINEAR:sg_filter
const SG_FILTER_NEAREST_MIPMAP_NEAREST:sg_filter
const SG_FILTER_NEAREST_MIPMAP_LINEAR:sg_filter
const SG_FILTER_LINEAR_MIPMAP_NEAREST:sg_filter
const SG_FILTER_LINEAR_MIPMAP_LINEAR:sg_filter
const _SG_FILTER_NUM:sg_filter
const _SG_FILTER_FORCE_U32:sg_filter

#rem
    sg_wrap

    The texture coordinates wrapping mode when sampling a texture
    image. This is used in the sg_image_desc.wrap_u, .wrap_v
    and .wrap_w members when creating an image.

    The default wrap mode is SG_WRAP_REPEAT.

    NOTE: SG_WRAP_CLAMP_TO_BORDER is not supported on all backends
    and platforms. To check for support, call sg_query_features()
    and check the "clamp_to_border" boolean in the returned
    sg_features struct.

    Platforms which don't support SG_WRAP_CLAMP_TO_BORDER will silently fall back
    to SG_WRAP_CLAMP_TO_EDGE without a validation error.

    Platforms which support clamp-to-border are:

        - all desktop GL platforms
        - Metal on macOS
        - D3D11

    Platforms which do not support clamp-to-border:

        - GLES2/3 and WebGL/WebGL2
        - Metal on iOS
#end
enum sg_wrap
end
const _SG_WRAP_DEFAULT:sg_wrap	'/* value 0 reserved for default-init */
const SG_WRAP_REPEAT:sg_wrap
const SG_WRAP_CLAMP_TO_EDGE:sg_wrap
const SG_WRAP_CLAMP_TO_BORDER:sg_wrap
const SG_WRAP_MIRRORED_REPEAT:sg_wrap
const _SG_WRAP_NUM:sg_wrap
const _SG_WRAP_FORCE_U32:sg_wrap

#rem
    sg_border_color

    The border color to use when sampling a texture, and the UV wrap
    mode is SG_WRAP_CLAMP_TO_BORDER.

    The default border color is SG_BORDERCOLOR_OPAQUE_BLACK
#end
enum sg_border_color
end
const _SG_BORDERCOLOR_DEFAULT:sg_border_color	'/* value 0 reserved for default-init */
const SG_BORDERCOLOR_TRANSPARENT_BLACK:sg_border_color
const SG_BORDERCOLOR_OPAQUE_BLACK:sg_border_color
const SG_BORDERCOLOR_OPAQUE_WHITE:sg_border_color
const _SG_BORDERCOLOR_NUM:sg_border_color
const _SG_BORDERCOLOR_FORCE_U32:sg_border_color

#rem
    sg_vertex_format

    The data type of a vertex component. This is used to describe
    the layout of vertex data when creating a pipeline object.
#end
enum sg_vertex_format
end
const SG_VERTEXFORMAT_INVALID:sg_vertex_format
const SG_VERTEXFORMAT_FLOAT:sg_vertex_format
const SG_VERTEXFORMAT_FLOAT2:sg_vertex_format
const SG_VERTEXFORMAT_FLOAT3:sg_vertex_format
const SG_VERTEXFORMAT_FLOAT4:sg_vertex_format
const SG_VERTEXFORMAT_BYTE4:sg_vertex_format
const SG_VERTEXFORMAT_BYTE4N:sg_vertex_format
const SG_VERTEXFORMAT_UBYTE4:sg_vertex_format
const SG_VERTEXFORMAT_UBYTE4N:sg_vertex_format
const SG_VERTEXFORMAT_SHORT2:sg_vertex_format
const SG_VERTEXFORMAT_SHORT2N:sg_vertex_format
const SG_VERTEXFORMAT_USHORT2N:sg_vertex_format
const SG_VERTEXFORMAT_SHORT4:sg_vertex_format
const SG_VERTEXFORMAT_SHORT4N:sg_vertex_format
const SG_VERTEXFORMAT_USHORT4N:sg_vertex_format
const SG_VERTEXFORMAT_UINT10_N2:sg_vertex_format
const _SG_VERTEXFORMAT_NUM:sg_vertex_format
const _SG_VERTEXFORMAT_FORCE_U32:sg_vertex_format

#rem
    sg_vertex_step

    Defines whether the input pointer of a vertex input stream is advanced
    'per vertex' or 'per instance'. The default step-func is
    SG_VERTEXSTEP_PER_VERTEX. SG_VERTEXSTEP_PER_INSTANCE is used with
    instanced-rendering.

    The vertex-step is part of the vertex-layout definition
    when creating pipeline objects.
#end
enum sg_vertex_step
end
const _SG_VERTEXSTEP_DEFAULT:sg_vertex_step		'/* value 0 reserved for default-init */
const SG_VERTEXSTEP_PER_VERTEX:sg_vertex_step
const SG_VERTEXSTEP_PER_INSTANCE:sg_vertex_step
const _SG_VERTEXSTEP_NUM:sg_vertex_step
const _SG_VERTEXSTEP_FORCE_U32:sg_vertex_step

#rem
    sg_uniform_type

    The data type of a uniform block member. This is used to
    describe the internal layout of uniform blocks when creating
    a shader object.
#end
enum sg_uniform_type
end
const SG_UNIFORMTYPE_INVALID:sg_uniform_type
const SG_UNIFORMTYPE_FLOAT:sg_uniform_type
const SG_UNIFORMTYPE_FLOAT2:sg_uniform_type
const SG_UNIFORMTYPE_FLOAT3:sg_uniform_type
const SG_UNIFORMTYPE_FLOAT4:sg_uniform_type
const SG_UNIFORMTYPE_MAT4:sg_uniform_type
const _SG_UNIFORMTYPE_NUM:sg_uniform_type
const _SG_UNIFORMTYPE_FORCE_U32:sg_uniform_type

#rem
    sg_cull_mode

    The face-culling mode, this is used in the
    sg_pipeline_desc.rasterizer.cull_mode member when creating a
    pipeline object.

    The default cull mode is SG_CULLMODE_NONE
#end
enum sg_cull_mode
end
const _SG_CULLMODE_DEFAULT:sg_cull_mode	'/* value 0 reserved for default-init */
const SG_CULLMODE_NONE:sg_cull_mode
const SG_CULLMODE_FRONT:sg_cull_mode
const SG_CULLMODE_BACK:sg_cull_mode
const _SG_CULLMODE_NUM:sg_cull_mode
const _SG_CULLMODE_FORCE_U32:sg_cull_mode

#rem
    sg_face_winding

    The vertex-winding rule that determines a front-facing primitive. This
    is used in the member sg_pipeline_desc.rasterizer.face_winding
    when creating a pipeline object.

    The default winding is SG_FACEWINDING_CW (clockwise)
#end
enum sg_face_winding
end
const _SG_FACEWINDING_DEFAULT:sg_face_winding	'/* value 0 reserved for default-init */
const SG_FACEWINDING_CCW:sg_face_winding
const SG_FACEWINDING_CW:sg_face_winding
const _SG_FACEWINDING_NUM:sg_face_winding
const _SG_FACEWINDING_FORCE_U32:sg_face_winding

#rem
    sg_compare_func

    The compare-function for depth- and stencil-ref tests.
    This is used when creating pipeline objects in the members:

    sg_pipeline_desc
        .depth_stencil
            .depth_compare_func
            .stencil_front.compare_func
            .stencil_back.compare_func

    The default compare func for depth- and stencil-tests is
    SG_COMPAREFUNC_ALWAYS.
#end
enum sg_compare_func
end
const _SG_COMPAREFUNC_DEFAULT:sg_compare_func	'/* value 0 reserved for default-init */
const SG_COMPAREFUNC_NEVER:sg_compare_func
const SG_COMPAREFUNC_LESS:sg_compare_func
const SG_COMPAREFUNC_EQUAL:sg_compare_func
const SG_COMPAREFUNC_LESS_EQUAL:sg_compare_func
const SG_COMPAREFUNC_GREATER:sg_compare_func
const SG_COMPAREFUNC_NOT_EQUAL:sg_compare_func
const SG_COMPAREFUNC_GREATER_EQUAL:sg_compare_func
const SG_COMPAREFUNC_ALWAYS:sg_compare_func
const _SG_COMPAREFUNC_NUM:sg_compare_func
const _SG_COMPAREFUNC_FORCE_U32:sg_compare_func

#rem
    sg_stencil_op

    The operation performed on a currently stored stencil-value when a
    comparison test passes or fails. This is used when creating a pipeline
    object in the members:

    sg_pipeline_desc
        .depth_stencil
            .stencil_front
                .fail_op
                .depth_fail_op
                .pass_op
            .stencil_back
                .fail_op
                .depth_fail_op
                .pass_op

    The default value is SG_STENCILOP_KEEP.
#end
enum sg_stencil_op
end
const _SG_STENCILOP_DEFAULT:sg_stencil_op		'/* value 0 reserved for default-init */
const SG_STENCILOP_KEEP:sg_stencil_op
const SG_STENCILOP_ZERO:sg_stencil_op
const SG_STENCILOP_REPLACE:sg_stencil_op
const SG_STENCILOP_INCR_CLAMP:sg_stencil_op
const SG_STENCILOP_DECR_CLAMP:sg_stencil_op
const SG_STENCILOP_INVERT:sg_stencil_op
const SG_STENCILOP_INCR_WRAP:sg_stencil_op
const SG_STENCILOP_DECR_WRAP:sg_stencil_op
const _SG_STENCILOP_NUM:sg_stencil_op
const _SG_STENCILOP_FORCE_U32:sg_stencil_op

#rem
    sg_blend_factor

    The source and destination factors in blending operations.
    This is used in the following members when creating a pipeline object:

    sg_pipeline_desc
        .blend
            .src_factor_rgb
            .dst_factor_rgb
            .src_factor_alpha
            .dst_factor_alpha

    The default value is SG_BLENDFACTOR_ONE for source
    factors, and SG_BLENDFACTOR_ZERO for destination factors.
#end
enum sg_blend_factor
end
const _SG_BLENDFACTOR_DEFAULT:sg_blend_factor	'/* value 0 reserved for default-init */
const SG_BLENDFACTOR_ZERO:sg_blend_factor
const SG_BLENDFACTOR_ONE:sg_blend_factor
const SG_BLENDFACTOR_SRC_COLOR:sg_blend_factor
const SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR:sg_blend_factor
const SG_BLENDFACTOR_SRC_ALPHA:sg_blend_factor
const SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA:sg_blend_factor
const SG_BLENDFACTOR_DST_COLOR:sg_blend_factor
const SG_BLENDFACTOR_ONE_MINUS_DST_COLOR:sg_blend_factor
const SG_BLENDFACTOR_DST_ALPHA:sg_blend_factor
const SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA:sg_blend_factor
const SG_BLENDFACTOR_SRC_ALPHA_SATURATED:sg_blend_factor
const SG_BLENDFACTOR_BLEND_COLOR:sg_blend_factor
const SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR:sg_blend_factor
const SG_BLENDFACTOR_BLEND_ALPHA:sg_blend_factor
const SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA:sg_blend_factor
const _SG_BLENDFACTOR_NUM:sg_blend_factor
const _SG_BLENDFACTOR_FORCE_U32:sg_blend_factor

#rem
    sg_blend_op

    Describes how the source and destination values are combined in the
    fragment blending operation. It is used in the following members when
    creating a pipeline object:

    sg_pipeline_desc
        .blend
            .op_rgb
            .op_alpha

    The default value is SG_BLENDOP_ADD.
#end
enum sg_blend_op
end
const _SG_BLENDOP_DEFAULT:sg_blend_op	'/* value 0 reserved for default-init */
const SG_BLENDOP_ADD:sg_blend_op
const SG_BLENDOP_SUBTRACT:sg_blend_op
const SG_BLENDOP_REVERSE_SUBTRACT:sg_blend_op
const _SG_BLENDOP_NUM:sg_blend_op
const _SG_BLENDOP_FORCE_U32:sg_blend_op

#rem
    sg_color_mask

    Selects the color channels when writing a fragment color to the
    framebuffer. This is used in the members
    sg_pipeline_desc.blend.color_write_mask when creating a pipeline object.

    The default colormask is SG_COLORMASK_RGBA (write all colors channels)
#end
enum sg_color_mask
end
const _SG_COLORMASK_DEFAULT:sg_color_mask ' = 0,      '/* value 0 reserved for default-init */
const SG_COLORMASK_NONE:sg_color_mask ' = (0x10),     '/* special value for 'all channels disabled */
const SG_COLORMASK_R:sg_color_mask ' = (1<<0),
const SG_COLORMASK_G:sg_color_mask ' = (1<<1),
const SG_COLORMASK_B:sg_color_mask ' = (1<<2),
const SG_COLORMASK_A:sg_color_mask ' = (1<<3),
const SG_COLORMASK_RGB:sg_color_mask ' = 0x7,
const SG_COLORMASK_RGBA:sg_color_mask ' = 0xF,
const _SG_COLORMASK_FORCE_U32:sg_color_mask ' = 0x7FFFFFFF

#rem
    sg_action

    Defines what action should be performed at the start of a render pass:

    SG_ACTION_CLEAR:    clear the render target image
    SG_ACTION_LOAD:     load the previous content of the render target image
    SG_ACTION_DONTCARE: leave the render target image content undefined

    This is used in the sg_pass_action structure.

    The default action for all pass attachments is SG_ACTION_CLEAR, with the
    clear color rgba = {0.5f, 0.5f, 0.5f, 1.0f], depth=1.0 and stencil=0.

    If you want to override the default behaviour, it is important to not
    only set the clear color, but the 'action' field as well (as long as this
    is in its _SG_ACTION_DEFAULT, the value fields will be ignored).
#end
enum sg_action
end
const _SG_ACTION_DEFAULT:sg_action
const SG_ACTION_CLEAR:sg_action
const SG_ACTION_LOAD:sg_action
const SG_ACTION_DONTCARE:sg_action
const _SG_ACTION_NUM:sg_action
const _SG_ACTION_FORCE_U32:sg_action

#rem
    sg_pass_action

    The sg_pass_action struct defines the actions to be performed
    at the start of a rendering pass in the functions sg_begin_pass()
    and sg_begin_default_pass().

    A separate action and clear values can be defined for each
    color attachment, and for the depth-stencil attachment.

    The default clear values are defined by the macros:

    - SG_DEFAULT_CLEAR_RED:     0.5f
    - SG_DEFAULT_CLEAR_GREEN:   0.5f
    - SG_DEFAULT_CLEAR_BLUE:    0.5f
    - SG_DEFAULT_CLEAR_ALPHA:   1.0f
    - SG_DEFAULT_CLEAR_DEPTH:   1.0f
    - SG_DEFAULT_CLEAR_STENCIL: 0
#end

'// struct: sg_color_attachment_action
struct sg_color_attachment_action
	field action:sg_action
	field val:float[]
end

'// struct: sg_depth_attachment_action
struct sg_depth_attachment_action
	field action:sg_action
	field val:float
end

'// struct: sg_stencil_attachment_action
struct sg_stencil_attachment_action
	field action:sg_action
	field val:ubyte
end

'// struct: sg_pass_action
struct sg_pass_action
	field _start_canary:uint
	
	field colors:sg_color_attachment_action[] '[SG_MAX_COLOR_ATTACHMENTS]
	field depth:sg_depth_attachment_action
	field stencil:sg_stencil_attachment_action
	
	field _end_canary:uint
end

#rem
    sg_bindings

    The sg_bindings structure defines the resource binding slots
    of the sokol_gfx render pipeline, used as argument to the
    sg_apply_bindings() function.

    A resource binding struct contains:

    - 1..N vertex buffers
    - 0..N vertex buffer offsets
    - 0..1 index buffers
    - 0..1 index buffer offsets
    - 0..N vertex shader stage images
    - 0..N fragment shader stage images

    The max number of vertex buffer and shader stage images
    are defined by the SG_MAX_SHADERSTAGE_BUFFERS and
    SG_MAX_SHADERSTAGE_IMAGES configuration constants.

    The optional buffer offsets can be used to group different chunks
    of vertex- and/or index-data into the same buffer objects.
#end
struct sg_bindings
	field _start_canary:uint
	
	field vertex_buffers:sg_buffer[] '[SG_MAX_SAHDERSTAGE_BUFFERS]
	field vertex_buffer_offsets:int[] '[SG_MAX_SAHDERSTAGE_BUFFERS]
	
	field index_buffer:sg_buffer
	field index_buffer_offset:int
	
	field vs_images:sg_image[] '[SG_MAX_SHADERSTAGE_IMAGES]
	field fs_images:sg_image[] '[SG_MAX_SHADERSTAGE_IMAGES]
	
	field _end_canary:uint
end

#rem
    sg_buffer_desc

    Creation parameters for sg_buffer objects, used in the
    sg_make_buffer() call.

    The default configuration is:

    .size:      0       (this *must* be set to a valid size in bytes)
    .type:      SG_BUFFERTYPE_VERTEXBUFFER
    .usage:     SG_USAGE_IMMUTABLE
    .content    0
    .label      0       (optional string label for trace hooks)

    The dbg_label will be ignored by sokol_gfx.h, it is only useful
    when hooking into sg_make_buffer() or sg_init_buffer() via
    the sg_install_trace_hook

    ADVANCED TOPIC: Injecting native 3D-API buffers:

    The following struct members allow to inject your own GL, Metal
    or D3D11 buffers into sokol_gfx:

    .gl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .mtl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_buffer

    You must still provide all other members except the .content member, and
    these must match the creation parameters of the native buffers you
    provide. For SG_USAGE_IMMUTABLE, only provide a single native 3D-API
    buffer, otherwise you need to provide SG_NUM_INFLIGHT_FRAMES buffers
    (only for GL and Metal, not D3D11). Providing multiple buffers for GL and
    Metal is necessary because sokol_gfx will rotate through them when
    calling sg_update_buffer() to prevent lock-stalls.

    Note that it is expected that immutable injected buffer have already been
    initialized with content, and the .content member must be 0!

    Also you need to call sg_reset_state_cache() after calling native 3D-API
    functions, and before calling any sokol_gfx function.
#end
struct sg_buffer_desc
	field _start_canary:uint
	
	field size:int
	field type:sg_buffer_type
	field usage:sg_usage
	field content:void ptr
	field label:const_char_t ptr
	'/* GL specific */
	field gl_buffers:uint[] '[SG_NUM_INFLIGHT_FRAMES]
	'/* Metal specific */
	field mtl_buffers:void ptr[] '[SG_NUM_INFLIGHT_FRAMES]
	'/* D3D11 specific */
	field d3d11_buffer:void ptr
	
	field _end_canary:uint
end

#rem
    sg_subimage_content

    Pointer to and size of a subimage-surface data, this is
    used to describe the initial content of immutable-usage images,
    or for updating a dynamic- or stream-usage images.

    For 3D- or array-textures, one sg_subimage_content item
    describes an entire mipmap level consisting of all array- or
    3D-slices of the mipmap level. It is only possible to update
    an entire mipmap level, not parts of it.
#end
struct sg_subimage_content
	field ptr_:void ptr="ptr"
	field size:int
end

#rem
    sg_image_content

    Defines the content of an image through a 2D array
    of sg_subimage_content structs. The first array dimension
    is the cubemap face, and the second array dimension the
    mipmap level.
#end
struct sg_image_content
	field subimage:sg_subimage_content[][] '[SG_CUBEFACE_NUM][SG_MAX_MIPMAPS]
end

#rem
    sg_image_desc

    Creation parameters for sg_image objects, used in the
    sg_make_image() call.

    The default configuration is:

    .type:              SG_IMAGETYPE_2D
    .render_target:     false
    .width              0 (must be set to >0)
    .height             0 (must be set to >0)
    .depth/.layers:     1
    .num_mipmaps:       1
    .usage:             SG_USAGE_IMMUTABLE
    .pixel_format:      SG_PIXELFORMAT_RGBA8 for textures, backend-dependent
                        for render targets (RGBA8 or BGRA8)
    .sample_count:      1 (only used in render_targets)
    .min_filter:        SG_FILTER_NEAREST
    .mag_filter:        SG_FILTER_NEAREST
    .wrap_u:            SG_WRAP_REPEAT
    .wrap_v:            SG_WRAP_REPEAT
    .wrap_w:            SG_WRAP_REPEAT (only SG_IMAGETYPE_3D)
    .border_color       SG_BORDERCOLOR_OPAQUE_BLACK
    .max_anisotropy     1 (must be 1..16)
    .min_lod            0.0f
    .max_lod            FLT_MAX
    .content            an sg_image_content struct to define the initial content
    .label              0       (optional string label for trace hooks)

    SG_IMAGETYPE_ARRAY and SG_IMAGETYPE_3D are not supported on
    WebGL/GLES2, use sg_query_features().imagetype_array and
    sg_query_features().imagetype_3d at runtime to check
    if array- and 3D-textures are supported.

    Images with usage SG_USAGE_IMMUTABLE must be fully initialized by
    providing a valid .content member which points to
    initialization data.

    ADVANCED TOPIC: Injecting native 3D-API textures:

    The following struct members allow to inject your own GL, Metal
    or D3D11 textures into sokol_gfx:

    .gl_textures[SG_NUM_INFLIGHT_FRAMES]
    .mtl_textures[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_texture

    The same rules apply as for injecting native buffers
    (see sg_buffer_desc documentation for more details).
#end
struct sg_image_desc
	field _start_canary:uint
	
	field type:sg_image_type
	field render_target:bool
	
	field width:int
	field height:int
	
	field depth_layers:int 'union { int depth, int layers }
	
	field num_mipmaps:int
	field usage:sg_usage
	field pixel_format:sg_pixel_format
	field sample_count:int
	
	field min_filter:sg_filter
	field mag_filter:sg_filter
	
	field wrap_u:sg_wrap
	field wrap_v:sg_wrap
	field wrap_w:sg_wrap
	
	field border_color:sg_border_color
	
	field max_anisotropy:uint
	
	field min_lod:float
	field max_lod:float
	
	field content:sg_image_content
	
	field label:const_char_t ptr
	
	'/* GL specific */
	field gl_textures:uint[] '[SG_NUM_INFLIGHT_FRAMES]
	'/* Metal specific */
	field mtl_textures:void ptr[] '[SG_NUM_INFLIGHT_FRAMES]
	'/* D3D11 specific */
	field d3d11_texture:void ptr
	
	field _end_canary:uint
end

#rem
    sg_shader_desc

    The structure sg_shader_desc defines all creation parameters
    for shader programs, used as input to the sg_make_shader() function:

    - reflection information for vertex attributes (vertex shader inputs):
        - vertex attribute name (required for GLES2, optional for GLES3 and GL)
        - a semantic name and index (required for D3D11)
    - for each vertex- and fragment-shader-stage:
        - the shader source or bytecode
        - an optional entry function name
        - reflection info for each uniform block used by the shader stage:
            - the size of the uniform block in bytes
            - reflection info for each uniform block member (only required for GL backends):
                - member name
                - member type (SG_UNIFORMTYPE_xxx)
                - if the member is an array, the number of array items
        - reflection info for the texture images used by the shader stage:
            - the image type (SG_IMAGETYPE_xxx)
            - the name of the texture sampler (required for GLES2, optional everywhere else)

    For all GL backends, shader source-code must be provided. For D3D11 and Metal,
    either shader source-code or byte-code can be provided.

    For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
    on demand. If this fails, shader creation will fail.
#end

'// struct: sg_shader_attr_desc
struct sg_shader_attr_desc
	field name:const_char_t ptr			'/* GLSL vertex attribute name (only required for GLES2) */
	field sem_name:const_char_t ptr		'/* HLSL semantic name */
	field sem_index:int							'/* HLSL semantic index */
end

'// struct: sg_shader_uniform_desc
struct sg_shader_uniform_desc
	field name:const_char_t ptr
	field type:sg_uniform_type
	field array_count:int
end

'// struct: sg_shader_uniform_block_desc
struct sg_shader_uniform_block_desc
	field size:int
	field uniforms:sg_shader_uniform_desc[] '[SG_MAX_UB_MEMBERS]
end

'// struct: sg_shader_image_desc
struct sg_shader_image_desc
	field name:const_char_t ptr
	field type:sg_image_type
end

'// struct: sg_shader_stage_desc
struct sg_shader_stage_desc
	field source:const_char_t ptr
	field byte_code:ubyte ptr
	field byte_code_size:int
	field entry:const_char_t ptr
	field uniform_blocks:sg_shader_uniform_block_desc[] '[SG_MAX_SHADERSTAGE_UBS]
	field images:sg_shader_image_desc[] '[SG_MAX_SHADERSTAGE_IMAGES]
end

'// struct: sg_shader_desc
struct sg_shader_desc
	field _start_canary:uint
	
	field attrs:sg_shader_attr_desc[] '[SG_MAX_VERTEX_ATTRIBUTES]
	field vs:sg_shader_stage_desc
	field fs:sg_shader_stage_desc
	field label:const_char_t ptr
	
	field _end_canary:uint
end

#rem
    sg_pipeline_desc

    The sg_pipeline_desc struct defines all creation parameters
    for an sg_pipeline object, used as argument to the
    sg_make_pipeline() function:

    - the vertex layout for all input vertex buffers
    - a shader object
    - the 3D primitive type (points, lines, triangles, ...)
    - the index type (none, 16- or 32-bit)
    - depth-stencil state
    - alpha-blending state
    - rasterizer state

    If the vertex data has no gaps between vertex components, you can omit
    the .layout.buffers[].stride and layout.attrs[].offset items (leave them
    default-initialized to 0), sokol will then compute the offsets and strides
    from the vertex component formats (.layout.attrs[].offset). Please note
    that ALL vertex attribute offsets must be 0 in order for the the
    automatic offset computation to kick in.

    The default configuration is as follows:

    .layout:
        .buffers[]:         vertex buffer layouts
            .stride:        0 (if no stride is given it will be computed)
            .step_func      SG_VERTEXSTEP_PER_VERTEX
            .step_rate      1
        .attrs[]:           vertex attribute declarations
            .buffer_index   0 the vertex buffer bind slot
            .offset         0 (offsets can be omitted if the vertex layout has no gaps)
            .format         SG_VERTEXFORMAT_INVALID (must be initialized!)
    .shader:            0 (must be intilized with a valid sg_shader id!)
    .primitive_type:    SG_PRIMITIVETYPE_TRIANGLES
    .index_type:        SG_INDEXTYPE_NONE
    .depth_stencil:
        .stencil_front, .stencil_back:
            .fail_op:               SG_STENCILOP_KEEP
            .depth_fail_op:         SG_STENCILOP_KEEP
            .pass_op:               SG_STENCILOP_KEEP
            .compare_func           SG_COMPAREFUNC_ALWAYS
        .depth_compare_func:    SG_COMPAREFUNC_ALWAYS
        .depth_write_enabled:   false
        .stencil_enabled:       false
        .stencil_read_mask:     0
        .stencil_write_mask:    0
        .stencil_ref:           0
    .blend:
        .enabled:               false
        .src_factor_rgb:        SG_BLENDFACTOR_ONE
        .dst_factor_rgb:        SG_BLENDFACTOR_ZERO
        .op_rgb:                SG_BLENDOP_ADD
        .src_factor_alpha:      SG_BLENDFACTOR_ONE
        .dst_factor_alpha:      SG_BLENDFACTOR_ZERO
        .op_alpha:              SG_BLENDOP_ADD
        .color_write_mask:      SG_COLORMASK_RGBA
        .color_attachment_count 1
        .color_format           SG_PIXELFORMAT_RGBA8
        .depth_format           SG_PIXELFORMAT_DEPTHSTENCIL
        .blend_color:           { 0.0f, 0.0f, 0.0f, 0.0f }
    .rasterizer:
        .alpha_to_coverage_enabled:     false
        .cull_mode:                     SG_CULLMODE_NONE
        .face_winding:                  SG_FACEWINDING_CW
        .sample_count:                  1
        .depth_bias:                    0.0f
        .depth_bias_slope_scale:        0.0f
        .depth_bias_clamp:              0.0f
    .label  0       (optional string label for trace hooks)
#end

'// struct: sg_buffer_layout_desc
struct sg_buffer_layout_desc
	field stride:int
	field step_func:sg_vertex_step
	field step_rate:int
end

'// struct: sg_vertex_attr_desc
struct sg_vertex_attr_desc
	field buffer_index:int
	field offset:int
	field format:sg_vertex_format
end

'// struct: sg_layout_desc
struct sg_layout_desc
	field buffers:sg_buffer_layout_desc[] '[SG_MAX_SHADERSTAGE_BUFFERS]
	field attrs:sg_vertex_attr_desc[] '[SG_MAX_VERTEX_ATTRIBUTES]
end

'// struct: sg_stencil_state
struct sg_stencil_state
	field fail_op:sg_stencil_op
	field depth_fail_op:sg_stencil_op
	field pass_op:sg_stencil_op
	field compare_func:sg_compare_func
end

'// struct: sg_depth_stencil_state
struct sg_depth_stencil_state
	field stencil_front:sg_stencil_state
	field stencil_back:sg_stencil_state
	field depth_compare_func:sg_compare_func
	field depth_write_enabled:bool
	field stencil_enabled:bool
	field stencil_read_mask:ubyte
	field stencil_write_mask:ubyte
	field stencil_ref:ubyte
end

'// struct: sg_blend_state
struct sg_blend_state
	field enabled:bool
	
	field src_factor_rgb:sg_blend_factor
	field dst_factor_rgb:sg_blend_factor
	field op_rgb:sg_blend_op
	
	field src_factor_alpha:sg_blend_factor
	field dst_factor_alpha:sg_blend_factor
	field op_alpha:sg_blend_op
	
	field color_write_mask:ubyte
	field color_attachment_count:int
	
	field color_format:sg_pixel_format
	field depth_format:sg_pixel_format
	
	field blend_color:float[] 'size=4
end

'// struct: sg_rasterizer_state
struct sg_rasterizer_state
	field alpha_to_coverage_enabled:bool
	field cull_mode:sg_cull_mode
	field face_winding:sg_face_winding
	field sample_count:int
	field depth_bias:float
	field depth_bias_slpoe_scale:float
	field depth_bias_clamp:float
end

'// struct: sg_pipeline_desc
struct sg_pipeline_desc
	field _start_canary:uint
	
	field layout:sg_layout_desc
	field shader:sg_shader
	field primitive_type:sg_primitive_type
	field index_type:sg_index_type
	field depth_stencil:sg_depth_stencil_state
	field blend:sg_blend_state
	field rasterizer:sg_rasterizer_state
	field label:const_char_t ptr
	
	field _end_canary:uint
end

#rem
    sg_pass_desc

    Creation parameters for an sg_pass object, used as argument
    to the sg_make_pass() function.

    A pass object contains 1..4 color-attachments and none, or one,
    depth-stencil-attachment. Each attachment consists of
    an image, and two additional indices describing
    which subimage the pass will render: one mipmap index, and
    if the image is a cubemap, array-texture or 3D-texture, the
    face-index, array-layer or depth-slice.

    Pass images must fulfill the following requirements:

    All images must have:
    - been created as render target (sg_image_desc.render_target = true)
    - the same size
    - the same sample count

    In addition, all color-attachment images must have the same
    pixel format.
#end

'// struct: sg_attachment_desc
struct sg_attachment_desc
	field image:sg_image
	field mip_level:int
	field u_face_layer_slice:int ' union { int face, layer, slice }
end

'// struct: sg_pass_desc
struct sg_pass_desc
	field _start_canary:uint
	
	field color_attachments:sg_attachment_desc[] '[SG_MAX_COLOR_ATTACHMENTS]
	field depth_stencil_attachment:sg_attachment_desc
	field label:const_char_t ptr
	
	field _end_canary:uint
end

#rem
    sg_trace_hooks

    Installable callback functions to keep track of the sokol_gfx calls,
    this is useful for debugging, or keeping track of resource creation
    and destruction.

    Trace hooks are installed with sg_install_trace_hooks(), this returns
    another sg_trace_hooks struct with the previous set of
    trace hook function pointers. These should be invoked by the
    new trace hooks to form a proper call chain.
#end

'// struct: sg_trace_hooks
struct sg_trace_hooks
	field user_data:void ptr
	field reset_state_cache:void(user_data:void ptr)
	field make_buffer:void(desc:sg_buffer_desc ptr, result:sg_buffer, user_data:void ptr)
	field make_image:void(desc:sg_image_desc ptr, result:sg_image, user_data:void ptr)
	field make_shader:void(desc:sg_shader_desc ptr, result:sg_shader, user_data:void ptr)
	field make_pipeline:void(desc:sg_pipeline_desc ptr, result:sg_pipeline, user_data:void ptr)
	field make_pass:void(desc:sg_pass_desc ptr, result:sg_pass, user_data:void ptr)
	field destroy_buffer:void(buf:sg_buffer, user_data:void ptr)
	field destroy_image:void(img:sg_image, user_data:void ptr)
	field destroy_shader:void(shd:sg_shader, user_data:void ptr)
	field destroy_pipeline:void(pip:sg_pipeline, user_data:void ptr)
	field destroy_pass:void(pass:sg_pass, user_data:void ptr)
	field update_buffer:void(buf:sg_buffer, data_ptr:void ptr, data_size:int, user_data:void ptr)
	field update_image:void(img:sg_image, data:sg_image_content ptr, user_data:void ptr)
	field append_buffer:void(buf:sg_buffer, data_ptr:void ptr, data_size:int, result:int, user_data:void ptr)
	field begin_default_pass:void(pass_action:sg_pass_action ptr, width:int, height:int, user_data:void ptr)
	field begin_pass:void(pass:sg_pass, pass_action:sg_pass_action ptr, user_data:void ptr)
	field apply_viewport:void(x:int, y:int, width:int, height:int, origin_top_left:bool, user_data:void ptr)
	field apply_scissor_rect:void(x:int, y:int, width:int, height:int, origin_top_left:bool, user_data:void ptr)
	field apply_pipeline:void(pip:sg_pipeline, user_data:void ptr)
	field apply_bindings:void(bindings:sg_bindings ptr, user_data:void ptr)
	field apply_uniforms:void(stage:sg_shader_stage, ub_index:int, data:void ptr, num_bytes:int, user_data:void ptr)
	field draw:void(base_element:int, num_elements:int, num_instances:int, user_data:void ptr)
	field end_pass:void(user_data:void ptr)
	field commit:void(user_data:void ptr)
	field alloc_buffer:void(result:sg_buffer, user_data:void ptr)
	field alloc_image:void(result:sg_image, user_data:void ptr)
	field alloc_shader:void(result:sg_shader, user_data:void ptr)
	field alloc_pipeline:void(result:sg_pipeline, user_data:void ptr)
	field alloc_pass:void(result:sg_pass, user_data:void ptr)
	field init_buffer:void(buf_id:sg_buffer, desc:sg_buffer_desc ptr, user_data:void ptr)
	field init_image:void(img_id:sg_image, desc:sg_image_desc ptr, user_data:void ptr)
	field init_shader:void(shd_id:sg_shader, desc:sg_shader_desc ptr, user_data:void ptr)
	field init_pipeline:void(pip_id:sg_pipeline, desc:sg_pipeline_desc ptr, user_data:void ptr)
	field init_pass:void(pass_id:sg_pass, desc:sg_pass_desc ptr, user_data:void ptr)
	field fail_buffer:void(buf_id:sg_buffer, user_data:void ptr)
	field fail_image:void(img_id:sg_image, user_data:void ptr)
	field fail_shader:void(shd_id:sg_shader, user_data:void ptr)
	field fail_pipeline:void(pip_id:sg_pipeline, user_data:void ptr)
	field fail_pass:void(pass_id:sg_pass, user_data:void ptr)
	field push_debug_group:void(name:const_char_t ptr, user_data:void ptr)
	field pop_debug_group:void(user_data:void ptr)
	field err_buffer_pool_exhausted:void(user_data:void ptr)
	field err_image_pool_exhausted:void(user_data:void ptr)
	field err_shader_pool_exhausted:void(user_data:void ptr)
	field err_pipeline_pool_exhausted:void(user_data:void ptr)
	field err_pass_pool_exhausted:void(user_data:void ptr)
	field err_context_mismatch:void(user_data:void ptr)
	field err_pass_invalid:void(user_data:void ptr)
	field err_draw_invalid:void(user_data:void ptr)
	field err_bindings_invalid:void(user_data:void ptr)
end

#rem
    sg_buffer_info
    sg_image_info
    sg_shader_info
    sg_pipeline_info
    sg_pass_info

    These structs contain various internal resource attributes which
    might be useful for debug-inspection. Please don't rely on the
    actual content of those structs too much, as they are quite closely
    tied to sokol_gfx.h internals and may change more frequently than
    the other public API elements.

    The *_info structs are used as the return values of the following functions:

    sg_query_buffer_info()
    sg_query_image_info()
    sg_query_shader_info()
    sg_query_pipeline_info()
    sg_query_pass_info()
#end

'// struct: sg_slot_info
struct sg_slot_info
	field state:sg_resource_state	'/* the current state of this resource slot */
	field res_id:uint				'/* type-neutral resource if (e.g. sg_buffer.id) */
	field ctx_id:uint				'/* the context this resource belongs to */
end

'// struct: sg_buffer_info
struct sg_buffer_info
	field slot:sg_slot_info				'/* resource pool slot info */
	field update_frame_index:uint		'/* frame index of last sg_update_buffer() */
	field append_frame_index:uint		'/* frame index of last sg_append_buffer() */
	field append_pos:int				'/* current position in buffer for sg_append_buffer() */
	field append_overflow:bool			'/* is buffer in overflow state (due to sg_append_buffer) */
	field num_slots:int					'/* number of renaming-slots for dynamically updated buffers */
	field active_slot:int				'/* currently active write-slot for dynamically updated buffers */
end

'// struct: sg_image_info
struct sg_image_info
	field slot:sg_slot_info				'/* resource pool slot info */
	field upd_frame_index:uint			'/* frame index of last sg_update_image() */
	field num_slots:int					'/* number of renaming-slots for dynamically updated images */
	field active_slot:int				'/* currently active write-slot for dynamically updated images */
end

'// struct: sg_shader_info
struct sg_shader_info
	field slot:sg_slot_info				'/* resoure pool slot info */
end

'// struct: sg_pipeline_info
struct sg_pipeline_info
	field slot:sg_slot_info				'/* resource pool slot info */
end

'// struct: sg_pass_info
struct sg_pass_info
	field slot:sg_slot_info				'/* resource pool slot info */
end

#rem
    sg_desc

    The sg_desc struct contains configuration values for sokol_gfx,
    it is used as parameter to the sg_setup() call.

    The default configuration is:

    .buffer_pool_size:      128
    .image_pool_size:       128
    .shader_pool_size:      32
    .pipeline_pool_size:    64
    .pass_pool_size:        16
    .context_pool_size:     16

    GL specific:
    .gl_force_gles2
        if this is true the GL backend will act in "GLES2 fallback mode" even
        when compiled with SOKOL_GLES3, this is useful to fall back
        to traditional WebGL if a browser doesn't support a WebGL2 context

    Metal specific:
        (NOTE: All Objective-C object references are transferred through
        a bridged (const void*) to sokol_gfx, which will use a unretained
        bridged cast (__bridged id<xxx>) to retrieve the Objective-C
        references back. Since the bridge cast is unretained, the caller
        must hold a strong reference to the Objective-C object for the
        duration of the sokol_gfx call!

    .mtl_device
        a pointer to the MTLDevice object
    .mtl_renderpass_descriptor_cb
        a C callback function to obtain the MTLRenderPassDescriptor for the
        current frame when rendering to the default framebuffer, will be called
        in sg_begin_default_pass()
    .mtl_drawable_cb
        a C callback function to obtain a MTLDrawable for the current
        frame when rendering to the default framebuffer, will be called in
        sg_end_pass() of the default pass
    .mtl_global_uniform_buffer_size
        the size of the global uniform buffer in bytes, this must be big
        enough to hold all uniform block updates for a single frame,
        the default value is 4 MByte (4 * 1024 * 1024)
    .mtl_sampler_cache_size
        the number of slots in the sampler cache, the Metal backend
        will share texture samplers with the same state in this
        cache, the default value is 64

    D3D11 specific:
    .d3d11_device
        a pointer to the ID3D11Device object, this must have been created
        before sg_setup() is called
    .d3d11_device_context
        a pointer to the ID3D11DeviceContext object
    .d3d11_render_target_view_cb
        a C callback function to obtain a pointer to the current
        ID3D11RenderTargetView object of the default framebuffer,
        this function will be called in sg_begin_pass() when rendering
        to the default framebuffer
    .d3d11_depth_stencil_view_cb
        a C callback function to obtain a pointer to the current
        ID3D11DepthStencilView object of the default framebuffer,
        this function will be called in sg_begin_pass() when rendering
        to the default framebuffer
#end

struct sg_desc
	field _start_canary:uint
	
	field buffer_pool_size:int
	field image_pool_size:int
	field shader_pool_size:int
	field pipeline_pool_size:int
	field pass_pool_size:int
	field context_pool_size:int
	'/* GL specific */
	field gl_force_gles2:bool
	'/* Metal-specific */
	field mtl_device:void ptr
	field mtl_renderpass_descriptor_cb:void ptr()
	field mtl_drawable_cb:void ptr()
	field mtl_global_uniform_buffer_size:int
	field mtl_sampler_cache_size:int
	'/* D3D11-specific */
	field d3d11_device:void ptr
	field d3d11_device_context:void ptr
	field d3d11_render_target_view_cb:void ptr()
	field d3d11_depth_stencil_view_cb:void ptr()
	
	field _end_canary:uint
end

'//-------- Functions

'/* setup and misc functions  */
function sg_setup:void(desc:sg_desc ptr)
function sg_shutdown:void()
function sg_isvalid:bool()
function sg_reset_state_cache:void()
function sg_install_trace_hooks:sg_trace_hooks(trace_hooks:sg_trace_hooks ptr)
function sg_push_debug_group:void(name:const_char_t ptr)
function sg_pop_debug_group:void()

'/* resource creation, destruction and updating  */
function sg_make_buffer:sg_buffer(desc:sg_buffer_desc ptr)
function sg_make_image:sg_image(desc:sg_image_desc ptr)
function sg_make_shader:sg_shader(desc:sg_shader_desc ptr)
function sg_make_pipeline:sg_pipeline(desc:sg_pipeline_desc ptr)
function sg_make_pass:sg_pass(desc:sg_pass_desc ptr)
function sg_destroy_buffer:void(buf:sg_buffer)
function sg_destroy_image:void(img:sg_image)
function sg_destroy_shader:void(shd:sg_shader)
function sg_destroy_pipeline:void(pip:sg_pipeline)
function sg_destroy_pass:void(pass:sg_pass)
function sg_update_buffer:void(buf:sg_buffer, data_ptr:void ptr, data_size:int)
function sg_update_image:void(img:sg_image, data:sg_image_content ptr)
function sg_append_buffer:int(buf:sg_buffer, data_ptr:void ptr, data_size:int)
function sg_query_buffer_overflow:bool(buf:sg_buffer)

'/* rendering functions  */
function sg_begin_default_pass:void(pass_action:sg_pass_action ptr , width:int, height:int)
function sg_begin_pass:void(pass:sg_pass, pass_action:sg_pass_action ptr)
function sg_apply_viewport:void(x:int, y:int, width:int, height:int, origin_top_left:bool)
function sg_apply_scissor_rect:void(x:int, y:int, width:int, height:int, origin_top_left:bool)
function sg_apply_pipeline:void(pip:sg_pipeline)
function sg_apply_bindings:void(bindings:sg_bindings ptr)
function sg_apply_uniforms:void(stage:sg_shader_stage, ub_index:int, data:void ptr, num_bytes:int)
function sg_draw:void(base_element:int, num_elements:int, num_instances:int)
function sg_end_pass:void()
function sg_commit:void()

'/* getting information  */
function sg_query_desc:sg_desc()
function sg_query_backend:sg_backend()
function sg_query_features:sg_features()
function sg_query_limits:sg_limits()
function sg_query_pixelformat:sg_pixelformat_info(fmt:sg_pixel_format)
'/* get current state of a resource (INITIAL, ALLOC, VALID, FAILED, INVALID)  */
function sg_query_buffer_state:sg_resource_state(buf:sg_buffer)
function sg_query_image_state:sg_resource_state(img:sg_image)
function sg_query_shader_state:sg_resource_state(shd:sg_shader)
function sg_query_pipeline_state:sg_resource_state(pip:sg_pipeline)
function sg_query_pass_state:sg_resource_state(pass:sg_pass)
'/* get runtime information about a resource  */
function sg_query_buffer_info:sg_buffer_info(buf:sg_buffer)
function sg_query_image_info:sg_image_info(img:sg_image)
function sg_query_shader_info:sg_shader_info(shd:sg_shader)
function sg_query_pipeline_info:sg_pipeline_info(pip:sg_pipeline)
function sg_query_pass_info:sg_pass_info(pass:sg_pass)
'/* get resource creation desc struct with their default values replaced  */
function sg_query_buffer_defaults:sg_buffer_desc(desc:sg_buffer_desc ptr)
function sg_query_image_defaults:sg_image_desc(desc:sg_image_desc ptr)
function sg_query_shader_defaults:sg_shader_desc(desc:sg_shader_desc ptr)
function sg_query_pipeline_defaults:sg_pipeline_desc(desc:sg_pipeline_desc ptr)
function sg_query_pass_defaults:sg_pass_desc(desc:sg_pass_desc ptr)

'/* separate resource allocation and initialization (for async setup)  */
function sg_alloc_buffer:sg_buffer()
function sg_alloc_image:sg_image()
function sg_alloc_shader:sg_shader()
function sg_alloc_pipeline:sg_pipeline()
function sg_alloc_pass:sg_pass()
function sg_init_buffer:void(buf_id:sg_buffer, desc:sg_buffer_desc ptr)
function sg_init_image:void(img_id:sg_image, desc:sg_image_desc ptr)
function sg_init_shader:void(shd_id:sg_shader, desc:sg_shader_desc ptr)
function sg_init_pipeline:void(pip_id:sg_pipeline, desc:sg_pipeline_desc ptr)
function sg_init_pass:void(pass_id:sg_pass, desc:sg_pass_desc ptr)
function sg_fail_buffer:void(buf_id:sg_buffer)
function sg_fail_image:void(img_id:sg_image)
function sg_fail_shader:void(shd_id:sg_shader)
function sg_fail_pipeline:void(pip_id:sg_pipeline)
function sg_fail_pass:void(pass_id:sg_pass)

'/* rendering contexts (optional)  */
function sg_setup_context:sg_context()
function sg_activate_context:void(ctx_id:sg_context)
function sg_discard_context:void(ctx_id:sg_context)





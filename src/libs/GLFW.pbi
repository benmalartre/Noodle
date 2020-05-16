; /************************************************************************
;  * GLFW - An OpenGL framework
;  * API version: 2.7
;  * WWW:         http://www.glfw.org/
;  *------------------------------------------------------------------------
;  * Copyright (c) 2002-2006 Marcus Geelnard
;  * Copyright (c) 2006-2010 Camilla Berglund
;  *
;  * This software is provided 'as-is', without any express Or implied
;  * warranty. In no event will the authors be held liable For any damages
;  * arising from the use of this software.
;  *
;  * Permission is granted To anyone To use this software For any purpose,
;  * including commercial applications, And To alter it And redistribute it
;  * freely, subject To the following restrictions:
;  *
;  * 1. The origin of this software must Not be misrepresented; you must not
;  *    claim that you wrote the original software. If you use this software
;  *    in a product, an acknowledgment in the product documentation would
;  *    be appreciated but is Not required.
;  *
;  * 2. Altered source versions must be plainly marked As such, And must Not
;  *    be misrepresented As being the original software.
;  *
;  * 3. This notice may Not be removed Or altered from any source
;  *    distribution.
;  *
;  *************************************************************************/
XIncludeFile "OpenGL.pbi"

DeclareModule GLFW
  ;UseModule OpenGL

  ; /*************************************************************************
  ;  * GLFW version 
  ;  *************************************************************************/
  
  #GLFW_VERSION_MAJOR  =  3
  #GLFW_VERSION_MINOR =   0
  #GLFW_VERSION_REVISION= 0
  
  
  ; /*************************************************************************
  ;  * Input handling definitions
  ;  *************************************************************************/
  
  ;/* Key And button state/action definitions */
  #GLFW_RELEASE =  0
  #GLFW_PRESS  =  1
  #GLFW_REPEAT = 2
  
  ;/* The unknown key */
  #GLFW_KEY_UNKNOWN           = -1
  
  ;/* Printable keys */
  #GLFW_KEY_SPACE             = 32
  #GLFW_KEY_APOSTROPHE        = 39  ;/* ' */
  #GLFW_KEY_COMMA             = 44  ;/* , */
  #GLFW_KEY_MINUS             = 45  ;/* - */
  #GLFW_KEY_PERIOD            = 46  ;/* . */
  #GLFW_KEY_SLASH             = 47  ;/* / */
  #GLFW_KEY_0                 = 48
  #GLFW_KEY_1                 = 49
  #GLFW_KEY_2                 = 50
  #GLFW_KEY_3                 = 51
  #GLFW_KEY_4                 = 52
  #GLFW_KEY_5                 = 53
  #GLFW_KEY_6                 = 54
  #GLFW_KEY_7                 = 55
  #GLFW_KEY_8                 = 56
  #GLFW_KEY_9                 = 57
  #GLFW_KEY_SEMICOLON         = 59  ;/*  */
  #GLFW_KEY_EQUAL             = 61  ;/* = */
  #GLFW_KEY_A                 = 65
  #GLFW_KEY_B                 = 66
  #GLFW_KEY_C                 = 67
  #GLFW_KEY_D                 = 68
  #GLFW_KEY_E                 = 69
  #GLFW_KEY_F                 = 70
  #GLFW_KEY_G                 = 71
  #GLFW_KEY_H                 = 72
  #GLFW_KEY_I                 = 73
  #GLFW_KEY_J                 = 74
  #GLFW_KEY_K                 = 75
  #GLFW_KEY_L                 = 76
  #GLFW_KEY_M                 = 77
  #GLFW_KEY_N                 = 78
  #GLFW_KEY_O                 = 79
  #GLFW_KEY_P                 = 80
  #GLFW_KEY_Q                 = 81
  #GLFW_KEY_R                 = 82
  #GLFW_KEY_S                 = 83
  #GLFW_KEY_T                 = 84
  #GLFW_KEY_U                 = 85
  #GLFW_KEY_V                 = 86
  #GLFW_KEY_W                 = 87
  #GLFW_KEY_X                 = 88
  #GLFW_KEY_Y                 = 89
  #GLFW_KEY_Z                 = 90
  #GLFW_KEY_LEFT_BRACKET      = 91  ;/* [ */
  #GLFW_KEY_BACKSLASH         = 92  ;/* \ */
  #GLFW_KEY_RIGHT_BRACKET     = 93  ;/* ] */
  #GLFW_KEY_GRAVE_ACCENT      = 96  ;/* ` */
  #GLFW_KEY_WORLD_1           = 161 ;/* non-US #1 */
  #GLFW_KEY_WORLD_2           = 162 ;/* non-US #2 */
  
  ;/* Function keys */
  #GLFW_KEY_ESCAPE            = 256
  #GLFW_KEY_ENTER             = 257
  #GLFW_KEY_TAB               = 258
  #GLFW_KEY_BACKSPACE         = 259
  #GLFW_KEY_INSERT            = 260
  #GLFW_KEY_DELETE            = 261
  #GLFW_KEY_RIGHT             = 262
  #GLFW_KEY_LEFT              = 263
  #GLFW_KEY_DOWN              = 264
  #GLFW_KEY_UP                = 265
  #GLFW_KEY_PAGE_UP           = 266
  #GLFW_KEY_PAGE_DOWN         = 267
  #GLFW_KEY_HOME              = 268
  #GLFW_KEY_END               = 269
  #GLFW_KEY_CAPS_LOCK         = 280
  #GLFW_KEY_SCROLL_LOCK       = 281
  #GLFW_KEY_NUM_LOCK          = 282
  #GLFW_KEY_PRINT_SCREEN      = 283
  #GLFW_KEY_PAUSE             = 284
  #GLFW_KEY_F1                = 290
  #GLFW_KEY_F2                = 291
  #GLFW_KEY_F3                = 292
  #GLFW_KEY_F4                = 293
  #GLFW_KEY_F5                = 294
  #GLFW_KEY_F6                = 295
  #GLFW_KEY_F7                = 296
  #GLFW_KEY_F8                = 297
  #GLFW_KEY_F9                = 298
  #GLFW_KEY_F10               = 299
  #GLFW_KEY_F11               = 300
  #GLFW_KEY_F12               = 301
  #GLFW_KEY_F13               = 302
  #GLFW_KEY_F14               = 303
  #GLFW_KEY_F15               = 304
  #GLFW_KEY_F16               = 305
  #GLFW_KEY_F17               = 306
  #GLFW_KEY_F18               = 307
  #GLFW_KEY_F19               = 308
  #GLFW_KEY_F20               = 309
  #GLFW_KEY_F21               = 310
  #GLFW_KEY_F22               = 311
  #GLFW_KEY_F23               = 312
  #GLFW_KEY_F24               = 313
  #GLFW_KEY_F25               = 314
  #GLFW_KEY_KP_0              = 320
  #GLFW_KEY_KP_1              = 321
  #GLFW_KEY_KP_2              = 322
  #GLFW_KEY_KP_3              = 323
  #GLFW_KEY_KP_4              = 324
  #GLFW_KEY_KP_5              = 325
  #GLFW_KEY_KP_6              = 326
  #GLFW_KEY_KP_7              = 327
  #GLFW_KEY_KP_8              = 328
  #GLFW_KEY_KP_9              = 329
  #GLFW_KEY_KP_DECIMAL        = 330
  #GLFW_KEY_KP_DIVIDE         = 331
  #GLFW_KEY_KP_MULTIPLY       = 332
  #GLFW_KEY_KP_SUBTRACT       = 333
  #GLFW_KEY_KP_ADD            = 334
  #GLFW_KEY_KP_ENTER          = 335
  #GLFW_KEY_KP_EQUAL          = 336
  #GLFW_KEY_LEFT_SHIFT        = 340
  #GLFW_KEY_LEFT_CONTROL      = 341
  #GLFW_KEY_LEFT_ALT          = 342
  #GLFW_KEY_LEFT_SUPER        = 343
  #GLFW_KEY_RIGHT_SHIFT       = 344
  #GLFW_KEY_RIGHT_CONTROL     = 345
  #GLFW_KEY_RIGHT_ALT         = 346
  #GLFW_KEY_RIGHT_SUPER       = 347
  #GLFW_KEY_MENU              = 348
  #GLFW_KEY_LAST              = #GLFW_KEY_MENU
  
  ;/* Modifiers Keys */s
  #GLFW_MOD_SHIFT           = $0001
  #GLFW_MOD_CONTROL         = $0002
  #GLFW_MOD_ALT             = $0004
  #GLFW_MOD_SUPER           = $0008
  
  ;/* Mouse button definitions */
  #GLFW_MOUSE_BUTTON_1   =    0
  #GLFW_MOUSE_BUTTON_2   =   1
  #GLFW_MOUSE_BUTTON_3   =   2
  #GLFW_MOUSE_BUTTON_4   =   3
  #GLFW_MOUSE_BUTTON_5   =   4
  #GLFW_MOUSE_BUTTON_6   =   5
  #GLFW_MOUSE_BUTTON_7   =   6
  #GLFW_MOUSE_BUTTON_8    =  7
  #GLFW_MOUSE_BUTTON_LAST  = #GLFW_MOUSE_BUTTON_8
  
  ;/* Mouse button aliases */
  #GLFW_MOUSE_BUTTON_LEFT   = #GLFW_MOUSE_BUTTON_1
  #GLFW_MOUSE_BUTTON_RIGHT  = #GLFW_MOUSE_BUTTON_2
  #GLFW_MOUSE_BUTTON_MIDDLE  = #GLFW_MOUSE_BUTTON_3
  
  
  ;/* Joystick identifiers */
  #GLFW_JOYSTICK_1   =       0
  #GLFW_JOYSTICK_2   =       1
  #GLFW_JOYSTICK_3    =      2
  #GLFW_JOYSTICK_4    =      3
  #GLFW_JOYSTICK_5    =      4
  #GLFW_JOYSTICK_6    =      5
  #GLFW_JOYSTICK_7    =      6
  #GLFW_JOYSTICK_8    =      7
  #GLFW_JOYSTICK_9    =      8
  #GLFW_JOYSTICK_10   =      9
  #GLFW_JOYSTICK_11    =     10
  #GLFW_JOYSTICK_12    =     11
  #GLFW_JOYSTICK_13    =     12
  #GLFW_JOYSTICK_14    =     13
  #GLFW_JOYSTICK_15    =     14
  #GLFW_JOYSTICK_16     =    15
  #GLFW_JOYSTICK_LAST    =   #GLFW_JOYSTICK_16
  
  ;/*************************************************************************
  ;  * Errors
  ;*************************************************************************/
  #GLFW_NOT_INITIALIZED       = $00010001
  #GLFW_NO_CURRENT_CONTEXT    = $00010002
  #GLFW_INVALID_ENUM          = $00010003
  #GLFW_INVALID_VALUE         = $00010004
  #GLFW_OUT_OF_MEMORY         = $00010005
  #GLFW_API_UNAVAILABLE       = $00010006
  #GLFW_VERSION_UNAVAILABLE   = $00010007
  #GLFW_PLATFORM_ERROR        = $00010008
  #GLFW_FORMAT_UNAVAILABLE    = $00010009
  
  ;/*************************************************************************
  ;  * Other definitions
  ;  *************************************************************************/
  
  ;/* glfwOpenWindow modes */
  #GLFW_FOCUSED              =  $00020001
  #GLFW_ICONIFIED            =  $00020002
  #GLFW_RESIZABLE            =  $00020003
  #GLFW_VISIBLE              =  $00020004
  #GLFW_DECORATED            =  $00020005
  #GLFW_AUTO_ICONIFY         =  $00020006
  #GLFW_FLOATING             =  $00020007
  
  #GLFW_RED_BITS             =  $00021001
  #GLFW_GREEN_BITS           =  $00021002
  #GLFW_BLUE_BITS            =  $00021003
  #GLFW_ALPHA_BITS           =  $00021004
  #GLFW_DEPTH_BITS           =  $00021005
  #GLFW_STENCIL_BITS         =  $00021006
  #GLFW_ACCUM_RED_BITS       =  $00021007
  #GLFW_ACCUM_GREEN_BITS     =  $00021008
  #GLFW_ACCUM_BLUE_BITS      =  $00021009
  #GLFW_ACCUM_ALPHA_BITS     =  $0002100A
  #GLFW_AUX_BUFFERS          =  $0002100B
  #GLFW_STEREO               =  $0002100C
  #GLFW_SAMPLES              =  $0002100D
  #GLFW_SRGB_CAPABLE         =  $0002100E
  #GLFW_REFRESH_RATE         =  $0002100F
  #GLFW_DOUBLEBUFFER         =  $00021010
  
  #GLFW_CLIENT_API           =  $00022001
  #GLFW_CONTEXT_VERSION_MAJOR = $00022002
  #GLFW_CONTEXT_VERSION_MINOR = $00022003
  #GLFW_CONTEXT_REVISION      = $00022004
  #GLFW_CONTEXT_ROBUSTNESS    = $00022005
  #GLFW_OPENGL_FORWARD_COMPAT = $00022006
  #GLFW_OPENGL_DEBUG_CONTEXT  = $00022007
  #GLFW_OPENGL_PROFILE        = $00022008
  
  #GLFW_OPENGL_API            = $00030001
  #GLFW_OPENGL_ES_API         = $00030002
  
  #GLFW_NO_ROBUSTNESS          =         0
  #GLFW_NO_RESET_NOTIFICATION  = $00031001
  #GLFW_LOSE_CONTEXT_ON_RESET  = $00031002
  
  #GLFW_OPENGL_ANY_PROFILE     =         0
  #GLFW_OPENGL_CORE_PROFILE    = $00032001
  #GLFW_OPENGL_COMPAT_PROFILE  = $00032002
  
  #GLFW_CURSOR                = $00033001
  #GLFW_STICKY_KEYS           = $00033002
  #GLFW_STICKY_MOUSE_BUTTONS  = $00033003
  
  #GLFW_CURSOR_NORMAL         = $00034001
  #GLFW_CURSOR_HIDDEN         = $00034002
  #GLFW_CURSOR_DISABLED       = $00034003
  
  #GLFW_ANY_RELEASE_BEHAVIOR  =        0
  #GLFW_RELEASE_BEHAVIOR_FLUSH= $00035001
  #GLFW_RELEASE_BEHAVIOR_NONE = $00035002
  
  ; Cursors
  #GLFW_ARROW_CURSOR          = $00036001
  #GLFW_GLFW_IBEAM_CURSOR     = $00036002
  #GLFW_CROSSHAIR_CURSOR      = $00036003
  #GLFW_HAND_CURSOR           = $00036004
  #GLFW_HRESIZE_CURSOR        = $00036005
  #GLFW_VRESIZE_CURSOR        = $00036006
  
  #GLFW_CONNECTED             = $00040001
  #GLFW_DISCONNECTED          = $00040002
  
  #GLFW_DONT_CARE             = -1
  
  ;/* Time spans longer than this (seconds) are considered To be infinity */
  #GLFW_INFINITY = 100000.0
  
  ;---------------------------------------------------------------------------
  ; Macros
  ;---------------------------------------------------------------------------
  ;{
  ;-----------------------------------------
  ; Get Pseudotype(unicode/ascii)
  ;-----------------------------------------
  CompilerIf #PB_Compiler_Unicode
    Macro GLFWPSEUDOTYPE
      p-utf8
    EndMacro
  CompilerElse
    Macro GLFWPSEUDOTYPE
      p-ascii
    EndMacro
  CompilerEndIf
  
  ;}
  
  ;---------------------------------------------------------------------------
  ; Structures
  ;---------------------------------------------------------------------------
  ;{
  ;--------------------------------------
  ; Monitor (Opaque Structure)
  ;--------------------------------------
  Structure GLFWmonitor : EndStructure
  
  ;--------------------------------------
  ; Window (Opaque Structure)
  ;--------------------------------------
  Structure GLFWwindow : EndStructure
  
  ;--------------------------------------
  ; Cursor (Opaque Structure)
  ;--------------------------------------
  Structure GLFWcursor : EndStructure
  
  ;--------------------------------------
  ; Video Mode
  ;--------------------------------------
  Structure GLFWvidmode
    Width.l
    Height.l
    RedBits.l
    BlueBits.l
    GreenBits.l
  EndStructure
  
  ;--------------------------------------
  ; Gamma Ramp
  ;--------------------------------------
  Structure GLFWgammaramp
    *red      ; pointer to array of unsigned short
    *green    ; pointer to array of unsigned short
    *blue     ; pointer to array of unsigned short
    size.l
  EndStructure
  
  ;--------------------------------------
  ; Image
  ;--------------------------------------
  Structure GLFWimage
    width.i
    height.i
    *pixels; pointer to unsigned char*
  EndStructure
  ;}
  
  
  ;---------------------------------------------------------------------------
  ; Prototypes
  ;---------------------------------------------------------------------------
  ;{
  PrototypeC PGLFWGLPROC()
  PrototypeC PGLFWERROR(err_code.i,description.GLFWPSEUDOTYPE)
  PrototypeC PGLFWCREATEWINDOWPROC(w.i,h.i,name.GLFWPSEUDOTYPE,*monitor.GLFWmonitor=#Null,*parent.GLFWwindow=#Null)
  PrototypeC PGLFWWINDOWPOS(*window.GLFWwindow,posx.i,posy.i)
  PrototypeC PGLFWWINDOWSIZE(*window.GLFWwindow,width.i,height.i)
  PrototypeC PGLFWWINDOWCLOSE(*window.GLFWwindow)
  PrototypeC PGLFWWINDOWREFRESH(*window.GLFWwindow)
  PrototypeC PGLFWWINDOWFOCUS(*window.GLFWwindow)
  PrototypeC PGLFWKEY(*window.GLFWwindow,key.i,scancode.i,action.i,modifier.i)    ; Key Pressed/Released Callback Function
  PrototypeC PGLFWCHAR(*window.GLFWwindow,character.l)                            ; Unicode Character Input Callback Function
  PrototypeC PGLFWMOUSEBUTTON(*window.GLFWwindow,button.i,action.i,modifier.i)    ; Mouse Button  Pressed/Released Callback Function
  PrototypeC PGLFWMOUSEPOS(*window.GLFWwindow,posx.d,posy.d)                      ; Mouse Position Callback Function
  PrototypeC PGLFWMOUSEENTER(*window.GLFWwindow,entered.i)                        ; Mouse Enter/Leave Callback Function 
  PrototypeC PGLFWMOUSESCROLL(*window.GLFWwindow,xoffset.d,yoffset.d)             ; Mouse Scroll(Wheel) Callback Function 
  PrototypeC PGLFWFRAMEBUFFERSIZE(*window.GLFWwindow)
  ;}
    
  ;---------------------------------------------------------------------------
  ; Import Functions
  ;---------------------------------------------------------------------------
  ;{
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    Import "..\..\libs\x64\windows\glfw3.lib"
  
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
      
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    Import "../../libs/x64/linux/glfw3.a" : EndImport
      Import "/usr/lib/x86_64-linux-gnu/libxcb.a" : EndImport
      Import "/usr/lib/x86_64-linux-gnu/libXau.a" : EndImport 
      Import "/usr/lib/x86_64-linux-gnu/libXdmcp.a" : EndImport 
      Import "/usr/lib/x86_64-linux-gnu/libXcursor.a" : EndImport
      Import "/usr/lib/x86_64-linux-gnu/libXrender.a" : EndImport
      Import "/usr/lib/x86_64-linux-gnu/libX11.a" : EndImport  
      Import "/usr/lib/x86_64-linux-gnu/libXinerama.a" : EndImport  
      Import "/usr/lib/x86_64-linux-gnu/libXi.a" : EndImport  
      Import "/usr/lib/x86_64-linux-gnu/libXrandr.a" : EndImport 
      Import "/usr/lib/x86_64-linux-gnu/libXxf86vm.a" : EndImport 
      Import "/usr/lib/x86_64-linux-gnu/libXext.a" : EndImport 
      Import "/usr/lib/x86_64-linux-gnu/libXfixes.a" : EndImport 
      
;     ImportC "-lGL" : EndImport
;     ImportC "-lGLU" : EndImport
;     ImportC "-lX11" : EndImport  
;     ImportC "-lXinerama" : EndImport  
;     ImportC "-lXi" : EndImport  
;     ImportC "-lXrandr" : EndImport 
;     ImportC "-lXcursor" : EndImport
;     ImportC "-lXxf86vm" : EndImport 
    Import "../../libs/x64/linux/glfw3.a"
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
      
    ;___________________________________________________________________________
    ;  MacOSX
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    Import "/System/Library/Frameworks/Quartz.framework/Quartz" : EndImport
    Import "/System/Library/Frameworks/IOKit.framework/IOKit" : EndImport
    Import "/System/Library/Frameworks/Foundation.framework/Foundation" : EndImport
    Import "/System/Library/Frameworks/AppKit.framework/AppKit" : EndImport
    Import "../../libs/x64/macosx/libglfw3.a"
  
  CompilerEndIf

  	;/* GLFW initialization, termination And version querying */
  	glfwInit()
  	glfwTerminate()
  	glfwGetVersion(*major, *minor, *rev)                                           ;(*major.i,*minor.i,*rev.i) 
  	glfwGetVersionString()                                                         ; return const char*
  
  	;/* GLFW monitors */
  	glfwGetMonitors(*count)                                                        ;(*count.i) ; return a **GLFWmonitor
  	glfwGetPrimaryMonitor()                                                        ; return a *GLFWmonitor
  	glfwGetMonitorPos(*monitor.GLFWmonitor, *xpos, *ypos)                          ;(*monitor.GLFWmonitor,*xpos.i,*ypos.i)
  	glfwGetMonitorPhysicalSize(*monitor.GLFWmonitor, *width,*height)               ;(*monitor.GLFWmonitor,*xpos.i,*ypsos.i)
  	glfwGetMonitorName(*monitor.GLFWmonitor)                                       ;(*monitor.GLFWmonitor) return const char*
  	glfwSetMonitorCallback(*monitor.GLFWmonitor, callback.i)
  	
  	;/* Windows */
  	glfwGetVideoModes(*monitor.GLFWmonitor,*count);                                ;(*monitor.GLFWmonitor, *count.i)
  	glfwGetVideoMode(*monitor.GLFWmonitor);
  	glfwSetGamma(*monitor.GLFWmonitor, gamma.f);
  	glfwGetGammaRamp(*monitor.GLFWmonitor)                                         ; return a *GLFWgammaramp
  	glfwSetGammaRamp(*monitor.GLFWmonitor, *ramp.GLFWgammaramp);
  	glfwDefaultWindowHints()
  	glfwWindowHint(target.i, hint.i)
  	glfwCreateWindow(w.i,h.i,name.GLFWPSEUDOTYPE,*monitor.GLFWmonitor=#Null,*parent.GLFWwindow=#Null)
  
  	glfwDestroyWindow(*window.GLFWwindow)
  	glfwWindowShouldClose(*window.GLFWwindow)
  	glfwSetWindowShouldClose(*window.GLFWwindow, value.i)
  	glfwSetWindowTitle(*window.GLFWwindow,title.GLFWPSEUDOTYPE)
  	glfwGetWindowPos(*window.GLFWwindow, *xpos, *ypos)                       ;(*window.GLFWwindow,*xpos.i,*ypos.i)
  	glfwSetWindowPos(*window.GLFWwindow, xpos.i, ypos.i)
  	glfwGetWindowSize(*window.GLFWwindow, *width, *height)                   ;(*window.GLFWwindow,*width.i,*height.i)
  	glfwSetWindowSize(*window.GLFWwindow, width.i, height.i)
  	glfwGetFramebufferSize(*window.GLFWwindow, *width, *height)              ;(*window.GLFWwindow,*width.i,*height.i)
  	glfwGetWindowFrameSize(*window.GLFWwindow,*left, *top, *right, *bottom)  ;(*window.GLFWwindow,*left., *top.i, *right.i, *bottom.i);
  	glfwIconifyWindow(*window.GLFWwindow)
  	glfwRestoreWindow(*window.GLFWwindow)
  	glfwShowWindow(*window.GLFWwindow)
  	glfwHideWindow(*window.GLFWwindow)
  	glfwGetWindowMonitor(*window.GLFWwindow)                                 ; return a *GLFWmonitor
  	glfwGetWindowAttrib.i(*window.GLFWwindow, attrib.i)
  	glfwSetWindowUserPointer(*window.GLFWwindow, *ptr)                       ; set-up user pointer for the specified GLFW*window.GLFWwindow
  	glfwGetWindowUserPointer(*window.GLFWwindow)                             ; get user pointer
  	
  	
  	;/* Time */
  	glfwGetTime.d()
  	glfwSetTime(time.d)
  
  	;/* Events */
  	glfwPollEvents()
  	glfwWaitEvents()
  	glfwPostEmptyEvent()
  	
  	;/* Inputs */
  	glfwGetInputMode.i(*window.GLFWwindow, mode.i)                           ; Modes:#GLFW_CURSOR,#GLFW_STICKY_KEYS,#GLFW_STICKY_MOUSE_BUTTONS
  	glfwSetInputMode(*window.GLFWwindow, mode.i, value.i);
  	
    glfwGetKey.i(*window.GLFWwindow, key.i)                                  ; return #GLFW_PRESS or #GLFW_RELEASE
    
    ;/* Mouse */
    glfwGetMouseButton(*window.GLFWwindow, button.i)                         ; return #GLFW_PRESS or #GLFW_RELEASE
    glfwGetCursorPos(*window.GLFWwindow, *xpos, *ypos)                       ;(*window.GLFWwindow,*xpos.d, *ypos.d)
    glfwSetCursorPos(*window.GLFWwindow, xpos.d, ypos.d)
    
    ;/* Cursor */
    glfwCreateCursor(*image.GLFWimage, xhot.i, yhot.i)
    glfwCreateStandardCursor(shape.i)
    glfwDestroyCursor(*cursor.GLFWcursor)
    glfwSetCursor(*window.GLFWwindow,*cursor.GLFWcursor)
    
    ;/* Joystick (untested)*/
  	glfwJoystickPresent(joystick.i)               ; Joystick Is Present?
  	glfwGetJoystickAxes(joystick.i, *count)       ;(joystick.i, *count.i) return const float* describing axis values
  	glfwGetJoystickButtons(joystick.i, *count)    ;(joystick.i, *count.i) return const unsigned char* describing buttons values
  	glfwGetJoystickName(joystick.i)               ; return const char* containing joystick name
  	
  	;/* Clipboard */
  	glfwSetClipboardString(*window.GLFWwindow, string.GLFWPSEUDOTYPE)        ; Put String to Clipboard
  	glfwGetClipboardString(*window.GLFWwindow)                               ; return const char* from clipboard content
  	
  	;/* Callbacks */
    glfwSetErrorCallback(*cb.PGLFWERROR)                                     ; Set Error Callback
  	glfwSetWindowPosCallback(*window.GLFWwindow, *cb.PGLFWWINDOWPOS)         ; Set Window Pos Callback
  	glfwSetWindowSizeCallback(*window.GLFWwindow, *cb.PGLFWWINDOWSIZE)       ; Set Window Size Callback
  	glfwSetWindowCloseCallback(*window.GLFWwindow, *cb.PGLFWWINDOWCLOSE)     ; Set Window Close Callback
  	glfwSetWindowRefreshCallback(*window.GLFWwindow, *cb.PGLFWWINDOWREFRESH) ; Set Window Refresh Callback
  	glfwSetWindowFocusCallback(*window.GLFWwindow, *cb.PGLFWWINDOWFOCUS)     ; Set Window Focus Callback
  	glfwSetKeyCallback(*window.GLFWwindow, *cb.PGLFWKEY)                     ; Set Keyboard Key Callback
  	glfwSetCharCallback(*window.GLFWwindow, *cb.PGLFWCHAR)                   ; Set Keyboard Input Callback
  	glfwSetMouseButtonCallback(*window.GLFWwindow, *cb.PGLFWMOUSEBUTTON)     ; Mouse Button Callback
  	glfwSetCursorPosCallback(*window.GLFWwindow, *cb.PGLFWMOUSEPOS)          ; Mouse Move Callback
  	glfwSetCursorEnterCallback(*window.GLFWwindow, *cb.PGLFWMOUSEENTER)      ; Mouse Enter/Leave Window
  	glfwSetScrollCallback(*window.GLFWwindow, *cb.PGLFWMOUSESCROLL)          ; Mouse Scroll(wheel)
  	glfwSetFramebufferSizeCallback (*window.GLFWwindow, *cb.PGLFWFRAMEBUFFERSIZE); FrameBuffer Size CallBack
  	
  	
  	;/* Contexts */
  	glfwMakeContextCurrent(*window.GLFWwindow)
  	glfwGetCurrentContext()                                       ; return a *GLFWwindow
  	glfwSwapBuffers(*window.GLFWwindow)                           ; Swap Front/Back OpenGL Buffers
  	glfwSwapInterval(interval.i)                                  ; Vertical Retrace Synchronization(VSync)
  	
  	;/* Extensions */
  	glfwExtensionSupported(extension.GLFWPSEUDOTYPE)                           ; Extension Is Supported?
  	;glfwGetProcAddress(procname.GLFWPSEUDOTYPE)
  	glfwGetProcAddress(extname.GLFWPSEUDOTYPE)
  	
  	;/* Underlying Window */
  	CompilerSelect #PB_Compiler_OS
  	  CompilerCase #PB_OS_Windows
  	    glfwGetWin32Window(*window.GLFWwindow)                                 ; return underlying HWND
  	CompilerEndSelect
  
  EndImport
  
  Declare GLFW_Error_Callback(error.i,description.s)
  Declare GLFW_Key_Callback(*window.GLFWwindow,key.i,scancode.i,action.i,modifiers.i)
  Declare GLFW_MouseButton_Callback(*window.GLFWwindow,button.i,action.i,modifier.i)
  Declare GLFW_MouseEnter_Callback(*window.GLFWwindow,entered.i)
  Declare GLFW_MouseMove_Callback(*window.GLFWwindow,entered.i)
  Declare GLFW_WindowRefresh_Callback(*window.GLFWwindow)
  Declare glfwDebugVersion()
  Declare GLFWDLogCurrentMonitorInfo()
  Declare glfwSetParentWindow(*window.GLFWwindow,parentWindow)
  Declare glfwCreateFullScreenWindow()
  Declare glfwCreateWindowedWindow(width.i,height.i,name.s)
  ;}
EndDeclareModule

Module GLFW
  ;UseModule OpenGL
  ;---------------------------------------------------------------------------
  ; Callbacks (exemples)
  ;---------------------------------------------------------------------------
  ;{
  ;-------------------------
  ; Error Callback
  ;-------------------------
  Procedure GLFW_Error_Callback(error.i,description.s)
    Debug description  
  EndProcedure
  
  ;-------------------------
  ; Keyboard Key Callback
  ;-------------------------
  Procedure GLFW_Key_Callback(*window.GLFWwindow,key.i,scancode.i,action.i,modifiers.i)
    If key = #GLFW_KEY_ESCAPE And action = #GLFW_PRESS
      glfwSetWindowShouldClose(*window.GLFWwindow,#True)
    ElseIf key = #GLFW_KEY_S And action = #GLFW_PRESS
      Debug "Activate Camera"
    EndIf
  EndProcedure
  
  ;--------------------------
  ; Mouse Button Callback
  ;--------------------------
  Procedure GLFW_MouseButton_Callback(*window.GLFWwindow,button.i,action.i,modifier.i)
    Debug "GLFW MouseButton Callback"
    If button = #GLFW_MOUSE_BUTTON_LEFT And action = #GLFW_PRESS
      Debug "Left Mouse Button Callback!!"
    EndIf
  EndProcedure
  
  ;--------------------------
  ; Mouse Enter/Leave Callback
  ;--------------------------
  Procedure GLFW_MouseEnter_Callback(*window.GLFWwindow,entered.i)
    If entered = #True
      Debug "Mouse Entered Window..."
    Else
      Debug "Mouse Leaved Window..."
    EndIf
  EndProcedure
  
  ;--------------------------
  ; Mouse Move Callback
  ;--------------------------
  Procedure GLFW_MouseMove_Callback(*window.GLFWwindow,entered.i)
    If entered = #True
      Debug "Mouse Entered Window..."
    Else
      Debug "Mouse Leaved Window..."
    EndIf
  EndProcedure
  
  ; glfwSetCursorEnterCallback(*window,@GLFW_MouseEnter_Callback())
  ; glfwSetWindowFocusCallback(*window,@GLFW_WindowFocusCallback())
  
  ;--------------------------
  ; Window Refresh Callback
  ;--------------------------
  Procedure GLFW_WindowRefresh_Callback(*window.GLFWwindow)
    Debug "GLFW Window Refresh Callback!!"
  EndProcedure
  
  ;}
  
  ;----------------------------------------------------------------------
  ; Debug
  ;----------------------------------------------------------------------
  ;{
  ;----------------------------
  ; Log GLFW Version
  ;----------------------------
  Procedure glfwDebugVersion()
    Protected *version = glfwGetVersionString()
    ;Debug "GLFW Version : "+ GLGETSTRINGOUTPUT(*version)
  EndProcedure
  
  
  ;-------------------------------------------------------------
  ; Log Current Monitor Infos
  ;-------------------------------------------------------------
  Procedure GLFWDLogCurrentMonitorInfo()
    Protected *monitor.GLFWmonitor = glfwGetPrimaryMonitor()
    Protected *name = glfwGetMonitorName(*monitor)
    ;Debug "GLFW Current Monitor : "+ GLGETSTRINGOUTPUT(*name)
    Protected width, height
    Debug glfwGetMonitorPhysicalSize(*monitor.GLFWmonitor,@width,@height)
    Debug "Monitor Physical Size ---> Width : "+Str(width)+", Height : "+Str(height)
  EndProcedure
  ;}
  
  ;--------------------------------------------------------------
  ;Set Parent Window
  ;--------------------------------------------------------------
  ;{
  Procedure glfwSetParentWindow(*window.GLFWwindow,parentWindow)
    CompilerIf #PB_Compiler_OS =  #PB_OS_Windows
      Protected HWND.i = glfwGetWin32Window(*window) 
      SetParent_(HWND,parentWindow)
      ;SetWindowPos_(HWND,#HWND_TOPMOST,0,0,0,0,#SWP_NOMOVE|#SWP_NOSIZE)
    CompilerElse
      Debug "GLFWParentWindow : No Solution for Linux/MacOS yet..."
    CompilerEndIf
  EndProcedure
  ;}
  
  ;--------------------------------------------------------------
  ; Error Callback
  ;--------------------------------------------------------------
  ;{
  Procedure glfwErrorCallback(error.i, *description)
    MessageRequester("GLFW ERROR",PeekS(*description))
  EndProcedure
  ;}
  
  ;--------------------------------------------------------------
  ;Open FullScreen Window
  ;--------------------------------------------------------------
  ;{
  Procedure glfwCreateFullScreenWindow()
    Protected title.s = "GLFW3.1 - "
    Protected *monitor.GLFWmonitor  = glfwGetPrimaryMonitor()
    Protected *mode.GLFWvidmode  = glfwGetVideoMode(*monitor)
  ;       glfwWindowHint(#GLFW_OPENGL_PROFILE,#GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(#GLFW_RED_BITS,*mode\RedBits)
    glfwWindowHint(#GLFW_BLUE_BITS,*mode\BlueBits)
    glfwWindowHint(#GLFW_GREEN_BITS,*mode\GreenBits)
    
    ;glfwWindowHint(GLFW_SAMPLES, 4);
    If Not OpenGL::#USE_LEGACY_OPENGL
      glfwWindowHint(#GLFW_CONTEXT_VERSION_MAJOR, 3)
      glfwWindowHint(#GLFW_CONTEXT_VERSION_MINOR, 3)
      glfwWindowHint(#GLFW_OPENGL_FORWARD_COMPAT, #GL_TRUE)
      glfwWindowHint(#GLFW_OPENGL_PROFILE, #GLFW_OPENGL_CORE_PROFILE)
      glfwWindowHint(#GLFW_STENCIL_BITS, 8)
      title + "CORE"
    Else
      title + "LEGACY"
    EndIf
    
    glfwSetErrorCallback(@glfwErrorCallback())
    Protected *window.GLFWwindow = glfwCreateWindow(*mode\Width,*mode\Height,title,*monitor,#Null)
  
    
    If Not *window
      MessageRequester("GLFW", "Fail To Open GLFW FullScreen Window!!")
      ProcedureReturn #False
    EndIf
  
   ;Print out GLFW, OpenGL version And GLEW Version:
    Protected iOpenGLMajor.i = glfwGetWindowAttrib(*window, #GLFW_CONTEXT_VERSION_MAJOR);
    Protected iOpenGLMinor.i = glfwGetWindowAttrib(*window, #GLFW_CONTEXT_VERSION_MINOR);
    Protected iOpenGLRevision.i = glfwGetWindowAttrib(*window, #GLFW_CONTEXT_REVISION)  ;
  
    Debug "Status: Using GLFW Version "+glfwGetVersionString()
    Debug "Status: Using OpenGL Version: "+Str(iOpenGLMajor)+","+Str(iOpenGLMinor)+", Revision : "+Str(iOpenGLRevision)
    glfwMakeContextCurrent(*window)
    
    ProcedureReturn *window
  EndProcedure
  ;}
  
  ;--------------------------------------------------------------
  ;Open Windowed GLFW Window
  ;--------------------------------------------------------------
  ;{
  Procedure glfwCreateWindowedWindow(width.i,height.i,name.s)

    Protected *monitor.GLFWmonitor  = glfwGetPrimaryMonitor()
    Protected title.s = name +" - "
    If Not OpenGL::#USE_LEGACY_OPENGL
      glfwWindowHint(#GLFW_CONTEXT_VERSION_MAJOR, 3)
      glfwWindowHint(#GLFW_CONTEXT_VERSION_MINOR, 3)
      glfwWindowHint(#GLFW_OPENGL_FORWARD_COMPAT, #GL_TRUE)
      glfwWindowHint(#GLFW_OPENGL_PROFILE, #GLFW_OPENGL_CORE_PROFILE)
      glfwWindowHint(#GLFW_STENCIL_BITS, 8)
      title + "CORE"
    Else 
      title + "LEGACY"
    EndIf
    glfwSetErrorCallback(@glfwErrorCallback())
    
    Protected *window.GLFWwindow = glfwCreateWindow(width,height,title,#Null,#Null)
  
    If Not *window
      MessageRequester("GLFW", "Fail To Open GLFW Windowed Window!!")
      ProcedureReturn #False
    EndIf
  
   ;Print out GLFW, OpenGL version And GLEW Version:
    Protected iOpenGLMajor.i = glfwGetWindowAttrib(*window, #GLFW_CONTEXT_VERSION_MAJOR);
    Protected iOpenGLMinor.i = glfwGetWindowAttrib(*window, #GLFW_CONTEXT_VERSION_MINOR);
    Protected iOpenGLRevision.i = glfwGetWindowAttrib(*window, #GLFW_CONTEXT_REVISION)  ;
  
    Debug "Status: Using GLFW Version "+glfwGetVersionString()
    Debug "Status: Using OpenGL Version: "+Str(iOpenGLMajor)+","+Str(iOpenGLMinor)+", Revision : "+Str(iOpenGLRevision)
    glfwMakeContextCurrent(*window)
    
    ProcedureReturn *window
  EndProcedure
  ;}
EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 759
; FirstLine = 743
; Folding = -----
; EnableXP
; EnableUnicode
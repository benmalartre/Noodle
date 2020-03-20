XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Callback.pbi"
XIncludeFile "../core/Signal.pbi"
XIncludeFile "../core/Perlin.pbi"
XIncludeFile "../core/Commands.pbi"
XIncludeFile "../core/UIColor.pbi"
XIncludeFile "../core/Pose.pbi"
XIncludeFile "../core/Image.pbi"

; ============================================================================
;   OPENGL MODULES
; ============================================================================
XIncludeFile "../libs/OpenGL.pbi"
CompilerIf #USE_GLFW
  XIncludeFile "../libs/GLFW.pbi"
CompilerEndIf

XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../libs/FTGL.pbi"

XIncludeFile "../opengl/Types.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../opengl/Layer.pbi"
; XIncludeFile "../opengl/Framebuffer.pbi"
; XIncludeFile "../opengl/Texture.pbi"
; XIncludeFile "../opengl/ScreenQuad.pbi"

; XIncludeFile "../opengl/CubeMap.pbi"


; XIncludeFile "../core/Application.pbi"
; XIncludeFile "../libs/FTGL.pbi"
; XIncludeFile "../opengl/Framebuffer.pbi"
; XIncludeFile"../objects/Polymesh.pbi"
; XIncludeFile"../objects/Scene.pbi"
; XIncludeFile "../ui/ViewportUI.pbi"


; ;UseModule Math
; UseModule Time
; UseModule OpenGL
; CompilerIf #USE_GLFW
;   UseModule GLFW
; CompilerEndIf
; UseModule OpenGLExt
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 26
; Folding = -
; EnableXP
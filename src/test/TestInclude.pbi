


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile"../objects/Scene.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


;UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 17
; Folding = -
; EnableXP
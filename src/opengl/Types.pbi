XIncludeFile "Framebuffer.pbi"
XIncludeFile "ScreenQuad.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ============================================================================
;  GLContext Module Declaration
; ============================================================================
DeclareModule GLContext
  UseModule OpenGL
  #MAX_GL_CONTEXT = 5
  Global counter = 0
  Global GL_LINE_WIDTH_MIN.f
  Global GL_LINE_WIDTH_MAX.f
  
  Global Dim shadernames.s(26)
  shadernames(0) =  "selection"
  shadernames(1) =  "simple"
  shadernames(2) =  "wireframe"
  shadernames(3) =  "polymesh"
  shadernames(4) =  "cloud"
  shadernames(5) =  "instances"
  shadernames(6) =  "cubemap"
  shadernames(7) =  "deferred"
  shadernames(8) =  "gbuffer"
  shadernames(9) =  "gbufferic"
  shadernames(10) = "reflection"
  shadernames(11) = "ssao"
  shadernames(12) = "ssao_blur"
  shadernames(13) = "shadowmap"
  shadernames(14) = "shadowmapic"
  shadernames(15) = "shadowsimple"
  shadernames(16) = "shadowdefered"
  shadernames(17) = "shadowmapCSM"
  shadernames(18) = "shadowCSM"
  shadernames(19) = "shadowCSMdefered"
  shadernames(20) = "simple2D"
  shadernames(21) = "bitmap"
  shadernames(22) = "curve"
  shadernames(23) = "drawer"
  shadernames(24) = "stroke2D"
  shadernames(25) = "normal"

  Structure GLContext_t
    *window.GLFWwindow      ;main window holding shared gl context
    *writer                 ; FTGL::FTGL_Drawer
    width.d
    height.d
    useGLFW.b
    ID.i
    focus.b
    shader.GLuint
    
    List *framebuffers.Framebuffer::Framebuffer_t()
    Map *shaders.Program::Program_t()
  EndStructure
  
  Declare New(width.i, height.i, *context=#Null)
  Declare Setup(*Me.GLContext_t)
  Declare Copy(*Me.GLContext_t, *shared.GLContext_t)
  Declare Delete(*Me.GLContext_t)
  Declare SetContext(*Me.GLContext_t)
  Declare FlipBuffer(*Me.GLContext_t)
  Declare GetSupportedLineWidth(*Me.GLContext_t)
  Declare Resize(*Me.GLContext_t, width.i, height.i)
  Declare AddFramebuffer(*Me.GLContext_t, *framebuffer)
  Declare GetOpenGLVersion(*Me.GLContext_t)
  Declare.f BackingScaleFactor()  
  Global *MAIN_GL_CTXT.GLContext_t
  Global MAIN_GL_CTXT_WIDTH = 1024
  Global MAIN_GL_CTXT_HEIGHT = 1024
EndDeclareModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 18
; FirstLine = 14
; Folding = -
; EnableXP
; EnableUnicode
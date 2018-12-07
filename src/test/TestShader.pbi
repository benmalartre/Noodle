
XIncludeFile "../core/Application.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

Global framecount.l
Global lasttime.l

Global WIDTH = 1280
Global HEIGHT = 720


; GLSL Shaders
Global *s_shader.Program::Program_t


; Screen Space Quad
Global *quad.ScreenQuad::ScreenQuad_t

; Framebuffer
Global *buffer.Framebuffer::Framebuffer_t


Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *ctx.GLContext::GLcontext_t

Procedure GetFPS()
 framecount +1
  Protected current.l = Time::Get()*1000
  Protected elapsed.l = current - lasttime
  If elapsed > 1000
    fps = framecount;/(elapsed /1000)
    lasttime = current
    framecount = 0
  EndIf  
EndProcedure

Procedure Draw(*app.Application::Application_t)
  GetFPS()
  ViewportUI::SetContext(*viewport)
  Framebuffer::BindOutput(*buffer)
  glClearColor(Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1.0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  
  Framebuffer::BlitTo(*buffer,0,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT,#GL_NEAREST)
  ViewportUI::FlipBuffer(*viewport)
EndProcedure

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  *app = Application::New("Shader",800,600)
  *viewport = ViewportUI::New(*app\manager\main, "Viewport")
  *viewport\camera = *app\camera
  *app\context = *viewport\context
  
  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  Define *ftgl_drawer.FTGL::FTGL_Drawer = FTGL::New()
  
  
  ; Shaders
  ;-----------------------------------------------------
  *s_shader = Program::NewFromName("wireframe")

  
  *quad = ScreenQuad::New()
  ScreenQuad::Setup(*quad,*s_shader)
  
  ; Buffer
  ;-----------------------------------------------------
  *buffer = Framebuffer::New("Buffer",WIDTH,HEIGHT)
  Framebuffer::AttachTexture(*buffer,"color",#GL_RGBA16F,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)
  
  
  Application::Loop(*app,@Draw())

EndIf

; glDeleteBuffers(1,@vbo)
; glDeleteVertexArrays(1,@vao)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 56
; FirstLine = 32
; Folding = -
; EnableXP
; Constant = #USE_GLFW=1
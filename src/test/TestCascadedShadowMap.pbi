

XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile"../objects/Scene.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

Global down.b
Global lmb_p.b
Global mmb_p.b
Global rmb_p.b
Global oldX.f
Global oldY.f
Global width.i
Global height.i

Global *torus.Polymesh::Polymesh_t
Global *teapot.Polymesh::Polymesh_t
Global *ground.Polymesh::Polymesh_t
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t

Global *buffer.Framebuffer::Framebuffer_t
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLContext::SetContext(*app\context)
  Framebuffer::BindOutput(*buffer)
  glClearColor(0.25,0.25,0.25,1.0)
  glViewport(0, 0, *buffer\width,*buffer\height)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glEnable(#GL_DEPTH_TEST)
  
  glUseProgram(shader)
  Matrix4::SetIdentity(offset)
  Framebuffer::BindOutput(*buffer)
  glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*app\camera\view)
  glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*app\camera\projection)
  glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  T+0.01

;   Polymesh::Draw(*torus)
;   Polymesh::Draw(*teapot)
;   Polymesh::Draw(*ground)
;   Polymesh::Draw(*null)
;   Polymesh::Draw(*cube)
  Polymesh::Draw(*bunny, *app\context)
  
  glDisable(#GL_DEPTH_TEST)
  
  glViewport(0,0,width,height)
  glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
  glReadBuffer(#GL_COLOR_ATTACHMENT0)
  glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT ,#GL_NEAREST);
  
  glDisable(#GL_DEPTH_TEST)
  
  
;   glEnable(#GL_BLEND)
;   glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
;   glDisable(#GL_DEPTH_TEST)
;   FTGL::SetColor(*ftgl_drawer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*ftgl_drawer,"Yeahhhhhh",-0.9,0.9,ss,ss*ratio)
; 
;   glDisable(#GL_BLEND)
  GLContext::FlipBuffer(*app\context)

 EndProcedure
 

 
 Define useJoystick.b = #False
 width = 600
 height = 600
; Main
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("TestMesh",width,height)
   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main, "Viewport", *app\camera, *app\handle)
    *viewport\camera = *app\camera
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *buffer = Framebuffer::New("Color",*app\width,*app\height)
  Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachTexture(*buffer,"normal",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)

  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  
  *s_wireframe = Program::NewFromName("simple")
  *s_polymesh = Program::NewFromName("polymesh")
  
  shader = *s_polymesh\pgm

;   *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
;   *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
;   *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
;   *null.Polymesh::Polymesh_t = Polymesh::New("Null",Shape::#SHAPE_NULL)
;   *cube.Polymesh::Polymesh_t = Polymesh::New("Cube",Shape::#SHAPE_CUBE)
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
;   Polymesh::Setup(*torus,*s_polymesh)
;   Polymesh::Setup(*teapot,*s_polymesh)
;   Polymesh::Setup(*ground,*s_polymesh)
;   Polymesh::Setup(*null,*s_polymesh)
;   Polymesh::Setup(*cube,*s_polymesh)
  Polymesh::Setup(*bunny,*s_polymesh)


  
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 121
; FirstLine = 98
; Folding = -
; EnableXP
; Executable = polymesh.exe
; Debugger = Standalone
; Constant = #USE_GLFW=1
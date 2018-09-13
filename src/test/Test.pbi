

XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

Global *s_simple.Program::Program_t

Global *buffer.Framebuffer::Framebuffer_t
Global *cloud.PointCloud::PointCloud_t
Global *torus.Polymesh::Polymesh_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t

Procedure Draw(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  glUseProgram(*s_simple\pgm)
  Define.m4f32 model,view,proj
  Matrix4::SetIdentity(@model)
  
  Framebuffer::BindOutput(*buffer)

  glCheckError("Bind FrameBuffer")
  glViewport(0, 0, *app\width,*app\height)
  glCheckError("Set Viewport")

  glDepthMask(#GL_TRUE);
  glClearColor(Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1.0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glCheckError("Clear")
  glEnable(#GL_DEPTH_TEST)
  
  glUniformMatrix4fv(glGetUniformLocation(*s_simple\pgm,"offset"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*s_simple\pgm,"model"),1,#GL_FALSE,@model)
  
  glUniformMatrix4fv(glGetUniformLocation(*s_simple\pgm,"view"),1,#GL_FALSE,*app\camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*s_simple\pgm,"projection"),1,#GL_FALSE,*app\camera\projection)
  glUniform3f(glGetUniformLocation(*s_simple\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glCheckError("Set Uniforms")
  Polymesh::Draw(*torus)
  glCheckError("Draw Mesh")
  glDepthMask(#GL_FALSE);
  
  ;Framebuffer::BlitTo(*buffer,#Null,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT,#GL_NEAREST)
  glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
  glReadBuffer(#GL_COLOR_ATTACHMENT0)
  glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
  glDisable(#GL_DEPTH_TEST)
  
  ViewportUI::FlipBuffer(*viewport)
  
EndProcedure
    
Define model.m4f32
; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  *app = Application::New("Test",120,60)

  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
    *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Matrix4::SetIdentity(@model)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  Debug *app\width
  Debug *app\height
  *buffer = Framebuffer::New("Color",*app\width,*app\height)
  
  *s_simple = Program::NewFromName("simple")

  ;Define *compo.Framebuffer::Framebuffer_t = Framebuffer::New("Compo",GadgetWidth(gadget),GadgetHeight(gadget))
  
  Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)

  *torus = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
  *cloud = PointCloud::New("Cloud",Shape::#SHAPE_TORUS)
  Polymesh::Setup(*torus,*s_simple)
  PointCloud::Setup(*cloud,*s_simple)
  
  Application::Loop(*app,@Draw())
EndIf
; IDE Options = PureBasic 5.62 (Linux - x64)
; CursorPosition = 87
; FirstLine = 15
; Folding = -
; EnableThread
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
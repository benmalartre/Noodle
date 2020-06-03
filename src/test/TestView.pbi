
XIncludeFile "../core/Application.pbi"

EnableExplicit
UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Global WIDTH = 800
Global HEIGHT = 600

CompilerIf #Use_LEGACY_OPENGL
  Global s_vert.s = "#version 120"+Chr(10)
  s_vert + "attribute vec2 position;"+Chr(10)
  s_vert + "attribute vec2 coords;"+Chr(10)
  s_vert + "varying vec2 texCoords;"+Chr(10)
  s_vert + "void main()"+Chr(10)
  s_vert + "{"+Chr(10)
  s_vert + "    gl_Position = vec4(position,0.0f,1.0f);"+Chr(10)
  s_vert + "    texCoords = coords;"+Chr(10)
  s_vert + "}"
  
  
  Global s_frag.s = "#version 120"+Chr(10)
  s_frag + "void main(){"+Chr(10)
  s_frag + " gl_FragColor = vec4(1.0,0.0,0.0,1.0);"+Chr(10)
  s_frag + "}"
CompilerElse
  
  Global s_vert.s = "#version 330"+Chr(10)
  s_vert + "layout (location = 0) in vec2 position;"+Chr(10)
  s_vert + "layout (location = 1) in vec2 coords;"+Chr(10)
  s_vert + "out vec2 texCoords;"+Chr(10)
  s_vert + "void main()"+Chr(10)
  s_vert + "{"+Chr(10)
  s_vert + "    gl_Position = vec4(position,0.0f,1.0f);"+Chr(10)
  s_vert + "    texCoords = coords;"+Chr(10)
  s_vert + "}"
  
  Global s_frag.s = "#version 330"+Chr(10)
  s_frag + "in vec2 texCoords;"+Chr(10)
  s_frag + "out vec4 outColor;"+Chr(10)
  s_frag + "uniform float iGlobalTime;"+Chr(10)
  s_frag + "uniform vec2 iResolution;"+Chr(10)
  s_frag + "void main(){"+Chr(10)
  s_frag + " outColor = vec4(texCoords,0.0,1.0);"+Chr(10)
  s_frag + "}"
  
CompilerEndIf


Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()

Define *app.Application::Application_t = Application::New("Solar System",1200,600)



Define *s1.View::View_t = View::Split(*app\window\main,#PB_Splitter_Vertical,66)
; Define *s2.View::View_t = View::Split(*s1\left)
Define *s2.View::View_t = View::Split(*s1\right,0,60)
Define *s3.View::View_t = View::Split(*s2\right,#PB_Splitter_SecondFixed,60)
Window::OnEvent(*app\window,#PB_Event_SizeWindow)
Define *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*s1\left,"ViewportUI", *app\camera, *app\handle)
Define viewport.UI::IUI = *viewport
*app\context = *viewport\context
Define shaders.UI::IUI = ShaderUI::New(*s2\left,"Shader",#Null)
Define log.UI::IUI = LogUI::New(*s3\left,"LogUI")
Define timeline.UI::IUI = TimelineUI::New(*s3\right,"TimelineUI")

; FTGL Drawer
;-----------------------------------------------------
FTGL::Init()

; CompilerIf #PB_Compiler_Unicode
;   Global *shader.Program::Program_t = Program::New("custom",Shader::DeCodeUnicodeShader(s_vert),Shader::DeCodeUnicodeShader(s_frag))
;   Global *shader2.Program::Program_t = Program::NewFromName("polymesh")
; CompilerElse
  Global *shader.Program::Program_t = Program::New("custom",s_vert,s_frag)
  Global *shader2.Program::Program_t = Program::NewFromName("polymesh")
; CompilerEndIf



UseJPEGImageDecoder()
Define texture.i  =LoadImage(#PB_Any,"..\..\textures\moonbumpmap2.jpg")
Define textureID = Utils::GLLoadImage(texture,#False,#GL_REPEAT,#GL_REPEAT,#GL_LINEAR,#GL_LINEAR)
Define texture2.i  =LoadImage(#PB_Any,"..\..\textures\earth.jpg")
Define textureID2 = Utils::GLLoadImage(texture2,#False,#GL_REPEAT,#GL_REPEAT)
ShaderUI::SetContent(shaders,*shader)
 
Global *ship.Polymesh::Polymesh_t = Polymesh::New("Dhip",Shape::#SHAPE_TOMATO)
Global *quad.ScreenQuad::ScreenQuad_t = ScreenQuad::New()
Global *camera.Camera::Camera_t = Camera::New("Camera1",Camera::#Camera_Perspective)


Polymesh::Setup(*ship,*shader2)
ScreenQuad::Setup(*quad,*shader)

Define e
Define.m4f32 model,offset
Matrix4::SetIdentity(model)
Matrix4::SetIdentity(offset)
Define.f T
Define *vp.ViewportUI::ViewportUI_t = *viewport
*vp\camera = *camera
Define T.f
Repeat
  e = WaitWindowEvent()
  T = Application::GetFPS(*app)
;   SetGadgetAttribute(*viewport
;   Framebuffer::BindOutput(*buffer)
  

  glClearColor(0,0,0,1.0)
  glViewport(0, 0, GadgetWidth(*vp\gadgetID),GadgetHeight(*vp\gadgetID))
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)

  glEnable(#GL_DEPTH_TEST)
  
  glUseProgram(*shader\pgm)
  glDepthMask(#GL_FALSE)
  glEnable(#GL_TEXTURE_2D)
  glActiveTexture(#GL_TEXTURE0)
  glBindTexture(#GL_TEXTURE_2D, textureID);
  glActiveTexture(#GL_TEXTURE1)
  glBindTexture(#GL_TEXTURE_2D, textureID2);
  
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_ONE,#GL_ONE_MINUS_SRC_ALPHA)
;   Framebuffer::BindOutput(*buffer)
  glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"projection"),1,#GL_FALSE,*camera\projection)
  ;glUniform3f(glGetUniformLocation(*shader\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform1f(glGetUniformLocation(*shader\pgm,"iGlobalTime"),Time::Get())
  glUniform2f(glGetUniformLocation(*shader\pgm,"iResolution"),GadgetWidth(*vp\gadgetID),GadgetHeight(*vp\gadgetID))
  glUniform3f(glGetUniformLocation(*shader\pgm,"iMouse"),0,0,0)
  glUniform1i(glGetUniformLocation(*shader\pgm,"iChannel0"),0)
  glUniform1i(glGetUniformLocation(*shader\pgm,"iChannel1"),1)
  SetGadgetAttribute(*vp\gadgetID,#PB_OpenGL_SetContext,#True)
  ScreenQuad::Draw(*quad)
  
  
  
  glUseProgram(*shader2\pgm)
  glDepthMask(#GL_TRUE)
  glUniformMatrix4fv(glGetUniformLocation(*shader2\pgm,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*shader2\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*shader2\pgm,"projection"),1,#GL_FALSE,*camera\projection)
  glUniform3f(glGetUniformLocation(*shader2\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  
  ;Polymesh::Draw(*ship)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/GadgetWidth(*vp\gadgetID)
  Define ratio.f = GadgetWidth(*vp\gadgetID) / GadgetHeight(*vp\gadgetID)
  FTGL::Draw(*app\context\writer,"Date : "+FormatDate("%dd/%mm/%yyyy", Date()),-0.9,0.95,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Time : "+FormatDate("%hh:%ii:%ss", Date()),-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"User : "+UserName(),-0.9,0.85,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+StrF(*app\fps),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  SetGadgetAttribute(*vp\gadgetID,#PB_OpenGL_FlipBuffers,#True)
;   Polymesh::Draw(*teapot)
;   Polymesh::Draw(*ground)
;   Polymesh::Draw(*null)
;   Polymesh::Draw(*cube)
;   Polymesh::Draw(*bunny)
  
;   glDisable(#GL_DEPTH_TEST)
;   
;   glViewport(0,0,width,height)
;   glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
;   glReadBuffer(#GL_COLOR_ATTACHMENT0)
;   glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT ,#GL_NEAREST);
;   
;   glDisable(#GL_DEPTH_TEST)
  
  Window::OnEvent(*app\window,e)
Until e = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 54
; FirstLine = 50
; Folding = -
; EnableXP
; Executable = glslsandbox.exe
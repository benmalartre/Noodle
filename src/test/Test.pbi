

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
Global backingScaleFactor.f = GLContext::BackingScaleFactor()

Procedure Draw(*app.Application::Application_t)
;   GLContext::SetContext(*app\context)
  
  glUseProgram(*s_simple\pgm)
  Define.m4f32 model,view,proj
  Matrix4::SetIdentity(model)
  
;   Framebuffer::BindOutput(*buffer)
;   glCheckError("Bind FrameBuffer")
  glViewport(0, 0, *app\width * backingScaleFactor,*app\height * backingScaleFactor)
  glCheckError("Set Viewport")
; 
;   glDepthMask(#GL_TRUE);
;   glCheckError("Set DEPTH MASK")
  glClearColor(Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1.0)
  glCheckError("Set CLEAR COLOR")
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
;   glDepthMask(#GL_FALSE)
;   glCheckError("DEPTH MASK")
;   Framebuffer::Unbind(*buffer)
  ;   Framebuffer::BlitTo(*buffer,#Null,#GL_COLOR_BUFFER_BIT,#GL_NEAREST)
;   glCheckError("DRAW")
;   Framebuffer::BlitTo(*buffer, #Null, #GL_COLOR_BUFFER_BIT, #GL_NEAREST)
;   glCheckError("BLIT") 
  GLContext::FlipBuffer(*viewport\context)
  glCheckError("FLIP")
 

EndProcedure
    
Define model.m4f32
; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  *app = Application::New("Test",800,800)

  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  GLContext::GetOpenGLVersion(*viewport\context)
  
  Matrix4::SetIdentity(model)

;   *buffer = Framebuffer::New("Color",*app\width,*app\height)
  

  *s_simple = Program::NewFromName("simple")

  ;Define *compo.Framebuffer::Framebuffer_t = Framebuffer::New("Compo",GadgetWidth(gadget),GadgetHeight(gadget))
  
;   Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
;   Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH24_STENCIL8)
;   Debug "ATTACH TEXTURE + RENDER"
;   GLCheckError("BIND OUTPUT BEFORE")
; ;   Framebuffer::BindOutput(*buffer)
;   GLCheckError("BIND OUTPUT AFTER")
;   Debug "ATTACH TEXTURE + RENDER"
; ;   Framebuffer::BlitTo(*buffer, #Null, #GL_COLOR_BUFFER_BIT, #GL_NEAREST)
  
  Define TextureName.GLuint
  glGenTextures(1, @TextureName)
	glActiveTexture(#GL_TEXTURE0)
  glBindTexture(#GL_TEXTURE_2D, TextureName);
	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_BASE_LEVEL, 0)
	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAX_LEVEL, 0)
	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
	glTexImage2D(#GL_TEXTURE_2D, 0, #GL_RGBA8, *app\width, *app\height, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, 0)

	glBindTexture(#GL_TEXTURE_2D, 0);
		
		
  Dim FramebufferName.GLuint(2)
  Define ColorRenderbufferName.GLuint
  glGenFramebuffers(2, @FramebufferName(0))

		glGenRenderbuffers(1, @ColorRenderbufferName)
		glBindRenderbuffer(#GL_RENDERBUFFER, ColorRenderbufferName);
		glRenderbufferStorage(#GL_RENDERBUFFER, #GL_RGBA8, *app\width, *app\height)

		glBindFramebuffer(#GL_FRAMEBUFFER, FramebufferName(0))
		glFramebufferRenderbuffer(#GL_FRAMEBUFFER, #GL_COLOR_ATTACHMENT0, #GL_RENDERBUFFER, ColorRenderbufferName)
		If Not glCheckFramebufferStatus(#GL_FRAMEBUFFER) = #GL_FRAMEBUFFER_COMPLETE
		  MessageRequester("FAIL", "CREATE FRAME BUFFER")
		EndIf
		
		glBindFramebuffer(#GL_FRAMEBUFFER, 0);

		glBindFramebuffer(#GL_FRAMEBUFFER, FramebufferName(1))
		glFramebufferTexture(#GL_FRAMEBUFFER, #GL_COLOR_ATTACHMENT0, TextureName, 0)
		If Not glCheckFramebufferStatus(#GL_FRAMEBUFFER) = #GL_FRAMEBUFFER_COMPLETE
		  MessageRequester("FAIL", "CREATE TEXTURE BUFFER")
		EndIf
		
		glBindFramebuffer(#GL_FRAMEBUFFER, 0);
  
		*torus = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
  Define *geom.Geometry::PolymeshGeometry_t = *torus\geom
;   Define *indices = *geom\a_faceindices
;   Define *positions = *geom\a_positions
;   
;   Define msg.s = CArray::GetAsString(*indices, "INDICES : ")+Chr(10)
;   msg + CArray::GetAsString(*positions, "POSITIONS : ")+Chr(10)
;   MessageRequester("CUBE", msg)
;   *cloud = PointCloud::New("Cloud",Shape::#SHAPE_TORUS)
  Polymesh::Setup(*torus)
;   PointCloud::Setup(*cloud,*s_simple)
  
  Application::Loop(*app,@Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 145
; FirstLine = 93
; Folding = -
; EnableThread
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
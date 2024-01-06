EnableExplicit

XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit

Global *camera.Camera::Camera_t = #Null
Global *app.Application::Application_t = #Null
Global *viewport.ViewportUI::ViewportUI_t = #Null
Global *layer.LayerDefault::LayerDefault_t

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLContext::SetContext(*viewport\context)
  Protected *light.Light::Light_t = CArray::GetValuePtr(*app\scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
;   Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
;   Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
;   Object3D::SetLocalTransform(*light, *t)
;   
  
  Scene::Update(*app\scene)
  
  
  Protected *s.Program::Program_t = *viewport\context\shaders("reflection")
  glUseProgram(*s\pgm)
  glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
  
LayerDefault::Draw(*layer, *app\scene)
;   Application::Draw(*app, *layer, *app\camera)
  ViewportUI::Blit(*viewport, *layer\framebuffer)

  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85 / *viewport\context\width
  Define ratio.f = *viewport\context\width / *viewport\context\height
  FTGL::Draw(*viewport\context\writer,"Nb Vertices : 666",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  *app = Application::New("TestCubeMap",800,600)
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"Test Cube Map", *app\camera, *app\handle)     
    GLContext::SetContext(*viewport\context)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  *app\scene = Scene::New()
  
  GLContext::SetContext(*viewport\context)
  *layer = LayerDefault::New(800,600,*viewport\context,*app\camera)

  FTGL::Init()
  
  Define *m.CubeMap::CubeMap_t = CubeMap::New("../../cube_maps/ldr/stpeters_cross.tif")
  CubeMap::Setup(*m)
  
  Global *s_polymesh.Program::Program_t = Program::NewFromName("polymesh")
  Global *s_reflection.Program::Program_t = Program::NewFromName("reflection")
  Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
  Scene::AddChild(*app\scene, *bunny)
  Scene::Setup(*app\scene)
  Define shader.GLuint
  Define offset.m4f32
  
  Application::Loop(*app, @Draw())
  
  
  
EndIf

; glDeleteBuffers(1,@vbo)
; glDeleteVertexArrays(1,@vao)
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 38
; FirstLine = 22
; Folding = -
; EnableXP
; Executable = reflected.exe
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
  GLContext::SetContext(*app\context)
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
;   Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
;   Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
;   Object3D::SetLocalTransform(*light, *t)
;   
  
  Scene::Update(Scene::*current_scene)
  
  
  Protected *s.Program::Program_t = *app\context\shaders("polymesh")
  glUseProgram(*s\pgm)
  glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
   
  Application::Draw(*app, *layer, *app\camera)
  ViewportUI::Blit(*viewport, *layer\datas\buffer)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85 / *app\context\width
  Define ratio.f = *app\context\width / *app\context\height
  FTGL::Draw(*app\context\writer,"Nb Vertices : 666",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  GLContext::FlipBuffer(*app\context)

 EndProcedure

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  *app = Application::New("TestCubeMap",800,600)
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"Test Cube Map", *app\camera, *app\handle)     
    Application::SetContext(*app, *viewport\context)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Scene::*current_scene = Scene::New()
  
  GLContext::SetContext(*app\context)
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)

  FTGL::Init()
  
  Define *m.CubeMap::CubeMap_t = CubeMap::New("../../cube_maps/ldr/stpeters_cross.tif")
  CubeMap::Setup(*m)
  
  Global *s_polymesh.Program::Program_t = Program::NewFromName("polymesh")
  Global *s_reflection.Program::Program_t = Program::NewFromName("reflection")
  Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_SPHERE)
  Polymesh::Setup(*bunny,*s_polymesh)
  Define shader.GLuint
  Define offset.m4f32
  
  Application::Loop(*app, @Draw())
  
  
  
EndIf

; glDeleteBuffers(1,@vbo)
; glDeleteVertexArrays(1,@vao)
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 58
; FirstLine = 25
; Folding = -
; EnableXP
; Executable = reflected.exe

XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
UseModule OpenGLExt

EnableExplicit

Global *s_simple.Program::Program_t

Global *cloud.PointCloud::PointCloud_t
Global *torus.Polymesh::Polymesh_t
Global *app.Application::Application_t
Global *layer.LayerDefault::LayerDefault_t
Global *viewport.ViewportUI::ViewportUI_t

Procedure Draw(*app.Application::Application_t)
  LayerDefault::Draw(*layer,*app\context)
  
  Protected sx.f = 0.004
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  FTGL::Draw(*app\context\writer,"Hello everybody,",-1,0.9,sx,sx)
  FTGL::Draw(*app\context\writer,"This is Font Drawing in OpenGL",-1,0.75,sx,sx)
  FTGL::Draw(*app\context\writer,"Using FreeType C Library",-1,0.6,sx,sx)
  
  ViewportUI::FlipBuffer(*viewport)
  
EndProcedure
    
Define model.m4f32
; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  FTGL::Init()
  *app = Application::New("FTGL",800,600)
  Global *scene = Scene::New()
  Scene::*current_scene = *scene
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"Viewport3D")
    *app\context = GLContext::New(0,#False,*viewport\gadgetID)
    *viewport\camera = *app\camera
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Debug "Camera :: "+Str(*app\camera)
  
  Matrix4::SetIdentity(@model)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *s_simple = *app\context\shaders("simple")

  *layer.LayerDefault::LayerDefault_t = LayerDefault::New(*app\width,*app\height,*app\context,*app\camera)
  LayerDefault::Setup(*layer)

  *torus = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
  *cloud = PointCloud::New("Cloud",Shape::#SHAPE_SPHERE)
;   Polymesh::Setup(*torus,*s_simple)
;   PointCloud::Setup(*cloud,*s_simple)
  Global *model.Model::Model_t = Model::New("Test")
  Object3D::AddChild(*model,*torus)
  Object3D::AddChild(*model,*cloud)
  
  Scene::AddModel(*scene,*model)
  Scene::Setup(*scene,*app\context)
  
  Application::Loop(*app,@Draw())
EndIf
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 28
; FirstLine = 14
; Folding = -
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=1
; EnableUnicode
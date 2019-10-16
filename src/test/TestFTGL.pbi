
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

Global *cloud.PointCloud::PointCloud_t
Global *torus.Polymesh::Polymesh_t
Global *app.Application::Application_t
Global *layer.LayerDefault::LayerDefault_t
Global *viewport.ViewportUI::ViewportUI_t

Procedure PointToScreen(mouse_x.f, mouse_y.f, width.f, height.f)
  ; 3d Normalised Device Coordinates
  Define x.f = (2.0 * mouse_x) / width - 1.0
  Define y.f = 1.0 - (2.0 * mouse_y) / height
  Define z.f = 1.0
  Define ray_nds.Math::v3f32
  Vector3::Set(ray_nds, x, y, z)
  
  ; 4d Homogeneous Clip Coordinates
  Define ray_clip.Math::v4f32
  Vector4::Set(ray_clip, ray_nds\x, ray_nds\y, -1.0, 1.0)
  
  ; 4d Eye (Camera) Coordinates
  Define ray_eye.Math::v4f32
  Define inv_proj.Math::m4f32
  Matrix4::Inverse(inv_proj, *app\camera\projection)
  Vector4::MulByMatrix4(ray_eye, ray_clip, inv_proj,#False)
  ray_eye\x = -1.0
  ray_eye\y = 0.0
  
  ; world coordinates
  Define inv_view.Math::m4f32
  Matrix4::Inverse(inv_view, *app\camera\view)
  Define ray_world.Math::v3f32
  Vector3::MulByMatrix4(ray_world, ray_eye, inv_view)
  Vector3::NormalizeInPlace(ray_world)
EndProcedure



Procedure Draw(*app.Application::Application_t)
  LayerDefault::Draw(*layer,*app\context)
  
  Define *geom.Geometry::PolymeshGeometry_t = *torus\geom
  
  *app\context\writer\background = #False
  Protected sx.f = 0.001
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define i
  Define *p.Math::v3f32, proj.v3f32
  
  
  For i=0 To *geom\nbpoints
    *p = CArray::GetValue(*geom\a_positions, i)
    ViewportUI::Project(*viewport,*p,proj)
    FTGL::SetColor(*app\context\writer,Math::Random_0_1(), Math::Random_0_1(),Math::Random_0_1(),1.0)
    FTGL::Draw(*app\context\writer, "HELLO", proj\x, proj\y,sx,sx)
  Next
  
  FTGL::Draw(*app\context\writer,"Hello everybody,",-1,0.9,sx,sx)
  FTGL::Draw(*app\context\writer,"This is Font Drawing in OpenGL",-1,0.75,sx,sx)
  FTGL::Draw(*app\context\writer,"Using FreeType C Library",-1,0.6,sx,sx)
  FTGL::EndDraw(*app\context\writer)
  GLContext::FlipBuffer(*app\context)
  
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
    *viewport = ViewportUI::New(*app\window\main,"Viewport3D", *app\camera, *app\handle)
    *app\context = *viewport\context
    *viewport\camera = *app\camera
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Debug "Camera :: "+Str(*app\camera)
  
  Matrix4::SetIdentity(model)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *s_simple = *app\context\shaders("simple")

  *layer.LayerDefault::LayerDefault_t = LayerDefault::New(*app\width,*app\height,*app\context,*app\camera)
  LayerDefault::Setup(*layer)
  Application::AddLayer(*app, *layer)

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
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 57
; FirstLine = 47
; Folding = -
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=1
; EnableUnicode
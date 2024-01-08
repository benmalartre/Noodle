


XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Delaunay.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit


Global width.i
Global height.i

Global *model.Model::Model_t
Global *mesh.Polymesh::Polymesh_t
Global *drawer.Drawer::Drawer_t

Global *default.LayerDefault::LayerDefault_t
Global *shadows.LayerShadowMap::LayerShadowMap_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *defered.LayerDefered::LayerDefered_t
Global *defshadows.LayerShadowDefered::LayerShadowDefered_t
Global *ssao.LayerSSAO::LayerSSAO_t
Global *quad.ScreenQuad::ScreenQuad_t

Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.d


Procedure RandomLine()
  Protected seed.v3f32
  
EndProcedure


; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
  width = WindowWidth(window,#PB_Window_InnerCoordinate)
  height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLEnable(#GL_DEPTH_TEST)
 GLContext::SetContext(*viewport\context)
  Scene::Update(*app\scene)  
  LayerDefault::Draw(*default, *app\scene, *viewport\context)
;   LayerGBuffer::Draw(*gbuffer, *app\scene, *viewport\context)
;   LayerShadowMap::Draw(*shadows, *app\scene, *viewport\context)
;   LayerDefered::Draw(*defered, *app\scene,  *viewport\context)
;   LayerShadowDefered::Draw(*defshadows, *app\scene, *viewport\context)
  
  ViewportUI::Blit(*viewport, *default\framebuffer)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*viewport\context\writer,"Test Shadow Map",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*viewport\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure
 
 Define useJoystick.b = #False
 width = 800
 height = 800
 
 Globals::Init()
 FTGL::Init()
 

 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("Test Delaunay Triangulation",width,height)
   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"Test Shadow", *app\camera, *app\handle)     
   
  EndIf

  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  
  *model = Model::New("Model")
  
  Define *grid = Polymesh::New("Grid", Shape::#SHAPE_GRID)
  *mesh = Polymesh::New("Mesh", Shape::#SHAPE_BUNNY)
  *drawer = Drawer::New("Drawer")
  
  Define *delaunay.Delaunay::Delaunay_t = AllocateStructure(Delaunay::Delaunay_t)
  Define m.m4f32
  Matrix4::SetFromOther(m, *app\camera\view)
  m\v[12] = 0.0
  m\v[13] = 0.0
  m\v[14] = 0.0
  
  Define *points.CArray::CArrayV3F32 = CARray::New(CARray::#ARRAY_V3F32)
  Define *p.v3f32
  Define i
  Define N = 10240
  CArray::SetCount(*points, N)
  For i = 0 To N-1
    *p = CArray::GetValue(*points, i)
    *p\x = Random_0_1() - 0.5
    *p\z = Random_0_1() - 0.5
  Next
  
  Delaunay::Init(*delaunay, *mesh\geom\a_positions, m)
;   Delaunay::Init(*delaunay, *points, Matrix4::IDENTITY())
  
  Define *points.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
  Define n = ArraySize(*delaunay\points()), i
  Define *p.v3f32
  CArray::SetCount(*points, n)
  For i = 0 To n - 1
    *p = CArray::GetValue(*points, i)
    *p\x = *delaunay\points(i)\x
    *p\z = *delaunay\points(i)\y
  Next
  
  Define *item.Drawer::Item_t = Drawer::AddPoints(*drawer, *points)
  Define color.c4f32
  Color::Set(color, 1,0,0.5,1)
  Drawer::SetColor(*item, color)
  Drawer::SetSize(*item, 10.0)
  
  Define *triangle.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
  Define *colors.CArray::CArrayC4F32 = CArray::New(CArray::#ARRAY_C4F32)
  CArray::SetCount(*triangle, 3 * ArraySize(*delaunay\triangles()))
  CArray::SetCount(*colors, 3 * ArraySize(*delaunay\triangles()))
  For i = 0 To ArraySize(*delaunay\triangles())/3 - 1
    *p = CArray::GetValue(*triangle, i * 3)
    *p\x = *delaunay\points(*delaunay\triangles(i*3))\x
    *p\y = 0.1
    *p\z = *delaunay\points(*delaunay\triangles(i*3))\y
    
    *p = CArray::GetValue(*triangle, i * 3 + 1)
    *p\x = *delaunay\points(*delaunay\triangles(i*3+1))\x
    *p\y = 0.1
    *p\z = *delaunay\points(*delaunay\triangles(i*3+1))\y
    
    *p = CArray::GetValue(*triangle, i * 3 + 2)
    *p\x = *delaunay\points(*delaunay\triangles(i*3+2))\x
    *p\y = 0.1
    *p\z = *delaunay\points(*delaunay\triangles(i*3+2))\y
    
    Color::Set(color, Random_0_1(), Random_0_1(), Random_0_1(), 1)
    CArray::SetValue(*colors, i * 3 + 0, color)
    CArray::SetValue(*colors, i * 3 + 1, color)
    CArray::SetValue(*colors, i * 3 + 2, color)
  Next
  
  
  
  *item = Drawer::AddColoredTriangle(*drawer, *triangle, *colors)
  
  Object3D::AddChild(*model, *drawer)
  Object3D::AddChild(*model, *grid)
;   Object3D::AddChild(*model, *mesh)
  
  Scene::AddModel(*app\scene,*model)
  
  Scene::Setup(*app\scene)
  
  *default = LayerDefault::New(width,height,*viewport\context,*app\camera)
  
  
; ReDim *delaunay\points(3)
; ReDim *delaunay\triangles(1)
; 
; Define p.Math::v2f32
; 
; Vector2::Set(*delaunay\points(0), -5, 0)
; Vector2::Set(*delaunay\points(1), 0, 5)
; Vector2::Set(*delaunay\points(2), 5, 0)
; 
; Delaunay::SetupTriangle(*delaunay, *delaunay\triangles(0), 0, 1, 2)
; 
; Vector2::Set(p, 2, 2)
; Debug Delaunay::IsInCircle(*delaunay, p, *delaunay\triangles(0))
; Vector2::Set(p, -5, -5)
; Debug Delaunay::IsInCircle(*delaunay, p, *delaunay\triangles(0))

; 
;   Define *model.Model::Model_t = Scene::CreateMeshGrid(12,6,12, Shape::#SHAPE_TORUS)
;  
;   *ground = Polymesh::New("Ground",Shape::#SHAPE_GRID)
;   Transform::SetScaleFromXYZValues(*ground\localT, 3, 3, 3)
;   Object3D::SetLocalTransform(*ground, *ground\localT)
; 
;   Object3D::AddChild(*model,*ground)
;   
;   Define *light.Light::Light_t = Light::New("Light",Light::#Light_Infinite)
;   Vector3::Set(*light\pos,4,8,2)
;   Vector3::Set(*light\color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
;   Object3D::AddChild(*model,*light)
;   
;   Scene::AddModel(*app\scene,*model)
;   
;   Scene::Setup(*app\scene)
;   
;   
;   *default = LayerDefault::New(width,height,*viewport\context,*app\camera)
;   *gbuffer = LayerGBuffer::New(width,height,*viewport\context,*app\camera)
;   *shadows= LayerShadowMap::New(1024,1024,*viewport\context,*light)
;   *defered = LayerDefered::New(width,height,*viewport\context,*gbuffer\framebuffer,*shadows\framebuffer,*app\camera)
;   *defshadows = LayerShadowDefered::New(width,height,*viewport\context,*gbuffer\framebuffer,*shadows\framebuffer,*app\camera)
;  
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 131
; FirstLine = 104
; Folding = -
; EnableXP
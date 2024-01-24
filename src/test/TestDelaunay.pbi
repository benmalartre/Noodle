


XIncludeFile "../core/Application.pbi"
XIncludeFile "../objects/Delaunay.pbi"


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
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.d

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLEnable(#GL_DEPTH_TEST)
 GLContext::SetContext(*viewport\context)
  Scene::Update(*app\scene)  
  LayerDefault::Draw(*default, *app\scene, *viewport\context)
  
  ViewportUI::Blit(*viewport, *default\framebuffer)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*viewport\context\writer,"Test Delaunay",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*viewport\context\writer,"Took : "+StrD(T),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure
 
 width = 800
 height = 800
 
 Globals::Init()
 FTGL::Init()
 

 If Time::Init()
   
   Log::Init()
   *app = Application::New("Test Delaunay Triangulation",width,height)
   *viewport = ViewportUI::New(*app\window\main,"Test Shadow", *app\camera, *app\handle)     

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
  
  Define startT.d = Time::Get()
  Delaunay::Init(*delaunay, *mesh\geom\a_positions, m)
  T = Time::Get() - startT
  
  Define *points.CArray::CArrayV3F32 = CArray::New(Types::#TYPE_V3F32)
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
  Drawer::SetSize(*item, 2.0)
  
  Define *triangle.CArray::CArrayV3F32 = CArray::New(Types::#Type_V3F32)
  Define *colors.CArray::CArrayC4F32 = CArray::New(Types::#Type_C4F32)
  CArray::SetCount(*triangle, 3 * ArraySize(*delaunay\triangles()))
  CArray::SetCount(*colors, 3 * ArraySize(*delaunay\triangles()))
  Define numTriangles = ArraySize(*delaunay\triangles())/3
  Define s.f = 1.0 / numTriangles
  For i = 0 To numTriangles - 1
    *p = CArray::GetValue(*triangle, i * 3)
    *p\x = *delaunay\points(*delaunay\triangles(i*3))\x
    *p\z = *delaunay\points(*delaunay\triangles(i*3))\y
    
    *p = CArray::GetValue(*triangle, i * 3 + 1)
    *p\x = *delaunay\points(*delaunay\triangles(i*3+1))\x
    *p\z = *delaunay\points(*delaunay\triangles(i*3+1))\y
    
    *p = CArray::GetValue(*triangle, i * 3 + 2)
    *p\x = *delaunay\points(*delaunay\triangles(i*3+2))\x
    *p\z = *delaunay\points(*delaunay\triangles(i*3+2))\y
    
    Color::Set(color, i * s, 1 - i * s, 0.75, 1)
    CArray::SetValue(*colors, i * 3 + 0, color)
    CArray::SetValue(*colors, i * 3 + 1, color)
    CArray::SetValue(*colors, i * 3 + 2, color)
  Next
  
  *item = Drawer::AddColoredTriangle(*drawer, *triangle, *colors)
  Drawer::SetWireframe(*item, #True)
  Object3D::AddChild(*model, *drawer)
;   Object3D::AddChild(*model, *grid)
;   Object3D::AddChild(*model, *mesh)
  
  Scene::AddModel(*app\scene,*model)
  
  Scene::Setup(*app\scene)
  
  *default = LayerDefault::New(width,height,*viewport\context,*app\camera)
  GLContext::AddFramebuffer(*viewport\context, *default\framebuffer)
  
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 67
; FirstLine = 89
; Folding = -
; EnableXP
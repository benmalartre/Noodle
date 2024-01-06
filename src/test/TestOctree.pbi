XIncludeFile "../core/Application.pbi"

EnableExplicit

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

Global width = 800
Global height = 600

Global *s_simple.Program::Program_t
Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t
Global *torus.Polymesh::Polymesh_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *octree.Octree::Octree_t
Global *mesh.Polymesh::Polymesh_t
Global *geom.Geometry::PolymeshGeometry_t
Global *query.Locator::Locator_t

Procedure PolygonSoup()
  Protected *mesh.Polymesh::Polymesh_t = Polymesh::New("SOUP", Shape::#SHAPE_None)
  Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  Protected *topo.Geometry::Topology_t = Topology::New()
  
  ;   PolymeshGeometry::TeapotTopology(*topo)
  Topology::Sphere(*topo, 2,64 ,32)
  Protected numTopos.i = 12
  
  Protected *matrices.CArray::CArrayM4F32 = CArray::New(CARray::#ARRAY_M4F32)
  CArray::SetCount(*matrices, numTopos)
  Define i
  Define p.v3f32
  Define s.v3f32
  Define *m.m4f32
  RandomSeed(666)
  For i=0 To numTopos-1
    Vector3::Set(p, Random(50)-25, Random(50)-25, Random(50)-25)
    *m = CArray::GetPtr(*matrices, i)
    Matrix4::SetIdentity(*m)
    Vector3::Set(s, 1,1,1);Random(4)+2,Random(4)+2,Random(4)+2)
    Matrix4::SetScale(*m, s)
    Matrix4::SetTranslation(*m,   p)
  Next
  
  Protected *topos.CArray::CArrayPtr = CArray::New(CArray::#ARRAY_PTR)
  Topology::TransformArray(*topo, *matrices, *topos)
  Topology::MergeArray(*topo, *topos)
  
  PolymeshGeometry::Set2(*geom, *topo)
  Object3D::Freeze(*mesh)
  
  For i=0 To numTopos-1
    Topology::Delete(CArray::GetValuePtr(*topos, i))
  Next
  CArray::Delete(*topos)
  Topology::Delete(*topo)
  ProcedureReturn *mesh
;   Define *merged.Polymesh::Polymesh_t = Polymesh::New("Merged",Shape::#SHAPE_NONE)
;   Define *mgeom.Geometry::PolymeshGeometry_t = *merged\geom
;   
;   Define i
;       
;   Define *bgeom.Geometry::PolymeshGeometry_t = *bunny\geom
;   
;   Define *outtopo.CArray::CArrayPtr = CArray::newCArrayPtr()
;   Define *matrices.CArray::CarrayM4F32 = CArray::newCArrayM4F32()
;   Define m.m4f32
;   Define pos.v3f32
;   
;   Matrix4::SetIdentity(@m)
;   
;   Define *loc.Geometry::Location_t
;   Define *pos.v3f32, *nrm.v3f32
;   Define scl.v3f32
;   Define size.f
;   For i=0 To CArray::GetCount(*samples)-1
;     *loc = CArray::GetValuePtr(*samples,i)
;     *pos = Location::GetPosition(*loc)
;     *nrm = Location::GetNormal(*loc)
;     size = Random(50)+32
;     Vector3::ScaleInPlace(*nrm, size/2)
;     Vector3::AddInPlace(*pos, *nrm)
;     Matrix4::SetIdentity(@m)
;     Matrix4::SetTranslation(@m,*pos)
;     
;     Vector3::Set(scl, size, size, size)
;     Matrix4::SetScale(@m, @scl)
;   CArray::Append(*matrices,@m)
;  Next
;   
;   Define *topo.Geometry::Topology_t = Topology::New(*bgeom\topo)
;   Topology::TransformArray(*topo,*matrices,*outtopo)
;   Topology::MergeArray(*topo,*outtopo)
;   PolymeshGeometry::Set2(*mgeom,*topo)
;   PolymeshGeometry::RandomColorByPolygon(*mgeom)
  
EndProcedure

Procedure TestHit()
  Protected *qp.v3f32 = *query\localT\t\pos
  
  Define loc.Geometry::Location_t
  Define i
  
  Define P = Drawer::AddPoint(*drawer, *qp)
  
  Drawer::SetSize(P, 12)
  Drawer::SetColor(P, Color::RED)
  
  Octree::ResetHits(*octree)
  Define radius.f 
  radius = Octree::GetClosestPoint(*octree, *qp, loc)
  If radius >= 0
    P = Drawer::AddPoint(*drawer, loc\p)
    Drawer::SetSize(P, 10)
    Drawer::SetColor(P, Color::GREEN)
    Define L = Drawer::AddLine(*drawer, *qp, loc\p)
    Drawer::SetColor(L, Color::GREEN)
  EndIf
  Octree::Draw(*octree, *drawer, *geom)
  Define m.m4f32
  Matrix4::SetIdentity(m)
  Define scl.v3f32

  Vector3::Set(scl, radius*2, radius*2, radius*2)
  Matrix4::SetScale(m, scl)
  Matrix4::SetTranslation(m, *qp)
  Define S = Drawer::AddSphere(*drawer, m)
  Drawer::SetColor(S, Color::PURPLE)
  Drawer::SetWireframe(S, #True)
  
  Define radius.f = Octree::GetClosestPoint(*octree, *qp, loc)
  If radius >= 0
    P = Drawer::AddPoint(*drawer, loc\p)
    Drawer::SetSize(P, 10)
    Drawer::SetColor(P, Color::GREEN)
    Define L = Drawer::AddLine(*drawer, *qp, loc\p)
    Drawer::SetColor(L, Color::RED)
  EndIf
  Define m.m4f32
  Matrix4::SetIdentity(m)
  Define scl.v3f32

  Vector3::Set(scl, radius*2, radius*2, radius*2)
  Matrix4::SetScale(m, scl)
  Matrix4::SetTranslation(m, *qp)
  Define S = Drawer::AddSphere(*drawer, m)
  Drawer::SetColor(S, Color::YELLOW)
  Drawer::SetWireframe(S, #True)

EndProcedure
 
Procedure Draw(*app.Application::Application_t)
  GLContext::SetContext(*viewport\context)
  *app\scene\dirty= #True
  
  Drawer::Flush(*drawer)
  TestHit()

  Scene::Update(*app\scene)
  Define numCells.l
;   
;   LayerDefault::Draw(*layer, *viewport\context)
; ;   FTGL::BeginDraw(*viewport\context\writer)
; ;   FTGL::SetColor(*viewport\context\writer,1,1,1,1)
; ;   Define ss.f = 0.85/*viewport\sizX
; ;   Define ratio.f = *viewport\sizX / *viewport\sizY
; ;   FTGL::Draw(*viewport\context\writer,"OCTREE : ",-0.9,0.9,ss,ss*ratio)
; ;   FTGL::SetColor(*viewport\context\writer,1,0.5,0.75,1)
; ;   FTGL::Draw(*viewport\context\writer,"Num Leaves : "+Str(numCells),-0.9,0.8,ss,ss*ratio)
; ;   FTGL::Draw(*viewport\context\writer, "RADIUS : "+Str(666), -0.9, 0.7, ss, ss*ratio)
; ;   
; ;   FTGL::EndDraw(*viewport\context\writer)
; ;   
;   GLContext::FlipBuffer(*viewport\context)
  

  *app\scene\dirty= #True
  
  Scene::Update(*app\scene)
;   GLContext::SetContext(*viewport\context)
  LayerDefault::Draw(*layer, *app\scene)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  
  Define ss.f = 0.85/*viewport\sizX
  Define ratio.f = *viewport\sizX / *viewport\sizy
  FTGL::Draw(*viewport\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  glDisable(#GL_BLEND)
  
 GLContext::FlipBuffer(*viewport\context)
  
EndProcedure




Time::Init()
Log::Init()

 *app = Application::New("Octree",width, height, #PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_SizeGadget)
  Application::AddShortcuts(*app)
 If Not #USE_GLFW
   *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)   
    View::SetContent(*app\window\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
EndIf
 

Define T.d = Time::Get()
*mesh.Polymesh::Polymesh_t = PolygonSoup();Polymesh::New("S", Shape::#SHAPE_SPHERE);
*drawer = Drawer::New()
Define polygonSoupT.d = Time::Get() - T
*query = Locator::New("QUERY")

*geom.Geometry::PolymeshGeometry_t = *mesh\geom
Geometry::ComputeBoundingBox(*geom)
Vector3::Echo(*geom\bbox\extend, "BBOX : ")

Define.v3f32 bmin, bmax
Vector3::Sub(bmin, *geom\bbox\origin, *geom\bbox\extend)
Vector3::Add(bmax, *geom\bbox\origin, *geom\bbox\extend)

Vector3::Echo(bmin, "octree bmin")
Vector3::Echo(bmax, "octree bmax")
*octree = Octree::New(bmin, bmax, 0)

T = Time::Get()
Octree::Build(*octree, *geom, 6)
Define buildOctreeT.d = Time::get() - T
T = Time::Get()
Octree::Draw(*octree, *drawer, *geom)
Define drawOctreeT.d = Time::get() - T
Define numCells.i = 0
Octree::NumCells(*octree, @numCells)
Octree::GetCells(*octree)


Define buildMessage.s = "Polygon Soup : "+StrD(polygonSoupT)+Chr(10)
buildMessage + "Build Octree : "+StrD(buildOctreeT)+Chr(10)
buildMessage + "Draw Octree : "+StrD(drawOctreeT)+Chr(10)
buildMessage + "Num Leaves : "+Str(numCells)+Chr(10)
buildMessage + "Num Triangles : "+Str(*geom\nbtriangles)+Chr(10)
Debug buildMessage

*app\scene = Scene::New()
GLContext::SetContext(*viewport\context)
*layer = LayerDefault::New(*viewport\sizX,*viewport\sizY,*viewport\context,*app\camera)
Global *root.Model::Model_t = Model::New("Model")
Object3D::AddChild(*root, *mesh)
Object3D::AddChild(*root, *drawer)
Object3D::AddChild(*root, *query)

Scene::AddModel(*app\scene, *root)

Define t.d = Time::Get()
Scene::Setup(*app\scene)
Scene::SelectObject(*app\scene, *query)
ViewportUI::SetHandleTarget(*viewport, *query)

Application::Loop(*app, @Draw())

Octree::Delete(*octree)
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 228
; FirstLine = 199
; Folding = -
; EnableThread
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
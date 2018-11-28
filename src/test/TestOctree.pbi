XIncludeFile "../core/Application.pbi"

EnableExplicit

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

Global *s_simple.Program::Program_t
Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t
Global *torus.Polymesh::Polymesh_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *octree.Octree::Octree_t
Global *mesh.Polymesh::Polymesh_t
Global *geom.Geometry::PolymeshGeometry_t
Global query.v3f32

Procedure PolygonSoup()
  Protected *mesh.Polymesh::Polymesh_t = Polymesh::New("SOUP", Shape::#SHAPE_None)
  Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  Protected *topo.Geometry::Topology_t = Topology::New()
  
  ;   PolymeshGeometry::TeapotTopology(*topo)
  PolymeshGeometry::SphereTopology(*topo, 1,256 ,128)
  Protected numTopos.i = 12
  
  Protected *matrices.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
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
  
  Protected *topos.CArray::CArrayPtr = CArray::newCArrayPtr()
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
  Vector3::RandomizeInPlace(query,0.5)
  Define loc.Geometry::Location_t
  Define i
  
  Define P = Drawer::AddPoint(*drawer, query)
  
  Drawer::SetSize(P, 12)
  Drawer::SetColor(P, Color::_RED())
  
  Octree::ResetHits(*octree)
  Define radius.f = Octree::GetClosestPoint(*octree, query, loc)
  If radius >= 0
    P = Drawer::AddPoint(*drawer, loc\p)
    Drawer::SetSize(P, 10)
    Drawer::SetColor(P, Color::_GREEN())
    Define L = Drawer::AddLine(*drawer, query, loc\p)
    Drawer::SetColor(L, Color::_WHITE())
  EndIf
  Octree::Draw(*octree, *drawer, *geom)
  Define m.m4f32
  Matrix4::SetIdentity(m)
  Define scl.v3f32

  Vector3::Set(scl, radius*2, radius*2, radius*2)
  Matrix4::SetScale(m, scl)
  Matrix4::SetTranslation(m, query)
  Define S = Drawer::AddSphere(*drawer, m)
  Drawer::SetColor(S, Color::_PURPLE())
  Drawer::SetWireframe(S, #True)
EndProcedure
 
Procedure Draw(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  Scene::*current_scene\dirty= #True
  
  Drawer::Flush(*drawer)
  TestHit()
  Scene::Update(Scene::*current_scene)
  Define numCells.l
;   Octree::NumCells(*octree, @numCells)
  LayerDefault::Draw(*layer, *app\context)
  


  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*viewport\width
  Define ratio.f = *viewport\width / *viewport\height
  FTGL::Draw(*app\context\writer,"OCTREE : ",-0.9,0.9,ss,ss*ratio)
  FTGL::SetColor(*app\context\writer,1,0.5,0.75,1)
  FTGL::Draw(*app\context\writer,"Num Leaves : "+Str(numCells),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*app\context\writer, "RADIUS : "+Str(666), -0.9, 0.7, ss, ss*ratio)
  
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)
EndProcedure




Time::Init()
Log::Init()

*app = Application::New("Octree",800, 800, #PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_SizeGadget)

If Not #USE_GLFW
  *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
  *app\context = *viewport\context
  *viewport\camera = *app\camera
  View::SetContent(*app\manager\main,*viewport)
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
EndIf

Define T.d = Time::Get()
*mesh.Polymesh::Polymesh_t = PolygonSoup()
Object3D::SetShader(*mesh, *app\context\shaders("polymesh"))
*drawer = Drawer::New()
Define polygonSoupT.d = Time::Get() - T


*geom.Geometry::PolymeshGeometry_t = *mesh\geom

Define.v3f32 bmin, bmax
Vector3::Sub(bmin, *geom\bbox\origin, *geom\bbox\extend)
Vector3::Add(bmax, *geom\bbox\origin, *geom\bbox\extend)


*octree = Octree::New(bmin.v3f32, bmax.v3f32, 0)
T = Time::Get()
Octree::Build(*octree, *geom, 6)
Define buildOctreeT.d = Time::get() - T
T = Time::Get()
Octree::Draw(*octree, *drawer, *geom)
Define drawOctreeT.d = Time::get() - T
Define numCells.i = 0
Octree::NumCells(*octree, @numCells)

Define buildMessage.s = "Polygon Soup : "+StrD(polygonSoupT)+Chr(10)
buildMessage + "Build Octree : "+StrD(buildOctreeT)+Chr(10)
buildMessage + "Draw Octree : "+StrD(drawOctreeT)+Chr(10)
buildMessage + "Num Leaves : "+Str(numCells)+Chr(10)
buildMessage + "Num Triangles : "+Str(*geom\nbtriangles)+Chr(10)

Vector3::Set(query, 1,2,1)
Define loc.Geometry::Location_t
Define i
Define numTests = 1024
T = Time::Get()
For i=0 To numTests-1
  Define hit = Octree::GetClosestPoint(*octree, query, loc)
Next
Define hitT.d = Time::Get() - T

Define P = Drawer::AddPoint(*drawer, query)

Drawer::SetSize(P, 12)
Drawer::SetColor(P, Color::_RED())
; If hit
  buildMessage + "HIT : "+Vector3::ToString(loc\p)+Chr(10)
  buildMessage + Str(numTests)+" Tests took : "+StrD(hitT)
  P = Drawer::AddPoint(*drawer, loc\p)
  Drawer::SetSize(P, 10)
  Drawer::SetColor(P, Color::_GREEN())
; EndIf


MessageRequester("TEST OCTREE : USE SSE "+Str(Bool(Defined(USE_SSE, #PB_Constant) And #USE_SSE)), buildMessage)

Scene::*current_scene = Scene::New()
*layer = LayerDefault::New(800,800,*app\context,*app\camera)
viewportUI::AddLayer(*viewport, *layer)
Global *root.Model::Model_t = Model::New("Model")
Object3D::AddChild(*root, *mesh)
Object3D::AddChild(*root, *drawer)

Scene::AddModel(Scene::*current_scene, *root)

Define t.d = Time::Get()
Scene::Setup(Scene::*current_scene, *app\context)


Application::Loop(*app, @Draw())

Octree::Delete(*octree)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 193
; FirstLine = 151
; Folding = -
; EnableThread
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
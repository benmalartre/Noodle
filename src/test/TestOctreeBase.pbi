XIncludeFile "../objects/Octree.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../core/Morton.pbi"
XIncludeFile "../core/Application.pbi"

UseModule Math
Global width = 800
Global height = 600
Global model.Math::m4f32

Global *mesh.Polymesh::Polymesh_t
Global *layer.LayerDefault::LayerDefault_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *drawer.Drawer::Drawer_t
Global *root.Model::Model_t
Global ray.Geometry::Ray_t
Global plane.Geometry::Plane_t
Global *octree.Octree::Octree_t
Global query.v3f32
Global cartesian.Morton::Point3D_t
Global matches.i

Procedure PolygonSoup(numTopos=9)
  Protected *mesh.Polymesh::Polymesh_t = Polymesh::New("SOUP", Shape::#SHAPE_None)
  Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  Protected *topo.Geometry::Topology_t = Topology::New()
  
  ;   PolymeshGeometry::TeapotTopology(*topo)
  PolymeshGeometry::SphereTopology(*topo, 1,64 ,32)
  
  Protected *matrices.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
  Protected *positions.CArray::CArrayV3F32 = CARray::newCArrayV3F32()
  CArray::SetCount(*matrices, numTopos)
  Define i
  Define p.v3f32
  Define s.v3f32
  Define *m.m4f32
  Define *p.v3f32
  RandomSeed(666)
  MathUtils::BuildCircleSection(*positions, numTopos, 8)
  For i=0 To numTopos-1
;     Vector3::Set(p, Random(50)-25, Random(50)-25, Random(50)-25)
    *m = CArray::GetPtr(*matrices, i)
    Matrix4::SetIdentity(*m)
    Vector3::Set(s, 1,1,1);Random(4)+2,Random(4)+2,Random(4)+2)
    Matrix4::SetScale(*m, s)
    *p = CArray::GetValue(*positions, i)
    Matrix4::SetTranslation(*m,   *p)
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
  
  CArray::Delete(*matrices)
  CArray::Delete(*positions)
  
  ProcedureReturn *mesh
EndProcedure


Procedure UpdateQuery()
  If Event() = #PB_Event_Gadget And EventGadget() = *viewport\gadgetID
    Protected mx.i = GetGadgetAttribute(*viewport\gadgetID, #PB_OpenGL_MouseX)
    Protected my.i = GetGadgetAttribute(*viewport\gadgetID, #PB_OpenGL_MouseY)
    Protected w.i = GadgetWidth(*viewport\gadgetID)
    Protected h.i = GadgetHeight(*viewport\gadgetID)
    
    Camera::MousePositionToRayDirection(*app\camera, mx, my, w, h, ray\direction)
    Vector3::SetFromOther(ray\origin, *app\camera\pos)
    
    Vector3::Set(plane\normal, 0,1,0)
    plane\distance = 0
;     Camera::GetViewPlaneNormal(*app\camera, plane\normal)
    Define distance.f
    If Ray::PlaneIntersection(ray, plane, @distance)
      Ray::GetIntersectionPoint(ray, distance, query)  
    EndIf
    
    Octree::RealToCartesian(*octree, query, cartesian)
    Octree::ClampCartesian(*octree, cartesian)
    Define morton = Morton::Encode3D(cartesian)
    Octree::ResetHits(*octree)
;     Define *c1 = Octree::GetClosestCell(*octree, query)
    Define *c2.Octree::Cell_t = Octree::GetCell(*octree, morton, query)
    If *c2
      Define *L = Drawer::AddLine(*drawer, query, *c2\bmin)
      Drawer::SetColor(*L, Color::_WHITE())
    EndIf
    
;     If *c1 = *c2
;       matches + 1
;     EndIf
    
  EndIf
  
  Define *Q = Drawer::AddPoint(*drawer, query)

    Drawer::SetSize(*Q, 8)
    Drawer::SetColor(*Q, Color::_YELLOW())
  EndProcedure
  
  
  Procedure BenchClosestCell(*octree, numTests.i)
    Define i
    Define T.d = Time::get()
    Define pnt.v3f32
    Define *c1.Octree::Cell_t
    Vector3::RandomizeInPlace(pnt,1)
    For i = 0 To numTests -1
      *c1 = Octree::GetClosestCell(*octree, pnt)
    Next
    Define E1.d = Time::Get() - T
    
    T.d = Time::get()
    
    Define morton.i 
    Define *c2.Octree::Cell_t
    For i = 0 To numTests -1
      Octree::RealToCartesian(*octree, pnt, cartesian)
      Octree::ClampCartesian(*octree, cartesian)
      morton = Morton::Encode3D(cartesian)
      
      *c2 = Octree::GetCell(*octree, morton, pnt)
    Next
    Define E2.d = Time::Get() - T
    
    MessageRequester("OCTREE BENCHMARK CLOSEST CELL", "NUM TESTS : "+Str(numTests)+Chr(10)+
                                                      "RECURSIVE : "+StrD(E1)+Chr(10)+
                                                      "MORTON : "+StrD(E2)+Chr(10)+
                                                      "C1 : "+Str(*c1)+Chr(10)+
                                                      "C2 : "+Str(*c2))
  EndProcedure
  


; Update
;--------------------------------------------
Procedure Update(*app.Application::Application_t)

  
  ViewportUI::SetContext(*viewport)
  
  Drawer::Flush(*drawer)
  Octree::Draw(*octree, *drawer, *mesh\geom)
  UpdateQuery()
  Scene::*current_scene\dirty = #True
  Scene::Update(Scene::*current_scene)
  
  ViewportUI::Draw(*viewport, *app\context)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Num Matches : "+Str(matches),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

 EndProcedure

Globals::Init()
FTGL::Init()
;--------------------------------------------
 If Time::Init()
   
   Log::Init()
   *app = Application::New("Test Octree Base",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI", *app\camera)
     
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *layer)

  Global *root.Model::Model_t = Model::New("Model")
  
  
  *root = Model::New("ROOT")
  *mesh = PolygonSoup();Polymesh::New("MESH", Shape::#SHAPE_SPHERE)
  PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
;   Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
;   PolymeshGeometry::SphereTopology(*geom\topo, 2, 512, 256)
;   PolymeshGeometry::Set2(*geom, *geom\topo)
  Object3D::Freeze(*mesh)
  *drawer = Drawer::New("DRAWER")
  Object3D::SetShader(*drawer, *app\context\shaders("drawer"))
  
  Define bmin.v3f32, bmax.v3f32
  Vector3::Sub(bmin, *mesh\geom\bbox\origin, *mesh\geom\bbox\extend)
  Vector3::Add(bmax, *mesh\geom\bbox\origin, *mesh\geom\bbox\extend)
  
  
  *octree = Octree::New(bmin, bmax, 0)
  
  Octree::Build(*octree, *mesh\geom, 6)
  Define numCells.i
  Octree::NumCells(*octree, @numCells)
  Octree::GetCells(*octree)
  
  BenchClosestCell(*octree, 1024)
 
  
;   Object3D::AddChild(*root, *mesh)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  
  
  Application::Loop(*app, @Update())

EndIf


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 185
; FirstLine = 173
; Folding = -
; EnableXP
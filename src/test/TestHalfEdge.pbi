; TEST HALF EDGE
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../core/Slot.pbi"

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
  Utils::BuildCircleSection(*positions, numTopos, 8)
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



Procedure GetNeighbors(*mesh.Geometry::PolymeshGeometry_t)
  Define *first.Geometry::HalfEdge_t
  Define *current.Geometry::HalfEdge_t
  NewList neighbors.i()
  Define i = 0

  For i=0 To *mesh\nbpoints - 1
    
    ClearList(neighbors())
    *first = *mesh\a_halfedges(CArray::getValueL(*mesh\a_vertexhalfedge, i))
    AddElement(neighbors())
    neighbors() = *first\opposite_he\vertex
    
    *current = *first\opposite_he\next_he

    While Not *first = *current
      AddElement(neighbors())
      neighbors() = *current\opposite_he\vertex
      *current = *current\opposite_he\next_he
    Wend

  Next

EndProcedure


Procedure DrawNeighbors(*geom.Geometry::PolymeshGeometry_t, *drawer.Drawer::Drawer_t, index.i)
  index = Random(*geom\nbpoints-1)
  Define *O = Drawer::AddPoint(*drawer, CArray::GetValue(*geom\a_positions, index))
  Drawer::SetSize(*O, 8)
  Drawer::SetColor(*O, Color::_RED())
  Define *neighbors.CArray::CArrayLong = CArray::newCArrayLong()
  Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  PolymeshGeometry::GetVertexNeighbors(*geom, index, *neighbors)
  CArray::SetCount(*positions, CArray::GetCount(*neighbors))
  Define i
  For i = 0 To *neighbors\itemCount - 1
    CopyMemory(CArray::GetValue(*geom\a_positions, CArray::GetValueL(*neighbors, i)), CArray::GetValue(*positions, i), SizeOf(Math::v3f32))
  Next
  
  Define *P = Drawer::AddPoints(*drawer, *positions)
  Drawer::SetSize(*P, 4)
  Drawer::SetColor(*P, Color::_GREEN())
  
  CArray::Delete(*neighbors)
  CArray::Delete(*positions)
EndProcedure


Procedure ComputeIslands(*mesh.Geometry::PolymeshGeometry_t)
  
  Dim visitedPoly.b(*mesh\nbpolygons)
  Dim visitedHalfEdge.b(*mesh\nbedges)
  Dim polygonIslandIndex.i(*mesh\nbpolygons)
  
  Define islandIndex = 0
  CArray::SetCount(*mesh\a_islands, *mesh\nbpoints)
  Define i
  Define *next.Geometry::HalfEdge_t
  Define *first.Geometry::HalfEdge_t
  NewList *queue.Geometry::HalfEdge_t()
  Define walk.b
  For i=0 To *mesh\nbedges-1
    Define *he.Geometry::HalfEdge_t = *mesh\a_halfedges(i)
    If Not visitedPoly(*he\face)
      Debug "--------------------------------------------------------------------"
      Debug "ADD POLYGON ISLAND : "+Str(islandIndex)
      *first = *he
      visitedPoly(*he\face) = #True
      AddElement(*queue())
      *queue() = *he
      walk = #True
      While walk
        If *he\opposite_he\face >= 0 And Not visitedPoly(*he\opposite_he\face)
          visitedPoly(*he\opposite_he\face) = #True
          *he = *he\opposite_he\prev_he
          AddElement(*queue())
          *queue() = *he
        Else
          *he = *he\next_he
          If *he = *queue()
            DeleteElement(*queue())
            If ListSize(*queue())
              *he = *queue()
            Else
              walk = #False
            EndIf
          EndIf
        EndIf
      Wend  
      islandIndex + 1
    EndIf
    
  Next
  
EndProcedure

Procedure PrintHalfdges(*geom.Geometry::PolymeshGeometry_t)
  Define  e
  Define *h.Geometry::HalfEdge_t
  For e = 0 To ArraySize(*geom\a_halfedges())-1
    *h = *geom\a_halfedges(e)
    Debug Str(*h\ID)+" : v=("+Str(*h\vertex)+","+Str(*h\next_he\vertex)+"), f="+Str(*h\face)+", n="+Str(*h\next_he\ID)+", p="+Str(*h\prev_he\ID)+", o="+Str(*h\opposite_he\ID)
;      Debug Str(*h\ID)+" : v=("+Str(*h\vertex)+"), f="+Str(*h\face)+", n="+Str(*h\next_he)+", p="+Str(*h\prev_he)+", o="+Str(*h\opposite_he)
  Next
EndProcedure


; Update
;--------------------------------------------
Procedure Update(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  
  Drawer::Flush(*drawer)
  DrawNeighbors(*mesh\geom, *drawer,0)

  Scene::*current_scene\dirty = #True
  Scene::Update(Scene::*current_scene)
  
  ViewportUI::Draw(*viewport, *app\context)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

EndProcedure

  


Globals::Init()
FTGL::Init()
;--------------------------------------------
 If Time::Init()
   
   Log::Init()
   *app = Application::New("Test Half Edge",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI", *app\camera)
     *app\context = *viewport\context
     
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
;   *mesh = Polymesh::New("MESH", Shape::#SHAPE_BUNNY)
;   *mesh\wireframe = #True
  Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
;   PolymeshGeometry::GridTopology(*geom\topo, 2,3,3)
;   PolymeshGeometry::Set2(*geom, *geom\topo)

  PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
  PrintHalfdges(*mesh\geom)
  PolymeshGeometry::ComputeIslands(*mesh\geom)
  PolymeshGeometry::RandomColorByIsland(*mesh\geom)
  GetNeighbors(*mesh\geom)
;   Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
;   PolymeshGeometry::SphereTopology(*geom\topo, 2, 512, 256)
;   PolymeshGeometry::Set2(*geom, *geom\topo)
  Object3D::Freeze(*mesh)
  *drawer = Drawer::New("DRAWER")
  Object3D::SetShader(*drawer, *app\context\shaders("drawer"))
  
  Define bmin.v3f32, bmax.v3f32
  Vector3::Sub(bmin, *mesh\geom\bbox\origin, *mesh\geom\bbox\extend)
  Vector3::Add(bmax, *mesh\geom\bbox\origin, *mesh\geom\bbox\extend)

 
  
  Object3D::AddChild(*root, *mesh)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  
  
  Application::Loop(*app, @Update())

EndIf


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 244
; FirstLine = 212
; Folding = --
; EnableXP
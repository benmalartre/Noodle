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

XIncludeFile "../core/Application.pbi"

UseModule Math
Global width = 1024
Global height = 720
Global model.Math::m4f32

Global *mesh.Polymesh::Polymesh_t
Global *layer.LayerDefault::LayerDefault_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *drawer.Drawer::Drawer_t
Global *root.Model::Model_t
Global *selected.CArray::CArrayLong = CArray::newCArrayLong()
Global rootIndex.i
Global numTopos = 7

Procedure PolygonSoup(numTopos=9)
  Protected *mesh.Polymesh::Polymesh_t = Polymesh::New("SOUP", Shape::#SHAPE_TEAPOT)
  Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  Define *topo = *geom\topo
;   PolymeshGeometry::BunnyTopology(*geom)
;   Define *topo = Topology::New()
;   Topology::Bunny(*topo)
  
  Protected *matrices.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
  Protected *positions.CArray::CArrayV3F32 = CARray::newCArrayV3F32()
  CArray::SetCount(*matrices, numTopos)
  Define i
  Define p.v3f32
  Define s.v3f32
  Define *m.m4f32
  Define *p.v3f32
  RandomSeed(666)
  Utils::BuildCircleSection(*positions, numTopos+1, 8)
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
;   Topology::Delete(*topo)
;   For i=0 To numTopos-1
;     Topology::Delete(CArray::GetValuePtr(*topos, i))
;   Next
;   
;   CArray::Delete(*topos)
;   

  CArray::Delete(*matrices)
  CArray::Delete(*positions)
  
  ProcedureReturn *mesh
EndProcedure

Procedure DrawSelected(*geom.Geometry::PolymeshGeometry_t)

  Define *O = Drawer::AddPoint(*drawer, CArray::GetValue(*geom\a_positions, rootIndex))
  Drawer::SetSize(*O, 8)
  Drawer::SetColor(*O, Color::_RED())
  Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*positions, CArray::GetCount(*selected))
  Define i
  For i = 0 To *selected\itemCount - 1
    CArray::SetValue(*positions, i, CArray::GetValue(*geom\a_positions, CArray::GetValueL(*selected, i)))
  Next
  
  Define *P = Drawer::AddPoints(*drawer, *positions)
  Drawer::SetSize(*P, 4)
  Drawer::SetColor(*P, Color::_GREEN())
  
  CArray::Delete(*positions)
EndProcedure


; Update
;--------------------------------------------
Procedure Update(*app.Application::Application_t)
  
  If Event() = #PB_Event_Gadget And EventGadget() = *viewport\gadgetID
    If EventType() = #PB_EventType_KeyDown
      Define key = GetGadgetAttribute(*viewport\gadgetID, #PB_OpenGL_Key)
      Select key
        Case #PB_Shortcut_Add
          PolymeshGeometry::GrowVertexNeighbors(*mesh\geom, *selected)
        Case #PB_Shortcut_Subtract
          PolymeshGeometry::ShrinkVertexNeighbors(*mesh\geom, *selected)
        Case #PB_Shortcut_Return
          rootIndex = Random(*mesh\geom\nbpoints - 1)
          CArray::SetCount(*selected,1)
          CARray::SetValueL(*selected, 0, rootIndex)
      EndSelect
    EndIf
  EndIf
  
  GLContext::SetContext(*app\context)
  glViewport(0,0,*app\context\width, *app\context\height)
  Drawer::Flush(*drawer)
  DrawSelected(*mesh\geom)

  Scene::*current_scene\dirty = #True
  Scene::Update(Scene::*current_scene)
  
  Application::Draw(*app, *layer)

;   FTGL::BeginDraw(*app\context\writer)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
;   FTGL::EndDraw(*app\context\writer)
  
  GLContext::FlipBuffer(*app\context)
  viewportUI::Blit(*viewport, *layer\buffer)

EndProcedure

  


Globals::Init()
FTGL::Init()
;--------------------------------------------
 If Time::Init()
   
   Log::Init()
   *app = Application::New("Test Half Edge",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI", *app\camera, *app\context)
     
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  GLContext::SetContext(*app\context)
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  Application::AddLayer(*app, *layer)

  Global *root.Model::Model_t = Model::New("Model")
  
  
  *root = Model::New("ROOT")
    *mesh = PolygonSoup(32);Polymesh::New("MESH", Shape::#SHAPE_SPHERE)
;   *mesh = Polymesh::New("MESH", Shape::#SHAPE_BUNNY)
;   *mesh\wireframe = #True
  Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
;   PolymeshGeometry::GridTopology(*geom\topo, 2,3,3)
;   PolymeshGeometry::Set2(*geom, *geom\topo)

  PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
  Debug "COMPUTE HALF EDGES OK"
  PolymeshGeometry::ComputeIslands(*mesh\geom)
  Debug "COMPUTE ISLANDS OK"
  PolymeshGeometry::RandomColorByIsland(*mesh\geom)
  Debug "COLOR BY ISLAND OK"
;   GetNeighbors(*mesh\geom)
;   Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
;   PolymeshGeometry::SphereTopology(*geom\topo, 2, 512, 256)
;   PolymeshGeometry::Set2(*geom, *geom\topo)
  Object3D::Freeze(*mesh)
  Debug "FREEZE OK"
  *drawer = Drawer::New("DRAWER")
  Object3D::SetShader(*drawer, *app\context\shaders("drawer"))
  
  Define bmin.v3f32, bmax.v3f32
  Vector3::Sub(bmin, *mesh\geom\bbox\origin, *mesh\geom\bbox\extend)
  Vector3::Add(bmax, *mesh\geom\bbox\origin, *mesh\geom\bbox\extend)

 
  
  Object3D::AddChild(*root, *mesh)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  
  ;   CArray::AppendL(*selected, 7)
  rootIndex = 7
  PolymeshGeometry::GetVertexNeighbors(*mesh\geom, rootIndex, *selected)
  Application::Loop(*app, @Update())

EndIf


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 130
; FirstLine = 93
; Folding = -
; EnableXP
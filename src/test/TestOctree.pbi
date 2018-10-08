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

Procedure PolygonSoup()
  Protected *mesh.Polymesh::Polymesh_t = Polymesh::New("SOUP", Shape::#SHAPE_None)
  Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  Protected *topo.Geometry::Topology_t = Topology::New()
  
  PolymeshGeometry::SphereTopology(*topo, 3,32,16)
  Protected numTopos.i = 128
  
  Protected *matrices.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
  CArray::SetCount(*matrices, numTopos)
  Define i
  Define p.v3f32
  Define *m.m4f32
  For i=0 To numTopos-1
    Vector3::Set(p, Random(50)-25, Random(50)-25, Random(50)-25)
    *m = CArray::GetPtr(*matrices, i)
    Matrix4::SetIdentity(*m)
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

 
Procedure Draw(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
  Define numCells.l
  Octree::NumCells(*octree, @numCells)
  LayerDefault::Draw(*layer, *app\context)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*viewport\width
  Define ratio.f = *viewport\width / *viewport\height
  FTGL::Draw(*app\context\writer,"OCTREE : ",-0.9,0.9,ss,ss*ratio)
  FTGL::SetColor(*app\context\writer,1,0.5,0.75,1)
  FTGL::Draw(*app\context\writer,"Num Leaves : "+Str(numCells),-0.9,0.8,ss,ss*ratio)
  
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
Define *mesh.Polymesh::Polymesh_t = PolygonSoup()
; Object3D::SetShader(*mesh, *app\context\shaders("polymesh"))
*drawer = Drawer::New()
Define polygonSoupT.d = Time::Get() - T


Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom

Define.v3f32 bmin, bmax
Vector3::Sub(bmin, *geom\bbox\origin, *geom\bbox\extend)
Vector3::Add(bmax, *geom\bbox\origin, *geom\bbox\extend)


*octree = Octree::New(@bmin.v3f32, @bmax.v3f32, 0)
T = Time::Get()
Octree::Build(*octree, *geom, 4)
Define buildOctreeT.d = Time::get() - T
T = Time::Get()
Octree::Draw(*octree, *drawer, *geom)
Define drawOctreeT.d = Time::get() - T

Define buildMessage.s = "Polygon Soup : "+StrD(polygonSoupT)+Chr(10)
buildMessage + "Build Octree : "+StrD(buildOctreeT)+Chr(10)
buildMessage + "Draw Octree : "+StrD(drawOctreeT)+Chr(10)

buildMessage + "Num Triangles : "+Str(*geom\nbtriangles)
MessageRequester("Octree", buildMessage)


Define *poisson.Poisson::Poisson_t = Poisson::New()
Define box.Geometry::Box_t
Define origin.v3f32, extend.v3f32
Vector3::Set(origin, 1,3,2)
Vector3::Set(extend, 12,12,12)
Box::Set(@box, @origin, @extend)

Scene::*current_scene = Scene::New()
*layer = LayerDefault::New(800,800,*app\context,*app\camera)
viewportUI::AddLayer(*viewport, *layer)
Global *root.Model::Model_t = Model::New("Model")
Object3D::AddChild(*root, *mesh)
Object3D::AddChild(*root, *drawer)

Scene::AddModel(Scene::*current_scene, *root)

Define t.d = Time::Get()
; Poisson::CreateGrid(*poisson, *mesh\geom\bbox,0.2)
; ; Define numSamples = Poisson::Sample(*poisson)
; Poisson::SignedDistances(*poisson, *mesh\geom)
; Poisson::Setup(*poisson, *drawer)
Scene::Setup(Scene::*current_scene, *app\context)


; Define str.s
; str + "#################### POISSON SAMPLING ######################"+Chr(10)
; str + " Generated "+Str(numSamples) + " Samples in "+StrD(Time::Get()-t)+" milliseconds"+Chr(10)
; str + "############################################################"+Chr(10)
; 
; MessageRequester("POISSON", str)

Application::Loop(*app, @Draw())

Octree::Delete(*octree)

;     
; Define model.m4f32
; ; Main
; ;--------------------------------------------
; If Time::Init()
;   Log::Init()
;   *app = Application::New("Test",800,600)
; 
;   If Not #USE_GLFW
;     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
;     *app\context = *viewport\context
;     *viewport\camera = *app\camera
;     View::SetContent(*app\manager\main,*viewport)
;     ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
;   EndIf
;   
;   Matrix4::SetIdentity(@model)
;   
;   Debug "Size "+Str(*app\width)+","+Str(*app\height)
;   Debug *app\width
;   Debug *app\height
;   *buffer = Framebuffer::New("Color",*app\width,*app\height)
;   
;   *s_simple = Program::NewFromName("simple")
; 
;   ;Define *compo.Framebuffer::Framebuffer_t = Framebuffer::New("Compo",GadgetWidth(gadget),GadgetHeight(gadget))
;   
;   Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
;   Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)
; 
;   *torus = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
;   *cloud = PointCloud::New("Cloud",Shape::#SHAPE_TORUS)
;   Polymesh::Setup(*torus,*s_simple)
;   PointCloud::Setup(*cloud,*s_simple)
;   
;   Application::Loop(*app,@Draw())
; EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 174
; FirstLine = 154
; Folding = -
; EnableThread
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
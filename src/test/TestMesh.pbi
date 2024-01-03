


XIncludeFile "../core/Application.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit

Global down.b
Global lmb_p.b
Global mmb_p.b
Global rmb_p.b
Global oldX.f
Global oldY.f
Global width.i
Global height.i

Global *torus.Polymesh::Polymesh_t
Global *teapot.Polymesh::Polymesh_t
Global *ground.Polymesh::Polymesh_t
Global *box.Polymesh::Polymesh_t
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t

Global *layer.LayerDefault::LayerDefault_t
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


Procedure RandomGround()
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Ground", Shape::#SHAPE_NONE)
  Protected *geom.Geometry::PolymeshGeometry_t = *ground\geom

  PolymeshGeometry::GridTopology(*geom, 100,100,100)
  
    Protected *topo.Geometry::Topology_t = *geom\topo
  Define i
  Define *p.v3f32
  For i=0 To CArray::GetCount(*topo\vertices)-1
    *p = CArray::GetValue(*topo\vertices, i)
    *p\x * 10
    *p\z * 10
    *p\y = (Sin(*p\x/100) *40) ;+ (Random(100)*0.1 - 5)) 
  Next
  PolymeshGeometry::Set2(*geom, *topo)
  Object3D::Freeze(*ground)
  ProcedureReturn *ground
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

  
  GLContext::SetContext(*viewport\context)
  *app\scene\dirty= #True
  
  Scene::Update(*app\scene)
  
 
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
  
  Define writer = *viewport\context\writer
  FTGL::BeginDraw(writer)
  FTGL::SetColor(writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(writer,"Testing Polymesh",-0.9,0.9,ss,ss*ratio)

  FTGL::EndDraw(writer)
  
  GLContext::FlipBuffer(*viewport\context)

;     

 EndProcedure
 
 Define useJoystick.b = #False
 width = 800
 height = 800
 
 Globals::Init()
 FTGL::Init()
 
 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("TestMesh",width,height)
   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"Test Mesh", *app\camera, *app\handle)     
   
  EndIf
  
  *quad = ScreenQuad::New()
  ScreenQuad::Setup(*quad,*viewport\context\shaders("bitmap"))

  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  
    
  *layer = LayerDefault::New(width,height,*viewport\context,*app\camera)
  Application::AddLayer(*app, *layer)
  
  Define pos.v3f32,scl.v3f32

  Global *root.Model::Model_t = Model::New("Model")


  *ground.Polymesh::Polymesh_t = RandomGround()
  

  
  *box = Polymesh::New("Box",Shape::#SHAPE_CUBE)
  
  Define *samples.CArray::CArrayLocation = CArray::New(CArray::#ARRAY_LOCATION)
  *samples\geometry = *ground\geom
  *samples\transform = *ground\globalT
  Sampler::SamplePolymesh(*ground\geom,*samples,256,7)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
  
  Define *merged.Polymesh::Polymesh_t = Polymesh::New("Merged",Shape::#SHAPE_NONE)
  *merged\wireframe = #False
  Define *mgeom.Geometry::PolymeshGeometry_t = *merged\geom
  
  Define *topos.CArray::CArrayPtr = CArray::New(CArray::#ARRAY_PTR)
  Define *ggeom.Geometry::PolymeshGeometry_t = *ground\geom
  Define *gtopo.Geometry::Topology_t = *ggeom\topo
  Define i
      
  Define *bgeom.Geometry::PolymeshGeometry_t = *bunny\geom
  
  Define *topos.CArray::CArrayPtr = CArray::New(CArray::#ARRAY_PTR)
  Define *matrices.CArray::CarrayM4F32 = CArray::New(CArray::#ARRAY_M4F32)
  Define m.m4f32
  Define pos.v3f32
    
  Define *loc.Geometry::Location_t
  Define *pos.v3f32, *nrm.v3f32
  Define scl.v3f32
  Define size.f = 7
  Define pos.v3f32, center.v3f32
  Vector3::Set(center, 0,5,0)
;   CArray::SetCount(*matrices, CArray::GetCount(*samples))
  For i=0 To CArray::GetCount(*samples)-1
    *loc = CArray::GetValue(*samples,i)
    Location::GetPosition(*loc,*ggeom,*ground\globalT)
    Location::GetNormal(*loc,*ggeom,*ground\globalT)
    Matrix4::SetIdentity(m)
    size = Random(50)+5
    Vector3::ScaleInPlace(*loc\n, size/2)
    Vector3::AddInPlace(*loc\p, *loc\n)
    Vector3::Randomize(pos, center, 12)
    Matrix4::SetIdentity(m)
    Matrix4::SetTranslation(m, *loc\p)
    
    Vector3::Set(scl, size, size, size)
    Matrix4::SetScale(m, scl)
   
    CArray::Append(*matrices,m)
;     CArray::SetValue(*matrices, i, m)
 Next
  
 Define *topo.Geometry::Topology_t = Topology::New(*bgeom\topo)
 
 
 Topology::TransformArray(*topo,*matrices,*topos)
  Topology::MergeArray(*topo,*topos)
 
  Define sT.d = Time::Get()
  PolymeshGeometry::Set2(*mgeom,*topo)
  Topology::Delete(*topo)
  
;   PolymeshGeometry::ComputeHalfEdges(*mgeom)
;   PolymeshGeometry::ComputeIslands(*mgeom)
;   PolymeshGeometry::RandomColorByIsland(*mgeom)
  Object3D::Freeze(*merged)
  
  Object3D::AddChild(*root,*merged)
  
  Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root,*bunny)
  
  Scene::AddModel(*app\scene,*root)
  Scene::Setup(*app\scene)
  ViewportUI::SetHandleTarget(*viewport, *merged)
 
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 226
; FirstLine = 177
; Folding = -
; EnableXP
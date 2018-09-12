


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


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

Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f


Procedure RandomGround()
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Ground", Shape::#SHAPE_GRID)
  Protected *geom.Geometry::PolymeshGeometry_t = *ground\geom
  Protected *topo.Geometry::Topology_t = *geom\topo
  
  PolymeshGeometry::GridTopology(*topo, 100,100,100)
  
  Define i
  Define *p.v3f32
  For i=0 To CArray::GetCount(*topo\vertices)-1
    *p = CArray::GetValue(*topo\vertices, i)
    *p\x * 10
    *p\z * 10
    *p\y = (Sin(*p\x/10) *4 ); + (Random(10)*0.1 - 0.5)) * Cos(*p\z *0.04 )  + Random(10)*0.25
  Next
  PolymeshGeometry::Set2(*geom, *topo)
  ProcedureReturn *ground
EndProcedure


; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
  View::OnEvent(*app\manager\main,Event())
  
  Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
  Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
  Object3D::SetLocalTransform(*light, *t)
  
  ViewportUI::SetContext(*viewport)
  Scene::Update(Scene::*current_scene)
  ViewportUI::Draw(*viewport, *app\context)
  
;   Protected *s.Program::Program_t = *app\context\shaders("polymesh")
;   glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)

 
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*bunny\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

 EndProcedure
 
 Define useJoystick.b = #False
 width = 800
 height = 600
 ; Main
 Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("TestMesh",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
     
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *layer)

  Global *root.Model::Model_t = Model::New("Model")
  
  
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

  *ground.Polymesh::Polymesh_t = RandomGround();Polymesh::New("Ground",Shape::#SHAPE_GRID)
  Object3D::SetShader(*ground,*s_polymesh)
  
  Define pos.v3f32,scl.v3f32
  
  *box = Polymesh::New("Box",Shape::#SHAPE_CUBE)
  
  Define *samples.CArray::CArrayPtr = CArray::newCArrayPtr()
  Sampler::SamplePolymesh(*ground\geom,*samples,64,7)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_TEAPOT)
  Object3D::SetShader(*bunny,*s_polymesh)
  
  Define *merged.Polymesh::Polymesh_t = Polymesh::New("Merged",Shape::#SHAPE_NONE)
  Define *mgeom.Geometry::PolymeshGeometry_t = *merged\geom
  
  Define *topos.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *ggeom.Geometry::PolymeshGeometry_t = *ground\geom
  Define *gtopo.Geometry::Topology_t = *ggeom\topo
  Define i
      
  Define *bgeom.Geometry::PolymeshGeometry_t = *bunny\geom
;   CArray::AppendPtr(*topos,*ggeom\topo)
;   Define m.m4f32
;   Define v.v3f32
;   Vector3::Set(@v,0,1,0)
;   Matrix4::SetIdentity(@m)
;   Matrix4::SetTranslation(@m,@v)
;   Topology::Transform(*bgeom\topo, @m)
;   CArray::AppendPtr(*topos,*bgeom\topo) 
;   
;   Topology::MergeArray(*mgeom\topo,*topos)
  
  Define *outtopo.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *matrices.CArray::CarrayM4F32 = CArray::newCArrayM4F32()
  Define m.m4f32
  Define pos.v3f32
  
;   Vector3::Set(@pos,0,7,0)
;   Matrix4::SetIdentity(@m)
;   Matrix4::SetTranslation(@m,@pos)
;   CArray::Append(*matrices,@m)
;   
;   Vector3::Set(@pos,2,7,4)
  Matrix4::SetIdentity(@m)
  
  Define *loc.Geometry::Location_t
  Define *pos.v3f32, *nrm.v3f32
  Define scl.v3f32
  Define size.f
  For i=0 To CArray::GetCount(*samples)-1
    *loc = CArray::GetValuePtr(*samples,i)
    *pos = Location::GetPosition(*loc)
    *nrm = Location::GetNormal(*loc)
    size = Random(70)/2
    Vector3::ScaleInPlace(*nrm, size)
    Vector3::AddInPlace(*pos, *nrm)
    Matrix4::SetIdentity(@m)
    Matrix4::SetTranslation(@m,*pos)
    
    Vector3::Set(@scl, size, size, size)
    Matrix4::SetScale(@m, @scl)
  CArray::Append(*matrices,@m)
 Next
  
  Define *topo.Geometry::Topology_t = Topology::New(*bgeom\topo)
  Topology::TransformArray(*topo,*matrices,*outtopo)
  Topology::MergeArray(*topo,*outtopo)
  PolymeshGeometry::Set2(*mgeom,*topo)
  Object3D::Freeze(*merged)
  Object3D::AddChild(*root,*merged)
  
  Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root,*bunny)
   Scene::AddModel(Scene::*current_scene,*root)
   Scene::Setup(Scene::*current_scene,*app\context)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 109
; FirstLine = 89
; Folding = -
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
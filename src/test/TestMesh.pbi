


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
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
Global *ftgl_drawer.FTGL::FTGL_Drawer

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
;   Vector3::Set(*light\pos, 5-Random(10),10,5-Random(10))
;   Light::Update(*light)
;   Vector3::Echo(*light\pos,"LIGHT POSITION")
  ViewportUI::SetContext(*viewport)
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer, *app\context)
;   LayerShadowMap::Draw(*shadows, *app\context)
;   LayerGBuffer::Draw(*gbuffer,*app\context)
  ;LayerDefered::Draw(*defered,*app\context)
;   LayerShadowDefered::Draw(*defshadows, *app\context)
  
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*ftgl_drawer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*ftgl_drawer,"Nb Vertices : "+Str(*bunny\geom\nbpoints),-0.9,0.9,ss,ss*ratio)

  glDisable(#GL_BLEND)
  
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
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  *shadows = LayerShadowMap::New(800,800,*app\context,CArray::GetValuePtr(Scene::*current_scene\lights, 0))
  *gbuffer = LayerGBuffer::New(800,600,*app\context,*app\camera)
  *defered = LayerDefered::New(800,600,*app\context,*gbuffer\buffer,*shadows\buffer,*app\camera)
  *defshadows = LayerShadowDefered::New(800,600,*app\context,*gbuffer\buffer, *shadows\buffer,*app\camera)
  Global *root.Model::Model_t = Model::New("Model")
  
  ; FTGL Drawer
  ;-----------------------------------------------------
  
  *ftgl_drawer = FTGL::New()
  
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

;   *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
;   *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
  *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
  Object3D::SetShader(*ground,*s_polymesh)
  
  
  ;Define *loc.Geometry::Location_t = Location::New(*ground\geom,*ground\globalT,0,0.5,0.5)
;   Define *pos.v3f32 = Location::GetPosition(*loc)
;   Vector3::Echo(*pos,"Location Position")
  
  Define *samples.CArray::CArrayPtr = CArray::newCArrayPtr()
  Sampler::SamplePolymesh(*ground\geom,*samples,64,7)
  
  Define pos.v3f32,scl.v3f32
  Vector3::Set(@pos,0,-5,0)
  Vector3::Set(@scl,100,1,100)
  Matrix4::SetScale(*ground\localT\m,@scl)
  Matrix4::SetTranslation(*ground\localT\m,@pos)
  Transform::UpdateSRTFromMatrix(*ground\localT)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
  Object3D::SetShader(*bunny,*s_polymesh)
;   Polymesh::Setup(*torus,*s_polymesh)
;   Polymesh::Setup(*teapot,*s_polymesh)
;   Polymesh::Setup(*ground,*s_polymesh)
;   Polymesh::Setup(*bunny,*s_polymesh)
; Polymesh::Draw(*ground)
;   Polymesh::Draw(*bunny)
  
  Define *merged.Polymesh::Polymesh_t = Polymesh::New("Merged",Shape::#SHAPE_NONE)
  Define *mgeom.Geometry::PolymeshGeometry_t = *merged\geom
  
  Define *topos.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *ggeom.Geometry::PolymeshGeometry_t = *ground\geom
  Define *gtopo.Geometry::Topology_t = *ggeom\topo
  Define i
      
  Define *bgeom.Geometry::PolymeshGeometry_t = *bunny\geom
  CArray::AppendPtr(*topos,*ggeom\topo)
  Define m.m4f32
  Define v.v3f32
  Vector3::Set(@v,0,1,0)
  Matrix4::SetIdentity(@m)
  Matrix4::SetTranslation(@m,@v)
  Topology::Transform(*bgeom\topo, @m)
  CArray::AppendPtr(*topos,*bgeom\topo) 
  
  Topology::MergeArray(*mgeom\topo,*topos)
  
  Define *outtopo.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *matrices.CArray::CarrayM4F32 = CArray::newCArrayM4F32()
  Define m.m4f32
  Define pos.v3f32
  
  Vector3::Set(@pos,0,7,0)
  Matrix4::SetIdentity(@m)
  Matrix4::SetTranslation(@m,@pos)
  CArray::Append(*matrices,@m)
  
  Vector3::Set(@pos,2,7,4)
  Matrix4::SetIdentity(@m)
  
  Define *loc.Geometry::Location_t
  Define *pos.v3f32
  For i=0 To CArray::GetCount(*samples)-1
    *loc = CArray::GetValuePtr(*samples,i)
    *pos = Location::GetPosition(*loc)
   Vector3::Set(*pos,*pos\x,7,i*10)
  Matrix4::SetTranslation(@m,*pos)
  CArray::Append(*matrices,@m)
 Next
  

  Topology::TransformArray(*mgeom\topo,*matrices,*outtopo)
  Topology::MergeArray(*mgeom\topo,*outtopo)
  PolymeshGeometry::Set2(*mgeom,*mgeom\topo)
  Object3D::Freeze(*merged)
  Object3D::AddChild(*root,*merged)
  
;   Object3D::AddChild(*root,*ground)
;   Object3D::AddChild(*root,*bunny)
   Scene::AddModel(Scene::*current_scene,*root)
   Scene::Setup(Scene::*current_scene,*app\context)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 111
; FirstLine = 107
; Folding = -
; EnableThread
; EnableXP
; Executable = D:/Volumes/STORE N GO/Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
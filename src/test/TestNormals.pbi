


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
Global *drawer.Drawer::Drawer_t

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
Global T.d


Procedure RandomLine()
  Protected seed.v3f32
  
EndProcedure


Procedure RandomGround()
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Ground", Shape::#SHAPE_NONE)
  Protected *geom.Geometry::PolymeshGeometry_t = *ground\geom
  Protected *topo.Geometry::Topology_t = *geom\topo
  
  PolymeshGeometry::GridTopology(*topo, 100,100,100)
  
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
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

Procedure RandomCubes(numItems.i,y.f=0)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Drawer::Item_t
  Protected m.m4f32
  Protected p.v3f32
  Define i,j
  For i=0 To numItems-1
    Vector3::Set(p,i, y, (Random(10)-5)/10)
    Matrix4::SetIdentity(m)
    Matrix4::SetTranslation(m,p)

    Color::Set(color, Random(255)/255, Random(255)/255, Random(255)/255,1)
    *item = Drawer::AddBox(*drawer, @m)
    Drawer::SetColor(*item,  @color)
  Next
EndProcedure

Procedure UpdateNormals()
  Drawer::Flush(*drawer)
  Define *offsetedNormals.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*offsetedNormals, *bunny\geom\nbpoints)
  Define i
  Define *n.v3f32, *p.v3f32, *o.v3f32
  Define *geom.Geometry::PolymeshGeometry_t = *bunny\geom
  For i=0 To *bunny\geom\nbpoints - 1
    *n = CArray::GetValue(*geom\a_pointnormals, i)
    *p = CArray::GetValue(*geom\a_positions, i)
    *o = CArray::GetValue(*offsetedNormals, i)
    Vector3::Add(*o, *p, *n)
  Next
  
  Define *L.Drawer::Item_t = Drawer::AddLines2(*drawer, *bunny\geom\a_positions, *offsetedNormals)
  Drawer::SetColor(*L, Color::RED)
  
  CArray::Delete(*offsetedNormals)
  
  Define m.m4f32
  Box::GetMatrixRepresentation(*geom\bbox, m)
  Define *B.Drawer::Box_t = Drawer::AddBox(*drawer, m)
  Drawer::SetColor(*B, Color::MAGENTA)
  
  
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLContext::SetContext(*app\context)
  GLCheckError("Set GL Context")
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
  Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
  Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
  Object3D::SetLocalTransform(*light, *t)
  
  UpdateNormals()
  Scene::*current_scene\dirty= #True
  Scene::Update(Scene::*current_scene)
  
  Protected *s.Program::Program_t = *app\context\shaders("polymesh")
  glUseProgram(*s\pgm)
  GLCheckError("USE PGM")
  glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
  GLCheckError("Set UNIFORM")
  Application::Draw(*app, *layer, *app\camera)
  
;   Debug "context : "+Str(*app\context)
;   Debug "writer : "+Str(*app\context\writer)
;   FTGL::BeginDraw(*app\context\writer)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*bunny\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
;   FTGL::EndDraw(*app\context\writer)
;   
  GLContext::FlipBuffer(*app\context)

 EndProcedure

; ; Draw
; ;--------------------------------------------
; Procedure Draw(*app.Application::Application_t)
;   
;   ViewportUI::SetContext(*viewport)
;   Drawer::Flush(*drawer)
; ;   RandomSpheres(Random(64,16), Random(10)-5)
;   RandomCubes(Random(64,16), Random(10)-5)
; ;   RandomStrips(32)
; ;   RandomPoints(Random(256, 64))
;   Scene::*current_scene\dirty= #True
;   
;   Scene::Update(Scene::*current_scene)
;   LayerDefault::Draw(*layer, *app\context)
;   
;   FTGL::BeginDraw(*app\context\writer)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*app\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
;   FTGL::EndDraw(*app\context\writer)
;   glDisable(#GL_BLEND)
;   
;   ViewportUI::FlipBuffer(*viewport)
; 
; EndProcedure


 
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
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   *app = Application::New("Test Normals", width, height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)     
;      *app\context\writer\background = #True
    View::SetContent(*app\window\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
;   ViewportUI::AddLayer(*viewport, *layer)

  Global *root.Model::Model_t = Model::New("Model")

  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

;   *ground.Polymesh::Polymesh_t = RandomGround();Polymesh::New("Ground",Shape::#SHAPE_GRID)
;   Object3D::SetShader(*ground,*s_polymesh)
;   
  Define pos.v3f32,scl.v3f32
  
;   *box = Polymesh::New("Box",Shape::#SHAPE_CUBE)
  
;   Define *samples.CArray::CArrayPtr = CArray::newCArrayPtr()
;   Sampler::SamplePolymesh(*ground\geom,*samples,256,7)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_TORUS)
  Define *geom.Geometry::PolymeshGeometry_t = *bunny\geom
;   PolymeshGeometry::SphereTopology(*geom\topo, 4, 64 , 32)
;   PolymeshGeometry::Set2(*geom, *geom\topo)
;   
;   Polymesh::SetDirtyState(*bunny, Object3D::#DIRTY_STATE_TOPOLOGY)
;   Object3D::Freeze(*bunny)
;   Object3D::SetShader(*bunny,*s_polymesh)
  
  *drawer = Drawer::New("MeshNormals")
;   Define i
;   Define S.d = Time::get()
;   For i=0 To 12
;     PolymeshGeometry::RecomputeNormals(*geom)
;   Next
;   Define E.d = Time::Get() - S
;   MessageRequester("COMPUTE NORMALS : ", "12 Time "+Str(*geom\nbtriangles)+" TRIANGLES TOOK "+StrD(E))
  Object3D::AddChild(*root, *bunny)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)

  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 159
; FirstLine = 133
; Folding = --
; EnableXP
; Executable = D:/Volumes/STORE N GO/Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; Constant = #USE_GLFW=0
; EnableUnicode



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
Global *csm.LayerCascadedShadowMap::LayerCascadedShadowMap_t

Global Dim *frustrums.Polymesh::Polymesh_t(3)

Global *drawer.Drawer::Drawer_t
Global Dim *items.Drawer::Item_t(3)

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

; Set Bounding Box
;--------------------------------------------
Procedure SetBoundingBox(*frustrum.Polymesh::Polymesh_t, *infos.LayerCascadedShadowMap::OrthographicProjectionInfo_t)
  Debug "SET FRUSTRUM CALLED"
  Protected *geom.Geometry::PolymeshGeometry_t = *frustrum\geom
  Protected *v.v3f32
  Protected *positions.CArray::CArrayV3F32 = *geom\a_positions
  *v = CArray::GetValue(*positions,0)
  Vector3::Set(*v,*infos\right, *infos\top,*infos\far)
  CArray::SetValue(*positions,0,*v)
  *v = CArray::GetValue(*positions,1)
  Vector3::Set(*v,*infos\right, *infos\top,*infos\near)
  CArray::SetValue(*positions,1,*v)
  *v = CArray::GetValue(*positions,2)
  Vector3::Set(*v,*infos\left, *infos\top,*infos\near)
  CArray::SetValue(*positions,2,*v)
  *v = CArray::GetValue(*positions,3)
  Vector3::Set(*v,*infos\left, *infos\top,*infos\far)
  CArray::SetValue(*positions,3,*v)
  *v = CArray::GetValue(*positions,4)
  Vector3::Set(*v,*infos\right, *infos\bottom,*infos\far)
  CArray::SetValue(*positions,4,*v)
  *v = CArray::GetValue(*positions,5)
  Vector3::Set(*v,*infos\right, *infos\bottom,*infos\near)
  CArray::SetValue(*positions,5,*v)
  *v = CArray::GetValue(*positions,6)
  Vector3::Set(*v,*infos\left, *infos\bottom,*infos\near)
  CArray::SetValue(*positions,6,*v)
  *v = CArray::GetValue(*positions,7)
  Vector3::Set(*v,*infos\left, *infos\bottom,*infos\far)
  CArray::SetValue(*positions,7,*v)
  Polymesh::SetDirtyState(*frustrum, Object3D::#DIRTY_STATE_DEFORM)
EndProcedure


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
;   Vector3::Set(*light\pos, 5-Random(10),10,5-Random(10))
;   Light::Update(*light)
;   Vector3::Echo(*light\pos,"LIGHT POSITION")
  ViewportUI::SetContext(*viewport)
  
  LayerCascadedShadowMap::Draw(*csm, *app\context)
  Define i
  For i=0 To 2
    SetBoundingBox(*frustrums(i), *csm\cascadeProjections(i))
  Next
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
     *app\context = GLContext::New(0,#False,*viewport\gadgetID)
     
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::Event(*viewport,#PB_Event_SizeWindow)
  EndIf
  Global *cam2.Camera::Camera_t = Camera::New("Camera2", Camera::#Camera_Perspective)
  *viewport\camera = *cam2
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  Scene::*current_scene = Scene::New()
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  *shadows = LayerShadowMap::New(800,800,*app\context,CArray::GetValuePtr(Scene::*current_scene\lights, 0))
  *gbuffer = LayerGBuffer::New(800,600,*app\context,*app\camera)
  *defered = LayerDefered::New(800,600,*app\context,*gbuffer\buffer,*shadows\buffer,*app\camera)
  *defshadows = LayerShadowDefered::New(800,600,*app\context,*gbuffer\buffer, *shadows\buffer,*app\camera)
  *csm = LayerCascadedShadowMap::New(1024,1024,*app\context,*app\camera,CArray::GetValuePtr(Scene::*current_scene\lights, 0))
  Global *root.Model::Model_t = Model::New("Model")
  
  Layer::SetPOV(*layer, *cam2)
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
  
  
  Define i
  For i=0 To ArraySize(*frustrums())-1
    *frustrums(i) = Polymesh::New("Frustrum"+Str(i+1),Shape::#SHAPE_CUBE)
    *frustrums(i)\wireframe = #True
    Object3D::AddChild(*root,*frustrums(i))
  Next
  
  *drawer = Drawer::New("Drawer")
  Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  Define position.Math::v3f32
  Define color.Math::c4f32
  CArray::SetCount(*positions, 12)
  Define j
  For i=0 To ArraySize(*items())-1
    For j=0 To CArray::GetCount(*positions)-1
      Vector3::Set(@position, i, j, 0)
      CArray::SetValue(*positions, j, @position)
    Next
    Color::Set(@color, Random(255)/255, Random(255)/255, Random(255)/255)
    *items(i) = Drawer::NewPoint(*drawer, *positions)
    Drawer::SetColor(*items(i),  @color)
    Drawer::SetSize(*items(i), 6)
  Next
  
  Define *samples.CArray::CArrayPtr = CArray::newCArrayPtr()
  Sampler::SamplePolymesh(*ground\geom,*samples,1,7)
  
  Define pos.v3f32,scl.v3f32
  Vector3::Set(@pos,0,-5,0)
  Vector3::Set(@scl,100,1,100)
  Matrix4::SetScale(*ground\localT\m,@scl)
  Matrix4::SetTranslation(*ground\localT\m,@pos)
  Transform::UpdateSRTFromMatrix(*ground\localT)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
  Object3D::SetShader(*bunny,*s_polymesh)
  
;   Object3D::AddChild(*root,*ground)
;   Object3D::AddChild(*root,*bunny)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::AddChild(Scene::*current_scene, *drawer)
   Scene::Setup(Scene::*current_scene,*app\context)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 236
; FirstLine = 86
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; Executable = D:/Volumes/STORE N GO/Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
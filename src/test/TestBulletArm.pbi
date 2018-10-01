XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../core/Object.pbi"
XIncludeFile "../libs/Bullet.pbi"


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile"../objects/Scene.pbi"
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

Global *bicep.Polymesh::Polymesh_t
Global *forearm.Polymesh::Polymesh_t
Global *hand.Polymesh::Polymesh_t


Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *drawer.Drawer::Drawer_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f

Global default_layer.Layer::ILayer

Structure BTCharacter_t
  *pelvis.Object3D::Object3D_t
  *spine.Object3D::Object3D_t
  *torso.Object3D::Object3D_t
EndStructure


; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

;-----------------------------------------------
; Create Curved Ground Data
;-----------------------------------------------
Procedure BTCreateCurvedGroundData(*shader.Program::Program_t)
  
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Bullet_Curved_Ground",Shape::#SHAPE_GRID)
  Protected *mesh.Geometry::PolymeshGeometry_t = *ground\geom
  Object3D::SetShader(*ground,*shader)
  
  Protected i
  Protected pos.v3f32
  Protected *p.v3f32
  
  For i=0 To CArray::GetCount(*mesh\a_positions)-1
   
    *p = CArray::GetValue(*mesh\a_positions,i)
    Vector3::Set(pos,*p\x*10,(Random(20)-10)*0.1,*p\z*10)
    CArray::SetValue(*mesh\a_positions,i,pos)
  Next
  

  *ground\deformdirty = #True
  PolymeshGeometry::SetColors(*mesh)
  PolymeshGeometry::RecomputeNormals(*mesh,1.0)
  
  Object3D::Freeze(*ground)
  
  Scene::AddChild(Scene::*current_scene,*ground)
  
  Protected *t.Transform::Transform_t = *ground\localT
  Transform::SetTranslationFromXYZValues(*t,0,-2,0)
  Transform::SetScaleFromXYZValues(*t,1,1,1)
  Transform::UpdateMatrixFromSRT(*t)
  
  Object3D::SetGlobalTransform(*ground,*t)
  Object3D::UpdateTransform(*ground,#Null)
    
  BulletRigidBody::BTCreateRigidBodyFrom3DObject(*ground,Bullet::#TRIANGLEMESH_SHAPE,0,Bullet::*bullet_world)
  Protected *body.Bullet::btRigidBody = *ground\rigidbody
  Bullet::BTSetAngularFactorF(*body,0.5)
  Bullet::BTSetFriction(*body,100)
EndProcedure


Procedure AddBone(*parent.Object3D::Object3D_t, name.s, *shader.Program::Program_t, *start.v3f32, *end.v3f32, mass.f)
  Protected pos.v3f32
  Protected delta.v3f32
  Protected upv.v3f32
  Protected rot.q4f32
  Protected scl.v3f32
  Vector3::Set(upv, 0,0,1)
  Protected l.f
  
  Vector3::LinearInterpolate(@pos, *start, *end, 0.5)
  Vector3::Sub(@delta, *end, *start)
  l = Vector3::Length(@delta)
  Quaternion::LookAt(@rot, @delta, @upv)
  Vector3::Set(scl, 1, l, 1)
  
  ; add bone
  Protected *bone.Polymesh::Polymesh_t = Polymesh::New(name,Shape::#SHAPE_CUBE)
  Object3D::SetShader(*bone,*shader)
  Object3D::AddChild(*parent, *bone)
  
  ; set transform
  Protected *t.Transform::Transform_t = *bone\localT
  Transform::SetScale(*t, @scl)
  Transform::SetRotationFromQuaternion(*t, @rot)
  Transform::SetTranslation(*t, @pos)
  *t\srtdirty = #True
  
  Object3D::SetGlobalTransform(*bone,*t)
  Object3D::SetStaticTransform(*bone,*t)
  Object3D::UpdateTransform(*bone,*parent\globalT)
  
  ; create rigid body
  BulletRigidBody::BTCreateRigidBodyFrom3DObject(*bone,Bullet::#BOX_SHAPE,mass,Bullet::*bullet_world)
  Protected *body.Bullet::btRigidBody = *bone\rigidbody
  Bullet::BTSetAngularFactorF(*body,0.5)
  Bullet::BTSetFriction(*body,10)
  
  ; set color
  Protected color.c4f32
  Color::Randomize(@color)
  PolymeshGeometry::SetColors(*bone\geom,@color)  
  
  ; output 
  ProcedureReturn *bone
EndProcedure

; ---------------------------------------------------------------
; Draw Pivot
; ---------------------------------------------------------------
Procedure DrawPivot(*A.Object3D::Object3D_t, *drawer.Drawer::Drawer_t)
  Protected axis.v3f32
  
  Protected *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*positions, 2)
  Protected *p.v3f32 = CArray::GetPtr(*positions, 1)
  Vector3::SetFromOther(CArray::GetPtr(*positions, 0), *A\globalT\t\pos)
  Vector3::Set(*p,1,0,0)
  Vector3::MulByMatrix4InPlace(*p,*A\globalT\m)
  
  
  Protected color.c4f32
  Color::Set(@color, 1,0,0,1)
  
  Protected *axis.Drawer::Item_t = Drawer::NewLines(*drawer, *positions)
  Drawer::SetColor(*axis, @color)
  
  Vector3::Set(*p,0,1,0)
  Vector3::MulByMatrix4InPlace(*p,*A\globalT\m)
  Color::Set(@color, 0,1,0,1)
  *axis.Drawer::Item_t = Drawer::NewLines(*drawer, *positions)
  Drawer::SetColor(*axis, @color)
  
  Vector3::Set(*p,0,0,1)
  Vector3::MulByMatrix4InPlace(*p,*A\globalT\m)
  Color::Set(@color, 0,0,1,1)
  *axis.Drawer::Item_t = Drawer::NewLines(*drawer, *positions)
  Drawer::SetColor(*axis, @color)
  
EndProcedure

Procedure AddConstraint(*A.Object3D::Object3D_t, *B.Object3D::Object3D_t, *drawer.Drawer::Drawer_t)
  Protected pivot1.v3f32
  Protected pivot2.v3f32
  Protected axis1.v3f32
  Protected axis2.v3f32
  
  Vector3::Set(axis1,0,12,0)
  Vector3::Set(axis2,12,12,0)
  
  DrawPivot(*A, *drawer)
  
  Protected *hinge.BulletConstraint::BTConstraint_t = BulletConstraint::NewHinge(*A, *B, @pivot1, @pivot2, @axis1, @axis2)
  Bullet::BTAddConstraint(Bullet::*bullet_world,*hinge\cns,#True)
  ProcedureReturn *hinge
  
EndProcedure



Procedure BulletCharacter(*s.Program::Program_t)
  
  Scene::*current_scene = Scene::New("Test Arm")
  Protected scene.Scene::IScene = Scene::*current_scene
 
  
  Global *root.Model::Model_t = Model::New("Model")
  
  Protected sp.v3f32
  Protected ep.q4f32
  
  Protected x,y,z
  
  ; add ground
  BTCreateCurvedGroundData(*s)
  
  ; add bicep
  Vector3::Set(sp, 0,0,0)
  Vector3::Set(ep, 2,0,0)
  *bicep = AddBone(*root, "Bicep_Bone", *s, @sp, @ep, 0.0)
  
  ; add forearm
  Vector3::Set(sp, 2,0,0)
  Vector3::Set(ep, 5,0,-0.5)
  *forearm = AddBone(*root, "Forearm_Bone", *s, @sp, @ep, 1.0)
  
  ; add hand
  Vector3::Set(sp, 5,0,-0.5)
  Vector3::Set(ep, 8,0,0)
  *hand = AddBone(*root, "Hand_Bone", *s, @sp, @ep, 1.0)
  
  ; add constraints
  AddConstraint(*bicep, *forearm, *drawer)
  AddConstraint(*forearm, *hand, *drawer)
  
  Scene::AddModel(Scene::*current_scene,*root)
  ProcedureReturn Scene::*current_scene
EndProcedure

 ; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  If EventType() = #PB_EventType_KeyDown
    Protected key.i = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_Key)
    Select key
      Case #PB_Shortcut_Space
        Scene::*current_scene\dirty = #True
        Scene::Update(Scene::*current_scene)
        BulletWorld::hlpUpdate(Bullet::*bullet_world,1/25)
        BulletWorld::AddGroundPlane(Bullet::*bullet_world)
      Case #PB_Shortcut_Return
        BulletWorld::hlpReset(Bullet::*bullet_world)
    EndSelect
  EndIf
  
  ViewportUI::Draw(*viewport, *app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*app\context\writer,"Bullet Demo",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)
  
;   Polymesh::Draw(*teapot)
; ;   Polymesh::Draw(*ground)
; ; ;   Polymesh::Draw(*null)
; ; ;   Polymesh::Draw(*cube)
; ;   Polymesh::Draw(*bunny)
;   
;   glDisable(#GL_DEPTH_TEST)
;   
;   glViewport(0,0,width,height)
;   glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
;   glReadBuffer(#GL_COLOR_ATTACHMENT0)
;   glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
;   
;   glDisable(#GL_DEPTH_TEST)
;   glEnable(#GL_BLEND)
;   glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
;   glDisable(#GL_DEPTH_TEST)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*app\context\writer,"Bullet Library",-0.9,0.9,ss,ss*ratio)
;   FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
;   FTGL::Draw(*app\context\writer,"Nb Rigid Bodies : "+Str(Bullet::BTGetNumCollideObjects(Bullet::*bullet_world)),-0.9,0.7,ss,ss*ratio)
;   glDisable(#GL_BLEND)
;   
;   If Not #USE_GLFW
;     SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
;   EndIf

 EndProcedure

 
 Define useJoystick.b = #False
 width = 800
 height = 600
 ; Main
 Globals::Init()
 Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("Bullet Arm",width,height,#PB_Window_SystemMenu|#PB_Window_SizeGadget)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
      *viewport\camera = *app\camera

   ; ViewportUI::Event(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  
  *drawer = Drawer::New()
  BulletCharacter(*app\context\shaders("polymesh"))
  
  Global *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  ;Debug "Size "+Str(*app\width)+","+Str(*app\height)
  Global *default.Layer::Layer_t = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *default)
;   
;   Global *gbuffer.Layer::Layer_t = LayerGBuffer::New(WIDTH,HEIGHT,*app\context,*app\camera)
;   LayerGBuffer::Setup(*gbuffer)
;   
; 
;   Global *shadowmap.Layer::Layer_t = LayerShadowMap::New(1024,1024,*app\context,*light)
;   LayerShadowMap::Setup(*shadowmap)
;   
;   Light::Update(*light)
;   ; Debug *app\context\shaders("simple2D")  
;   Global *defered.Layer::Layer_t = LayerShadowDefered::New(WIDTH,HEIGHT,*app\context,*gbuffer\buffer,*shadowmap\buffer,*app\camera)
;   LayerShadowDefered::Setup(*defered)
  
  Global default_layer.Layer::ILayer = *default
;   Global gbuffer.Layer::ILayer = *gbuffer
;   Global shadowmap.Layer::ILayer = *shadowmap
;   Global defered.Layer::ILayer = *defered
;   
  

  ;*torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
; ;   *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
;   *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
;   Define pos.v3f32,scl.v3f32
;   Vector3::Set(pos,0,-1,0)
;   Vector3::Set(scl,100,1,100)
;   Matrix4::SetScale(*ground\matrix,@scl)
;   Matrix4::SetTranslation(*ground\matrix,@pos)
;   
;   *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
 ; Polymesh::Setup(*torus,*s_polymesh)
; ;   Polymesh::Setup(*teapot,*s_polymesh)
;   Polymesh::Setup(*ground,*s_polymesh)
;   Polymesh::Setup(*bunny,*s_polymesh)
  Scene::AddChild(Scene::*current_scene, *drawer)
Scene::Setup(Scene::*current_scene,*app\context)
  
  
  Application::Loop(*app, @Draw())
EndIf
Bullet::Term()
Globals::Term()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 366
; FirstLine = 313
; Folding = --
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
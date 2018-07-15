


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
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f

Global default_layer.Layer::ILayer

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure


Procedure AddBone(*parent.Object3D::Object3D_t, name.s, *shader.Program::Program_t, *start.v3f32, *end.v3f32, mass.f)
  Protected pos.v3f32
  Protected delta.v3f32
  Protected upv.v3f32
  Protected rot.q4f32
  Protected scl.v3f32
  Vector3::Set(@upv, 0,0,1)
  Protected l.f
  
  Vector3::LinearInterpolate(@pos, *start, *end, 0.5)
  Vector3::Sub(@delta, *end, *start)
  l = Vector3::Length(@delta)
  Quaternion::LookAt(@rot, @delta, @upv)
  Vector3::Set(@scl, 1, 1, l)
  
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


Procedure BulletScene(*s.Program::Program_t)
  
  Scene::*current_scene = Scene::New("Test Arm")
  Protected scene.Scene::IScene = Scene::*current_scene
 
  
  Global *root.Model::Model_t = Model::New("Model")
  
  Protected sp.v3f32
  Protected ep.q4f32
  
  Protected x,y,z
  
  ; add bicep
  Vector3::Set(@sp, 0,0,0)
  Vector3::Set(@ep, 2,0,0)
  *bicep = AddBone(*root, "Bicep_Bone", *s, @sp, @ep, 0.0)
  
  ; add forearm
  Vector3::Set(@sp, 2,0,0)
  Vector3::Set(@ep, 5,0,-0.5)
  *forearm = AddBone(*root, "Forearm_Bone", *s, @sp, @ep, 1.0)
  
  ; add hand
  Vector3::Set(@sp, 5,0,-0.5)
  Vector3::Set(@ep, 8,0,0)
  *hand = AddBone(*root, "Hand_Bone", *s, @sp, @ep, 1.0)
  
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
  
 
;   Scene::Draw(Scene::*current_scene,*s_polymesh,Object3D::#Object3D_Polymesh)
  
 default_layer\Draw  (*app\context)
;   gbuffer\Draw(*app\context  )
;   shadowmap\Draw(*app\context)
;   
  ;*shadows\texture = Framebuffer::GetTex(*shadowmap\buffer,0)

;   defered\Draw(*app\context)
  ;*bitmap\bitmap = Framebuffer::GetTex(*defered\buffer,0)
  ;bitmap\Draw(*app\context)
  ;ssao\Draw(*app\context)
  glDisable(#GL_DEPTH_TEST)
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*app\context\writer,"Bullet Demo",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  glDisable(#GL_BLEND)
  
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
  
  BulletScene(*app\context\shaders("polymesh"))
  
  Global *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  ;Debug "Size "+Str(*app\width)+","+Str(*app\height)
  Global *default.Layer::Layer_t = LayerDefault::New(800,600,*app\context,*app\camera)
  LayerDefault::Setup(*default)
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
;   Vector3::Set(@pos,0,-1,0)
;   Vector3::Set(@scl,100,1,100)
;   Matrix4::SetScale(*ground\matrix,@scl)
;   Matrix4::SetTranslation(*ground\matrix,@pos)
;   
;   *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
 ; Polymesh::Setup(*torus,*s_polymesh)
; ;   Polymesh::Setup(*teapot,*s_polymesh)
;   Polymesh::Setup(*ground,*s_polymesh)
;   Polymesh::Setup(*bunny,*s_polymesh)
Scene::Setup(Scene::*current_scene,*app\context)
  
  
  Application::Loop(*app, @Draw())
EndIf
Bullet::Term()
Globals::Term()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 79
; FirstLine = 63
; Folding = -
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
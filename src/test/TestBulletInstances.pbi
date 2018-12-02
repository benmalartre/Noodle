


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile"../objects/Scene.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf  #USE_GLFW
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
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t
Global *cloud.InstanceCloud::InstanceCloud_t
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
Global gbuffer.Layer::ILayer
Global shadowmap.Layer::ILayer
Global defered.Layer::ILayer

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

;   Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Bullet_Curved_Ground",Shape::#SHAPE_GRID)
;   BulletRigidBody::BTCreateRigidBodyFrom3DObject(*ground,Bullet::#GROUNDPLANE_SHAPE,0,Bullet::*bullet_world)
  
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Bullet_Curved_Ground",Shape::#SHAPE_GRID)
  Protected *mesh.Geometry::PolymeshGeometry_t = *ground\geom
  ;PolymeshGeometry::InvertNormals(*mesh)
  Object3D::SetShader(*ground,*shader)
  
  Protected i
  Protected *p.v3f32
  
  For i=0 To CArray::GetCount(*mesh\a_positions)-1
   
    *p = CArray::GetValue(*mesh\a_positions,i)
    Vector3::Set(*p,*p\x*10,(Random(20)-10),*p\z*10)
  Next
  

  *ground\deformdirty = #True
  PolymeshGeometry::SetColors(*mesh)
  PolymeshGeometry::ComputeNormals(*mesh,1.0)
  
  Object3D::Freeze(*ground)
  
  Scene::AddChild(Scene::*current_scene,*ground)
  
  Protected *t.Transform::Transform_t = *ground\localT
  Transform::SetTranslationFromXYZValues(*t,0,-10,0)
  Transform::SetScaleFromXYZValues(*t,1,1,1)
  Transform::UpdateMatrixFromSRT(*t)
  
  Object3D::SetGlobalTransform(*ground,*t)
  Object3D::UpdateTransform(*ground,#Null)
    
  BulletRigidBody::BTCreateRigidBodyFrom3DObject(*ground,Bullet::#TRIANGLEMESH_SHAPE,0,Bullet::*bullet_world)
  Protected *body.Bullet::btRigidBody = *ground\rigidbody
  Bullet::BTSetAngularFactorF(*body,0.5)
  Bullet::BTSetFriction(*body,100)
; ; 
;     With *mesh
;       BTCreateCurvedGround(*raa_bullet_sdk,\nbtriangles,\nbpoints,\a_positions\GetPtr(),\a_triangleindices\GetPtr())
;     EndWith
  
EndProcedure


Procedure BulletScene(*s.Program::Program_t)
  Scene::*current_scene = Scene::New("Test Bullet")
  Protected scene.Scene::IScene = Scene::*current_scene
  Global *root.Model::Model_t = Model::New("Model")
  
  Protected p.v3f32
  Protected q.q4f32
  
  Protected x,y,z
  
  Protected *pos.CArray::CArrayV3f32 = CArray::newCArrayV3F32()
  Protected *id.CArray::CArrayChar = CArray::newCArrayChar()
  Protected v.v3f32
  Protected i
  Protected nb = 12
  For i=0 To nb
    Vector3::Set(v,0,i,0)
    CArray::Append(*pos,v)
  Next
  ;BTCreateSphereSoftBody()
  
;   Protected *sb.btSoftBody = BTCreateSoftBodyFromConvexHull(*raa_bullet_sdk,pos\GetPtr(0),nb)
  
;   BTAddSoftBody(*raa_bullet_world,*sb)
  
;OPolymesh_Dummy(*sphere,1000000)

Protected *t.Transform::Transform_t
Protected color.c4f32
Protected factor.v3f32

 *cloud.InstanceCloud::InstanceCloud_t = InstanceCloud::New("RigidBodies",Shape::#SHAPE_SPHERE)
Vector3::Set(factor,1,1,1)
Color::Set(color,1.0,0.5,0.4,1)
  For x=0 To 7
    For y=0 To 1
      For z=0 To 7
        Protected *mesh.Polymesh::Polymesh_t = Polymesh::New("RigidBody"+Str(x*10*10+y*10+z+1),Shape::#SHAPE_TEAPOT)
        Object3D::SetShader(*mesh,*s)
        ;Protected *cube.CPolymesh = newCPolymesh("RigidBody"+Str(x*10*10+y*10+z+1),#RAA_Shape_Cube,Random(20)*0.2+0.1)
        Object3D::AddChild(*root,*mesh)

        ;*mesh\Sphere()
        ;OPolymeshGeometry_Sphere(*mesh\GetGeometry(),1,12,12)
        *t.Transform::Transform_t = *mesh\localT
        Vector3::Set(p,x*2-10,10*2+y,z*2-10)
        Vector3::SetFromOther(*t\t\pos,p)

        Quaternion::SetFromAxisAngleValues(q,Random(255)/255,Random(255)/255,Random(255)/255,Random(360))
        Quaternion::SetFromOther(*t\t\rot,q)
        
        Vector3::Set(*t\t\scl,3,3,3)
        *t\srtdirty = #True
        Object3D::SetGlobalTransform(*mesh,*t)
        Object3D::UpdateTransform(*mesh,*root\globalT)
        BulletRigidBody::BTCreateRigidBodyFrom3DObject(*mesh,Bullet::#CONVEXHULL_SHAPE,1.0,Bullet::*bullet_world)
        Protected *body.Bullet::btRigidBody = *mesh\rigidbody
        Bullet::BTSetAngularFactorF(*body,0.5)
        Bullet::BTSetFriction(*body,10)
        Color::Randomize(color)
        PolymeshGeometry::SetColors(*mesh\geom,color)
      Next z
    Next y
  Next x
  
    BTCreateCurvedGroundData(*s)
  
  Scene::AddModel(Scene::*current_scene,*root)
  ProcedureReturn Scene::*current_scene
EndProcedure


 ; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  
  Scene::*current_scene\dirty = #True
  Scene::Update(Scene::*current_scene)
  BulletWorld::hlpUpdate(Bullet::*bullet_world,1/25)
  BulletWorld::AddGroundPlane(Bullet::*bullet_world)
;   Scene::Draw(Scene::*current_scene,*s_polymesh,Object3D::#Object3D_Polymesh)
  
 default_layer\Draw  (*app\context)
;   gbuffer\Draw(*app\context  )
;   shadowmap\Draw(*app\context)
;   
; ;   *shadows\texture = Framebuffer::GetTex(*shadowmap\buffer,0)
; 
;   defered\Draw(*app\context)
;   *bitmap\bitmap = Framebuffer::GetTex(*defered\buffer,0)
;   bitmap\Draw(*app\context)
;   ssao\Draw(*app\context)
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
  
  CompilerIf Not #USE_GLFW
    SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
  CompilerEndIf
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
   *app = Application::New("TestBullet",width,height,#PB_Window_SystemMenu|#PB_Window_SizeGadget)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
    *viewport\camera = *app\camera

   ; ViewportUI::Event(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  
  BulletScene(*app\context\shaders("polymesh"))
  
  Global *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  Global *default.Layer::Layer_t = LayerDefault::New(800,600,*app\context,*app\camera)
  LayerDefault::Setup(*default)
  
  Global *gbuffer.Layer::Layer_t = LayerGBuffer::New(WIDTH,HEIGHT,*app\context,*app\camera)
  LayerGBuffer::Setup(*gbuffer)
  

  Global *shadowmap.Layer::Layer_t = LayerShadowMap::New(1024,1024,*app\context,*light)
  LayerShadowMap::Setup(*shadowmap)
  
  Light::Update(*light)
  ; Debug *app\context\shaders("simple2D")  
  Global *defered.Layer::Layer_t = LayerShadowDefered::New(WIDTH,HEIGHT,*app\context,*gbuffer\buffer,*shadowmap\buffer,*app\camera)
  LayerShadowDefered::Setup(*defered)
  
  Global default_layer.Layer::ILayer = *default
  Global gbuffer.Layer::ILayer = *gbuffer
  Global shadowmap.Layer::ILayer = *shadowmap
  Global defered.Layer::ILayer = *defered
  
  

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
Scene::Setup(Scene::*current_scene,*app\context)
  
  
  Application::Loop(*app, @Draw())
EndIf
Bullet::Term()
Globals::Term()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 87
; FirstLine = 83
; Folding = --
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
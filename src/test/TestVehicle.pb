


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

Global *torus.Polymesh::Polymesh_t
Global *teapot.Polymesh::Polymesh_t
Global *ground.Polymesh::Polymesh_t
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t

Global *buffer.Framebuffer::Framebuffer_t
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
Procedure Ground(*scene.Scene::Scene_t,*shader.Program::Program_t)

  
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Bullet_Curved_Ground",Shape::#SHAPE_GRID)
  Protected *mesh.Geometry::PolymeshGeometry_t = *ground\geom
  ;PolymeshGeometry::InvertNormals(*mesh)
  Object3D::SetShader(*ground,*shader)
  
  Protected i
  Protected pos.v3f32
  Protected *p.v3f32
  
  For i=0 To CArray::GetCount(*mesh\a_positions)-1
   
    *p = CArray::GetValue(*mesh\a_positions,i)
    Vector3::Set(@pos,*p\x*10,(Random(5)-2.5),*p\z*10)
    CArray::SetValue(*mesh\a_positions,i,pos)
  Next
  Object3D::Freeze(*ground)
  *ground\deformdirty = #True
  PolymeshGeometry::SetColors(*mesh)
  PolymeshGeometry::RecomputeNormals(*mesh,1.0)
  
  
  Scene::AddChild(*scene,*ground)
  
  Protected *t.Transform::Transform_t = *ground\localT
  Transform::SetTranslationFromXYZValues(*t,0,-10,0)
  Transform::SetScaleFromXYZValues(*t,1,1,1)
  Transform::UpdateMatrixFromSRT(*t)
  
  Object3D::SetGlobalTransform(*ground,*t)
  Object3D::UpdateTransform(*ground,#Null)
  
  BulletRigidBody::BTCreateRigidBodyFrom3DObject(*ground,Bullet::#TRIANGLEMESH_SHAPE,0.0,Bullet::*bullet_world)
;   Protected *body.Bullet::btRigidBody = *ground\rigidbody
;   Bullet::BTSetAngularFactorF(*body,0.5)
;   Bullet::BTSetFriction(*body,100)
; ; ; 
;     With *mesh
;       BTCreateCurvedGround(*raa_bullet_sdk,\nbtriangles,\nbpoints,\a_positions\GetPtr(),\a_triangleindices\GetPtr())
;     EndWith
  
EndProcedure



Procedure Wheel(*model.Model::Model_t,*shader.Program::Program_t,name.s,*pos.v3f32,radius.f)
  Protected *wheel.Object3D::Object3D_t = Polymesh::New(name,Shape::#SHAPE_CYLINDER)
  *wheel\shader = *shader
  Protected q.q4f32
  Protected *t.Transform::Transform_t = *wheel\localT
Transform::Init(*t)
  Quaternion::SetFromAxisAngleValues(*t\t\rot,0,0,1,Math::#F32_PI_2)
  Vector3::Set(*t\t\scl,radius,1,radius)
  Vector3::SetFromOther(*t\t\pos,*pos)
  *t\srtdirty = #True
  Object3D::SetGlobalTransform(*wheel,*t)
  Object3D::UpdateTransform(*wheel,*model\globalT)
  Object3D::AddChild(*model,*wheel)
  
  BulletRigidBody::BTCreateRigidBodyFrom3DObject(*wheel,Bullet::#CYLINDER_SHAPE,1.0,Bullet::*bullet_world)
  Protected scl.v3f32
  Vector3::Set(@scl,1,1,1)
  Bullet::BTSetScaling(*wheel\rigidbody,@scl)

  Protected *body.Bullet::btRigidBody = *wheel\rigidbody
  Bullet::BTSetAngularFactorF(*body,0.5)
  Bullet::BTSetFriction(*body,10)
  ProcedureReturn *wheel
EndProcedure



Procedure Vehicle(*scene.Scene::Scene_t,*shader.Program::Program_t,w.f,h.f,d.f)
  Protected wh.f = h/4
  Protected wr.f = wh
  Protected *model.Model::Model_t = Model::New("Vehicle")
  Protected *chassis.Polymesh::Polymesh_t = Polymesh::New("Chassis",Shape::#SHAPE_CUBE)
  *chassis\shader = *shader
  
  Object3D::AddChild(*model,*chassis)
  Protected *t.Transform::Transform_t = *chassis\localT
  
  Protected sh = h-wh
  Protected th = wr+(h-wh)/2
  Transform::SetScaleFromXYZValues(*t,w,sh,d)
  Transform::SetTranslationFromXYZValues(*t,0,th,0) 
  Object3D::SetGlobalTransform(*chassis,*t)
  Object3D::UpdateTransform(*chassis,#Null)
  
  BulletRigidBody::BTCreateRigidBodyFrom3DObject(*chassis,Bullet::#BOX_SHAPE,100,Bullet::*bullet_world)
  Protected scl.v3f32
  Vector3::Set(@scl,1,1,1)
  Bullet::BTSetScaling(*chassis\rigidbody,@scl)
  
  
;   Protected *head.Polymesh::Polymesh_t = Polymesh::New("Head",Shape::#SHAPE_CUBE)
;   *head\shader = *shader
;   
;   Object3D::AddChild(*chassis,*head)
;   *t.Transform::Transform_t = *head\localT
; 
;   Transform::SetScaleFromXYZValues(*t,w/3,h-wh,d/3)
;   Transform::SetTranslationFromXYZValues(*t,w/2,wr+(h-wh)/2,d/2)
;   Object3D::SetLocalTransform(*head,*t)
  
  Protected pos.v3f32
  Vector3::Set(@pos,-(w/2+0.5),0,d/3)
  Protected *lfwheel.Object3D::Object3D_t = Wheel(*model,*shader,"LFWheel",@pos,wr)
    
  Vector3::Set(@pos,w/2+0.5,0,d/3)
  Protected *rfwheel.Object3D::Object3D_t = Wheel(*model,*shader,"RFWheel",@pos,wr)
  Vector3::Set(@pos,-(w/2+0.5),0,-d/3)
  Protected *lbwheel.Object3D::Object3D_t = Wheel(*model,*shader,"LBWheel",@pos,wr)
  Vector3::Set(@pos,w/2+0.5,0,-d/3)
  Protected *rbwheel.Object3D::Object3D_t = Wheel(*model,*shader,"RBWheel",@pos,wr)
  
  
  Protected pivot1.v3f32
  Protected pivot2.v3f32
  Protected axis1.v3f32
  Protected axis2.v3f32
  
  Vector3::Set(@pivot1,0,0,0)
  Vector3::Set(@pivot2,-(w/2+0.5),-sh/2,d/3)
  
  Vector3::Set(@axis1,0,1,0)
  Vector3::Set(@axis2,1,0,0)

  Protected *lfcns.BulletConstraint::BTConstraint_t = BulletConstraint::NewHinge(*lfwheel,*chassis,@pivot1,@pivot2,@axis1,@axis2,#False)
  Bullet::BTAddConstraint(Bullet::*bullet_world,*lfcns\cns,#True)
  
  Vector3::Set(@pivot1,0,0,0)
  Vector3::Set(@pivot2,w/2+0.5,-sh/2,d/3)
  Protected *rfcns.BulletConstraint::BTConstraint_t = BulletConstraint::NewHinge(*rfwheel,*chassis,@pivot1,@pivot2,@axis1,@axis2,#False)
                                                                                               ;   Bullet::BTAddConstraint(Bullet::*bullet_world,*rfcns\cns)
  Bullet::BTAddConstraint(Bullet::*bullet_world,*rfcns\cns,#True)
  
  Vector3::Set(@pivot1,0,0,0)
  Vector3::Set(@pivot2,-(w/2+0.5),-sh/2,-d/3)
  Protected *lbcns.BulletConstraint::BTConstraint_t = BulletConstraint::NewHinge(*lbwheel,*chassis,@pivot1,@pivot2,@axis1,@axis2,#False)
                                                                                               ;   Bullet::BTAddConstraint(Bullet::*bullet_world,*rfcns\cns)
  Bullet::BTAddConstraint(Bullet::*bullet_world,*lbcns\cns,#True)
  
  Vector3::Set(@pivot1,0,0,0)
  Vector3::Set(@pivot2,w/2+0.5,-sh/2,-d/3)
  Protected *rbcns.BulletConstraint::BTConstraint_t = BulletConstraint::NewHinge(*rbwheel,*chassis,@pivot1,@pivot2,@axis1,@axis2,#False)
                                                                                               ;   Bullet::BTAddConstraint(Bullet::*bullet_world,*rfcns\cns)
  Bullet::BTAddConstraint(Bullet::*bullet_world,*rbcns\cns,#True)
  ; 
  
  Protected *head.Polymesh::Polymesh_t = Polymesh::New("Head",Shape::#SHAPE_CUBE)
  *chassis\shader = *shader
  
  Object3D::AddChild(*model,*head)
  *t = *head\localT
  

  Transform::SetScaleFromXYZValues(*t,w/2,h/2,d/2)
  Transform::SetTranslationFromXYZValues(*t,0,h*2,0) 
  Object3D::SetGlobalTransform(*head,*t)
  Object3D::UpdateTransform(*head,#Null)
  
  BulletRigidBody::BTCreateRigidBodyFrom3DObject(*head,Bullet::#BOX_SHAPE,100,Bullet::*bullet_world)
  Vector3::Set(@scl,1,1,1)
  Bullet::BTSetScaling(*head\rigidbody,@scl)
  
  Vector3::Set(@pivot1,0,-1,0)
  Vector3::Set(@pivot2,0,1,0)
  
  
  Protected *hcns.BulletConstraint::BTConstraint_t = BulletConstraint::NewPoint2Point(*head,*chassis,@pivot1,@pivot2)
                                                                                               ;   Bullet::BTAddConstraint(Bullet::*bullet_world,*rfcns\cns)
  Bullet::BTAddConstraint(Bullet::*bullet_world,*hcns\cns,#False)
  
  Scene::AddModel(*scene,*model)
EndProcedure


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
;   If Not #USE_GLFW
;     ViewportUI::Event(*viewport,WindowEvent())
;   EndIf
  
  If EventType() = #PB_EventType_KeyDown
    If GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_Key) = #PB_Shortcut_Space
      BulletWorld::hlpUpdate(Bullet::*bullet_world,1/25)
    EndIf
  EndIf
  
      
 
  
  Framebuffer::BindOutput(*buffer)
  glClearColor(0.25,0.25,0.25,1.0)
  glViewport(0, 0, *buffer\width,*buffer\height)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glEnable(#GL_DEPTH_TEST)
  
  glUseProgram(shader)
  Matrix4::SetIdentity(@offset)
  Framebuffer::BindOutput(*buffer)
  glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*app\camera\view)
  glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*app\camera\projection)
  glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform3f(glGetUniformLocation(shader,"lightPosition"),4.0,20.0,2.0)
  T+0.01
  
  ;Polymesh::Draw(*torus)
  
  Scene::Update(Scene::*current_scene)
  Scene::Draw(Scene::*current_scene,*s_polymesh,Object3D::#Object3D_Polymesh)
  
;   Polymesh::Draw(*teapot)
;   Polymesh::Draw(*ground)
; ;   Polymesh::Draw(*null)
; ;   Polymesh::Draw(*cube)
;   Polymesh::Draw(*bunny)
  
;   glDisable(#GL_DEPTH_TEST)
  
  glViewport(0,0,width,height)
  glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
  glReadBuffer(#GL_COLOR_ATTACHMENT0)
  glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
  
  glDisable(#GL_DEPTH_TEST)
  
  
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Bullet Vehicle",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  glDisable(#GL_BLEND)
  
  If Not #USE_GLFW
    SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
  EndIf

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
   *app = Application::New("TestMesh",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = GLContext::New(0,#False,*viewport\gadgetID)
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::Event(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *buffer = Framebuffer::New("Color",*app\width,*app\height)
  Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachTexture(*buffer,"normal",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)
  
  *s_wireframe = Program::NewFromName("simple")
  *s_polymesh = Program::NewFromName("polymesh")
  
  shader = *s_polymesh\pgm
  
  Global *scene.Scene::Scene_t = Scene::New("Scene1")
  Scene::*current_scene = *scene
  Global *vehicle = Vehicle(*scene,*s_polymesh,4,2,6)
  Ground(*scene,*s_polymesh)
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
Scene::Setup(*scene,*app\context)
  
  
  Application::Loop(*app, @Draw())
EndIf
Bullet::Term()
Globals::Term()
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 127
; Folding = -
; EnableXP
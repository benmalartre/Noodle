﻿


XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../libs/Bullet.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile"../objects/Scene.pbi"
XIncludeFile "../ui/ViewportUI.pbi"
XIncludeFile"../bullet/RigidBody.pbi"
XIncludeFile"../bullet/World.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit

; Global ErrorMessage$
; Procedure ErrorHandler()
;  
;   ErrorMessage$ = "A program error was detected:" + Chr(13) 
;   ErrorMessage$ + Chr(13)
;   ErrorMessage$ + "Error Message:   " + ErrorMessage()      + Chr(13)
;   ErrorMessage$ + "Error Code:      " + Str(ErrorCode())    + Chr(13)  
;   ErrorMessage$ + "Code Address:    " + Str(ErrorAddress()) + Chr(13)
;  
;   If ErrorCode() = #PB_OnError_InvalidMemory   
;     ErrorMessage$ + "Target Address:  " + Str(ErrorTargetAddress()) + Chr(13)
;   EndIf
;  
;   If ErrorLine() = -1
;     ErrorMessage$ + "Sourcecode line: Enable OnError lines support to get code line information." + Chr(13)
;   Else
;     ErrorMessage$ + "Sourcecode line: " + Str(ErrorLine()) + Chr(13)
;     ErrorMessage$ + "Sourcecode file: " + ErrorFile() + Chr(13)
;   EndIf
;  
;   ErrorMessage$ + Chr(13)
;   ErrorMessage$ + "Register content:" + Chr(13)
;  
;   CompilerSelect #PB_Compiler_Processor 
;     CompilerCase #PB_Processor_x86
;       ErrorMessage$ + "EAX = " + Str(ErrorRegister(#PB_OnError_EAX)) + Chr(13)
;       ErrorMessage$ + "EBX = " + Str(ErrorRegister(#PB_OnError_EBX)) + Chr(13)
;       ErrorMessage$ + "ECX = " + Str(ErrorRegister(#PB_OnError_ECX)) + Chr(13)
;       ErrorMessage$ + "EDX = " + Str(ErrorRegister(#PB_OnError_EDX)) + Chr(13)
;       ErrorMessage$ + "EBP = " + Str(ErrorRegister(#PB_OnError_EBP)) + Chr(13)
;       ErrorMessage$ + "ESI = " + Str(ErrorRegister(#PB_OnError_ESI)) + Chr(13)
;       ErrorMessage$ + "EDI = " + Str(ErrorRegister(#PB_OnError_EDI)) + Chr(13)
;       ErrorMessage$ + "ESP = " + Str(ErrorRegister(#PB_OnError_ESP)) + Chr(13)
;  
;     CompilerCase #PB_Processor_x64
;       ErrorMessage$ + "RAX = " + Str(ErrorRegister(#PB_OnError_RAX)) + Chr(13)
;       ErrorMessage$ + "RBX = " + Str(ErrorRegister(#PB_OnError_RBX)) + Chr(13)
;       ErrorMessage$ + "RCX = " + Str(ErrorRegister(#PB_OnError_RCX)) + Chr(13)
;       ErrorMessage$ + "RDX = " + Str(ErrorRegister(#PB_OnError_RDX)) + Chr(13)
;       ErrorMessage$ + "RBP = " + Str(ErrorRegister(#PB_OnError_RBP)) + Chr(13)
;       ErrorMessage$ + "RSI = " + Str(ErrorRegister(#PB_OnError_RSI)) + Chr(13)
;       ErrorMessage$ + "RDI = " + Str(ErrorRegister(#PB_OnError_RDI)) + Chr(13)
;       ErrorMessage$ + "RSP = " + Str(ErrorRegister(#PB_OnError_RSP)) + Chr(13)
;       ErrorMessage$ + "Display of registers R8-R15 skipped."         + Chr(13)
;  
;   CompilerEndSelect
;  
;   MessageRequester("OnError example", ErrorMessage$)
;   End
;   
;   
;   
; EndProcedure
; 
;  OnErrorCall(@ErrorHandler())

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

Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *scene.Scene::Scene_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f

Global *default.Layer::Layer_t
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
Procedure BTCreateCurvedGroundData()

;   Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Bullet_Curved_Ground",Shape::#SHAPE_GRID)
;   BulletRigidBody::BTCreateRigidBodyFrom3DObject(*ground,Bullet::#GROUNDPLANE_SHAPE,0,Bullet::*bullet_world)
  
  *ground.Polymesh::Polymesh_t = Polymesh::New("Bullet_Curved_Ground",Shape::#SHAPE_GRID)
  Protected *mesh.Geometry::PolymeshGeometry_t = *ground\geom
  ;PolymeshGeometry::InvertNormals(*mesh)
  
  Protected i
  Protected pos.v3f32
  Protected *p.v3f32
  
  For i=0 To CArray::GetCount(*mesh\a_positions)-1
    *p = CArray::GetValue(*mesh\a_positions,i)
    Vector3::Set(pos,*p\x*8,*p\y*3 + Random(5),*p\z*8)
    CArray::SetValue(*mesh\a_positions,i,pos)
  Next
  
  
  *ground\deformdirty = #True
;   PolymeshGeometry::SetColors(*mesh)
  PolymeshGeometry::ComputeNormals(*mesh,1.0)
  
  Topology::Update(*mesh\topo, *mesh\a_positions )
  
  Object3D::Freeze(*ground)
  
  Scene::AddChild(*scene,*ground)
  
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
  
EndProcedure


Procedure DeformGround()

  Protected *mesh.Geometry::PolymeshGeometry_t = *ground\geom

  Protected i
  Protected pos.v3f32
  Protected *p.v3f32
  
  For i=0 To CArray::GetCount(*mesh\a_positions)-1
    *p = CArray::GetValue(*mesh\a_positions,i)
  Next
  
  *ground\dirty = Object3D::#DIRTY_STATE_DEFORM
;   PolymeshGeometry::SetColors(*mesh)
  PolymeshGeometry::ComputeNormals(*mesh,1)
  
  Topology::Update(*mesh\base, *mesh\a_positions )
EndProcedure




Procedure BulletScene()

  *scene = Scene::New("Test Bullet")
  
  Global *root.Model::Model_t = Model::New("Model")
  
  Protected p.v3f32
  Protected q.q4f32
  
  Protected x,y,z
  
  Protected *pos.CArray::CArrayV3f32 = CArray::New(Types::#TYPE_V3F32)
  Protected *id.CArray::CArrayChar = CArray::New(Types::#TYPE_CHAR)
  Protected v.v3f32
  Protected i
  Protected nb = 164
  For i=0 To nb
    Vector3::Set(v,0,i,0)
    CArray::Append(*pos,@v)
  Next

Protected *t.Transform::Transform_t
Protected color.c4f32
Protected factor.v3f32
Vector3::Set(factor,1,1,1)
Color::Set(color,1.0,0.5,0.4,1.0)
  For x=0 To 4
    For y=0 To 12
      For z=0 To 4
        Protected *cube.Polymesh::Polymesh_t = Polymesh::New("RigidBody"+Str(x*10*10+y*10+z+1),Shape::#SHAPE_BUNNY)
        ;Protected *cube.CPolymesh = newCPolymesh("RigidBody"+Str(x*10*10+y*10+z+1),#RAA_Shape_Cube,Random(20)*0.2+0.1)
        Object3D::AddChild(*root,*cube)

        ;*cube\Sphere()
        ;OPolymeshGeometry_Sphere(*cube\GetGeometry(),1,12,12)
        *t.Transform::Transform_t = *cube\localT
        Vector3::Set(p,x*2-10,10*2+y,z*2-10)
        Vector3::SetFromOther(*t\t\pos,p)

        Quaternion::SetFromAxisAngleValues(q,Random(255)/255,Random(255)/255,Random(255)/255,Random(360))
        Quaternion::SetFromOther(*t\t\rot,q)
        
        Vector3::Set(*t\t\scl,3,3,3)
        *t\srtdirty = #True
        Object3D::SetLocalTransform(*cube,*t)
        Object3D::SetStaticTransform(*cube,*t)
        Object3D::UpdateTransform(*cube,*root\globalT)
        BulletRigidBody::BTCreateRigidBodyFrom3DObject(*cube,Bullet::#CONVEXHULL_SHAPE,1.0,Bullet::*bullet_world)
        Protected *body.Bullet::btRigidBody = *cube\rigidbody
        Bullet::BTSetAngularFactorF(*body,0.5)
        Bullet::BTSetFriction(*body,10)
        Color::Randomize(color)
        PolymeshGeometry::SetColors(*cube\geom,@color)
      Next z
    Next y
  Next x
  
    ;Ground
   BTCreateCurvedGroundData()
  
  Scene::AddModel(*scene,*root)
  ProcedureReturn *scene
EndProcedure

 ; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLContext::SetContext(*viewport\context)
  If EventType() = #PB_EventType_KeyDown
    If GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_Key) = #PB_Shortcut_Space
      BulletWorld::hlpReset(Bullet::*bullet_world)
    EndIf
  EndIf
  
  DeformGround()
  BulletWorld::hlpUpdate(Bullet::*bullet_world,1/25)
  
  *scene\dirty = #True
  Scene::Update(*scene)
  
  
  GLCheckError("TEST BULLET BEGIN DRAW")
  LayerDefault::Draw(*default, *scene, *viewport\context)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*viewport\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)

    
  GLCheckError("TEST BULLET END DRAW")
  
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
 width = 1024
 height = 720
 ; Main
 Globals::Init()
 Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   
   *app = Application::New("TestBullet",width,height,#PB_Window_SystemMenu|#PB_Window_SizeGadget)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
     View::SetContent(*app\window\main,*viewport)
     ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
     *default.Layer::Layer_t = LayerDefault::New(width,height,*viewport\context,*app\camera)
  Else
    GLContext::Setup(*viewport\context)
    Define *shader.Program::Program_t = *viewport\context\shaders("polymesh")
    *default.Layer::Layer_t = LayerDefault::New(width,height,*viewport\context,*app\camera)
  EndIf
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  
  BulletScene()
  
  Global *light.Light::Light_t = CArray::GetValuePtr(*scene\lights,0)
  

  
  
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
  
;   Global gbuffer.Layer::ILayer = *gbuffer
;   Global shadowmap.Layer::ILayer = *shadowmap
;   Global defered.Layer::ILayer = *defered
  
  

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
  Scene::Setup(*scene)
  
  Define nbb = Bullet::BTGetNumCollideObjects(Bullet::*bullet_world)
  
  
  Application::Loop(*app, @Draw())
EndIf
Bullet::Term()
Globals::Term()
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 6
; Folding = --
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; Constant = #USE_GLFW=0
; EnableUnicode
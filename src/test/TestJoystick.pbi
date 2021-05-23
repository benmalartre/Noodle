


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"
XIncludeFile "../controls/Joystick.pbi"


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
Global *joystick.Joystick::Joystick_t

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

Procedure UpdateObject(*object.Object3D::Object3D_t,*camera.Camera::Camera_t,x.f,z.f)
  
  Protected *ot.Transform::Transform_t = *object\localT
  Vector3::Set(*ot\t\pos,*ot\t\pos\x+x,*ot\t\pos\y+0,*ot\t\pos\z+z)
  *ot\srtdirty = #True
  Object3D::SetLocalTransform(*object,*ot)
EndProcedure

Procedure UpdateCamera(*object.Object3D::Object3D_t,*camera.Camera::Camera_t,x.f,y.f,azimuth.f,vertical.f)
   Protected *t.Transform::Transform_t = *camera\localT  
  Protected dir.v3f32
  Protected up.v3f32
  Vector3::Set(up,0,1,0)
  Vector3::Sub(@dir,*camera\pos,*camera\lookat)
  Vector3::NormalizeInPlace(@dir)
  
    Protected delta.v3f32
  Protected m3.m3f32
  Vector3::Set(delta,x,y)
  Vector3::Set(delta,delta\x,0,delta\y)
  MathUtils::DirectionToRotation(@m3,@dir,@up)
  Vector3::MulByMatrix3InPlace(@delta,@m3)
  
EndProcedure


; Draw
;--------------------------------------------
Procedure Update(*app.Application::Application_t)
  Joystick::GetAxis(*joystick)
  Joystick::GetButtons(*joystick)
  ; Update
  ;------------------------------------
  FirstElement(*joystick\axis())
  Protected x.f = *joystick\axis()\horizontal*0.1
  Protected z.f = *joystick\axis()\vertical*0.1
  
  NextElement(*joystick\axis())
  Protected azimuth = *joystick\axis()\horizontal
  Protected vertical = -*joystick\axis()\vertical
  Protected width.d,height.d
  
  UpdateObject(*bunny,*app\camera,x,z)
  Protected *cm.m4f32 = *app\camera\matrix
  Protected q.q4f32
  Protected v.v3f32
  Vector3::Set(v,x,0,z)

  Matrix4::GetQuaternion(*cm,@q)
  Vector3::MulByQuaternionInPlace(@v,@q)
  
  GLFW::glfwGetWindowSize(*app\window,@width,@height)
  Camera::Orbit(*app\camera,azimuth,vertical,width,height)

;   Quaternion::SetFromAxisAngleValues(*bunny\localT\t\rot,1,0,0,Math::#F32_PI_2)
  Transform::UpdateMatrixFromSRT(*bunny\localT)
 Scene::Update(Scene::*current_scene)
  ; Draw
  ;------------------------------------
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
  glUniform3f(glGetUniformLocation(shader,"lightPosition"),0.0,10.0,2.0)
  T+0.01
;   Quaternion::SetFromAxisAngleValues(*bunny\localT\t\rot,1,0,0,Math::#F32_PI_2)
;   Transform::UpdateMatrixFromSRT(*bunny\localT)
 
;   Polymesh::Draw(*torus)
;   Polymesh::Draw(*teapot)
  Scene::Draw(Scene::*current_scene,*s_polymesh)
;   Polymesh::Draw(*null)
;   Polymesh::Draw(*cube)
  
  
  glDisable(#GL_DEPTH_TEST)
  
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
  Protected i
  ForEach *joystick\buttons()
    FTGL::Draw(*app\context\writer,"Button: "+Str(i)+" Pressed : "+*joystick\buttons()\pressed,-0.9,0.9-(i*0.05),ss,ss*ratio)
    i+1
  Next
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
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("TestMesh",width,height)

   If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
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
  Scene::*current_scene = Scene::New()
  Global *root.Model::Model_t = Model::New("Model")
  
  ; Joystick
  ;-----------------------------------------------------
  *joystick = Joystick::New(GLFW::#GLFW_JOYSTICK_1)
  Joystick::GetAxis(*joystick)
  MessageRequester("JOYSTICK VALID",Str(*joystick\valid))
  
  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  
  *s_wireframe = Program::NewFromName("simple")
  *s_polymesh = Program::NewFromName("polymesh")
  
  shader = *s_polymesh\pgm

;   *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
;   *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
  *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
  Object3D::SetShader(*ground,*s_polymesh)
  Define pos.v3f32,scl.v3f32
  Vector3::Set(pos,0,-1,0)
  Vector3::Set(scl,100,1,100)
  Matrix4::SetScale(*ground\matrix,@scl)
  Matrix4::SetTranslation(*ground\matrix,@pos)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_TORUS)
  Object3D::SetShader(*bunny,*s_polymesh)
;   Polymesh::Setup(*torus,*s_polymesh)
;   Polymesh::Setup(*teapot,*s_polymesh)
;   Polymesh::Setup(*ground,*s_polymesh)
;   Polymesh::Setup(*bunny,*s_polymesh)
; Polymesh::Draw(*ground)
;   Polymesh::Draw(*bunny)
  
  Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root,*bunny)
   Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene)
  Application::Loop(*app, @Update())
EndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 77
; FirstLine = 73
; Folding = -
; EnableXP
; Executable = polymesh.exe
; Debugger = Standalone
; EnableUnicode
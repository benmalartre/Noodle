


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

Global *null.Polymesh::Polymesh_t

Global *buffer.Framebuffer::Framebuffer_t
Global shader.l
Global *s_wireframe.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *layer.LayerDefault::layerDefault_t

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

Procedure AddLocator(*parent.Object3D::Object3D_t,name.s,x.f,y.f,z.f)
  Protected *n.Locator::Locator_t = Locator::New(name.s)
  Protected *t.Transform::Transform_t = *n\localT
  ;   Vector3::Set(*t\t\pos,x,y,z)
  Debug "###### SET TRANSLATION XYZ VALUES :  "+StrF(x)+","+StrF(y)+","+StrF(z)
  Object3D::AddChild(*parent,*n)
  Protected q.q4f32
  Quaternion::SetIdentity(q)
  Transform::SetTranslationFromXYZValues(*t,x,y,z)
  Transform::SetRotationFromQuaternion(*t,q)
  Object3D::SetLocalTransform(*n,*t)
  Object3D::UpdateTransform(*n,*parent\globalT)
  ProcedureReturn *n
EndProcedure

Procedure AddGridNull(*root.Model::Model_t,*shader.Program::Program_t,i,j,k,width,height,depth)
  Protected x.f,y.f,z.f
  Protected xs.f,ys.f,zs.f
  x = -width/2
  y = -height/2
  z = -depth/2
  xs = width/i
  ys = height/j
  zs = depth/k
  
  Protected ii,jj,kk
  Protected *n.Locator::Locator_t
  For ii=0 To i-1
    For jj=0 To j-1
      For kk=0 To k-1
        Debug "Null"+Str(i)+Str(j)+Str(k)+" ---> "+StrF(x+ii*xs)+","+StrF(y+jj*ys)+","+StrF(z+kk*zs)
        *n = AddNull(*root,"Null"+Str(i)+Str(j)+Str(k),x+ii*xs,y+jj*ys,z+kk*zs)
        *n\icon = Locator::#Icon_Default
        
        Locator::SetShader(*n,*shader)
        
      Next
    Next
  Next
  
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
;   Framebuffer::BindOutput(*buffer)
;   glClearColor(0.25,0.25,0.25,1.0)
;   glViewport(0, 0, *viewport\width,*viewport\height)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glEnable(#GL_DEPTH_TEST)
  

 Scene::Update(Scene::*current_scene)
;   Scene::Draw(Scene::*current_scene,*app\context\shaders("wireframe"),-1)
  
;   Protected *buffer.Framebuffer::Framebuffer_t = *viewport\layer\buffer
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
;   
;   
;   glEnable(#GL_BLEND)
;   glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
;   glDisable(#GL_DEPTH_TEST)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   FTGL::Draw(*app\context\writer,"Null Testing",-0.9,0.9,ss,ss*ratio)
; 
;   glDisable(#GL_BLEND)
  ViewportUI::Draw(*viewport, *app\context)
  ViewportUI::FlipBuffer(*viewport)
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
   *app = Application::New("Test Null",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
     *layer = LayerDefault::New(width, height, *app\context, *app\camera)
     *viewport\camera = *app\camera
     ViewportUI::AddLayer(*viewport, *layer)
     View::SetContent(*app\manager\main,*viewport)
      ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf

  Scene::*current_scene = Scene::New()
  Global *root.Model::Model_t = Model::New("Model")
 
  AddGridNull(*root,*app\context\shaders("wireframe"),10,10,10,20,20,20)
  Scene::AddModel(Scene::*current_scene, *root)
  
  Define pos.v3f32,scl.v3f32
  Vector3::Set(pos,0,-1,0)
  Vector3::Set(scl,100,1,100)
  Scene::Setup(Scene::*current_scene,*app\context)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 87
; FirstLine = 83
; Folding = -
; EnableXP
; EnableUnicode
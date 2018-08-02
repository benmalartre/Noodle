


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
Global *s_simple.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *ftgl_drawer.FTGL::FTGL_Drawer
Global *handle.Handle::Handle_t

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
;   LayerDefault::Draw(*layer, *app\context)
;   LayerShadowMap::Draw(*shadows, *app\context)
;   LayerGBuffer::Draw(*gbuffer,*app\context)
  ;LayerDefered::Draw(*defered,*app\context)
;   LayerShadowDefered::Draw(*defshadows, *app\context)
  
  glClearColor(0,0,0,0)
  glClear(#GL_DEPTH_BUFFER_BIT|#GL_COLOR_BUFFER_BIT)
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*ftgl_drawer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*ftgl_drawer,"Nb Vertices : "+Str(*torus\geom\nbpoints),-0.9,0.9,ss,ss*ratio)

  glDisable(#GL_BLEND)
  
  glUseProgram(*s_wireframe\pgm)
  Protected identity.m4f32
  Matrix4::SetIdentity(@identity)
  
  glUniformMatrix4fv(glGetUniformLocation(*s_wireframe\pgm,"model"),1,#GL_FALSE,@identity)
  glUniformMatrix4fv(glGetUniformLocation(*s_wireframe\pgm,"view"),1,#GL_FALSE, Layer::GetViewMatrix(*layer))
  glUniformMatrix4fv(glGetUniformLocation(*s_wireframe\pgm,"projection"),1,#GL_FALSE, Layer::GetProjectionMatrix(*layer))

  Handle::Draw(*handle, *app\context)
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
  
  *s_wireframe = *app\context\shaders("wireframe")
  *s_polymesh = *app\context\shaders("polymesh")
  *s_simple = *app\context\shaders("simple")
  
  shader = *s_polymesh\pgm
  
  Global *model.Model::Model_t = Model::New("Model")
  *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
  Object3D::SetShader(*torus,*s_polymesh)
  
  *handle = Handle::New()
  Object3D::SetShader(*handle, *s_wireframe)
  
  Handle::SetTarget(*handle, *torus)
  Handle::SetActiveTool(*handle, Globals::#TOOL_TRANSLATE)

  Object3D::AddChild(*model,*torus)
  Scene::AddObject(Scene::*current_scene,*handle)
  Scene::AddModel(Scene::*current_scene,*model)
   Scene::Setup(Scene::*current_scene,*app\context)
   
   Handle::SetActiveTool(*handle, Globals::#TOOL_ROTATE)
   Handle::InitTransform(*handle, *torus\globalT)
   Handle::Resize(*handle,*app\camera)
   Handle::Setup(*handle, *app\context)
   Handle::Update(*handle)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 163
; FirstLine = 112
; Folding = -
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
﻿

EnableExplicit

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
  
; ;    Handle::SetActiveTool(*handle, *app\tool)
; ;    Handle::InitTransform(*handle, *torus\globalT)
; ;    Handle::Resize(*handle,*app\camera)
; ;    Handle::Setup(*handle, *app\context)
; ;    Handle::Update(*handle)
; ;    
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  Vector3::Set(*light\pos, 5-Random(10),10,5-Random(10))
  Light::Update(*light)
  ViewportUI::SetContext(*viewport)
  Scene::Update(Scene::*current_scene)
  
  ViewportUI::Draw(*viewport, *app\context)
  ;LayerDefault::Draw(*layer, *app\context)
;   LayerShadowMap::Draw(*shadows, *app\context)
;   LayerGBuffer::Draw(*gbuffer,*app\context)
  ;LayerDefered::Draw(*defered,*app\context)
;   LayerShadowDefered::Draw(*defshadows, *app\context)
  
;   glClearColor(0,0,0,0)
;   glClear(#GL_DEPTH_BUFFER_BIT|#GL_COLOR_BUFFER_BIT)
;   glEnable(#GL_BLEND)
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*torus\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  
  Select *app\tool
    Case Globals::#TOOL_TRANSLATE
      FTGL::Draw(*app\context\writer,"Active Tool : Translate",-0.9,0.8,ss,ss*ratio)
    Case Globals::#TOOL_ROTATE
      FTGL::Draw(*app\context\writer,"Active Tool : Rotate",-0.9,0.8,ss,ss*ratio)
    Case Globals::#TOOL_SCALE
      FTGL::Draw(*app\context\writer,"Active Tool : Scale",-0.9,0.8,ss,ss*ratio)
    Case Globals::#TOOL_CAMERA
      FTGL::Draw(*app\context\writer,"Active Tool : Camera",-0.9,0.8,ss,ss*ratio)
  EndSelect
  

  FTGL::EndDraw(*app\context\writer)
  

;   Handle::Draw(*handle, *app\context)
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
  ViewportUI::AddLayer(*viewport, *layer)
;   *shadows = LayerShadowMap::New(800,800,*app\context,CArray::GetValuePtr(Scene::*current_scene\lights, 0))
;   *gbuffer = LayerGBuffer::New(800,600,*app\context,*app\camera)
;   *defered = LayerDefered::New(800,600,*app\context,*gbuffer\buffer,*shadows\buffer,*app\camera)
;   *defshadows = LayerShadowDefered::New(800,600,*app\context,*gbuffer\buffer, *shadows\buffer,*app\camera)
  Global *root.Model::Model_t = Model::New("Model")
  
  ; FTGL Drawer
  ;-----------------------------------------------------
    
  *s_wireframe = *app\context\shaders("wireframe")
  *s_polymesh = *app\context\shaders("polymesh")
  *s_simple = *app\context\shaders("simple")
  
  shader = *s_polymesh\pgm
  
  Global *model.Model::Model_t = Model::New("Model")
  *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
  Object3D::SetShader(*torus,*s_polymesh)
  Object3D::AddChild(*model,*torus)
  Scene::AddModel(Scene::*current_scene,*model)
  Scene::Setup(Scene::*current_scene,*app\context)
  
;   Scene::SelectObject(Scene::*current_scene, *torus)
  ViewportUI::SetHandleTarget(*viewport, *torus)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 133
; FirstLine = 105
; Folding = -
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
XIncludeFile "../core/Application.pbi"

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

Global *scene.Scene::Scene_t
Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t

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
Global *positions.CArray::CArrayV3F32 = CArray::New(Types::#TYPE_V3F32)
Global *texts.CArray::CArrayStr = CArray::New(Types::#TYPE_STR)

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
  width = WindowWidth(window,#PB_Window_InnerCoordinate)
  height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
EndProcedure

Procedure RandomSpheres(numItems.i,y.f=0)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Drawer::Item_t
  Protected m.m4f32
  Protected p.v3f32
  Define i,j
  For i=0 To numItems-1
    Vector3::Set(p,i, y, (Random(10)-5)/10)
    Matrix4::SetIdentity(m)
    Matrix4::SetTranslation(m,p)

    Color::Set(color, Random(255)/255, Random(255)/255, Random(255)/255,1)
    *item = Drawer::AddSphere(*drawer, m)
    Drawer::SetColor(*item,  color)
  Next
EndProcedure

Procedure RandomCubes(numItems.i,y.f=0)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Drawer::Item_t
  
  Protected m.m4f32
  Protected p.v3f32
  Define i,j
  For i=0 To numItems-1
    Vector3::Set(p,i, y, (Random(10)-5)/10)
    Matrix4::SetIdentity(m)
    Matrix4::SetTranslation(m,p)

    Color::Set(color, Random(255)/255, Random(255)/255, Random(255)/255,1)
    *item = Drawer::AddBox(*drawer, @m)
    *item\wireframe = Bool(Random(10)>5)
    Drawer::SetColor(*item,  @color)
  Next
EndProcedure

Procedure RandomStrips(numItems.i)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Drawer::Item_t
  CArray::SetCount(*positions, 12)
  Define i,j
  For i=0 To numItems-1
    For j=0 To CArray::GetCount(*positions)-1
      Vector3::Set(position, i, j, (Random(10)-5)/10)
      CArray::SetValue(*positions, j, position)
    Next
    Color::Set(color, Random(255)/255, Random(255)/255, Random(255)/255,1)
    *item = Drawer::AddStrip(*drawer, *positions)
    Drawer::SetColor(*item,  @color)
    Drawer::SetSize(*item, 6)
  Next
EndProcedure

Procedure RandomPoints(numItems.i)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Drawer::Item_t
  CArray::SetCount(*positions, 12)
  Define i,j
  For i=0 To numItems-1
    For j=0 To CArray::GetCount(*positions)-1
      Vector3::Set(position, i, j, (Random(10)-5)/10)
      CArray::SetValue(*positions, j, position)
    Next
    Color::Set(color, Random(255)/255, Random(255)/255, Random(255)/255,1)
    *item = Drawer::AddPoints(*drawer, *positions)
    Drawer::SetColor(*item,  @color)
    Drawer::SetSize(*item, 6)
  Next
EndProcedure

Procedure RandomTexts(numItems.i, text.s)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Drawer::Item_t
  CArray::SetCount(*positions, 12)
  Define i,j
  For i=0 To numItems-1

    Vector3::Set(position, i, j, (Random(10)-5)/10)
    Color::Set(color, Random(255)/255, Random(255)/255, Random(255)/255,1)
    *item = Drawer::AddText(*drawer, position, "zobiniktou")
    Drawer::SetColor(*item,  @color)
    Drawer::SetSize(*item, 6)
  Next
EndProcedure


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  GLContext::SetContext(*viewport\context)
;   Drawer::Flush(*drawer)

  *scene\dirty= #True
  
  Scene::Update(*scene)
;   GLContext::SetContext(*viewport\context)
  LayerDefault::Draw(*layer, *scene, *viewport\context)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  
  Define ss.f = 0.85/*viewport\sizX
  Define ratio.f = *viewport\sizX / *viewport\sizy
  FTGL::Draw(*viewport\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  glDisable(#GL_BLEND)
  
 GLContext::FlipBuffer(*viewport\context)
  

 EndProcedure

 Define useJoystick.b = #False
 width = 800
 height = 600
 
 ; Main
 Globals::Init()
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   *app = Application::New("Test Drawer",width,height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI",*app\camera, *app\handle)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
   
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *scene = Scene::New()
  *layer = LayerDefault::New(800,600,*viewport\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
    
  *s_wireframe = GLContext::*SHARED_CTXT\shaders("simple")
  *s_polymesh = GLContext::*SHARED_CTXT\shaders("polymesh")
  
  shader = *s_polymesh\pgm
; 
;   Define *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
;   Object3D::SetShader(*ground,*s_polymesh)
 
  Define i
  
  *drawer = Drawer::New("Drawer")
  
;   Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(*scene,*root)
  
  RandomSpheres(Random(64,16), Random(10)-5)
  RandomPoints(Random(256, 64))
  RandomCubes(Random(64,16), Random(10)-5)
  RandomStrips(32)
;   RandomTexts(32,"HELLO")
;   
  Scene::Setup(*scene)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 211
; FirstLine = 160
; Folding = --
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
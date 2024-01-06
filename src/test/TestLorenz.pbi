
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

Structure Lorenz_t
  x.f
  y.f
  z.f
  a.f
  b.f
  c.f
  t.f
  max_pnts.i
  np.i
EndStructure

Procedure InitLorenz(*Me.Lorenz_t, max_pnts)
  *Me\x = 0.1
  *Me\y = 0
  *Me\z = 0
  *Me\a = 10.0
  *Me\b = 28.0
  *Me\c = 8.0 / 3.0
  *Me\t = 0.01
  *Me\max_pnts = max_pnts
  *Me\np = 0
EndProcedure

Procedure UpdateLorenz(*Me.Lorenz_t)
  Define.f xt, yt, zt
  xt = *Me\x + *Me\t * *Me\a * (*Me\y - *Me\x)
  yt = *Me\y + *Me\t * (*Me\x * (*Me\b - *Me\z) - *Me\y)
  zt = *Me\z + *Me\t * (*Me\x * *Me\y - *Me\c * *Me\z)
  
  *Me\x = xt
  *Me\y = yt
  *Me\z = zt
EndProcedure


Global down.b
Global lmb_p.b
Global mmb_p.b
Global rmb_p.b
Global oldX.f
Global oldY.f
Global width.i
Global height.i

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
Global *positions.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
Global np.Math::v3f32
Global lorenz.Lorenz_t

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
  width = WindowWidth(window,#PB_Window_InnerCoordinate)
  height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
EndProcedure

Procedure DrawLorenz(*l.Lorenz_t)
  Vector3::Set(np, *l\x, *l\y, *l\z)
  If Carray::GetCount(*positions) < *l\max_pnts
    CArray::Append(*positions, np)
    *l\np + 1
  Else
    CArray::Remove(*positions, 0)
    CArray::Append(*positions, np)
  EndIf
  
  Drawer::AddStrip(*drawer, *positions)
;   Define position.Math::v3f32
;   Define color.Math::c4f32
;   Protected *item.Drawer::Item_t
;   CArray::SetCount(*positions, 12)
;   Define i,j
;   For i=0 To numItems-1
;     For j=0 To CArray::GetCount(*positions)-1
;       Vector3::Set(position, i, j, (Random(10)-5)/10)
;       CArray::SetValue(*positions, j, position)
;     Next
;     Color::Set(color, Random(255)/255, Random(255)/255, Random(255)/255,1)
;     *item = Drawer::AddPoints(*drawer, *positions)
;     Drawer::SetColor(*item,  @color)
;     Drawer::SetSize(*item, 6)
;   Next
EndProcedure


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  GLContext::SetContext(*viewport\context)
  Drawer::Flush(*drawer)
  ;   RandomSpheres(Random(64,16), Random(10)-5)
  UpdateLorenz(lorenz)
  DrawLorenz(lorenz)
;   RandomPoints(Random(256, 64))
  *app\scene\dirty= #True
  
  Scene::Update(*app\scene)
  LayerDefault::Draw(*layer, *app\scene)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*viewport\context\writer,"Lorenz Attractor : "+Str(lorenz\np),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  glDisable(#GL_BLEND)
  
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure
 
 Define i
 Define useJoystick.b = #False
 width = 800
 height = 600
 
 InitLorenz(lorenz, 2048)
 ; Main
 Globals::Init()
 FTGL::Init()

 If Time::Init()
   Log::Init()
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   *app = Application::New("Test Lorenz",width,height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
 
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  *layer = LayerDefault::New(800,600,*viewport\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
  *drawer = Drawer::New("Drawer")
  
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(*app\scene,*root)
  Scene::Setup(*app\scene)
   
  Application::Loop(*app, @Draw(), 1/60)
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 131
; FirstLine = 111
; Folding = --
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
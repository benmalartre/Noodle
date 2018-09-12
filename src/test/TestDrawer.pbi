


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
Global *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()

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
    Vector3::Set(@p,i, y, (Random(10)-5)/10)
    Matrix4::SetIdentity(@m)
    Matrix4::SetTranslation(@m,@p)

    Color::Set(@color, Random(255)/255, Random(255)/255, Random(255)/255)
    *item = Drawer::NewSphere(*drawer, @m)
    Drawer::SetColor(*item,  @color)
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
    Vector3::Set(@p,i, y, (Random(10)-5)/10)
    Matrix4::SetIdentity(@m)
    Matrix4::SetTranslation(@m,@p)

    Color::Set(@color, Random(255)/255, Random(255)/255, Random(255)/255)
    *item = Drawer::NewBox(*drawer, @m)
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
      Vector3::Set(@position, i, j, (Random(10)-5)/10)
      CArray::SetValue(*positions, j, @position)
    Next
    Color::Set(@color, Random(255)/255, Random(255)/255, Random(255)/255)
    *item = Drawer::NewStrip(*drawer, *positions)
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
      Vector3::Set(@position, i, j, (Random(10)-5)/10)
      CArray::SetValue(*positions, j, @position)
    Next
    Color::Set(@color, Random(255)/255, Random(255)/255, Random(255)/255)
    *item = Drawer::NewPoints(*drawer, *positions)
    Drawer::SetColor(*item,  @color)
    Drawer::SetSize(*item, 6)
  Next
EndProcedure


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  ViewportUI::SetContext(*viewport)
  Drawer::Flush(*drawer)
;   RandomSpheres(Random(64,16), Random(10)-5)
  RandomCubes(Random(64,16), Random(10)-5)
  RandomStrips(32)
;   RandomPoints(Random(256, 64))
  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer, *app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  glDisable(#GL_BLEND)
  
  ViewportUI::FlipBuffer(*viewport)

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
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
 
  
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
    
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm
; 
;   Define *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
;   Object3D::SetShader(*ground,*s_polymesh)
 
  Define i
  
  *drawer = Drawer::New("Drawer")
  
;   Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 132
; FirstLine = 95
; Folding = --
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode
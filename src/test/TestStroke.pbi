XIncludeFile "../core/Application.pbi"

Global *app.Application::Application_t 
Global *viewport.ViewportUI::ViewportUI_t
Global *scene.Scene::Scene_t
Global *layer.LayerDefault::LayerDefault_t
Global *stroke.LayerStroke::LayerStroke_t

Time::Init()
Log::Init()

#width = 800
#height = 400

Global down.b = #False
Procedure Update()
  
    GLContext::SetContext(*viewport\context)
  Scene::Update( *app\scene)
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  ViewportUI::Blit(*viewport, *layer\framebuffer)

  
;   Define e,x,y,mx,my
;   Define *current.View::View_t
; ;   
; ;   If Event() = #PB_Event_Gadget And EventGadget() = *viewport\gadgetID
; ;     Select EventType()
; ;       Case #PB_EventType_LeftButtonDown
; ;         LayerStroke::StartStroke(*stroke)
; ;         down = #True
; ;       Case #PB_EventType_LeftButtonUp
; ;         If down
; ;           LayerStroke::EndStroke(*stroke)
; ;           down = #False
; ;         EndIf
; ;       Case #PB_EventType_MouseMove
; ;         If down
; ;           Define mx,my
; ;           mx = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseX)
; ;           my = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseY)
; ;           LayerStroke::AddPoint(*stroke,mx,my)
; ;         EndIf
; ;         
; ;     EndSelect
; ;   EndIf  
; 
;   Scene::Update(*app\scene)  
;   
  GLContext::SetContext(*viewport\context)
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
;   
; ;   LayerStroke::Update(*stroke)
; ;   LayerStroke::Draw(*stroke, *viewport\context)
; ;   ViewportUI::Blit(*viewport, *stroke\framebuffer)
; 
;  
; ;   
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*viewport\context\writer,"Test Shadow Map",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*viewport\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
;   
  GLContext::FlipBuffer(*viewport\context)

  
EndProcedure

width = 800
 height = 800
 
 Globals::Init()
 FTGL::Init()
 

 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("Test Delaunay Triangulation",width,height)
   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"Test Stroke", *app\camera, *app\handle)     
   
  EndIf

  *app\scene= Scene::New()
  Define *model.Model::Model_t = Model::New("Model")
  
  
  Define *sphere.Polymesh::Polymesh_t = Polymesh::New("mesh", Shape::#SHAPE_BUNNY)
  Object3D::AddChild(*model, *sphere)
Scene::AddModel(*app\scene, Scene::CreateMeshGrid(6,6,6,Shape::#SHAPE_SPHERE))
*layer.LayerDefault::LayerDefault_t = LayerDefault::New(*viewport\sizX,*viewport\sizY,*viewport\context, *app\camera)
; *stroke.LayerStroke::LayerStroke_t = LayerStroke::New(*viewport\sizX,*viewport\sizY,*viewport\context, *app\camera)


; Define i, j
; For j=0 To 6
;   LayerStroke::StartStroke(*layer)
;   For i=0 To *viewport\sizX/100
;     LayerStroke::AddPoint(*layer,i*100, j*10 +Sin(i*0.1)*8 + *viewport\sizY * 0.5 + Random(5)-2.5)
;   Next
;   LayerStroke::EndStroke(*layer)
; Next


Scene::Setup(*app\scene)

Application::Loop(*app,@Update())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 51
; FirstLine = 41
; Folding = -
; EnableXP
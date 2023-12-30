XIncludeFile "../core/Application.pbi"

Global *app.Application::Application_t 
Global *viewport.ViewportUI::ViewportUI_t
Global *scene.Scene::Scene_t
Global *layer.LayerStroke::LayerStroke_t


Time::Init()
Log::Init()

#width = 800
#height = 400

Global down.b = #False
Procedure Update()
  Define e,x,y,mx,my
  Define *current.View::View_t
  
  If Event() = #PB_Event_Gadget And EventGadget() = *viewport\gadgetID
    Select EventType()
      Case #PB_EventType_LeftButtonDown
        LayerStroke::StartStroke(*layer)
        down = #True
      Case #PB_EventType_LeftButtonUp
        If down
          LayerStroke::EndStroke(*layer)
          down = #False
        EndIf
      Case #PB_EventType_MouseMove
        If down
          Define mx,my
          mx = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseX)
          my = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseY)
          LayerStroke::AddPoint(*layer,mx,my)
        EndIf
        
    EndSelect
  EndIf  
  
  GLContext::SetContext(*viewport\context)
  LayerStroke::Update(*layer)
  LayerStroke::Draw(*layer, *viewport\context)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  GLContext::FlipBuffer(*viewport\context)

  
EndProcedure

*app = Application::New("TestStrokes",#width,#height)
OpenGLExt::GLCheckError("create application")

If Not #USE_GLFW
  *viewport = ViewportUI::New(*app\window\main,"Viewport", *app\camera, *app\handle)     
  OpenGLExt::GLCheckError("create viewport")
;   Application::SetContext(*app, *viewport\context)
  OpenGLExt::GLCheckError("set application context")
 ;*app\context\writer\background = #True
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  OpenGLExt::GLCheckError("resize viewport")
EndIf

; *scene= Scene::New()
; Define *sphere.Polymesh::Polymesh_t = Polymesh::New("mesh", Shape::#SHAPE_SPHERE)
; Scene::AddChild(*scene, *sphere)

*layer.LayerStroke::LayerStroke_t = LayerStroke::New(*viewport\sizX,*viewport\sizY,*viewport\context, *app\camera)
OpenGLExt::GLCheckError("create strokes layer")


; Define i, j
; For j=0 To 6
;   LayerStroke::StartStroke(*layer)
;   For i=0 To *viewport\sizX/100
;     LayerStroke::AddPoint(*layer,i*100, j*10 +Sin(i*0.1)*8 + *viewport\sizY * 0.5 + Random(5)-2.5)
;   Next
;   LayerStroke::EndStroke(*layer)
; Next



Application::AddLayer(*app, *layer)
; Scene::Setup(*scene, *app\context)

Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 56
; FirstLine = 29
; Folding = -
; EnableXP
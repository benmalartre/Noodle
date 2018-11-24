
; ============================================================================
;  raafal viewport with 3D Objects + WIP Alembic + WIP Manipulator
; ............................................................................
;  this is he main file
; ============================================================================
;  2013/04/01 | Ben Malartre
;  - creation
; ============================================================================


XIncludeFile "../core/Application.pbi"

Global *app.Application::Application_t 
Global *viewport.ViewportUI::ViewportUI_t
Global *stroke.LayerStroke::LayerStroke_t


Time::Init()
Log::Init()

Enumeration
  #Main_Window = 0
  #Timeline_Window
  #View3D_Window
  #Explorer_Window
EndEnumeration
#width = 800
#height = 400

Global down.b = #False
Procedure Update()
  Define e,x,y,mx,my
  Define *current.View::View_t
  
  LayerStroke::Update(*stroke)
  LayerStroke::Draw(*stroke, *viewport\context)
  
 ViewportUI::FlipBuffer(*viewport)
  ;*stroke\Draw(*viewport\context,0)

  If Event() = #PB_Event_Gadget And EventGadget() = *viewport\gadgetID
    Select EventType()
      Case #PB_EventType_LeftButtonDown
        LayerStroke::StartStroke(*stroke)
        down = #True
      Case #PB_EventType_LeftButtonUp
        If down
          LayerStroke::EndStroke(*stroke)
          down = #False
        EndIf
      Case #PB_EventType_MouseMove
        If down
          Define mx,my
          mx = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseX)
          my = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseY)
          LayerStroke::AddPoint(*stroke,mx,my)
        EndIf
        
    EndSelect
  EndIf  
EndProcedure

Scene::*current_scene = Scene::New()
Define *scene.Scene::Scene_t = Scene::*current_scene
Define *sphere.Polymesh::Polymesh_t = Polymesh::New("mesh", Shape::#SHAPE_BUNNY)
Define *geom.Geometry::PolymeshGeometry_t = *sphere\geom
Scene::AddChild(*scene, *sphere)

*app.Application::Application_t = Application::New("TEST STROKES", 800, 600)
;Define viewport.CViewport = newCViewport(*manager\main);*manager\main\gadgetID,*manager\window)
; Define *view.View::View_t = View::Split(*app\manager\main,#False)

; Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*splitted\left, "Viewport")
*viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*app\manager\main, "Viewport");*manager\main\gadgetID,*manager\window)
*app\context = *viewport\context
*viewport\camera = *app\camera

; Define *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*view\right)
; ExplorerUI::Setup(*explorer)

; OScene_Setup(*raa_current_scene,0,#True)
Scene::Setup(Scene::*current_scene,*viewport\context)


*stroke.LayerStroke::LayerStroke_t = LayerStroke::New(*viewport\width,*viewport\height,*viewport\context, *app\camera)
LayerStroke::Setup(*stroke, *app\context)

Define i, j
For j=0 To 6
  LayerStroke::StartStroke(*stroke)
  For i=0 To *viewport\width /100
    LayerStroke::AddPoint(*stroke,i*100, j*10 +Sin(i*0.1)*8 + *viewport\height * 0.5 + Random(5)-2.5)
  Next
  LayerStroke::EndStroke(*stroke)
Next



ViewportUI::AddLayer(*viewport, *stroke)
Scene::Setup(Scene::*current_scene, *app\context)

Application::Loop(*app,@Update())

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 30
; FirstLine = 26
; Folding = -
; EnableXP
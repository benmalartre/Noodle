XIncludeFile "Application.pbi"


DeclareModule DemoApplication
  Structure DemoApplication_t Extends Application::Application_t
    *viewport.ViewportUI::ViewportUI_t
  EndStructure
  
  Declare New (name.s, width.i=800, height.i=800, options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  Declare Draw(*Me.DemoApplication_t)
EndDeclareModule

Module DemoApplication
  Procedure New(name.s, width=800, height=800, options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    Protected *Me.DemoApplication_t = AllocateStructure(DemoApplication_t)
    *Me\name = name
    *running = *Me
    Protected w.i, h.i
   
    *Me\window = Window::New(name,0,0,width,height,options)

    *Me\width = WindowWidth(*Me\window\ID,#PB_Window_InnerCoordinate)
    *Me\height = WindowHeight(*Me\window\ID,#PB_Window_InnerCoordinate)
  
    *Me\idle = #True
          
    *Me\camera = Camera::New("Camera",Camera::#Camera_Perspective)
    *Me\handle = Handle::New()
    *Me\handle\camera = *Me\camera
;     *Me\select = LayerSelection::New(width, height, *Me\context, *Me\camera)
;     Handle::Setup(*Me\handle, *Me\context)
    
    Protected *main.View::View_t = *Me\window\main
    Protected *view.View::View_t = View::Split(*main,0,50)
    Protected *top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)
    
    Protected *middle.View::View_t = View::Split(*top\right,#PB_Splitter_Vertical,60)
    Protected *center.View::View_t = View::Split(*middle\left,#PB_Splitter_Vertical,30)
    Protected *bottom.View::View_t = View::Split(*view\right,#PB_Splitter_SecondFixed,120)
    
    Protected *menu.MenuUI::MenuUI_t = MenuUI::New(*top\left,"Menu")
    Protected *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*center\left,"Explorer")
    Protected *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*center\right,"Viewport", *Me\camera, *Me\handle)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
    
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Draw(*Me.DemoApplication_t)
  EndProcedure
  
  
EndModule


Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
UIColor::Init()

Define *demo.DemoApplication::DemoApplication_t = DemoApplication::New("Demo")



Application::Loop(*demo, DemoApplication::@Draw())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 8
; FirstLine = 10
; Folding = -
; EnableXP
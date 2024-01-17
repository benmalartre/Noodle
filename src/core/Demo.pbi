XIncludeFile "Application.pbi"

;   ====================================
;  |   menu/toolbar                   * |
;  |------------------------------------|
;  | explorer | viewport    |  property |
;  |          |             |           |
;  |          |             |           |
;  |------------------------------------|
;  |    timeline                        |
;   ====================================

DeclareModule DemoApplication
  Enumeration
    #Demo_With_Menu     = 1 << 1
    #Demo_With_Timeline = 1 << 2
    #Demo_With_Explorer = 1 << 3
    #Demo_With_Property = 1 << 4
    #Demo_With_Viewport = 1 << 5
    #Demo_With_Custom   = 1 << 6
  EndEnumeration
  
  #Demo_With_All = #Demo_With_Menu|#Demo_With_Explorer|#Demo_With_Property|#Demo_With_Timeline|#Demo_With_Viewport
  
  Prototype UpdateFN(*ptr)
  
  Structure DemoApplication_t Extends Application::Application_t
    *explorer.ExplorerUI::ExplorerUI_t
    *property.PropertyUI::PropertyUI_t
    *timeline.TimelineUI::TimelineUI_t
    *viewport.ViewportUI::ViewportUI_t
    *canvas.CanvasUI::CanvasUI_t
    *view.View::View_t
    *layer.LayerDefault::LayerDefault_t
    
    updateImpl.UpdateFN
  EndStructure
  
  Declare Init (*Me.DemoApplication_t, name.s, width.i=1200, height.i=800, options=#Demo_With_All)
  Declare Update(*Me.DemoApplication_t)
  Declare GetView(*Me.DemoApplication_t)
  
EndDeclareModule

Module DemoApplication
  UseModule OpenGL
  UseModule OpenGLExt
  Procedure Init(*Me.DemoApplication_t, name.s, width=1200, height=800, options=#Demo_With_All)

    Globals::Init()
    Time::Init()
    Log::Init()
    FTGL::Init()
    Commands::Init()
    UIColor::Init()
    CompilerIf #USE_ALEMBIC
      Alembic::Init()
    CompilerEndIf
   
    *Me\name = name
    *Me\window = Window::New(name,0,0,width,height,#PB_Window_SystemMenu|#PB_Window_SizeGadget)
    *Me\width = WindowWidth(*Me\window\ID,#PB_Window_InnerCoordinate)
    *Me\height = WindowHeight(*Me\window\ID,#PB_Window_InnerCoordinate)
    *Me\idle = #True
    *Me\scene = Scene::New()
    *Me\camera = Camera::New("Camera",Camera::#Camera_Perspective)
    *Me\handle = Handle::New(*Me\camera)
;     *Me\select = LayerSelection::New(width, height, *Me\context, *Me\camera)
;     Handle::Setup(*Me\handle, *Me\context)
    
    Define.View::View_t *view, *top, *middle, *bottom, *left, *right
    
    *view = *Me\window\main
    If options & #Demo_With_Menu
      View::Split(*view,#PB_Splitter_FirstFixed,0)
      *left = *view\left
      *view = *view\right
      *Me\window\menu = MenuUI::New(*left,"Menu")
      Define *item.MenuUI::MenuItem_t = MenuUI::AddItem(*Me\window\menu, "File", 0)
      MenuUI::AddSubItem(*Me\window\menu, *item, "Load", Globals::#Menu_Scene_Load)
      MenuUI::AddSubItem(*Me\window\menu, *item, "Save", Globals::#Menu_Scene_Save)
      MenuUI::AddSubItem(*Me\window\menu, *item, "Save As", Globals::#Menu_Scene_SaveAs)
      
;       Define *subitem = MenuUI::AddSubItem(*Me\window\menu, *item, "three", 3)
;       
;       MenuUI::AddSubItem(*Me\window\menu, *subitem, "sub-one", 4)
;       MenuUI::AddSubItem(*Me\window\menu, *subitem, "sub-two", 5)
;       MenuUI::AddSubItem(*Me\window\menu, *subitem, "sub-three", 6)
    EndIf
    If options & #Demo_With_Timeline
      View::Split(*view,#PB_Splitter_SecondMinimumSize|#PB_Splitter_SecondFixed,60)
      *bottom = *view\right
      *view = *view\left
      Protected *timeline.TimelineUI::TimelineUI_t = TimelineUI::New(*bottom,"Timeline")
    EndIf
    
    If options & #Demo_With_Explorer
      View::Split(*view,#PB_Splitter_Vertical,20)
      *left = *view\left
      *view = *view\right
      *Me\explorer = ExplorerUI::New(*left,"Explorer")
      ExplorerUI::Connect(*Me\explorer, *Me\scene)
    EndIf
    
     If options & #Demo_With_Property
       View::Split(*view,#PB_Splitter_Vertical,75)
       *Me\property = PropertyUI::New(*view\right,"Property")
      *view = *view\left
    EndIf
    
    If options & #Demo_With_Custom
      View::Split(*view)
      *Me\view = *view\right
      *view = *view\left
    Else
      *Me\view = *view
    EndIf
    
    If options & #Demo_With_Viewport
      *Me\viewport = ViewportUI::New(*view,"Viewport", *Me\camera, *Me\handle)
      *Me\layer = LayerDefault::New(*Me\viewport\sizX, *Me\viewport\sizY, *Me\viewport\context, *Me\camera)
      GLContext::AddFramebuffer(*Me\viewport\context, *Me\layer\framebuffer)
  
      ViewportUI::OnEvent(*Me\viewport,#PB_Event_SizeWindow)
    Else
      *Me\canvas = CanvasUI::New(*view, "Canvas")
    EndIf
    
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Update(*Me.DemoApplication_t)
    If *Me\viewport
      GLContext::SetContext(*Me\viewport\context)
      If *Me\updateImpl
        Define fn.UpdateFN = *Me\updateImpl
        fn(*Me)
      EndIf
  
      LayerDefault::Draw(*Me\layer, *Me\scene, *Me\viewport\context)
      
      ViewportUI::Blit(*Me\viewport, *Me\layer\framebuffer)
  
      FTGL::BeginDraw(*Me\viewport\context\writer)
      FTGL::SetColor(*Me\viewport\context\writer, 1,1,1,1)
    
      Define ss.f = 0.85/width
      Define ratio.f = width / height
      FTGL::Draw(*Me\viewport\context\writer,"Demo : "+*Me\name,-0.9,0.9,ss,ss*ratio)
      FTGL::EndDraw(*Me\viewport\context\writer)
      
      GLContext::FlipBuffer(*Me\viewport\context)
    EndIf
    
  EndProcedure
  
  Procedure GetView(*Me.DemoApplication_t)
    ProcedureReturn *Me\view
  EndProcedure

EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 126
; FirstLine = 80
; Folding = --
; EnableXP
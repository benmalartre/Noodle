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
    #WITH_MENU     = 1 << 1
    #WITH_TIMELINE = 4 << 2
    #WITH_EXPLORER = 8 << 3
    #WITH_PROPERTY = 16 << 4
  EndEnumeration
  
  #WITH_ALL = #WITH_MENU|#WITH_EXPLORER|#WITH_PROPERTY|#WITH_TIMELINE
  
  Structure DemoApplication_t Extends Application::Application_t
    *explorer.ExplorerUI::ExplorerUI_t
    *property.PropertyUI::PropertyUI_t
    *timeline.TimelineUI::TimelineUI_t
    *viewport.ViewportUI::ViewportUI_t
    *view.View::View_t
    *layer.LayerDefault::LayerDefault_t
  EndStructure
  
  Declare New (name.s, width.i=1200, height.i=800, options=#WITH_ALL)
  Declare Draw(*Me.DemoApplication_t)
  Declare GetView(*Me.DemoApplication_t)
  
EndDeclareModule

Module DemoApplication
  UseModule OpenGL
  UseModule OpenGLExt
  Procedure New(name.s, width=1200, height=800, options=#WITH_ALL)

    Globals::Init()
    Time::Init()
    Log::Init()
    FTGL::Init()
    Commands::Init()
    UIColor::Init()
    CompilerIf #USE_ALEMBIC
      Alembic::Init()
    CompilerEndIf
   
    Protected *Me.DemoApplication_t = AllocateStructure(DemoApplication_t)
    *Me\name = name

    *Me\window = Window::New(name,0,0,width,height,#PB_Window_SystemMenu|#PB_Window_SizeGadget)

    *Me\width = WindowWidth(*Me\window\ID,#PB_Window_InnerCoordinate)
    *Me\height = WindowHeight(*Me\window\ID,#PB_Window_InnerCoordinate)
  
    *Me\idle = #True
    
    *Me\scene = Scene::New()
    *Me\camera = Camera::New("Camera",Camera::#Camera_Perspective)
    *Me\handle = Handle::New()
    *Me\handle\camera = *Me\camera
;     *Me\select = LayerSelection::New(width, height, *Me\context, *Me\camera)
;     Handle::Setup(*Me\handle, *Me\context)
    
    Define.View::View_t *view, *top, *middle, *bottom, *left, *right
    
    *view = *Me\window\main
    If options & #WITH_MENU
      View::Split(*view,#PB_Splitter_FirstFixed,25)
      *top = *view\left
      *view = *view\right
      Protected *menu.MenuUI::MenuUI_t = MenuUI::New(*top,"Menu")
    EndIf
    If options & #WITH_TIMELINE
      View::Split(*view,#PB_Splitter_SecondMinimumSize|#PB_Splitter_SecondFixed,60)
      *bottom = *view\right
      *view = *view\left
      Protected *timeline.TimelineUI::TimelineUI_t = TimelineUI::New(*bottom,"Timeline")
    EndIf
    
    If options & #WITH_EXPLORER
      View::Split(*view,#PB_Splitter_Vertical,20)
      *left = *view\left
      *view = *view\right
      *Me\explorer = ExplorerUI::New(*left,"Explorer")
    EndIf
    
     If options & #WITH_PROPERTY
      View::Split(*view,#PB_Splitter_Vertical,75)
      *right = *view\right
      *view = *view\left
      *Me\property = PropertyUI::New(*right,"Property",#Null)
    EndIf
    
    *Me\viewport= ViewportUI::New(*view,"Viewport", *Me\camera, *Me\handle)
    *Me\layer = LayerDefault::New(*Me\viewport\sizX, *Me\viewport\sizY, *Me\viewport\context, *Me\camera)
    GLContext::AddFramebuffer(*Me\viewport\context, *Me\layer\framebuffer)

    ViewportUI::OnEvent(*Me\viewport,#PB_Event_SizeWindow)
    
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Draw(*Me.DemoApplication_t)
    GLContext::SetContext(*Me\viewport\context)
    Scene::Update(*Me\scene)
    LayerDefault::Draw(*Me\layer, *Me\scene, *Me\viewport\context)
    
    ViewportUI::Blit(*Me\viewport, *Me\layer\framebuffer)

    FTGL::BeginDraw(*Me\viewport\context\writer)
    FTGL::SetColor(*Me\viewport\context\writer, 1,1,1,1)
  
    Define ss.f = 0.85/width
    Define ratio.f = width / height
    FTGL::Draw(*Me\viewport\context\writer,"Demo : "+*Me\name,-0.9,0.9,ss,ss*ratio)
    FTGL::EndDraw(*Me\viewport\context\writer)
    
    GLContext::FlipBuffer(*Me\viewport\context)
  EndProcedure
  
  Procedure GetView(*Me.DemoApplication_t)
    ProcedureReturn   *Me\view
  EndProcedure

EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 41
; FirstLine = 21
; Folding = --
; EnableXP
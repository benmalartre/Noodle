XIncludeFile "../ui/UI.pbi"

;============================================================
; View Module Declaration
;============================================================
DeclareModule View
    #VIEW_BORDER_SENSIBILITY = 4
    #VIEW_SPLITTER_DROP = 7
    
  Enumeration
    #VIEW_NONE
    #VIEW_TOP
    #VIEW_BOTTOM
    #VIEW_LEFT
    #VIEW_RIGHT
    #VIEW_OTHER
  EndEnumeration
 
  Structure View_t Extends Control::Control_t
    *window                         ; window
    *content.UI::UI_t               ; view content
    *right.View_t
    *left.View_t
    
    lorr.b                          ; left or right view
    id.i                            ; unique ID
    axis.b                          ; splitter axis
    perc.i                          ; splitter percentage
    
    fixed.b                         ; is view resizable
    fixed_size.i                    ; static size  (for fixed view)
    fixed_side.i                    ; which side is fixed
   
    lastx.i
    lasty.i
    offsetx.i
    offsety.i
    zoom.i
    
    splitter.i                    ; canvas splitter ID(if not leaf)

    leaf.b
    active.b
    dirty.b                         ; view need a refresh
    down.b
    
    lsplitter.i
    rsplitter.i
    tsplitter.i
    bsplitter.i    
  EndStructure
  
  Declare New(x.i,y.i,width.i,height.i,*top,axis.b=#False,name.s="View",lorr.b=#True,scroll.b=#True)
  Declare Delete(*view.View_t)
  Declare Draw(*view.View_t)
;   Declare DrawDebug(*view.View_t)
  Declare.b MouseInside(*view,x.i,y.i)
  Declare TouchBorder(*view,x.i,y.i,w.i)
  Declare TouchBorderEvent(*view)
  Declare ClearBorderEvent(*view)
  Declare GetActive(*view,x.i,y.i)
  Declare Split(*view,options.i=0,perc.i=50)
  Declare Resize(*view,x.i,y.i,width.i,height.i)
  Declare OnEvent(*view,event.i)
  Declare InitSplitter(*view.View_t)
  Declare EventSplitter(*view.View_t,border.i)
  Declare SetContent(*view.View_t,*content.UI::UI_t)
  Declare GetWindowID(*view)
  
  ; ============================================================================
  ;  VTABLE ( Object + Control + ControlButton )
  ; ============================================================================
  DataSection
    ViewVT:
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

;============================================================
; Window Module Declaration
;============================================================
DeclareModule Window

  Enumeration
    #SHORTCUT_UNDO
    #SHORTCUT_REDO
  EndEnumeration
  
  Structure Window_t Extends Object::Object_t
    name.s
    *main.View::View_t
    *active.View::View_t
    Map *uis.UI::UI_t()
    imageID.i
    lastx.i
    lasty.i
    ID.i
    down.b
  
  EndStructure
  
  Interface IWindow
    Delete()
    OnEvent()
  EndInterface
  
  Global *MAIN_WINDOW.Window_t
  Global NewMap *ALL_WINDOWS.Window_t()
  
  Declare New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget, parentID.i=0)
  Declare Delete(*Me.Window_t)
  Declare OnEvent(*Me.Window_t,event.i)
  Declare DrawPickImage(*Me.Window_t)
  Declare Draw(*Me.Window_t)
  Declare Pick(*Me.Window_t, mx.i, my.i)
  Declare TearOff(*Me.Window_t, x.i, y.i, width.i, height.i)
  DataSection 
    WindowVT: 
    Data.i @Delete()
    Data.i @OnEvent()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 122
; FirstLine = 79
; Folding = -
; EnableXP
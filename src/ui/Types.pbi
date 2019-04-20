
XIncludeFile "../objects/Scene.pbi"
XIncludeFile "../core/commands.pbi"
XIncludeFile "../ui/View.pbi"
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
 
  Structure View_t
    *window                         ; window
    *content.UI::UI_t               ; view content
    *right.View_t
    *left.View_t
    *parent.View_t
    
    name.s                          ; view name
    lorr.b                          ; left or right view
    
    x.i                             ; view position X
    y.i                             ; view position Y
    width.i                         ; view actual width
    height.i                        ; view actual height
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
    type.i
    
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
EndDeclareModule

;============================================================
; Window Module Declaration
;============================================================
DeclareModule Window

  Enumeration
    #SHORTCUT_UNDO
    #SHORTCUT_REDO
  EndEnumeration
  
    
  Structure Window_t
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
  
  Global *MAIN_WINDOW.Window_t
  
  Declare New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget, parentID.i=0)
  Declare Delete(*Me.Window_t)
  Declare OnEvent(*Me.Window_t,event.i)
  Declare DrawPickImage(*Me.Window_t)
  Declare Draw(*Me.Window_t)
  Declare Pick(*Me.Window_t, mx.i, my.i)
  Declare TearOff(*Me.Window_t, x.i, y.i, width.i, height.i)

EndDeclareModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 117
; FirstLine = 55
; Folding = -
; EnableXP
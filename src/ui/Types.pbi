﻿XIncludeFile "../core/Control.pbi"

; ==============================================================================
;  UI Module Declaration
; ==============================================================================
DeclareModule UI
  Enumeration
    #UI_DUMMY
    #UI_GRAPH
    #UI_3D
    #UI_SHADER
    #UI_COLOR
    #UI_LOG
    #UI_TIMELINE
    #UI_ANIMATION_EDITOR
  EndEnumeration
  
  Structure UI_t Extends Control::Control_t
    lastX.i
    lastY.i
    offsetX.i
    offsetY.i
    
    dirty.b
    down.b
    zoom.f
    
    imageID.i
    iSizX.i
    iSizY.i
    
    scrollable.b
    scrolling.b
    scrollX.i
    scrollY.i
    scrollMaxX.i
    scrollMaxY.i
    scrollLastX.i
    scrollLastY.i
    last_x.i
    last_y.i
    *view
  EndStructure
  
  Interface IUI Extends Control::IControl
  EndInterface
  
  Declare.s GetName(*Me.UI_t)
  Declare GetScrollArea(*Me.UI_t)
  Declare Scroll(*Me.UI_t,mode.b =#False)
  Declare GetView(*Me.UI_t)
  Declare GetWindow(*Me.UI_t)
  
EndDeclareModule

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
    
    drag.b                          ; drag splitter
    lorr.b                          ; left or right view
    axis.b                          ; splitter axis
    perc.i                          ; splitter percentage
    border.i                        ; splitter border
    
    fixed.b                         ; is view resizable
    fixed_size.i                    ; static size  (for fixed view)
    fixed_side.i                    ; which side is fixed
   
    lastx.i
    lasty.i
    offsetx.i
    offsety.i
    zoom.i
    
    splitter.i                      ; canvas splitter ID(if not leaf)

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
  Declare.b PointInside(*view,x.i,y.i)
  Declare TouchBorder(*view,x.i,y.i,w.i)
  Declare TouchBorderEvent(*view)
  Declare GetActive(*view,x.i,y.i)
  Declare Split(*view,options.i=0,perc.i=50)
  Declare Resize(*view,x.i,y.i,width.i,height.i)
  Declare OnEvent(*view,event.i)
  Declare InitSplitter(*view.View_t)
  Declare DragSplitter(*Me.View_t)
  Declare EventSplitter(*view.View_t,border.i)
  Declare SetContent(*view.View_t,*content.UI::UI_t)
  Declare GetWindowID(*view)

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
    *menu.UI::UI_t
    *main.View::View_t
    *active.View::View_t
    Map *uis.UI::UI_t()
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
  Global NewList *ALL_WINDOWS.Window_t()
  
  Declare GetWindowById(id.i)
  
  Declare New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget, parentID.i=0)
  Declare Delete(*Me.Window_t)
  Declare OnEvent(*Me.Window_t,event.i)
  Declare Pick(*Me.Window_t, mx.i, my.i)
  Declare TearOff(*Me.Window_t, x.i, y.i, width.i, height.i)
  Declare AddMenuItem(*Me.Window_t, name.s, event.i=-1)
  Declare AddSubMenuItem(*Me.Window_t, *menuItem, name.s, event.i=-1)
  DataSection 
    WindowVT: 
    Data.i @Delete()
    Data.i @OnEvent()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 82
; FirstLine = 60
; Folding = -
; EnableXP
XIncludeFile "UI.pbi"
XIncludeFile "../objects/Scene.pbi"
XIncludeFile "../core/commands.pbi"

;============================================================
; View Module Declaration
;============================================================
DeclareModule View
  Enumeration
    #VIEW_NONE
    #VIEW_TOP
    #VIEW_BOTTOM
    #VIEW_LEFT
    #VIEW_RIGHT
    #VIEW_OTHER
  EndEnumeration

  Structure View_t
    *manager                        ; view manager
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
    
    splitterID.i                    ; canvas splitter ID(if not leaf)

    parentID.i                      ; parent window ID
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
  
EndDeclareModule

;============================================================
; ViewManager Module Declaration
;============================================================
DeclareModule ViewManager
  #VIEW_BORDER_SENSIBILITY = 4
  #VIEW_SPLITTER_DROP = 7
  
  Enumeration
    #SHORTCUT_UNDO
    #SHORTCUT_REDO
  EndEnumeration
  
    
  Structure ViewManager_t
    name.s
    *main.View::View_t
    *active.View::View_t
    Map *uis.UI::UI_t()
    imageID.i
    lastx.i
    lasty.i
    window.i
  
  EndStructure
  
  Global *view_manager.ViewManager_t
  
  Declare New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  Declare Delete(*Me.ViewManager_t)
  Declare OnEvent(*Me.ViewManager_t,event.i)
  Declare DrawPickImage(*Me.ViewManager_t)
  Declare Draw(*Me.ViewManager_t)
  Declare Pick(*Me.ViewManager_t, mx.i, my.i)
;   Declare UpdateMap(*Me.ViewManager_t)
EndDeclareModule


;============================================================
; View module Implementation
;============================================================
Module View
  ;----------------------------------------------------------
  ; Constructor
  ;----------------------------------------------------------
  Procedure New(x.i,y.i,width.i,height.i,*top.View_t,axis.b = #False,name.s="View",lorr.b=#True,scroll.b=#True)
    Protected *view.View_t = AllocateMemory(SizeOf(View_t))
    *view\x = x
    *view\y = y
    *view\width = width
    *view\height = height
  
    *view\right = #Null
    *view\left = #Null
    *view\leaf = #True
    *view\active = #False
    *view\dirty = #True
    *view\name = name
    *view\lorr = lorr
    *view\content = #Null
    
    *view\axis = axis
    *view\type = 0
    
    ;increment view id counter
    view_id_counter + 1
    *view\id = view_id_counter
    
    If *top = #Null
      *view\manager = #Null
      *view\parent = #Null
    Else
      *view\parent = *top
      *view\manager = *top\manager
    EndIf
   
    ProcedureReturn *view
  EndProcedure
  
  ;----------------------------------------------------------
  ; Delete View
  ;----------------------------------------------------------
  Procedure Delete(*view.View_t)
    
    FreeMemory(*view)
    
  EndProcedure
  

  
  ;----------------------------------------------------------
  ; Resize
  ;----------------------------------------------------------
  Procedure Resize(*view.View_t,x.i,y.i,width.i,height.i)
    Protected *Me.ViewManager::ViewManager_t = *view\manager
    
    *view\x = x
    *view\y = y
    *view\width = width
    *view\height = height
    Protected mx,my

    If *view\leaf

      Protected *ui.UI::UI_t = *view\content
      Protected ui.UI::IUI = *ui
      If *ui
        ResizeGadget(*ui\container,x,y,width,height)  
        ui\Event(#PB_Event_SizeWindow)
      EndIf
     
    Else
      Protected hs = ViewManager::#VIEW_BORDER_SENSIBILITY/2
      If *view\fixed
        If *view\axis
          If *view\fixed_side = #PB_Splitter_FirstFixed
            ResizeGadget(*view\splitterID,*view\x+ *view\fixed_size,*view\y,2*hs,*view\height)
            Resize(*view\left,*view\x,*view\y,*view\fixed_size-hs,*view\height)
            Resize(*view\right,*view\x+*view\fixed_size+hs,*view\y,*view\width-*view\fixed_size-hs,*view\height)
          Else
            ResizeGadget(*view\splitterID,*view\x+*view\width - *view\fixed_size,*view\y,2*hs,*view\height)
            Resize(*view\left,*view\x,*view\y,*view\width-*view\fixed_size-hs,*view\height)
            Resize(*view\right,*view\x+*view\width-*view\fixed_size+hs,*view\y,*view\fixed_size-hs,*view\height)
          EndIf
          
        Else
          If *view\fixed_side = #PB_Splitter_FirstFixed
            ResizeGadget(*view\splitterID,*view\x,*view\y + *view\fixed_size-hs,*view\width,2*hs)
            Resize(*view\left,*view\x,*view\y,*view\width,*view\fixed_size-hs)
            Resize(*view\right,*view\x,*view\y+*view\fixed_size+hs,*view\width,*view\height-*view\fixed_size-hs)
          Else
            ResizeGadget(*view\splitterID,*view\x,*view\y + *view\height-*view\fixed_size-hs,*view\width,2*hs)
            Resize(*view\left,*view\x,*view\y,*view\width,*view\height - *view\fixed_size-hs)
            Resize(*view\right,*view\x,*view\y+*view\height -*view\fixed_size+hs,*view\width,*view\fixed_size-hs)
          EndIf
          
        EndIf
      Else
        If *view\axis
          ResizeGadget(*view\splitterID,*view\x+*view\width* *view\perc/100-hs,*view\y,2*hs,*view\height)
          Resize(*view\left,*view\x,*view\y,*view\width* *view\perc/100-hs,*view\height)
          Resize(*view\right,*view\x+*view\width* *view\perc/100+hs,*view\y,*view\width-*view\width* *view\perc/100-hs,*view\height)
        Else
          ResizeGadget(*view\splitterID,*view\x,*view\y + *view\height * *view\perc/100-hs,*view\width,2*hs)
          Resize(*view\left,*view\x,*view\y,*view\width,*view\height* *view\perc/100-hs)
          Resize(*view\right,*view\x,*view\y+*view\height* *view\perc/100+hs,*view\width,*view\height-*view\height* *view\perc/100-hs)
        EndIf
      EndIf
    EndIf
    InitSplitter(*view)
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Get Percentage
  ;----------------------------------------------------------------------------------
  Procedure GetPercentage(*view.View_t,mx.i,my.i)
    ;If Not *view\fixed
      If Not *view\axis
        If my<*view\y Or my>*view\y+*view\height 
          ProcedureReturn
        EndIf
        *view\perc = (my-*view\y) * 100 /*view\height
      Else
        If mx<*view\x Or mx>*view\x+*view\width 
          ProcedureReturn
        EndIf
        *view\perc = (mx-*view\x) * 100 /*view\width
        
      EndIf
     
  ;   Else
  ;     ; when a view is fixed , it's size is in pixels...
  ;     If *view\axis
  ;       Debug "View ----------------------------------> Vertical"
  ;       Protected h = *view\fixed_size
  ;       Protected nh.f = *view\height/h*100
  ;       *view\perc = nh;
  ;     Else
  ;       Debug "View ----------------------------------> Horizontal"
  ;       Protected w = *view\fixed_size
  ;       Protected nw.f = *view\width/w*100
  ;       *view\perc = nw;
  ;     EndIf
  ;     
  ;   EndIf
      
      
    EndProcedure
    
  ;----------------------------------------------------------------------------------
  ; Split
  ;----------------------------------------------------------------------------------
  Procedure SetSplitter(*view.View_t,l,r,t,b)
    *view\lsplitter = l
    *view\rsplitter = r
    *view\tsplitter = t
    *view\bsplitter = b
  EndProcedure
  
  Procedure Split(*view.View_t,options.i=0,perc.i=50)
    If *view\leaf
      
;       If *view\gadgetID : FreeGadget(*view\gadgetID):EndIf
      Protected hs = ViewManager::#VIEW_BORDER_SENSIBILITY/2
      Protected *content = *view\content
      Protected *Me.ViewManager::ViewManager_t = *view\manager
      UseGadgetList(WindowID(*view\parentID))
      
      *view\fixed = Bool(options & #PB_Splitter_FirstFixed Or options & #PB_Splitter_SecondFixed)
      If *view\fixed
        If options & #PB_Splitter_FirstFixed
          *view\fixed_size = perc
          *view\fixed_side = #PB_Splitter_FirstFixed
        ElseIf options & #PB_Splitter_SecondFixed
           *view\fixed_size = perc
           *view\fixed_side = #PB_Splitter_SecondFixed
        EndIf
      EndIf
         
         
;       OpenGadgetList(*view\gadgetID)
      If options & #PB_Splitter_Vertical
        Protected mx
        If *view\fixed
          
          If *view\fixed_side = #PB_Splitter_FirstFixed
            mx = *view\fixed_size
          Else
            mx = *view\width-*view\fixed_size
          EndIf
        Else
          mx = *view\width*perc/100
        EndIf
        
        *view\left = New(*view\x,*view\y,mx-hs,*view\height,*view,#True,*view\name+"_L",#True)
        SetSplitter(*view\left,*view\lsplitter,*view,*view\tsplitter,*view\bsplitter)
        *view\left\content = *content
        *view\left\parentID = *view\parentID
        *view\right = New(*view\x+ mx+hs,*view\y,*view\width-mx-hs,*view\height,*view,#True,*view\name+"_R",#False)
        SetSplitter(*view\right,*view,*view\rsplitter,*view\tsplitter,*view\bsplitter)
        *view\right\parentID = *view\parentID
        
        
        *view\splitterID = CanvasGadget(#PB_Any,*view\x+mx-hs,*view\y,2*hs,*view\height)
        StartDrawing(CanvasOutput(*view\splitterID))
        Box(0,0,GadgetWidth(*view\splitterID), GadgetHeight(*view\splitterID), UIColor::COLOR_SPLITTER)
        StopDrawing()

      If Not *view\fixed : SetGadgetAttribute(*view\splitterID,#PB_Canvas_Cursor,#PB_Cursor_LeftRight) : EndIf
      
    Else
        Protected my
        If *view\fixed
          
          If *view\fixed_side = #PB_Splitter_FirstFixed
            my = *view\fixed_size
          Else
            my = *view\height-*view\fixed_size
          EndIf
        Else
          my = *view\height*perc/100
        EndIf

        *view\left = New(*view\x,*view\y,*view\width,my-hs,*view,#False,*view\name+"_L",#True)
        SetSplitter(*view\left,*view\lsplitter,*view\rsplitter,*view\tsplitter,*view)
        *view\left\content = *content
        *view\left\parentID = *view\parentID
        *view\right = New(*view\x,*view\y+ my+hs,*view\width,*view\height-my-hs,*view,#False,*view\name+"_R",#False)
        SetSplitter(*view\right,*view\lsplitter,*view\rsplitter,*view,*view\bsplitter)
        *view\right\parentID = *view\parentID

        *view\splitterID = CanvasGadget(#PB_Any,*view\x,*view\y+my-hs,*view \width,2*hs)
        StartDrawing(CanvasOutput(*view\splitterID))
        Box(0,0,GadgetWidth(*view\splitterID), GadgetHeight(*view\splitterID), UIColor::COLOR_SPLITTER)
        StopDrawing()
        If Not *view\fixed : SetGadgetAttribute(*view\splitterID,#PB_Canvas_Cursor,#PB_Cursor_UpDown):EndIf
      EndIf

      *view\axis = Bool(options & #PB_Splitter_Vertical)
      *view\leaf = #False
      *view\perc = perc
       
      ProcedureReturn *view
    Else
      ProcedureReturn #Null
    EndIf
    
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Touch Border Event
  ;----------------------------------------------------------------------------------
  Procedure.i TouchBorderEvent(*view.View_t)
    If Not *view : ProcedureReturn : EndIf
    Protected *Me.ViewManager::ViewManager_t = *view\manager
    Protected btn.i
    If *view\fixed : ProcedureReturn : EndIf
    If EventType() = #PB_EventType_LeftButtonDown
      Protected drag.b = #True
      
      Protected sx,sy,sw, sh
      Protected mx = WindowMouseX(*Me\window)
      Protected my = WindowMouseY(*Me\window)
       

      Define e
      Repeat 
        e = WaitWindowEvent()
        ; Get Mouse Position
        mx = WindowMouseX(*Me\window)
        my = WindowMouseY(*Me\window)
        ; Resize Window Event
        ;If EventType() = #PB_EventType_LeftButtonUp
        
        ;If e = #PB_Event_WindowDrop Or e = #PB_Event_GadgetDrop
        If e = #PB_Event_Gadget And EventType() = #PB_EventType_LeftButtonUp
          GetPercentage(*view,mx,my)
          drag = #False
        EndIf
  
      Until drag = #False
      ViewManager::OnEvent(*Me,#PB_Event_SizeWindow)
    EndIf
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Touch Border Event
  ;----------------------------------------------------------------------------------
  Procedure ClearBorderEvent(*view.View_t)
    
  EndProcedure

  
  ;----------------------------------------------------------------------------------
  ; Touch Border
  ;----------------------------------------------------------------------------------
  Procedure.i TouchBorder(*view.View_t,x.i,y.i,w.i)
    If Not  *view : ProcedureReturn : EndIf

    ;Left border
    If Abs(x - *view\x)<w                     : ProcedureReturn #VIEW_LEFT : EndIf
    ;Right border
    If Abs((*view\x+*view\width) - x)<w       : ProcedureReturn #VIEW_RIGHT : EndIf
    ;Top border
    If Abs(y - *view\y)<w                     : ProcedureReturn #VIEW_TOP : EndIf
    ;Bottom border
     If Abs((*view\y+*view\height) - y)<w     : ProcedureReturn #VIEW_BOTTOM : EndIf
    ProcedureReturn #VIEW_NONE
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Init Splitter
  ;------------------------------------------------------------------
  Procedure InitSplitter(*view.View_t)
    If *view And Not *view\fixed
      Protected *affected.View_t
      *affected = *view\tsplitter 
      If *affected And *affected\splitterID
        StartDrawing(CanvasOutput(*affected\splitterID  ))
        Box(0,0,GadgetWidth(*affected\splitterID),GadgetHeight(*affected\splitterID),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *view\lsplitter 
      If *affected And *affected\splitterID
        StartDrawing(CanvasOutput(*affected\splitterID  ))
        Box(0,0,GadgetWidth(*affected\splitterID),GadgetHeight(*affected\splitterID),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *view\rsplitter 
      If *affected And *affected\splitterID
        StartDrawing(CanvasOutput(*affected\splitterID  ))
        Box(0,0,GadgetWidth(*affected\splitterID),GadgetHeight(*affected\splitterID),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *view\bsplitter 
      If *affected And *affected\splitterID
        StartDrawing(CanvasOutput(*affected\splitterID  ))
        Box(0,0,GadgetWidth(*affected\splitterID),GadgetHeight(*affected\splitterID),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
    EndIf
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Splitter Event
  ;------------------------------------------------------------------
  Procedure EventSplitter(*view.View_t,border.i)
    If *view And Not *view\fixed
      ; Get Affected View
      Protected *affected.View_t
      Select border
        Case #VIEW_TOP
          *affected = *view\tsplitter
        Case #VIEW_LEFT
          *affected = *view\lsplitter
        Case #VIEW_RIGHT
          *affected = *view\rsplitter
        Case #VIEW_BOTTOM
          *affected = *view\bsplitter
      EndSelect
      
      If *affected And *affected\splitterID
        StartDrawing(CanvasOutput(*affected\splitterID  ))
        ;         Box(0,0,GadgetWidth(*view\top\splitterID),GadgetHeight(*view\top\splitterID),RGB(Random(100)*0.01,Random(100)*0.01,Random(100)*0.01))
        Box(0,0,GadgetWidth(*affected\splitterID),GadgetHeight(*affected\splitterID),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
        ProcedureReturn *affected
      EndIf
    EndIf
    
  EndProcedure
  
  
  ;----------------------------------------------------------------------------------
  ; Mouse Inside
  ;----------------------------------------------------------------------------------
  Procedure.b MouseInside(*view.View_t, x.i,y.i)
  
    If x>*view\x And x<*view\x+*view\width And y>*view\y And y<*view\y+*view\height
      ProcedureReturn #True
    EndIf
     
    ProcedureReturn #False
      
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Draw
  ;----------------------------------------------------------------------------------
  Procedure Draw(*view.View_t)

    
    If *view\leaf And *view\dirty
      ;OViewControl_OnEvent(*view\control,#PB_Event_Repaint,#Null)
  ;     StartDrawing(CanvasOutput(*view\canvasID))
  ;     Box(0,0,*view\width,*view\height,RGB(100,100,100))
  ;     DrawImage(ImageID(*view\imageID),*view\offsetx,*view\offsety) 
  ;     *view\dirty = #False
  ;     DrawingModeDrawPick
  ;     RoundBox(0,0,*view\width,*view\height,2,2,RGB(120,120,120))
  ;     StopDrawing()
    Else
      If *view\left : Draw(*view\left) : EndIf
      If *view\right : Draw(*view\right) : EndIf
    EndIf
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Get Active View
  ;----------------------------------------------------------------------------------
  Procedure GetActive(*view.View_t,x.i,y.i)
    Protected *Me.ViewManager::ViewManager_t = *view\manager
    Protected active.b = *view\active 
    If *view\leaf
      If MouseInside(*view,x,y) = #True
        *view\active = #True
        If active <>#True : *view\dirty  = #True : EndIf
      Else
        *view\active = #False
        If active = #True : *view\dirty = #True : EndIf
      EndIf
    Else
      If *view\left : GetActive(*view\left,x,y) : EndIf
      If *view\right : GetActive(*view\right,x,y) : EndIf
    EndIf

  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Drag View (if image > canvas)
  ;-----------------------------------------------------------------------------------
  Procedure Drag(*view.View_t)
  ;   Protected limit_x = GadgetWidth(*view\canvasID)-ImageWidth(*view\imageID)
  ;   Protected limit_y = GadgetHeight(*view\canvasID)-ImageHeight(*view\imageID)
  ;   
  ;   Protected mx = GetGadgetAttribute(*view\canvasID,#PB_Canvas_MouseX)
  ;   Protected my = GetGadgetAttribute(*view\canvasID,#PB_Canvas_MouseY)
  ;   
  ;   *view\offsetx + mx-*view\lastx
  ;   *view\offsety + my-*view\lasty
  ;   
  ; ;   Debug "Offset X : "+Str(*view\offsetx)
  ; ;   Debug "Offset Y : "+Str(*view\offsety)
  ;   
  ;   *view\lastx = mx
  ;   *view\lasty = my
  ;   
  ;   Clamp(*view\offsetx,limit_x,0)
  ;   Clamp(*view\offsety,limit_y,0)
  ;   OView_Draw(*view)
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; View Event
  ;-----------------------------------------------------------------------------------
  Procedure OnEvent(*Me.View_t,event.i)
    If Not event : ProcedureReturn : EndIf
    Protected *manager.ViewManager::ViewManager_t = *Me\manager
    
    If *Me\leaf
      If *Me\content <> #Null
        Protected *content.UI::IUI = *Me\content
        *content\Event(event)
      EndIf
      
    Else
      If event = #PB_Event_SizeWindow
        Resize(*Me,0,0,WindowWidth(*Me\parentID),WindowHeight(*Me\parentID))  
      ElseIf event = #PB_Event_Timer
        OnEvent(*Me\left,#PB_Event_Timer)
        OnEvent(*Me\right,#PB_Event_Timer)
      ElseIf event = #PB_Event_Repaint
        OnEvent(*Me\left,#PB_Event_Repaint)
        OnEvent(*Me\right,#PB_Event_Repaint)
      Else
        OnEvent(*Me\left,#PB_Event_Repaint)
        OnEvent(*Me\right,event)
        OnEvent(*Me\left,event)
      EndIf
      
    EndIf
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Set Content
  ;-----------------------------------------------------------------------------------
  Procedure SetContent(*Me.View_t,*content.UI::UI_t)
    If *Me\content
      Debug "Delete OLD content!!!"
    EndIf
   
    *Me\content = *content
    *content\parent = *Me
    
    Protected *manager.ViewManager::ViewManager_t = *Me\manager
    *manager\uis(*content\name) = *content
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Get Window
  ;-----------------------------------------------------------------------------------
  Procedure GetWindow(*Me.View_t)
    Protected *manager.ViewManager::ViewManager_t = *Me\manager
    ProcedureReturn *manager\window
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Get Scroll Area
  ;-----------------------------------------------------------------------------------
  Procedure GetScrollArea(*Me.View_t)
;     If *Me\scrollable
;       *Me\scrolling = #False
;       If *Me\width>*Me\iwidth : *Me\scrollmaxx = 0 : Else : *Me\scrollmaxx = *Me\iwidth-*Me\width : EndIf
;       If *Me\height>*Me\iheight : *Me\scrollmaxy = 0 : Else : *Me\scrollmaxy = *Me\iheight-*Me\height : EndIf
;     EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Scroll
  ;-----------------------------------------------------------------------------------
  Procedure Scroll(*Me.View_t,mode.b =#False)
;     If *Me\scrollable And (*Me\scrolling Or mode = #True)
;       If mode = #True
;         Protected d = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_WheelDelta)
;         *Me\scrolly + d*22
;       Else
;         
;         Protected x = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
;         Protected y = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
;         *Me\scrollx + (x-*Me\scrolllastx)
;         *Me\scrolly + (y-*Me\scrolllasty)
;         *Me\scrolllastx = x
;         *Me\scrolllasty = y
;       EndIf
;       
;       If *Me\scrollx>0 : *Me\scrollx = 0 : EndIf
;       If *Me\scrolly>0 : *Me\scrolly = 0 : EndIf
;       If *Me\scrollx<-*Me\scrollmaxx : *Me\scrollx = -*Me\scrollmaxx : EndIf
;       If *Me\scrolly<-*Me\scrollmaxy : *Me\scrolly = -*Me\scrollmaxy : EndIf
;       
;     EndIf
  EndProcedure
  
EndModule

;==========================================================================
; ViewManager module Implementation
;==========================================================================
Module ViewManager
  
  Procedure Resize(*Me.ViewManager_t)    
    If Not *Me : ProcedureReturn : EndIf
    Protected w = WindowWidth(*Me\window,#PB_Window_InnerCoordinate)
    Protected h = WindowHeight(*Me\window,#PB_Window_InnerCoordinate)

    View::Resize(*Me\main,0,0,w,h)
    DrawPickImage(*Me)
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Recurse View
  ;----------------------------------------------------------------------------------
  Procedure RecurseView(*Me.ViewManager_t,*view.View::View_t)
    If *view\leaf
      If *view\active
        *Me\active = *view
      EndIf
    Else
      If *view\left : RecurseView(*Me,*view\left) : EndIf
      If *view\right : RecurseView(*Me,*view\right) : EndIf
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Get Active View
  ;----------------------------------------------------------------------------------
  Procedure.i GetActiveView(*Me.ViewManager_t,x.i,y.i)
    Protected *view.View::View_t = *Me\main
    View::GetActive(*view,x,y)

    ProcedureReturn RecurseView(*Me, *Me\main)
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Drag
  ;----------------------------------------------------------------------------------
  Procedure Drag(*Me.ViewManager_t)
    ;Debug "View Manager Drag View Top ID: "+Str(*Me\active\top\id)  
  EndProcedure
  
;   ;----------------------------------------------------------------------------------
;   ; Set Map Element
;   ;----------------------------------------------------------------------------------
;   Procedure SetMapElement(*Me.ViewManager_t,*view.View::View_t)
;     If *view\leaf And *view\content
;       Protected name.s = *view\content\name
;       ; Check if already in map
;       AddMapElement(*Me\views(),name)
;       *Me\views() = *view\content
;       Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ADD VIEW MAP ELEMENT : "+name
;     Else
;       SetMapElement(*Me,*view\left)
;       SetMapElement(*Me,*view\right)
;     EndIf
;     
;   EndProcedure
;   
;   ;----------------------------------------------------------------------------------
;   ; Update Map
;   ;----------------------------------------------------------------------------------
;   Procedure UpdateMap(*Me.ViewManager_t)
;     ClearMap(*Me\views())
;     SetMapElement(*Me,*Me\main)
;   EndProcedure

  
  ;----------------------------------------------------------------------------------
  ; Event
  ;----------------------------------------------------------------------------------
  Procedure OnEvent(*Me.ViewManager_t,event.i)
    
    Protected x,y,w,h,i,gadgetID,state
    Protected dirty.b = #False
    Protected *view.View::View_t = #Null
    If *Me = #Null Or event = -1: ProcedureReturn: EndIf
    
    Protected mx = WindowMouseX(*Me\window)
    Protected my = WindowMouseY(*Me\window)
    
    Protected *old.View::View_t = *Me\active
    Protected *over.View::View_t = Pick(*Me, mx, my)
    If *old And *old <> *over
      If *old\content And IsGadget(*old\content\gadgetID)
        PostEvent(#PB_Event_Gadget, *Me\window, *old\content\gadgetID, #PB_EventType_LostFocus)
      EndIf
      ;View::OnEvent(*old, #PB_EventType_LostFocus)
    EndIf
    
    Select event
      Case #PB_Event_Gadget
        If *over
          Protected touch = View::TouchBorder(*over,mx,my,#VIEW_BORDER_SENSIBILITY)
          If EventType() = #PB_EventType_LostFocus
            gadgetID = EventGadget()
            If FindMapElement(*Me\uis(), Str(gadgetID))
              View::OnEvent(*Me\uis()\parent, event)
            EndIf
          Else
            If touch
              View::EventSplitter(*over,touch)
              Protected *affected.View::View_t = View::EventSplitter(*over,touch)
              If *affected
                View::TouchBorderEvent(*affected)
              EndIf
            Else
              View::ClearBorderEvent(*over)
            EndIf
            View::OnEvent(*over,event)
          EndIf
        EndIf
          
      Case #PB_Event_Timer
        Scene::Update(Scene::*current_scene)
        View::OnEvent(*Me\main,#PB_Event_Timer)
        
      Case Globals::#EVENT_NEW_SCENE
        View::OnEvent(*Me\main, Globals::#EVENT_NEW_SCENE)
        
      Case Globals::#EVENT_BUTTON_PRESSED
        
      Case Globals::#EVENT_COMMAND_CALLED
        View::OnEvent(*Me\main,Globals::#EVENT_COMMAND_CALLED)
      Case Globals::#EVENT_PARAMETER_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_PARAMETER_CHANGED)
        Scene::Update(Scene::*current_scene)
      Case Globals::#EVENT_SELECTION_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_SELECTION_CHANGED)
        
      Case Globals::#EVENT_HIERARCHY_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_SELECTION_CHANGED)
        
      Case Globals::#EVENT_GRAPH_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_GRAPH_CHANGED)
         Scene::Update(Scene::*current_scene)
      Case #PB_Event_Repaint
        View::OnEvent(*Me\main,#PB_Event_Repaint)
      Case #PB_Event_Timer
;         Select EventTimer()
;           Case #RAA_TIMELINE_TIMER
;             ; Get Timeline View
;             If FindMapElement(*Me\views(),"Timeline")
;               Protected *timeline.CView = *Me\views()
;               *timeline\Event(#PB_Event_Timer,#Null)
;             EndIf
;             
;         EndSelect
       
      Case #PB_Event_Menu
        Select EventMenu()
;           Case Globals::#SHORTCUT_COPY
;             Debug "View Manager : SHORTCUT COPY"
;             View::OnEvent(*Me\active,#PB_Event_Menu)
;           Case Globals::#SHORTCUT_CUT
;             Debug "View Manager : SHORTCUT CUT"
;             View::OnEvent(*Me\active,#PB_Event_Menu)
;           Case Globals::#SHORTCUT_PASTE
;             Debug "View Manager : SHORTCUT PASTE"
;             View::OnEvent(*Me\active,#PB_Event_Menu)
          Case Globals::#SHORTCUT_UNDO
            MessageRequester("View Manager","Undo Called")
            Commands::Undo(Commands::*manager)
          Case Globals::#SHORTCUT_REDO
            MessageRequester("View Manager","Redo Called")
            Commands::Redo(Commands::*manager)
          Default
            View::OnEvent(*over,#PB_Event_Menu)
            
        EndSelect
        
      Case #PB_Event_SizeWindow
        Resize(*Me)
      Case #PB_Event_MaximizeWindow
        Resize(*Me)
      Case #PB_Event_MoveWindow
        Resize(*Me)
      Case #PB_Event_Menu
        ProcedureReturn
      Case #PB_Event_CloseWindow
        ProcedureReturn 
    EndSelect
    
    *Me\active = *over
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Get Unique ID
  ;----------------------------------------------------------------------------------
  Procedure GetUniqueID(*Me.ViewManager_t, *view.View::View_t)
    Protected uuid.i = Random(65535)
    If FindMapElement(*Me\uis(), Str(uuid))
      GetUniqueID(*Me, *view)
    Else
      AddMapElement(*Me\uis(), Str(uuid))
      *Me\uis() = *view\content
      ProcedureReturn uuid
    EndIf  
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Recurse Draw View
  ;----------------------------------------------------------------------------------
  Procedure RecurseDrawPickImage(*Me.ViewManager_t,*view.View::View_t)
    If *view\leaf And *view\content
      Define uuid.i = GetUniqueID(*Me, *view)
      DrawingMode(#PB_2DDrawing_Default)
      Box(*view\x-#VIEW_BORDER_SENSIBILITY*0.5,
          *view\y-#VIEW_BORDER_SENSIBILITY*0.5,
          *view\width+#VIEW_BORDER_SENSIBILITY,
          *view\height+#VIEW_BORDER_SENSIBILITY, uuid)
    Else
      If *view\left : RecurseDrawPickImage(*Me,*view\left) : EndIf
      If *view\right : RecurseDrawPickImage(*Me,*view\right) : EndIf
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Draw Pick Image
  ; ----------------------------------------------------------------------------------
  Procedure DrawPickImage(*Me.ViewManager_t)
    ClearMap(*Me\uis())
    ResizeImage(*Me\imageID, *Me\main\width, *Me\main\height)
    StartDrawing(ImageOutput(*Me\imageID))
    RecurseDrawPickImage(*Me,*Me\main)
    StopDrawing()
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Draw Over Pick Image (DEV)
  ; ----------------------------------------------------------------------------------
  Procedure Draw(*Me.ViewManager_t)
    StartDrawing(WindowOutput(*Me\window))
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawImage(ImageID(*Me\imageID),0,0)
    If *Me\active
      DrawingMode(#PB_2DDrawing_Default)
      Box(*Me\active\x, *Me\active\y, *Me\active\width, *Me\active\height, RGBA(255,255,255,128))
    EndIf
    StopDrawing()
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Pick Active View
  ; ----------------------------------------------------------------------------------
  Procedure Pick(*Me.ViewManager_t, mx.i, my.i)
    Protected picked.i
    StartDrawing(ImageOutput(*Me\imageID))
    DrawingMode(#PB_2DDrawing_Default)
    If mx>=0 And mx<ImageWidth(*Me\imageID) And my>=0 And my<ImageHeight(*Me\imageID)
      picked = Point(mx, my)
      If FindMapElement(*Me\uis(), Str(picked))
        StopDrawing()
        ProcedureReturn *Me\uis()\parent
      EndIf
    EndIf
    StopDrawing()
    ProcedureReturn #Null
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Constructor
  ; ----------------------------------------------------------------------------------

  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*e.ViewManager_t)
    FreeMemory(*e)
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Constructor
  ; ----------------------------------------------------------------------------------
  Procedure New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    Protected *Me.ViewManager_t = AllocateMemory(SizeOf(ViewManager_t))
    
    InitializeStructure(*Me,ViewManager_t)
  
    *Me\name = name
    *Me\window = OpenWindow(#PB_Any, 0, 0, width, height, *Me\name, options)  
    EnableWindowDrop(*Me\window,#PB_Drop_Private,#PB_Drag_Move,#VIEW_SPLITTER_DROP)
    *Me\main = View::New(x.i,y.i,WindowWidth(*Me\window),WindowHeight(*Me\window),#Null,#False,name,#True)
    *Me\main\manager = *Me
    *Me\main\parentID = *Me\window
    *Me\active = *Me\main
    *Me\imageID = CreateImage(#PB_Any, width, height, 32)

    *view_manager = *Me
    
    ProcedureReturn *Me
    
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 2
; Folding = -------
; EnableXP
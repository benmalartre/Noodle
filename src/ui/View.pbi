XIncludeFile "UI.pbi"
XIncludeFile "../objects/Scene.pbi"

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
    
    *manager ;CViewManager(Not declared so commented)
    *content.UI::UI_t ;
    *right.View_t
    *left.View_t
    *top.View_t
    
    name.s                          ; View Name
    lorr.b                          ; left or right view
    
    x.i                             ; View Position X
    y.i                             ; View Position Y
    width.i                         ; View Actual Width
    height.i                        ; View Actual Height
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
    
    splitterID.i                    ; Canvas Splitter ID(if not leaf)

    parentID.i                      ; Parent Window ID
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
  Declare TouchBorderEvent(*view,border.i)
  Declare ClearBorderEvent(*view)
  Declare GetActive(*view,x.i,y.i)
  Declare Split(*view,options.i=0,perc.i=50)
  Declare Resize(*view,x.i,y.i,width.i,height.i)
  Declare OnEvent(*view,event.i)
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

    lastx.i
    lasty.i
    window.i
  
  EndStructure
  
  Global *view_manager.ViewManager_t
  
  Declare New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  Declare Delete(*manager.ViewManager_t)
  Declare OnEvent(*manager.ViewManager_t,event.i)
;   Declare UpdateMap(*manager.ViewManager_t)
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
   
;     *view\gadgetID = ContainerGadget(#PB_Any,x,y,width,height)
;   
;     SetGadgetColor(*view\gadgetID,#PB_Gadget_BackColor,COLOR_MAIN_BG)
;     ;*view\canvasID = FrameGadget(#PB_Any,0,0,width,height,"test");CanvasGadget(#PB_Any,0,0,width,height)
;     
;     CloseGadgetList()
    
    *view\axis = axis
    *view\type = 0;#VIEW_EMPTY
    
    ;increment view id counter
    view_id_counter + 1
    *view\id = view_id_counter
    
    If *top = #Null
      *view\manager = #Null
      *view\top = #Null
    Else
      *view\top = *top
      *view\manager = *top\manager
    EndIf
   
    ProcedureReturn *view
  EndProcedure
  
  ;----------------------------------------------------------
  ; Delete View
  ;----------------------------------------------------------
  Procedure Delete(*view.View_t)
;     If *view\gadgetID : FreeGadget(*view\gadgetID) : EndIf
;     If *view\canvasID : FreeGadget(*view\canvasID) : EndIf
;     If *view\imageID  : FreeImage(*view\imageID)   : EndIf
    
    FreeMemory(*view)
    
  EndProcedure
  

  
  ;----------------------------------------------------------
  ; Resize
  ;----------------------------------------------------------
  Procedure Resize(*view.View_t,x.i,y.i,width.i,height.i)
    Protected *manager.ViewManager::ViewManager_t = *view\manager
    
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
      Protected *manager.ViewManager::ViewManager_t = *view\manager
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
        If Not *view\fixed : SetGadgetAttribute(*view\splitterID,#PB_Canvas_Cursor,#PB_Cursor_UpDown):EndIf
      EndIf
      
     
      
      *view\axis = Bool(options & #PB_Splitter_Vertical)
      *view\leaf = #False
      *view\perc = perc
;       CloseGadgetList()
      
       
      ProcedureReturn *view
    Else
      ProcedureReturn #Null
    EndIf
    
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Touch Border Event
  ;----------------------------------------------------------------------------------
  Procedure.i TouchBorderEvent(*view.View_t,border.i)
    Protected *manager.ViewManager::ViewManager_t = *view\manager
    Protected btn.i
    If *view\fixed : ProcedureReturn : EndIf

    If EventType() = #PB_EventType_LeftButtonDown
      Protected drag.b = #True
      
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
      
      ; No Parent View ---> Cannot resize
      If Not *affected : ProcedureReturn : EndIf
      If *affected\content
        *affected\content\active = #True
      EndIf
      
      
      
      
      Protected sx,sy,sw, sh
      Protected mx = WindowMouseX(*manager\window)
      Protected my = WindowMouseY(*manager\window)
       

      Define e
      Repeat 
        e = WaitWindowEvent()
        ; Get Mouse Position
        mx = WindowMouseX(*manager\window)
        my = WindowMouseY(*manager\window)
        ; Resize Window Event
        ;If EventType() = #PB_EventType_LeftButtonUp
        
        ;If e = #PB_Event_WindowDrop Or e = #PB_Event_GadgetDrop
        If e = #PB_Event_Gadget And EventType() = #PB_EventType_LeftButtonUp
          GetPercentage(*affected,mx,my)
          drag = #False
        EndIf
  
      Until drag = #False
      ViewManager::OnEvent(*manager,#PB_Event_SizeWindow)
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
    
    ;Left border
    If Abs(*view\x - x)<w                 And  *view\y<y    And *view\y+*view\height>y : ProcedureReturn #VIEW_LEFT : EndIf
    
    ;Right border
    If Abs((*view\x+*view\width) - x)<w   And  *view\y<y    And *view\y+*view\height>y : ProcedureReturn #VIEW_RIGHT : EndIf
    
    ;Top border
    If Abs(*view\y - y)<w                 And  *view\x<x    And *view\x+*view\width>x : ProcedureReturn #VIEW_TOP : EndIf
    
    ;Bottom border
     If Abs((*view\y+*view\height) - y)<w  And  *view\x<x    And *view\x+*view\width>x : ProcedureReturn #VIEW_BOTTOM : EndIf
    
    ProcedureReturn #VIEW_NONE
    
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
        Box(0,0,GadgetWidth(*affected\splitterID),GadgetHeight(*affected\splitterID),UIColor::COLOR_SPLITTER)
        StopDrawing()
       
        
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
  ;     DrawingMode(#PB_2DDrawing_Outlined)
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
    Protected *manager.ViewManager::ViewManager_t = *view\manager
    
    Protected active.b = *view\active 
    
    If *view\leaf
      If MouseInside(*view,x,y) = #True
        *view\active = #True
        
        If active <>#True : *view\dirty  = #True : EndIf
        ProcedureReturn #True
      Else
        *view\active = #False
        If active = #True : *view\dirty = #True : EndIf
        ProcedureReturn #False
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
      If *Me\content <> #Null And event = #PB_Event_Gadget
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
    *content\top = *Me
    
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
  
  Procedure Resize(*manager.ViewManager_t)    
    If Not *manager : ProcedureReturn : EndIf
    Protected w = WindowWidth(*manager\window,#PB_Window_InnerCoordinate)
    Protected h = WindowHeight(*manager\window,#PB_Window_InnerCoordinate)
;       Protected ev_data.EventTypeDatas_t
;       ev_data\x = 0
;       ev_data\y = 0
;       ev_data\width = w
;       ev_data\height = h
      View::Resize(*manager\main,0,0,w,h)
      ;View::OnEvent(*manager\main,#PB_Event_SizeWindow)
  EndProcedure
    
    
  ;----------------------------------------------------------------------------------
  ; Recurse View
  ;----------------------------------------------------------------------------------
  Procedure RecurseView(*manager.ViewManager_t,*view.View::View_t)
    If *view\leaf
      If *view\active
        If *manager\active And *manager\active <> *view
          *manager\active\active = #False
          *manager\active\dirty = #True
          View::OnEvent(*manager\active,#PB_EventType_LostFocus)
        EndIf
        *manager\active = *view
      EndIf
    Else
      If *view\left : RecurseView(*manager,*view\left) : EndIf
      If *view\right : RecurseView(*manager,*view\right) : EndIf
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Get Active View
  ;----------------------------------------------------------------------------------
  Procedure.i GetActiveView(*manager.ViewManager_t,x.i,y.i)
    Protected *view.View::View_t = *manager\main
    View::GetActive(*view,x,y)
    ProcedureReturn RecurseView(*manager,*manager\main)
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Drag
  ;----------------------------------------------------------------------------------
  Procedure Drag(*manager.ViewManager_t)
    ;Debug "View Manager Drag View Top ID: "+Str(*manager\active\top\id)  
  EndProcedure
  
;   ;----------------------------------------------------------------------------------
;   ; Set Map Element
;   ;----------------------------------------------------------------------------------
;   Procedure SetMapElement(*manager.ViewManager_t,*view.View::View_t)
;     If *view\leaf And *view\content
;       Protected name.s = *view\content\name
;       ; Check if already in map
;       AddMapElement(*manager\views(),name)
;       *manager\views() = *view\content
;       Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ADD VIEW MAP ELEMENT : "+name
;     Else
;       SetMapElement(*manager,*view\left)
;       SetMapElement(*manager,*view\right)
;     EndIf
;     
;   EndProcedure
;   
;   ;----------------------------------------------------------------------------------
;   ; Update Map
;   ;----------------------------------------------------------------------------------
;   Procedure UpdateMap(*manager.ViewManager_t)
;     ClearMap(*manager\views())
;     SetMapElement(*manager,*manager\main)
;   EndProcedure

  
  ;----------------------------------------------------------------------------------
  ; Event
  ;----------------------------------------------------------------------------------
  Procedure OnEvent(*manager.ViewManager_t,event.i)
    
    Protected x,y,w,h,i,gadgetID,state
    Protected dirty.b = #False
    Protected *view.View::View_t = #Null
    If *manager = #Null Or event = -1: ProcedureReturn: EndIf
    
    Protected mx = WindowMouseX(*manager\window)
    Protected my = WindowMouseY(*manager\window)
        
    GetActiveView(*manager,mx,my)
    Debug "MANAGER EVENT : "+Str(event)
    Select event
      Case #PB_Event_Gadget      
        If *manager\active 
          Protected touch = View::TouchBorder(*manager\active,mx,my,#VIEW_BORDER_SENSIBILITY)
          If touch
            View::EventSplitter(*manager\active,touch)
            View::TouchBorderEvent(*manager\active,touch)
            View::OnEvent(*manager\active,event)
          Else
            View::ClearBorderEvent(*manager\active)
            View::OnEvent(*manager\active,event)
          EndIf
        EndIf
          
      Case #PB_Event_Timer
        Scene::Update(Scene::*current_scene)
        View::OnEvent(*manager\main,#PB_Event_Timer)
      
      Case Globals::#EVENT_BUTTON_PRESSED
        Debug "Button Pressed ---> "+PeekS(EventData())
        
      Case Globals::#EVENT_COMMAND_CALLED
        View::OnEvent(*manager\main,Globals::#EVENT_COMMAND_CALLED)
      Case Globals::#EVENT_PARAMETER_CHANGED
        View::OnEvent(*manager\main,Globals::#EVENT_PARAMETER_CHANGED)
        Scene::Update(Scene::*current_scene)
      Case Globals::#EVENT_GRAPH_CHANGED
        View::OnEvent(*manager\main,Globals::#EVENT_GRAPH_CHANGED)
         Scene::Update(Scene::*current_scene)
      Case #PB_Event_Repaint
        View::OnEvent(*manager\main,#PB_Event_Repaint)
      Case #PB_Event_Timer
;         Select EventTimer()
;           Case #RAA_TIMELINE_TIMER
;             ; Get Timeline View
;             If FindMapElement(*manager\views(),"Timeline")
;               Protected *timeline.CView = *manager\views()
;               *timeline\Event(#PB_Event_Timer,#Null)
;             EndIf
;             
;         EndSelect
;         
      Case #PB_Event_Menu
        Select EventMenu()
;           Case Globals::#SHORTCUT_COPY
;             Debug "View Manager : SHORTCUT COPY"
;             View::OnEvent(*manager\active,#PB_Event_Menu)
;           Case Globals::#SHORTCUT_CUT
;             Debug "View Manager : SHORTCUT CUT"
;             View::OnEvent(*manager\active,#PB_Event_Menu)
;           Case Globals::#SHORTCUT_PASTE
;             Debug "View Manager : SHORTCUT PASTE"
;             View::OnEvent(*manager\active,#PB_Event_Menu)
          Case Globals::#SHORTCUT_UNDO
            MessageRequester("View Manager","Undo Called")
            Commands::Undo(Commands::*manager)
          Case Globals::#SHORTCUT_REDO
            MessageRequester("View Manager","Redo Called")
            Commands::Redo(Commands::*manager)
          Default
            View::OnEvent(*manager\active,#PB_Event_Menu)
            
        EndSelect
        
            
      Case #PB_Event_SizeWindow
        Resize(*manager)
      Case #PB_Event_MaximizeWindow
        Resize(*manager)
      Case #PB_Event_MoveWindow
        Resize(*manager)
      Case #PB_Event_Menu
        ProcedureReturn
      Case #PB_Event_CloseWindow
        ProcedureReturn 
      
    EndSelect
  
  EndProcedure

  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*e.ViewManager_t)
    FreeMemory(*e)
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Constructor
  ; ----------------------------------------------------------------------------------
  Procedure New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
    Protected *Me.ViewManager_t = AllocateMemory(SizeOf(ViewManager_t))
    
    InitializeStructure(*Me,ViewManager_t)
  
    
    ;Protected options.i = #PB_Window_BorderLess|#PB_Window_Maximize
    ;Protected options.i = #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget
    *Me\name = name
    *Me\window = OpenWindow(#PB_Any, 0, 0, width, height, *Me\name, options)  
;     SetWindowColor(*Me\window,RGB(240,240,240))
    EnableWindowDrop(*Me\window,#PB_Drop_Private,#PB_Drag_Move,#VIEW_SPLITTER_DROP)
    *Me\main = View::New(x.i,y.i,WindowWidth(*Me\window),WindowHeight(*Me\window),#Null,#False,name,#True)
    *Me\main\manager = *Me
    *Me\main\parentID = *Me\window
    *Me\active = *Me\main
  
    
   
;   AddKeyboardShortcut(*manager\window,#PB_Shortcut_Return                 ,#RAA_SHORTCUT_ENTER)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Tab                    ,#SHORTCUT_NEXT)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Shift|#PB_Shortcut_Tab ,#SHORTCUT_PREVIOUS)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Shift|#PB_Shortcut_R   ,#SHORTCUT_RESET)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Delete                 ,#SHORTCUT_DELETE)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Control|#PB_Shortcut_C ,#SHORTCUT_COPY)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Control|#PB_Shortcut_V ,#SHORTCUT_PASTE)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Control|#PB_Shortcut_X ,#SHORTCUT_CUT)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Control|#PB_Shortcut_Z ,#SHORTCUT_UNDO)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Control|#PB_Shortcut_Y ,#SHORTCUT_REDO)
;     AddKeyboardShortcut(*Me\window,#PB_Shortcut_Escape                 ,#SHORTCUT_QUIT)

    *view_manager = *Me
    
    ProcedureReturn *Me
    
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.61 (Linux - x64)
; CursorPosition = 587
; FirstLine = 582
; Folding = ------
; EnableXP
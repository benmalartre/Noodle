XIncludeFile "Types.pbi"


;============================================================
; View Module Declared in Types.pbi
;============================================================

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
      *view\window = 0
      *view\parent = #Null
    Else
      *view\parent = *top
      *view\window = *top\window
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
      Protected hs = #VIEW_BORDER_SENSIBILITY/2
      If *view\fixed
        If *view\axis
          If *view\fixed_side = #PB_Splitter_FirstFixed
            ResizeGadget(*view\splitter,*view\x+ *view\fixed_size,*view\y,2*hs,*view\height)
            Resize(*view\left,*view\x,*view\y,*view\fixed_size-hs,*view\height)
            Resize(*view\right,*view\x+*view\fixed_size+hs,*view\y,*view\width-*view\fixed_size-hs,*view\height)
          Else
            ResizeGadget(*view\splitter,*view\x+*view\width - *view\fixed_size,*view\y,2*hs,*view\height)
            Resize(*view\left,*view\x,*view\y,*view\width-*view\fixed_size-hs,*view\height)
            Resize(*view\right,*view\x+*view\width-*view\fixed_size+hs,*view\y,*view\fixed_size-hs,*view\height)
          EndIf
          
        Else
          If *view\fixed_side = #PB_Splitter_FirstFixed
            ResizeGadget(*view\splitter,*view\x,*view\y + *view\fixed_size-hs,*view\width,2*hs)
            Resize(*view\left,*view\x,*view\y,*view\width,*view\fixed_size-hs)
            Resize(*view\right,*view\x,*view\y+*view\fixed_size+hs,*view\width,*view\height-*view\fixed_size-hs)
          Else
            ResizeGadget(*view\splitter,*view\x,*view\y + *view\height-*view\fixed_size-hs,*view\width,2*hs)
            Resize(*view\left,*view\x,*view\y,*view\width,*view\height - *view\fixed_size-hs)
            Resize(*view\right,*view\x,*view\y+*view\height -*view\fixed_size+hs,*view\width,*view\fixed_size-hs)
          EndIf
          
        EndIf
      Else
        If *view\axis
          ResizeGadget(*view\splitter,*view\x+*view\width* *view\perc/100-hs,*view\y,2*hs,*view\height)
          Resize(*view\left,*view\x,*view\y,*view\width* *view\perc/100-hs,*view\height)
          Resize(*view\right,*view\x+*view\width* *view\perc/100+hs,*view\y,*view\width-*view\width* *view\perc/100-hs,*view\height)
        Else
          ResizeGadget(*view\splitter,*view\x,*view\y + *view\height * *view\perc/100-hs,*view\width,2*hs)
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
      Protected hs = #VIEW_BORDER_SENSIBILITY/2
      Protected *content = *view\content

      UseGadgetList(WindowID(GetWindowID(*view)))
      
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
        *view\left\window = *view\window
        *view\right = New(*view\x+ mx+hs,*view\y,*view\width-mx-hs,*view\height,*view,#True,*view\name+"_R",#False)
        SetSplitter(*view\right,*view,*view\rsplitter,*view\tsplitter,*view\bsplitter)
        *view\right\window = *view\window
        
        
        *view\splitter = CanvasGadget(#PB_Any,*view\x+mx-hs,*view\y,2*hs,*view\height)
        StartDrawing(CanvasOutput(*view\splitter))
        Box(0,0,GadgetWidth(*view\splitter), GadgetHeight(*view\splitter), UIColor::COLOR_SPLITTER)
        StopDrawing()

      If Not *view\fixed : SetGadgetAttribute(*view\splitter,#PB_Canvas_Cursor,#PB_Cursor_LeftRight) : EndIf
      
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
        *view\left\window = *view\window
        *view\right = New(*view\x,*view\y+ my+hs,*view\width,*view\height-my-hs,*view,#False,*view\name+"_R",#False)
        SetSplitter(*view\right,*view\lsplitter,*view\rsplitter,*view,*view\bsplitter)
        *view\right\window = *view\window

        *view\splitter = CanvasGadget(#PB_Any,*view\x,*view\y+my-hs,*view \width,2*hs)
        StartDrawing(CanvasOutput(*view\splitter))
        Box(0,0,GadgetWidth(*view\splitter), GadgetHeight(*view\splitter), UIColor::COLOR_SPLITTER)
        StopDrawing()
        If Not *view\fixed : SetGadgetAttribute(*view\splitter,#PB_Canvas_Cursor,#PB_Cursor_UpDown):EndIf
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
    Protected btn.i
    If *view\fixed : ProcedureReturn : EndIf
    If EventType() = #PB_EventType_LeftButtonDown
      Protected drag.b = #True
      
      Protected sx,sy,sw, sh
      Protected windowID = EventWindow()
      Protected mx = WindowMouseX(windowID)
      Protected my = WindowMouseY(windowID)
       

      Define e
      Repeat 
        e = WaitWindowEvent()
        ; Get Mouse Position
        mx = WindowMouseX(windowID)
        my = WindowMouseY(windowID)
        ; Resize Window Event
        ;If EventType() = #PB_EventType_LeftButtonUp
        
        ;If e = #PB_Event_WindowDrop Or e = #PB_Event_GadgetDrop
        If e = #PB_Event_Gadget And EventType() = #PB_EventType_LeftButtonUp
          GetPercentage(*view,mx,my)
          drag = #False
        EndIf
  
      Until drag = #False
      PostEvent(#PB_Event_SizeWindow)
;       ViewManager::OnEvent(*Me,#PB_Event_SizeWindow)
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
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *view\lsplitter 
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *view\rsplitter 
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *view\bsplitter 
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
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
      
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
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
    
    If *Me\leaf
      If *Me\content <> #Null
        Protected *content.UI::IUI = *Me\content
        *content\Event(event)
      EndIf
      
    Else
      If event = #PB_Event_SizeWindow
        Resize(*Me,0,0,WindowWidth(*Me\window),WindowHeight(*Me\window))  
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
;     
;     Protected *manager.ViewManager::ViewManager_t = *Me\manager
;     If *manager : *manager\uis(*content\name) = *content : EndIf
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Get Window
  ;-----------------------------------------------------------------------------------
  Procedure GetWindow(*Me.View_t)
    ProcedureReturn *Me\window
  EndProcedure
  
  Procedure GetWindowID(*Me.View_t)
    Define *window.Window::Window_t = *Me\window
    ProcedureReturn *window\ID
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

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 379
; FirstLine = 358
; Folding = ----
; EnableXP
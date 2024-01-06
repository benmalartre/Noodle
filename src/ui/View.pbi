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
    Protected *Me.View_t = AllocateStructure(View_t)
    Object::INI(View)
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width
    *Me\sizY = height
  
    *Me\right = #Null
    *Me\left = #Null
    *Me\leaf = #True
    *Me\active = #False
    *Me\dirty = #True
    *Me\name = name
    *Me\lorr = lorr
    *Me\content = #Null
    
    *Me\axis = axis
    *Me\type = 0
    
    ;increment view id counter
    view_id_counter + 1
    *Me\id = view_id_counter
    
    If *top = #Null
      *Me\window = 0
      *Me\parent = #Null
    Else
      *Me\parent = *top
      *Me\window = *top\window
    EndIf
    ProcedureReturn *Me
  EndProcedure
  
  ;----------------------------------------------------------
  ; Delete View
  ;----------------------------------------------------------
  Procedure Delete(*Me.View_t)
    FreeStructure(*Me)
  EndProcedure
  
  ;----------------------------------------------------------
  ; Resize
  ;----------------------------------------------------------
  Procedure Resize(*Me.View_t,x.i,y.i,width.i,height.i)
    
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width
    *Me\sizY = height
    Protected mx,my
    If *Me\leaf
      Protected *ui.UI::UI_t = *Me\content
      Protected ui.UI::IUI = *ui
      If *ui
        ui\OnEvent(#PB_Event_SizeWindow)
      EndIf
    Else
      Protected hs = #VIEW_BORDER_SENSIBILITY/2
      If *Me\fixed
        If *Me\axis
          If *Me\fixed_side = #PB_Splitter_FirstFixed
            ResizeGadget(*Me\splitter,*Me\posX+ *Me\fixed_size,*Me\posY,2*hs,*Me\sizY)
            Resize(*Me\left,*Me\posX,*Me\posY,*Me\fixed_size-hs,*Me\sizY)
            Resize(*Me\right,*Me\posX+*Me\fixed_size+hs,*Me\posY,*Me\sizX-*Me\fixed_size-hs,*Me\sizY)
          Else
            ResizeGadget(*Me\splitter,*Me\posX+*Me\sizX - *Me\fixed_size,*Me\posY,2*hs,*Me\sizY)
            Resize(*Me\left,*Me\posX,*Me\posY,*Me\sizX-*Me\fixed_size-hs,*Me\sizY)
            Resize(*Me\right,*Me\posX+*Me\sizX-*Me\fixed_size+hs,*Me\posY,*Me\fixed_size-hs,*Me\sizY)
          EndIf
          
        Else
          If *Me\fixed_side = #PB_Splitter_FirstFixed
            ResizeGadget(*Me\splitter,*Me\posX,*Me\posY + *Me\fixed_size-hs,*Me\sizX,2*hs)
            Resize(*Me\left,*Me\posX,*Me\posY,*Me\sizX,*Me\fixed_size-hs)
            Resize(*Me\right,*Me\posX,*Me\posY+*Me\fixed_size+hs,*Me\sizX,*Me\sizY-*Me\fixed_size-hs)
          Else
            ResizeGadget(*Me\splitter,*Me\posX,*Me\posY + *Me\sizY-*Me\fixed_size-hs,*Me\sizX,2*hs)
            Resize(*Me\left,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY - *Me\fixed_size-hs)
            Resize(*Me\right,*Me\posX,*Me\posY+*Me\sizY -*Me\fixed_size+hs,*Me\sizX,*Me\fixed_size-hs)
          EndIf
          
        EndIf
      Else
        If *Me\axis
          ResizeGadget(*Me\splitter,*Me\posX+*Me\sizX* *Me\perc/100-hs,*Me\posY,2*hs,*Me\sizY)
          Resize(*Me\left,*Me\posX,*Me\posY,*Me\sizX* *Me\perc/100-hs,*Me\sizY)
          Resize(*Me\right,*Me\posX+*Me\sizX* *Me\perc/100+hs,*Me\posY,*Me\sizX-*Me\sizX* *Me\perc/100-hs,*Me\sizY)
        Else
          ResizeGadget(*Me\splitter,*Me\posX,*Me\posY + *Me\sizY * *Me\perc/100-hs,*Me\sizX,2*hs)
          Resize(*Me\left,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY* *Me\perc/100-hs)
          Resize(*Me\right,*Me\posX,*Me\posY+*Me\sizY* *Me\perc/100+hs,*Me\sizX,*Me\sizY-*Me\sizY* *Me\perc/100-hs)
        EndIf
      EndIf
    EndIf
    InitSplitter(*Me)
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Get Percentage
  ;----------------------------------------------------------------------------------
  Procedure GetPercentage(*Me.View_t,mx.i,my.i)
    ;If Not *Me\fixed
      If Not *Me\axis
        If my<*Me\posY Or my>*Me\posY+*Me\sizY 
          ProcedureReturn
        EndIf
        *Me\perc = (my-*Me\posY) * 100 /*Me\sizY
      Else
        If mx<*Me\posX Or mx>*Me\posX+*Me\sizX 
          ProcedureReturn
        EndIf
        *Me\perc = (mx-*Me\posX) * 100 /*Me\sizX
        
      EndIf
  ;   Else
  ;     ; when a view is fixed , it's size is in pixels...
  ;     If *Me\axis
  ;       Debug "View ----------------------------------> Vertical"
  ;       Protected h = *Me\fixed_size
  ;       Protected nh.f = *Me\sizY/h*100
  ;       *Me\perc = nh;
  ;     Else
  ;       Debug "View ----------------------------------> Horizontal"
  ;       Protected w = *Me\fixed_size
  ;       Protected nw.f = *Me\sizX/w*100
  ;       *Me\perc = nw;
  ;     EndIf
  ;     
  ;   EndIf
      
      
    EndProcedure
    
  ;----------------------------------------------------------------------------------
  ; Split
  ;----------------------------------------------------------------------------------
  Procedure SetSplitter(*Me.View_t,l,r,t,b)
    *Me\lsplitter = l
    *Me\rsplitter = r
    *Me\tsplitter = t
    *Me\bsplitter = b
  EndProcedure
  
  Procedure Split(*Me.View_t,options.i=0,perc.i=50)
    If *Me\leaf
      Protected hs = #VIEW_BORDER_SENSIBILITY/2
      Protected *content = *Me\content

      UseGadgetList(WindowID(GetWindowID(*Me)))
      
      *Me\fixed = Bool(options & #PB_Splitter_FirstFixed Or options & #PB_Splitter_SecondFixed)
      If *Me\fixed
        If options & #PB_Splitter_FirstFixed
          *Me\fixed_size = perc
          *Me\fixed_side = #PB_Splitter_FirstFixed
        ElseIf options & #PB_Splitter_SecondFixed
           *Me\fixed_size = perc
           *Me\fixed_side = #PB_Splitter_SecondFixed
        EndIf
      EndIf

      If options & #PB_Splitter_Vertical
        Protected mx
        If *Me\fixed
          
          If *Me\fixed_side = #PB_Splitter_FirstFixed
            mx = *Me\fixed_size
          Else
            mx = *Me\sizX-*Me\fixed_size
          EndIf
        Else
          mx = *Me\sizX*perc/100
        EndIf
        
        *Me\left = New(*Me\posX,*Me\posY,mx-hs,*Me\sizY,*Me,#True,*Me\name+"_L",#True)
        SetSplitter(*Me\left,*Me\lsplitter,*Me,*Me\tsplitter,*Me\bsplitter)
        *Me\left\content = *content
        *Me\left\window = *Me\window
        *Me\right = New(*Me\posX+ mx+hs,*Me\posY,*Me\sizX-mx-hs,*Me\sizY,*Me,#True,*Me\name+"_R",#False)
        SetSplitter(*Me\right,*Me,*Me\rsplitter,*Me\tsplitter,*Me\bsplitter)
        *Me\right\window = *Me\window
        
        *Me\splitter = CanvasGadget(#PB_Any,*Me\posX+mx-hs,*Me\posY,2*hs,*Me\sizY)
        StartDrawing(CanvasOutput(*Me\splitter))
        Box(0,0,GadgetWidth(*Me\splitter), GadgetHeight(*Me\splitter), UIColor::COLOR_SPLITTER)
        StopDrawing()

        If Not *Me\fixed : SetGadgetAttribute(*Me\splitter,#PB_Canvas_Cursor,#PB_Cursor_LeftRight) : EndIf
      
      Else
        Protected my
        If *Me\fixed
          
          If *Me\fixed_side = #PB_Splitter_FirstFixed
            my = *Me\fixed_size
          Else
            my = *Me\sizY-*Me\fixed_size
          EndIf
        Else
          my = *Me\sizY*perc/100
        EndIf

        *Me\left = New(*Me\posX,*Me\posY,*Me\sizX,my-hs,*Me,#False,*Me\name+"_L",#True)
        SetSplitter(*Me\left,*Me\lsplitter,*Me\rsplitter,*Me\tsplitter,*Me)
        *Me\left\content = *content
        *Me\left\window = *Me\window
        *Me\right = New(*Me\posX,*Me\posY+ my+hs,*Me\sizX,*Me\sizY-my-hs,*Me,#False,*Me\name+"_R",#False)
        SetSplitter(*Me\right,*Me\lsplitter,*Me\rsplitter,*Me,*Me\bsplitter)
        *Me\right\window = *Me\window

        *Me\splitter = CanvasGadget(#PB_Any,*Me\posX,*Me\posY+my-hs,*Me\sizX,2*hs)
        StartDrawing(CanvasOutput(*Me\splitter))
        Box(0,0,GadgetWidth(*Me\splitter), GadgetHeight(*Me\splitter), UIColor::COLOR_SPLITTER)
        StopDrawing()
        If Not *Me\fixed : SetGadgetAttribute(*Me\splitter,#PB_Canvas_Cursor,#PB_Cursor_UpDown):EndIf
      EndIf

      *Me\axis = Bool(options & #PB_Splitter_Vertical)
      *Me\leaf = #False
      *Me\perc = perc
       
      ProcedureReturn *Me
    Else
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Touch Border Event
  ;----------------------------------------------------------------------------------
  Procedure.i TouchBorderEvent(*Me.View_t)
    If Not *Me : ProcedureReturn : EndIf
    Protected btn.i
    If *Me\fixed : ProcedureReturn : EndIf
    If EventType() = #PB_EventType_LeftButtonDown
      Protected drag.b = #True
      
      Protected sx,sy,sw, sh
      Protected windowID = EventWindow()
      Protected mx = WindowMouseX(windowID)
      Protected my = WindowMouseY(windowID)
       

      Define e
      Repeat 
        e = WaitWindowEvent()
        mx = WindowMouseX(windowID)
        my = WindowMouseY(windowID)

        If e = #PB_Event_Gadget And EventType() = #PB_EventType_LeftButtonUp
          GetPercentage(*Me,mx,my)
          drag = #False
        EndIf
      Until drag = #False
      PostEvent(#PB_Event_SizeWindow)
    EndIf
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Touch Border Event
  ;----------------------------------------------------------------------------------
  Procedure ClearBorderEvent(*Me.View_t)
    
  EndProcedure

  
  ;----------------------------------------------------------------------------------
  ; Touch Border
  ;----------------------------------------------------------------------------------
  Procedure.i TouchBorder(*Me.View_t,x.i,y.i,w.i)
    If Not  *Me : ProcedureReturn : EndIf
    ;Left border
    If Abs(x - *Me\posX)<w                     : ProcedureReturn #VIEW_LEFT : EndIf
    ;Right border
    If Abs((*Me\posX+*Me\sizX) - x)<w       : ProcedureReturn #VIEW_RIGHT : EndIf
    ;Top border
    If Abs(y - *Me\posY)<w                     : ProcedureReturn #VIEW_TOP : EndIf
    ;Bottom border
     If Abs((*Me\posY+*Me\sizY) - y)<w     : ProcedureReturn #VIEW_BOTTOM : EndIf
    ProcedureReturn #VIEW_NONE
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Init Splitter
  ;------------------------------------------------------------------
  Procedure InitSplitter(*Me.View_t)
    If *Me And Not *Me\fixed
      Protected *affected.View_t
      *affected = *Me\tsplitter 
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *Me\lsplitter 
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *Me\rsplitter 
      If *affected And *affected\splitter
        StartDrawing(CanvasOutput(*affected\splitter  ))
        Box(0,0,GadgetWidth(*affected\splitter),GadgetHeight(*affected\splitter),UIColor::COLOR_TERNARY_BG)
        StopDrawing() 
      EndIf
      
      *affected = *Me\bsplitter 
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
  Procedure EventSplitter(*Me.View_t,border.i)
    If *Me And Not *Me\fixed
      ; Get Affected View
      Protected *affected.View_t
      Select border
        Case #VIEW_TOP
          *affected = *Me\tsplitter
        Case #VIEW_LEFT
          *affected = *Me\lsplitter
        Case #VIEW_RIGHT
          *affected = *Me\rsplitter
        Case #VIEW_BOTTOM
          *affected = *Me\bsplitter
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
  Procedure.b MouseInside(*Me.View_t, x.i,y.i)
  
    If x>*Me\posX And x<*Me\posX+*Me\sizX And y>*Me\posY And y<*Me\posY+*Me\sizY
      ProcedureReturn #True
    EndIf
     
    ProcedureReturn #False
      
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Draw
  ;----------------------------------------------------------------------------------
  Procedure Draw(*Me.View_t)

    
    If *Me\leaf And *Me\dirty
      ;OViewControl_OnEvent(*Me\control,#PB_Event_Repaint,#Null)
  ;     StartDrawing(CanvasOutput(*Me\canvasID))
  ;     Box(0,0,*Me\sizX,*Me\sizY,RGB(100,100,100))
  ;     DrawImage(ImageID(*Me\imageID),*Me\offsetx,*Me\offsety) 
  ;     *Me\dirty = #False
  ;     DrawingModeDrawPick
  ;     RoundBox(0,0,*Me\sizX,*Me\sizY,2,2,RGB(120,120,120))
  ;     StopDrawing()
    Else
      If *Me\left : Draw(*Me\left) : EndIf
      If *Me\right : Draw(*Me\right) : EndIf
    EndIf
    
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Get Active View
  ;----------------------------------------------------------------------------------
  Procedure GetActive(*Me.View_t,x.i,y.i)
    Protected active.b = *Me\active 
    If *Me\leaf
      If MouseInside(*Me,x,y) = #True
        *Me\active = #True
        If active <>#True : *Me\dirty  = #True : EndIf
      Else
        *Me\active = #False
        If active = #True : *Me\dirty = #True : EndIf
      EndIf
    Else
      If *Me\left : GetActive(*Me\left,x,y) : EndIf
      If *Me\right : GetActive(*Me\right,x,y) : EndIf
    EndIf

  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Drag View (if image > canvas)
  ;-----------------------------------------------------------------------------------
  Procedure Drag(*Me.View_t)
  ;   Protected limit_x = GadgetWidth(*Me\canvasID)-ImageWidth(*Me\imageID)
  ;   Protected limit_y = GadgetHeight(*Me\canvasID)-ImageHeight(*Me\imageID)
  ;   
  ;   Protected mx = GetGadgetAttribute(*Me\canvasID,#PB_Canvas_MouseX)
  ;   Protected my = GetGadgetAttribute(*Me\canvasID,#PB_Canvas_MouseY)
  ;   
  ;   *Me\offsetx + mx-*Me\lastx
  ;   *Me\offsety + my-*Me\lasty
  ;   
  ; ;   Debug "Offset X : "+Str(*Me\offsetx)
  ; ;   Debug "Offset Y : "+Str(*Me\offsety)
  ;   
  ;   *Me\lastx = mx
  ;   *Me\lasty = my
  ;   
  ;   Clamp(*Me\offsetx,limit_x,0)
  ;   Clamp(*Me\offsety,limit_y,0)
  ;   OView_Draw(*Me)
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; View Event
  ;-----------------------------------------------------------------------------------
  Procedure OnEvent(*Me.View_t,event.i)
    If Not event Or Not *Me : ProcedureReturn : EndIf
    If *Me\leaf
      If *Me\content <> #Null
        Protected *content.UI::IUI = *Me\content
        *content\OnEvent(event)
      EndIf
    Else
      Select event:
        Case #PB_Event_SizeWindow
          Resize(*Me,0,0,WindowWidth(*Me\window),WindowHeight(*Me\window))  
        Case #PB_Event_Timer
          OnEvent(*Me\left,#PB_Event_Timer)
          OnEvent(*Me\right,#PB_Event_Timer)
        Case #PB_Event_Repaint
          OnEvent(*Me\left,#PB_Event_Repaint)
          OnEvent(*Me\right,#PB_Event_Repaint)
        Default
          OnEvent(*Me\left,#PB_Event_Repaint)
          OnEvent(*Me\right,event)
          OnEvent(*Me\left,event)
      EndSelect
    EndIf
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------------
  ; Set Content
  ;-----------------------------------------------------------------------------------
  Procedure SetContent(*Me.View_t,*content.UI::UI_t)   
    *Me\content = *content
    *content\parent = *Me
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
;       If *Me\sizX>*Me\iwidth : *Me\scrollmaxx = 0 : Else : *Me\scrollmaxx = *Me\iwidth-*Me\sizX : EndIf
;       If *Me\sizY>*Me\iheight : *Me\scrollmaxy = 0 : Else : *Me\scrollmaxy = *Me\iheight-*Me\sizY : EndIf
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
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( View )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 269
; FirstLine = 236
; Folding = ----
; EnableXP
XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Control.pbi"
; XIncludeFile "Command.pbi"

; -----------------------------------------
; ControlColor Module Declaration
; -----------------------------------------
DeclareModule ControlColor
  #FIXED_HEIGHT = 60
  Structure ControlColor_t Extends Control::Control_t
    container.i
    red_txt.i
    green_txt.i
    blue_txt.i
    red_input.i
    green_input.i
    blue_input.i
    red_slider.i
    green_slider.i
    blue_slider.i
    display_canvas.i
    color.Math::c4f32
    r_dirty.b
    g_dirty.b
    b_dirty.b
    c_dirty.b
    collapsed.b
  EndStructure
  
  Interface IControlColor Extends Control::IControl
  EndInterface

  Declare New(name.s,x.i,y.i,w.i,h.i)
  Declare Delete(*Me.ControlColor_t)
  Declare Init(*Me.ControlColor_t)
  Declare OnEvent(*Me.ControlColor_t,event.i)
  Declare Term(*Me.ControlColor_t)
  Declare Draw(*Me.ControlColor_t)
  Declare Update(*Me.ControlColor_t)
  
  DataSection 
    ControlColorVT: 
    Data.i @OnEvent()
    Data.i @Delete()
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; ControlColor Module Implementation
; -----------------------------------------
Module ControlColor

  ; New
  ;-------------------------------
  Procedure New(name.s,x.i,y.i,w.i,h.i)
    
    Protected tw = 50
    Protected iw = 50
    Protected pw = h
    Protected *Me.ControlColor_t = AllocateMemory(SizeOf(ControlColor_t))
    InitializeStructure(*Me,ControlColor_t)
    *Me\name = name
    *Me\container = ContainerGadget(#PB_Any,x,y,w,h)
    *Me\red_txt = TextGadget(#PB_Any,4,4,tw,h/3,"Red")
    *Me\green_txt = TextGadget(#PB_Any,4,h/3+4,tw,h/3,"Green")
    *Me\blue_txt = TextGadget(#PB_Any,4,2*h/3+4,tw,h/3,"Blue")
    *Me\red_input = StringGadget(#PB_Any,tw,0,iw,h/3,"0.0",#PB_String_Numeric)
    *Me\green_input = StringGadget(#PB_Any,tw,h/3,iw,h/3,"0.0",#PB_String_Numeric)
    *Me\blue_input = StringGadget(#PB_Any,tw,2*h/3,iw,h/3,"0.0",#PB_String_Numeric)
    *Me\red_slider = TrackBarGadget(#PB_Any,tw+iw,0,w-(tw+iw+pw),h/3,0,255)
    *Me\green_slider = TrackBarGadget(#PB_Any,tw+iw,h/3,w-(tw+iw+pw),h/3,0,255)
    *Me\blue_slider = TrackBarGadget(#PB_Any,tw+iw,2*h/3,w-(tw+iw+pw),h/3,0,255)
    *Me\display_canvas = CanvasGadget(#PB_Any,w-pw,0,pw,h)
    *Me\VT = ?ControlColorVT
    
    *Me\r_dirty = #True
    Update(*Me)
    Draw(*Me)
    OnEvent(*Me,#PB_Event_SizeWindow)
    CloseGadgetList()
    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*Me.ControlColor_t)
    FreeGadget(*Me\red_slider)
    FreeGadget(*Me\green_slider)
    FreeGadget(*Me\blue_slider)
    FreeGadget(*Me\red_input)
    FreeGadget(*Me\green_input)
    FreeGadget(*Me\blue_input)
    FreeGadget(*Me\red_txt)
    FreeGadget(*Me\green_txt)
    FreeGadget(*Me\blue_txt)
    FreeGadget(*Me\display_canvas)
    ClearStructure(*Me,ControlColor_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; Update
  ;-------------------------------
  Procedure Update(*Me.ControlColor_t)
    If *Me\c_dirty
      ; Update RGB From COlor
      Protected r = *Me\color\r*255
      Protected g = *Me\color\g*255
      Protected b = *Me\color\b*255
      
      SetGadgetState(*Me\red_slider,r)
      SetGadgetState(*Me\green_slider,g)
      SetGadgetState(*Me\blue_slider,b)
      
      SetGadgetText(*Me\red_input,Str(r))
      SetGadgetText(*Me\green_input,Str(g))
      SetGadgetText(*Me\blue_input,Str(b))
      
    Else
      If *Me\r_dirty Or *Me\g_dirty Or *Me\b_dirty
        r = GetGadgetState(*Me\red_slider)
        g = GetGadgetState(*Me\green_slider)
        b = GetGadgetState(*Me\blue_slider)
     
        Color::Set(*Me\color,r/255,g/255,b/255,1.0)
      EndIf
      
    EndIf
    
  EndProcedure
  
  ; Draw
  ;-------------------------------
  Procedure Resize(*Me.ControlColor_t)
    Protected w = GadgetWidth(*Me\container)
    Protected h = GadgetHeight(*Me\container)
    If w<80 And Not *Me\collapsed
      *Me\collapsed = #True
      HideGadget(*Me\red_txt,#True)
      HideGadget(*Me\green_txt,#True)
      HideGadget(*Me\blue_txt,#True)
      HideGadget(*Me\red_input,#True)
      HideGadget(*Me\green_input,#True)
      HideGadget(*Me\blue_input,#True)
      HideGadget(*Me\red_slider,#True)
      HideGadget(*Me\green_slider,#True)
      HideGadget(*Me\blue_slider,#True)
      
    ElseIf w>=80 And *Me\collapsed
      *Me\collapsed = #False
      HideGadget(*Me\red_txt,#False)
      HideGadget(*Me\green_txt,#False)
      HideGadget(*Me\blue_txt,#False)
      HideGadget(*Me\red_input,#False)
      HideGadget(*Me\green_input,#False)
      HideGadget(*Me\blue_input,#False)
      HideGadget(*Me\red_slider,#False)
      HideGadget(*Me\green_slider,#False)
      HideGadget(*Me\blue_slider,#False)
    EndIf
    
  EndProcedure
  
  ; Draw
  ;-------------------------------
  Procedure Draw(*Me.ControlColor_t)
    Protected w = GadgetWidth(*Me\container)
    Protected h = GadgetHeight(*Me\container)
    StartDrawing(CanvasOutput(*Me\display_canvas))
    DrawingMode(#PB_2DDrawing_Default)
    Box(w-h,0,h,h,UIColor::COLOR_MAIN_BG)
    Protected x,y
    w = GadgetWidth(*Me\display_canvas)
    h = GadgetHeight(*Me\display_canvas)
    For x = 0 To w Step 4
      For y=0 To h Step 4
        Select (y/4)%2
          Case 0 
            Select (x/4)%2
              Case 0
                Box(x,y,4,4,RGB(100,100,100))
              Case 1
                Box(x,y,4,4,RGB(150,150,150))
            EndSelect
          Case 1
            Select (x/4)%2
              Case 0
                Box(x,y,4,4,RGB(150,150,150))
              Case 1
                Box(x,y,4,4,RGB(100,100,100))
            EndSelect
        EndSelect
        
      Next
      
    Next
    
    ;Box(0,0,GadgetWidth(*Me\frames_canvas),GadgetHeight(*Me\frames_canvas),RGB(175,175,175))
    StopDrawing()
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*Me.ControlColor_t)
    Debug "ControlColor Init Called!!!"
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*Me.ControlColor_t,event.i)
    Debug "ControlColor Event Called!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Draw(*Me)
    Select event
      Case #PB_Event_SizeWindow
;         Protected ty = GadgetHeight(*Me\container)-25
;         ResizeGadget(*Me\first_frame_btn,0,ty,25,20)
;         ResizeGadget(*Me\play_btn,25,ty,25,20)
;         ResizeGadget(*Me\stop_btn,50,ty,25,20)
;         ResizeGadget(*Me\last_frame_btn,75,ty,25,20)
;         ResizeGadget(*Me\loop_btn,100,ty,25,20)
;         ;ResizeGadget(*Me\current_frame_txt,75,0,25,GadgetHeight(*Me\container))
;         ResizeGadget(*Me\frames_canvas,0,0,GadgetWidth(*Me\container),GadgetHeight(*Me\container)-25)
;         Draw(*Me)
      Case #PB_Event_Gadget
;         Protected g = EventGadget()
;         Select g
;           
;           
;         EndSelect
        
    EndSelect
    
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*Me.ControlColor_t)
    Debug "ControlColor Term Called!!!"
  EndProcedure
  
  
EndModule

; UseModule ControlColor
; window = OpenWindow(#PB_Any,0,0,120,600,"Test ControlColor",#PB_Window_SizeGadget|#PB_Window_SystemMenu)
; *colorUI.ControlColor_t = ControlColor::New("ControlColor",0,0,120,60)
; Define e
; Repeat
;   e = WaitWindowEvent()
;   ControlColor::Event(*colorUI,e)
; Until e = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 81
; FirstLine = 77
; Folding = --
; EnableXP
; EnableUnicode
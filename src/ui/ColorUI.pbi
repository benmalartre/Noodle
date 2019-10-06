XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; -----------------------------------------
; ColorUI Module Declaration
; -----------------------------------------
DeclareModule ColorUI
  
  Structure ColorUI_t Extends UI::UI_t
    red_txt.i
    green_txt.i
    blue_txt.i
    red_input.i
    green_input.i
    blue_input.i
    red_slider.i
    green_slider.i
    blue_slider.i
    color_display.i
    color.Math::c4f32
    r_dirty.b
    g_dirty.b
    b_dirty.b
    c_dirty.b
    
  EndStructure
  
  Interface IColorUI Extends UI::IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s)
  Declare Delete(*Me.ColorUI_t)
  Declare Resize(*Me.ColorUI_t)
  Declare Draw(*Me.ColorUI_t)
  Declare DrawPickImage(*Me.ColorUI_t)
  Declare Pick(*Me.ColorUI_t)
  Declare OnEvent(*Me.ColorUI_t,event.i)
  Declare Update(*Me.ColorUI_t)
  
  DataSection 
    ColorUIVT: 
    Data.i @Delete()
    Data.i @Resize()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i @Pick()
    Data.i @OnEvent()
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; ColorUI Module Implementation
; -----------------------------------------
Module ColorUI

  ; New
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s)
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
    Protected tw = 50
    Protected iw = 50
    Protected pw = h
    Protected *Me.ColorUI_t = AllocateMemory(SizeOf(ColorUI_t))
    Object::INI(ColorUI)
    *Me\name = name
    *Me\container = ContainerGadget(#PB_Any,x,y,w,h)
    *Me\sizX = w
    *Me\sizY = h
    *Me\red_txt = TextGadget(#PB_Any,4,4,tw,h/3,"Red")
    *Me\green_txt = TextGadget(#PB_Any,4,h/3+4,tw,h/3,"Green")
    *Me\blue_txt = TextGadget(#PB_Any,4,2*h/3+4,tw,h/3,"Blue")
    *Me\red_input = StringGadget(#PB_Any,tw,0,iw,h/3,"0.0",#PB_String_Numeric)
    *Me\green_input = StringGadget(#PB_Any,tw,h/3,iw,h/3,"0.0",#PB_String_Numeric)
    *Me\blue_input = StringGadget(#PB_Any,tw,2*h/3,iw,h/3,"0.0",#PB_String_Numeric)
    *Me\red_slider = TrackBarGadget(#PB_Any,tw+iw,0,w-(tw+iw+pw),h/3,0,255)
    *Me\green_slider = TrackBarGadget(#PB_Any,tw+iw,h/3,w-(tw+iw+pw),h/3,0,255)
    *Me\red_slider = TrackBarGadget(#PB_Any,tw+iw,2*h/3,w-(tw+iw+pw),h/3,0,255)
    *Me\color_display = CanvasGadget(#PB_Any,w-pw,0,pw,h)
    OnEvent(*Me,#PB_Event_SizeWindow)
    CloseGadgetList()
    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*Me.ColorUI_t)
    FreeGadget(*Me\red_slider)
    FreeGadget(*Me\green_slider)
    FreeGadget(*Me\blue_slider)
    FreeGadget(*Me\color_display)
    Object::TERM(ColorUI)
  EndProcedure
  
  ; Update
  ;-------------------------------
  Procedure Update(*Me.ColorUI_t)
    If *Me\c_dirty
      ; Update RGB From COlor
      Protected r = Red(*Me\color)
      Protected g = Green(*Me\color)
      Protected b = Blue(*Me\color)
      
      SetGadgetState(*Me\red_slider,r)
      SetGadgetState(*Me\green_slider,g)
      SetGadgetState(*Me\blue_slider,b)
      
      SetGadgetText(*Me\red_input,Str(r))
      SetGadgetText(*Me\green_input,Str(g))
      SetGadgetText(*Me\blue_input,Str(b))
      
    Else
      If *Me\r_dirty Or *Me\g_dirty Or *Me\b_dirty
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  ; Draw
  ;-------------------------------
  Procedure Draw(*Me.ColorUI_t)
    StartDrawing(CanvasOutput(*Me\color_display))
    DrawingMode(#PB_2DDrawing_Default)
    Protected x,y
    Protected w = GadgetWidth(*Me\color_display)
    Protected h = GadgetHeight(*Me\color_display)
    For x = 0 To w Step 12
      For y=0 To h Step 12
        Select y%2
          Case 0 
            Select x%2
              Case 0
                Box(x,y,w/5,h/5,RGB(0,255,0))
              Case 1
                Box(x,y,w/5,h/5,RGB(255,0,0))
            EndSelect
          Case 1
            Select x%2
              Case 0
                Box(x,y,w/5,h/5,RGB(255,0,0))
              Case 1
                Box(x,y,w/5,h/5,RGB(0,255,0))
            EndSelect
        EndSelect
        
      Next
      
    Next
    
    ;Box(0,0,GadgetWidth(*Me\frames_canvas),GadgetHeight(*Me\frames_canvas),RGB(175,175,175))
    StopDrawing()
  EndProcedure
  
  Procedure DrawPickImage(*Me.COlorUI_t)
    
  EndProcedure
  
  Procedure Pick(*Me.COlorUI_t)
    
  EndProcedure
  
  Procedure Resize(*Me.COlorUI_t)
    
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*Me.ColorUI_t,event.i)
    Debug "ColorUI Event Called!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
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
  
  
EndModule

; UseModule ColorUI
; window = OpenWindow(#PB_Any,0,0,800,600,"Test ColorUI")
; *colorUI.ColorUI_t = ColorUI::New("ColorUI",0,0,800,60)
; Define e
; Repeat
;   e = WaitWindowEvent()
;   ColorUI::Event(*colorUI,e)
; Until e = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 161
; FirstLine = 136
; Folding = --
; EnableXP
; EnableUnicode
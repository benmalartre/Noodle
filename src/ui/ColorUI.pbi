XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; -----------------------------------------
; ColorUI Module Declaration
; -----------------------------------------
DeclareModule ColorUI
  UseModule UI
  
  Structure ColorUI_t Extends UI_t
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
  
  Interface IColorUI Extends IUI
  EndInterface

  Declare New(name.s,x.i,y.i,w.i,h.i)
  Declare Delete(*ui.ColorUI_t)
  Declare Init(*ui.ColorUI_t)
  Declare Event(*ui.ColorUI_t,event.i)
  Declare Term(*ui.ColorUI_t)
  Declare Draw(*ui.ColorUI_t)
  Declare Update(*ui.ColorUI_t)
  
  DataSection 
    ColorUIVT: 
      Data.i @Init()
      Data.i @Event()
      Data.i @Term()
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; ColorUI Module Implementation
; -----------------------------------------
Module ColorUI

  ; New
  ;-------------------------------
  Procedure New(name.s,x.i,y.i,w.i,h.i)
    
    Protected tw = 50
    Protected iw = 50
    Protected pw = h
    Protected *ui.ColorUI_t = AllocateMemory(SizeOf(ColorUI_t))
    InitializeStructure(*ui,ColorUI_t)
    *ui\name = name
    *ui\container = ContainerGadget(#PB_Any,x,y,w,h)
    *ui\width = w
    *ui\height = h
    *ui\red_txt = TextGadget(#PB_Any,4,4,tw,h/3,"Red")
    *ui\green_txt = TextGadget(#PB_Any,4,h/3+4,tw,h/3,"Green")
    *ui\blue_txt = TextGadget(#PB_Any,4,2*h/3+4,tw,h/3,"Blue")
    *ui\red_input = StringGadget(#PB_Any,tw,0,iw,h/3,"0.0",#PB_String_Numeric)
    *ui\green_input = StringGadget(#PB_Any,tw,h/3,iw,h/3,"0.0",#PB_String_Numeric)
    *ui\blue_input = StringGadget(#PB_Any,tw,2*h/3,iw,h/3,"0.0",#PB_String_Numeric)
    *ui\red_slider = TrackBarGadget(#PB_Any,tw+iw,0,w-(tw+iw+pw),h/3,0,255)
    *ui\green_slider = TrackBarGadget(#PB_Any,tw+iw,h/3,w-(tw+iw+pw),h/3,0,255)
    *ui\red_slider = TrackBarGadget(#PB_Any,tw+iw,2*h/3,w-(tw+iw+pw),h/3,0,255)
    *ui\color_display = CanvasGadget(#PB_Any,w-pw,0,pw,h)
    *ui\VT = ?ColorUIVT
    Event(*ui,#PB_Event_SizeWindow)
    CloseGadgetList()
    ProcedureReturn *ui
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*ui.ColorUI_t)
    FreeGadget(*ui\red_slider)
    FreeGadget(*ui\green_slider)
    FreeGadget(*ui\blue_slider)
    FreeGadget(*ui\color_display)
    ClearStructure(*ui,ColorUI_t)
    FreeMemory(*ui)
  EndProcedure
  
  ; Update
  ;-------------------------------
  Procedure Update(*ui.ColorUI_t)
    If *ui\c_dirty
      ; Update RGB From COlor
      Protected r = Red(*ui\color)
      Protected g = Green(*ui\color)
      Protected b = Blue(*ui\color)
      
      SetGadgetState(*ui\red_slider,r)
      SetGadgetState(*ui\green_slider,g)
      SetGadgetState(*ui\blue_slider,b)
      
      SetGadgetText(*ui\red_input,Str(r))
      SetGadgetText(*ui\green_input,Str(g))
      SetGadgetText(*ui\blue_input,Str(b))
      
    Else
      If *ui\r_dirty Or *ui\g_dirty Or *ui\b_dirty
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  ; Draw
  ;-------------------------------
  Procedure Draw(*ui.ColorUI_t)
    StartDrawing(CanvasOutput(*ui\color_display))
    DrawingMode(#PB_2DDrawing_Default)
    Protected x,y
    Protected w = GadgetWidth(*ui\color_display)
    Protected h = GadgetHeight(*ui\color_display)
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
    
    ;Box(0,0,GadgetWidth(*ui\frames_canvas),GadgetHeight(*ui\frames_canvas),RGB(175,175,175))
    StopDrawing()
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*ui.ColorUI_t)
    Debug "ColorUI Init Called!!!"
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure Event(*ui.ColorUI_t,event.i)
    Debug "ColorUI Event Called!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Draw(*ui)
    Select event
      Case #PB_Event_SizeWindow
;         Protected ty = GadgetHeight(*ui\container)-25
;         ResizeGadget(*ui\first_frame_btn,0,ty,25,20)
;         ResizeGadget(*ui\play_btn,25,ty,25,20)
;         ResizeGadget(*ui\stop_btn,50,ty,25,20)
;         ResizeGadget(*ui\last_frame_btn,75,ty,25,20)
;         ResizeGadget(*ui\loop_btn,100,ty,25,20)
;         ;ResizeGadget(*ui\current_frame_txt,75,0,25,GadgetHeight(*ui\container))
;         ResizeGadget(*ui\frames_canvas,0,0,GadgetWidth(*ui\container),GadgetHeight(*ui\container)-25)
;         Draw(*ui)
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
  Procedure Term(*ui.ColorUI_t)
    Debug "ColorUI Term Called!!!"
  EndProcedure
  
  
EndModule

UseModule ColorUI
window = OpenWindow(#PB_Any,0,0,800,600,"Test ColorUI")
*colorUI.ColorUI_t = ColorUI::New("ColorUI",0,0,800,60)
Define e
Repeat
  e = WaitWindowEvent()
  ColorUI::Event(*colorUI,e)
Until e = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 157
; FirstLine = 132
; Folding = --
; EnableUnicode
; EnableXP
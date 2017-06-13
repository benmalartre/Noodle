;===========================================================================================
; CONTROL MODULE DECLARATION
;===========================================================================================
DeclareModule Control
  Enumeration
    #CONTROL_BUTTON
    #CONTROL_COLOR
    #CONTROL_SLIDER
    #CONTROL_COMBO
    #CONTROL_NUMBER
    #CONTROL_STRING
    #CONTROL_GROUP
  EndEnumeration
  
  Structure Control_t
    name.s
    px.i
    py.i
    sx.i
    sy.i
    
    active.b
    over.b
    down.b
    gadgetID.i
    *datas
    
  EndStructure
EndDeclareModule

;===========================================================================================
; CONTROL MODULE IMPLEMENTATION
;===========================================================================================
Module Control
EndModule

;===========================================================================================
; SLIDER MODULE DECLARATION
;===========================================================================================
DeclareModule Slider
  Structure Slider_t Extends Control::Control_t
    min.f
    max.f
    cur.f
  EndStructure
  
  Declare New(name.s="Slider",px.i=0,py.i=0,sx.i=100,sy.i=20,min.f=0.0,max.f=0.0,cur.f=0.0)
  Declare Delete(*Me.Slider_t)
EndDeclareModule

;===========================================================================================
; SLIDER MODULE IMPLEMENTATION
;===========================================================================================
Module Slider
  ; Constructor
  ;-----------------------------------------------------------------------------------------
  Procedure New(name.s="Slider",px.i=0,py.i=0,sx.i=100,sy.i=20,min.f=0.0,max.f=0.0,cur.f=0.0)  
EndModule


Global window = OpenWindow(#PB_Any,0,0,800,600,"Vector Drawing")
Global canvas = CanvasGadget(#PB_Any,0,0,800,600)
StartVectorDrawing(CanvasVectorOutput(canvas))

; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 26
; Folding = -
; EnableUnicode
; EnableXP
XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/UIColor.pbi"

; ==============================================================================
;  CONTROL THERMOMETER MODULE DECLARATION
; ==============================================================================
DeclareModule ControlThermometer
  ; ----------------------------------------------------------------------------
  ;  Constants ( ControlThermometer_t )
  ; ----------------------------------------------------------------------------
  #PB_GadgetType_Thermometer = 129
  
  #THERMOMETER_RADIUS = 24
  #THERMOMETER_WIDTH = 8
  #THERMOMETER_HEIGHT  = 128
  
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlThermometer_t )
  ; ----------------------------------------------------------------------------
  Structure ControlThermometer_t Extends Control::Control_t
    oldX.i
    oldY.i
    mouseX.i
    mouseY.i
    angle.f
    last_angle.f
    angle_offset.f
    over.i
    down.i
    min.f
    max.f
    value.f
    *onchanged_signal.Slot::Slot_t
    *onleftclick_signal.Slot::Slot_t
    *onleftdoubleclick_signal.Slot::Slot_t
  EndStructure
  
EndDeclareModule

Module ControlThermometer
  
EndModule

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 34
; FirstLine = 11
; Folding = -
; EnableXP
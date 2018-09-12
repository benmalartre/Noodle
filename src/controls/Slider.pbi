XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Control.pbi"


DeclareModule ControlSlider
  Structure ControlSlider_t Extends Control::Control_t
    
  EndStructure
    
  Declare New(name.s,x.i,y.i,width.i,height.i)
  Declare Delete(*Me.ControlSlider_t)
  
  DataSection 
    ControlSliderVT: 
    Data.i @Event()
    Data.i @Delete()
  EndDataSection 
  
EndDeclareModule

Module ControlSlider
  
  ; CONSTRUCTOR
  ;--------------------------------------------------------------------------
  Procedure New(name.s,x.i,y.i,width.i,height.i)
    Protected *Me.ControlSlider_t = AllocateMemory(SizeOf(ControlSlider_t))
    InitializeStructure(*Me,ControlSlider_t)
    *Me\name = name
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width
    *Me\sizY = height
    *Me\VT = ?ControlSliderVT
    ProcedureReturn *Me
  EndProcedure
  
  ; DESTRUCTOR
  ;--------------------------------------------------------------------------
  Procedure Delete(*Me.ControlSlider_t)
    ClearStructure(*Me,ControlSlider_t)
    FreeMemory(*Me)
  EndProcedure
  
 
  
 
  
  Procedure Callback(*Me.ControlSliderItem_t)
    MessageRequester("[CONTROl MENU]","Callback Called!!!")
  EndProcedure
  
  Procedure OnEvent(*Me.ControlSliderItem_t,event.i,*ev_data.EventTypeDatas_t = #Null )
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 3
; Folding = --
; EnableXP
; EnableUnicode
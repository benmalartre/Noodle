XIncludeFile "Types.pbi"

; ==============================================================================
;  UI MODULE IMPLEMENTATION
; ==============================================================================
Module UI
  Procedure.s GetName(*ui.UI_t)
    ProcedureReturn *ui\name
  EndProcedure
  
  Procedure GetScrollArea(*Me.UI_t)
    If *Me\scrollable
      *Me\scrolling = #False
      If *Me\sizX>*Me\iSizX : *Me\scrollMaxX = 0 : Else : *Me\scrollMaxX = *Me\iSizX-*Me\sizX : EndIf
      If *Me\sizY>*Me\iSizY : *Me\scrollMaxY = 0 : Else : *Me\scrollMaxY = *Me\iSizY-*Me\sizY : EndIf
    EndIf
  EndProcedure
  
  Procedure Scroll(*Me.UI_t,mode.b =#False)
    If *Me\scrollable And (*Me\scrolling Or mode = #True)
      If mode = #True
        Protected d = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_WheelDelta)
        *Me\scrollY + d*22
      Else
        
        Protected x = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
        Protected y = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
        *Me\scrollX + (x-*Me\scrollLastX)
        *Me\scrollY + (y-*Me\scrollLastY)
        *Me\scrollLastX = x
        *Me\scrollLastY = y
      EndIf
      
      If *Me\scrollX>0 : *Me\scrollX = 0 : EndIf
      If *Me\scrollY>0 : *Me\scrollY = 0 : EndIf
      If *Me\scrollX<-*Me\scrollMaxX : *Me\scrollX = -*Me\scrollMaxX : EndIf
      If *Me\scrollY<-*Me\scrollMaxY : *Me\scrollY = -*Me\scrollMaxY : EndIf
      
    EndIf
  EndProcedure
  
  
  
  Procedure GetView(*Me.UI_t)
    ProcedureReturn *Me\view
  EndProcedure
  
  Procedure GetWindow(*Me.UI_t)
    Protected *view.View::View_t = *Me\view
    Debug "UI view :" + *Me\name +" : "+Str(*view)
    If *view
      ProcedureReturn *view\window
    Else
      ProcedureReturn #Null 
    EndIf
  EndProcedure

EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 51
; FirstLine = 1
; Folding = --
; EnableXP
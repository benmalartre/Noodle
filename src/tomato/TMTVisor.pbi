XIncludeFile "TMTInclude.pbi"
XIncludeFile "TMTUI.pbi"

DeclareModule TMTVisor
  Structure TMTVisor_t Extends TMTUI_t
    vao.GLint
  EndStructure
  Declare New()
  Declare Delete(*ui.TMTVisor_t)
EndDeclareModule

Module TMTVisor
  Procedure New()
    
  EndProcedure
  
  Procedure Delete(*ui.TMTVisor_t)
    
  EndProcedure
  
EndModule


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 19
; Folding = -
; EnableXP
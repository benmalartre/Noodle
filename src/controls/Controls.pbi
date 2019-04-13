XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "Divot.pbi"
XIncludeFile "Label.pbi"
XIncludeFile "Check.pbi"
XIncludeFile "Edit.pbi"
XIncludeFile "Number.pbi"
XIncludeFile "Button.pbi"
XIncludeFile "Group.pbi"
XIncludeFile "Icon.pbi"
XIncludeFile "Combo.pbi"
XIncludeFile "Timeline.pbi"
XIncludeFile "Explorer.pbi"

; ==============================================================================
;  CONTROL EDIT MODULE DECLARATION
; ==============================================================================
DeclareModule Controls
  Declare Init()
  Declare Term()
  
  Declare SetTheme(theme.i)
  
EndDeclareModule

Module Controls
  Procedure Init()
    ControlDivot::Init()
    ControlNumber::Init()
    ControlEdit::Init()
    ControlButton::Init()
    ControlIcon::Init()
    ControlCombo::Init()
    ControlExplorer::Init()
  EndProcedure
  
  Procedure Term()
    ControlDivot::Term()
    ControlNumber::Term()
    ControlEdit::Init()
    ControlButton::Term()
    ControlIcon::Term()
    ControlCombo::Term()
    ControlExplorer::Term()
  EndProcedure
  
  Procedure SetTheme(theme.i)
    UIColor::SetTheme(theme)
    ControlDivot::SetTheme(theme)
    ControlNumber::SetTheme(theme)
    ControlEdit::SetTheme(theme)
    ControlButton::SetTheme(theme)
    ControlIcon::SetTheme(theme)
    ControlCombo::SetTheme(theme)
    ;ControlExplorer::SetTheme(theme)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 50
; FirstLine = 3
; Folding = -
; EnableXP
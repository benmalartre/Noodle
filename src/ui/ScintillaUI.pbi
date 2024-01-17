XIncludeFile "../controls/Scintilla.pbi"
XIncludeFile "UI.pbi"

; ==========================================================================================
;   SCINTILLA UI DECLARATION
; ==========================================================================================
DeclareModule ScintillaUI
  Structure ScintillaUI_t Extends UI::UI_t
  EndStructure
  
  ; -------------------------------------------------------------------
  ;   DECLARE
  ; -------------------------------------------------------------------
  Declare New(*parent.View::View_t)
  Declare OnEvent(*Me.ScintillaUI_t, event.i)
  Declare Delete(*Me.ScintillaUI_t)
  Declare Resize(*Me.ScintillaUI_t, x.i, y.i, width.i, height.i)
  Declare AddItem(*Me.ScintillaUI_t, name.s)
  
  ; -------------------------------------------------------------------
  ;   VIRTUAL TABLE
  ; -------------------------------------------------------------------
  DataSection
    ScintillaUIVT:
      Data.i @OnEvent()
      Data.i @Delete()
  EndDataSection
  
EndDeclareModule

; ==========================================================================================
;   SCINTILLA UI IMPLEMENTATION
; ==========================================================================================
Module ScintillaUI

  ; ----------------------------------------------------------------------------------------
  ;   EVENT
  ; ----------------------------------------------------------------------------------------
  Procedure Resize(*Me.ScintillaUI_t, x.i, y.i, width.i, height.i)
    ResizeGadget(*Me\gadgetID, x, y, width, height)
  EndProcedure

  Procedure OnEvent(*Me.ScintillaUI_t, event.i) 
    Protected *top.View::View_t = *Me\view
    Select event
        
      Case #PB_EventType_Resize, #PB_Event_SizeWindow
        Resize(*Me, *top\posX, *top\posY, *top\sizX, *top\sizY)
        
    EndSelect

  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   ADD ITEM
  ; ----------------------------------------------------------------------------------------
  Procedure AddItem(*Me.ScintillaUI_t, name.s)
    AddGadgetItem(*Me\gadgetID, -1, "New", 0, 0)
    Protected *control.ControlScintilla::ControlScintilla_t = ControlScintilla::New(name, 0, 0, *Me\sizX, *Me\sizY)
  EndProcedure

  
  ; ----------------------------------------------------------------------------------------
  ;   CONSTRUCTOR
  ; ----------------------------------------------------------------------------------------
  Procedure New(*parent.View::View_t)
    
    Define *Me.ScintillaUI_t = AllocateStructure(ScintillaUI_t)
    Object::INI(ScintillaUI)
    
    *Me\parent = *parent
    *Me\posX = *parent\posX
    *Me\posY = *parent\posY
    *Me\sizX = *parent\sizX
    *Me\sizY = *parent\sizY
    *Me\gadgetID = PanelGadget(#PB_Any, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    AddItem(*Me, "New")
  
    View::SetContent(*parent, *Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   DESTRUCTOR
  ; ----------------------------------------------------------------------------------------
  Procedure Delete(*Me.ScintillaUI_t)
    FreeGadget(*Me\gadgetID)
    Object::TERM(ScintillaUI)
  EndProcedure
  
EndModule

; =======================================================================================================
;   EOF
; =======================================================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; Folding = --
; EnableXP
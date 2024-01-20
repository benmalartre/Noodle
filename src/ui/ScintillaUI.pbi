XIncludeFile "../controls/Scintilla.pbi"
XIncludeFile "UI.pbi"

; ==========================================================================================
;   SCINTILLA UI DECLARATION
; ==========================================================================================
DeclareModule ScintillaUI
  Structure ScintillaUI_t Extends UI::UI_t
    Map *editors.ControlScintilla::ControlScintilla_t()
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
  ;   RESIZE 
  ; ----------------------------------------------------------------------------------------
  Procedure Resize(*Me.ScintillaUI_t, x.i, y.i, width.i, height.i)
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width
    *Me\sizY = height
    ResizeGadget(*Me\gadgetID, x, y, width, height)
    ForEach *Me\editors()
      ControlScintilla::OnEvent(*Me\editors(), #PB_EventType_Resize, #Null)
    Next
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   EVENT
  ; ----------------------------------------------------------------------------------------
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
    OpenGadgetList(*Me\gadgetID)
    AddGadgetItem(*Me\gadgetID, -1, name, 0, 0)
    Protected *control.ControlScintilla::ControlScintilla_t = ControlScintilla::New(*Me, name, 0, 0, *Me\sizX, *Me\sizY)
    *Me\editors(name) = *control
    CloseGadgetList()
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
    CloseGadgetList()
    AddItem(*Me, "One")
    AddItem(*Me, "Two")
    AddItem(*Me, "Three")
  
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
; CursorPosition = 74
; Folding = --
; EnableXP
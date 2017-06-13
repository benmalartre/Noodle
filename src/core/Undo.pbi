XIncludeFile "Object.pbi"

DeclareModule UndoManager
  Prototype Cmd_Do(*info)
  Prototype Cmd_Undo(*info)
  Prototype Cmd_Clear(*info)


  ;---------------------------------------------
  ; Command Structure
  ;---------------------------------------------
  Structure Cmd_t
    Do.Cmd_Do
    Undo.Cmd_Undo
    Clear.Cmd_Clear
    *info
  EndStructure

  ;----------------------------------------------
  ; Undo/ Redo Manager
  ;----------------------------------------------
  Structure UndoManager_t Extends Object::Object_t
    List Undo_Stack.Cmd_t()
    List Redo_Stack.Cmd_t()
  EndStructure
  
  Declare New()
  Declare Delete(*manager.UndoManager_t)
  Declare Add(*manager.UndoManager_t,Do,Undo,Clear, *info)
  Declare Do(*manager.UndoManager_t)
  Declare Undo(*manager.UndoManager_t)
  Declare Redo(*manager.UndoManager_t)
  Declare Init()
  Declare Term()
  Global *manager.UndoManager_t
EndDeclareModule

Module UndoManager


  Procedure Add(*um.UndoManager_t, Do,Undo,Clear, *info)
    ForEach *um\Redo_Stack()
      *um\Redo_Stack()\Clear(*um\Redo_Stack()\info)
    Next
    ClearList (*um\Redo_Stack())
    AddElement(*um\Undo_Stack())
    With *um\Undo_Stack()
      \info = *info
      \Do = Do
      \Undo = Undo
      \Clear = Clear
    EndWith
    
  EndProcedure
  
   ;Procedure Do
  Procedure Do(*um.UndoManager_t)
    *um\Undo_Stack()\Do(*um\Undo_Stack()\info)
  EndProcedure
  
  ; Procedure Undo
  Procedure Undo(*um.UndoManager_t)
    If ListSize(*um\Undo_Stack())>0
      *um\Undo_Stack()\Undo(*um\Undo_Stack()\info)
      
      ; Before removing it we put the command in the Redo Stack
      AddElement(*um\Redo_Stack())
      With *um\Redo_Stack()
        \info = *um\Undo_Stack()\info
        \Do = *um\Undo_Stack()\Do
        \Undo = *um\Undo_Stack()\Undo
        \Clear = *um\Undo_Stack()\Clear
      EndWith
      DeleteElement(*um\Undo_Stack())
    EndIf
    
  EndProcedure
  
  ; Procedure Redo
  Procedure Redo(*um.UndoManager_t)
    If ListSize(*um\Redo_Stack())>0
      *um\Redo_Stack()\Do(*um\Redo_Stack()\info)
      
      ; Before removing it we put the command in the Undo Stack
      AddElement(*um\Undo_Stack())
      With *um\Undo_Stack()
        \info = *um\Redo_Stack()\info
        \Do = *um\Redo_Stack()\do
        \Undo = *um\Redo_Stack()\undo
        \Clear = *um\Redo_Stack()\clear
      EndWith
      DeleteElement(*um\Redo_Stack())
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------
  ; Init
  ;-----------------------------------------------------
  Procedure Init()
    *manager.UndoManager_t = New()
  EndProcedure
  
  ;-----------------------------------------------------
  ; Term
  ;-----------------------------------------------------
  Procedure Term()
    If *manager:
      Delete(*manager)
    EndIf
  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Destructor
  ;-----------------------------------------------------
  Procedure Delete(*um.UndoManager_t)
    ClearStructure(*um,UndoManager_t)
    FreeMemory(*um)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Constructor
  ;-----------------------------------------------------
  Procedure New()
    Protected *Me.UndoManager_t = AllocateMemory(SizeOf(UndoManager_t))
    InitializeStructure(*Me,UndoManager_t)
    ProcedureReturn *Me
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 27
; Folding = --
; EnableXP
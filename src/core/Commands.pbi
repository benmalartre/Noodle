XIncludeFile "Object.pbi"
; ============================================================================
; COMMANDS MODULE DECLARATION
; ============================================================================

DeclareModule Commands

  
  
  ; ============================================================================
  ;  PROTOTYPES
  ; ============================================================================
  Prototype Cmd_Do(*info)
  Prototype Cmd_Undo(*info)
  Prototype Cmd_Clear(*info)
  
  
  
  ; ============================================================================
  ;  STRUCTURES
  ; ============================================================================
  ; ----------------------------------------------------------------------------
  ;  CCommand Instance
  ; ----------------------------------------------------------------------------
  Structure Command_t
    Do.Cmd_Do
    Undo.Cmd_Undo
    Clear.Cmd_Clear
    *info
  EndStructure


  ; ----------------------------------------------------------------------------
  ;  CCommandManager Instance
  ; ----------------------------------------------------------------------------
  Structure CommandManager_t 
    
    List Undo_Stack.Command_t()
    List Redo_Stack.Command_t()
    
    
  EndStructure


  Declare New()
  Declare Delete(*manager.CommandManager_t)
  Declare Term()
  Declare Init()
  Declare Add(*manager.CommandManager_t,Do,Undo,Clear, *info)
  Declare Do(*manager.CommandManager_t)
  Declare Undo(*manager.CommandManager_t)
  Declare Redo(*manager.CommandManager_t)
  Declare Clear(*manager.CommandManager_t)
  
 Global *manager.CommandManager_t
EndDeclareModule

; ==============================================================================
;  COMMANDS MODULE IMPLEMENTATION
; ==============================================================================
Module Commands
  ;-----------------------------------------------------------------------------
  ; Clear
  ;-----------------------------------------------------------------------------
  Procedure Clear(*Me.CommandManager_t)
    ForEach *Me\Undo_Stack()
      *Me\Undo_Stack()\Clear(*Me\Undo_Stack()\info)
      DeleteElement(*Me\Undo_Stack())
    Next
    
    ForEach *Me\Redo_Stack()
      *Me\Redo_Stack()\Clear(*Me\Redo_Stack()\info)
      DeleteElement(*Me\Redo_Stack())
    Next
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add
  ;-----------------------------------------------------------------------------
  Procedure Add(*Me.CommandManager_t, Do,Undo,Clear, *info)
    ForEach *Me\Redo_Stack()
      *Me\Redo_Stack()\Clear(*Me\Redo_Stack()\info)
    Next
    ClearList (*Me\Redo_Stack())
    AddElement(*Me\Undo_Stack())
    With *Me\Undo_Stack()
      \info = *info
      \Do = Do
      \Undo = Undo
      \Clear = Clear
    EndWith
    
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Do
  ;-----------------------------------------------------------------------------
  Procedure Do(*Me.CommandManager_t)
    *Me\Undo_Stack()\Do(*Me\Undo_Stack()\info)
  EndProcedure

  
  ;-----------------------------------------------------------------------------
  ; Undo
  ;-----------------------------------------------------------------------------
  Procedure Undo(*Me.CommandManager_t)
    MessageRequester("Undo Called","Stack Size ---> "+Str(ListSize(*Me\Undo_Stack())))
    If ListSize(*Me\Undo_Stack())>0
      *Me\Undo_Stack()\Undo(*Me\Undo_Stack()\info)
      
      ; Before removing it we put the command in the Redo Stack
      AddElement(*Me\Redo_Stack())
      With *Me\Redo_Stack()
        \info = *Me\Undo_Stack()\info
        \Do = *Me\Undo_Stack()\Do
        \Undo = *Me\Undo_Stack()\Undo
        \Clear = *Me\Undo_Stack()\Clear
      EndWith
      DeleteElement(*Me\Undo_Stack())
    EndIf
    
  EndProcedure

  
  ;-----------------------------------------------------------------------------
  ; Redo
  ;-----------------------------------------------------------------------------
  Procedure Redo(*Me.CommandManager_t)
    MessageRequester("Redo Called","Stack Size ---> "+Str(ListSize(*Me\Redo_Stack())))
    If ListSize(*Me\Redo_Stack())>0
      *Me\Redo_Stack()\Do(*Me\Redo_Stack()\info)
      
      ; Before removing it we put the command in the Undo Stack
      AddElement(*Me\Undo_Stack())
      With *Me\Undo_Stack()
        \info = *Me\Redo_Stack()\info
        \Do = *Me\Redo_Stack()\do
        \Undo = *Me\Redo_Stack()\undo
        \Clear = *Me\Redo_Stack()\clear
      EndWith
      DeleteElement(*Me\Redo_Stack())
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Init
  ;-----------------------------------------------------------------------------
  Procedure Init()
    *manager = New()
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Term
  ;-----------------------------------------------------------------------------
  Procedure Term()
    If *manager : Delete(*manager) :EndIf
  EndProcedure

  
  ;-----------------------------------------------------------------------------
  ; Destructor
  ;-----------------------------------------------------------------------------
  Procedure Delete(*Me.CommandManager_t)
    ClearStructure(*Me,CommandManager_t)
    FreeMemory(*Me)
  EndProcedure

  
  ;-----------------------------------------------------------------------------
  ; Constructor
  ;-----------------------------------------------------------------------------
  Procedure New()
    Protected *Me.CommandManager_t = AllocateMemory(SizeOf(CommandManager_t))
    InitializeStructure(*Me,CommandManager_t)

    ProcedureReturn *Me
  EndProcedure

EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 71
; FirstLine = 59
; Folding = --
; EnableUnicode
; EnableXP
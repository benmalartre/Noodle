XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "Types.pbi"
XIncludeFile "../objects/Object3D.pbi"


; ============================================================================
; GRAPH BRANCH MODULE IMPLEMENTATION
; ============================================================================
Module Branch
  ;-----------------------------------------------------------------------------
  ; Recurse Node
  ;-----------------------------------------------------------------------------
  Procedure RecurseNodes(*Me.Branch_t,*current.Node::Node_t)
    If Not *current : ProcedureReturn : EndIf
  
    ForEach *current\inputs()
      If *current\inputs()\connected
        Protected *child.Node::Node_t = *current\inputs()\source\node
        AddElement(*Me\nodes())
        *Me\nodes() = *current\inputs()\source\node
        ;CArray::AppendPtr(*Me\nodes,*current\inputs()\source\node)
        RecurseNodes(*Me,*current\inputs()\source\node)
      EndIf
    Next
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Evaluate Port
  ;-----------------------------------------------------------------------------
  Procedure Build(*Me.Branch_t)
    ClearList(*Me\nodes())
    SelectElement(*Me\root\inputs(),*Me\id)
    Protected *port.NodePort::NodePort_t = *Me\root\inputs()
    If Not *port\connected Or *port\connexion = #Null : ProcedureReturn(void) : EndIf
    
    AddElement(*Me\nodes())
    *Me\nodes() = *port\source\node
  
    RecurseNodes(*Me,*port\source\node)
    Protected *current.Node::Node_t
    Protected current.Node::INode

    
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Update
  ;-----------------------------------------------------------------------------
  Procedure Evaluate(*Me.Branch_t)
    LastElement(*Me\nodes())
    Repeat 
     
      *current = *Me\nodes()
      If *current
        current = *current
        current\Evaluate()
      EndIf
      
      i-1
    Until Not PreviousElement(*Me\nodes())

  EndProcedure
  


  ; ----------------------------------------------------------------------------
  ;  Destructor
  ; ----------------------------------------------------------------------------
  Procedure Delete( *Me.Branch_t )
    
    FreeStructure(*Me)
 
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New()
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.Branch_t = AllocateStructure(Branch_t)
   
 
    
    ProcedureReturn( *Me)
    
  EndProcedure
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 72
; FirstLine = 47
; Folding = --
; EnableXP
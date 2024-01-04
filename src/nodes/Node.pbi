
DeclareModule Node
  Structure Node_t
    *VT
    dirty.b
    List *nodes.Node_t()
  EndStructure
  
  Interface INode
    Update()
  EndInterface
  
  Declare New()
  Declare Delete(*node.Node_t)
  Declare Update(*node.Node_t)
  Declare IsDirty(*node.Node_t)
EndDeclareModule

Module Node
  Procedure New()
    Protected *node.Node_t = AllocateStructure(Node_t)
    
    ProcedureReturn *node
  EndProcedure
  
  Procedure Delete(*node.Node_t)
    FreeStructure(*node)
  EndProcedure
  
  Procedure Update(*node.Node_t)
    Debug "Node Update Called..."
  EndProcedure
  
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 27
; Folding = -
; EnableXP
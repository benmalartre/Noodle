
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
    Protected *node.Node_t = AllocateMemory(SizeOf(Node_t))
    InitializeStructure(*node,Node_t)
    
    ProcedureReturn *node
  EndProcedure
  
  Procedure Delete(*node.Node_t)
    ClearStructure(*node,Node_t)
    FreeMemory(*node)
  EndProcedure
  
  Procedure Update(*node.Node_t)
    Debug "Node Update Called..."
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 15
; FirstLine = 1
; Folding = -
; EnableXP
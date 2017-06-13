XIncludeFile "../core/Operator.pbi"
XIncludeFile "../objects/Polymesh.pbi"
DeclareModule PushOp
  Structure PushOp_t Extends Operator::Operator_t
    *geom.Geometry::PolymeshGeometry_t
    
  EndStructure

    
EndDeclareModule

Module PushOp
  Procedure New(*obj.Polymesh::Polymesh_t)
    Protected *Me.PushOp_t = AllocateMemory(SizeOf(PushOp_t)
    InitializeStructure(*Me,PushOp_t)
  EndProcedure
  
  Procedure Init(*Me.PushOp_t)
    
  EndProcedure
  
  Procedure Evaluate(*Me.PushOp_t)
    Protected nbp = *Me\geom\
  EndProcedure

EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
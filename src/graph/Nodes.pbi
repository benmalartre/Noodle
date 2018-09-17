XIncludeFile "Types.pbi"

;====================================================================================
; NODES MODULE IMPLEMENTATION
;====================================================================================
Module Nodes
  Procedure DeleteNodeDescription(*desc.NodeDescription_t)
    FreeMemory(*desc)
  EndProcedure
  
  Procedure NewNodeDescription(name.s,category.s,constructor.i)
    Protected *desc.NodeDescription_t = AllocateMemory(SizeOf(NodeDescription_t))
    *desc\name = name
    *desc\label = Mid(name, 1, Len(name)-4) 
    
    *desc\category = category
    *desc\constructor = constructor
    ProcedureReturn *desc
  EndProcedure

  
  
  Procedure DeleteNodeCategory(*category.NodeCategory_t)
    ClearMap(*category\nodes())
    FreeMemory(*category)
  EndProcedure
  
  Procedure NewNodeCategory(label.s,*desc.NodeDescription_t)
    
    Protected *category.NodeCategory_t = AllocateMemory(SizeOf(NodeCategory_t))
    InitializeStructure(*category,NodeCategory_t)
    *category\label = label
    *category\nodes(*desc\name) = *desc
    ;*category\expended = #True
    ProcedureReturn *category
  EndProcedure
  
  Procedure AppendNode(*category.NodeCategory_t,*desc.NodeDescription_t)
    *category\nodes(*desc\name) = *desc
  EndProcedure



  Procedure AppendDescription(*desc.NodeDescription_t)
    
    ; Push Node Map
    Nodes::*graph_nodes(*desc\name) = *desc
    
    If *desc\category = "" : ProcedureReturn : EndIf
    ;Push Category Map
    Protected *category.NodeCategory_t = Nodes::*graph_nodes_category(*desc\category)
    If Not *category
      Nodes::*graph_nodes_category(*desc\category) = newNodeCategory(*desc\category,*desc)
    Else
      AppendNode(*category,*desc)
    EndIf
    
  EndProcedure
EndModule



;----------------------------------------------------------------------------
; Nodes
;----------------------------------------------------------------------------
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  IncludePath "..\nodes"
CompilerElse
  IncludePath "../nodes"
CompilerEndIf
  
  ; Hierarchy
  XIncludeFile "SceneNode.pbi"
  XIncludeFile "Object3DNode.pbi"
  XIncludeFile "ExecuteNode.pbi"

  ; Constants
  XIncludeFile "BooleanNode.pbi"
  XIncludeFile "IntegerNode.pbi"
  XIncludeFile "FloatNode.pbi"
  XIncludeFile "Vector3Node.pbi"
  XIncludeFile "QuaternionNode.pbi"
  XIncludeFile "StringNode.pbi"
  XIncludeFile "TimeNode.pbi"
  
  ; Arrays
  XIncludeFile "BuildArrayNode.pbi"
  XIncludeFile "BuildArrayFromConstantNode.pbi"
  XIncludeFile "BuildIndexArrayNode.pbi"
  XIncludeFile "ArraySubIndicesNode.pbi"
  XIncludeFile "MatrixArrayNode.pbi"
  
  ; Utils
  XIncludeFile "IfNode.pbi"
  XIncludeFile "AddNode.pbi"
  XIncludeFile "SubtractNode.pbi"
  XIncludeFile "ModuloNode.pbi"
  XIncludeFile "RandomNode.pbi"
  XIncludeFile "PerlinNode.pbi"
  XIncludeFile "FileExistsNode.pbi"
  
  XIncludeFile "MultiplyNode.pbi"
  XIncludeFile "MultiplyByScalarNode.pbi"
  XIncludeFile "DivideByScalarNode.pbi"
  XIncludeFile "TrigonometryNode.pbi"
  XIncludeFile "IntegerToFloatNode.pbi"
  XIncludeFile "FloatToVector3Node.pbi"
  XIncludeFile "FloatToQuaternionNode.pbi"
  XIncludeFile "LengthNode.pbi"
  XIncludeFile "NormalizeNode.pbi"
  XIncludeFile "RotateVectorNode.pbi"
  XIncludeFile "LinearInterpolateNode.pbi"
  XIncludeFile "Vector3ToFloatNode.pbi"
  XIncludeFile "SRTToMatrixNode.pbi"
  XIncludeFile "AxisAngleToRotationNode.pbi"
  
  ; Operators
  XIncludeFile "TreeNode.pbi"
  XIncludeFile "GetDataNode.pbi"
  XIncludeFile "SetDataNode.pbi"
  
  ; Generators
  XIncludeFile "AddPointNode.pbi"
  XIncludeFile "SampleGeometryNode.pbi"
  
  ; Topology
  XIncludeFile "PrimitiveMeshNode.pbi"
  XIncludeFile "TransformTopoNode.pbi"
  XIncludeFile "MergeTopoNode.pbi"
  XIncludeFile "MergeTopoArrayNode.pbi"  
  
  ; Alembic
  CompilerIf #USE_ALEMBIC 
    XIncludeFile "AlembicIPolymeshTopoNode.pbi"
    XIncludeFile "AlembicIPolymeshTopoSimpleNode.pbi"
    XIncludeFile "AlembicIPolymeshNode.pbi"
    XIncludeFile "AlembicIPointCloudNode.pbi"
  CompilerEndIf
  
;   
  IncludePath "../"
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 123
; FirstLine = 86
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode
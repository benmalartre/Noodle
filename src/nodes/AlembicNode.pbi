XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../objects/3DObject.pbi"
XIncludeFile "../libs/Booze.pbi"

; ==================================================================================================
; ADD NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AlembicNode
  Structure AlembicNode_t Extends Node::Node_t
    *obj.Object3D::Object3D_t
    *abc
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IAlembicNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Add",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AddNode_t)
  Declare Init(*node.AddNode_t)
  Declare Evaluate(*node.AddNode_t)
  Declare Terminate(*node.AddNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AddNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}

EndDeclareModule


  
  Interface IAlembicNode Extends Node::INode
    
  EndInterface
  
  Declare New(*obj.Object3D::Object3D_t,*abc)
  Declare Delete(*node.AlembicNode_t)
  Declare Update(*node.AlembicNode_t)
EndDeclareModule

Module AlembicNode
  Procedure New(*obj.Object3D::Object3D_t,*abc)
    Protected *node.AlembicNode_t = AllocateMemory(SizeOf(AlembicNode_t))
    InitializeStructure(*node,AlembicNode_t)
    *node\obj = *obj
    *node\abc = *abc
    ProcedureReturn *node
  EndProcedure
  
  Procedure Delete(*node.AlembicNode_t)
    Node::DEL(AlembicNode)
  EndProcedure
  
  Procedure Update(*node.AlembicNode_t)
    Debug "(((((((((((((((((((((((((( Node Update Called ))))))))))))))))))))))))))))))))))))))))))"
    Alembic::UpdateSample(*node\abc,Time::current_frame)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 3
; Folding = --
; EnableXP
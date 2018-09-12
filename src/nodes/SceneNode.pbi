XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../graph/Tree.pbi"
XIncludeFile "../objects/Root.pbi"

; ==================================================================================================
; SCENE NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SceneNode
  Structure SceneNode_t Extends Node::Node_t
    *object.Object3D::Object3D_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ISceneNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Scene",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.SceneNode_t)
  Declare Init(*node.SceneNode_t)
  Declare Evaluate(*node.SceneNode_t)
  Declare Terminate(*node.SceneNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("SceneNode","",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(SceneNode)
  EndDataSection
  

EndDeclareModule

; ==================================================================================================
; SCENE NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module SceneNode
Procedure AddObjectNode(*tree.Tree::Tree_t,*obj.Object3D::Object3D_t,*parent.Object3D::Object3D_t,x=0,y=0)
  
EndProcedure

Procedure RemoveObjectNode(*tree.Tree::Tree_t,*node.SceneNode_t)
  Debug "Remove Object Node : "+*node\object\fullname
  
    Tree::RemoveNode(*tree,*node)
EndProcedure

Procedure RecurseBuildTree(*tree.Tree::Tree_t,*obj.Object3D::Object3D_t,x,y)
  Protected nx, ny,i
  Protected nbc = ListSize(*obj\children())
  Protected color = RGB(30,120,60)
  Select *obj\type
    Case Object3D::#Object3D_Model
      color = RGB(30,120,60)
    Case Object3D::#Object3D_Polymesh
      color = RGB(60,150,80)
  EndSelect
  
  Protected *node.Node::Node_t = Tree::AddNode(*tree,"Object3DNode",x,y,100,50,color)
  *node\label = *obj\name
  
  Protected *scenenode.SceneNode_t = *node
  *scenenode\object = *obj
  

  Protected *child.Object3D::Object3D_t
  nx = x-200
  ny = y-(nbc/2)*100
  ForEach *obj\children()
    *child = *obj\children()
    Debug "Recurse Build Tree for "+*child\name
    RecurseBuildTree(*tree,*child,nx,ny)
    ny+100
  Next
  
EndProcedure

Procedure Setup( *node.SceneNode_t,*root.Root::Root_t )
  Protected x,y,w,h
  w=100
  h=20
  x=0
  y=0
  
  Protected i
  Protected *child.Object3D::Object3D_t
  x-200
  Protected nbc = ListSize(*root\children())
  y-(nbc/2)*100
  For i=0 To nbc-1
    SelectElement(*root\children(),i)
    *child = *root\children()
    RecurseBuildTree(*root\tree,*child,x,y)
  Next i
  
  
EndProcedure

Procedure Init(*node.SceneNode_t)
  Protected datatype.i = Attribute::#ATTR_TYPE_3DOBJECT
  Node::AddInputPort(*node,"Child1",datatype)
  Node::AddInputPort(*node,"New(Child1)...",Attribute::#ATTR_TYPE_NEW)
  *node\label = "Scene"
EndProcedure

Procedure RecurseNodes(*node.SceneNode_t,*current.Node::Node_t)

EndProcedure

Procedure EvaluatePort(*node.SceneNode_t,*port.NodePort::NodePort_t)

EndProcedure

Procedure Evaluate(*node.SceneNode_t)
  ForEach *node\inputs()
    EvaluatePort(*node,*node\inputs())
  Next
EndProcedure

Procedure Terminate(*node.SceneNode_t)

EndProcedure

; ============================================================================
; DESTRUCTOR
; ============================================================================
Procedure Delete(*node.SceneNode_t)
  FreeMemory(*node)
EndProcedure


; ============================================================================
;  CONSTRUCTORS
; ============================================================================
; ---[ Heap & stack]-----------------------------------------------------------------
Procedure.i New(*tree.Tree::Tree_t,type.s="Scene",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  
  ; ---[ Allocate Node Memory ]---------------------------------------------
  Protected *Me.SceneNode_t = AllocateMemory(SizeOf(SceneNode_t))
  
  ; ---[ Init Node]----------------------------------------------
  Node::INI(SceneNode,*tree,type,x,y,w,h,c)
  
  ; ---[ Return Node ]--------------------------------------------------------
  ProcedureReturn( *Me)
  
EndProcedure
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 102
; FirstLine = 94
; Folding = ---
; EnableXP
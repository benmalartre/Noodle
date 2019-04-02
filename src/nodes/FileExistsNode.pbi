XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; FILE EXISTS NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule FileExistsNode
  Structure FileExistsNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IFileExistsNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="FileExistsNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.FileExistsNode_t)
  Declare Init(*node.FileExistsNode_t)
  Declare Evaluate(*node.FileExistsNode_t)
  Declare Terminate(*node.FileExistsNode_t)
  
;   Declare ResolveReference(*node.FileExistsNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("FileExistsNode","Logic",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(FileExistsNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; FILE EXISTS NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module FileExistsNode
  
  Procedure Init(*node.FileExistsNode_t)
    Protected *input.NodePort::NodePort_t = Node::AddInputPort(*node,"FileName",Attribute::#ATTR_TYPE_STRING)
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Exists",Attribute::#ATTR_TYPE_BOOL)
    
    Node::PortAffectByName(*node, "FileName", "Exists")
    *node\label = "File Exists"
  EndProcedure
  
  Procedure Evaluate(*node.FileExistsNode_t)

    Protected *filenamePort.NodePort::NodePort_t = *node\Inputs()
    
    
    
    Protected *filenameArray.CArray::CArrayStr = NodePort::AcquireInputData(*filenamePort)

    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *outputArray.CArray::CArrayBool = *output\attribute\data
    
    Protected name.s = CArray::GetValueStr(*filenameArray,0)
    MessageRequester("FileExistsNode","Input : "+name)
    
    If FileSize(name)>0
      MessageRequester("FileExistsNode",name+" Exists!!!")
      CArray::SetValueB(*outputArray,0,#True)
    Else
      CArray::SetValueB(*outputArray,0,#False)
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.FileExistsNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.FileExistsNode_t)
    Node::DEL(FileExistsNode)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="FileExistsNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.FileExistsNode_t = AllocateMemory(SizeOf(FileExistsNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(FileExistsNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(FileExistsNode)
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 69
; FirstLine = 58
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode
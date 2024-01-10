XIncludeFile "../core/Commands.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../graph/Tree.pbi"
XIncludeFile "../objects/Object3D.pbi"

;-----------------------------------------------------------------------------
; Create Tree Command
;-----------------------------------------------------------------------------
DeclareModule CreateTreeCmd
  

  Structure CreateTreeCmd_t
    *object.Object3D::Object3D_t
  EndStructure
 
  
  Declare Do(*object.Object3D::Object3D_t)
  
EndDeclareModule

Module CreateTreeCmd

  Procedure hlpGetInfo(*object.Object3D::Object3D_t)
    Protected *info.CreateTreeCmd_t = AllocateStructure(CreateTreeCmd_t)
    *info\object = *object
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.CreateTreeCmd_t)
    FreeStructure(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.CreateTreeCmd_t)
    Protected *stack.Stack::Stack_t
    If Not *info\object\stack
      *info\object\stack = Stack::New()
      *stack = *info\object\stack
    Else
      *stack = *info\object\stack
    EndIf
    
    Protected *level.Stack::StackLevel_t = *stack\levels()
    AddElement(*level\nodes())
    Protected *tree.Tree::Tree_t = Tree::New(*info\object)
    *level\nodes() = *tree
  
    PostEvent(Globals::#EVENT_TREE_CREATED,#Null,#Null,#Null,*tree)
    
    MessageRequester("CreateTreeCmd","Create Tree On Selection Done!!!")

  EndProcedure
  
  Procedure hlpUndo(*info.CreateTreeCmd_t)
    
  EndProcedure
  
  Procedure Do(*object.Object3D::Object3D_t)
    ;*info = Cmd_CGraph_AddNode_GetInfo(*c,100+i*10,100+i*10,120,60,RGB(200,200,200))
    Protected *info = hlpGetInfo(*object)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  ;   OGraphTree_NodeInfos(*graph)
  ;   OGraphTree_DrawAllNodes(*graph)
    
    
  EndProcedure

EndModule

;-----------------------------------------------------------------------------
; Add Node Command
;-----------------------------------------------------------------------------
DeclareModule AddNodeCmd
  

  Structure AddNodeCmd_t
    *graph.Tree::Tree_t
    type.s
    x.i
    y.i
    w.i
    h.i
    c.i
    id.i
  EndStructure
  
  Declare Do(*graph.Tree::Tree_t,type.s,x.i,y.i,w.i,h.i,c.i)
  
EndDeclareModule

Module AddNodeCmd

  Procedure hlpGetInfo(*graph.Tree::Tree_t,type.s,x.i,y.i,w.i,h.i,c.i)
    Protected *info.AddNodeCmd_t = AllocateStructure(AddNodeCmd_t)
    *info\graph = *graph
    *info\type = type
    *info\x = x
    *info\y = y
    *info\w = w
    *info\h = h
    *info\c = c
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.AddNodeCmd_t)
    FreeStructure(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.AddNodeCmd_t)
    Protected id.i = Tree::AddNode(*info\graph,*info\type,*info\x,*info\y,*info\w,*info\h,*info\c)
  
    *info\id = id
  EndProcedure
  
  Procedure hlpUndo(*info.AddNodeCmd_t)
    Tree::RemoveNode(*info\graph,*info\id)
  EndProcedure
  
  Procedure Do(*graph.Tree::Tree_t,type.s,x.i,y.i,w.i,h.i,c.i)
    ;*info = Cmd_CGraph_AddNode_GetInfo(*c,100+i*10,100+i*10,120,60,RGB(200,200,200))
    Protected *info = hlpGetInfo(*graph,type,x,y,w,h,c)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  ;   OGraphTree_NodeInfos(*graph)
  ;   OGraphTree_DrawAllNodes(*graph)
    
    
  EndProcedure

EndModule


;----------------------------------------------
; Connect Nodes Command
;----------------------------------------------
DeclareModule ConnectNodesCmd
  Structure ConnectNodesCmd_t
    *tree.Tree::Tree_t
    *node.Node::Node_t
    *start.NodePort::NodePort_t
    *end.NodePort::NodePort_t
  EndStructure
  
  Declare Do(*Me.Tree::Tree_t,*parent.Node::Node_t,*start.NodePort::NodePort_t,*end.NodePort::NodePort_t)
EndDeclareModule

Module ConnectNodesCmd
  Procedure hlpGetInfo(*Me.Tree::Tree_t,*parent.Node::Node_t,*start.NodePort::NodePort_t,*end.NodePort::NodePort_t)
    Protected *info.ConnectNodesCmd_t = AllocateStructure(ConnectNodesCmd_t)
    *info\tree = *Me
    *info\node = *parent
    *info\start = *start
    *info\end = *end
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.ConnectNodesCmd_t)
    FreeStructure(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.ConnectNodesCmd_t)
    Tree::ConnectNodes(*info\tree,*info\node,*info\start,*info\end,#False)
  EndProcedure
  
  Procedure hlpUndo(*info.ConnectNodesCmd_t)
    Tree::DisconnectNodes(*info\tree,*info\node,*info\start,*info\end)
  EndProcedure
  
  Procedure Do(*Me.Tree::Tree_t,*parent.Node::Node_t,*start.NodePort::NodePort_t,*end.NodePort::NodePort_t)
    Protected *info = hlpGetInfo(*Me,*parent,*start,*end)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  EndProcedure
EndModule


;----------------------------------------------
; Implode Nodes Command
;----------------------------------------------
DeclareModule ImplodeNodesCmd
  Structure ImplodeNodesCmd_t
    *tree.Tree::Tree_t
    *nodes.CArray::CArrayPtr
    *parent.Node::Node_t
    *compound.CompoundNode::CompoundNode_t
  EndStructure
  
  Declare Do(*args.Args::Args_t)
  
EndDeclareModule

Module ImplodeNodesCmd

  Procedure hlpGetInfo(*tree.Tree::Tree_t,*nodes.CArray::CArrayPtr,*parent.Node::Node_t)
    Protected *info.ImplodeNodesCmd_t = AllocateStructure(ImplodeNodesCmd_t)
    *info\tree = *tree
    *info\nodes = CArray::New(Types::#TYPE_PTR)
    Protected i
    Protected *node.Node::Node_t
    If *nodes
      For i=0 To CArray::GetCount(*nodes)-1
        *node = CArray::GetValuePtr(*nodes,i)
        Debug *node\type
        CArray::AppendPtr(*info\nodes,*node)
      Next
    EndIf
    *info\parent = *parent
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.ImplodeNodesCmd_t)
   CArray::Delete(*info\nodes)
    FreeStructure(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.ImplodeNodesCmd_t)
    MessageRequester("ImplodeNodesCmd","hlpDo")
    *info\compound = Tree::ImplodeNodes(*info\tree,*info\nodes,*info\parent)
  EndProcedure
  
  Procedure hlpUndo(*info.ImplodeNodesCmd_t)
    Tree::ExplodeNode(*info\tree,*info\compound)
  EndProcedure
  
  Procedure Do(*args.Args::Args_t)
    Protected *tree.Tree::Tree_t = *args\args(0)\p
    Protected *nodes.CArray::CArrayPtr = *args\args(1)\p
    Protected *parent.Node::Node_t = *args\args(2)\p
    
    Protected *info = hlpGetInfo(*tree,*nodes,*parent)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
   
  EndProcedure
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 197
; FirstLine = 169
; Folding = -----
; EnableXP
; EnableUnicode
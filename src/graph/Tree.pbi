XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "Types.pbi"
XIncludeFile "../objects/Object3D.pbi"


; ============================================================================
; GRAPH TREE MODULE IMPLEMENTATION
; ============================================================================
Module Tree
  ;-----------------------------------------------------------------------------
  ; Get Branch Context
  ;-----------------------------------------------------------------------------
  Procedure GetBranchContext(*Me.Tree_t,*current.Node::Node_t)
    If Not *current : ProcedureReturn : EndIf
    
    ForEach *current\outputs()
      
    Next
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Recurse Node
  ;-----------------------------------------------------------------------------
  Procedure RecurseNodes(*Me.Tree_t,*current.Node::Node_t)
    If Not *current : ProcedureReturn : EndIf
    
    Protected *child.Node::Node_t
    
    If *current\class\name = "ExecuteNode"
      LastElement(*current\inputs())
      Repeat
         If *current\inputs()\connected
          *child = *current\inputs()\source\node
          AddElement(*Me\nodes())
          *Me\nodes() = *current\inputs()\source\node
          ;CArray::AppendPtr(*Me\nodes,*current\inputs()\source\node)
          RecurseNodes(*Me,*current\inputs()\source\node)
        EndIf
      Until Not PreviousElement(*current\inputs())
      
    Else
      
      ForEach *current\inputs()
        If *current\inputs()\connected
          *child = *current\inputs()\source\node
          AddElement(*Me\nodes())
          *Me\nodes() = *current\inputs()\source\node
          ;CArray::AppendPtr(*Me\nodes,*current\inputs()\source\node)
          RecurseNodes(*Me,*current\inputs()\source\node)
        EndIf
      Next
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Evaluate Port
  ;-----------------------------------------------------------------------------
  Procedure EvaluatePort(*Me.Tree_t,*port.NodePort::NodePort_t)
    ;recurse to leaf node
    If *port\class\name = "CompoundPortNode"
      Protected *c.CompoundNodePort::CompoundNodePort_t = *port
      *port = *c\port
      MessageRequester("Evaluate Port","CompoundNodePort")
    EndIf
    
    If Not *port\connected Or *port\connexion = #Null : ProcedureReturn(void) : EndIf
    
    If *Me\dirty = #True
  ;     CArray::SetCount(*Me\nodes,0)
  ;     CArray::AppendPtr(*Me\nodes,*port\source\node)
      ClearList(*Me\nodes())
      AddElement(*Me\nodes())
      *Me\nodes() = *port\source\node
    
      RecurseNodes(*Me,*port\source\node)
      Protected *current.Node::Node_t
      Protected current.Node::INode
      ;Protected i = CArray::GetCount(*Me\nodes)-1
      LastElement(*Me\nodes())
    EndIf
    
    Repeat 
     
      *current = *Me\nodes();CArray::GetValuePtr(*Me\nodes,i)
      
      If *current
        current = *current
        current\Evaluate()
      EndIf
      
      i-1
    Until Not PreviousElement(*Me\nodes())
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Update
  ;-----------------------------------------------------------------------------
  Procedure Evaluate(*Me.Tree_t)
    If *Me\current:Node::Update(*Me\current):EndIf
    
    ForEach *Me\root\inputs()
      EvaluatePort(*Me,*Me\root\inputs())
      ID+1
    Next
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Node
  ;-----------------------------------------------------------------------------
  Procedure.i AddNode(*Me.Tree_t,name.s,x.i,y.i,w.i,h.i,c.i)  
    Protected *node.Node::Node_t = Node::New(*Me,name.s,x,y,w,h,c)
   
    If Not *node
      Log::Message("[Tree]"+*Me\name+" : AddNode Failed with "+name)
    ElseIf name = "TreeNode" Or name = "LayerNode"
      Log::Message("[Tree]"+*Me\name+" : AddNode Succeeded ---> "+name+"(ROOT)")
    Else
      Graph::AttachListElement(*Me\current\nodes(),*node) 
      *Me\dirty = #True
      Log::Message("[Tree]"+*Me\name+" : AddNode Succeeded ---> "+name)
    EndIf
    
    PostEvent(Globals::#EVENT_GRAPH_CHANGED,EventWindow(),#Null)
    ProcedureReturn *node
    
  EndProcedure


  ;----------------------------------------------------------------------------------------
  ; Remove Node
  ;----------------------------------------------------------------------------------------
  Procedure RemoveNode(*Me.Tree_t,*other.Node::Node_t)
      
    Protected *node.Node::Node_t = #Null
    ForEach *Me\current\nodes()

      If *Me\current\nodes() = *other
        Graph::ExtractListElement(*Me\current\nodes(),*node)
        Break
      EndIf
    Next
    
    If *node
      DisconnectNode(*Me,*node)
      If *Me\current\class\name = "CompoundNode"
        ForEach *node\inputs()
          CompoundNode::RemoveExposedPort(*Me\current,*node\inputs())
        Next
        
        ForEach *node\outputs()
          CompoundNode::RemoveExposedPort(*Me\current,*node\outputs())
        Next
        
      EndIf
      
      Protected node.Node::INode = *node
      node\Delete()
      *Me\dirty = #True
    EndIf
    
  EndProcedure

  ;----------------------------------------------------------------------------------------
  ; Remove Last Node
  ;----------------------------------------------------------------------------------------
  Procedure RemoveLastNode(*Me.Tree_t)
    LastElement(*Me\current\nodes())
    
    Protected *node.Node::Node_t
    Graph::ExtractListElement(*Me\current\nodes(),*node)
    Node::Delete(*node)
  EndProcedure

  ;-----------------------------------------------------------------------------
  ;Connect/Disconnect Nodes
  ;-----------------------------------------------------------------------------
  Procedure ConnectNodes(*Me.Tree_t,*parent.Node::Node_t,*s.NodePort::NodePort_t,*e.NodePort::NodePort_t,interactive.b)
    
    If *s\io And *e\connected
      ProcedureReturn
    ElseIf *e\io And *s\connected
      ProcedureReturn
    EndIf
    
      
    Protected *connexion.Connexion::Connexion_t = Connexion::New(*s)
    
    *connexion\start = *s
    *connexion\end = *e
    
    ;Reverse connexion as it's from OUT to IN
    If *s\io
      *e\source = *s
      AddElement(*s\targets())
      *s\targets() = *e

      Connexion::Create(*connexion,*e,*s)
    Else
      *s\source = *e
      AddElement(*e\targets())
      *e\targets() = *s
      Connexion::Create(*connexion,*s,*e)
      
    EndIf
    
    Connexion::Connect(*connexion,*connexion\end,interactive.b)
    *connexion\end\connected = #True
    *connexion\start\connected = #True
    LastElement(*parent\connexions())
    Graph::AttachListElement(*parent\connexions(),*connexion)
    
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Disconnect Nodes
  ;-----------------------------------------------------------------------------
  Procedure DisconnectNodes(*Me.Tree_t,*parent.Node::Node_t,*start.NodePort::NodePort_t,*end.NodePort::NodePort_t)
    ; Check connexion
    If Not  *start\connected Or Not *end\connected : ProcedureReturn : EndIf
    Protected *cnx.Connexion::Connexion_t = *end\connexion
    
    Protected found.b = #False
    
    ; Remove connexion from List
    ForEach *parent\connexions()
      If *parent\connexions() = *cnx
        If *cnx\start\class\name = "CompoundNodePort"
          MessageRequester("Tree","Disconnect Nodes Connexion Statrt is CompoundNodePort")
        EndIf
        
        DeleteElement(*parent\connexions())
        found = #True
        Break
      EndIf
    Next
    
    If found
      ; Delete connexion
      Connexion::Delete(*cnx)
      *start\connected = #False
      *end\connected = #False
      
      ; Set Dirty Flag
      *Me\dirty = #True
    EndIf
    
  EndProcedure
  ;}

  ;-----------------------------------------------------------------------------
  ; Disconnect Node
  ;-----------------------------------------------------------------------------
  ;{
  Procedure DisconnectNode(*Me.Tree_t,*n.Node::Node_t)
    Protected *port.NodePort::NodePort_t
    Protected *connexion.Connexion::Connexion_t
  
    ForEach *Me\current\connexions()
      If *Me\current\connexions()\start\node = *n Or *Me\current\connexions()\end\node = *n
        *Me\current\connexions()\end\connected = #False
        *Me\current\connexions()\end\value = #Null
        Graph::ExtractListElement(*Me\current\connexions(),*connexion)
        FreeMemory(*connexion)
      EndIf
      
    Next
    
  
  EndProcedure
  ;}

  ;-----------------------------------------------------------------------------
  ; Delete Selected
  ;-----------------------------------------------------------------------------
  ;{
  Procedure DeleteSelected(*Me.Tree_t)
    Protected *node.Node::Node_t
    Protected id=0
    ForEach *Me\root\nodes()
      *node = *Me\root\nodes()
      If *node\selected And Not *node\type = "TreeNode"
        RemoveNode(*Me,id)
      EndIf
      id + 1
      
    Next
    
  EndProcedure
  ;}

  ;-----------------------------------------------------------------------------
  ; Implode Nodes
  ;-----------------------------------------------------------------------------
  Procedure ImplodeNodes(*tree.Tree_t,*nodes.CArray::CArrayPtr,*parent.Node::Node_t)
    
    
    If Not *tree
      Debug "[View Graph] Implode Nodes : Tree Invalid"
      ProcedureReturn
    EndIf
    
    
    Protected *compound.CompoundNode::CompoundNode_t = CompoundNode::New(*nodes,*parent,0,0,200,100,RGB(100,100,100))
  
    *tree\dirty = #True
    Protected *n.Node::Node_t
    Protected *extracted.Node::Node_t
    Protected *cnx.Connexion::Connexion_t
    Protected i.i
    
    ; Gather and Swap Nodes
    For i=0 To CArray::GetCount(*nodes)-1
      *n = CArray::GetValuePtr(*nodes,i)
      
      ForEach *parent\nodes()
        If *parent\nodes() = *n
          Graph::ExtractListElement(*parent\nodes(),*extracted)
          Break
        EndIf
      Next
;       Graph::AttachListElement(*compound\nodes(),*extracted)
;       *n\parent = *compound
    Next
    
    CompoundNode::CollectExposedInputPorts(*compound)
    CompoundNode::CollectExposedOutputPorts(*compound)
    
    
    ; Gather , Swap and Reconnect Connexions
    For i=0 To CArray::GetCount(*nodes)-1
      *n = CArray::GetValuePtr(*nodes,i)
      ForEach *n\inputs()
          If *n\inputs()\connected
            *cnx = *n\inputs()\connexion
            If Connexion::ShareParentNode(*cnx)
              Graph::AttachListElement(*compound\connexions(),*cnx)
              ForEach *parent\connexions()
                If *parent\connexions() = *cnx
                  Graph::ExtractListElement(*parent\connexions(),*cnx)
                  Break
                EndIf
              Next
            Else
              Debug "----------------------------------------- Create Compound -----------------------------------"
              Debug "Shared Connexion we have to Recreate It!!!"
            EndIf
            
          EndIf
        Next
      Next i
     
    
    
    Graph::AttachListElement(*parent\nodes(),*compound) 
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Explode Nodes
  ; ----------------------------------------------------------------------------
  Procedure ExplodeNode(*Me.Tree_t,*node.Node::Node_t)
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get All Data Providers
  ; ----------------------------------------------------------------------------
  Procedure GetDataProviders(*node.Node::Node_t,List *gets.Node::Node_t())
    ForEach *node\nodes()
      If *node\class\name = "GetDataNode"
        AddElement(*gets())
        *gets() = *node\nodes()
      EndIf
      ;Recurse
      GetDataProviders(*node\nodes(),*gets())
    Next
    
  EndProcedure
  
  Procedure GetAllDataProviders(*Me.Tree_t)
   ClearList(*Me\data_providers())
    GetDataProviders(*me\root,*Me\data_providers())
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get All Data Modifiers
  ; ----------------------------------------------------------------------------
  Procedure GetDataModifiers(*node.Node::Node_t,List *gets.Node::Node_t())
    ForEach *node\nodes()
      If *node\class\name = "SetDataNode"
        AddElement(*gets())
        *gets() = *node\nodes()
      EndIf
      ;Recurse
      GetDataModifiers(*node\nodes(),*gets())
    Next
    
  EndProcedure
  
  Procedure GetAllDataModifiers(*Me.Tree_t)
   ClearList(*Me\data_modifiers())
    GetDataProviders(*me\root,*Me\data_modifiers())
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Destructor
  ; ----------------------------------------------------------------------------
  Procedure Delete( *Me.Tree::Tree_t )

    ; ---[ Deallocate Underlying Arrays ]---------------------------------------
    Protected *root.Node::Node_t = *Me\root
    Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,#Null)
    ForEach *Me\root\connexions()
      Connexion::Delete(*Me\root\connexions())
    Next
    Protected *node.Node::Node_t
    ForEach *Me\root\nodes()
      *node = *Me\root\nodes()
      Node::Delete(*node)
    Next
    
    Node::Delete(*root)
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & Stack]----------------------------------------------------------
  Procedure.i New(*obj.Object3D::Object3D_t,name.s="Tree",context.i=Graph::#Graph_Context_Operator)
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.Tree_t = AllocateMemory( SizeOf(Tree_t) )
    
    ; ---[ Initialize Structures ]---------------------------------------------
    InitializeStructure(*Me,Tree_t)
    Object::INI(Tree)
    
    ; ---[ Init Object ]-------------------------------------------------------
    *Me\name = name
    
    ; ---[ Init Members ]------------------------------------------------------
    *Me\parent3dobject = *obj
    ;*Me\root = OGraphTree_AddNode(*Me,"RootNode",0,0,100,100,RGB(100,100,100))
    Select context
      Case Graph::#Graph_Context_Operator
        *Me\root = AddNode(*Me,"TreeNode",0,0,100,100,RGB(50,150,100))
      Case Graph::#Graph_Context_Hierarchy
        *Me\root = AddNode(*Me,"SceneNode",0,0,100,100,RGB(20,200,75))
      Case Graph::#Graph_Context_Shader
        *Me\root = AddNode(*Me,"LayerNode",0,0,100,100,RGB(180,120,20))
    EndSelect
    
    *Me\current = *Me\root
    
    ; ---[ Push Parent Object Stack ]------------------------------------------
    Stack::AddNode(*obj\stack,*Me,0)
    
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(Tree)

EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 29
; FirstLine = 22
; Folding = ----
; EnableUnicode
; EnableThread
; EnableXP
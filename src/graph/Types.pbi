XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ============================================================================
; GRAPH TYPES MODULE DECLARATION
; ============================================================================
DeclareModule Graph
  ; ==========================================================================
  ;  GLOBALS
  ; ==========================================================================
  Enumeration
    #Graph_Selection_None
    #Graph_Selection_Node
    #Graph_Selection_Connexion
    #Graph_Selection_Port
    #Graph_Selection_ExposeOutput
    #Graph_Selection_ExposeInput
    #Graph_Selection_Rectangle
    #Graph_Selection_Dive
    #Graph_Selection_Climb
  EndEnumeration
  
  #Graph_Background_Line = $555555
  #Graph_Background_Color = $666666
  #Graph_Compound_Border = 24
  #Graph_Compound_Color = $999999

  #Node_PortRadius = 5
  #Node_PortContour = #True
  #Node_PortShiftX = 0
  #Node_PortSpacing = 20
  #Node_DrawShadow = #True
  #Node_ShadowX = -8
  #Node_ShadowY = -8
  #Node_ShadowR = 16
  #Node_CornerRadius = 4
  #Node_TitleHeight = 7
  #Node_BorderUnselected = $66333333
  #Node_BorderSelected = $FFEEEEEE
  #Node_EditButtonRadius = 5
  #Node_EditButtonShiftX = 10
  #Node_EditButtonShiftY = 10
  #Node_EditButtonColor = $33999999
  
  #NODE_BORDER_WIDTH = 6
  #NODE_FONT_SIZE = 8
  #NODE_FONT_WIDTH = 32
  
  Enumeration 
    #Node_StateOK
    #Node_StateError
    #Node_StateInvalid
    #Node_StateUndefined
  EndEnumeration
  
  Enumeration
    #Graph_Context_Hierarchy
    #Graph_Context_Shader
    #Graph_Context_Modeling
    #Graph_Context_Compositing
    #Graph_Context_Operator  
    #Graph_Context_Simulation
  EndEnumeration
  
  Global Dim graph_context.s(6)
  graph_context(0) = "Hierarchy"
  graph_context(1) = "Shader"
  graph_context(2) = "Modeling"
  graph_context(3) = "Compositing"
  graph_context(4) = "Operator"
  graph_context(5) = "Simulation"
  
  Global GRAD_OUT = RGBA(0,0,0,0)
  Global GRAD_IN = RGBA(0,0,0,100)
  Global FONT_NODE
  Global FONT_PORT
  
  ; ==========================================================================
  ; DECLARE
  ; ==========================================================================

  Declare SwitchContext(id.i)
  
  ; ==========================================================================
  ; MACROS
  ; ==========================================================================
  Macro AttachListElement(p,e)
    AddElement(p)
    p = e
  EndMacro
  
  Macro ExtractListElement(p,e)
    e = p
    DeleteElement(p)
  EndMacro
  
  Macro AttachMapElement(m,k,e)
    AddMapElement(m,k)
    m = e
  EndMacro
  
  Macro ExtractMapElement(m,k,e)
    e = m
    DeleteMapElement(m,k)
  EndMacro
  
  Declare ResolveGetReference(*port)
  Declare ResolveSetReference(*port)
EndDeclareModule

; ============================================================================
; NODE PORT MODULE DECLARATION
; ============================================================================
DeclareModule NodePort
  UseModule Math
  UseModule Graph
  
    ;---------------------------------------------------------------------------
  ; Prototypes
  ;---------------------------------------------------------------------------
  Prototype ONCONNECTPORT(*port)
  Prototype ONDISCONNECTPORT(*port)

  ;---------------------------------------------------------------------------
  ; NodePort
  ;---------------------------------------------------------------------------
  Structure NodePort_t Extends Object::Object_t
    posx.i
    posy.i

    io.b
    connected.b
    connectioncallback.ONCONNECTPORT
    disconnectioncallback.ONCONNECTPORT
    selected.b
    id.i
    name.s
    decoratedname.s
    
    polymorph.b
    writable.b
    readonly.b
    datatype.i
    datacontext.i
    datastructure.i
    
    currenttype.i
    currentcontext.i
    currentstructure.i
    
    constant.b
    dirty.b
    
    ;Connexions
    *source.NodePort_t
    List *targets.NodePort_t()
    List *affects.NodePort_t()
    *connexion;.Connexion_t
    
    ;Parent Node
    *node       
    *attribute.Attribute::Attribute_t

    color.q

  EndStructure
  
  ;---------------------------------------------------------------------------
  ; Functions Declaration
  ;---------------------------------------------------------------------------
  Declare New(*parent,name.s,io.b=#False,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
  Declare Delete(*port.NodePort_t)
  Declare Echo(*port.NodePort_t)
  Declare GetColor(*port.NodePort_t)
  Declare Init(*port.NodePort_t, *geom.Geometry::Geometry_t)
  Declare InitFromReference(*port.NodePort_t,*attr.Attribute::Attribute_t)
  Declare.s AcquireReferenceData(*port.NodePort_t)
  Declare AcquireInputAttribute(*port.NodePort_t)
  Declare AcquireInputData(*port.NodePort_t)
  Declare AcquireOutputData(*port.NodePort_t)
  Declare Update(*port.NodePort_t,type.i=Attribute::#ATTR_TYPE_UNDEFINED,context.i=Attribute::#ATTR_CTXT_ANY,struct.i=Attribute::#ATTR_STRUCT_ANY)
  Declare GetDataType(*Me.NodePort_t)
  Declare IsAtomic(*Me.NodePort_t)
  Declare IsConnectable(*Me.NodePort_t,*Other.NodePort_t)
  Declare DecorateName(*Me.NodePort_t,width.i)
  Declare AcceptConnexion(*Me.NodePort_t,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
  Declare OnMessage(id.i, *up)
  Declare SetValue(*Me.NodePort_t,*value)
  Declare SetReference(*Me.NodePort_t,ref.s)
  Declare GetValue(*Me.NodePort_t)
  Declare GetReferenceSibling(*ref.NodePort_t)
  Declare SetupConnectionCallback(*Me.NodePort_t, *callback.ONCONNECTPORT)
  Declare SetupDisconnectionCallback(*Me.NodePort_t, *callback.ONCONNECTPORT)
  DataSection
    NodePortVT:
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; COMPOUND NODE PORT MODULE DECLARATION
; ============================================================================
DeclareModule CompoundNodePort
  ;---------------------------------------------------------------------------
  ; CompoundNodePort
  ;---------------------------------------------------------------------------

  Structure CompoundNodePort_t Extends NodePort::NodePort_t
    *port.NodePort::NodePort_t
  EndStructure
  
  Declare New(*parent,name.s,io.b)
  Declare NewFromPort(*port.NodePort::NodePort_t)
  Declare Delete(*Me.CompoundNodePort_t)
  Declare Init(*port.CompoundNodePort_t)
  DataSection
    CompoundNodePortVT:
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ============================================================================
; GRAPH CONNEXION MODULE DECLARATION
; ============================================================================
DeclareModule Connexion
  UseModule Math
  ;---------------------------------------------------------------------------
  ; GraphConnexion
  ;---------------------------------------------------------------------------
  Structure Connexion_t Extends Object::Object_t
    a.v2f32
    b.v2f32
    c.v2f32
    d.v2f32
    color.i
    connected.b
    samples.f
    dotted.b
    *start.NodePort::NodePort_t
    *end.NodePort::NodePort_t
  EndStructure
  
  #Graph_Bezier_DashedLines = #False
  #Graph_Bezier_Thickness = 2
  Global GRAPH_CONNEXION_LINEAR.b = #False
  Global GRAPH_CONNEXION_ACCURACY.f = 0.04
  Global GRAPH_CONNEXION_METHOD.i
  Global GRAPH_CONNEXION_ANTIALIASED.b = #False
  
  Macro DrawLine(x1,y1,x2,y2,color,antialiased)
    Select antialiased
      Case #True
        NormalL(x1,y1,x2,y2,color,#Graph_Bezier_Thickness)
      Case #False
        LineXY(x1,y1,x2,y2,color)
    EndSelect
  EndMacro

  
  Declare New(*p.NodePort::NodePort_t)
  Declare Create(*c.Connexion_t,*s.NodePort::NodePort_t,*e.NodePort::NodePort_t)
  Declare Init(*b.Connexion_t,color.i)
  Declare Delete(*c.Connexion_t)
  Declare ViewPosition(*c.Connexion_t)
  Declare Drag(*c.Connexion_t,x.i,y.i)
  Declare RecursePossible(*connexion.Connexion_t,datatype.i,datacontext.i,datastructure.i,way.b)
  Declare.b Possible(*c.Connexion_t,*p.NodePort::NodePort_t)
  Declare.b Connect(*c.Connexion_t,*p.NodePort::NodePort_t,interactive.b)
  Declare SetHead(*c.Connexion_t,*p.NodePort::NodePort_t)
  Declare ShareParentNode(*c.Connexion_t)
  Declare Draw(*c.Connexion_t,dotted.b)
  Declare Set(*c.Connexion_t,x1.i,y1.i,x2.i,y2.i)
  Declare Reuse(*c.Connexion_t)
EndDeclareModule

; ============================================================================
; NODE MODULE DECLARATION
; ============================================================================
DeclareModule Node
  ;---------------------------------------------------------------------------
  ; GraphNode
  ;---------------------------------------------------------------------------
  Structure Node_t Extends Object::Object_t
    ;Description
    name.s
    selected.b
    label.s
    type.s
    *parent.Node::Node_t
  
    ;Global infos 
    posx.l
    posy.l
    width.l
    height.l
    
    ;color
    red.i
    green.i
    blue.i
    color.i
    
    ;size
    step1.f
    step2.f
    
    ;state
    state.i
    errorstr.s
    leaf.b
    isroot.b
    dirty.b

    ; ports
    List *inputs.NodePort::NodePort_t()
    List *outputs.NodePort::NodePort_t()
  
    ; embedded nodes
    List *nodes.Node::Node_t()
    List *connexions.Connexion::Connexion_t()
    List *exposers.Connexion::Connexion_t()
    
    ;current port
    *port.NodePort::NodePort_t
  EndStructure
  
  Interface INode
    Evaluate()
    Delete()
    Init()
    Terminate()
    OnConnect(*port.NodePort::NodePort_t)
    OnDisconnect(*port.NodePort::NodePort_t)
  EndInterface
  
  ; ============================================================================
  ;  Macros
  ; ============================================================================
  Macro INI(cls,p,t,x,y,w,h,c)
    
    Object::INI(cls)
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\parent = p
    *Me\type = t
    *Me\posx = x
    *Me\posy = y
    *Me\width = w
    *Me\height = h
    *Me\color = c
    *Me\state = Graph::#Node_StateUndefined
    *Me\leaf = #True
    *Me\name = Globals::GUILLEMETS#cls#Globals::GUILLEMETS
    ; ---[ Initialize Structure ]-----------------------------------------------
    InitializeStructure(*Me,cls#_t)
  
    ; ---[ Init Node ]----------------------------------------------------------
    Init(*Me)

  EndMacro
  
  Macro DAT(cls)
     cls#VT:
     Data.i @Evaluate()
     Data.i @Delete()
     Data.i @Init()
     Data.i @Terminate()
     
     CompilerIf Defined(cls#::OnConnect, #PB_Procedure)
       Data.i cls#::@OnConnect()
     CompilerElse
       Data.i Node::@OnConnect()
     CompilerEndIf
     
     CompilerIf Defined(cls#::OnDisconnect, #PB_Procedure)
       Data.i cls#::@OnDisconnect()
     CompilerElse
       Data.i Node::@OnDisconnect()
     CompilerEndIf
     
  EndMacro
  
  Macro DEL(cls)
     
    ForEach *node\inputs()
      NodePort::Delete(*node\inputs())
    Next
    ForEach *node\outputs()
      NodePort::Delete(*node\outputs())
    Next

    ; ---[ Initialize Structure ]-----------------------------------------------
    ClearStructure(*node,cls#_t)
    FreeMemory(*node)
  
  EndMacro
  
  Prototype PGETDATAPROVIDERATTRIBUTE(*node.Node::Node_t)
  
  ;---------------------------------------------------------------------------
  ; Functions Declaration
  ;---------------------------------------------------------------------------
  Declare New(*tree.Node::Node_t,name.s="",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.Node_t)
  Declare Update(*node.Node_t)
  Declare.s GetName(*n.Node_t)
  Declare GetSize(*n.Node_t)
  Declare GetParent3DObject(*n.Node_t)
  Declare Draw(*n.Node_t)
  Declare ViewPosition(*n.Node_t,x.i,y.i)
  Declare ViewSize(*n.Node_t)
  Declare.b IsLeaf(*n.Node_t)
  Declare SetColor(*n.Node_t,r.i,g.i,b.i)
  Declare Drag(*n.Node_t,x.i,y.i)
  Declare.i IsUnderMouse(*n.Node_t,x.l,y.l)
  Declare.b InsideNode(*node.Node_t,*parent.Node_t)
  Declare.i Pick(*n.Node_t,x.l,y.l,connect.b=#False)
  Declare.b PickPort(*n.Node_t,*p.NodePort::NodePort_t,id.i,x.i,y.i)
  Declare.i GetPortByID(*n.Node_t,id.i)
  Declare.i GetPortByName(*n.Node_t,name.s)
  Declare.i SetInputPortID(*n.Node_t,*p.NodePort::NodePort_t,id.i = -1)
  Declare SetOutputPortID(*n.Node_t,*p.NodePort::NodePort_t,id.i = -1)
  Declare UpdatePorts(*n.Node_t,datatype.i,datacontext.i,datastructure.i)
  Declare AddInputPort(*n.Node_t,name.s,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
  Declare RemoveInputPort(*n.Node_t,id.i)
  Declare AddOutputPort(*n.Node_t,name.s,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
  Declare Inspect(*n.Node_t)
  Declare OnMessage(id.i,*up)
  Declare IsDirty(*n.Node_t)
  Declare UpdateDirty(*n.Node_t)
  Declare PortAffectByTime(*n.Node_t, affect.b, targetName.s)
  Declare PortAffectByName(*n.Node_t, sourceName.s, targetNames.s)
  Declare PortAffectByPort(*n.Node_t, *source.NodePort::NodePort_t, *target.NodePort::NodePort_t)
  Declare UpdateAffects(*n.Node_t)
  Declare SetClean(*n.Node_t)
  Declare OnConnect(*n.Node_t, *port.NodePort::NodePort_t)
  Declare OnDisconnect(*n.Node_t, *port.NodePort::NodePort_t)
  
  Global CLASS.Class::Class_t
  
  DataSection
    NodeVT:
  EndDataSection
  
EndDeclareModule

; ============================================================================
; COMPOUND NODE PORT MODULE DECLARATION
; ============================================================================
DeclareModule CompoundNode
  ;---------------------------------------------------------------------------
  ; CompoundNode
  ;---------------------------------------------------------------------------
  Structure CompoundNode_t Extends Node::Node_t
    introspected.b
    iexpanded.b
    iexpand.i
    oexpanded.b
    oexpand.i
    exposeinput.b
    exposeoutput.b
    
    *input_exposer.CompoundNodePort::CompoundNodePort_t
    *output_exposer.CompoundNodePort::CompoundNodePort_t
    
    List *exposed_inputs.CompoundNodePort::CompoundNodePort_t()
    List *exposed_outputs.CompoundNodePort::CompoundNodePort_t()
    
  ;   List *nodes.CGraphNode_t()
  ;   List *connexions.CGraphConnexion_t()
  EndStructure
  
  Declare New(*nodes.CArray::CArrayPtr,*parent.Node::Node_t,x.i,y.i,w.i,h.i,c.i)
  Declare Delete(*node.CompoundNode_t)
  
  Declare CollectExposedInputPorts(*Me.CompoundNode_t)
  Declare CollectExposedOutputPorts(*Me.CompoundNode_t)
  Declare Pick(*node.CompoundNode_t,gadgetID,mousex,mousey)
  Declare ExposePort(*node.CompoundNode_t,*port.NodePort::NodePort_t)
  Declare Draw(*Me.CompoundNode_t,gadgetID.i)
  Declare RemoveExposedPort(*node.CompoundNode_t,*port.NodePort::NodePort_t)
  Global CLASS.Class::Class_t
  
  DataSection
    CompoundNodeVT:
  EndDataSection
EndDeclareModule

    
; ============================================================================
;  GRAPH TREE MODULE DECLARARTION
; ============================================================================
DeclareModule Tree
  Structure Branch_t
    dirty.b
    List *nodes.Node::Node_t()
    List *filter_nodes.Node::Node_t()
    Map *unique_nodes.Node::Node_t()
  EndStructure
   
  Structure Tree_t Extends Node::Node_t
    ; ---[ Objects ]-----------------------------------------
    *root.Node::Node_t
    *current.Node::Node_t       ; Currently inspected node
    
    ; ---[ Lists ]-------------------------------------------
    List *all_nodes.Node::Node_t()
    List *filtered_nodes.Node::Node_t()
    List *all_connexions.Connexion::Connexion_t()
    List *data_providers.Node::Node_t()
    List *data_modifiers.Node::Node_t()
    List *all_branches.Branch_t()
    List *filtered_branches.Branch_t()
    Map *unique_nodes.Node::Node_t()
    
    ; ---[ current evaluate dbranch nodes ]------------------
    List *evaluation.NodePort::NodePort_t()
    
    ; ---[ callbacks ]---------------------------------------
    *on_delete.Signal::Signal_t
    *on_change.Signal::Signal_t
    
  EndStructure


  ; ----------------------------------------------------------------------------
  ;  FORWARD DECLARATION
  ; ----------------------------------------------------------------------------
  Declare New(*obj,name.s="Tree",context.i=Graph::#Graph_Context_Operator)
  Declare Delete(*tree.Tree_t)
  Declare RecurseNodes(*Me.Tree_t, *branch.Branch_t,*current.Node::Node_t, filter_dirty.b=#False)
  Declare EvaluateBranch(*Me.Tree_t, *branch.Branch_t)
  Declare Evaluate(*Me.Tree_t)
  Declare AddNode(*Me.Tree_t,name.s,x.i,y.i,w.i,h.i,c.i)  
  Declare RemoveNode(*Me.Tree_t,*other.Node::Node_t)
  Declare RemoveLastNode(*Me.Tree_t)
  Declare ConnectNodes(*Me.Tree_t,*parent.Node::Node_t,*s.NodePort::NodePort_t,*e.NodePort::NodePort_t,interactive.b)
  Declare DisconnectNodes(*Me.Tree_t,*parent.Node::Node_t,*start.NodePort::NodePort_t,*end.NodePort::NodePort_t)
  Declare DisconnectNode(*Me.Tree_t,*n.Node::Node_t)
  Declare DeleteSelected(*Me.Tree_t)
  Declare ImplodeNodes(*tree.Tree_t,*nodes.CArray::CArrayPtr,*parent.Node::Node_t)
  Declare ExplodeNode(*tree.Tree_t,*node.Node::Node_t)
  Declare GetAllDataProviders(*tree.Tree_t)
  Declare GetDataProviders(*current.Node::Node_t,List *gets.Node::Node_t())
  Declare GetAllDataModifiers(*tree.Tree::Tree_t)
  Declare GetDataModifiers(*current.Node::Node_t,List *sets.Node::Node_t())
  Declare.b CheckUniqueNode(*Me.Tree_t, *node.Node::Node_t)
  Declare.b CheckUniqueBranchNode(*Me.Tree_t, *branch.Branch_t, *node.Node::Node_t)
 
  DataSection
    TreeVT:
    Data.i @Evaluate()
    Data.i @Delete()
  EndDataSection
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

;====================================================================================
; NODES MODULE DECLARATION
;====================================================================================
DeclareModule Nodes
  ;----------------------------------------------------------------------------
  ; Node Description
  ;----------------------------------------------------------------------------
  Prototype PFNGRAPHNODECONSTRUCTOR(*tree.Node::Node_t,name.s,x.i,y.i,w.i,h.i,c.i)
  
  Structure NodeDescription_t
    name.s
    label.s
    category.s
    constructor.PFNGRAPHNODECONSTRUCTOR
    color_id.i
    selected.b
  EndStructure
  
  ;----------------------------------------------------------------------------
  ; Node Category
  ;----------------------------------------------------------------------------
  Structure NodeCategory_t
    label.s
    expended.b
    Map *nodes.NodeDescription_t()
  EndStructure
  
  ;----------------------------------------------------------------------------
  ; Nodes Global Management 
  ;----------------------------------------------------------------------------
  Global NewMap *graph_nodes.NodeDescription_t()
  Global NewMap *graph_nodes_category.NodeCategory_t()
  
  Declare NewNodeDescription(name.s,category.s,constructor.i)
  Declare DeleteNodeDescription(*desc.NodeDescription_t)
  
  Declare NewNodeCategory(label.s,*desc.NodeDescription_t)
  Declare DeleteNodeCategory(*category.NodeCategory_t)
  Declare AppendNode(*category.NodeCategory_t,*desc.NodeDescription_t)
  Declare AppendDescription(*desc.NodeDescription_t)
EndDeclareModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 349
; FirstLine = 341
; Folding = ---
; EnableXP
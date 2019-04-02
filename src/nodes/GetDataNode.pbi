XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule GetDataNode
  Structure GetDataNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IGetDataNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="GetData",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.GetDataNode_t)
  Declare Init(*node.GetDataNode_t)
  Declare Evaluate(*node.GetDataNode_t)
  Declare Terminate(*node.GetDataNode_t)
  
  Declare ResolveReference(*node.GetDataNode_t)
  Declare GetNodeAttribute(*node.GetDataNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("GetDataNode","Data",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(GetDataNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; FLOAT NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module GetDataNode
  UseModule Math
  Procedure ResolveReference(*node.GetDataNode_t)
    Protected *p.Object3D::Object3D_t = *node\parent3dobject
  
    Protected refname.s = NodePort::AcquireReferenceData(*node\inputs())
    If refname = "" : ProcedureReturn : EndIf
    
    Protected fields.i = CountString(refname, ".")+1
    Protected base.s = StringField(refname, 1,".")
    *node\label = refname
    Protected *output.NodePort::NodePort_t = Node::GetPortByName(*node,"Data")
    If base ="Self" Or base ="This"
      *node\attribute = *p\m_attributes(StringField(refname, 2,"."))
      If *node\attribute
        *output\currenttype = *node\attribute\datatype
        *output\currentcontext = *node\attribute\datacontext
        *output\currentstructure = *node\attribute\datastructure
        NodePort::Init(*output)
        *output\attribute = *node\attribute
        *output\dirty = #True
      EndIf
      
    Else
      Protected *o.Object3D::Object3D_t = Scene::GetObjectByName(Scene::*current_scene,base)
      If *o
        *node\attribute = *o\m_attributes(StringField(refname, 2,"."))
        If *node\attribute
          *output\currenttype = *node\attribute\datatype
          *output\currentcontext = *node\attribute\datacontext
          *output\currentstructure = *node\attribute\datastructure
          NodePort::Init(*output)
          *output\attribute = *node\attribute
          *output\dirty = #True
          MessageRequester("GET DATA NODE", "RESOLVE REFERENCE CALLED")
        EndIf
      Else
        MessageRequester("GetDataNode","Fail to Find Attribute"+base+StringField(refname, 2,"."))
      EndIf
      
    EndIf
   
    
  EndProcedure
  
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.GetDataNode_t)
    Node::AddInputPort(*node,"Reference",Attribute::#ATTR_TYPE_REFERENCE)
    Node::AddOutputPort(*node,"Data",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_REFERENCE)
    
    Node::PortAffectByName(*node, "Reference", "Data")
    Node::PortAffectByName(*node, "Reference", "Output")
    *node\label = "Get Data"
    ResolveReference(*node)
  EndProcedure
  
  Procedure Evaluate(*node.GetDataNode_t)

    Protected *ref.NodePort::NodePort_t = Node::GetPortByName(*node,"Reference")

    If Not *node\attribute Or *ref\refchanged : ResolveReference(*node) :*ref\refchanged = #False : EndIf
    
    If Not *node\attribute :Debug "[GetDataNode] Cannot resolve Reference" : ProcedureReturn : EndIf
    
    FirstElement(*node\outputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    
    If *output\attribute = #Null
      *output\currenttype = *node\attribute\datatype
      NodePort::Init(*output)
    EndIf
  
    If *output\attribute = #Null :Debug "[GetDataNode] Cannot resolve Output": ProcedureReturn : EndIf
  
    Select *node\attribute\datatype
     Case Attribute::#ATTR_TYPE_BOOL
        Protected bool.b
        Protected *bIn.CArray::CArrayBool,*bOut.CArray::CArrayBool
        *bOut = NodePort::AcquireOutputData(*output)
        *bIn = *node\attribute\data
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected int.i
        Protected *iIn.CArray::CArrayInt,*iOut.CArray::CArrayInt
        *iOut = NodePort::AcquireOutputData(*output)
        *iIn = *node\attribute\data
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected float.f
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
        *fOut = NodePort::AcquireOutputData(*output)
        *fIn = *node\attribute\data
        If CArray::GetCount(*fIn)
          CArray::Copy(*fOut,*fIn)
        EndIf
      Case Attribute::#ATTR_TYPE_COLOR
        Protected color.c4f32
        Protected *cIn.CArray::CArrayC4F32,*cOut.CArray::CArrayC4F32
        *cOut = NodePort::AcquireOutputData(*output)
        *cIn = *node\attribute\data
;         
;         Debug "[GetDataNode] Output Data Size : "+Str(CArray::GetCount(*cOut))
;         Debug "[GetDataNode] Attribute Data Size : "+Str(CArray::GetCount(*cIn))
        
        If CArray::GetCount(*cIn)
          ;vOut\SetCount(vIn\GetCount())
          CArray::Copy(*cOut,*cIn)
          ;CopyMemory(vIn\GetPtr(0),vOut\GetPtr(0),SizeOf(v)* vIn\GetCount())
;           Debug "Out Size --->W "+Str(CArray::GetCount(*cOut) * CArray::GetItemSize(*cOut))
        EndIf
  
    Case Attribute::#ATTR_TYPE_VECTOR3
        Protected v.v3f32
        Protected *vIn.CArray::CArrayV3F32,*vOut.CArray::CArrayV3F32
        *vOut = NodePort::AcquireOutputData(*output)
        *vIn = *node\attribute\data
;         Debug "[GetDataNode] Output Data Size : "+Str(CArray::GetCount(*vOut))
;         Debug "[GetDataNode] Attribute Data Size : "+Str(CArray::GetCount(*vIn))
;         
        If CArray::GetCount(*vIn)
          ;vOut\SetCount(vIn\GetCount())
          CArray::Copy(*vOut,*vIn)
          ;CopyMemory(vIn\GetPtr(0),vOut\GetPtr(0),SizeOf(v)* vIn\GetCount())
;           Debug "Out Size --->W "+Str(CArray::GetCount(*vOut) * CArray::GetItemSize(*vOut))
        EndIf
        
;       Default
;         Protected *tIn.CArray::CArrayT,*tOut.CArray::CArrayT
;         *tOut = *output\value
;         *tIn = *node\attribute\data
;         
;         If CArray::GetCount(*tIn)
;           CArray::Copy(*tOut,*tIn)
;         EndIf
        
      Case Attribute::#ATTR_TYPE_TOPOLOGY
        Protected *topo.Geometry::Topology_t
        Protected *tIn.CArray::CArrayPtr,*tOut.CArray::CArrayPtr
        *tOut = NodePort::AcquireOutputData(*output)
        *tIn = *node\attribute\data
        If CArray::GetCount(*tIn)
          ;vOut\SetCount(vIn\GetCount())
          CArray::Copy(*tOut,*tIn)
          ;CopyMemory(vIn\GetPtr(0),vOut\GetPtr(0),SizeOf(v)* vIn\GetCount())
;           Debug "Out Size --->W "+Str(CArray::GetCount(*vOut) * CArray::GetItemSize(*vOut))
        EndIf
        
        
    EndSelect
    ForEach *node\outputs()
      *node\outputs()\dirty = #False
    Next
    
  EndProcedure
  
  Procedure Terminate(*node.GetDataNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.GetDataNode_t)
    If *node\attribute
      Attribute::Delete(*node\attribute)
    EndIf
    Node::DEL(GetDataNode)
    
  EndProcedure
  
  Procedure OnMessage(id.i, *up)
  EndProcedure
  
  Procedure OnChange(*node.GetDataNode_t)
;     Protected *signal.Signal::Signal_t = *up
;     Protected *node.Object::Object_t = *signal\rcv_inst
;     If *node And *node\class\name = "GetDataNode": ResolveReference(*node) : EndIf
  EndProcedure
  
  Runtime Procedure GetNodeAttribute(*node.GetDataNode_t)
    ProcedureReturn *node\attribute
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="GetData",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.GetDataNode_t = AllocateMemory(SizeOf(GetDataNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(GetDataNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

  
  Class::DEF(GetDataNode)
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 190
; FirstLine = 161
; Folding = ---
; EnableThread
; EnableXP
; EnableUnicode
XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==============================================================================
; GET DATA NODE MODULE DECLARATION
; ==============================================================================
DeclareModule GetDataNode
  ; ----------------------------------------------------------------------------
  ;   STRUCTURE
  ; ----------------------------------------------------------------------------
  Structure GetDataNode_t Extends Node::Node_t
    custom.b
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
    need_compute.b
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;   INTERFACE
  ; ----------------------------------------------------------------------------
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
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("GetDataNode", "Data", @New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(GetDataNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==============================================================================
; GET DATA NODE MODULE IMPLEMENTATION
; ==============================================================================
Module GetDataNode
  UseModule Math
  Procedure ResolveReference(*node.GetDataNode_t)

    Protected refname.s
    Protected *p.Object3D::Object3D_t = Node::GetParent3DObject(*node)
    FirstElement(*Node\inputs())
    Define *location.NodePort::NodePort_t = *node\inputs()
    NextElement(*node\inputs())
    FirstElement(*node\outputs())
    Define *output.NodePort::NodePort_t = *node\outputs()
    If *location\connected
      *node\need_compute = #True
      refname = NodePort::AcquireReferenceData(*node\inputs())
      If refname = "" : ProcedureReturn : EndIf
      Define *locationArray.CArray::CArrayLocation = NodePort::AcquireInputData(*location)
      Define *geom.Geometry::Geometry_t = *locationArray\geometry
      Define *t.Transform::Transform_t = *locationArray\transform
      
      Define numLocations = CArray::GetCount(*locationArray)

      If *geom
        *node\attribute = *geom\m_attributes(refname)
        *output\currenttype = *node\attribute\datatype
        *output\currentcontext = *node\attribute\datacontext
        *output\currentstructure = *node\attribute\datastructure
        NodePort::Init(*output, *geom)
        *output\attribute\dirty = #True
      EndIf
            
;       If Not *node\attribute :
;         *node\attribute = Attribute::New(
;       
;       *node\attribute = *p\geom\m_attributes(StringField(refname, 2,"."))
;         If *node\attribute
;           *output\currenttype = *node\attribute\datatype
;           *output\currentcontext = *node\attribute\datacontext
;           *output\currentstructure = *node\attribute\datastructure
;           NodePort::Init(*output)
;           *output\attribute = *node\attribute
;           *output\dirty = #True
;         EndIf

    Else
      *node\need_compute = #False
      refname = NodePort::AcquireReferenceData(*node\inputs())
      If refname = "" : ProcedureReturn : EndIf
      
      Protected fields.i = CountString(refname, ".")+1
      Protected base.s = StringField(refname, 1,".")
      *node\label = refname
      If base ="Self" Or base ="This"
        *node\attribute = *p\geom\m_attributes(StringField(refname, 2,"."))
        If *node\attribute
          *output\currenttype = *node\attribute\datatype
          *output\currentcontext = *node\attribute\datacontext
          *output\currentstructure = *node\attribute\datastructure
          NodePort::Init(*output, *p\geom)
;           *output\attribute = *node\attribute
          *output\attribute\dirty = #True
        EndIf
      Else
        Protected *o.Object3D::Object3D_t = Scene::GetObjectByName(*scene,base)
        If *o
          *node\attribute = *o\geom\m_attributes(StringField(refname, 2,"."))
          If *node\attribute
            *output\currenttype = *node\attribute\datatype
            *output\currentcontext = *node\attribute\datacontext
            *output\currentstructure = *node\attribute\datastructure
            NodePort::Init(*output, *p\geom)
;             *output\attribute = *node\attribute
            *output\attribute\dirty = #True
          EndIf
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  ; ============================================================================
  ;   INIT
  ; ============================================================================
  Procedure Init(*node.GetDataNode_t)
    Node::AddInputPort(*node,"Source",Attribute::#ATTR_TYPE_LOCATION)
    Node::AddInputPort(*node,"Reference",Attribute::#ATTR_TYPE_REFERENCE)
    Node::AddOutputPort(*node,"Data",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_REFERENCE)
    
    Node::PortAffectByName(*node, "Reference", "Data")
    Node::PortAffectByName(*node, "Reference", "Output")
    *node\label = "Get Data"
    ResolveReference(*node)
  EndProcedure
  
  ; ============================================================================
  ;   EVALUATE
  ; ============================================================================
  Procedure Evaluate(*node.GetDataNode_t)
    FirstElement(*node\inputs())
    Protected *src.NodePort::NodePort_t = *node\inputs()
    NextElement(*node\inputs())
    Protected *refPort.NodePort::NodePort_t = *node\inputs()
    Protected *ref.Globals::Reference_t = *refPort\attribute\data

    If Not *node\attribute Or *ref\refchanged : ResolveReference(*node) :*ref\refchanged = #False : EndIf
    
    If Not *node\attribute : ProcedureReturn : EndIf
    
    FirstElement(*node\outputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    
  
    If *output\attribute = #Null : ProcedureReturn : EndIf
    If *node\need_compute And *src\connected
      Define *srcArray.CArray::CArrayLocation = NodePort::AcquireInputData(*src)
      Define *dstArray.CArray::CArrayT = NodePort::AcquireOutputData(*output)
      Define numSamples.i = CArray::GetCount(*srcArray)
      CArray::SetCount(*dstArray, numSamples)
      For i=0 To numSamples-1
        Location::GetValue(CArray::GetValue(*srcArray, i), *srcArray\geometry, *srcArray\transform, CArray::GetValue(*dstArray, i))
      Next
      
    Else
      Attribute::PassThrough(*node\attribute, *output\attribute)
    EndIf

    ForEach *node\outputs()
      *node\outputs()\attribute\dirty = #False
    Next
    
  EndProcedure
  
  ; ============================================================================
  ;   CALLBACKS
  ; ============================================================================
  Procedure OnChange(*node.GetDataNode_t)
;     Protected *signal.Signal::Signal_t = *up
;     Protected *node.Object::Object_t = *signal\rcv_inst
    If *node And *node\class\name = "GetDataNode": ResolveReference(*node) : EndIf
  EndProcedure
  
  Runtime Procedure GetNodeAttribute(*node.GetDataNode_t)
    ProcedureReturn *node\attribute
  EndProcedure
  
  ; ============================================================================
  ;   TERMINATE
  ; ============================================================================
  Procedure Terminate(*node.GetDataNode_t)
  
  EndProcedure
  
  ; ============================================================================
  ;   DESTRUCTOR
  ; ============================================================================
  Procedure Delete(*node.GetDataNode_t)
    If *node\attribute And *node\custom
      Attribute::Delete(*node\attribute)
    EndIf
    Node::DEL(GetDataNode)
    
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  ; ---[ Heap & stack]----------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="GetData",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]-----------------------------------------------
    Protected *Me.GetDataNode_t = AllocateStructure(GetDataNode_t)
    
    ; ---[ Init Node]-----------------------------------------------------------
    Node::INI(GetDataNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

  
  Class::DEF(GetDataNode)
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 225
; FirstLine = 198
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode
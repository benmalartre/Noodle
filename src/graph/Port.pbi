XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../objects/Topology.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../controls/Controls.pbi"
XIncludeFile "Types.pbi"

; ============================================================================
;  NODE PORT MODULE IMPLEMENTATION
; ============================================================================
Module NodePort
  ;------------------------------------------------------------
  ; Constructor
  ;------------------------------------------------------------
  Procedure New(*parent,name.s,io.b=#False,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
    Protected *Me.NodePort_t = AllocateStructure(NodePort_t)
    Object::INI(NodePort)
    *Me\node = *parent
    *Me\name = name
    *Me\datatype = datatype
    *Me\currenttype = datatype
    GetDataType(*Me)
    *Me\datacontext = datacontext
    *Me\currentcontext = datacontext
    *Me\datastructure = datastructure
    *Me\currentstructure = datastructure
    *Me\io = io
  
    Init(*Me,#Null)
  
    *Me\connected = #False
    *Me\selected = #False
      
    ProcedureReturn *Me
  EndProcedure
  
  ;------------------------------------------------------------
  ; Destructor
  ;------------------------------------------------------------
  Procedure Delete(*Me.NodePort::NodePort_t)
    If *Me\attribute And Not *Me\attribute\atomic: Attribute::Delete(*Me\attribute) : EndIf
    Object::TERM(NodePort)
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Echo Port
  ;-----------------------------------------------------------------------------
  Procedure Echo(*port.NodePort_t)
    Protected datatype.s,datastructure.s,datacontext.s
    Select *port\currenttype
      Case Attribute::#ATTR_TYPE_BOOL
        datatype = "[Boolean]"
      Case Attribute::#ATTR_TYPE_INTEGER
        datatype = "[Long]"
      Case Attribute::#ATTR_TYPE_LONG
        datatype = "[Integer]"
      Case Attribute::#ATTR_TYPE_ENUM
        datatype = "[Enum]"
      Case Attribute::#ATTR_TYPE_COLOR
        datatype = "[Color]"
      Case Attribute::#ATTR_TYPE_EXECUTE
        datatype = "[Execution]"
      Case Attribute::#ATTR_TYPE_FLOAT
        datatype = "[Float]"
      Case Attribute::#ATTR_TYPE_VECTOR2
        datatype = "[Vector2]"
      Case Attribute::#ATTR_TYPE_VECTOR3
        datatype = "[Vector3]"
      Case Attribute::#ATTR_TYPE_AUDIO
        datatype = "[Audio]"
      Case Attribute::#ATTR_TYPE_FILE
        datatype = "[File]"
      Case Attribute::#ATTR_TYPE_UNDEFINED
        datatype = "[Undefined]"
    EndSelect
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Get Color
  ;-----------------------------------------------------------------------------
  Procedure.i GetColor(*port.NodePort_t)
    Select *port\currenttype
      Case Attribute::#ATTR_TYPE_UNDEFINED
        *port\color = Attribute::#ATTR_COLOR_UNDEFINED
      Case Attribute::#ATTR_TYPE_BOOL
        *port\color = Attribute::#ATTR_COLOR_BOOL
      Case Attribute::#ATTR_TYPE_FLOAT
        *port\color = Attribute::#ATTR_COLOR_FLOAT
      Case Attribute::#ATTR_TYPE_INTEGER
        *port\color =  Attribute::#ATTR_COLOR_INTEGER
      Case Attribute::#ATTR_TYPE_ENUM
        *port\color =  Attribute::#ATTR_COLOR_ENUM
      Case Attribute::#ATTR_TYPE_COLOR
        *port\color =  Attribute::#ATTR_COLOR_COLOR
      Case Attribute::#ATTR_TYPE_MATRIX3
        *port\color = Attribute::#ATTR_COLOR_MATRIX3
      Case Attribute::#ATTR_TYPE_MATRIX4
        *port\color = Attribute::#ATTR_COLOR_MATRIX4
      Case Attribute::#ATTR_TYPE_QUATERNION
        *port\color =  Attribute::#ATTR_COLOR_QUATERNION
      Case Attribute::#ATTR_TYPE_ROTATION
        *port\color =  Attribute::#ATTR_COLOR_ROTATION
      Case Attribute::#ATTR_TYPE_STRING
        *port\color =  Attribute::#ATTR_COLOR_STRING
      Case Attribute::#ATTR_TYPE_TOPOLOGY
        *port\color =  Attribute::#ATTR_COLOR_TOPOLOGY
      Case Attribute::#ATTR_TYPE_GEOMETRY
        *port\color =  Attribute::#ATTR_COLOR_GEOMETRY
      Case Attribute::#ATTR_TYPE_LOCATION
        *port\color =  Attribute::#ATTR_COLOR_LOCATION
      Case Attribute::#ATTR_TYPE_VECTOR2
        *port\color =  Attribute::#ATTR_COLOR_VECTOR2
      Case Attribute::#ATTR_TYPE_VECTOR3
        *port\color =  Attribute::#ATTR_COLOR_VECTOR3
      Case Attribute::#ATTR_TYPE_VECTOR4
        *port\color =  Attribute::#ATTR_COLOR_VECTOR4
      Case Attribute::#ATTR_TYPE_EXECUTE
        *port\color = Attribute::#ATTR_COLOR_EXECUTE
      Case Attribute::#ATTR_TYPE_REFERENCE
        *port\color = Attribute::#ATTR_COLOR_REFERENCE
      Case Attribute::#ATTR_TYPE_3DOBJECT
        *port\color = Attribute::#ATTR_COLOR_3DOBJECT
      Case Attribute::#ATTR_TYPE_TEXTURE
        *port\color = Attribute::#ATTR_COLOR_TEXTURE
      Case Attribute::#ATTR_TYPE_SHADER
        *port\color = Attribute::#ATTR_COLOR_SHADER
      Case Attribute::#ATTR_TYPE_AUDIO
        *port\color = Attribute::#ATTR_COLOR_AUDIO
      Case Attribute::#ATTR_TYPE_FILE
        *port\color = Attribute::#ATTR_COLOR_FILE
    EndSelect
    
    ProcedureReturn *port\color
  EndProcedure


  ;-----------------------------------------------------------------------------
  ; Init
  ;-----------------------------------------------------------------------------
  Procedure Init(*port.NodePort_t, *geom.Geometry::Geometry_t)
    If Not *geom
      Define *object3D.Object3D::Object3D_t = Node::GetParent3DObject(*port\node)
      *geom = *object3D\geom
    EndIf
    
  ;   Select *port\currentstructure
    Select *port\currenttype
      Case Attribute::#ATTR_TYPE_UNDEFINED
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, #Null, #False, *port\readonly, *port\constant, *port\writable,#False)
        
      Case Attribute::#ATTR_TYPE_BOOL
        Protected *bVal.CArray::CArrayBool = CArray::New(Types::#TYPE_BOOL)
        CArray::AppendB(*bVal,#False)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *bVal, #False, *port\readonly, *port\constant, *port\writable,#True)

      Case Attribute::#ATTR_TYPE_FLOAT
        Protected *fVal.CArray::CArrayFloat = CArray::New(Types::#TYPE_FLOAT)
        CArray::AppendF(*fVal,0)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *fVal, #False, *port\readonly, *port\constant, *port\writable, #True)

      Case Attribute::#ATTR_TYPE_LONG
        Protected *lVal.CArray::CArrayLong = CArray::New(Types::#TYPE_LONG)
        CArray::AppendL(*lVal,0)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *lVal, #False, *port\readonly, *port\constant, *port\writable,#True)

      Case Attribute::#ATTR_TYPE_INTEGER
        Protected *iVal.CArray::CArrayInt = CArray::New(Types::#TYPE_INT)
        CArray::AppendI(*iVal,0)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *iVal, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_ENUM
        Protected *eVal.CArray::CArrayStr = CArray::New(Types::#TYPE_STR)
        CArray::AppendStr(*eVal,"SALUT ! CA vA ??")
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *eVal, #False, *port\readonly, *port\constant, *port\writable,#True)

      Case Attribute::#ATTR_TYPE_VECTOR2
        Protected *vVal2.CArray::CArrayV2F32 = CArray::New(Types::#TYPE_V2F32)
        Protected v2.v2f32
        Vector2::Set(v2,0,0)
        CArray::Append(*vVal2,v2)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *vVal2, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected *vVal3.CArray::CArrayV3F32 = CArray::New(Types::#TYPE_V3F32)
        Protected v3.v3f32
        Vector3::Set(v3,0,0,0)
        CArray::Append(*vVal3,v3)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *vVal3, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_VECTOR4
        Protected *vVal4.CArray::CArrayC4F32 = CArray::New(Types::#TYPE_V4F32)
        Protected v4.c4f32
        Color::Set(v4,0,0,0,0)
        CArray::Append(*vVal4,v4)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *vVal4, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_QUATERNION
        Protected *qVal4.CArray::CArrayQ4F32 = CArray::New(Types::#TYPE_Q4F32)
        Protected q4.q4f32
        Quaternion::SetIdentity(q4)
        CArray::Append(*qVal4,q4)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *qVal4, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_MATRIX3
        Protected *mVal3.CArray::CArrayM3F32 = CArray::New(Types::#TYPE_M3F32)
        Protected m3.m3f32
        Matrix3::SetIdentity(m3)
        CArray::Append(*mVal3,m3)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *mVal3, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_MATRIX4

        Protected *mVal4.CArray::CArrayM4F32 = CArray::New(Types::#TYPE_M4F32)
        Protected m4.m4f32
        Matrix4::SetIdentity(m4)
        CArray::Append(*mVal4,m4)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *mVal4, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_COLOR
        Protected *cVal.CArray::CArrayC4F32 = CArray::New(Types::#TYPE_C4F32)
        Protected c.c4f32
        Color::Set(c,0,0,0,1)
        CArray::Append(*cVal,c)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *cVal, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_STRING
        Protected *sVal.CArray::CArrayStr = CArray::New(Types::#TYPE_STR)
        Protected s.s = ""
        CArray::AppendStr(*sVal,s)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *sVal, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_REFERENCE
        ; /!\ there is a leak here
        Protected *ref.Globals::Reference_t = AllocateStructure(Globals::Reference_t)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *ref, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_TOPOLOGY
        Protected *data.CArray::CArrayPtr = CArray::New(Types::#TYPE_PTR)
        Protected *topo.Geometry::Topology_t = Topology::New()
        CArray::AppendPtr(*data,*topo)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *data, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_LOCATION
        Define *object3D.Object3D::Object3D_t = Geometry::GetParentObject3D(*geom)
        *loc.CArray::CArrayLocation = CArray::New(Types::#TYPE_LOCATION)
        *loc\geometry = *geom
        *loc\geometry = *object3D\globalT
        
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *loc, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_GEOMETRY
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *geom, #False, *port\readonly, *port\constant, *port\writable,#False)
        
      Case Attribute::#ATTR_TYPE_AUDIO
        *audio.CArray::CArrayPtr = CArray::New(Types::#TYPE_PTR)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *audio, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_FILE
        *file.CArray::CArrayStr = CArray::New(Types::#TYPE_STR)
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, *file, #False, *port\readonly, *port\constant, *port\writable,#True)
       
      Case Attribute::#ATTR_TYPE_3DOBJECT
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, #Null, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_EXECUTE
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, #Null, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Case Attribute::#ATTR_TYPE_NEW
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, #Null, #False, *port\readonly, *port\constant, *port\writable,#True)
        
      Default
        *port\attribute = Attribute::New(*port\node,*port\name, *port\currenttype, *port\currentstructure, *port\currentcontext, #Null, #False, *port\readonly, *port\constant, *port\writable,#True)
        
    EndSelect
    
    If *port\io = #False And *port\attribute
      *port\attribute\dirty = #True
    EndIf
    
    GetColor(*port)
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Init From Reference
  ;-----------------------------------------------------------------------------
  Procedure InitFromReference(*port.NodePort_t,*attr.Attribute::Attribute_t)
    *port\currentcontext = *attr\datacontext
    *port\currentstructure = *attr\datastructure
    *port\currenttype = *attr\datatype
    *port\attribute = *attr
    GetColor(*port)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Init From Name
  ;-----------------------------------------------------------------------------
  Procedure InitFromName(*port.NodePort_t,name.s)
    If *port\connected
      Define *locationArray.CArray::CArrayLocation = NodePort::AcquireInputData(*port)
      Define *geom.Geometry::Geometry_t = *locationArray\geometry
      Define *t.Transform::Transform_t = *locationArray\transform
      Define numLocations = CARray::GetCount(*locationArray)
      If numLocations > 0
        Define *location.Geometry::Location_t = CArray::GetValuePtr(*locationArray, 0)
        If *location
;           *port\currentcontext = *attr\datacontext
;           *port\currentstructure = *attr\datastructure
;           *port\currenttype = *attr\datatype
;           *port\attribute = *attr
;            GetColor(*port)
        EndIf
      EndIf
    EndIf

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Get Reference Sibling Port (datas)
  ;-----------------------------------------------------------------------------
  Procedure GetReferenceSibling(*ref.NodePort_t)
    Define *node.Node::Node_t = *ref\node
    If *ref\currenttype = Attribute::#ATTR_TYPE_REFERENCE
      If Not *ref\io
        ForEach(*node\inputs())
          If *node\inputs() = *ref
            PreviousElement(*node\inputs())
            ProcedureReturn *node\inputs()
          EndIf
        Next
      Else
        ForEach(*node\outputs())
          If *node\outputs() = *ref
            PreviousElement(*node\outputs())
            ProcedureReturn *node\outputs()
          EndIf
        Next
      EndIf
    Else
      If Not *ref\io
        ForEach(*node\inputs())
          If *node\inputs() = *ref
            NextElement(*node\inputs())
            ProcedureReturn *node\inputs()
          EndIf
        Next
      Else
        ForEach(*node\outputs())
          If *node\outputs() = *ref
            NextElement(*node\outputs())
            ProcedureReturn *node\outputs()
          EndIf
        Next
      EndIf
    EndIf
    
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Acquire Reference Data
  ;-----------------------------------------------------------------------------
  Procedure.s AcquireReferenceData(*port.NodePort_t)
    If *port\currenttype = Attribute::#ATTR_TYPE_REFERENCE
      Define *sibling.NodePort_t = GetReferenceSibling(*port)

      Protected *data
      Protected *ref.Globals::Reference_t = *port\attribute\data
      Protected *srcRef.Globals::Reference_t = #Null
      If *port\connected : *srcRef = *port\source\attribute\data : EndIf
      If *srcRef
        *ref\daisyreference = *srcRef\reference+"."+*ref\reference
      Else
        *ref\daisyreference = *ref\reference
      EndIf
        
      If *sibling\connected
        *data = *sibling\source\attribute
        
      Else
        *data = *sibling\attribute
        If Not *data : Init(*sibling, #Null) : *data = *port\attribute: EndIf
        
      EndIf
      ProcedureReturn *ref\daisyreference  
    EndIf
    
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Acquire Input Data
  ;-----------------------------------------------------------------------------
  Procedure AcquireInputData(*port.NodePort_t)
    
    Protected *data.CArray::CArrayT
    Select *port\currentstructure
      Case Attribute::#ATTR_STRUCT_ARRAY
        ; Case STRUCT_ARRAY
        ;-----------------------------------------------------------------------
        If *port\connected
          *data = *port\source\attribute\data
        Else
          *data = *port\attribute\data
          If Not *data : Init(*port, #Null) : *data = *port\attribute\data: EndIf
          *port\attribute\dirty = #False
        EndIf
        
      Case Attribute::#ATTR_STRUCT_SINGLE
        ; Case STRUCT_SINGLE
        ;-----------------------------------------------------------------------
        If *port\connected
          *data = *port\source\attribute\data
        Else
          *data = *port\attribute\data
          If Not *data : Init(*port, #Null) : *data = *port\attribute\data: EndIf
          *port\attribute\dirty = #False
        EndIf

      Case Attribute::#ATTR_STRUCT_ANY
        ; Case STRUCT_ANY
        ;-----------------------------------------------------------------------
        If *port\connected
          *data = *port\source\attribute\data
        Else
        
          *data = *port\attribute\data
          If Not *data : Init(*port, #Null) : *data = *port\attribute\data: EndIf
          *port\attribute\dirty = #False
        EndIf
    EndSelect
    
    If *data
      If CArray::GetCount(*data) <= 1
        *port\constant = #True
      Else
        *port\constant = #False
      EndIf
      ProcedureReturn *data
    EndIf
         
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Acquire Input Attribute
  ;-----------------------------------------------------------------------------
  Procedure AcquireInputAttribute(*port.NodePort_t)
    If *port\connected
      ProcedureReturn *port\source\attribute
    Else
      ProcedureReturn *port\attribute
    EndIf
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Acquire Output Data
  ;-----------------------------------------------------------------------------
  Procedure AcquireOutputData(*port.NodePort_t)
    
    Protected *data.CArray::CArrayT
    Select *port\currentstructure
      Case Attribute::#ATTR_STRUCT_ARRAY
        ; Case STRUCT_ARRAY
        ;-----------------------------------------------------------------------
        *data = *port\attribute\data
        If Not *data : Init(*port, #Null) : *data = *port\attribute\data: EndIf
        *port\attribute\dirty = #False
        
      Case Attribute::#ATTR_STRUCT_SINGLE
        ; Case STRUCT_SINGLE
        ;-----------------------------------------------------------------------
        *data = *port\attribute\data
        If Not *data : Init(*port,#Null) : *data = *port\attribute\data: EndIf
        *port\attribute\dirty = #False
        
      Case Attribute::#ATTR_STRUCT_ANY
        ; Case STRUCT_ANY
        ;-----------------------------------------------------------------------
        *data = *port\attribute\data
        If Not *data : Init(*port, #Null) : *data = *port\attribute\data: EndIf
        *port\attribute\dirty = #False

    EndSelect
    
    If *data
      If CArray::GetCount(*data) <= 1
        *port\constant = #True
      Else
        *port\constant = #False
      EndIf
      ProcedureReturn *data
    EndIf

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Acquire Output Attribute
  ;-----------------------------------------------------------------------------
  Procedure AcquireOutputAttribute(*port.NodePort_t)
    ProcedureReturn *port\attribute
  EndProcedure


  ;-----------------------------------------------------------------------------
  ; Update
  ;-----------------------------------------------------------------------------
  Procedure Update(*port.NodePort_t,type.i=Attribute::#ATTR_TYPE_UNDEFINED,context.i=Attribute::#ATTR_CTXT_ANY,struct.i=Attribute::#ATTR_STRUCT_ANY)
    ;Delete Old Data
    If *port\attribute\data : 
      Protected *v.CArray::CArrayT = *port\attribute\data
      CArray::Delete(*v)
      *port\attribute\data = #Null
    EndIf
  
    ; Create New Data
    *port\currenttype = type
    *port\currentcontext = context
    *port\currentstructure = struct
  
    Init(*port, #Null)
    
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Get Data Type
  ;-----------------------------------------------------------------------------
  Procedure GetDataType(*Me.NodePort_t)
    Protected nbDataType.i
    
    ; Hierarchy context
    If *Me\datatype = Attribute::#ATTR_TYPE_3DOBJECT : *Me\currenttype = Attribute::#ATTR_TYPE_3DOBJECT : ProcedureReturn
    ; Shading context  
    ElseIf *Me\datatype = Attribute::#ATTR_TYPE_SHADER : *Me\currenttype = Attribute::#ATTR_TYPE_SHADER : ProcedureReturn
    ElseIf *Me\datatype = Attribute::#ATTR_TYPE_FRAMEBUFFER : *Me\currenttype = Attribute::#ATTR_TYPE_FRAMEBUFFER : ProcedureReturn
      ElseIf *Me\datatype = Attribute::#ATTR_TYPE_TEXTURE: *Me\currenttype = Attribute::#ATTR_TYPE_TEXTURE : ProcedureReturn
    ; Operator context
    Else
      If *Me\datatype & Attribute::#ATTR_TYPE_UNDEFINED : *Me\currenttype = Attribute::#ATTR_TYPE_UNDEFINED : ProcedureReturn : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_NEW : *Me\currenttype = Attribute::#ATTR_TYPE_NEW : ProcedureReturn : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_REFERENCE : *Me\currenttype = Attribute::#ATTR_TYPE_REFERENCE : ProcedureReturn : EndIf
      
      If *Me\datatype & Attribute::#ATTR_TYPE_BOOL : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_LONG : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_INTEGER : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_ENUM : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_FLOAT : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_VECTOR2 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_VECTOR3 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_VECTOR4 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_COLOR : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_ROTATION : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_QUATERNION : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_MATRIX3 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_MATRIX4 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_STRING : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_SHAPE : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_TOPOLOGY : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_GEOMETRY : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_LOCATION : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_EXECUTE : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_FILE : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_AUDIO : nbDataType+1 : EndIf
      
      If nbDataType = 1
        *Me\currenttype = *Me\datatype
        *Me\polymorph = #False
      Else
        *Me\currenttype = Attribute::#ATTR_TYPE_UNDEFINED
        *Me\polymorph = #True
      EndIf
    EndIf
    
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Is Atomic
  ;-----------------------------------------------------------------------------
  Procedure IsAtomic(*Me.NodePort_t)
    If *Me\io And *Me\connected
      ProcedureReturn *Me\source\attribute\atomic
    Else
      ProcedureReturn *Me\attribute\atomic
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Is Connectable
  ;-----------------------------------------------------------------------------
  Procedure IsConnectable(*Me.NodePort_t,*Other.NodePort_t)
    If Not *Me\currenttype = *Other\currenttype
      ProcedureReturn #False
    EndIf
    
    If Not *Me\currentstructure = Attribute::#ATTR_STRUCT_ANY Or *Me\currentstructure = *Other\currentstructure
      ProcedureReturn #False
    EndIf
    
    If Not *Me\currentcontext = Attribute::#ATTR_CTXT_ANY Or *Me\currentcontext = *other\currentcontext
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Decorate Name
  ;-----------------------------------------------------------------------------
  Procedure DecorateName(*Me.NodePort_t,width.i)
    Protected w.i = TextWidth(*Me\name)
    Protected diff = width - w
    Protected unit = TextWidth(".")
    Protected deco.s
    Protected a
    For a=0 To diff/unit
      deco +"."  
    Next a
    Select *Me\io
      Case #True
        *Me\decoratedname = *Me\name+deco
      Case #False
        *Me\decoratedname = deco+*Me\name
    EndSelect
    
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Accept Connexion
  ;-----------------------------------------------------------------------------
  Procedure AcceptConnexion(*p.NodePort_t,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
    If Not Bool(*p\datatype & datatype )
      ; the ENUM / INTEGER special case
      If *p\datatype = Attribute::#ATTR_TYPE_ENUM And datatype = Attribute::#ATTR_TYPE_INTEGER Or
         *p\datatype = Attribute::#ATTR_TYPE_INTEGER And datatype = Attribute::#ATTR_TYPE_ENUM:
        If *p\connected
          ProcedureReturn 0
        Else
          ProcedureReturn 1
        EndIf
      EndIf
      
      ProcedureReturn -1
    ElseIf *p\connected
      ProcedureReturn 0
    Else
      ProcedureReturn 1
    EndIf
  EndProcedure
  
  
  ;-----------------------------------------------
  ; Set Value
  ;-----------------------------------------------
  Procedure SetValue(*port.NodePort_t,*value)
    Protected *array.CArray::CArrayT = *port\attribute\data
    Select *port\datatype
      Case Attribute::#ATTR_TYPE_REFERENCE
        MessageRequester("Port Type Reference!! ","OK")
      Case Attribute::#ATTR_TYPE_BOOL
        CArray::SetValueB(*array,0,PeekB(*value))
      Case Attribute::#ATTR_TYPE_LONG
        CArray::SetValueL(*array,0,PeekL(*value))
      Case Attribute::#ATTR_TYPE_INTEGER
        CArray::SetValueI(*array,0,PeekI(*value))
      Case Attribute::#ATTR_TYPE_FLOAT
        CArray::SetValueF(*array,0,PeekF(*value))
      Default
        CArray::SetValuePtr(*array,0,*value)
    EndSelect
  EndProcedure
  
  ;-----------------------------------------------
  ; Set Minimum
  ;-----------------------------------------------
  Procedure SetMinimum(*port.NodePort_t, value.d)
    *port\minimum = value
  EndProcedure
  
  ;-----------------------------------------------
  ; Set Maximum
  ;-----------------------------------------------
  Procedure SetMaximum(*port.NodePort_t, value.d)
    *port\maximum = value
  EndProcedure
  
  
  ;-----------------------------------------------
  ; Set Value
  ;-----------------------------------------------
  Procedure SetReference(*port.NodePort_t,ref.s)
    Select *port\datatype
      Case Attribute::#ATTR_TYPE_REFERENCE
        Protected *ref.Globals::Reference_t = *port\attribute\data
        *ref\reference = ref
        *ref\refchanged = #True
        Protected *node.Node::Node_t = *port\node
        Graph::ResolveGetReference(*port.NodePort::NodePort_t)
    EndSelect
    
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Get Value
  ;-----------------------------------------------
  Procedure GetValue(*port.NodePort_t)
    ProcedureReturn *port\attribute\data
    
  EndProcedure
  ;-----------------------------------------------------------------------------
  ; On Message
  ;-----------------------------------------------------------------------------
  Procedure OnMessage(id.i, *up)

;     Protected *sig.Signal::Signal_t = *up
;     Protected *c.Control::Control_t = *sig\snd_inst
;     Protected *port.NodePort::NodePort_t = *sig\rcv_inst
;     Protected *node.Node::Node_t = *port\node
;     Select *port\currenttype
;       Case Attribute::#ATTR_TYPE_REFERENCE
; ;         Protected ctrl.Control::IControlEdit = *c
;         *port\reference = ControlEdit::GetValue(*c)
;         *port\refchanged = #True
;         *port\dirty = #True
;         Debug "New REFERENCE Value : "+*port\reference
;         
; 
; ;         If *node\type = "GetDataNode"
; ;           ResolveGetReference(*node)
; ;         ElseIf *node\type = "SetDataNode"
; ;          ResolveSetReference(*node)
; ;         EndIf
;         
;   ;       ; Output Port
;   ;       If *port\io
;   ;         OSetDataNode_ResolveReference(*port\node)
;   ;       ; Input Port
;   ;       Else
;   ;         OGetDataNode_ResolveReference(*port\node)
;   ;       EndIf
;         
;         
;       Case Attribute::#ATTR_TYPE_BOOL
;         Protected *bCtrl.ControlCheck::ControlCheck_t = *c
;         Protected *bVal.CArray::CArrayBool = *port\value
;         CArray::SetValueB(*bVal,0,ControlCheck::GetValue(*bCtrl))
;         *port\dirty = #True
;         ;bVal\SetValue(0,bCtrl\GetValue())
; ;         Debug "New BOOL Value : "+Str(bVal\GetValue(0))
;         
;       Case Attribute::#ATTR_TYPE_INTEGER
;         Protected *iCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         Protected *iVal.CArray::CArrayInt = *port\value
;         CArray::SetValueI(*iVal,0,*iCtrl\value_n)
;         *port\dirty = #True
;         
;       Case Attribute::#ATTR_TYPE_FLOAT
;         
;         Protected *fCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         Protected fv.f = *fCtrl\value_n
;         Protected *fVal.CArray::CArrayFloat = *port\value
;         CArray::SetValueF(*fVal,0,fv);*fCtrl\value_n)
;         *port\dirty = #True
;         
;       Case Attribute::#ATTR_TYPE_VECTOR3
;         Protected *vVal.CArray::CArrayV3F32 = *port\value
;         Protected *v.v3f32 = CArray::GetValue(*vVal, 0)
;         
;         Protected *vCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         Protected f.f = *vCtrl\value_n
;         Select *sig\rcv_slot
;           Case 0;X
;             *v\x = f
;           Case 1;Y
;             *v\y = f
;           Case 2;Z
;             *v\z = f
;         EndSelect
;         
;         *port\dirty = #True
;         
;       Case Attribute::#ATTR_TYPE_Quaternion
;         Protected *qVal.CArray::CArrayQ4F32 = *port\value
;         Protected *q.q4f32 = CArray::GetValue(*qVal,0)
;         
;         Protected *qCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         f.f = *qCtrl\value_n
;         Select *sig\rcv_slot
;           Case 0;X
;             *q\x = f
;           Case 1;Y
;             *q\y = f
;           Case 2;Z
;             *q\z = f
;           Case 3;Angle
;             *q\w = Radian(f)
;         EndSelect
; 
;         *port\dirty = #True
;         
;       Case Attribute::#ATTR_TYPE_STRING
;         
;         Protected *sVal.CArray::CArrayStr = *port\value
;         Protected s.s = ControlEdit::GetValue(*c)
;     
;         
;         CArray::SetValueStr(*sVal,0,s)
;         MessageRequester("Port String On Message",CArray::GetValueStr(*sVal,0))
;         *port\dirty = #True
;         ;vVal\SetValue(0,@v);*fCtrl\value_n)
;         
;        Case Attribute::#ATTR_TYPE_COLOR
;         Protected *cVal.CArray::CArrayC4F32 = *port\value
;         Protected c.c4f32
;         
;   ;       Vector3_SetFromOther(@c,cVal\GetValue(0))
;   ;       
;   ;       Protected *vCtrl.CControlNumber_t = *sig\snd_inst
;   ;       Protected f.f = *vCtrl\value_n
;   ;       Select *sig\rcv_slot
;   ;         Case 0;X
;   ;           Debug "X Parameter Vector Update..."
;   ;           Vector3_Set(@v,f,v\y,v\z)
;   ;         Case 1;Y
;   ;           Vector3_Set(@v,v\x,f,v\z)
;   ;         Case 2;Z
;   ;           Vector3_Set(@v,v\x,v\y,f)
;   ;       EndSelect
;         
;   ;       vVal\SetValue(0,@v);*fCtrl\value_n)
;         
;         
;             
;         
;   ;       Debug ""+Str(*sig\
;         Debug "Vector 3 Message Slot : "+Str(*sig\rcv_slot)
;   ;       Protected *fCtrl.CControlNumber_t = *sig\snd_inst
;   ;       Protected fv.f = *fCtrl\value_n
;   ;       Debug "Recieved FLOAT port "+StrF(fv)
;   ;       Protected fVal.CArrayF32 = *port\value
;   ;       fVal\SetValue(0,fv);*fCtrl\value_n)
;   ; 
;   ;       Debug "New FLOAT Value : "+StrF(fVal\GetValue(0))
;   ;       
;     EndSelect
;     
;     *scene\dirty = #True
  EndProcedure
  
  Procedure SetupConnectionCallback(*Me.NodePort_t, *callback.ONCONNECTPORT)
    Define *node.Node::Node_t = *Me\node
    *Me\connectioncallback = *callback
  EndProcedure
  
  Procedure SetupDisconnectionCallback(*Me.NodePort_t, *callback.ONDISCONNECTPORT)
    *Me\disconnectioncallback = *callback
  EndProcedure


  Class::DEF(NodePort)
  


EndModule

; ============================================================================
;  End Of File
; ============================================================================
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 73
; FirstLine = 54
; Folding = -----
; EnableXP
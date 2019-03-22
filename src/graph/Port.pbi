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
    Protected *Me.NodePort_t = AllocateMemory(SizeOf(NodePort_t))
    InitializeStructure(*Me,NodePort_t)
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
  
    Init(*Me)
  
    *Me\connected = #False
    *Me\selected = #False
      
    ProcedureReturn *Me
  EndProcedure
  
  ;------------------------------------------------------------
  ; Destructor
  ;------------------------------------------------------------
  Procedure Delete(*Me.NodePort::NodePort_t)
    ClearStructure(*Me,NodePort_t)
    FreeMemory(*Me)
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Log
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
      Case Attribute::#ATTR_TYPE_UNDEFINED
        datatype = "[Undefined]"
    EndSelect
    
    Protected log.s = "Input Port "+*port\name+": "
    If *port\io
      log = "Output Port "+*port\name+": "
    EndIf
    
    log + "Data Type "+datatype
    
    Debug log
    
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
        
    EndSelect
    
    ProcedureReturn *port\color
  EndProcedure


  ;-----------------------------------------------------------------------------
  ; Init
  ;-----------------------------------------------------------------------------
  Procedure Init(*port.NodePort_t)
  ;   Select *port\currentstructure
    Select *port\currenttype
      Case Attribute::#ATTR_TYPE_UNDEFINED
        *port\value = #Null
        
      Case Attribute::#ATTR_TYPE_BOOL
        Protected *bVal.CArray::CArrayBool = CArray::newCArrayBool()
        CArray::AppendB(*bVal,#False)
        *port\value = *bVal

      Case Attribute::#ATTR_TYPE_FLOAT
        Protected *fVal.CArray::CArrayFloat = CArray::newCArrayFloat()
        CArray::AppendF(*fVal,0)
        *port\value = *fVal

      Case Attribute::#ATTR_TYPE_LONG
        Protected *lVal.CArray::CArrayLong = CArray::newCArrayLong()
        CArray::AppendL(*lVal,0)
        *port\value = *lVal

      Case Attribute::#ATTR_TYPE_INTEGER
        Protected *iVal.CArray::CArrayInt = CArray::newCArrayInt()
        CArray::AppendI(*iVal,0)
        *port\value = *iVal

      Case Attribute::#ATTR_TYPE_VECTOR2
  ;       Protected vVal2.CArrayV2F32 = newCArrayV2F32()
  ;       Protected v2.v2f32
  ;       ;Vector2_Set(@v2,0,0)
  ;       vVal2\Append(v2)
  ;       *port\value = vVal2
  ;       Debug "Array Size :  "+Str(vVal2\GetCount())
        
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected *vVal3.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
        Protected v3.v3f32
        Vector3::Set(v3,0,0,0)
        CArray::Append(*vVal3,v3)
        *port\value = *vVal3
        
      Case Attribute::#ATTR_TYPE_VECTOR4
        Protected *vVal4.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
        Protected v4.c4f32
        Color::Set(v4,0,0,0,0)
        CArray::Append(*vVal4,v4)
        *port\value = *vVal4
        
      Case Attribute::#ATTR_TYPE_QUATERNION
        Protected *qVal4.CArray::CArrayQ4F32 = CArray::newCArrayQ4F32()
        Protected q4.q4f32
        Quaternion::SetIdentity(q4)
        CArray::Append(*qVal4,q4)
        *port\value = *qVal4
        
      Case Attribute::#ATTR_TYPE_MATRIX3
        Protected *mVal3.CArray::CArrayM3F32 = CArray::newCArrayM3F32()
        Protected m3.m3f32
        Matrix3::SetIdentity(m3)
        CArray::Append(*mVal3,m3)
        *port\value = *mVal3
        
      Case Attribute::#ATTR_TYPE_MATRIX4

        Protected *mVal4.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
        Protected m4.m4f32
        Matrix4::SetIdentity(m4)
        CArray::Append(*mVal4,m4)
        *port\value = *mVal4
        
      Case Attribute::#ATTR_TYPE_COLOR
        Protected *cVal.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
        Protected c.c4f32
        Color::Set(c,0,0,0,1)
        CArray::Append(*cVal,c)
        *port\value = *cVal
        
      Case Attribute::#ATTR_TYPE_STRING
        Protected *sVal.CArray::CArrayStr = CARray::newCArrayStr()
        Protected s.s = ""
        CArray::AppendStr(*sVal,s)
        *port\value = *sVal
        
      Case Attribute::#ATTR_TYPE_REFERENCE
        Protected sVal.s = *port\reference
        *port\reference = sVal
        *port\refchanged = #True
        
      Case Attribute::#ATTR_TYPE_LOCATION
        *port\value = CArray::newCArrayPtr()
        
      Case Attribute::#ATTR_TYPE_TOPOLOGY
        Protected *data.CArray::CArrayPtr = CArray::newCArrayPtr()
        ;       *data\Append(newCAttributePolymeshTopology())
        Protected *topo.Geometry::Topology_t = Topology::New()
        CArray::AppendPtr(*data,*topo)
        *port\value = *data
        
      Case Attribute::#ATTR_TYPE_LOCATION
        *data.CArray::CArrayPtr = CArray::newCArrayPtr()
        ;Protected *loc.Location::Location_t = Location::New()
        CArray::AppendPtr(*data,#Null)
        *port\value = *data
        
      Case Attribute::#ATTR_TYPE_GEOMETRY
        *data.CArray::CArrayPtr = CArray::newCArrayPtr()
        CArray::AppendPtr(*data,#Null)
        *port\value = *data
        
      Case Attribute::#ATTR_TYPE_AUDIO
        *audio.CArray::CArrayPtr = CArray::newCArrayPtr()
        CArray::AppendPtr(*data,#Null)
        *port\value = *audio
       
      Case Attribute::#ATTR_TYPE_3DOBJECT
;         Debug "Init Port :  AttributeType_3DObject"
  ;       Protected *obj.C3DObject_t = #Null
  ;       *port\value = *obj
        
       Case Attribute::#ATTR_TYPE_EXECUTE
  ;       Protected *obj.C3DObject_t = #Null
  ;       *port\value = *obj
        
        Case Attribute::#ATTR_TYPE_NEW
  ;       Protected *obj.C3DObject_t = #Null
  ;       *port\value = *obj
        
      Default
        Debug "Faileddto Init Graph Node Port "+*port\name
        *port\value = #Null
    EndSelect
    
    If *port\io = #False
      *port\dirty = #True
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
    *port\value = *attr\data
    GetColor(*port)
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Acquire Reference Data
  ;-----------------------------------------------------------------------------
  Procedure.s AcquireReferenceData(*port.NodePort_t)
    Protected *data
     If *port\connected
       *data = *port\source\value
       *port\daisyreference = *port\source\reference+"."+*port\reference
      Else
        *port\daisyreference = *port\reference
        *data = *port\value
        If Not *data : Init(*port) : *data = *port\value: EndIf
      EndIf
    ProcedureReturn *port\daisyreference  
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Acquire Input Data
  ;-----------------------------------------------------------------------------
  Procedure AcquireInputData(*port.NodePort_t)
    
    Protected *data.CArray::CArrayT
    Select *port\currentstructure
      Case Attribute::#ATTR_STRUCT_ARRAY
        ;Case STRUCT_ARRAY
        ;-----------------------------------------------------
        If *port\connected
          *data = *port\source\value
        Else
          *data = *port\value
          If Not *data : Init(*port) : *data = *port\value: EndIf
          *port\dirty = #False
        EndIf
        
      Case Attribute::#ATTR_STRUCT_SINGLE
        ;Case STRUCT_SINGLE
        ;-----------------------------------------------------
        If *port\connected
          *data = *port\source\value
        Else
          *data = *port\value
          If Not *data : Init(*port) : *data = *port\value: EndIf
          *port\dirty = #False
        EndIf
        
      Case Attribute::#ATTR_STRUCT_ANY
        ;Case STRUCT_ANY
        ;-----------------------------------------------------
        If *port\connected
          *data = *port\source\value
        Else
        
          *data = *port\value
          If Not *data : Init(*port) : *data = *port\value: EndIf
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
  ; Acquire Output Data
  ;-----------------------------------------------------------------------------
  Procedure AcquireOutputData(*port.NodePort_t)
    
    Protected *data.CArray::CArrayT
    
    Protected *target.NodePort_t
    If *port\connected
      Protected *connexion.Connexion::Connexion_t = *port\connexion
      *target = *connexion\end
        ProcedureReturn *target\value
    Else
      ProcedureReturn *port\value
    EndIf
    
      
         
  EndProcedure


  ;-----------------------------------------------------------------------------
  ; Update
  ;-----------------------------------------------------------------------------
  Procedure Update(*port.NodePort_t,type.i=Attribute::#ATTR_TYPE_UNDEFINED,context.i=Attribute::#ATTR_CTXT_ANY,struct.i=Attribute::#ATTR_STRUCT_ANY)
    
    ;Delete Old Data
    If *port\value : 
      Protected *v.CArray::CArrayT = *port\value
      CArray::Delete(*v)
      *port\value = 0
    EndIf
  
    ; Create New Data
    *port\currenttype = type
    *port\currentcontext = context
    *port\currentstructure = struct
  
    Init(*port)
    
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
      If *Me\datatype & Attribute::#ATTR_TYPE_COLOR : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_BOOL : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_FLOAT : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_INTEGER : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_MATRIX3 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_MATRIX4 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_QUATERNION : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_ROTATION : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_STRING : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_TOPOLOGY : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_GEOMETRY : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_LOCATION : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_VECTOR2 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_VECTOR3 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_VECTOR4 : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_AUDIO : nbDataType+1 : EndIf
      If *Me\datatype & Attribute::#ATTR_TYPE_EXECUTE : nbDataType+1 : EndIf
      
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
    Protected *array.CArray::CArrayT = *port\value
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
  ; Set Value
  ;-----------------------------------------------
  Procedure SetReference(*port.NodePort_t,ref.s)
    Select *port\datatype
      Case Attribute::#ATTR_TYPE_REFERENCE
        *port\reference = ref
        *port\refchanged = #True
        Protected *node.Node::Node_t = *port\node
        Graph::ResolveGetReference(*port.NodePort::NodePort_t)
    EndSelect
    
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Get Value
  ;-----------------------------------------------
  Procedure GetValue(*port.NodePort_t)
    ProcedureReturn *port\value
    
  EndProcedure
  ;-----------------------------------------------------------------------------
  ; On Message
  ;-----------------------------------------------------------------------------
  Procedure OnMessage(id.i, *up)

    Protected *sig.Signal::Signal_t = *up
    Protected *c.Control::Control_t = *sig\snd_inst
    Protected *port.NodePort::NodePort_t = *sig\rcv_inst
    Protected *node.Node::Node_t = *port\node
    Select *port\currenttype
      Case Attribute::#ATTR_TYPE_REFERENCE
;         Protected ctrl.Control::IControlEdit = *c
        *port\reference = ControlEdit::GetValue(*c)
        *port\refchanged = #True
        *port\dirty = #True
        Debug "New REFERENCE Value : "+*port\reference
        

;         If *node\type = "GetDataNode"
;           ResolveGetReference(*node)
;         ElseIf *node\type = "SetDataNode"
;          ResolveSetReference(*node)
;         EndIf
        
  ;       ; Output Port
  ;       If *port\io
  ;         OSetDataNode_ResolveReference(*port\node)
  ;       ; Input Port
  ;       Else
  ;         OGetDataNode_ResolveReference(*port\node)
  ;       EndIf
        
        
      Case Attribute::#ATTR_TYPE_BOOL
        Protected *bCtrl.ControlCheck::ControlCheck_t = *c
        Protected *bVal.CArray::CArrayBool = *port\value
        CArray::SetValueB(*bVal,0,ControlCheck::GetValue(*bCtrl))
        *port\dirty = #True
        ;bVal\SetValue(0,bCtrl\GetValue())
;         Debug "New BOOL Value : "+Str(bVal\GetValue(0))
        
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected *iCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
        Protected *iVal.CArray::CArrayInt = *port\value
        CArray::SetValueI(*iVal,0,*iCtrl\value_n)
        *port\dirty = #True
        
      Case Attribute::#ATTR_TYPE_FLOAT
        
        Protected *fCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
        Protected fv.f = *fCtrl\value_n
        Protected *fVal.CArray::CArrayFloat = *port\value
        CArray::SetValueF(*fVal,0,fv);*fCtrl\value_n)
        *port\dirty = #True
        
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected *vVal.CArray::CArrayV3F32 = *port\value
        Protected *v.v3f32 = CArray::GetValue(*vVal, 0)
        
        Protected *vCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
        Protected f.f = *vCtrl\value_n
        Select *sig\rcv_slot
          Case 0;X
            *v\x = f
          Case 1;Y
            *v\y = f
          Case 2;Z
            *v\z = f
        EndSelect
        
        *port\dirty = #True
        
      Case Attribute::#ATTR_TYPE_Quaternion
        Protected *qVal.CArray::CArrayQ4F32 = *port\value
        Protected *q.q4f32 = CArray::GetValue(*qVal,0)
        
        Protected *qCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
        f.f = *qCtrl\value_n
        Select *sig\rcv_slot
          Case 0;X
            *q\x = f
          Case 1;Y
            *q\y = f
          Case 2;Z
            *q\z = f
          Case 3;Angle
            *q\w = Radian(f)
        EndSelect

        *port\dirty = #True
        
      Case Attribute::#ATTR_TYPE_STRING
        
        Protected *sVal.CArray::CArrayStr = *port\value
        Protected s.s = ControlEdit::GetValue(*c)
    
        
        CArray::SetValueStr(*sVal,0,s)
        MessageRequester("Port String On Message",CArray::GetValueStr(*sVal,0))
        *port\dirty = #True
        ;vVal\SetValue(0,@v);*fCtrl\value_n)
        
       Case Attribute::#ATTR_TYPE_COLOR
        Protected *cVal.CArray::CArrayC4F32 = *port\value
        Protected c.c4f32
        
  ;       Vector3_SetFromOther(@c,cVal\GetValue(0))
  ;       
  ;       Protected *vCtrl.CControlNumber_t = *sig\snd_inst
  ;       Protected f.f = *vCtrl\value_n
  ;       Select *sig\rcv_slot
  ;         Case 0;X
  ;           Debug "X Parameter Vector Update..."
  ;           Vector3_Set(@v,f,v\y,v\z)
  ;         Case 1;Y
  ;           Vector3_Set(@v,v\x,f,v\z)
  ;         Case 2;Z
  ;           Vector3_Set(@v,v\x,v\y,f)
  ;       EndSelect
        
  ;       vVal\SetValue(0,@v);*fCtrl\value_n)
        
        
            
        
  ;       Debug ""+Str(*sig\
        Debug "Vector 3 Message Slot : "+Str(*sig\rcv_slot)
  ;       Protected *fCtrl.CControlNumber_t = *sig\snd_inst
  ;       Protected fv.f = *fCtrl\value_n
  ;       Debug "Recieved FLOAT port "+StrF(fv)
  ;       Protected fVal.CArrayF32 = *port\value
  ;       fVal\SetValue(0,fv);*fCtrl\value_n)
  ; 
  ;       Debug "New FLOAT Value : "+StrF(fVal\GetValue(0))
  ;       
    EndSelect
    
    Scene::*current_scene\dirty = #True
  EndProcedure
  
  


  Class::DEF(NodePort)
  


EndModule

; ============================================================================
;  End Of File
; ============================================================================
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 255
; FirstLine = 251
; Folding = ----
; EnableXP
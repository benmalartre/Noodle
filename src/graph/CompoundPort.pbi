
XIncludeFile "Port.pbi"

; ============================================================================
;  NODE PORT MODULE IMPLEMENTATION
; ============================================================================
Module CompoundNodePort
  UseModule Math
  ;------------------------------------------------------------
  ; Constructors
  ;------------------------------------------------------------
  Procedure New(*parent.Node::Node_t,name.s,io.b)
    Protected *Me.CompoundNodePort_t = AllocateMemory(SizeOf(CompoundNodePort_t))
    Object::INI(CompoundNodePort)
    *Me\port = #Null
    *Me\node = *parent
    *Me\name = name
    *Me\datatype = Attribute::#ATTR_TYPE_POLYMORPH
    *Me\currenttype = Attribute::#ATTR_TYPE_POLYMORPH
    *Me\datacontext = Attribute::#ATTR_CTXT_ANY
    *Me\currentcontext = Attribute::#ATTR_CTXT_ANY
    *Me\datastructure = Attribute::#ATTR_STRUCT_ANY
    *Me\currentstructure = Attribute::#ATTR_STRUCT_ANY
    *Me\io = io
    
    Init(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewFromPort(*port.NodePort::NodePort_t)
    Protected *Me.CompoundNodePort_t = AllocateMemory(SizeOf(CompoundNodePort_t))
    Object::INI(CompoundNodePort)
    *Me\port = *port
    *Me\node = *port\node
    *Me\name = *port\name
    *Me\datatype = *port\datatype
    *Me\currenttype = *port\currenttype
    *Me\datacontext = *port\datacontext
    *Me\currentcontext = *port\currentcontext
    *Me\datastructure = *port\datastructure
    *Me\currentstructure = *port\currentstructure
    *Me\color = *port\color
    *Me\io = *port \io
    
    Init(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ;------------------------------------------------------------
  ; Destructor
  ;------------------------------------------------------------
  Procedure Delete(*Me.CompoundNodePort_t)
    ClearStructure(*Me,CompoundNodePort_t)
    FreeMemory(*Me)
  EndProcedure
  
  Procedure Init(*Me.CompoundNodePort_t)
    
    NodePort::GetColor(*Me)
    If *Me\port : *Me\attribute\data = *Me\port\attribute\data : EndIf
  EndProcedure
  

  ;-----------------------------------------------------------------------------
  ; On Message
  ;-----------------------------------------------------------------------------
  Procedure OnMessage(id.i, *up)

;     Protected *sig.Signal::Signal_t = *up
;     Protected *c.Control::Control_t = *sig\snd_inst
;     Protected *port.NodePort::NodePort_t = *sig\rcv_inst
;     Select *port\currenttype
;       Case Attribute::#ATTR_TYPE_REFERENCE
;         *port\reference = ControlEdit::GetValue(*c)
;         *port\refchanged = #True
;         Protected *node.Node::Node_t = *port\node
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
;         
;       Case Attribute::#ATTR_TYPE_INTEGER
;         Protected *iCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         Protected *iVal.CArray::CArrayInt = *port\value
;         CArray::SetValueI(*iVal,0,*iCtrl\value_n)
;         
;       Case Attribute::#ATTR_TYPE_FLOAT
;         
;         Protected *fCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         Protected fv.f = *fCtrl\value_n
;         Protected *fVal.CArray::CArrayFloat = *port\value
;         CArray::SetValueF(*fVal,0,fv)
;                 
;       Case Attribute::#ATTR_TYPE_VECTOR3
;         Protected *vVal.CArray::CArrayV3F32 = *port\value
;         Protected v.v3f32
;         CopyMemory(CArray::GetValue(*vVal,0), @v, 12)
;         
;         Protected *vCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         Protected f.f = *vCtrl\value_n
;         Select *sig\rcv_slot
;           Case 0;X
;             Vector3::Set(v,f,v\y,v\z)
;           Case 1;Y
;             Vector3::Set(v,v\x,f,v\z)
;           Case 2;Z
;             Vector3::Set(v,v\x,v\y,f)
;         EndSelect
;         
;         CArray::SetValue(*vVal,0,v)
;         
;       Case Attribute::#ATTR_TYPE_Quaternion
;         Protected *qVal.CArray::CArrayQ4F32 = *port\value
;         Protected q.q4f32
;         Protected *o.q4f32 = CArray::GetValue(*qVal,0)
;         Quaternion::SetFromOther(q, *o)
;         
;         Protected *qCtrl.ControlNumber::ControlNumber_t = *sig\snd_inst
;         f.f = *qCtrl\value_n
;         Select *sig\rcv_slot
;           Case 0;X
;             Quaternion::Set(q,f,q\y,q\z,q\w)
;           Case 1;Y
;             Quaternion::Set(q,q\x,f,q\z,q\w)
;           Case 2;Z
;             Quaternion::Set(q,q\x,q\y,f,q\w)
;           Case 3;Angle
;             Quaternion::Set(q,q\x,q\y,q\z,Radian(f))
;         EndSelect
;         
;         CArray::SetValue(*qVal,0,q)
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
    Scene::*current_scene\dirty = #True
  EndProcedure
  
  


  Class::DEF(CompoundNodePort)
  


EndModule

; ============================================================================
;  End Of File
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 59
; FirstLine = 55
; Folding = --
; EnableXP
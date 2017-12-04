
; ============================================================================
;  Loader Module Declaration
; ============================================================================
DeclareModule Loader
  ; ----------------------------------------------------------------------------
  ;  Loader
  ; ----------------------------------------------------------------------------
  Structure Loader_t Extends Object::Object_t
    path.s
    type.i
    xml.i               ; XML Object
    current.i           ; Current XML Node
    root.i              ; XML Root Node
    numLoaded3DObject.i
  EndStructure
  
  Global Dim extensions.s(3)
  extensions(0) = "compound"     ; Compound
  extensions(1) = "scene"     ; Scene
  extensions(2) = "model"     ; Model
  
  Global CLASS.Class::Class_t
  
  Declare New(path.s="")
  Declare Delete(*Me.Loader_t)
  Declare Load(*Me.Loader_t)
EndDeclareModule



; ============================================================================
;  Loader Module Implementation
; ============================================================================
Module Loader
  UseModule Math
  ;---------------------------------------------------------------
  ; Load Transform
  ;---------------------------------------------------------------
  Procedure LoadTransform(node.i,*obj.Object3D::Object3D_t)
    Protected kinematics.i = ChildXMLNode(node,2)
    Protected *t.Transform::Transform_t = *obj\localT
    Protected *m.Math::m4f32 = *t\m
    Protected localTransform.i = ChildXMLNode(kinematics, 1)
    value.s = GetXMLAttribute(localTransform,"Value")
    MessageRequester("LOADER","MATRIX : "+value)
    Matrix4::FromString(*m, value)
;     Protected bufferLength.i = Len(lm)+2
;     Protected *mem = AllocateMemory(bufferLength)
;     PokeS(*mem,lm,bufferLength)
;     Base64Decoder(*mem,bufferLength,*t\m,SizeOf(m4f32))
    Transform::UpdateSRTFromMatrix(*t)
    Object3D::SetLocalTransform(*obj,*t)
    Object3D::UpdateTransform(*obj,#Null)
    
  
     
;     *t = *obj\globalT
;     Protected gm.s = GetXMLAttribute(kine,"GlobalTransform")
;     bufferLength.i = Len(gm)+2
;     *mem = ReAllocateMemory(*mem,bufferLength)
;     PokeS(*mem,gm,bufferLength)
;     Base64Decoder(*mem,bufferLength,*t\m,SizeOf(m4f32))
;     FreeMemory(*mem)
;     Transform::UpdateSRTFromMatrix(*t)
  EndProcedure
  
  Procedure GetVector3FromString(string.s,*v.v3f32)
    If Left(string,1)="(" : string = Right(string,Len(string)-1) : EndIf
    If Right(string,1)=")" : string = Left(string,Len(string)-1) : EndIf
    
    *v\x = ValF(StringField(string,1,","))
    *v\y = ValF(StringField(string,2,","))
    *v\z = ValF(StringField(string,3,","))
  
  EndProcedure
  
  Procedure GetQuaternionFromString(string.s,*q.q4f32)
    If Left(string,1)="(" : string = Right(string,Len(string)-1) : EndIf
    If Right(string,1)=")" : string = Left(string,Len(string)-1) : EndIf
    
    *q\x = ValF(StringField(string,1,","))
    *q\y = ValF(StringField(string,2,","))
    *q\z = ValF(StringField(string,3,","))
    *q\w = ValF(StringField(string,4,","))
  
  EndProcedure
  
  Procedure GetMatrix4FromString(string.s,*m.m4f32)
    If Left(string,1)="(" : string = Right(string,Len(string)-1) : EndIf
    If Right(string,1)=")" : string = Left(string,Len(string)-1) : EndIf
    
    *m\v[0] = ValF(StringField(string,1,","))
    *m\v[1] = ValF(StringField(string,2,","))
    *m\v[2] = ValF(StringField(string,3,","))
    *m\v[3] = ValF(StringField(string,4,","))
    
    *m\v[4] = ValF(StringField(string,5,","))
    *m\v[5] = ValF(StringField(string,6,","))
    *m\v[6] = ValF(StringField(string,7,","))
    *m\v[7] = ValF(StringField(string,8,","))
    
    *m\v[8] = ValF(StringField(string,9,","))
    *m\v[9] = ValF(StringField(string,10,","))
    *m\v[10] = ValF(StringField(string,11,","))
    *m\v[11] = ValF(StringField(string,12,","))
    
    *m\v[12] = ValF(StringField(string,13,","))
    *m\v[13] = ValF(StringField(string,14,","))
    *m\v[14] = ValF(StringField(string,15,","))
    *m\v[15] = ValF(StringField(string,16,","))
  
  EndProcedure
  
  ;---------------------------------------------------------------
  ; Load Polymesh
  ;---------------------------------------------------------------
  Procedure LoadPolymesh(*Me.Loader_t,node.i,*mesh.Polymesh::Polymesh_t)
    Protected i
    Protected child.i
    Protected datas.s
    Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
    Protected *topo.Geometry::Topology_t = *geom\base
    Protected nbpoints
    Protected nbindices
    datas + GetXMLNodeName(node)+Chr(10)
    For i=1 To XMLChildCount(node)
      child = ChildXMLNode(node,i)
      ExamineXMLAttributes(child)
      While NextXMLAttribute(child)
        If XMLAttributeName(child) = "NbVertices"
          nbpoints = Val(XMLAttributeValue(child))
          CArray::SetCount(*topo\vertices, nbpoints)
        ElseIf XMLAttributeName(child) = "NbIndices"
          nbindices = Val(XMLAttributeValue(child))
          CArray::SetCount(*topo\faces, nbindices)
        ElseIf XMLAttributeName(child) = "Vertices"
          str.s = XMLAttributeValue(child)
          bufferLength.i = StringByteLength(str)
          ;Base64Decoder(@str,bufferLength,CArray::GetPtr(*topo\vertices,0),nbpoints* CArray::GetItemSize(*topo\vertices))
          Base64Decoder(str,CArray::GetPtr(*topo\vertices,0),nbpoints* CArray::GetItemSize(*topo\vertices))
        ElseIf XMLAttributeName(child) = "Indices"
          str.s = XMLAttributeValue(child)
          bufferLength.i = StringByteLength(str)
          ;Base64Decoder(@str,bufferLength,CArray::GetPtr(*topo\faces,0),nbindices* CArray::GetItemSize(*topo\faces))
          Base64Decoder(str,CArray::GetPtr(*topo\faces,0),nbindices* CArray::GetItemSize(*topo\faces))
        EndIf
      Wend
    Next
  EndProcedure
  
    
  ;---------------------------------------------------------------
  ; Load Attributes
  ;---------------------------------------------------------------
  Procedure LoadAttributes(*Me.Loader_t,node.i,*obj.Object3D::Object3D_t)
  
    If *obj = #Null : ProcedureReturn : EndIf
    
    Protected i=0,j=0
    Protected attrs =ChildXMLNode(node,3)
    Protected attr
    Protected nbFields
    Protected str.s
    Protected datatype.i
    Protected datacontext.i
    Protected datastructure.i
    Protected datasize.i
    Protected attrName.s
    Protected *mem
    Protected bufferLength.i
    
    Protected *attr.Attribute::Attribute_t
  
    For i=1 To XMLChildCount(attrs)
      attr.i = ChildXMLNode(attrs,i)
      attrName = GetXMLNodeName(attr)
      ExamineXMLAttributes(attr)
      While NextXMLAttribute(attr)
        Select XMLAttributeName(attr)
          Case "Type"
            datatype = Val(XMLAttributeValue(attr))
          Case "Context"
            datacontext = Val(XMLAttributeValue(attr))
          Case "Structure"
            datastructure = Val(XMLAttributeValue(attr))
          Case "Size"
            datasize = Val(XMLAttributeValue(attr))
            Debug "Attribute "+attrName+" DataSize : "+Str(datasize)
        EndSelect
       
      Wend
      If Not datasize : Continue : EndIf
      
      *attr = *obj\m_attributes(attrName)
      If Not *attr
        ; Create Attribute as it doesn't exists!!!
        MessageRequester("Noodle","Attribute "+GetXMLNodeName(attr)+" doesn't exists!!!")
      EndIf
      
      Select datastructure
        Case Attribute::#ATTR_STRUCT_SINGLE
          Select datatype
            ; Boolean
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_BOOL
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  PokeB(*attr\data,Val(GetXMLNodeText(attr)))
                Default
                    Protected *bArray.CArray::CArrayBool = *attr\data
                    CArray::SetCount(*bArray,datasize)
                    Protected sBoo.s = GetXMLNodeText(attr)
                    bufferLength.i = StringByteLength(sBoo)
                    ;Base64Decoder(@sBoo,bufferLength,CArray::GetPtr(*bArray,0),datasize* CArray::GetItemSize(*bArray))
                    Base64Decoder(sBoo,CArray::GetPtr(*bArray,0),datasize* CArray::GetItemSize(*bArray))
                EndSelect
                
            ; Integer
            ;-----------------------------------------------
              Case Attribute::#ATTR_TYPE_LONG
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  PokeL(*attr\data,Val(GetXMLNodeText(attr)))
                Default
                  Protected *lArray.CArray::CArrayLong = *attr\data
                  CArray::SetCount(*lArray,datasize)
                  Protected sLong.s = GetXMLNodeText(attr)
                  Debug sLong
                  bufferLength.i = StringByteLength(sLong)
                  ;Base64Decoder(@sLong,bufferLength,CArray::GetPtr(*lArray,0),datasize* CArray::GetItemSize(*lArray))
                  Base64Decoder(sLong,CArray::GetPtr(*lArray,0),datasize* CArray::GetItemSize(*lArray))
              EndSelect
              
            ; Integer
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_INTEGER
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  PokeI(*attr\data,Val(GetXMLNodeText(attr)))
                Default
                  Protected *iArray.CArray::CArrayInt = *attr\data
                  CArray::SetCount(*iArray,datasize)
                  Protected sInt.s = GetXMLNodeText(attr)
                  Debug sInt
                  bufferLength.i = StringByteLength(sInt)
                  ;Base64Decoder(@sInt,bufferLength,CArray::GetPtr(*iArray,0),datasize* CArray::GetItemSize(*iArray))
                  Base64Decoder(sInt,CArray::GetPtr(*iArray,0),datasize* CArray::GetItemSize(*iArray))
              EndSelect
              
            ; Float
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_FLOAT
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  PokeF(*attr\data,ValF(GetXMLNodeText(attr)))
                Default
                  Protected *f32Array.CARray::CArrayFloat = *attr\data
                  CArray::SetCount(*f32Array,datasize)
                  Protected sF32.s = GetXMLNodeText(attr)
                  bufferLength.i = StringByteLength(sF32)
                  ;Base64Decoder(@sF32,bufferLength,CArray::GetPtr(*f32Array,0),datasize* CArray::GetItemSize(*f32Array))
                  Base64Decoder(sF32,CArray::GetPtr(*f32Array,0),datasize* CArray::GetItemSize(*f32Array))
              EndSelect
              
            ; Vector3
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_VECTOR3
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  Protected v.v3f32
                  str.s = GetXMLNodeText(attr)
                  GetVector3FromString(str.s,@v)
                  CopyMemory(@v,*attr\data,SizeOf(v))
                Default
                  Protected *v3f32Array.CArray::CArrayV3f32 = *attr\data
                  CArray::SetCount(*v3f32Array,datasize)
                  str.s = GetXMLNodeText(attr)
                  bufferLength.i = StringByteLength(str)
                  ;Base64Decoder(@str,bufferLength,CArray::GetPtr(*v3f32Array,0),datasize* CArray::GetItemSize(*v3f32Array))
                  Base64Decoder(str,CArray::GetPtr(*v3f32Array,0),datasize* CArray::GetItemSize(*v3f32Array))
              EndSelect
              
            ; Quaternion
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_QUATERNION
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  Protected q.q4f32
                  str.s = GetXMLNodeText(attr)
                  GetQuaternionFromString(str.s,@q)
                  CopyMemory(@q,*attr\data,SizeOf(q))
                Default
                  Protected *qArray.CArray::CArrayV3F32 = *attr\data
                  CArray::SetCount(*qArray,datasize)
                  Protected qF32.s = GetXMLNodeText(attr)
                  bufferLength.i = StringByteLength(qF32)
                  ;Base64Decoder(@qF32,bufferLength,CArray::GetPtr(*qArray,0),datasize* CArray::GetItemSize(*qArray))
                  Base64Decoder(qF32,CArray::GetPtr(*qArray,0),datasize* CArray::GetItemSize(*qArray))
              EndSelect 
            ; Matrix4
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_MATRIX4
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  Protected m4.m4f32
                  str.s = GetXMLNodeText(attr)
                  GetMatrix4FromString(str.s,@m4)
                  CopyMemory(@m4,*attr\data,SizeOf(m4))
                Default
                  Protected *m4Array.CArray::CArrayM4F32 = *attr\data
                  CArray::SetCount(*m4Array,datasize)
                  Protected m4F32.s = GetXMLNodeText(attr)
                  bufferLength.i = StringByteLength(m4F32)
                  ;Base64Decoder(@m4F32,bufferLength,CArray::GetPtr(*m4Array,0),datasize* CArray::GetItemSize(*m4Array))
                  Base64Decoder(m4F32,CArray::GetPtr(*m4Array,0),datasize* CArray::GetItemSize(*m4Array))
              EndSelect
          EndSelect
          
        ; 2D Array
        Case Attribute::#ATTR_STRUCT_ARRAY
           Select datatype
            ; Boolean
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_BOOL
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  *bArray.CArray::CArrayBool = *attr\data
                  sBoo.s = GetXMLNodeText(attr)
                  nbFields = CountString(sBoo,",")
  
                  For j=1 To nbFields
                    CArray::AppendB(*bArray,Val(StringField(sBoo,j,",")))
                  Next
  
              EndSelect
              
            ; Long
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_LONG
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  *lArray.CArray::CArrayLong = *attr\data
                  CArray::SetCount(*lArray,datasize)
                  sLong.s = GetXMLNodeText(attr)
                  Debug sLong
                  bufferLength.i = StringByteLength(sLong)
                  ;Base64Decoder(@sLong,bufferLength,CArray::GetPtr(*lArray,0),datasize* CArray::GetItemSize(*lArray))
                 Base64Decoder(sLong,CArray::GetPtr(*lArray,0),datasize* CArray::GetItemSize(*lArray))
              EndSelect

              
            ; Integer
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_INTEGER
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  *iArray.CArray::CArrayInt = *attr\data
                  CArray::SetCount(*iArray,datasize)
                  sInt.s = GetXMLNodeText(attr)
                  bufferLength.i = StringByteLength(sInt)
                  ;Base64Decoder(@sInt,bufferLength,CArray::GetPtr(*iArray,0),datasize* CArray::GetItemSize(*iArray))
                  Base64Decoder(sInt,CArray::GetPtr(*iArray,0),datasize* CArray::GetItemSize(*iArray))
              EndSelect
              
            ; Float
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_FLOAT
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  *fArray.CArray::CArrayFloat = *attr\data
                  CArray::SetCount(*fArray,datasize)
                  sFloat.s = GetXMLNodeText(attr)
                  bufferLength.i = StringByteLength(sFloat)
                  ;Base64Decoder(@sFloat,bufferLength,CArray::GetPtr(*fArray,0),datasize* CArray::GetItemSize(*fArray))
                  Base64Decoder(sFloat,CArray::GetPtr(*fArray,0),datasize* CArray::GetItemSize(*fArray))
              EndSelect
              
            ; Vector3
            ;-----------------------------------------------
            Case Attribute::#ATTR_TYPE_VECTOR3
              Select *attr\datacontext
                Case Attribute::#ATTR_CTXT_SINGLETON
                  *v.v3f32
                  *v3F32Array.CArray::CArrayV3F32 = *attr\data
                  CArray::SetCount(*v3F32Array,datasize)
                  v3F32.s = GetXMLNodeText(attr)
                  bufferLength.i = StringByteLength(v3F32)
                  ;Base64Decoder(@v3F32,bufferLength,CArray::GetPtr(*v3F32Array,0),datasize* CArray::GetItemSize(*v3F32Array))
                  Base64Decoder(v3F32,CArray::GetPtr(*v3F32Array,0),datasize* CArray::GetItemSize(*v3F32Array))
              EndSelect
              

          EndSelect
      EndSelect
  
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------------
  ; Load 3D Objects
  ;---------------------------------------------------------------
  Procedure Load3DObject(*Me.Loader_t,node.i,*scene.Scene::Scene_t,*parent.Object3D::Object3D_t)
    Protected *object.Object3D::Object3D_t
    Protected name.s
    Protected attributes.i
    Select GetXMLAttribute(node,"Type")
      ;------------------------------------------------------
      ; PointCloud
      ;------------------------------------------------------
      Case "PointCloud"
        name.s= GetXMLNodeName(node)
        Protected *cloud.PointCloud::PointCloud_t = PointCloud::New(name,0)
        Object3D::AddChild(*parent,*cloud)
        Scene::AddObject(*scene,*cloud)
        Protected *pcgeom.Geometry::PointCloudGeometry_t = *cloud\geom
        *object = *cloud
        LoadAttributes(*Me,node,*cloud)
        *cloud\dirty = #True
        *parent = cloud
        *Me\numLoaded3DObject +1
      ;------------------------------------------------------
      ; Polymesh
      ;------------------------------------------------------
      Case "Polymesh"
        Debug "THIS IS A POLYMESH..."
        name.s = GetXMLNodeName(node)
        Protected *mesh.Polymesh::Polymesh_t = Polymesh::New(name,Shape::#SHAPE_NONE)
        Object3D::AddChild(*parent,*mesh)
        Scene::AddChild(*scene,*mesh)
        Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
        *object = *mesh
        ;PolymeshGeometry::BunnyTopology(*geom\base)
        LoadPolymesh(*Me,node,*mesh)
        
        *parent = *mesh
        *Me\numLoaded3DObject +1
    EndSelect
    
  ;   ; Load Transform
    If *object<> #Null
      LoadTransform(node,*object)
      ;   ; Load Attributes
      ;   LoadAttributes(*Me,node,*object)
    EndIf

 
    
    If XMLChildCount(node)
      Protected child
      Protected c
      For c=1 To XMLChildCount(node)
        child = ChildXMLNode(node,c)
        Load3DObject(*Me,child,*scene,*parent)
      Next
    EndIf
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Load
  ;------------------------------------------------------------------
  Procedure Load(*Me.Loader_t)
    If Scene::*current_scene : Scene::Delete(Scene::*current_scene) : EndIf
    
    Scene::*current_scene = Scene::New("Clone")
    Protected root.i = ChildXMLNode(RootXMLNode(*Me\xml))
    Protected name.s = GetXMLNodeName(root)
    Protected o
    Protected n
    For o=1 To XMLChildCount(root)
      n = ChildXMLNode(root,o)
      Load3DObject(*Me,n,Scene::*current_scene,Scene::*current_scene\root)
    Next
    
    MessageRequester("LOADER","NUM LOADED 3D OBEJCTS : "+Str(*Me\numLoaded3DObject))
    
    ProcedureReturn Scene::*current_scene
  EndProcedure
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*e.Loader_t)
    FreeMemory(*e)
  EndProcedure
  
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(path.s="")
    Protected *Me.Loader_t = AllocateMemory(SizeOf(Loader_t))
    *Me\path = path
    *Me\numLoaded3DObject = 0
    Protected file.s = OpenFileRequester("Raabit Load Scene",path,extensions(1),-1)
    If file
      *Me\xml = LoadXML(#PB_Any,file)
    EndIf
    
    ProcedureReturn *Me
  EndProcedure
  ;}
  
  Class::DEF(Loader)
EndModule
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 389
; FirstLine = 366
; Folding = ---
; EnableXP
; EnableUnicode
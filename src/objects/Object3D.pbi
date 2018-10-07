XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Object.pbi"
XIncludeFile "../core/Perlin2.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../opengl/Texture.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/PolymeshGeometry.pbi"
XIncludeFile "../objects/Stack.pbi"


DeclareModule Object3D
  UseModule Math
  UseModule OpenGL
  Enumeration
    #Object3D_None
    #Object3D_Camera
    #Object3D_Light
    #Object3D_Null
    #Object3D_Polymesh
    #Object3D_Curve
    #Object3D_PointCloud
    #Object3D_InstanceCloud
    #Object3D_Grid
    #Object3D_Model
    #Object3D_Root
    #Object3D_Layer
    #Object3D_Drawer
  EndEnumeration

  #DIRTY_STATE_CLEAN = 0
  #DIRTY_STATE_TRANSFORM = 1
  #DIRTY_STATE_DEFORM = 2
  #DIRTY_STATE_UVW = 4
  #DIRTY_STATE_COLOR = 8
  #DIRTY_STATE_TOPOLOGY = 16
  
  Structure Object3D_t Extends Object::Object_t
    
    uniqueID.i
    visited.b
    
    vao.i
    vbo.i
    eab.i
    type.i
    *shader.Program::Program_t
    *geom.Geometry::Geometry_t
    name.s
    fullname.s
    matrix.m4f32
    initialized.b
    visible.b
    dirty.i
    localT.Transform::Transform_t
    globalT.Transform::Transform_t
    staticT.Transform::Transform_t
    
    rigidbody.i
    rbshape.i
    softbody.i
    mass.f
    
    selected.b
    wireframe_r.f
    wireframe_g.f
    wireframe_b.f
    
    *texture.Texture::Texture_t
    
    *parent.Object3D_t
    *model.Object3D_t
    List *children.Object3D_t()
    *stack.Stack::Stack_t
    Map *m_attributes.Attribute::Attribute_t()
    
  EndStructure
  
  
  Macro Object3D_ATTR()
    Protected *t.Transform::Transform_t = *Me\globalT
    Protected *global = Attribute::New("GlobalTransform",Attribute::#ATTR_TYPE_MATRIX4,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*t\m,#False,#True)
    Object3D::AddAttribute(*Me,*global)
    *t = *Me\localT
    Protected *local = Attribute::New("LocalTransform",Attribute::#ATTR_TYPE_MATRIX4,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*t\m,#False,#True)
    Object3D::AddAttribute(*Me,*local)
    Protected *viewvis = Attribute::New("ViewVisibility",Attribute::#ATTR_TYPE_BOOL,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\visible,#False,#True)
    Object3D::AddAttribute(*Me,*viewvis)
  EndMacro
  
  ; List& Map Management
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
  
  
  
  Interface IObject3D
   ; GetName.s()
    Delete()
    Setup(*shader.Program::Program_t)
    Update()
    Clean()
    Draw()
  EndInterface
  
  
  Declare.b IsA(*obj.Object3D_t,type.i)
  Declare Freeze(*obj.Object3D_t)
  Declare FreezeTransform(*obj.Object3D_t)
  Declare ResetLocalKinematicState(*obj.Object3D_t)
  Declare ResetGlobalKinematicState(*obj.Object3D_t)
  Declare ResetStaticKinematicState(*obj.Object3D_t)
  Declare AddChild(*obj.Object3D_t,*child.Object3D_t)
  Declare.b RemoveChild(*obj.Object3D_t,*child.Object3D_t)
;   Declare SetWireframeColor(*obj.Object3D_t,r.d,g.d,b.d)
;   Declare SetMaterial(*obj.Object3D_t,shader.i)
;   Declare GetMaterial(*obj.Object3D_t)
;   Declare GetUniqueID(*obj.Object3D_t)
  Declare SetLocalTransform(*Me.Object3D_t,*t.Transform::Transform_t)
  Declare GetGlobalTransform(*Me.Object3D_t)
  Declare SetGlobalTransform(*Me.Object3D_t,*t.Transform::Transform_t)
  Declare SetStaticTransform(*Me.Object3D_t,*t.Transform::Transform_t)
  Declare UpdateTransform(*obj.Object3D::Object3D_t,*pt.Transform::Transform_t=#Null)
  Declare UpdateLocalTransform(*obj.Object3D::Object3D_t)
  Declare GetAttribute(*obj.Object3D_t,name.s)
  Declare AddAttribute(*obj.Object3D_t,*attribute.Attribute::Attribute_t)
  Declare DeleteAttribute(*obj.Object3D_t,name.s)
  Declare DeleteAllAttributes(*obj.Object3D_t)
  Declare.b CheckAttributeExist(*obj.Object3D_t,attrname.s)
  Declare SetAttributeDirty(*obj.Object3D_t, attrname.s)
  Declare SetAttributeClean(*obj.Object3D_t, attrname.s)
  Declare SetShader(*obj.Object3D_t,*shader.Program::Program_t)
  ;   Declare SetVisibility(visible.b)
  Declare EncodeID(*color.v3f32,id.i)
  Declare DecodeID(r.GLubyte,g.GLubyte,b.GLubyte)
  Declare FindChildren(*obj.Object3D_t,name.s,type.i,*io_array.CArray::CArrayPtr,recurse.b)
    
EndDeclareModule


Module Object3D
  ; Is A
  ;--------------------------------------------------------------
  Procedure.b IsA(*obj.Object3D_t,type.i)
    ProcedureReturn Bool(*obj\type = type)
  EndProcedure
  ; Freeze
  ;--------------------------------------------------------------
  Procedure Freeze(*obj.Object3D_t)
    If *obj\type = Object3D::#Object3D_Polymesh
      Protected *geom.Geometry::PolymeshGeometry_t = *obj\geom
      PolymeshGeometry::GetTopology(*geom)
      Topology::Copy(*geom\base,*geom\topo)
      Stack::Clear(*obj\stack)
    EndIf
   
  EndProcedure
  
  ; FreezeTransform
  ;--------------------------------------------------------------
  Procedure FreezeTransform(*obj.Object3D_t)
    
  EndProcedure
  
  ; Reset Local Kinematic State
  ;--------------------------------------------------------------
  Procedure ResetLocalKinematicState(*obj.Object3D_t)
    Vector3::Set(*obj\localT\t\pos,0,0,0)
    Quaternion::SetIdentity(*obj\localT\t\rot)
    Vector3::Set(*obj\localT\t\scl,1,1,1)
    *obj\localT\srtdirty = #True
    Transform::UpdateMatrixFromSRT(*obj\localT)
  EndProcedure
  
  ; Reset Global Kinematic State
  ;--------------------------------------------------------------
  Procedure ResetGlobalKinematicState(*obj.Object3D_t)
    Vector3::Set(*obj\globalT\t\pos,0,0,0)
    Quaternion::SetIdentity(*obj\globalT\t\rot)
    Vector3::Set(*obj\globalT\t\scl,1,1,1)
    *obj\globalT\srtdirty = #True
    Transform::UpdateMatrixFromSRT(*obj\globalT)
  EndProcedure
  
  ; Reset Static Kinematic State
  ;--------------------------------------------------------------
  Procedure ResetStaticKinematicState(*obj.Object3D_t)
    Transform::SetFromOther(*obj\staticT,*obj\globalT)
  EndProcedure
  
  ; Remove Child
  ;--------------------------------------------------------------
  Procedure.b RemoveChild(*obj.Object3D_t,*child.Object3D_t)
    ForEach *obj\children()
      If *obj\children() = *child
        DeleteElement(*obj\children())
        Break;
      EndIf
    Next
  
  EndProcedure
  
  ; Add Child 
  ;--------------------------------------------------------------
  Procedure AddChild(*parent.Object3D_t,*child.Object3D_t)
    If *child\parent
      ForEach *child\parent\children()
        If *child\parent\children() = *child
          DeleteElement(*child\parent\children())
          Break;
        EndIf
      Next
    EndIf
    *child\parent = *parent
    
    If *parent\type = Object3D::#Object3D_Model
      *child\model = *parent
    Else
      *child\model = *parent\model
    EndIf
      
    AddElement(*parent\children())
    *parent\children() = *child
  EndProcedure
  
   ; Set Shader 
  ;--------------------------------------------------------------
  Procedure SetShader(*obj.Object3D_t,*shader.Program::Program_t)
    *obj\shader = *shader
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Set Transform
  ; ----------------------------------------------------------------------------
  Procedure SetLocalTransform(*Me.Object3D_t,*t.Transform::Transform_t)
    
    Protected i
    If *t\srtdirty
      Transform::UpdateMatrixFromSRT(*t)
      *t\srtdirty = #False
    EndIf
     If *t\matrixdirty
      Transform::UpdateSRTFromMatrix(*t)
      *t\matrixdirty = #False
    EndIf
    Protected *mt.Transform::Transform_t = *Me\localT
  
    For i=0 To 15
      *mt\m\v[i] = *t\m\v[i]
    Next i
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get Global Transform
  ; ----------------------------------------------------------------------------
  Procedure GetGlobalTransform(*Me.Object3D_t)
    ProcedureReturn(*Me\globalT)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Set Global Transform
  ; ----------------------------------------------------------------------------
  Procedure SetGlobalTransform(*Me.Object3D_t,*t.Transform::Transform_t)
    
    Protected i
    If *t\srtdirty
      Transform::UpdateMatrixFromSRT(*t)
      *t\srtdirty = #False
    EndIf
     If *t\matrixdirty
      Transform::UpdateSRTFromMatrix(*t)
      *t\matrixdirty = #False
    EndIf
    Protected *mt.Transform::Transform_t = *Me\globalT
  
    For i=0 To 15
      *mt\m\v[i] = *t\m\v[i]
    Next i
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Set Global Transform
  ; ----------------------------------------------------------------------------
  Procedure SetStaticTransform(*Me.Object3D_t,*t.Transform::Transform_t)
    
    Protected i

    Protected *mt.Transform::Transform_t = *Me\staticT
  
    For i=0 To 15
      *mt\m\v[i] = *t\m\v[i]
    Next i
    Transform::UpdateSRTFromMatrix(*Me\staticT)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get Static Kinematic State Transform
  ; ----------------------------------------------------------------------------
  Procedure GetStaticKinematicState(*Me.Object3D_t)
    ProcedureReturn(*Me\staticT)
  EndProcedure
  
  ;-----------------------------------------------
  ; Update Transform
  ;-----------------------------------------------
  Procedure UpdateTransform(*obj.Object3D::Object3D_t,*pt.Transform::Transform_t=#Null)
    Protected *local.Transform::Transform_t = *obj\localT
    If *pt = #Null
      If *obj\parent
        *pt = *obj\parent\globalT
      Else
        Matrix4::SetFromOther(*obj\globalT\m,*obj\localT\m)
        Transform::UpdateSRTFromMatrix(*obj\globalT)
        ProcedureReturn
      EndIf
    EndIf
    
    ; Multiply by Global Matrix of Parent Object
    Matrix4::Multiply(*obj\matrix,*pt\m,*obj\localT\m)

    ; Set Global Matrix
    Matrix4::SetFromOther(*obj\globalT\m,*obj\matrix)
    Transform::UpdateSRTFromMatrix(*obj\globalT)

  EndProcedure
  
  ;-----------------------------------------------
  ; Update Local Transform
  ;-----------------------------------------------
  Procedure UpdateLocalTransform(*obj.Object3D::Object3D_t)
    Protected *pt.Transform::Transform_t = *obj\parent\globalT
    Protected *local.Transform::Transform_t = *obj\localT
    Protected *global.Transform::Transform_t = *obj\globalT
    Protected inv.m4f32
    Protected m.m4f32
    Matrix4::Inverse(inv,*pt\m)
    
    ; Multiply by Global Matrix of Parent Object
    Matrix4::Multiply(m,*global\m,@inv)

    ; Set Local Matrix
    Matrix4::SetFromOther(*obj\localT\m,m)
    Transform::UpdateSRTFromMatrix(*obj\localT)

  EndProcedure

  ;-----------------------------------------------
  ; Get Attribute
  ;-----------------------------------------------
  Procedure GetAttribute(*obj.Object3D_t,name.s)
    If Not *obj\m_attributes(name)
      ProcedureReturn #Null
    Else
      ProcedureReturn *obj\m_attributes(name)
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Add Attribute
  ;-----------------------------------------------
  Procedure AddAttribute(*obj.Object3d_t,*attribute.Attribute::Attribute_t)
    If Not *obj : ProcedureReturn : EndIf
    If Not *attribute : ProcedureReturn : EndIf
    
    If *obj\m_attributes(*attribute\name)
      Debug "C3DObject ["+*obj\name+"]: Attribute "+*attribute\name+" Already exists !! "
      ProcedureReturn #Null
    Else
      Object3D::AttachMapElement(*obj\m_attributes(),*attribute\name,*attribute)
    EndIf

  EndProcedure
  
  ;-----------------------------------------------
  ; Delete Attribute
  ;-----------------------------------------------
  Procedure DeleteAttribute(*obj.Object3D_t,name.s)
    If Not *obj : ProcedureReturn : EndIf
  
    If *obj\m_attributes(name)
      Protected *attribute.Attribute::Attribute_t = *obj\m_attributes(name)
      DeleteMapElement(*obj\m_attributes(),name)
      Attribute::Delete(*attribute)
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Delete All Attributes
  ;-----------------------------------------------
  Procedure DeleteAllAttributes(*obj.Object3D_t)
    If Not *obj : ProcedureReturn : EndIf
    
    ForEach *obj\m_attributes()
      Protected *attribute.Attribute::Attribute_t = *obj\m_attributes()
      DeleteMapElement(*obj\m_attributes())
      Attribute::Delete(*attribute)
    Next
    
    FreeMap(*obj\m_attributes())
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Check Attribute Exists
  ;-----------------------------------------------
  Procedure.b CheckAttributeExist(*obj.Object3D_t,attrname.s)
    If *obj\m_attributes(attrname)
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Set Attribute Dirty
  ;-----------------------------------------------
  Procedure SetAttributeDirty(*obj.Object3D_t,attrname.s)
    If *obj\m_attributes(attrname)
      *obj\m_attributes(attrname)\dirty = #True
    EndIf
  EndProcedure
  
  ;-----------------------------------------------
  ; Set Attribute Clean
  ;-----------------------------------------------
  Procedure SetAttributeClean(*obj.Object3D_t,attrname.s)
    If *obj\m_attributes(attrname)
      *obj\m_attributes(attrname)\dirty = #False
    EndIf
  EndProcedure
  
  ;-----------------------------------------------
  ; Encode ID
  ;-----------------------------------------------
  Procedure EncodeID(*color.v3f32,id.i)
    Protected r = (id & $0000FF) >>  0
    Protected g = (id & $00FF00) >>  8
    Protected b = (id & $FF0000) >> 16
    *color\x = r / 255
    *color\y = g / 255
    *color\z = b / 255
  EndProcedure
  
  ;-----------------------------------------------
  ; Encode ID
  ;-----------------------------------------------
  Procedure DecodeID(x.GLubyte,y.GLubyte,z.GLubyte)
    ProcedureReturn x + y * 256 + z * 256 * 256
  EndProcedure
  
  
  ;-----------------------------------------------
  ; Child Match Name
  ;-----------------------------------------------
  Procedure.b ChildMatchName(*obj.Object3D::Object3D_t,name.s)
    If name = "" : ProcedureReturn #True : EndIf
    If FindString(name,"*")
      If FindString(*obj\name,RemoveString(name,"*"))
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
      
    Else
      If *obj\name = name
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Child Match
  ;-----------------------------------------------
  Procedure.b ChildMatch(*obj.Object3D::Object3D_t,name.s,type.i)
    If type >-1
      If *obj\type = type
        ProcedureReturn  ChildMatchName(*obj,name)
      EndIf
    Else
      ProcedureReturn  ChildMatchName(*obj,name)
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
   ;-----------------------------------------------
  ; Find Children
  ;-----------------------------------------------
  Procedure FindChildren(*obj.Object3D_t,name.s,type.i,*io_array.CArray::CArrayPtr,recurse.b)
    ForEach *obj\children()
      If recurse
        FindChildren(*obj\children(),name.s,type.i,*io_array,recurse)
      EndIf
      If ChildMatch(*obj\children(),name,type)
        CArray::AppendUnique(*io_array,*obj\children())
      EndIf
    Next
    
  EndProcedure

EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 361
; FirstLine = 336
; Folding = ------
; EnableXP
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../libs/Bullet.pbi"

; ============================================================================
;  Bullet RigidBody Object 
; ============================================================================
;  2014/02/17 | Ben Malartre
; ============================================================================
DeclareModule BulletRigidBody
  ; ============================================================================
  ;  STRUCTURES
  ; ===========================================================================
  Structure BTRigidBody_t Extends Object::Object_t
    *obj.Object3D::Object3D_t
    *body.btRigidBody
    *shape.btShape 
    vao.i
    vbo.i
  EndStructure
  
  Declare Setup(*body.BTRigidBody_t,contextID.i)
  Declare Draw(*body.BTRigidBody_t)
  Declare BTAddRigidBodyFromShape(*obj.Object3D::Object3D_t,*shape.Bullet::btCollisionShape,mass.f,*world.Bullet::btDynamicsWorld=#Null)
  Declare BTConvexHullCollisionShape(*obj.Object3D::Object3D_t)
  Declare BTConvexDecompositionCollisionShape(*obj.Object3D::Object3D_t)
  Declare BTTriangleMeshCollisionShape(*obj.Object3D::Object3D_t)
  Declare BTCreateRigidBodyFrom3DObject(*obj.Object3D::Object3D_t,shapetype.i,mass.f,*world.Bullet::btDynamicsWorld=#Null)
  Declare BTCreateCompoundRigidBodyFrom3DObjects(*objs.CArray::CArrayPtr,shapetype.i,mass.f)
  Declare BTCreateSoftBodyFrom3DObject(*obj.Object3D::Object3D_t,shapetype.i,mass.f,*world.Bullet::btDynamicsWorld=#Null)
  
EndDeclareModule

Module BulletRigidBody
  ;-----------------------------------------------------
  ; Setup 
  ;-----------------------------------------------------
  Procedure Setup(*body.BTRigidBody_t,contextID.i)
    ;---[ Check Datas ]--------------------------------
    If Not *body : ProcedureReturn : EndIf
    
    ;---[ Get Underlying Shape ]--------------------
    Protected *shape.Bullet::btCollisionShape = *body\shape
    
  
    Protected GLfloat_s.f
    Protected GLint_s.i
    Protected i.i
    
  ;   ; Get Polymesh Datas
  ;   Protected size_p.i = nbv * SizeOf(GLfloat_s) * 3
  ;   Protected size_n.i = nbv * SizeOf(GLfloat_s) * 3
  ;   Protected size_c.i = nbv * SizeOf(GLfloat_s) * 4
  ;   Protected size_t.i = size_p + size_n + size_c
  ;   
  ;   If size_t = 0 : ProcedureReturn :EndIf
  ;   
  ;   ;Main GL Context Shared Datas
  ;   If contextID = 0
  ; 
  ;     ; Setup Static Kinematic STate
  ;     O3DObject_ResetStaticKinematicState(*p)
  ;     
  ;     ;Attach Shader
  ;     *p\shader = *gl_context\s_polymesh
  ; ;     
  ; ;     If *p\vao
  ; ;       Protected x
  ; ;       For x=0 To ArraySize(*p\vaos())-1
  ; ;         If *p\vaos(x) :   glDeleteVertexArrays(1,*p\vaos(x)) : EndIf
  ; ;       Next x 
  ; ;       glDeleteVertexArrays(1,*p\vao)
  ; ;       
  ; ;     EndIf
  ;     
  ;     ; Create Vertex Array Object
  ;     glGenVertexArrays(1,@*p\vao)
  ;     glBindVertexArray(*p\vao)
  ;     
  ;     ; Create Vertex Buffer Object
  ;     glGenBuffers(1,@*p\vbo)
  ;     glBindBuffer(#GL_ARRAY_BUFFER,*p\vbo)
  ;     
  ;     ; Fill Buffer
  ;     OPolymesh_BuildGLData(*p)
  ;     
  ;     ; Create Edge Elements Buffer
  ;     glGenBuffers(1,@*p\eab)
  ;     glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,*p\eab)
  ;     glBufferData(#GL_ELEMENT_ARRAY_BUFFER,*geom\a_edgeindices\GetCount()*SizeOf(GLint_s),*geom\a_edgeindices\GetPtr(),#GL_DYNAMIC_DRAW)
  ;   
  ;     glBindVertexArray(0)
  ;     
  ;     *p\initialized = #True
  ;     
  ;   ; Per Context Datas
  ; Else
  ;   
  ;     ; Delete existing data
  ;      ;If *p\vaos(contextID): glDeleteVertexArrays(1,@*p\vaos(contextID)) : EndIf
  ; 
  ;     glGenVertexArrays(1,@*p\vaos(contextID))
  ;     glBindVertexArray(*p\vaos(contextID))
  ; 
  ;     glBindBuffer(#GL_ARRAY_BUFFER,*p\vbo)
  ;     glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,*p\eab)
  ;     ; Attibute Position
  ;     Protected uPosition.GLint = glGetAttribLocation(*p\shader,"position")
  ;     glEnableVertexAttribArray(uPosition)
  ;     glVertexAttribPointer(uPosition,3,#GL_FLOAT,#GL_FALSE,0,0)
  ;     
  ;     ;Attibute Normal
  ;     Protected uNormal.GLint = glGetAttribLocation(*p\shader,"normal")
  ;     glEnableVertexAttribArray(uNormal)
  ;     glVertexAttribPointer(uNormal,3,#GL_FLOAT,#GL_FALSE,0,size_p)
  ;     
  ;     ; Attribute Color
  ;     Protected uColor.GLint = glGetAttribLocation(*p\shader,"color")
  ;     glVertexAttribPointer(uColor,4,#GL_FLOAT,#GL_FALSE,0,size_p+size_n)
  ;     glEnableVertexAttribArray(uColor)
  ;     
  ;   EndIf
     
  EndProcedure
  
  ;-----------------------------------------------
  ; Draw Rigid Body
  ;-----------------------------------------------
  Procedure Draw(*body.BTRigidBody_t)
    Protected mat.Bullet::btMatrix4
    Bullet::BTGetMatrix(*body\body,@mat)
    
    ;*body\shape
  EndProcedure
  
  ;-----------------------------------------------
  ; Add Rigid Body From Shape
  ;-----------------------------------------------
  Procedure BTAddRigidBodyFromShape(*obj.Object3D::Object3D_t,*shape.Bullet::btCollisionShape,mass.f,*world.Bullet::btDynamicsWorld=#Null)
    If *shape
      Protected *body.Bullet::btRigidBody = Bullet::BTCreateRigidBody(*obj,mass,*shape)
      Protected *t.Transform::Transform_t = *obj\localT
      
      Bullet::BTSetScaling(*body,*t\t\scl)
      Bullet::BTSetOrientation(*body,*t\t\rot)
      Bullet::BTSetPosition(*body,*t\t\pos)
      
      If *world = #Null : *world = Bullet::*bullet_world : EndIf
      Bullet::BTAddRigidBody(*world, *body)
      *obj\rigidbody = *body
      *obj\rbshape = *shape
      ProcedureReturn *body
    EndIf
  EndProcedure
  
  ;-----------------------------------------------
  ; Construct ConvexHull from Polymesh
  ;-----------------------------------------------
  Procedure BTConvexHullCollisionShape(*obj.Object3D::Object3D_t)
    
    Protected *geom.Geometry::PolymeshGeometry_t = *obj\geom
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define size_t = *geom\nbpoints * 12
      Protected *mem = AllocateMemory(size_t)
      Define i
      For i=0 To *geom\nbpoints-1
        CopyMemory(*geom\a_positions\data + i * 16, *mem + i * 12, 12)  
      Next
      
;       CopyMemory(*geom\a_positions\data, *mem, size_t)
;       Memory::UnshiftAlign(*mem, *geom\nbpoints, 16, 12)
      Protected *shape.Bullet::btCollisionShape = Bullet::BTNewConvexHullShape(*geom\nbtriangles,CArray::GetPtr(*geom\a_triangleindices,0),*geom\nbpoints,*mem)
      FreeMemory(*mem)
    CompilerElse
      Protected *shape.Bullet::btCollisionShape = Bullet::BTNewConvexHullShape(*geom\nbtriangles,CArray::GetPtr(*geom\a_triangleindices,0),*geom\nbpoints,CArray::GetPtr(*geom\a_positions,0))
    CompilerEndIf

    ProcedureReturn *shape
  EndProcedure
  
  ;-----------------------------------------------
  ; Construct ConvexDecomposition from Polymesh
  ;-----------------------------------------------
  Procedure BTConvexDecompositionCollisionShape(*obj.Object3D::Object3D_t)
    
    Protected *geom.Geometry::PolymeshGeometry_t = *obj\geom
    Debug "ConvexDecompositionShape Called for "+*obj\name
    ;Debug "Nb Cluster Afetr Convex Decomposition : "+Str(BTNewConvexDecompositionShape(*geom\nbtriangles,*geom\a_triangleindices\GetPtr(),*geom\nbpoints,*geom\a_positions\GetPtr()))
     Protected *shape.Bullet::btCollisionShape ;BTNewConvexDecompositionShape(*geom\nbtriangles,*geom\a_triangleindices\GetPtr(),*geom\nbpoints,*geom\a_positions\GetPtr())
  
    ProcedureReturn *shape
  EndProcedure
  
  ;-----------------------------------------------
  ; Construct Triangle Mesh from Polymesh
  ;-----------------------------------------------
  Procedure BTTriangleMeshCollisionShape(*obj.Object3D::Object3D_t)
    Protected *shape.Bullet::btCollisionShape
    Protected *geom.Geometry::PolymeshGeometry_t = *obj\geom
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      *shape = Bullet::BTNewBvhTriangleMeshShape(*geom\nbtriangles,
                                                 CArray::GetPtr(*geom\a_triangleindices,0),
                                                 *geom\nbpoints, 
                                                 CArray::GetPtr(*geom\a_positions,0), 
                                                 #True)
    CompilerElse
      *shape = Bullet::BTNewBvhTriangleMeshShape(*geom\nbtriangles,
                                                 CArray::GetPtr(*geom\a_triangleindices,0),
                                                 *geom\nbpoints, 
                                                 CArray::GetPtr(*geom\a_positions,0), 
                                                 #False)
    CompilerEndIf
          
    ProcedureReturn *shape
  EndProcedure
  
  ;-----------------------------------------------
  ; Construct GImpact Mesh from Polymesh
  ;-----------------------------------------------
  Procedure BTGImpactCollisionShape(*obj.Object3D::Object3D_t)
    Protected *shape.Bullet::btCollisionShape
    Protected *geom.Geometry::PolymeshGeometry_t = *obj\geom
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define size_t = *geom\nbpoints * 16
      Protected *mem = AllocateMemory(size_t)
      CopyMemory(*geom\a_positions\data, *mem, size_t)
      Memory::UnshiftAlign(*mem, *geom\nbpoints, 16, 12)
      *shape = Bullet::BTNewGImpactShape(*geom\nbtriangles,CArray::GetPtr(*geom\a_triangleindices,0),*geom\nbpoints, *mem)
      FreeMemory(*mem)
    CompilerElse
      *shape = Bullet::BTNewGImpactShape(*geom\nbtriangles,CArray::GetPtr(*geom\a_triangleindices,0),*geom\nbpoints,CArray::GetPtr(*geom\a_positions,0))
    CompilerEndIf
          
    ProcedureReturn *shape
  EndProcedure
  
  
  ;-----------------------------------------------
  ; Create Rigid Body From 3D Object
  ;-----------------------------------------------
  Procedure BTCreateRigidBodyFrom3DObject(*obj.Object3D::Object3D_t,shapetype.i,mass.f,*world.Bullet::btDynamicsWorld=#Null)
    Protected *shape.Bullet::btCollisionShape = #Null
    *obj\mass = mass
    
;     CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
;        CArray::UnshiftAlign(*obj\geom\a_positions\data, *obj\geom\nbpoints, 16, 12)  
;      CompilerEndIf
     
    Select shapetype
      Case Bullet::#GROUNDPLANE_SHAPE
          Protected norm.Math::v3f32
          Vector3::Set(norm,0,1,0)
        *shape = Bullet::BTNewGroundPlaneShape(norm,*obj\localT\t\scl\x)
        
      Case Bullet::#BOX_SHAPE
        *shape = Bullet::BTNewBoxShape(0.5,0.5,0.5)
    
      Case Bullet::#SPHERE_SHAPE
        *shape = Bullet::BTNewSphereShape(0.5)
      Case Bullet::#CYLINDER_SHAPE
        *shape = Bullet::BTNewCylinderShape(0.5,1)
      Case Bullet::#CAPSULE_SHAPE
        *shape = Bullet::BTNewCapsuleShape(0.5,1)
      Case Bullet::#CONE_SHAPE
        *shape = Bullet::BTNewConeShape(0.5,1)
     Case Bullet::#CONVEXHULL_SHAPE
        ; only works on Polymesh
        If Not *obj\type = Object3D::#Polymesh : ProcedureReturn :EndIf
        *shape = BTConvexHullCollisionShape(*obj)
       Case Bullet::#CONVEXDECOMPOSITION_SHAPE
        ; only works on Polymesh
        If Not *obj\type = Object3D::#Polymesh : ProcedureReturn :EndIf
       *shape =  BTConvexDecompositionCollisionShape(*obj)
        
      Case Bullet::#TRIANGLEMESH_SHAPE
        ; only works on Polymesh
        If Not *obj\type = Object3D::#Polymesh : ProcedureReturn :EndIf
        
        *shape = BTTriangleMeshCollisionShape(*obj)
  
      Case Bullet::#GIMPACT_SHAPE
        If Not *obj\type = Object3D::#Polymesh : ProcedureReturn :EndIf
        Protected *mesh.Polymesh::Polymesh_t = *obj
        Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
        *shape = BTGImpactCollisionShape(*obj)

    EndSelect 
    
;     CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
;       CArray::ShiftAlign(*obj\geom\a_positions\data, *obj\geom\nbpoints, 12, 16) 
;     CompilerEndIf
    
    If *shape
      Protected *body.Bullet::btRigidBody = BTAddRigidBodyFromShape(*obj,*shape,mass,*world)
      ProcedureReturn *body
    Else
      MessageRequester("BULLET", "Can Not Create Rigid Body Shape For "+*obj\name)
    EndIf

  EndProcedure
  
  ;-----------------------------------------------
  ; Create Compound Rigid Body From 3D Objects Array
  ;-----------------------------------------------
  Procedure BTCreateCompoundRigidBodyFrom3DObjects(*objs.CArray::CArrayPtr,shapetype.i,mass.f)
  
    Protected *child.Object3D::Object3D_t
    Protected *pshape.Bullet::btCollisionShape = Bullet::BTNewCompoundShape()
    Protected *cshape.Bullet::btCollisionShape
    Protected *tc.Transform::Transform_t
  
    Protected c
    For c=0 To CArray::GetCount(*objs)-1
      *child = CArray::GetValue(*objs,c)
      *tc = *child\globalT

      Select shapetype
        Case Bullet::#GROUNDPLANE_SHAPE
          Protected norm.Math::v3f32
          Vector3::Set(norm,0,1,0)
          *cshape = Bullet::BTNewGroundPlaneShape(@norm, 100)
        Case Bullet::#BOX_SHAPE
          *cshape = Bullet::BTNewBoxShape(0.5,0.5,0.5)
        Case Bullet::#SPHERE_SHAPE
          *cshape = Bullet::BTNewSphereShape(1)
        Case Bullet::#CYLINDER_SHAPE
          *cshape = Bullet::BTNewCylinderShape(0.5,1)
        Case Bullet::#CAPSULE_SHAPE
          *cshape = Bullet::BTNewCapsuleShape(0.5,1)
        Case Bullet::#CONE_SHAPE
          *cshape = Bullet::BTNewConeShape(0.5,1)
        Case Bullet::#CONVEXHULL_SHAPE      ; only works on Polymesh
          If Not *child\type = Object3D::#Polymesh : Return :EndIf

        Case Bullet::#TRIANGLEMESH_SHAPE    ; only works on Polymesh
          If Not *child\type = Object3D::#Polymesh : Return :EndIf
          *cshape = BTTriangleMeshCollisionShape(*child)
          
        Case Bullet::#GIMPACT_SHAPE         ; only works on Polymesh
          If Not *child\type  = Object3D::#Polymesh : Return :EndIf
          *cshape = BTGImpactCollisionShape(*child)

      EndSelect 
      Bullet::BTAddChildShape(*pshape,*cshape,*tc\t\pos,*tc\t\rot)

    Next c
    
    Protected *body.Bullet::btRigidBody = BTAddRigidBodyFromShape(CArray::GetValue(*objs,0),*pshape,mass)
    Protected *out.BTRigidBody_t = AllocateStructure(BTRigidBody_t)
    *out\body = *body
    *out\shape = *pshape
    ProcedureReturn *out
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Create Rigid Body From Instance Cloud
  ;-----------------------------------------------
  Procedure BTCreateRigidBodyFromInstanceCloud(*cloud.InstanceCloud::InstanceCloud_t,shapetype.i,mass.f,*world.Bullet::btDynamicsWorld=#Null)
    Protected *shape.Bullet::btCollisionShape = #Null
    Protected *s.Geometry::Shape_t = *cloud\shape
    Select shapetype
      Case Bullet::#GROUNDPLANE_SHAPE
          Protected norm.Math::v3f32
          Vector3::Set(norm,0,1,0)
        *shape = Bullet::BTNewGroundPlaneShape(norm,1)
        
      Case Bullet::#BOX_SHAPE
        *shape = Bullet::BTNewBoxShape(0.5,0.5,0.5)
    
      Case Bullet::#SPHERE_SHAPE
        *shape = Bullet::BTNewSphereShape(0.5)
      Case Bullet::#CYLINDER_SHAPE
        *shape = Bullet::BTNewCylinderShape(0.5,1)
      Case Bullet::#CAPSULE_SHAPE
        *shape = Bullet::BTNewCapsuleShape(0.5,1)
      Case Bullet::#CONE_SHAPE
        *shape = Bullet::BTNewConeShape(0.5,1)
     Case Bullet::#CONVEXHULL_SHAPE
        ; only works on Polymesh
        If Not *cloud\type = Object3D::#InstanceCloud : ProcedureReturn :EndIf
        *shape = BTConvexHullCollisionShape(*obj)
       Case Bullet::#CONVEXDECOMPOSITION_SHAPE
        ; only works on Polymesh
        If Not *cloud\type = Object3D::#InstanceCloud  : ProcedureReturn :EndIf
       *shape =  BTConvexDecompositionCollisionShape(*obj)
        
      Case Bullet::#TRIANGLEMESH_SHAPE
        ; only works on Polymesh
        If Not *cloud\type = Object3D::#InstanceCloud  : ProcedureReturn :EndIf
        
        *shape = BTTriangleMeshCollisionShape(*obj)
  
      Case Bullet::#GIMPACT_SHAPE
        If Not *cloud\type = Object3D::#InstanceCloud  : ProcedureReturn :EndIf
        Protected *mesh.Polymesh::Polymesh_t = *obj
        Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
        *shape = BTGImpactCollisionShape(*obj)

    EndSelect 
    
;     CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
;       CArray::ShiftAlign(*obj\geom\a_positions\data, *obj\geom\nbpoints, 12, 16) 
;     CompilerEndIf
    
    If *shape
      Define nbp = *cloud\geom\nbpoints
      
      Protected *body.Bullet::btRigidBody = BTAddRigidBodyFromShape(*obj,*shape,mass,*world)
;       ProcedureReturn *body
    Else
      MessageRequester("BULLET", "Can Not Create Rigid Body Shape For Instance Cloud "+*cloud\name)
    EndIf

  EndProcedure
  
  
  ;-----------------------------------------------
  ; Create Soft Body From 3D Object
  ;-----------------------------------------------
  Procedure BTCreateSoftBodyFrom3DObject(*obj.Object3D::Object3D_t,shapetype.i,mass.f,*world.Bullet::btDynamicsWorld=#Null)
    Protected *sbd.Bullet::btSoftBody 
    Protected *mesh.Polymesh::Polymesh_t
    Protected *geom.Geometry::PolymeshGeometry_t
    
    
    If Not *obj\type = Object3D::#Polymesh : Return :EndIf
    Protected *t.Transform::Transform_t = *obj\globalT
    *mesh = *obj
    *geom = *mesh\geom
    
    
    Select shapetype
     Case Bullet::#CONVEXHULL_SHAPE
       ; only works on Polymesh
  
       *sbd = Bullet::BTCreateSoftBodyFromConvexHull(*obj,Bullet::*bullet_sdk,CArray::GetPtr(*geom\a_positions,0),CArray::GetPtr(*geom\a_triangleindices,0),*geom\nbtriangles)
  ;      BTTranslate(*sbd,0,Random(100),0)
       Case Bullet::#CONVEXDECOMPOSITION_SHAPE
        ; only works on Polymesh
        If Not *obj\type = Object3D::#Polymesh : Return :EndIf
        
      Case Bullet::#TRIANGLEMESH_SHAPE
        ; only works on Polymesh
        If Not *obj\type = Object3D::#Polymesh : Return :EndIf
        
        *sbd = Bullet::BTCreateSoftBodyFromTriMesh(*obj,Bullet::*bullet_sdk,CArray::GetPtr(*geom\a_positions,0),CArray::GetPtr(*geom\a_triangleindices,0),*geom\nbtriangles)
  
      Case Bullet::#GIMPACT_SHAPE
        If Not *obj\type = Object3D::#Polymesh : Return :EndIf
        
      Case Bullet::#CLUSTERED_SHAPE
        If Not *obj\type = Object3D::#Polymesh : Return :EndIf
        *sbd = Bullet::BTCreateClusterSoftBodyFromTriMesh(*obj,Bullet::*bullet_sdk,CArray::GetPtr(*geom\a_positions,0),CArray::GetPtr(*geom\a_triangleindices,0),*geom\nbtriangles,12)
    EndSelect 
    
    If *sbd
      
      If *world = #Null : *world = *bullet_world : EndIf
      *obj\softbody = *sbd
    EndIf
    
    ProcedureReturn *sbd
  
  EndProcedure
  
  
  
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 350
; FirstLine = 346
; Folding = ---
; EnableXP
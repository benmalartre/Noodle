XIncludeFile "../core/Math.pbi"

; ============================================================================
;  BULLET WORLD DECLARATION
; ============================================================================
DeclareModule BulletWorld

  Structure BTWorld_t Extends Object::Object_t
    *world.btDynamicsWorld
    *ground.bTRigidBody
  ;   *statics.CArrayPtr()
  ;   *dynamics.CArrayPtr()
  ;   *constraints.CArrayPtr()
    
  EndStructure
  
  Declare New()
  Declare Delete( *Me.BTWorld_t )
  Declare Update(*Me.BTWorld_t)
  Declare SetGravity(*Me.BTWorld_t,x.f=0,y.f=-10,z.f=0)
  Declare Reset(*Me.BTWorld_t)
  Declare AddGroundPlane(*Me.BTWorld_t)
  Declare hlpUpdate(*world.Bullet::btDynamicsWorld,time_step.f=0.1)
  Declare hlpReset(*world.Bullet::btDynamicsWorld)
EndDeclareModule

; ============================================================================
;  BULLET WORLD IMPLEMENTATION
; ============================================================================
Module BulletWorld
  UseModule Math
  ;-----------------------------------------------
  ; Update ONE Rigid Body
  ;-----------------------------------------------
  Procedure hlpUpdateChild(*obj.Object3D::Object3D_t)
    If Not *obj: ProcedureReturn : EndIf
    
    If *obj\rigidbody
      Protected *child.Object3D::Object3D_t
    
      Protected *t.Transform::Transform_t = *obj\localT

      Protected p.v3f32
      Protected q.q4f32
    
      Bullet::BTGetPosition(*obj\rigidbody,p)
      Bullet::BTGetOrientation(*obj\rigidbody,q)
      
      Protected *q.q4f32 = *t\t\rot
      Transform::SetTranslationFromXYZValues(*t,p\x, p\y, p\z)
      Quaternion::Set(*q,q\x,q\y,q\z,q\w)
      Transform::SetRotationFromQuaternion(*t,*q)
      Object3D::SetGlobalTransform(*obj,*t)
    ElseIf *obj\softbody
        Debug "Soft Body Update Called"
  ;     Protected *mesh.Cpolymesh_t =*obj
  ;     Protected *geom.CPolymeshGeometry_t = *mesh\geometry
  ;    Debug "Nb Points ---> "+Str( BTUpdatePointPosition(*obj\softbody,*geom\a_positions\GetPtr()))
  ;     
    EndIf
  EndProcedure
  
  ;-----------------------------------------------
  ; Update ALL Rigid Bodies
  ;-----------------------------------------------
  Procedure hlpUpdate(*world.Bullet::btDynamicsWorld,time_step.f=0.1)
   
    Bullet::BTStepSimulation(*world,time_step)
    Protected i
    Protected nbb = Bullet::BTGetNumCollideObjects(*world)
   
    Protected *rbody.Bullet::btRigidBody
    Protected *sbody.Bullet::btSoftBody
    Protected *obj.Object3D::Object3D_t

    For i=0 To nbb-1
      ;If BTGetBodyType(*world,i) = #
      *rbody = Bullet::BTGetRigidBodyByID(*world,i)
      
      If(*rbody)
        *obj = Bullet::BTGetUserData(*rbody)
        If *obj
          hlpUpdateChild( *obj)
        EndIf
      EndIf
  
    Next i
    
    Protected nbs = Bullet::BTGetNumSoftBodies(*world)
    Protected *mesh.Polymesh::Polymesh_t
    Protected *geom.Geometry::PolymeshGeometry_t
    For i=0 To nbs-1
      *sbody = Bullet::BTGetSoftBodyByID(*world,i)
      
      If *sbody
        *obj = Bullet::BTGetUserData(*sbody)
        If *obj
          *mesh = *obj
          *geom = *mesh\geom
          Debug "Soft Body Ptr -----------> "+Str(*sbody)
          Debug "Soft Body Nb Points : "+Str(Bullet::BTGetSoftBodyNbVertices(*sbody))
          Debug "Soft Body Nb Faces : "+Str(Bullet::BTGetSoftBodyNbFaces(*sbody))
          Debug "Soft Body Nb Nodes : "+Str(Bullet::BTGetSoftBodyNbNodes(*sbody))
          
          Bullet::BTUpdateSoftBodyGeometry(*sbody,CArray::GetPtr(*geom\a_positions,0))
          PolymeshGeometry::RecomputeNormals(*geom,0.0)
          ;*mesh\topodirty = #True
          *mesh\deformdirty = #True
        Else
          Debug "Soft Body doesn't have User Data..."
        EndIf
      
        
      Else
        Debug "Can't find Soft Body by ID!!!"
      EndIf
    Next i
    
     
  EndProcedure
  
  ;-----------------------------------------------
  ; Reset All Rigid Bodies  
  ;-----------------------------------------------
  Procedure hlpReset(*world.Bullet::btDynamicsWorld)
    
    Protected i
    Protected nbb = Bullet::BTGetNumCollideObjects(*world)
    MessageRequester("Bullet", "Nb Collide Objects : "+Str(nbb))
    Protected *body.Bullet::btRigidBody
    Protected *obj.Object3D::Object3D_t
    Protected *state.Transform::Transform_t
    Protected *m.m4f32
    For i=0 To nbb-1
      Debug "Reset Rigid Body ID "+Str(i) 
      *body = Bullet::BTGetRigidBodyByID(*world,i)
      *obj = Bullet::BTGetUserData(*body)
      If Not *obj : Continue :EndIf

      If *obj\mass>0
        *m = *obj\staticT\m
        ;Bullet::BTSetMatrix(*body,*m)
        Bullet::BTSetPosition(*body,*obj\staticT\t\pos)
        Object3D::SetGlobalTransform(*obj,*obj\staticT)
        ;Object3D::
        ;*obj\SetGlobalTransform(*state)
      EndIf
    Next i
    
    MessageRequester("Bullet","Reset Called")
  EndProcedure
  
  Procedure AddGroundPlane(*Me.BTWorld_t)
    ;Bullet::BTCreate
  EndProcedure
  
  
  
  
  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  
  
  ;-----------------------------------------------
  ; Update All Rigid Bodies
  ;-----------------------------------------------
  Procedure Update(*Me.BTWorld_t)
    If Not *Me:ProcedureReturn : EndIf
    
    Debug "----------------------> Bullet World Update!!!"
    hlpUpdate(*Me\world,1/25)
  ;   dynamicsWorld->stepSimulation(1.f/25.0f,10);
  ; 		
  ; 	//print positions of all objects
  ; 	For (int j=dynamicsWorld->getNumCollisionObjects()-1; j>=0 ;j--)
  ; 	{
  ; 		btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[j];
  ; 		btRigidBody* body = btRigidBody::upcast(obj);
  ; 		If (body && body->getMotionState())
  ; 		{
  ; 			btTransform trans;
  ; 			body->getMotionState()->getWorldTransform(trans);
  ; 			printf("world pos = %f,%f,%f\n",float(trans.getOrigin().getX()),float(trans.getOrigin().getY()),float(trans.getOrigin().getZ()));
  ; 		}
  ; 		}
  
    
  EndProcedure
  
  ;-----------------------------------------------
  ; Set Gravity
  ;-----------------------------------------------
  Procedure SetGravity(*Me.BTWorld_t,x.f=0,y.f=-10,z.f=0)
    If Not*Me : ProcedureReturn : EndIf
    
    Protected gravity.v3f32
    Vector3::Set(gravity,x,y,z)
    Bullet::BTSetGravity(*Me\world,@gravity)
  EndProcedure
  
  ;-----------------------------------------------
  ; Reset All Rigid Bodies
  ;-----------------------------------------------
  Procedure Reset(*Me.BTWorld_t)
    hlpReset(*Me\world)
  EndProcedure

  
  ; ----------------------------------------------------------------------------
  ;  Destructor
  ; ----------------------------------------------------------------------------
  Procedure Delete( *Me.BTWorld_t )
    Bullet::BTDeleteDynamicsWorld(*Me\world)
    ClearStructure(*Me,BTWorld_t)
    FreeMemory(*Me)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New()
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.BTWorld_t = AllocateMemory( SizeOf(BTWorld_t) )
    
    ; ---[ Initialize Structure ]------------------------------------------------
    InitializeStructure(*Me,BTWorld_t)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\world = Bullet::BTCreateDynamicsWorld(Bullet::*bullet_sdk)
    MessageRequester("Bullet","Created Dynamics World")
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

EndModule
; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 74
; FirstLine = 61
; Folding = --
; EnableXP
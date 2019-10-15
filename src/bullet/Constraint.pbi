XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "RigidBody.pbi"

; Macro btConstraintType:i:EndMacro
;   Enumeration
;   	#CONSTRAINT_POINT2POINT=3
;   	#CONSTRAINT_HINGE
;   	#CONSTRAINT_CONETWIST
;   	#CONSTRAINT_D6
;   	#CONSTRAINT_SLIDER
;   	#CONSTRAINT_CONTACT
;   	#CONSTRAINT_D6_SPRING
;   	#CONSTRAINT_GEAR
;   	#CONSTRAINT_MAX
;   EndEnumeration

; ============================================================================
;  Bullet Constraint Object 
; ============================================================================
;  2014/02/17 | Ben Malartre
; ============================================================================
DeclareModule BulletConstraint
  UseModule Math
  ; ============================================================================
  ;  STRUCTURES
  ; ===========================================================================
  Structure BTConstraint_t Extends Object::Object_t
    *objA.Object3D::Object3D_t
    *objB.Object3D::Object3D_t
    *bodyA.Bullet::btRigidBody
    *bodyB.Bullet::btRigidBody

    vao.i
    vbo.i
    
    *cns.Bullet::btConstraint
  EndStructure
  
  Declare Setup(*body.BTConstraint_t)
  Declare Draw(*body.BTConstraint_t)
  Declare New(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32,type.i,*axis1.v3f32=#Null,*axis2.v3f32=#Null)
  Declare NewHinge(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32,*axis1.v3f32,*axis2.v3f32,usereferenceframe.b=#False)
  Declare NewPoint2Point(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32)
  Declare NewGear(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32)
  Declare NewSlider(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32)
  Declare NewGeneric6Dof(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*frameA.trf32,*frameB.trf32)
  Declare NewConeTwist(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*frameA.trf32,*frameB.trf32)
  Declare Delete(*cns.BTConstraint_t)
EndDeclareModule

Module BulletConstraint
  UseModule Math
  
  Procedure Setup(*body.BTConstraint_t)
    
  EndProcedure
  
  Procedure Draw(*body.BTConstraint_t)
    
  EndProcedure
  
  ; Hinge Constraint
  ;-------------------------------------------------------------
  Procedure NewHinge(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32,*axis1.v3f32,*axis2.v3f32,usereferenceframe.b=#False)
    Protected *Me.BTConstraint_t = AllocateMemory(SizeOf(BTConstraint_t))
    
    *Me\objA  = *objA
    *Me\objB = *objB
    *Me\bodyA = *objA\rigidbody
    *Me\bodyB = *objB\rigidbody
    
    *Me\cns = Bullet::BTNewHingeConstraint(*Me\bodyA,*Me\bodyB,*pivot1,*pivot2,*axis1,*axis2,usereferenceframe)

    ProcedureReturn *Me
  EndProcedure
  
  
  ; Point2Point Constraint
  ;-------------------------------------------------------------
   Procedure NewPoint2Point(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32)
    Protected *Me.BTConstraint_t = AllocateMemory(SizeOf(BTConstraint_t))
    
    *Me\objA  = *objA
    *Me\objB = *objB
    *Me\bodyA = *objA\rigidbody
    *Me\bodyB = *objB\rigidbody
    
    *Me\cns = Bullet::BTNewPoint2PointConstraint(*Me\bodyA,*Me\bodyB,*pivot1,*pivot2)

    ProcedureReturn *Me
  EndProcedure
  
  ; Gear Constraint
  ;-------------------------------------------------------------
  Procedure NewGear(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32)
    Protected *Me.BTConstraint_t = AllocateMemory(SizeOf(BTConstraint_t))
    
    *Me\objA  = *objA
    *Me\objB = *objB
    *Me\bodyA = *objA\rigidbody
    *Me\bodyB = *objB\rigidbody
    
    *Me\cns = Bullet::BTNewGearConstraint(*objA\rigidbody,*objB\rigidbody,*pivot1,*pivot2,0.5)

    ProcedureReturn *Me
  EndProcedure
  
  ; Slider Constraint
  ;-------------------------------------------------------------
  Procedure NewSlider(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*frameA.trf32,*frameB.trf32)
    Protected *Me.BTConstraint_t = AllocateMemory(SizeOf(BTConstraint_t))
    
    *Me\objA  = *objA
    *Me\objB = *objB
    *Me\bodyA = *objA\rigidbody
    *Me\bodyB = *objB\rigidbody
    
    *Me\cns = Bullet::BTNewGearConstraint(*objA\rigidbody,*objB\rigidbody,*pivot1,*pivot2,0.5)

    ProcedureReturn *Me
  EndProcedure
  
  ; Generic6Dof Constraint
  ;-------------------------------------------------------------
  Procedure NewGeneric6Dof(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*frameA.trf32,*frameB.trf32)
    Protected *Me.BTConstraint_t = AllocateMemory(SizeOf(BTConstraint_t))
    
    *Me\objA  = *objA
    *Me\    objB = *objB
    *Me\bodyA = *objA\rigidbody
    *Me\bodyB = *objB\rigidbody
    
    *Me\cns = Bullet::BTNewGearConstraint(*objA\rigidbody,*objB\rigidbody,*frameA,*frameB,0.5)

    ProcedureReturn *Me
  EndProcedure
  
  ; ConeTwist Constraint
  ;-------------------------------------------------------------
  Procedure NewConeTwist(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*frameA.trf32,*frameB.trf32)
    Protected *Me.BTConstraint_t = AllocateMemory(SizeOf(BTConstraint_t))
    
    *Me\objA  = *objA
    *Me\objB = *objB
    *Me\bodyA = *objA\rigidbody
    *Me\bodyB = *objB\rigidbody
    
    *Me\cns = Bullet::BTNewConeTwistConstraint(*objA\rigidbody,*objB\rigidbody,*frameA,*frameB)

    ProcedureReturn *Me
  EndProcedure
  
  ; Constructor
  ;-------------------------------------------------------------
  Procedure New(*objA.Object3D::Object3D_t,*objB.Object3D::Object3D_t,*pivot1.v3f32,*pivot2.v3f32,type.i,*axis1.v3f32=#Null,*axis2.v3f32=#Null)
    Protected *Me.BTConstraint_t = AllocateMemory(SizeOf(BTConstraint_t))
    Protected axisA.v3f32, axisB.v3f32
    Protected q.q4f32
    Quaternion::SetIdentity(q)
    Vector3::Set(axisA,1,0,0)
    Vector3::Set(axisB,0,1,0)
    
;   	#CONSTRAINT_HINGE
;   	#CONSTRAINT_CONETWIST
;   	#CONSTRAINT_D6
;   	#CONSTRAINT_SLIDER
;   	#CONSTRAINT_CONTACT
;   	#CONSTRAINT_D6_SPRING
;   	#CONSTRAINT_GEAR
;   	#CONSTRAINT_MAX
    
    Select type:
        
      Case Bullet::#CONSTRAINT_POINT2POINT
        *Me\cns = Bullet::BTNewPoint2PointConstraint(*objA\rigidbody,*objB\rigidbody,*pivot1,*pivot2)
        
       Case Bullet::#CONSTRAINT_HINGE
          *Me\cns = Bullet::BTNewHingeConstraint(*objA\rigidbody,*objB\rigidbody,*pivot1,*pivot2,*axis2,*axis2,#True)
        
      Case Bullet::#CONSTRAINT_CONETWIST
        
      Case Bullet::#CONSTRAINT_D6
        
      Case Bullet::#CONSTRAINT_SLIDER
;         btSliderConstraint(btRigidBody& rbA,
;                    btRigidBody& rbB,
;                    const btTransform& frameInA,
;                    const btTransform& frameInB,
;                    bool useLinearReferenceFrameA);
   
        
;       Case Bullet::#CONSTRAINT_GEAR
;         MessageRequester("Bodies",Str(*objA\rigidbody)+","+Str(*objB\rigidbody))
;         *Me\cns = Bullet::BTNewGearConstraint(*objA\rigidbody,*objB\rigidbody,*pivot1,*pivot2,0.5)
;         MessageRequester("Constraint GEAR ",Str(*Me\cns))
    EndSelect
    ProcedureReturn *Me 
  EndProcedure
  
  Procedure Delete(*body.BTConstraint_t)
    
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 128
; FirstLine = 124
; Folding = ---
; EnableXP
XIncludeFile "../core/Math.pbi"

; ============================================================================
;
;  Copyright (c) 2013, Ben Malartre, Gitans Production.
;  All rights reserved, worldwide.
;
;  Redistribution  and  use  in  source  and  binary  forms,  with or  without
;  modification, are permitted provided that the following conditions are met:
;
;  - Redistributions of  source code  must retain  the above copyright notice,
;    this list of conditions and the following disclaimer.
;  - Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
;  - Neither the name of  RADFAC nor the names of its contributors may be used
;    to  endorse  or  promote  products  derived  from  this  software without
;    specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;  AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT LIMITED TO, THE
;  IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;  ARE DISCLAIMED.  IN NO EVENT SHALL THE  COPYRIGHT HOLDER OR CONTRIBUTORS BE
;  LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
;  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT  LIMITED  TO,  PROCUREMENT OF
;  SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA,  OR PROFITS; OR BUSINESS
;  INTERRUPTION) HOWEVER CAUSED  AND ON ANY  THEORY OF  LIABILITY,  WHETHER IN
;  CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING  NEGLIGENCE OR OTHERWISE)
;  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;
;  For permission, contact benmalartre@hotmail.com.
;
; ============================================================================
;  raalib.libs.bullet.pbi
; ............................................................................
;  Bullet Physic Engine CAPI(not complete) integration
; ============================================================================
;  2014/02/12 | Ben Malartre
;  - creation
; 
; ============================================================================
; 
; Bullet Continuous Collision Detection And Physics Library
; Copyright (c) 2003-2006 Erwin Coumans  http://continuousphysics.com/Bullet/
; 
; This software is provided 'as-is', without any express Or implied warranty.
; In no event will the authors be held liable For any damages arising from the use of this software.
; Permission is granted To anyone To use this software For any purpose, 
; including commercial applications, And To alter it And redistribute it freely, 
; subject To the following restrictions:
; 
; 1. The origin of this software must Not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
; 2. Altered source versions must be BTainly marked As such, And must Not be misrepresented As being the original software.
; 3. This notice may Not be removed Or altered from any source distribution.
; 
; 
; Draft high-level generic physics C-API. For low-level access, use the physics SDK native API's.
; Work in progress, functionality will be added on demand.
; 
; If possible, use the richer Bullet C++ API, by including "btBulletDynamicsCommon.h"
; 
DeclareModule Bullet
  UseModule Math
  #BT_USE_DOUBLE_PRECISION = #False
  
  Macro btScalar
   f
  EndMacro
  
  CompilerIf #BT_USE_DOUBLE_PRECISION
    Macro btReal : d : EndMacro
  CompilerElse
    Macro btReal : f : EndMacro
  CompilerEndIf
  
  Structure btVector3
    v.btReal[3]
  EndStructure
  
  Structure btQuaternion
    v.btReal[4]
  EndStructure
  
  Structure btMatrix4
    v.btReal[16]
  EndStructure
  
  Structure btXform
    p.btReal[3]
    r.btReal[4]
    s.btReal[3]
  EndStructure
  
  ; Dynamics world, belonging To some physics SDK (C-API)
  Structure btDynamicsWorld
  EndStructure
  
  
  ; Collision Dispatcher
  Structure btDispatcher : EndStructure
  
  ; Rigid Body that can be part of a Dynamics World (C-API)
  Structure btRigidBody : EndStructure
  
  ; Soft Body that can be part of a Dynamics World (C-API)
  Structure btSoftBody : EndStructure
  
  
  ; Collision Shape/Geometry, property of a Rigid Body (C-API)
  Structure btCollisionShape : EndStructure
  
  
  ; Constraint For Rigid Bodies (C-API)
  Structure btConstraint : EndStructure
  Structure btConstraintSolver : EndStructure
  
  
  ; Triangle Mesh Interface (C-API)
  Structure btMeshInterface : EndStructure
  Structure btTriangleIndexVertexArray : EndStructure
  
  ; Broadphase Scene/Proxy Handles (C-API)
  Structure btBroadphaseInterface : EndStructure
  Structure btCollisionBroadphase : EndStructure
  Structure btBroadphaseProxy : EndStructure
  Structure btCollisionWorld :EndStructure
  Structure btCollisionDispatcher :  EndStructure
  Structure btDefaultCollisionConfiguration : EndStructure
  
  ; Raycast Result Storage
  Structure btRayCastResult
  	*m_body.btRigidBody
  	*m_shape.btCollisionShape		
  	m_positionWorld.btVector3		
  	m_normalWorld.btVector3	
  	m_triangleindex.l
  
  EndStructure
  
  Structure btConvexHullDescription
  	num_points.i
  	num_planes.i
  	num_edges.i
  	*vertices ; btReal
  	*indices  ; int
  	
  EndStructure
  
  Structure btSoftBodyWorldInfo
  ; 	air_density.btScalar
  ; 	water_density.btScalar
  ; 	water_offset.btScalar
  ; 	water_normal.btVector3
  ; 	*m_broadphase.btBroadphaseInterface
  ; 	*m_dispatcher.btDispatcher
  ; 	m_gravity.btVector3
  ; 	*m_sparsesdf
  ;  
  EndStructure
  
  ;	Particular physics SDK (C-API)
  Structure btPhysicsSdk
  ;   m_worldAabbMin.btVector3	
  ;   m_worldAabbMax.btVector3
  ;   *m_softBodyWorldInfo.btSoftBodyWorldInfo
  ;   
  ;   *m_broadphase.btBroadphaseInterface
  ; 	*m_dispatcher.btCollisionDispatcher
  ; 	*m_solver.btConstraintSolver
  ; 	*m_boxBoxCF
  ; 	*m_collisionConfiguration.btCollisionConfiguration
  ; 	
  ; 	*m_world.btDynamicsWorld
  ; 	*m_pick.btDynamicsWorld
  ; 	
  ; 	*shapes
  	
  	
  EndStructure
  
  Macro btCollideShapeType:i:EndMacro
  Enumeration 
    #GROUNDPLANE_SHAPE
    #BOX_SHAPE
    #SPHERE_SHAPE
    #CYLINDER_SHAPE
    #CONE_SHAPE
    #CAPSULE_SHAPE
    #CONVEXHULL_SHAPE
    #CONVEXDECOMPOSITION_SHAPE
    #TRIANGLEMESH_SHAPE
    #GIMPACT_SHAPE
    #CLUSTERED_SHAPE
  EndEnumeration
  
  Macro btConstraintType:i:EndMacro
  Enumeration
  	#CONSTRAINT_POINT2POINT=3
  	#CONSTRAINT_HINGE
  	#CONSTRAINT_SLIDER
  	#CONSTRAINT_CONETWIST
  	#CONSTRAINT_D6
  	#CONSTRAINT_FIXED
  	#CONSTRAINT_D6_SPRING
    
  	#CONSTRAINT_MAX
  EndEnumeration
  
  Macro btConstraintParams:i:EndMacro
  Enumeration
  	#CONSTRAINT_ERP=1
  	#CONSTRAINT_STOP_ERP
  	#CONSTRAINT_CFM
  	#CONSTRAINT_STOP_CFM
  EndEnumeration
  
  Enumeration
    #WORLD_COLLISION
    #WORLD_DYNAMICS
  EndEnumeration
  
  
  
  
  Structure BTWorld_t Extends Object::Object_t
    *world.btDynamicsWorld
  ;   *statics.CArrayPtr()
  ;   *dynamics.CArrayPtr()
  ;   *constraints.CArrayPtr()
    
  EndStructure
  
  
  Global *bullet_sdk.btPhysicsSDK
  
  Global *bullet_world.btDynamicsWorld
  Global *pick_world.btDynamicsWorld
  
  Prototype btBroadphaseCallback(*clientData, *object1,*object2);

  ; ---------------------------------------------------------------------------
  ; Import Functions
  ; ---------------------------------------------------------------------------
  ; {
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ;MessageRequester("Bullet",RAAFAL_LIB_INCLUDE_PATH+"bullet.lib")
    ImportC "..\..\libs\x64\windows\bullet.lib" : EndImport
    ImportC "..\..\libs\x64\windows\BulletCollision.lib" : EndImport
    ImportC "..\..\libs\x64\windows\BulletDynamics.lib" :EndImport
    ImportC "..\..\libs\x64\windows\BulletSoftBody.lib"  : EndImport
    ImportC "..\..\libs\x64\windows\LinearMath.lib" : EndImport
    ImportC "..\..\libs\x64\windows\bullet.lib"
    
          
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "../../libs/x64/linux/bullet.a" : EndImport
    ImportC "-lstdc++" : EndImport
    ImportC "../../libs/x64/linux/libBulletDynamics.a":EndImport
    ImportC "../../libs/x64/linux/libBulletSoftBody.a": EndImport
    ImportC "../../libs/x64/linux/libBulletCollision.a" : EndImport
    ImportC "../../libs/x64/linux/libLinearMath.a" : EndImport
    
    ImportC "../../libs/x64/linux/bullet.a"
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
     ;___________________________________________________________________________
    ;  MacOSX
    ;¯¯¯¯¯¯¯¯¯
    ImportC "../../libs/x64/macosx/bullet.a" : EndImport
    ImportC "../../libs/x64/macosx/libBulletDynamics.a":EndImport
    ImportC "../../libs/x64/macosx/libBulletSoftBody.a": EndImport
    ImportC "../../libs/x64/macosx/libBulletCollision.a" : EndImport
    ImportC "../../libs/x64/macosx/libLinearMath.a" : EndImport
    
    ImportC "../../libs/x64/macosx/bullet.a"
      
      
  CompilerEndIf
        
  
  
      BTTestWorld(useMCLPSolver.b)
      BTTestXForm(*T.btXform)
      ;Create And Delete a Bullet SDK
      BTSoftBodyWorld()
      BTCheckSoftBodyWorldInfo(*physicsSdk.btPhysicsSdk)
      BTTest(*physicsSdk.btPhysicsSdk)
      BTCreateDynamicsSdk()
      BTDeleteDynamicsSdk(*physicsSdk.btPhysicsSdk)
      BTGetDynamicsWorld(*physicsSdk.btPhysicsSdk)
      BTGetWorldBoundingBox(*physicsSdk.btPhysicsSdk,*bb_min.v3f32,*bb_max.v3f32)
  		
  		; Collision World, Not strictly necessary, you can also just create a Dynamics World With Rigid Bodies which internally manages the Collision World With Collision Objects
  		BTCreateSapBroadphase(*beginCallback.btBroadphaseCallback ,*endCallback.btBroadphaseCallback); return a btCollisionBroadphase	Object
  		BTDestroyBroadphase(*bp.btCollisionBroadphase ); destroy a btCollisionBroadphase	Object
  		BTCreateProxy(*bp.btCollisionBroadphase, *clientData, minX.btReal ,minY.btReal ,minZ.btReal , maxX.btReal ,maxY.btReal, maxZ.btReal);return a btBroadphaseProxy Object
  		BTDestroyProxy(*bp.btCollisionBroadphase, *proxy.btBroadphaseProxy); ; destroy a btBroadphaseProxy	Object
  		BTSetBoundingBox(*proxy.btBroadphaseProxy , minX.btReal ,minY.btReal ,minZ.btReal , maxX.btReal ,maxY.btReal, maxZ.btReal);
  		BTCreateCollisionWorld(*physicsSdk.btPhysicsSdk)                                                                          ; return a btCollisionWorld Object
  		
  		
  		; Dynamics World
  		BTCreateDynamicsWorld(*physicsSdk.btPhysicsSdk,useMCLPSolver.b=#False); return a btDynamicsWorld Object
  		BTDeleteDynamicsWorld(*world.btDynamicsWorld)
  		
  		BTCreateSoftRigidDynamicsWorld(*physicsSdk.btPhysicsSdk); return a btSoftRigidDynamicsWorld Object
  		BTDeleteSoftRigidDynamicsWorld(*world.btDynamicsWorld)
  		
  		BTStepSimulation(*world.btDynamicsWorld, timeStep.btReal)
  		BTAddRigidBody(*world.btDynamicsWorld, *object.btRigidBody)
  		BTRemoveRigidBody(*world.btDynamicsWorld, *object.btRigidBody)
  		BTGetNumCollideObjects(*world.btDynamicsWorld )
  		BTSetGravity( *world.btDynamicsWorld, *gravity.btVector3)
  		
  		BTAddSoftBody( *world.btDynamicsWorld, *bd.btSoftBody)
  		
  		BTCheckSoftBodySolver(*sdk.btPhysicsSdk)
  		BTResetSparseSDF(*sdk.btPhysicsSdk)
  		
  		
  		;BTSetCollisionProcessedCallback( fn.ContactProcessedCallback  )
  		
  		; Rigid Body
      BTCreateRigidBody(	*user_data, mass.f, *cshape.btCollisionShape ); return a btRigidBody Object
      BTDeleteRigidBody( *body.btRigidBody)                             ; delete a btRigidBody Object
      BTGetRigidBodyByID(*world.btDynamicsWorld,id.i)
      BTGetUserData(*body.btRigidBody); return C3DObject
      BTSetActivationState( *body.btRigidBody, state.i)
  	  BTRigidBodySetCollisionFlags(*body.btRigidBody , flags.i)
  	  BTRigidBodyGetCollisionFlags(*body.btRigidBody)
  	  BTCreateCurvedGround(*sdk.btPhysicsSdk,nbt.i, nbv.i, *vertices, *indices)
  	  BTSetLinearFactor(*body.btRigidBody,*factor.btVector3)
  	  BTSetAngularFactorF(*body.btRigidBody,factor.f)
  	  BTSetAngularFactor(*body.btRigidBody,*factor.btVector3)
  	  BTSetLinearVelocity(*body.btRigidBody,*velocity.btVector3)
  	  BTSetAngularVelocity(*body.btRigidBody,*velocity.btVector3)
  	  
  	  ;Soft Body
  	  BTCreateSoftBodyFromConvexHull(*user_data,*sdk.btPhysicsSdk,*vertices,*indices, nb_triangles.i)
  	  BTCreateSoftBodyFromTriMesh(*obj,*physicsSdk.btPhysicsSdk,*vertices,*indices,nb_triangles.i)
  	  BTCreateClusterSoftBodyFromTriMesh(*obj,*physicsSdk.btPhysicsSdk,*vertices,*indices,nb_triangles.i,nb_clusters.i)
  	  BTGetSoftBodyByID(*world.btDynamicsWorld,id.i)
  	  BTUpdatePointPosition(*sbd.btSoftBody,*vertices)
  	  BTSoftBox(*physicsSdk.btPhysicsSdk,*bb_min.v3f32,*bb_max.v3f32)
  	  BTGetNumSoftBodies(*world.btDynamicsWorld)
  	  BTSoftBoulder(*physicsSdk.btPhysicsSdk,*p.btVector3,*s.btVector3,np.i,id.i)
  	  BTUpdateSoftBodyGeometry(*sbd.btSoftBody,*vertices)
  	  BTGetSoftBodyNbVertices(*sbd.btSoftBody)
  	  BTGetSoftBodyNbFaces(*sbd.btSoftBody)
  	  BTGetSoftBodyNbNodes(*sbd.btSoftBody)
  	  
  	  ; Constraints
      BTNewHingeConstraint(*bodyA.btRigidBody,*bodyB.btRigidBody, *pivotA.btVector3,*pivotB.btVector3,*axisA.btVector3,*axisB.btVector3,usereferenceframe.b)
      BTNewHingeConstraintWorld(*body.btRigidBody, *pivot.btVector3,*axis.btVector3,usereferenceframe.b=#False)
      BTSetHingeConstraintLimits(*constraint.btConstraint,low.btReal, high.btReal, softness.btReal=0.9,biasFactor.btReal=0.3, relaxationFactor.btReal=1.0)
      BTNewGearConstraint(*bodyA.btRigidBody,*bodyB.btRigidBody, *axisA.btVector3,*axisB.btVector3,ratio.f)
      BTNewPoint2PointConstraint(*bodyA.btRigidBody,*bodyB.btRigidBody, *pivotA.btVector3,*pivotB.btVector3)
      BTNewSliderConstraint(*bodyA.btRigidBody,*bodyB.btRigidBody,*frameA.trf32,*frameB.trf32,useReferenceFrameA.b)
	    BTNewGeneric6DofConstraint(*bodyA.btRigidBody,*bodyB.btRigidBody,*frameA.trf32,*frameB.trf32,usereferenceframeA.b)
	
      BTSetGeneric6DofConstraintLimit(*constraint.btConstraint,axis.i, lo.btReal, hi.btReal);
	    BTSetGeneric6DofConstraintLinearLowerLimit(*constraint.btConstraint,*limit.v3f32);
	    BTSetGeneric6DofConstraintLinearUpperLimit(*constraint.btConstraint,*limit.v3f32);
	    BTSetGeneric6DofConstraintAngularLowerLimit(*constraint.btConstraint,*limit.v3f32);
	    BTSetGeneric6DofConstraintAngularUpperLimit(*constraint.btConstraint,*limit.v3f32);
	
  	  BTAddConstraint(*world.btDynamicsWorld,*constraint.btConstraint,disableCollisionBetweenLinkedBodies.b)
  	  
  	  ; Collision Shape definition 
  	  BTNewGroundPlaneShape(*pos.v3f32,size.f)              ; return a btCollisionShape Object
      BTNewSphereShape(radius.btReal)                       ; return a btCollisionShape Object
      BTNewBoxShape(x.btReal,y.btReal,z.btReal)             ; return a btCollisionShape Object
      BTNewCapsuleShape(radius.btReal, height.btReal)       ; return a btCollisionShape Object
      BTNewConeShape(radius.btReal , height.btReal)         ; return a btCollisionShape Object
      BTNewCylinderShape(radius.btReal , height.btReal)     ; return a btCollisionShape Object
      BTNewCompoundShape()                                  ; return a btCollisionShape Object
      BTAddChildShape(*compoundShape.btCollisionShape,*childShape.btCollisionShape, *childPos.btVector3,*childOrn.btQuaternion)
      BTNewGImpactShape(num_tri.i,*indices, num_vertices.i,*vertices) ; indices is an array of int , vertices an array of btVector3
      BTNewBvhTriangleMeshShape(num_tri.i,*indices, num_vertices.i,*vertices) ; indices is an array of int , vertices an array of btVector3
      BTDeleteShape(*shape.btCollisionShape)
      BTSetCollisionMargin(*body.btRigidBody,margin.btReal)
      BTGetCollisionMargin.btReal(*body.btRigidBody)
      BTSetFriction(*body.btRigidBody,friction.btReal)
      
      ; Convex Hull
      BTNewEmptyConvexHullShape() ; return a BTCollisionShape Object
      BTNewConvexHullShape(num_tri.i,*indices, num_vertices.i,*vertices) ; return a BTCollisionShape Object
      BTAddVertex(*convexHull.btCollisionShape, x.btReal,y.btReal,z.btReal)
      BTGetConvexHullShapeDescription(*convexHull.btCollisionShape,*desc.btConvexHullDescription)
      BTFillConvexHullShapeDescription(*convexHull.btCollisionShape,*desc.btConvexHullDescription)
      BTDrawConvexHullShape(*convexHull.btCollisionShape,*model.m4f32,*view.m4f32,*proj.m4f32)
      BTDrawCollisionShape(*shape.btCollisionShape,*model.m4f32,*proj.m4f32)
      
     ; BTNewConvexDecompositionShape(num_tri.i,*tri, num_vertices.i,*vertices);
      
      ; Concave Static triangle meshes
      BTNewMeshInterface(); return a BTMeshInterface Object
      BTAddTriangle(*mesh.btMeshInterface, *v0.btVector3,*v1.btVector3,*v2.btVector3)
      BTNewTriangleMeshShape(*mesh.btMeshInterface); return a btCollisionShape Object
      BTSetScaling(*body.btRigidBody, *cscaling.btVector3)
      BTTranslate(*body.btRigidBody, x.btReal,y.btReal,z.btReal)
      BTTransform(*body.btSoftBody, *q.btQuaternion, *p.btVector3)
      
      ; SOLID has Response Callback/Table/Management 
      ; PhysX has Triggers, User Callbacks And filtering
      ; ODE has the typedef void dNearCallback (void *Data, dGeomID o1, dGeomID o2);
      ; 
      ; /*	typedef void BTUpdatedPositionCallback(void* userData, btRigidBodyHandle	rbHandle, btVector3 pos); */
      ; /*	typedef void BTUpdatedOrientationCallback(void* userData, btRigidBodyHandle	rbHandle, btQuaternion orientation); */
      
      ; get world transform
      BTGetMatrix(*object.btRigidBody, *matrix.btMatrix4)
      BTGetPosition(*object.btRigidBody,*position.btVector3 )
      BTGetOrientation(*object.btRigidBody,*orientation.btQuaternion)
      
      
      ; set world transform (position/orientation)
      BTSetPosition(*object.btRigidBody, *position.btVector3)
      BTSetOrientation(*object.btRigidBody, *orientation.btQuaternion)
      BTSetEuler(yaw.btReal,pitch.btReal,roll.btReal, *orient.btQuaternion)
      BTSetMatrix(*object.btRigidBody, *matrix)
      
      BTTestVector3(*position.btVector3,x.f,y.f,z.f)
      BTTestQuaternion(*orientation.btQuaternion,x.f,y.f,z.f,w.f)
      
      ; Raycasting
      BTRayCast(*world.btDynamicsWorld, *rayStart.btVector3, *rayEnd.btVector3, *io_res.btRayCastResult)
      BTRayCastHit(*world.btDynamicsWorld)
      
      ; Nearest Point
      BTNearestPoints.d(*p1.btVector3, *p2.btVector3, *p3.bTVector3, *q1.btVector3, *q2.btVector3, *q3.btVector3, *pa, *pb, *normal.btVector3)
    EndImport
    
    Declare.b Init()
    Declare.b Term()
EndDeclareModule

; 

; 
; 	extern  int 
; 
; 	/* Sweep API */
; 
; 	/* extern  BTRigidBodyHandle BTObjectCast(plDynamicsWorldHandle world, const BTVector3 rayStart, const BTVector3 rayEnd, BTVector3 hitpoint, BTVector3 normal); */
; 
; 	/* Continuous Collision Detection API */
; 	
; 	// needed For source/blender/blenkernel/intern/collision.c
; 	double BTNearestPoints(float p1[3], float p2[3], float p3[3], float q1[3], float q2[3], float q3[3], float *pa, float *pb, float normal[3]);
; 




; ============================================================================
;  Bullet Module Implementation
; ============================================================================
Module Bullet
  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure.b Init( )
    
    Debug "---------------------BULLET INIT --------------------------"
    ; ---[ Init Once ]----------------------------------------------------------
    
    *bullet_sdk = BTCreateDynamicsSdk()
    
    
    ; Test XForm
    Protected T.Transform::Transform_t
    Transform::Init(T)
    BTTestXForm(@T\t)
    Vector3::Echo(T\t\pos,"Bullet Test XForm Position")
    Quaternion::Echo(T\t\rot,"Bullet Test XForm Rotation")
    Vector3::Echo(T\t\scl,"Bullet Test XForm Scale")
  
  ;   *raa_pick_world = BTCreateDynamicsWorld(*raa_bullet_sdk)
    *bullet_world = BTCreateSoftRigidDynamicsWorld(*bullet_sdk)
; *bullet_world = BTCreateDynamicsWorld(*bullet_sdk)
;     *bullet_world = BTTestWorld(#True)


    
    Debug "Bullet_World --> "+Str(*bullet_world)
;     Debug "SDK_Bullet_World --> "+Str(BTGetDynamicsWorld(*bullet_sdk))
;     Debug "Soft Body Solver --> "+Str(BTCheckSoftBodySolver(*bullet_sdk))
;     Debug "SoftBodyWorldInfos SDF Nb Cells : "+Str(BTCheckSoftBodySolver(*bullet_sdk))
  ;   Debug "Sdk_Bullet_World --> "+Str(*raa_bullet_sdk\m_world)
  
    Protected gravity.v3f32
    Vector3::Set(@gravity,0,-10,0)
    BTSetGravity(*bullet_world,@gravity)
   Debug "Bullet Num Collision Objects -------------------------------------------------------> "+Str(BTTest(*raa_bullet_sdk))
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  Term
  ; ----------------------------------------------------------------------------
  Procedure.b Term(  )
  
    Debug "Lib Bullet Term Once Called ----->"
    ; ---[ Term Once ]----------------------------------------------------------
    BTDeleteSoftRigidDynamicsWorld(*bullet_world)
    Debug "Deleted Bullet SoftRigid Dynamics WOrld!!!"
    BTDeleteDynamicsSdk(*bullet_sdk)
    Debug "Deleted Bullet Physics SDK!!!"
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
EndModule
; IDE Options = PureBasic 5.41 LTS (Linux - x64)
; CursorPosition = 263
; FirstLine = 248
; Folding = ---
; EnableXP
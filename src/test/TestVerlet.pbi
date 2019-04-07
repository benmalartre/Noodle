
; Copyright (c) 2011, Movania Muhammad Mobeen
; All rights reserved.
; 
; Redistribution And use in source And binary forms, With Or without modification,
; are permitted provided that the following conditions are met:
; 
; Redistributions of source code must retain the above copyright notice, this List
; of conditions And the following disclaimer.
; Redistributions in binary form must reproduce the above copyright notice, this List
; of conditions And the following disclaimer in the documentation And/Or other
; materials provided With the distribution.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS And CONTRIBUTORS "AS IS" And ANY
; EXPRESS Or IMPLIED WARRANTIES, INCLUDING, BUT Not LIMITED To, THE IMPLIED WARRANTIES
; OF MERCHANTABILITY And FITNESS For A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
; SHALL THE COPYRIGHT HOLDER Or CONTRIBUTORS BE LIABLE For ANY DIRECT, INDIRECT,
; INCIDENTAL, SPECIAL, EXEMPLARY, Or CONSEQUENTIAL DAMAGES (INCLUDING, BUT Not LIMITED
; To, PROCUREMENT OF SUBSTITUTE GOODS Or SERVICES; LOSS OF USE, DATA, OR PROFITS;
; Or BUSINESS INTERRUPTION) HOWEVER CAUSED And ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, Or TORT (INCLUDING NEGLIGENCE Or OTHERWISE) ARISING IN
; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN If ADVISED OF THE POSSIBILITY OF SUCH
; DAMAGE.
; */
; 
; //A simple cloth using Verlet integration based on the SIGGRAPH course notes
; //"Realtime Physics" http://www.matthiasmueller.info/realtimephysics/coursenotes.pdf
; //using GLUT,GLEW And GLM libraries. This code is intended For beginners
; //so that they may understand what is required To Verlet integration
; //based cloth simulation.
; //
; //This code is under BSD license. If you make some improvements,
; //Or are using this in your research, do let me know And I would appreciate
; //If you acknowledge this in your code.
; //
; //Controls:
; //left click on any empty region To rotate, middle click To zoom
; //left click And drag any point To drag it.
; //
; //Author: Movania Muhammad Mobeen
; //        School of Computer Engineering,
; //        Nanyang Technological University,
; //        Singapore.
; //Email : mova0002@e.ntu.edu.sg
XIncludeFile "../core/Application.pbi"
#width = 1024
#height = 1024

Global numX = 20
Global numY = 20
Global total_points = (numX+1)*(numY+1)
Global size = 4
Global hsize.f = size/2.0

#DEFAULT_DAMPING =  -0.0125
#KsStruct = 50.75
#KdStruct = -0.25
#KsShear = 50.75
#KdShear = -0.25
#KsBend = 50.95
#KdBend = -0.25

Global gravity.Math::v3f32
Vector3::Set(gravity, 0.0, -0.00981, 0.0)
Global mass = 1.0

Global timeStep.f =  1/60.0
Global currentTime = 0
Global accumulator.d = timeStep


Global selected_index = -1

Enumeration
  #STRUCTURAL_SPRING = 0
  #SHEAR_SPRING = 1
  #BEND_SPRING = 2
EndEnumeration

Structure Spring_t
  p1.i                ; point A index
  p2.i                ; point B index
	rest_length.f       ; rest length
	Ks.f                ; stiffness coefficient
	Kd.f                ; damping coefficient
	type.i              ; spring type
EndStructure

Structure Verlet_t
  *geom.Geometry::Geometry_t  
  *X.CArray::CArrayV3F32
  *X_last.CArray::CArrayV3F32
  *F.CArray::CArrayV3F32
  *springs.CArray::CArrayPtr
  mass.f
EndStructure


Procedure NewVerlet(*geom.Geometry::Geometry_t)
  Define *Me.Verlet_t = AllocateMemory(SizeOf(Verlet_t))
  *Me\mass = 1.0
  *Me\geom = *geom
  *Me\X = CArray::newCArrayV3F32()
  *Me\X_last = CArray::newCArrayV3F32()
  *Me\F = CArray::newCArrayV3F32()
  *Me\springs = CArray::newCArrayPtr()
  Debug "CREATE VERLET : "+Str(*Me\geom)
  ProcedureReturn *Me
EndProcedure

Procedure DeleteVerlet(*Me.Verlet_t)
  CArray::Delete(*Me\X)
  CArray::Delete(*Me\X_last)
  CArray::Delete(*Me\F)
  CArray::Delete(*Me\X_last)
  CArray::DeleteReferences(*Me\springs)
  CArray::Delete(*Me\springs)
  FreeMemory(*Me)
EndProcedure


Procedure AddSpring(*Me.Verlet_t, a.i, b.i, ks.f, kd.f, type.i)
  Define *spring.Spring_t = AllocateMemory(SizeOf(Spring_t))
	
	*spring\p1=a
	*spring\p2=b
	*spring\Ks=ks
	*spring\Kd=kd
	*spring\type = type
	
	Define delta.Math::v3f32
	Vector3::Sub(delta, CArray::GetValue(*Me\X, a), CArray::GetValue(*Me\X, b))
	*spring\rest_length = Vector3::Length(delta)
	CArray::AppendPtr(*Me\springs, *spring)
	ProcedureReturn *spring
EndProcedure


Global spring_count=0



Procedure RigGeometry(*Me.Verlet_t, index.i)
  Define *geom.Geometry::PolymeshGeometry_t = *Me\geom
  Define base = 0, i, j, a, b
  For i =0 To index -1
    base + CArray::GetValueL(*geom\a_vertexpolygoncount, i)
  Next
  Define numVertices = *geom\nbpoints
  Define *neighbors.CArray::CArrayLong = CArray::newCArrayLong()
  
  ; clear old rig
  CArray::DeleteReferences(*Me\springs)
  
  NewMap unique_edges()
  Define edgeKey.s
  For i=0 To numVertices - 1
    PolymeshGeometry::GetVertexNeighbors(*geom, i, *neighbors)
    a = i
    For j=0 To Carray::GetCount(*neighbors)-1
      b = CArray::GetValueL(*neighbors, j)
      If b < a : Define t = a : a = b : b = t : EndIf
      edgeKey = Str(b)+","+Str(a)
      If Not FindMapElement(unique_edges(), edgeKey)
        Define *spring.Spring_t = AddSpring(*Me,a,b,#KsBend,#KdBend,#BEND_SPRING)
        unique_edges(edgeKey) =   *spring
      EndIf
      
    Next
    
  Next
  
  Debug "RIG GEOMETRY!!!"
;   *geom\a_vertexpolygonindices
EndProcedure



Procedure InitVerlet(*Me.Verlet_t)
  Select *Me\geom\type
    Case Geometry::#Polymesh
      Define *geom.Geometry::PolymeshGeometry_t = *Me\geom
      PolymeshGeometry::ComputeHalfEdges(*geom)
  EndSelect
  
EndProcedure


Procedure IntegrateVerlet(*verlet.Verlet_t, deltaTime.f) 
	Define deltaTime2Mass.f = (deltaTime*deltaTime)/ *verlet\mass
	Define i=0
  Define buffer.Math::v3f32, *Xi.Math::v3f32, *Xi_last.Math::v3f32, *Fi.Math::v3f32

  For i=0 To total_points - 1
    
    *Xi = CArray::GetValue(*verlet\X, i)
    *Xi_last = CArray::GetValue(*verlet\X_last, i)
    *Fi = CArray::GetValue(*verlet\F, i)
    Vector3::SetFromOther(buffer, *Xi)
    
    *Xi\x = *Xi\x + (*Xi\x - *Xi_last\x) + deltaTime2Mass * *Fi\x
    *Xi\y = *Xi\y + (*Xi\y - *Xi_last\y) + deltaTime2Mass * *Fi\y
    *Xi\z = *Xi\z + (*Xi\z - *Xi_last\z) + deltaTime2Mass * *Fi\z
    
    CArray::SetValue(*verlet\X_last, i, buffer)
    
    If *Xi\y<0 : *Xi\y = 0 : EndIf
  Next
EndProcedure
  
Procedure GetVerletVelocity(*velocity.Math::v3f32, *Xii.Math::v3f32, *Xi_last.Math::v3f32, dt.f )
  Vector3::Sub(*velocity, *Xi, *Xi_last)
  Vector3::ScaleInPlace(*velocity, 1.0/dt)
EndProcedure

Procedure ComputeForces(*Me.Verlet_t, dt.f)
	Define i=0
	Define *Fi.Math::v3f32
	Define velocity.Math::v3f32
	Define tmp.Math::v3f32
	
	For i=0 To *Me\geom\nbpoints - 1
	  *Fi = CArray::GetValue(*Me\F, i)
	  Vector3::Set(*Fi, 0, 0, 0)
	  
		GetVerletVelocity(velocity, *Xi, *Xi_last, dt)
		; add gravity force
		If i <> 0 And i <> numX		
		  Vector3::AddInPlace(*Fi, gravity)
		  Vector3::ScaleAddInPlace(*Fi,velocity, #DEFAULT_DAMPING)
		EndIf
		
	Next
	
	Define *spring.Spring_t
	Define.Math::v3f32 v1, v2, *p1, *p1_last, *p2, *p2_last
	Define.Math::v3f32 deltaP, deltaV, springF
	Define dist.f, leftTerm.f, rightTerm.f
	For i=0 To *Me\springs\itemCount - 1
	  *spring = CArray::GetValuePtr(*Me\springs, i)
	  *p1 = CArray::GetValue(*Me\X, *spring\p1)
	  *p1_last = CArray::GetValue(*Me\X_last, *spring\p1)
	  *p2 = CArray::GetValue(*Me\X, *spring\p2)
	  *p2_last = CArray::GetValue(*Me\X_last, *spring\p2)
	  
	  GetVerletVelocity(v1, p1, p1_last, dt)
	  GetVerletVelocity(v2, p2, p2_last, dt)
	  
	  Vector3::Sub(deltaP, p1, p2)
	  Vector3::Sub(deltaV, v1, v2)
	  dist = Vector3::Length(deltaP)
	  If Abs(dist)<0.0000001 : Continue : EndIf
	  
	  leftTerm = -*spring\Ks * (dist - *spring\rest_length)
	  rightTerm = *spring\Kd * (Vector3::Dot(deltaV, deltaP)/dist)
	  
	  Vector3::Normalize(springF, deltaP)
	  Vector3::ScaleInPlace(springF, leftTerm + rightTerm)
	  
	  If *spring\p1 <> 0 And *spring\p1 <> numX
	    Vector3::AddInPlace(CArray::GetValue(*Me\F, *spring\p1), springForce)
	  EndIf
	  
	  If *spring\p2 <> 0 And *spring\p2 <> numX
	    Vector3::SubInPlace(CArray::GetValue(*Me\F, *spring\p2), springForce)
	  EndIf
	  
	Next

EndProcedure


; void ApplyProvotDynamicInverse() {
; 	For(size_t i=0;i<springs.size();i++) {
; 		//check the current lengths of all springs
; 		glm::vec3 p1 = X[springs[i].p1];
; 		glm::vec3 p2 = X[springs[i].p2];
; 		glm::vec3 deltaP = p1-p2;
; 		float dist = glm::length(deltaP);
; 		If(dist>springs[i].rest_length) {
; 			dist -= (springs[i].rest_length);
; 			dist /= 2.0f;
; 			deltaP = glm::normalize(deltaP);
; 			deltaP *= dist;
; 			If(springs[i].p1==0 || springs[i].p1 ==numX) {
; 				X[springs[i].p2] += deltaP;
; 			} Else If(springs[i].p2==0 || springs[i].p2 ==numX) {
; 				X[springs[i].p1] -= deltaP;
; 			} Else {
; 				X[springs[i].p1] -= deltaP;
; 				X[springs[i].p2] += deltaP;
; 			}
; 		}
; 	}
; }

; Procedure EllipsoidCollision(*Me.Verlet_t)
;   Define i
;   Define x_0.Math::v4f32
;   Define delta0.Math::v3f32
;   Define distance.f
;   For i=0 To *Me\geom\nbpoints - 1
;     
; 		glm::vec4 X_0 = (inverse_ellipsoid*glm::vec4(X[i],1));
; 		glm::vec3 delta0 = glm::vec3(X_0.x, X_0.y, X_0.z) - center;
; 		float distance = glm::length(delta0);
; 		If (distance < 1.0f) {
; 			delta0 = (radius - distance) * delta0 / distance;
; 
; 			// Transform the delta back To original space
; 			glm::vec3 delta;
; 			glm::vec3 transformInv;
; 			transformInv = glm::vec3(ellipsoid[0].x, ellipsoid[1].x, ellipsoid[2].x);
; 			transformInv /= glm::dot(transformInv, transformInv);
; 			delta.x = glm::dot(delta0, transformInv);
; 			transformInv = glm::vec3(ellipsoid[0].y, ellipsoid[1].y, ellipsoid[2].y);
; 			transformInv /= glm::dot(transformInv, transformInv);
; 			delta.y = glm::dot(delta0, transformInv);
; 			transformInv = glm::vec3(ellipsoid[0].z, ellipsoid[1].z, ellipsoid[2].z);
; 			transformInv /= glm::dot(transformInv, transformInv);
; 			delta.z = glm::dot(delta0, transformInv);
; 			X[i] +=  delta ;
; 			X_last[i] = X[i];
; 		} 
; 	}
; 	}
	
Procedure StepPhysics(*Me.Verlet_t, dt.f)
	ComputeForces(*Me, dt)
	IntegrateVerlet(*Me, dt)
; 	EllipsoidCollision()
	;ApplyProvotDynamicInverse()
EndProcedure


Procedure OnIdle(*Me.Verlet_t)
; 	/*
; 	//Semi-fixed time stepping
; 	If ( frameTime > 0.0 )
;     {
;         const float deltaTime = min( frameTime, timeStep );
;         StepPhysics(deltaTime );
;         frameTime -= deltaTime;
;     }
; 	*/

	;Fixed time stepping + rendering at different fps
	If  accumulator >= timeStep 
      StepPhysics(*Me, timeStep )
      accumulator - timeStep
  EndIf

EndProcedure

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Bunny", Shape::#SHAPE_BUNNY)
PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
; Define *verlet.Verlet_t = NewVerlet(*mesh\geom)

;  RigGeometry(*verlet, 0)


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 356
; FirstLine = 300
; Folding = --
; EnableXP
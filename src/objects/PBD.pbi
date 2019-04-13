XIncludeFile "../objects/Geometry.pbi"


DeclareModule PDB
  #USE_TRIANGLE_BENDING_CONSTRAINT = 1
  #PI                              = 3.1415926536
  #EPSILON                         = 0.0000001
 
  Structure DistanceConstraint_t
    p1.i
    p2.i
    rest_length.f
    k.f
    k_prime.f
  EndStructure
  
  CompilerIf #USE_TRIANGLE_BENDING_CONSTRAINT
    Structure BendingConstraint_t
      p1.i
      p2.i
      p3.i
      rest_length.f
      w.f
      k.f
      k_prime.f
    EndStructure
    
  CompilerElse
    Structure BendingConstraint_t
      p1.i
      p2.i
      p3.i
      p4.i
      rest_length1.f
      rest_length2.f
      w1.f
      w2.f
      k.f
      k_prime.f
    EndStructure
    
  CompilerEndIf
  
  ; particle system
  Structure PBD_t
    *geom.Geometry::Geometry_t
    *X.CArray::CArrayV3F32          ; position
    *tmp_X.CArray::CArrayV3F32      ; predicted position
    *V.CArray::CArrayV3F32          ; velocity
    *F.CArray::CArrayV3F32          ; force
    *W.CArray::CArrayFloat          ; inverse particle mass
    *Ri.CArray::CArrayV3F32         ; Ri = Xi-Xcm
    *phi0.CArray::CArrayFloat       ; initial dihedral angle between adjacent triangles
    List bending_constraints.BendingConstraint_t()
    List distance_constraints.DistanceConstraint_t()
    
    gravity.Math::v3f32
  EndStructure

EndDeclareModule


Module PDB

  Procedure.f GetArea(*Me.PDB_t, a.i, b.i, c.i)
    Define e1.Math::v3f32, e2.Math::v3f32, cross.v3f32
    Vector3::Sub(CArray::GetValue(*Me\X, b), CArray::GetValue(*Me\X, a))
    Vector3::Sub(CArray::GetValue(*Me\X, c), CArray::GetValue(*Me\X, a))
    Vector3::Cross(cross, e1, e2)
    ProcedureReturn 0.5 * Vector3::Length(cross)
  EndProcedure
  
   Procedure  GetNormal(*Me.PDB_t, ind0.i, ind1.i, ind2.i, *nrm.Math::v3f32)
     Define.Math::v3f32 e1, e2
     Vector3::Sub(e1, CArray::GetValue(*Me\X, ind0), CArray::GetValue(*Me\X, ind1))
     Vector3::Sub(e2, CArray::GetValue(*Me\X, ind2), CArray::GetValue(*Me\X, ind1))
     Vector3::Cross(*nrm, e1, e2)
     Vector3::NormalizeInPlace(*nrm)
   EndProcedure
   
  
  
  Procedure AddDistanceConstraint(*Me.PDB_t,a.i, b.i, k.f) 
    Define *c.DistanceConstraint_t = AllocateMemory(SizeOf(DistanceConstraint_t))
  	*c\p1=a
  	*c\p2=b
  	*c\k =k
  	*c\k_prime = 1.0-Pow((1.0-*c\k), 1.0/*Me\solver_iterations);  //1.0f-pow((1.0f-c.k), 1.0f/ns);
  	
  	If(*c\k_prime>1.0) 
  		*c\k_prime = 1.0;
  	EndIf
  	
  	Define deltaP.Math::v3f32
  	Vector3::Sub(CArray::GetValue(*Me\geom\a_positions, *c\p1), CArray::GetValue(*Me\geom\a_positions, *c\p2))
  	*c\rest_length = Vector3::Length(deltaP)
  	
  	AddElement(*Me\distance_constraints())
  	*Me\distance_constraints() = *c
  
  EndProcedure
  
CompilerIf #USE_TRIANGLE_BENDING_CONSTRAINT
  Procedure AddBendingConstraint(*Me.PDB_t, pa.i, pb.i, pc.i, k.f)
  	Define *c.BendingConstraint_t = AllocateMemory(SizeOf(BendingConstraint_t))
  	*c\p1=pa
  	*c\p2=pb
  	*c\p3=pc
  	
  	*c\w = CArray::GetValueF(*Me\W, pa) + CArray::GetValueF(*Me\W, pb) + 2*CArray::GetValueF(*Me\W, pc)
  	Define center.Math::v3f32
  	Vector3::Add(center, CArray::GetValue(*Me\X, pa), CArray::GetValue(*Me\X, pb))
  	Vector3::AddInPlace(center, CArray::GetValue(*Me\X, pc))
  	Vector3::ScaleInPlace(center, 0.3333)
  	
  	Define delta.Math::v3f32
  	Vector3::Sub(delta, CArray::GetValue(*Me\X, pc), center)
  	*c\rest_length = Vector3::Length(delta)
  	
  	c\k = k
  	c\k_prime = 1.0-Pow((1.0-c\k), 1.0/*Me\solver_iterations);  //1.0f-pow((1.0f-c.k), 1.0f/ns);
  	If(c\k_prime>1.0)  : c.k_prime = 1.0 : EndIf
  	
  	AddElement(*Me\bending_constraints())
  	*Me\bending_constraints() = *c
  EndProcedure
  
CompilerElse
  Procedure AddBendingConstraint(*Me.PDB_t, pa.i, pb.i, pc.i, pd.i, k.i)
  	Define *c.BendingConstraint_t = AllocateMemory(SizeOf(BendingConstraint_t))
  	*c\p1=pa
  	*c\p2=pb
  	*c\p3=pc
  	*c\p4=pd
  	*c\w1 = CArray::GetValueF(W, pa) + CArray::GetValueF(W ,pb) + 2*CArray::GetValueF(W, pc);
  	*c\w2 = *c\w1
  	
;   	glm::vec3 center1 = 0.3333 * (X[pa] + X[pb] + X[pc]);
;   	glm::vec3 center2 = 0.3333 * (X[pa] + X[pb] + X[pd]);
;    	c\rest_length1 = glm::length(X[pc]-center1);
;   	c\rest_length2 = glm::length(X[pd]-center2);
  	c\k = k;
  	
  	c\k_prime = 1.0-Pow((1.0-c\k), 1.0/*Me\solver_iterations);  //1.0f-pow((1.0f-c.k), 1.0f/ns);
  	If(c\k_prime>1.0) : c\k_prime = 1.0 : EndIf
  	AddElement(*Me\bending_constraints())
  	*Me\bending_constraints() = *c
  EndProcedure
CompilerEndIf
  
CompilerIf #USE_TRIANGLE_BENDING_CONSTRAINT
  Procedure.f GetDihedralAngle(*Me.PBD_t, *c.BendingConstraint_t, *n1.Math::v3f32, *n2.Math::v3f32, *d) 
    GetNormal(*Me, *c\p1, *c\p2, *c\p3, *n1)
    GetNormal(*Me, *c\p1, *c\p2, *c\p4, *n2)
    ProcedureReturn Vector3::Dot(*n1, *n2)
;     Procedure
;   	n1 = GetNormal(c.p1, c.p2, c.p3);
;   	n2 = GetNormal(c.p1, c.p2, c.p4); 
;   	d = glm::dot(n1, n2);
;   	Return ACos(d);
  EndProcedure
  
CompilerEndIf

; 
;   	//add horizontal constraints
;   	For(int i=0;i<numX-1;i++) {
;   		For(int j=0;j<=numY;j++) {	   
;   			AddBendingConstraint(getIndex(i,j), getIndex(i+1,j), getIndex(i+2,j), kBend);
;   		}
;   	}
;   
;   	#else
;   	For(int i = 0; i < v-1; ++i) {
;   		For(int j = 0; j < u-1; ++j) {	 			 
;   			int p1 = i * (numX+1) + j;            
;   			int p2 = p1 + 1;            
;   			int p3 = p1 + (numX+1);            
;   			int p4 = p3 + 1;   
;   			 
;   			If ((j+i)%2) {  						
;   				AddBendingConstraint(p3,p2,p1,p4, kBend);	
;   			} Else {  
;   				AddBendingConstraint(p4,p1,p3,p2, kBend);
;   			}     
;   		}
;   	}		 
;   	float d;
;   	glm::vec3 n1, n2;
;   	phi0.resize(b_constraints.size());
;   	
;   	For(i=0;i<b_constraints.size();i++) {		
;   		phi0[i] = GetDihedralAngle(b_constraints[i],d,n1,n2);		
;   	}	
;   	#endif
;   
;   	//create a basic ellipsoid object
;   	ellipsoid = glm::translate(glm::mat4(1),glm::vec3(0,2,0));
;   	ellipsoid = glm::rotate(ellipsoid, 45.0f ,glm::vec3(1,0,0));
;   	ellipsoid = glm::scale(ellipsoid, glm::vec3(fRadius,fRadius,fRadius/2));
;   	inverse_ellipsoid = glm::inverse(ellipsoid);
;   }
;   
  
  
  
;   	
;   	glBegin(GL_LINES);
;   	For(i=0;i<b_constraints.size();i++) {
;   		b = b_constraints[i];
;   		c1 = (X[b.p1] + X[b.p2] + X[b.p3]) /3.0f;
;   		c2 = (X[b.p1] + X[b.p2] + X[b.p4]) /3.0f;
;   		GetDihedralAngle(b,d,n1,n2);
;   		glColor3f(Abs(n1.x), Abs(n1.y), Abs(n1.z) );
;   		glVertex3f(c1.x,c1.y,c1.z);		glVertex3f(c1.x+size*n1.x,c1.y+size*n1.y,c1.z+size*n1.z);
;   
;   		glColor3f(Abs(n2.x), Abs(n2.y), Abs(n2.z));
;   		glVertex3f(c2.x,c2.y,c2.z);		glVertex3f(c2.x+size*n2.x,c2.y+size*n2.y,c2.z+size*n2.z);
;   	}
;   	glEnd();
;   #endif
;   #endif
;   	glutSwapBuffers();
;   }
;   

  
  Procedure ComputeForces(*Me.PDB_t)
  	Define i=0
  	Define zerForce.Math::v3f32
  	Define *force.Math::v3f32
  	For i=0 To *Me\geom\nbpoints - 1
  	  *force = CArray::GetValue(*Me\F, i)
  	  Vector3::SetFromOther(*force, zeroForce)
  	  If CArray::GetValueF(*Me\W, i) > 0
  	    Vector3::AddInPlace(*force, *Me\gravity)
  	  EndIf
  	Next
  EndProcedure
  
  Procedure IntegrateExplicitWithDamping(*Me.PBD_t, deltaTime.f)
  	Define deltaTimeMass.f = deltaTime
  	Define i=0;
  	
  	Define Xcm.Math::v3f32
  	Define Vcm.Math::v3f32
  	Define sumM.f = 0
  	Define *v.Math::v3f32
  	For i=0 To *Me\geom\nbpoints-1
  	  *v = CArray::GetValue(*Me\V, i)
  	  Vector3::ScaleInPlace(*v, *Me\global_damping)
      Vector3::ScaleAddInPlace(*v, CArray::GetValue(*Me\F, i), deltaTime * CArray::GetValueF(*Me\W, i))
  		
  		; calculate the center of mass's position 
      ; and velocity for damping calc
      Vector3::ScaleAddInPlace(Xcm, CArray::GetValue(*Me\X), *Me\mass)
      Vector3::ScaleAddInPlace(Vcm, CArray::GetValue(*Me\V), *Me\mass)
      
  		sumM + *Me\mass
  	Next
  	
  	If sumM > 0
  	  Vector3::ScaleInPlace(Xcm, 1 / sumM)
  	  Vector3::ScaleInPlace(Vcm, 1 / sumM)
  	EndIf
  	
  	Define I.Math::m3f32
  	Matrix3::SetIdentity(I)
  	Define L.Math::v3f32 
  	Define w.Math::v3f32        ; angular velocity
  	Define s.Math::v3f32
  	Define C.Math::v3f32
  	Define tmp.Math::m3f32
  	Define pmt.Math::m3f32
  	Define *Rii.Math::v3f32
  	For i=0 To *Me\geom\nbpoints-1
  	  Vector3::Sub(CArray::GetValue(*Me\Ri, i), CArray::GetValue(*Me\X, i), Xcm)  
  	  Vector3::Scale(s, CArray::GetValue(*Me\V, i), *Me\mass)
  	  Vector3::Cross(C,CArray::GetValue(*Me\Ri, i), s)
  	  Vector3::AddInPlace(L, C)
  	  
  	  *Rii = CArray::GetValue(*Me\Ri, i)
  	  Matrix3::Set(tmp,0, -*Rii\z, *Rii\y, 
  	               *Rii\z, 0, -*Rii\x,
  	               -*Rii\y,  *Rii\x, 0)
  	  
  	  Matrix3::Transpose(pmt, tmp)
  	  Matrix3::MulByMatrix3InPlace(tmp, pmt)
  	  Matrix3::ScaleInPlace(tmp, mass)
  	  Matrix3::AddInPlace(I, tmp)
  	  
  	Next
  	
  	For(i=0;i<total_points;i++) { 
  		Ri[i] = (X[i] - Xcm);	
  		
  		L += glm::cross(Ri[i],mass*V[i]); 
  
  		;thanks To DevO For pointing this And these notes really helped.
  		;http://www.sccg.sk/~onderik/phd/ca2010/ca10_lesson11.pdf
  
  		glm::mat3 tmp = glm::mat3(0,-Ri[i].z,  Ri[i].y, 
  							 Ri[i].z,       0,-Ri[i].x,
  							 -Ri[i].y,Ri[i].x,        0);
  		I +=(tmp*glm::transpose(tmp))*mass;
  	} 
  	
  	w = glm::inverse(I)*L;
  	
  	//apply center of mass damping
  	For(i=0;i<total_points;i++) {
  		glm::vec3 delVi = Vcm + glm::cross(w,Ri[i])-V[i];		
  		V[i] += kDamp*delVi;
  	}
  
  	//calculate predicted position
  	For(i=0;i<total_points;i++) {
  		If(W[i] <= 0.0) { 
  			tmp_X[i] = X[i]; //fixed points
  		} Else {
  			tmp_X[i] = X[i] + (V[i]*deltaTime);				 
  		}
  	} 
  }
   
  Procedure Integrate(*Me.PBD_t, deltaTime.f)
  	Define inv_dt.f = 1.0/deltaTime
  	Define i=0
    Define 
  	For i=0 To *Me\geom\nbpoints - 1	
  	  Vector3::Sub(CArray::GetValue(*Me\V, i), CArray::GetValue(*Me\tmp_X, i), CArray::GetValue(*Me\X, i))
  	  Vector3::ScaleInPlace(CArray::GetValue(*Me\V, i), inv_dt)
  	  Vector3::SetFromOther(CArray::GetValue(*Me\X, i), CArray::GetValue(*Me\tmp_X, i))	 
  	Next
  EndProcedure
  
  Procedure UpdateDistanceConstraint(*Me.PBD_t,index.i)
    SelectElement(*Me\distance_constraints(), index)
    Define *c.DistanceConstraint_t c = *Me\distance_constraints()
    Define dir.Math::v3f32
    Vector3::Sub(dir, CArray::GetValue(*Me\tmp_X, *c\p1), CArray::GetValue(*Me\tmp_X, *c\p2))
  	Define len.f = Vector3::Length(dir) 
  	If(len <= #EPSILON)  : ProcedureReturn : EndIf
  	
  	Define w1.f = CArray::GetValueF(W, *c\p1)
  	Define w2.f = CArray::GetValueF(W, *c\p2)
  	Define invMass.f = w1+ w2
  	If(invMass <= #EPSILON) : ProcedureReturn : EndIf
   
  	Define dP.Math::v3f32 
  	Vector3::Scale(dP, dir, (1.0/len) )
  	Vector3::ScaleInPlace(dP, (1.0/invMass) * (len-c\rest_length )* c\k_prime)

  	If(w1 > 0.0) 
  	  Vector3::ScaleAddInPlace(CArray::GetValue(*Me\tmp_X, *c\p1), dp, -w1)
  	EndIf
  	

	  If(w2 > 0.0)
  	  Vector3::ScaleAddInPlace(CArray::GetValue(*Me\tmp_X, *c\p2), dp, w2)
  	EndIf
 
  	
  EndProcedure
  	
  
  Procedure UpdateBendingConstraint(*Me.PBD_t, index.i)
    Define i=0
    SelectElement(*Me\bending_constraints(), index)
  	Define *c.BendingConstraint_t = *Me\bending_constraints()
  
  CompilerIf #USE_TRIANGLE_BENDING_CONSTRAINT
  	;Using the paper suggested by DevO
  	;http://image.diku.dk/kenny/download/kelager.niebe.ea10.pdf
   
  	;global_k is a percentage of the Global dampening constant 
  	float global_k = global_dampening*0.01f; 
  	glm::vec3 center = 0.3333f * (tmp_X[c.p1] + tmp_X[c.p2] + tmp_X[c.p3]);
  	glm::vec3 dir_center = tmp_X[c.p3]-center;
  	float dist_center = glm::length(dir_center);
  
  	float diff = 1.0f - ((global_k + c.rest_length) / dist_center);
  	glm::vec3 dir_force = dir_center * diff;
  	glm::vec3 fa = c.k_prime * ((2.0f*W[c.p1])/c.w) * dir_force;
  	glm::vec3 fb = c.k_prime * ((2.0f*W[c.p2])/c.w) * dir_force;
  	glm::vec3 fc = -c.k_prime * ((4.0f*W[c.p3])/c.w) * dir_force;
  
  	If(W[c.p1] > 0.0)  {
  		tmp_X[c.p1] += fa;
  	}
  	If(W[c.p2] > 0.0) {
  		tmp_X[c.p2] += fb;
  	}
  	If(W[c.p3] > 0.0) {
  		tmp_X[c.p3] += fc;
  	}
  #else
  
  	//Using the dihedral angle approach of the position based dynamics		
  	float d = 0, phi=0,i_d=0;
  	glm::vec3 n1=glm::vec3(0), n2=glm::vec3(0);
  	
  	glm::vec3 p1 = tmp_X[c.p1];
  	glm::vec3 p2 = tmp_X[c.p2]-p1;
  	glm::vec3 p3 = tmp_X[c.p3]-p1;
  	glm::vec3 p4 = tmp_X[c.p4]-p1;
  
  	glm::vec3 p2p3 = glm::cross(p2,p3);		
  	glm::vec3 p2p4 = glm::cross(p2,p4);		
  
  	float lenp2p3 = glm::length(p2p3);
  	
  	If(lenp2p3 == 0.0) { Return; } //need to handle this case.
  
  	float lenp2p4 = glm::length(p2p4);
  
  	If(lenp2p4 == 0.0) { Return; } //need to handle this case.
  	
  	n1 = glm::normalize(p2p3);
  	n2 = glm::normalize(p2p4); 
  
   	d	= glm::dot(n1,n2);
  	phi = ACos(d);
  
  	;try To catch invalid values that will Return NaN.
  	; sqrt(1 - (1.0001*1.0001)) = NaN 
  	; sqrt(1 - (-1.0001*-1.0001)) = NaN 
  	If(d<-1.0) 
  		d = -1.0; 
  	Else If(d>1.0) 
  		d=1.0; //d = clamp(d,-1.0,1.0);
  	
  	;in both Case sqrt(1-d*d) will be zero And nothing will be done.
  	;0� Case, the triangles are facing in the opposite direction, folded together.
  	If(d == -1.0){ 
  	   phi = PI;  //acos(-1.0) == PI
         If(phi == phi0[index]) 
  		   Return; //nothing to do 
  
        ;in this Case one just need To push 
  	  ;vertices 1 And 2 in n1 And n2 directions, 
  	  ;so the constrain will do the work in second iterations.
  	  If(c.p1!=0 && c.p1!=numX)
  		tmp_X[c.p3] += n1/100.0f;
  
  	  If(c.p2!=0 && c.p2!=numX)
  		tmp_X[c.p4] += n2/100.0f;
  
  	  Return;
  	}
  	If(d == 1.0){; //180� Case, the triangles are planar
  		phi = 0.0;  //acos(1.0) == 0.0
          If(phi == phi0[index]) 
  			Return; //nothing to do 
  	}
  
  	i_d = sqrt(1-(d*d))*(phi-phi0[index]) ;
  
  	glm::vec3 p2n1 = glm::cross(p2,n1);
  	glm::vec3 p2n2 = glm::cross(p2,n2);
  	glm::vec3 p3n2 = glm::cross(p3,n2);
  	glm::vec3 p4n1 = glm::cross(p4,n1);
  	glm::vec3 n1p2 = -p2n1;
  	glm::vec3 n2p2 = -p2n2;
  	glm::vec3 n1p3 = glm::cross(n1,p3);
  	glm::vec3 n2p4 = glm::cross(n2,p4);
  
  	glm::vec3 q3 =  (p2n2 + n1p2*d)/ lenp2p3;
  	glm::vec3 q4 =  (p2n1 + n2p2*d)/ lenp2p4;
  	glm::vec3 q2 =  (-(p3n2 + n1p3*d)/ lenp2p3) - ((p4n1 + n2p4*d)/lenp2p4);
  
  	glm::vec3 q1 = -q2-q3-q4;
  	
  	float q1_len2 = glm::dot(q1,q1);// glm::length(q1)*glm::length(q1);
  	float q2_len2 = glm::dot(q2,q2);// glm::length(q2)*glm::length(q1);
  	float q3_len2 = glm::dot(q3,q3);// glm::length(q3)*glm::length(q1);
  	float q4_len2 = glm::dot(q4,q4);// glm::length(q4)*glm::length(q1); 
  
  	float sum = W[c.p1]*(q1_len2) +
  				W[c.p2]*(q2_len2) +
  				W[c.p3]*(q3_len2) +
  				W[c.p4]*(q4_len2);	
  				
  	glm::vec3 dP1 = -( (W[c.p1] * i_d) /sum)*q1;
  	glm::vec3 dP2 = -( (W[c.p2] * i_d) /sum)*q2;
  	glm::vec3 dP3 = -( (W[c.p3] * i_d) /sum)*q3;
  	glm::vec3 dP4 = -( (W[c.p4] * i_d) /sum)*q4;
  	
  	If(W[c.p1] > 0.0) {
  		tmp_X[c.p1] += dP1*c.k;
  	}
  	If(W[c.p2] > 0.0) {
  		tmp_X[c.p2] += dP2*c.k;
  	}
  	If(W[c.p3] > 0.0) {
  		tmp_X[c.p3] += dP3*c.k;
  	}	
  	If(W[c.p4] > 0.0) {
  		tmp_X[c.p4] += dP4*c.k;
  	}  
  #endif
  }
;   //----------------------------------------------------------------------------------------------------
  Procedure GroundCollision(*Me.PBD_t)
    Define i
    Define *p.Math::v3f32
    For i=0 To *Me\geom\nbpoints - 1
      *p = CArray::GetValue(*Me\tmp_X, i)
      ;collision With zero ground
  		If *p\y<0 : *p\y=0 : EndIf
  	Next
  EndProcedure
  
  	
  Procedure EllipsoidCollision(*Me.PBD_t)
;   	For(size_t i=0;i<total_points;i++) {
;   		glm::vec4 X_0 = (inverse_ellipsoid*glm::vec4(tmp_X[i],1));
;   		glm::vec3 delta0 = glm::vec3(X_0.x, X_0.y, X_0.z) - center;
;   		float distance = glm::length(delta0);
;   		If (distance < 1.0f) {
;   			delta0 = (radius - distance) * delta0 / distance;
;   
;   			// Transform the delta back To original space
;   			glm::vec3 delta;
;   			glm::vec3 transformInv;
;   			transformInv = glm::vec3(ellipsoid[0].x, ellipsoid[1].x, ellipsoid[2].x);
;   			transformInv /= glm::dot(transformInv, transformInv);
;   			delta.x = glm::dot(delta0, transformInv);
;   			transformInv = glm::vec3(ellipsoid[0].y, ellipsoid[1].y, ellipsoid[2].y);
;   			transformInv /= glm::dot(transformInv, transformInv);
;   			delta.y = glm::dot(delta0, transformInv);
;   			transformInv = glm::vec3(ellipsoid[0].z, ellipsoid[1].z, ellipsoid[2].z);
;   			transformInv /= glm::dot(transformInv, transformInv);
;   			delta.z = glm::dot(delta0, transformInv);
;   			tmp_X[i] +=  delta ;
;   			V[i] = glm::vec3(0);
;   		} 
;   	}
  EndProcedure
  
  
  ;   UPDATE EXTERNAL CONSTRAINTS
  ; ----------------------------------------------------------------------------------------
  Procedure UpdateExternalConstraints(*Me.PBD_t)
  	EllipsoidCollision(*Me)
  EndProcedure
  	
  ;   UPDATE INTERNAL CONSTRAINTS
  ; ----------------------------------------------------------------------------------------
  Procedure UpdateInternalConstraints(*Me.PBD_t, deltaTime.f)
  	Define i=0, si
   
  	For si=0 To *Me\solver_iterations - 1
  		For i=0 To ListSize(*Me\distance_constraints()) - 1
  			UpdateDistanceConstraint(*Me, i)
  		Next
  		For i=0 To ListSize(*Me\bending_constraints()) - 1
  			UpdateBendingConstraint(*Me, i)
  		Next
  		GroundCollision(*Me)
  	Next
  EndProcedure
  
  ;   STEP PHYSICS
  ; ----------------------------------------------------------------------------------------
  Procedure StepPhysics( *Me.PDB_t, dt.f )
  	
  	ComputeForces(*Me)
  	IntegrateExplicitWithDamping(*Me, dt)
  	 
;   	; For collision constraints
;   	UpdateInternalConstraints(dt);	
;   	UpdateExternalConstraints();
;   
  	Integrate(*Me, dt)
  EndProcedure
  
  

EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 289
; FirstLine = 272
; Folding = ----
; EnableXP
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

  void DrawGrid()
  {
  	glBegin(GL_LINES);
  	glColor3f(0.5f, 0.5f, 0.5f);
  	For(int i=-GRID_SIZE;i<=GRID_SIZE;i++)
  	{
  		glVertex3f((float)i,0,(float)-GRID_SIZE);
  		glVertex3f((float)i,0,(float)GRID_SIZE);
  
  		glVertex3f((float)-GRID_SIZE,0,(float)i);
  		glVertex3f((float)GRID_SIZE,0,(float)i);
  	}
  	glEnd();
  }
  
  inline glm::vec3 GetNormal(int ind0, int ind1, int ind2) {
  	glm::vec3 e1 = X[ind0]-X[ind1];
  	glm::vec3 e2 = X[ind2]-X[ind1];
  	Return glm::normalize(glm::cross(e1,e2));
  }
  
  #ifndef USE_TRIANGLE_BENDING_CONSTRAINT
  inline float GetDihedralAngle(BendingConstraint c, float& d, glm::vec3& n1, glm::vec3& n2) {	 
  	n1 = GetNormal(c.p1, c.p2, c.p3);
  	n2 = GetNormal(c.p1, c.p2, c.p4); 
  	d = glm::dot(n1, n2);
  	Return ACos(d);
  }
  #else
  inline int getIndex(int i, int j) {
  	Return j*(numX+1) + i;
  }
  #endif
  void InitGL() { 
   
  	startTime = (float)glutGet(GLUT_ELAPSED_TIME);
  	currentTime = startTime;
  
  	// get ticks per second
      QueryPerformanceFrequency(&frequency);
  
      // start timer
      QueryPerformanceCounter(&t1);
  
  
  	glEnable(GL_DEPTH_TEST);
  	size_t i=0, j=0, count=0;
  	int l1=0, l2=0;
  	float ypos = 7.0f;
  	int v = numY+1;
  	int u = numX+1;
  
  	indices.resize( numX*numY*2*3);
   
  	X.resize(total_points);
  	tmp_X.resize(total_points);
  	V.resize(total_points);
  	F.resize(total_points); 
  	Ri.resize(total_points); 
  	 
  	//fill in positions
  	For(int j=0;j<=numY;j++) {		 
  		For(int i=0;i<=numX;i++) {	 
  			X[count++] = glm::vec3( ((float(i)/(u-1)) *2-1)* hsize, size+1, ((float(j)/(v-1) )* size));
  		}
  	}
  
  	///DevO: 24.07.2011
  	W.resize(total_points); 
  	For(i=0;i<total_points;i++) {	
  		W[i] = 1.0f/mass;
  	}
  	/// 2 Fixed Points 
  	W[0] = 0.0;
  	W[numX] = 0.0;
  
  	memcpy(&tmp_X[0].x, &X[0].x, SizeOf(glm::vec3)*total_points);
  
  	//fill in velocities	 
  	memset(&(V[0].x),0,total_points*SizeOf(glm::vec3));
  
  	//fill in indices
  	GLushort* id=&indices[0];
  	For (int i = 0; i < numY; i++) {        
  		For (int j = 0; j < numX; j++) {            
  			int i0 = i * (numX+1) + j;            
  			int i1 = i0 + 1;            
  			int i2 = i0 + (numX+1);            
  			int i3 = i2 + 1;            
  			If ((j+i)%2) {                
  				*id++ = i0; *id++ = i2; *id++ = i1;                
  				*id++ = i1; *id++ = i2; *id++ = i3;            
  			} Else {                
  				*id++ = i0; *id++ = i2; *id++ = i3;                
  				*id++ = i0; *id++ = i3; *id++ = i1;            
  			}        
  		}    
  	}
  	 
  	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  	//glPolygonMode(GL_BACK, GL_LINE);
  	glPointSize(5);
  
  	wglSwapIntervalEXT(0);
  
  	//check the damping values
  	If(kStretch>1)
  		kStretch=1;
  	If(kStretch<0)
  		kStretch=0;
  	If(kBend>1)
  		kBend=1;
  	If(kBend<0)
  		kBend=0;
  	If(kDamp>1)
  		kDamp=1;
  	If(kDamp<0)
  		kDamp=0;
  	If(global_dampening>1)
  		global_dampening = 1;
  
  	//setup constraints
  	// Horizontal
  	For (l1 = 0; l1 < v; l1++)	// v
  		For (l2 = 0; l2 < (u - 1); l2++) {
  			AddDistanceConstraint((l1 * u) + l2,(l1 * u) + l2 + 1, kStretch);
  		}
  
  	// Vertical
  	For (l1 = 0; l1 < (u); l1++)	
  		For (l2 = 0; l2 < (v - 1); l2++) {
  			AddDistanceConstraint((l2 * u) + l1,((l2 + 1) * u) + l1, kStretch);
  		}
  
  	
  	// Shearing distance constraint
  	For (l1 = 0; l1 < (v - 1); l1++)	
  		For (l2 = 0; l2 < (u - 1); l2++) {
  			AddDistanceConstraint((l1 * u) + l2,((l1 + 1) * u) + l2 + 1, kStretch);
  			AddDistanceConstraint(((l1 + 1) * u) + l2,(l1 * u) + l2 + 1, kStretch);
  		}
  
  	
  	// create bending constraints	
  	#ifdef USE_TRIANGLE_BENDING_CONSTRAINT
  	//add vertical constraints
  	For(int i=0;i<=numX;i++) {
  		For(int j=0;j<numY-1 ;j++) {
  			AddBendingConstraint(getIndex(i,j), getIndex(i,(j+1)), getIndex(i,j+2), kBend);
  		}
  	}
  	//add horizontal constraints
  	For(int i=0;i<numX-1;i++) {
  		For(int j=0;j<=numY;j++) {	   
  			AddBendingConstraint(getIndex(i,j), getIndex(i+1,j), getIndex(i+2,j), kBend);
  		}
  	}
  
  	#else
  	For(int i = 0; i < v-1; ++i) {
  		For(int j = 0; j < u-1; ++j) {	 			 
  			int p1 = i * (numX+1) + j;            
  			int p2 = p1 + 1;            
  			int p3 = p1 + (numX+1);            
  			int p4 = p3 + 1;   
  			 
  			If ((j+i)%2) {  						
  				AddBendingConstraint(p3,p2,p1,p4, kBend);	
  			} Else {  
  				AddBendingConstraint(p4,p1,p3,p2, kBend);
  			}     
  		}
  	}		 
  	float d;
  	glm::vec3 n1, n2;
  	phi0.resize(b_constraints.size());
  	
  	For(i=0;i<b_constraints.size();i++) {		
  		phi0[i] = GetDihedralAngle(b_constraints[i],d,n1,n2);		
  	}	
  	#endif
  
  	//create a basic ellipsoid object
  	ellipsoid = glm::translate(glm::mat4(1),glm::vec3(0,2,0));
  	ellipsoid = glm::rotate(ellipsoid, 45.0f ,glm::vec3(1,0,0));
  	ellipsoid = glm::scale(ellipsoid, glm::vec3(fRadius,fRadius,fRadius/2));
  	inverse_ellipsoid = glm::inverse(ellipsoid);
  }
  
  
  
  	sprintf_s(info, "FPS: %3.2f, Frame time (GLUT): %3.4f msecs, Frame time (QP): %3.3f", fps, frameTime, frameTimeQP);
  	glutSetWindowTitle(info);
  
  	glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
  	glLoadIdentity();
  
  	//set viewing transformation
  	glTranslatef(0,0,dist);
  	glRotatef(rX,1,0,0);
  	glRotatef(rY,0,1,0);
  	
  	glGetDoublev(GL_MODELVIEW_MATRIX, MV);
  	viewDir.x = (float)-MV[2];
  	viewDir.y = (float)-MV[6];
  	viewDir.z = (float)-MV[10];
  	Right = glm::cross(viewDir, Up);
  
  	//draw grid
  	DrawGrid();
  	
  	//draw ellipsoid
  	glColor3f(0,1,0);
  	glPushMatrix();
  		glMultMatrixf(glm::value_ptr(ellipsoid));
  			glutWireSphere(fRadius, iSlices, iStacks);
  	glPopMatrix();
  
  
  	//draw polygons
  	glColor3f(1,1,1);
  	glBegin(GL_TRIANGLES);
  	For(i=0;i<indices.size();i+=3) {
  		glm::vec3 p1 = X[indices[i]];
  		glm::vec3 p2 = X[indices[i+1]];
  		glm::vec3 p3 = X[indices[i+2]];
  		glVertex3f(p1.x,p1.y,p1.z);
  		glVertex3f(p2.x,p2.y,p2.z);
  		glVertex3f(p3.x,p3.y,p3.z);
  	}
  	glEnd();	 
  
  	//draw points
  	
  	glBegin(GL_POINTS);
  	For(i=0;i<total_points;i++) {
  		glm::vec3 p = X[i];
  		int is = (i==selected_index);
  		glColor3f((float)!is,(float)is,(float)is);
  		glVertex3f(p.x,p.y,p.z);
  	}
  	glEnd();
  
  
  	//draw normals For Debug only 	
  #ifndef USE_TRIANGLE_BENDING_CONSTRAINT
  #ifdef _DEBUG
  	BendingConstraint b;
  	float size = 0.1f;
  	float d = 0;
  	glm::vec3 n1, n2, c1, c2;
  
  	
  	glBegin(GL_LINES);
  	For(i=0;i<b_constraints.size();i++) {
  		b = b_constraints[i];
  		c1 = (X[b.p1] + X[b.p2] + X[b.p3]) /3.0f;
  		c2 = (X[b.p1] + X[b.p2] + X[b.p4]) /3.0f;
  		GetDihedralAngle(b,d,n1,n2);
  		glColor3f(Abs(n1.x), Abs(n1.y), Abs(n1.z) );
  		glVertex3f(c1.x,c1.y,c1.z);		glVertex3f(c1.x+size*n1.x,c1.y+size*n1.y,c1.z+size*n1.z);
  
  		glColor3f(Abs(n2.x), Abs(n2.y), Abs(n2.z));
  		glVertex3f(c2.x,c2.y,c2.z);		glVertex3f(c2.x+size*n2.x,c2.y+size*n2.y,c2.z+size*n2.z);
  	}
  	glEnd();
  #endif
  #endif
  	glutSwapBuffers();
  }
  

  
  Procedure ComputeForces(*Me.PDB_t)
  	Define i=0
  	
  	For i=0 To *Me\geom\nbpoints - 1
  		F[i] = glm::vec3(0); 
  		 
  		;add gravity force
  		If(W[i]>0)		 
  			F[i] += gravity ; 
  	}	
  } 
  void IntegrateExplicitWithDamping(float deltaTime) {
  	float deltaTimeMass = deltaTime;
  	size_t i=0;
   
  	glm::vec3 Xcm = glm::vec3(0);
  	glm::vec3 Vcm = glm::vec3(0);
  	float sumM = 0;
  	For(i=0;i<total_points;i++) {
  
  		V[i] *= global_dampening; //global velocity dampening !!!		
  		V[i] = V[i] + (F[i]*deltaTime)*W[i]; 	 					
  		
  		//calculate the center of mass's position 
  		//And velocity For damping calc
  		Xcm += (X[i]*mass);
  		Vcm += (V[i]*mass);
  		sumM += mass;
  	}
  	Xcm /= sumM; 
  	Vcm /= sumM; 
  
  	glm::mat3 I = glm::mat3(1);
  	glm::vec3 L = glm::vec3(0);
  	glm::vec3 w = glm::vec3(0);//angular velocity
  	
  	
  	For(i=0;i<total_points;i++) { 
  		Ri[i] = (X[i] - Xcm);	
  		
  		L += glm::cross(Ri[i],mass*V[i]); 
  
  		//thanks To DevO For pointing this And these notes really helped.
  		//http://www.sccg.sk/~onderik/phd/ca2010/ca10_lesson11.pdf
  
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
; CursorPosition = 410
; FirstLine = 180
; Folding = ----
; EnableXP
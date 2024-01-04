XIncludeFile "../objects/Geometry.pbi"

DeclareModule Verlet
  #DEFAULT_DAMPING =  -0.0
  #KsStruct = 50.75
  #KdStruct = -0.25
  #KsShear = 50.75
  #KdShear = -0.25
  #KsBend = 50.75
  #KdBend = -0.25
  
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
    *X.CArray::CArrayV3F32          ; position
    *X_last.CArray::CArrayV3F32     ; last position
    *F.CArray::CArrayV3F32          ; force
    *I.CArray::CArrayFloat          ; input weight
    *springs.CArray::CArrayPtr      ; linear springs
    mass.f
    gravity.Math::v3f32
  	
  EndStructure
  
  Declare New(*geom.Geometry::Geometry_t, mass.f)
  Declare Delete(*Me.Verlet_t)
  Declare Deform(*Me.Verlet_t)
  Declare Draw(*Me.Verlet_t, *drawer.Drawer::Drawer_t)
  Declare AddSpring(*Me.Verlet_t, a.i, b.i, ks.f, kd.f, type.i)
  Declare RigGeometry(*Me.Verlet_t)
  Declare StepPhysics(*Me.Verlet_t, dt.f)
  Declare ComputeForces(*Me.Verlet_t, dt.f)
  
EndDeclareModule

Module Verlet
  
  ; ------------------------------------------------------------------------
  ;   Add Spring
  ; ------------------------------------------------------------------------
  Procedure AddSpring(*Me.Verlet_t, a.i, b.i, ks.f, kd.f, type.i)
    Define *spring.Spring_t = AllocateStructure(Spring_t)
  	
  	*spring\p1=a
  	*spring\p2=b
  	*spring\Ks=ks
  	*spring\Kd=kd
  	*spring\type = type
  	
  	Define delta.Math::v3f32
  	Define.Math::v3f32 *a, *b
  	*a = CArray::GetPtr(*Me\X, a)
  	*b = CArray::GetPtr(*Me\X, b)
  	Vector3::Sub(delta, *b, *a)
  	*spring\rest_length = Vector3::Length(delta)
  	CArray::AppendPtr(*Me\springs, *spring)
  	ProcedureReturn *spring
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ;   Is Real Edge
  ; ------------------------------------------------------------------------
  Procedure.b IsRealEdge(*geom.Geometry::PolymeshGeometry_t, a.i, b.i)
    Define i, x, y
    Define *cur.Geometry::HalfEdge_t, *nxt.Geometry::HalfEdge_t
    For i=0 To CArray::GetCount(*geom\a_halfedges)-1
      *cur = CArray::GetValuePtr(*geom\a_halfedges, i)
      *nxt = *cur\next_he
      x = *cur\vertex
      y = *nxt\vertex
      If (a=x And b=y) Or (a=y And b=x) : ProcedureReturn #True : EndIf
    Next
    ProcedureReturn #False

  EndProcedure
  
  ; ------------------------------------------------------------------------
  ;   Is Vertices in First Ring
  ; ------------------------------------------------------------------------
  Procedure InFirstRing( *geom.Geometry::PolymeshGeometry_t, idx.i, *firstring.CArray::CArrayLong)
    Define i
    For i=0 To CArray::GetCount(*firstring)-1
      If CArray::GetValueL(*firstring, i) = idx
        ProcedureReturn #True
      EndIf
    Next
    ProcedureReturn #False
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ; Rig Geometry
  ; ------------------------------------------------------------------------
  Procedure RigGeometry(*Me.Verlet_t)
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geom
    Define i, j, k, a, b
 
    Define numVertices = *geom\nbpoints
    Define *neighbors.CArray::CArrayLong = CArray::New(CArray::#ARRAY_LONG)
    Define *secondary.CArray::CArrayLong = CArray::New(CArray::#ARRAY_LONG)

    ; clear old rig
    CArray::DeleteReferences(*Me\springs, Verlet::Spring_t, 0)
    
    NewMap unique_edges()
    Define edgeKey.s
    For i=0 To numVertices - 1
      ; get first ring vertices
      PolymeshGeometry::GetVertexAdjacents(*geom, i, *neighbors)
      
      For j=0 To Carray::GetCount(*neighbors)-1
        a = i
        b = CArray::GetValueL(*neighbors, j)
        If a = b : Continue : EndIf
        
        If b < a : Define t = a : a = b : b = t : EndIf
        edgeKey = Str(a)+","+Str(b)
        If Not FindMapElement(unique_edges(), edgeKey)
          
          Define *spring.Spring_t = AddSpring(*Me,a,b,#KsStruct,#KdStruct,#STRUCTURAL_SPRING)

          AddMapElement(unique_edges(), edgeKey)
          unique_edges() = *spring
        EndIf
      Next
      
;       ; get secondary ring vertices
;       For j=0 To CArray::GetCount(*neighbors)-1
; 
;         PolymeshGeometry::GetVertexAdjacents(*geom, CArray::GetValueL(*neighbors, j), *secondary)
;         For k=0 To CArray::GetCount(*secondary)-1
;           a = i
;           If a = k : Continue : EndIf
;           b = CArray::GetValueL(*secondary, k)
;           If Not InFirstRing(*geom, b, *neighbors)
;             If b < a : Define t = a : a = b : b = t : EndIf
;             edgeKey = Str(a)+","+Str(b)
; ;             If Not FindMapElement(unique_edges(), edgeKey)
;     
;               Define *spring.Spring_t = AddSpring(*Me,a,b,#KsBend,#KdBend,#BEND_SPRING)
;               AddMapElement(unique_edges(), edgeKey)
;               unique_edges() = *spring
; ;             EndIf
;           EndIf
;           
;         Next
;       Next

    Next
    CArray::Delete(*neighbors)  
    CArray::Delete(*secondary)  
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ; Initialize
  ; ------------------------------------------------------------------------
  Procedure Init(*Me.Verlet_t)
    Select *Me\geom\type
      Case Geometry::#Polymesh
        Define *geom.Geometry::PolymeshGeometry_t = *Me\geom
        PolymeshGeometry::ComputeHalfEdges(*geom)
    EndSelect
    
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ; Deform
  ; ------------------------------------------------------------------------
   Procedure Deform(*Me.Verlet_t)
    Select *Me\geom\type
      Case Geometry::#Polymesh
        Define *geom.Geometry::PolymeshGeometry_t = *Me\geom
        CArray::Copy(*geom\a_positions, *Me\X)
        Polymesh::SetDirtyState(Geometry::GetParentObject3D(*Me\geom), Object3D::#DIRTY_STATE_DEFORM)
    EndSelect
    
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ; Draw
  ; ------------------------------------------------------------------------
  Procedure Draw(*Me.Verlet_t, *drawer.Drawer::Drawer_t)
    Define *positions.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
    Define *colors.CArray::CArrayC4F32 = CArray::New(CArray::#ARRAY_C4F32)
    Define numSprings = CArray::GetCount(*Me\springs)
    If numSprings > 0
      Define color.Math::c4f32
      CArray::SetCount(*positions,numSprings *2)
      CArray::SetCount(*colors,numSPrings *2)
      
      Define struct_color.Math::c4f32
      Define bend_color.Math::c4f32
      Define shear_color.Math::c4f32
      Color::Set(struct_color,0.5,0.9,0.5,1.0)
      Color::Set(bend_color,0.9,0.4,0.1,1.0)
      Color::Set(shear_color,0.1,0.6,0.9,1.0)
      
      Define i
      Define *spring.Verlet::Spring_t
      For i=0 To numSprings-1
        *spring = CArray::GetValuePtr(*Me\springs, i)
        CArray::SetValue(*positions, i*2, CArray::GetValue(*Me\X,  *spring\p1))
        CArray::SetValue(*positions, i*2+1, CArray::GetValue(*Me\X,  *spring\p2))
        If *spring\type = #STRUCTURAL_SPRING
          CArray::SetValue(*colors, i*2, struct_color)
          CArray::SetValue(*colors, i*2+1, struct_color)
        ElseIf *spring\type = #BEND_SPRING
          CArray::SetValue(*colors, i*2, bend_color)
          CArray::SetValue(*colors, i*2+1, bend_color)
        ElseIf *spring\type = #SHEAR_SPRING
          CArray::SetValue(*colors, i*2, shear_color)
          CArray::SetValue(*colors, i*2+1, shear_color)
        EndIf
      Next
      
      Define *line.Drawer::Line_t = Drawer::AddColoredLines(*drawer, *positions, *colors)
      Drawer::SetSize(*line, 2)
  ;     Color::Set(color,0.35,0.9,0.35,1.0)
  ;     Drawer::SetColor(*line, color)
  
      CArray::Copy(*positions, *Me\X)
      Define *pnt.Drawer::Point_t = Drawer::AddPoints(*drawer, *positions)
      Color::Set(color,1.0,0.2,0.35,1.0)
      Drawer::SetColor(*pnt, color)
      Drawer::SetSize(*pnt, 4)
    EndIf
    
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ; Integrate
  ; ------------------------------------------------------------------------
  Procedure Integrate(*verlet.Verlet_t, deltaTime.f) 
  	Define deltaTime2Mass.f = (deltaTime*deltaTime)/ *verlet\mass
  	Define i=0
    Define buffer.Math::v3f32, *Xi.Math::v3f32, *Xi_last.Math::v3f32, *Fi.Math::v3f32
  
    For i=0 To *verlet\geom\nbpoints - 1
      
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
  
  ; ------------------------------------------------------------------------
  ; Get Velocity Macro
  ; ------------------------------------------------------------------------
  Macro GetVelocity(_velocity, _Xi, _Xi_last, _dt )
    Vector3::Sub(_velocity, _Xi, _Xi_last)
    Vector3::ScaleInPlace(_velocity, 1.0/_dt)
  EndMacro
  
  ; ------------------------------------------------------------------------
  ; Compute Forces
  ; ------------------------------------------------------------------------
  Procedure ComputeForces(*Me.Verlet_t, dt.f)
  	Define i=0
  	Define *Fi.Math::v3f32, *Xi.Math::v3f32, *Xi_last.Math::v3f32
  	Define velocity.Math::v3f32

  	Define tmp.Math::v3f32
  	
  	For i=0 To *Me\geom\nbpoints - 1
  	  *Fi = CArray::GetValue(*Me\F, i)
  	  *Xi = CArray::GetValue(*Me\X, i)
  	  *Xi_last = CArray::GetValue(*Me\X_last, i)
  	  Vector3::Set(*Fi, 0, 0, 0)
  	  
  		GetVelocity(velocity, *Xi, *Xi_last, dt)
  		; add gravity force
  		;If i <> 0 And i <> numX		
  		  Vector3::AddInPlace(*Fi, *Me\gravity)
  		  Vector3::ScaleAddInPlace(*Fi,velocity, #DEFAULT_DAMPING)
  		;EndIf
  	Next
  	
  	Define *spring.Spring_t
  	Define.Math::v3f32 v1, v2, *p1, *p1_last, *p2, *p2_last, *f1, *f2
  	Define.Math::v3f32 deltaP, deltaV, springF
  	Define dist.f, leftTerm.f, rightTerm.f
  	For i=0 To *Me\springs\itemCount - 1
  	  *spring = CArray::GetValuePtr(*Me\springs, i)
  	  *p1 = CArray::GetValue(*Me\X, *spring\p1)
  	  *p1_last = CArray::GetValue(*Me\X_last, *spring\p1)
  	  *p2 = CArray::GetValue(*Me\X, *spring\p2)
  	  *p2_last = CArray::GetValue(*Me\X_last, *spring\p2)
  	  GetVelocity(v1, *p1, *p1_last, dt)
  	  GetVelocity(v2, *p2, *p2_last, dt)
  	  Vector3::Sub(deltaP, *p1, *p2)
  	  Vector3::Sub(deltaV, v1, v2)
  	  dist = Vector3::Length(deltaP)
  	  If Abs(dist)<0.0000001 : Continue : EndIf
  	  leftTerm = -*spring\Ks * (dist - *spring\rest_length)
  	  rightTerm = *spring\Kd * (Vector3::Dot(deltaV, deltaP)/dist)
  	  Vector3::Normalize(springF, deltaP)
  	  Vector3::ScaleInPlace(springF, leftTerm + rightTerm)
  	  *f1 = CArray::GetValue(*Me\F, *spring\p1)
  	  *f2 = CArray::GetValue(*Me\F, *spring\p2)
  	  ;If *spring\p1 <> 0 And *spring\p1 <> numX
  	    Vector3::AddInPlace(*f1, springF)
  	  ;EndIf
  	  ;If *spring\p2 <> 0 And *spring\p2 <> numX
  	    Vector3::SubInPlace(*f2, springF)
  	  ;EndIf
  	Next
  
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ;   CONSTRUCTOR
  ; ------------------------------------------------------------------------
  Procedure New(*geom.Geometry::Geometry_t, mass.f)
    Define *Me.Verlet_t = AllocateStructure(Verlet_t)

  	Vector3::Set(*Me\gravity, 0,-0.00981,0)
    *Me\mass = mass
    *Me\geom = *geom
    *Me\X = CArray::New(CArray::#ARRAY_V3F32)
    *Me\X_last = CArray::New(CArray::#ARRAY_V3F32)
    *Me\F = CArray::New(CArray::#ARRAY_V3F32)
    *Me\springs = CArray::New(CArray::#ARRAY_PTR)
    
    Define zeroForce.Math::v3f32
    Vector3::Set(zeroForce, 0, 0,0)
    CArray::Copy(*Me\X, *Me\geom\a_positions)
  	CArray::Copy(*Me\X_last, *Me\geom\a_positions)
  	CArray::SetCount(*Me\F, *Me\geom\nbpoints)
    CArray::Fill(*Me\F, zeroForce)
    ProcedureReturn *Me
  EndProcedure
  
  ; ------------------------------------------------------------------------
  ;   DESTRUCTOR
  ; ------------------------------------------------------------------------
  Procedure Delete(*Me.Verlet_t)
    CArray::Delete(*Me\X)
    CArray::Delete(*Me\X_last)
    CArray::Delete(*Me\F)
    CArray::DeleteReferences(*Me\springs, Verlet::Spring_t, 0)
    CArray::Delete(*Me\springs)
    FreeStructure(*Me)
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
  	Integrate(*Me, dt)
  
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
  
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 363
; FirstLine = 360
; Folding = ---
; EnableXP
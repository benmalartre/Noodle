XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"


DeclareModule HeatDiffusion
  UseModule Math
  Structure _Vertex_t
    valence.i                       ; num neighbor vertices
    *neighbors.CArray::CArrayLong   ; neighbor indices
    area.f                          ; 1/3 area of surrounding faces
    LCii.f                          ; diagonal laplacian weights
    *LCij.CArray::CArrayFloat       ; off diagonal  laplacian weights
    constrained.b                   ; true when this vertex is the heat source vertex
    u0.f                            ; heat initial condition
    ut.f                            ; heat after time t
    divX.f                          ; divergence of the normalized gradient of u on adjacent faces
    phi.f                           ; distance
    
  EndStructure
  
  Structure _Face_t
    normal.v3f32
    area.f
    gradu.v3f32
    center.v3f32
  EndStructure
  
  Structure Solver_t
    *mesh.Geometry::PolymeshGeometry_t
    minphi.f
    maxphi.f
    Array faces._Face_t(1)
    Array vertices._Vertex_t(1)
  EndStructure
  
  Declare Init(*solver.Solver_t, *mesh.Polymesh::Polymesh_t)
  Declare Reset(*solver.Solver_t, index.i)
  Declare Laplacian(*solver.Solver_t)
  Declare HeatFlow(*solver.Solver_t, steps.i, t.f)
  Declare GradU(*solver.Solver_t)
  Declare Divergence(*solver.SOlver_t)
  Declare Distance(*solver.Solver_t, steps.i)
  Declare GetColors(*solver.Solver_t, *colors.CArray::CArrayC4F32)
EndDeclareModule


Module HeatDiffusion
  ; Init from mesh geometry
  ;
  Procedure Init(*solver.Solver_t, *mesh.Polymesh::Polymesh_t)
    Define i, j
    Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
    Protected *neighbors.CArray::CArrayLong = CArray::New(CArray::#ARRAY_LONG)
    Protected *v._Vertex_t
    *solver\mesh = *geom
    ReDim *solver\vertices(*solver\mesh\nbpoints)
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      *v\neighbors = CArray::New(CArray::#ARRAY_LONG)
      PolymeshGeometry::GetVertexNeighbors(*solver\mesh, i, *v\neighbors)
      *v\valence = CArray::GetCount(*v\neighbors)
      *v\LCij = CArray::New(CArray::#ARRAY_FLOAT)
      CArray::SetCount(*v\LCij, *v\valence)
    Next
    
    ReDim *solver\faces(*solver\mesh\nbpolygons)
    
    CArray::Delete(*neighbors)
  EndProcedure
  
  ; Reset heat and distance solution
  ;
  Procedure Reset(*solver.Solver_t, index.i)
    Define i
    Define *v._Vertex_t
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      If i = index
        *v\constrained = #True
        *v\u0 = 1.0
      Else
        *v\constrained = #False
        *v\u0 = 0.0
      EndIf
      *v\ut = *v\u0
      *v\phi = 0
    Next
  EndProcedure
  
  ; Compute laplacian
  ;
  Procedure Laplacian(*solver.Solver_t)
    Define i, j, k
    Define sum.f, val.f, cot0.f, cot1.f, cotan.f
    Define *v._Vertex_t, *n._Vertex_t
    Define *polygons.CArray::CArrayLong = CArray::New(CArray::#ARRAY_LONG)
    PolymeshGeometry::ComputePolygonAreas(*solver\mesh)
    PolymeshGeometry::ComputeVertexPolygons(*solver\mesh)
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      *v\area = 0
      *v\LCii = 0
      For j = 0 To *v\valence - 1
        CArray::SetValueF(*v\LCij, j, 0)
      Next
      
      ; Calculation of vertex areas
      sum = 0.0    
      PolymeshGeometry::GetVertexPolygons(*solver\mesh, i, *polygons)
            
      For j = 0 To CArray::GetCount(*polygons) - 1
        sum + CArray::GetValueF(*solver\mesh\a_polygonareas, CArray::GetValueL(*polygons, j))
      Next
      *v\area = (1.0/3.0)*sum
      
      ; Calculation of LCii and LCij
      sum = 0
      For j = 0 To *v\valence - 1
        k = CArray::GetValueL(*v\neighbors, j)
        cot0 = PolymeshGeometry::ComputeCotangentWeight(*solver\mesh, i, k)
        cot1 = PolymeshGeometry::ComputeCotangentWeight(*solver\mesh, k, i)
        cotan = 1.0/Tan(cot0) + 1.0/Tan(cot1)
        sum + cotan
        val = (1.0/2.0) * cotan
        CArray::SetValueF(*v\LCij, j, val)
      Next
      *v\LCii = (-1.0 / 2.0) * sum
      
    Next
  EndProcedure
  
  ; Solve heat flow 
  ; Perform a specified number of projected Gauss-Seidel steps of the heat diffusion equation
  ;
  Procedure HeatFlow(*solver.Solver_t, steps.i, t.f)
    Define i, j, k
    Define *v._Vertex_t, *n._Vertex_t
    Define sum3.f
    For i = 0 To steps - 1
      For j =0 To ArraySize(*solver\vertices()) - 1
        *v = *solver\vertices(j)
        
        If *v\constrained : Continue : EndIf
        sum3 = 0.0
        For k = 0 To *v\valence - 1
          *n = *solver\vertices(CArray::GetValueL(*v\neighbors, k))
          sum3 + (t * CArray::GetValueF(*v\LCij, k) *  *n\ut)
        Next
        
        *v\ut = (*v\u0 + sum3) / (*v\area - (t * *v\LCii)) 
      Next
    Next
    
  EndProcedure
  
  ; Compute the gradient of heat at each face
  ;
  Procedure GradU(*solver.Solver_t)
    Protected *f._Face_t
    Protected offset = 0
    Protected n, a, b
    Protected e.v3f32, v.v3f32, *a.v3f32, *b.v3f32, *n.v3f32
    For i = 0 To ArraySize(*solver\faces())-1
      *f = *solver\faces(i)
      *n = CArray::GetValue(*solver\mesh\a_polygonnormals, i)
      n = CArray::GetValueL(*solver\mesh\a_facecount, i)
      Vector3::Set(*f\gradu, 0, 0, 0)
      
      For j = 0 To n-1
        a = CArray::GetValueL(*solver\mesh\a_faceindices, offset + j)
        b = CArray::GetValueL(*solver\mesh\a_faceindices, offset + ((j + 1) % n))
        c = CArray::GetValueL(*solver\mesh\a_faceindices, offset + ((j + 2) % n))
        *a = CArray::GetValue(*solver\mesh\a_positions, a)
        *b = CArray::GetValue(*solver\mesh\a_positions, b)
        
        Vector3::Sub(e, *b, *a)
        Vector3::Cross(v, *n, e)
        Vector3::ScaleInPlace(v, *solver\vertices(c)\ut)
        Vector3::AddInPlace(*f\gradu, v)
      Next
      
      Vector3::ScaleInPlace(*f\gradu, -1)
      Vector3::NormalizeInPlace(*f\gradu)
      offset + n
    Next
    
  EndProcedure
  
  ; Compute the divergence of normalized gradients at the vertices
  ;
  Procedure Divergence(*solver.Solver_t)
    Protected *he.Geometry::HalfEdge_t
    Protected *v._Vertex_t, *n._Vertex_t
    Protected *f._Face_t
    Protected sum.f, cot0.f, cot1.f
    Protected *a.v3f32, *b.v3f32, *c.v3f32, e1.v3f32, e2.v3f32
    Protected v, a, b, c
    
    For v = 0 To ArraySize(*solver\vertices()) - 1
      *v = *solver\vertices(v)
      sum = 0.0
      For j = 0 To *v\valence - 1
        a = CArray::GetValueL(*v\neighbors, j)
        b = CArray::GetValueL(*v\neighbors, (j + 1) % *v\valence)
        c = CArray::GetValueL(*v\neighbors, (j + 2) % *v\valence)
        *he = PolymeshGeometry::GetHalfEdge(*solver\mesh, v, a)
        *f = *solver\faces(*he\face)
        *a = CArray::GetValue(*solver\mesh\a_positions, a)
        *b = CArray::GetValue(*solver\mesh\a_positions, b)
        *c = CArray::GetValue(*solver\mesh\a_positions, c)
        
        Vector3::Sub(e1, *b, *a)
        Vector3::Sub(e2, *c, *a)
        
        cot0 = PolymeshGeometry::ComputeCotangentWeight(*solver\mesh, a, b)
        cot1 = PolymeshGeometry::ComputeCotangentWeight(*solver\mesh, b, c)
        
        sum +  ( (1.0/Tan(cot0)) * Vector3::Dot(e1, *f\gradu) ) + ( (1.0/Tan(cot1)) * Vector3::Dot(e2, *f\gradu) )
      
      Next
      
      *v\divX = (0.5) * sum
    Next
  EndProcedure
  
  ; Solve the distance
  ; Uses Poisson equation, Laplacian of distance equal to divergence of normalized heat gradients.
  ; This is Step III in Algorithm 1 of the Geodesics in Heat paper, but here is done iteratively 
  ; with a Gauss-Seidel solve of some number of steps To refine the solution whenever this method 
  ; is called.
  ;
  Procedure Distance(*solver.Solver_t, steps.i)
    Protected *v._Vertex_t
    Protected i, j, k, n
    Define lcijSum.f
    For i = 0 To steps-1
      For j = 0 To ArraySize(*solver\vertices()) - 1
        *v = *solver\vertices(j)
        lcijSum = 0.0
        For k = 0 To *v\valence - 1
          n = CArray::GetValueL(*v\neighbors, k)
          lcijSum + CArray::GetValueF(*v\LCij, k) * *solver\vertices(n)\phi
        Next
        *v\phi = (*v\divX - lcijSum) / *v\LCii
      Next
    Next
    
   *solver\minphi = #F32_MAX
   *solver\maxphi = #F32_MIN
   
   For j = 0 To ArraySize(*solver\vertices()) -1
     *v = *solver\vertices(j)
     If IsNAN(*v\phi) : *v\phi = 0.0 : EndIf
     
     If *v\phi < *solver\minphi : *solver\minphi = *v\phi : EndIf
     If *v\phi > *solver\maxphi : *solver\maxphi = *v\phi : EndIf
   Next
   
   For j = 0 To ArraySize(*solver\vertices()) -1
     *v = *solver\vertices(j)
     *v\phi - *solver\minphi
   Next
   
   *solver\maxphi - *solver\minphi

  EndProcedure
  
  Procedure GetColors(*solver.Solver_t, *colors.CArray::CArrayC4F32)
    CArray::SetCount(*colors, ArraySize(*solver\vertices()))
    Define i
    Define c.c4f32
    Define *v._Vertex_t
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      Color::Set(c, RESCALE(*v\phi, 0, *solver\maxphi, 1, 0), RESCALE(*v\phi, 0, *solver\maxphi, 0, 1), 0, 1)
      CArray::SetValue(*colors, i, c)
    Next
    
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 274
; FirstLine = 236
; Folding = --
; EnableXP
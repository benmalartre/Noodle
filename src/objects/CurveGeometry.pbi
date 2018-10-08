
XIncludeFile "../core/Array.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Vertex.pbi"
XIncludeFile "../objects/Sample.pbi"
XIncludeFile "../objects/Topology.pbi"
XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/Location.pbi"
XIncludeFile "../objects/Object3D.pbi"

;========================================================================================
; CurveGeometry Module Declaration
;========================================================================================
DeclareModule CurveGeometry
  Macro CurvePeriodicity : l : EndMacro
  Enumeration
    #CURVE_NON_PERIODIC
    #CURVE_PERIODIC
  EndEnumeration
  
  Macro CurveType : l : EndMacro
  Enumeration
    #CURVE_CUBIC
    #CURVE_LINEAR
    #CURVE_VARIABLEORDER
  EndEnumeration
  
  UseModule Geometry
  UseModule Math
  Declare New(*parent)
  Declare Delete(*geom.CurveGeometry_t)
  Declare Set(*Me.CurveGeometry_t,*vertices.CArray::CArrayV3F32,*numVertices.CArray::CArrayLong=#Null)
  Declare SetFromOther(*geom.CurveGeometry_t,*other.CurveGeometry_t)
  Declare Reset(*geom.CurveGeometry_t)
  Declare SetPointsPosition(*Me.CurveGeometry_t,*v.CArray::CArrayV3F32)
  Declare SetPointsNormal(*Me.CurveGeometry_t,*v.CArray::CArrayV3F32)
  Declare Update(*Me.CurveGeometry_t)
  Declare GetNbCurves(*Me.CurveGeometry_t)
  Declare GetCurveNbPoints(*Me.CurveGeometry_t, index.i)
  Declare CatmullInterpolatePositions(*Me.CurveGeometry_t, *positions.CArray::CArrayV3f32)
  Declare CatmullInterpolateColors(*Me.CurveGeometry_t, *colors.CArray::CArrayV3f32)
  Declare CatmullInterpolateTangents(*Me.CurveGeometry_t, *normals.CArray::CArrayV3f32)
  Declare CatmullInterpolateWidths(*Me.CurveGeometry_t, *width.CArray::CArrayFloat)
EndDeclareModule

;========================================================================================
; CurveGeometry Module Implementation
;========================================================================================
Module CurveGeometry
  UseModule Geometry
  UseModule Math
  
  ;---------------------------------------------------------
  ; Set
  ;---------------------------------------------------------
  Procedure Set(*Me.CurveGeometry_t,*vertices.CArray::CArrayV3F32,*numVertices.CArray::CArrayLong=#Null)
    *Me\nbpoints = CArray::GetCount(*vertices)
    
    CArray::SetCount(*Me\a_positions, *Me\nbpoints)
    CArray::SetCount(*Me\a_velocities, *Me\nbpoints)
    CArray::SetCount(*Me\a_colors, *Me\nbpoints)
    CArray::SetCount(*Me\a_widths, *Me\nbpoints)
    CArray::SetCount(*Me\a_uvs, *Me\nbpoints)
    CArray::SetCount(*Me\a_normals, *Me\nbpoints)
    
    CArray::Copy(*Me\a_positions, *vertices)
    If *numVertices
      CArray::Copy(*Me\a_numVertices, *numVertices)
    Else
      CArray::SetCount(*Me\a_numVertices, 1)
      CArray::SetValueL(*Me\a_numVertices, 0, *Me\nbpoints)
    EndIf
    
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set From Other
  ;---------------------------------------------------------
  Procedure SetFromOther(*geom.CurveGeometry_t,*other.CurveGeometry_t)
    *geom\nbpoints = *other\nbpoints
    *geom\type = *other\type
    *geom\wrap = *other\wrap
    *geom\ubasis = *other\ubasis
    *geom\vbasis = *other\vbasis
    
    CArray::Copy(*geom\a_positions, *other\a_positions)
    CArray::Copy(*geom\a_colors, *other\a_colors)
    CArray::Copy(*geom\a_velocities, *other\a_velocities)
    CArray::Copy(*geom\a_numVertices, *other\a_numVertices)
    CArray::Copy(*geom\a_widths, *other\a_widths)
    CArray::Copy(*geom\a_uvs, *other\a_uvs)
    CArray::Copy(*geom\a_normals, *other\a_normals)
    
    If *other\a_knots : CArray::Copy(*geom\a_knots, *other\a_knots) : EndIf
    If *other\a_weights : CArray::Copy(*geom\a_weights, *other\a_weights) : EndIf
    If *other\a_orders : CArray::Copy(*geom\a_orders, *other\a_orders) : EndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Reset
  ;---------------------------------------------------------
  Procedure Reset(*geom.CurveGeometry_t)
    
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Points Position
  ;---------------------------------------------------------
  Procedure SetPointsPosition(*Me.CurveGeometry_t,*v.CArray::CArrayV3F32)
    Protected nbp = *Me\nbpoints
    
    ; ---[ Check Nb Points ]--------------------------------
    If CArray::GetCount(*v) = nbp
      ; ---[ Set Point Position ]---------------------------
      CArray::Copy(*Me\a_positions,*v)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Points Normal
  ;---------------------------------------------------------
  Procedure SetPointsNormal(*Me.CurveGeometry_t,*v.CArray::CArrayV3F32)

    Protected nbp = *Me\nbpoints
    
    ; ---[ Check Nb Points ]--------------------------------
    If CArray::GetCount(*v) = nbp
      ; ---[ Set Sample Normal ]---------------------------
      Protected i
      For i=0 To nbs-1
        CArray::SetValue(*Me\a_normals,i,CArray::GetValue(*v,i))
      Next 
    EndIf
  EndProcedure
 
  
  ;---------------------------------------------------------
  ; Update
  ;---------------------------------------------------------
  Procedure Update(*Me.CurveGeometry_t)
  
  
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Nb Curves
  ;---------------------------------------------------------
  Procedure.i GetNbCurves(*Me.CurveGeometry_t)
    ProcedureReturn CArray::GetCount(*Me\a_numVertices)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Nb Vertices
  ;---------------------------------------------------------
  Procedure GetCurveNbPoints(*Me.CurveGeometry_t, index.i)
    If CArray::GetCount(*Me\a_numVertices) < index
      ProcedureReturn CArray::GetValueL(*Me\a_numVertices, index)
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Point Position
  ;---------------------------------------------------------
  Procedure GetPointsPosition(*Me.CurveGeometry_t,*io_pos.CArray::CArrayV3F32)
    CArray::Copy(*io_pos,*Me\a_positions)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Point Normal
  ;---------------------------------------------------------
  Procedure GetPointsNormal(*Me.CurveGeometry_t,*io_norm.CArray::CArrayV3F32)
    CArray::Copy(*io_norm,*Me\a_normals)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Catmull Weights
  ;---------------------------------------------------------
  Procedure GetCatmullWeights(u.f, *weights.v4f32)
    Define.f uu, uuu
    uu = u * u
	  uuu = uu * u
	  
	  *weights\y = -2.0 * uuu + 3.0 * uu
	  *weights\x = 1.0 - *weights\y
	  *weights\z = uuu - 2.0 * uu + u
	  *weights\w = uuu - uu
	EndProcedure
	
	;---------------------------------------------------------
  ; Compute Curve Length
  ;---------------------------------------------------------
	Procedure.f ComputeLength(*Me.CurveGeometry_t, index.i)
	  If index <0 Or index >CArray::GetCount(*Me\a_numVertices)
	    ProcedureReturn -1
	  Else
	    Protected i
	    For i=0 To CArray::GetValueL(*Me\a_numVertices, index)-1
	      
	    Next
	    
	  EndIf
	  
	EndProcedure
	
	;---------------------------------------------------------
  ; Compute Curve Normals
  ;---------------------------------------------------------
	Procedure ComputeNormals(*Me.CurveGeometry_t)
	  Protected i, j, base=0
	  Protected numVertices.i
	  Protected nrm.v3f32
	  Protected upv.v3f32, t1.v3f32, t2.v3f32
	  Protected *p1.v3f32, *p2.v3f32, *p3.v3f32
	  Vector3::Set(upv, 0,0,1)
	  For i=0 To CArray::GetCount(*Me\a_numVertices)
	    numVertices = CArray::GetValueL(*Me\a_numVertices, i)
	    For j=0 To numVertices -1
	      If j = 0
	        *p1 = CArray::GetValue(*me\a_positions, base)
	        *p2 = CArray::GetValue(*me\a_positions, base+1)
          Vector3::Sub(t1, *p2, *p1)
        ElseIf j = numVertices - 2 Or *Me\nbpoints = j + base + 1
          *p1 = CArray::GetValue(*me\a_positions, base+j-1)
          *p2 = CArray::GetValue(*me\a_positions, base + j)
          Vector3::Sub(t1, *p2, *p1)
        Else
          *p1 = CArray::GetValue(*me\a_positions, j+base)
          *p2 = CArray::GetValue(*me\a_positions, j+base-1)
          *p3 = CArray::GetValue(*me\a_positions, j+base+1)
          Vector3::Sub(t1, *p1, *p2)
          Vector3::Sub(t2, *p3, *p1)
          Vector3::AddInPlace(t1, t2)
          Vector3::ScaleInPlace(t1, 0.5)
        EndIf
        Vector3::Cross(nrm, t1, upv)
        Vector3::NormalizeInPlace(nrm)
        CArray::SetValue(*Me\a_normals, j+base, @norm)
      Next
      base + numVertices
    Next
	EndProcedure
	
	;---------------------------------------------------------
  ; Compute Curve Samples
  ;---------------------------------------------------------
	Procedure.f ComputeSamples(*Me.CurveGeometry_t)
	  Protected i
	  Protected base.i = 0
	  Protected numCurves.i = CArray::GetCount(*Me\a_numVertices)
	  Protected numVertices.i
	  Protected numSamples.i
	  *Me\nbsamples = 0
	  CArray::SetCount(*Me\a_numSamples, numCurves)
	  For i=0 To numCurves - 1
	    numVertices = CArray::GetValueL(*Me\a_numVertices, i)
	    numSamples = Random(10)+64
	    
	    CArray::SetValueL(*Me\a_numSamples, i, numSamples)
	    base + numVertices
	    *Me\nbsamples + numSamples
	  Next
 
	EndProcedure
	
	
	;---------------------------------------------------------
  ; Get Catmull Position
  ;---------------------------------------------------------
  Procedure GetCatmullPosition(*P.v3f32, *A.v3f32, *B.v3f32, *C.v3f32, *D.v3f32, u.f)
    Protected weights.v4f32
    GetCatmullWeights(u, @weights)
  	; Tangents.
  	Protected t2.v3f32
  	Protected t3.v3f32
  	If *A
  	  Vector3::Sub(t2, *C, *A)
  	Else
  	  Vector3::Sub(t2, *C, *B)
  	EndIf
  	Vector3::ScaleInPlace(t2, 0.5)
  	
  	If *D
  	  Vector3::Sub(t3, *D, *B)
  	Else
  	  Vector3::Sub(t3, *C, *B)
  	EndIf
  	Vector3::ScaleInPlace(t3, 0.5)
  	
  	; Compute point at u
  	Protected x.f = weights\x * *B\x + weights\y * *C\x + weights\z * t2\x + weights\w * t3\x
  	Protected y.f = weights\x * *B\y + weights\y * *C\y + weights\z * t2\y + weights\w * t3\y
  	Protected z.f = weights\x * *B\z + weights\y * *C\z + weights\z * t2\z + weights\w * t3\z
  	
  	Vector3::Set(*P, x,y,z)

  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Catmull Tangent
  ;---------------------------------------------------------
  Procedure GetCatmullTangent(*T.v3f32, *A.v3f32, *B.v3f32)
    Vector3::Sub(*T, *B, *A)
    Vector3::NormalizeInPlace(*T)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Catmull Normal
  ;---------------------------------------------------------
  Procedure GetCatmullNormal(*N.v3f32, *A.v3f32, *B.v3f32, blend.f)
    Vector3::LinearInterpolate(*N, *A, *B, blend)
    Vector3::NormalizeInPlace(*N)
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Catmull Interpolate Positions
  ;---------------------------------------------------------
  Procedure CatmullInterpolatePositions(*Me.CurveGeometry_t, *positions.CArray::CArrayV3F32)
    Protected index.i = 0 
    Protected nbSamples.i
    Protected nbVertices.i
    Protected offsetSample.i = 0
    Protected offsetVertex.i = 0
    Protected i, ip1
    Protected u.f
    
    Protected *A.v3f32, *B.v3f32, *C.v3f32, *D.v3f32
    Protected gPos.f, fInc.f
    
    For index=0 To CArray::GetCount(*Me\a_numVertices)-1
      
      nbSamples = CArray::GetValueL(*Me\a_numSamples, index)
      nbVertices = CArray::GetValueL(*Me\a_numVertices, index)
      
      gPos = (nbVertices - 1) / (nbSamples-1)
      fInc = gPos
  
      ;First point is first of curve CVs
      CArray::SetValue(*positions, offsetSample, CArray::GetValue(*Me\a_positions, offsetVertex))
      
      For i=1 To nbSamples - 2
        ip1 = Int(gPos) + offsetVertex
        u = gPos - Round(gPos, #PB_Round_Down)
        If ip1 <= offsetVertex : *A = #Null : Else : *A = CArray::GetValue(*Me\a_positions, ip1-1) : EndIf
        *B = CArray::GetValue(*Me\a_positions, ip1)
        *C = CArray::GetValue(*Me\a_positions, ip1+1)
        If ip1 >= (offsetVertex + nbVertices - 2) : *D = #Null : Else : *D = CArray::GetValue(*Me\a_positions, ip1+2) : EndIf
        
        GetCatmullPosition(CArray::GetValue(*positions, offsetSample + i), *A, *B, *C, *D, u)
          
        gPos + fInc
      Next
      
      ; Last point is last of curve CVs
      CArray::SetValue(*positions, offsetSample + nbSamples - 1, CArray::GetValue(*Me\a_positions, offsetVertex + nbVertices - 1))
      
      offsetVertex + nbVertices
      offsetSample + nbSamples
      
      
    Next
    

  EndProcedure
  
  ;---------------------------------------------------------
  ; Catmull Interpolate Colors
  ;---------------------------------------------------------
  Procedure CatmullInterpolateColors(*Me.CurveGeometry_t, *colors.CArray::CArrayV3F32)
    Protected index.i
    Protected nbSamples.i
    Protected nbVertices.i
    Protected offsetSample.i = 0
    Protected offsetVertex.i = 0
    Protected *c1.c4f32, *c2.c4f32, *o.c4f32
    Protected gPos.f, fInc.f
    Protected i, ip1
    Protected u.f
    
    For index = 0 To CArray::GetCount(*Me\a_numVertices)-1
      nbVertices = CArray::GetValueL(*Me\a_numVertices, index)
      nbSamples = CArray::GetValueL(*Me\a_numSamples, index)
      gPos = (nbVertices - 1) / (nbSamples-1)
      fInc = gPos
      
      ;First point is first of curve CVs
      CArray::SetValue(*colors, offsetSample, CArray::GetValue(*Me\a_colors, offsetVertex))
      
      For i=1 To nbSamples - 2
        ip1 = Int(gPos) + offsetVertex
        u = gPos - Round(gPos, #PB_Round_Down)
        *c1 = CArray::GetValue(*Me\a_colors, ip1 )
        *c2 = CArray::GetValue(*Me\a_colors, ip1+1)
        *c1\a = 1
        *c2\a = 1
        *o = CArray::GetValue(*colors, i + offsetSample)
        Color::LinearInterpolate(*o, *c1, *c2, u)        
        gPos + fInc
      Next
      
      ; Last point is last of curve CVs
      CArray::SetValue(*colors, offsetSample + nbSamples-1, CArray::GetValue(*Me\a_colors,offsetVertex + nbVertices - 1))
      
      offsetSample + nbSamples
      offsetVertex + nbVertices
    Next

  EndProcedure
  
  ;---------------------------------------------------------
  ; Catmull Interpolate Tangents
  ;---------------------------------------------------------
  Procedure CatmullInterpolateTangents(*Me.CurveGeometry_t, *tangents.CArray::CArrayV3F32)
    Protected index.i
    Protected nbSamples.i
    Protected nbVertices.i
    Protected offsetSample.i = 0
    Protected offsetVertex.i = 0
    Protected gPos.f, fInc.f
    Protected i, ip1
    Protected u.f
    
    For index=0 To CArray::GetCount(*Me\a_numVertices) - 1
      nbVertices = CArray::GetValueL(*Me\a_numVertices, index)
      nbSamples = CArray::GetValueL(*Me\a_numSamples, index)
      gPos = (nbVertices - 1) / (nbSamples-1)
      fInc = gPos
      
          
      For i=0 To nbSamples - 1
        ip1 = Int(gPos) + offsetVertex
        u = gPos - Round(gPos, #PB_Round_Down)
        If ip1 <= offsetVertex
          GetCatmullTangent(CArray::GetValue(*tangents, offsetSample+i), CArray::GetValue(*Me\a_positions, offsetVertex), CArray::GetValue(*Me\a_positions, offsetVertex+1))
        ElseIf ip1 >=  (offsetVertex + nbVertices - 2) 
          GetCatmullTangent(CArray::GetValue(*tangents, offsetSample+i), CArray::GetValue(*Me\a_positions, offsetVertex+ nbVertices - 2), CArray::GetValue(*Me\a_positions, offsetVertex+ nbVertices - 2))
        Else
          GetCatmullTangent(CArray::GetValue(*tangents, offsetSample+i), CArray::GetValue(*Me\a_positions, ip1), CArray::GetValue(*Me\a_positions, ip+1))
        EndIf
        gPos + fInc
      Next
      
      offsetSample + nbSamples
      offsetVertex + nbVertices
     Next

   EndProcedure
   
   ;---------------------------------------------------------
  ; Catmull Interpolate Normals
  ;---------------------------------------------------------
  Procedure CatmullInterpolateNormals(*Me.CurveGeometry_t, *normals.CArray::CArrayV3F32)
    Protected index.i
    Protected nbSamples.i
    Protected nbVertices.i
    Protected offsetSample.i = 0
    Protected offsetVertex.i = 0
    Protected gPos.f, fInc.f
    Protected i, ip1
    Protected u.f
    
    For index=0 To CArray::GetCount(*Me\a_numVertices) - 1
      nbVertices = CArray::GetValueL(*Me\a_numVertices, index)
      nbSamples = CArray::GetValueL(*Me\a_numSamples, index)
      gPos = (nbVertices - 1) / (nbSamples-1)
      fInc = gPos
      
          
      For i=0 To nbSamples - 1
        ip1 = Int(gPos) + offsetVertex
        u = gPos - Round(gPos, #PB_Round_Down)
        If ip1 <= offsetVertex
          GetCatmullNormal(CArray::GetValue(*normals, offsetSample+i), CArray::GetValue(*Me\a_normals, offsetVertex), CArray::GetValue(*Me\a_normals, offsetVertex+1),u)
        ElseIf ip1 >=  (offsetVertex + nbVertices - 2) 
          GetCatmullNormal(CArray::GetValue(*normals, offsetSample+i), CArray::GetValue(*Me\a_normals, offsetVertex+ nbVertices - 2), CArray::GetValue(*Me\a_normals, offsetVertex+ nbVertices - 2),u)
        Else
          GetCatmullNormal(CArray::GetValue(*normals, offsetSample+i), CArray::GetValue(*Me\a_normals, ip1), CArray::GetValue(*Me\a_normals, ip+1),u)
        EndIf
        gPos + fInc
      Next
      
      offsetSample + nbSamples
      offsetVertex + nbVertices
     Next

  EndProcedure
  
  ;---------------------------------------------------------
  ; Catmull Interpolate Widths
  ;---------------------------------------------------------
  Procedure CatmullInterpolateWidths(*Me.CurveGeometry_t, *widths.CArray::CArrayFloat)
    Protected index.i
    Protected nbSamples.i
    Protected nbVertices.i
    Protected offsetSample.i = 0
    Protected offsetVertex.i = 0
    Protected w1.f, w2.f, bw.f
    Protected gPos.f, fInc.f
    Protected i, ip1
    Protected u.f
    CArray::Echo(*Me\a_widths)
    
    For index=0 To CArray::GetCount(*Me\a_numVertices) - 1
      nbVertices = CArray::GetValueL(*Me\a_numVertices, index)
      nbSamples = CArray::GetValueL(*Me\a_numSamples, index)
    
      gPos = (nbVertices - 1) / (nbSamples-1)
      fInc = gPos
    
      ;First point is first of curve CVs
      CArray::SetValueF(*widths, offsetSample, CArray::GetValueF(*Me\a_widths, offsetVertex))
      
      For i=1 To nbSamples - 2
        ip1 = Int(gPos) + offsetVertex
        u = gPos - Round(gPos, #PB_Round_Down)
        w1 = CArray::GetValueF(*Me\a_widths, ip1)
        w2 = CArray::GetValueF(*Me\a_widths, ip1+1)
        LINEAR_INTERPOLATE(bw, w1, w2, u)
        CArray::SetValueF(*widths, offsetSample + i, bw)
        gPos + fInc
      Next
      
      ; Last point is last of curve CVs
      CArray::SetValueF(*widths, offsetSample + nbSamples-1, CArray::GetValueF(*Me\a_widths, offsetVertex + nbVertices - 1))
      
      offsetSample + nbSamples
      offsetVertex + nbVertices
    Next
  EndProcedure
 
  ;---------------------------------------------------------
  ; Random One Curve
  ;---------------------------------------------------------
  Procedure RandomOneCurve(*Me.CurveGeometry_t, numCvs.i)
    *Me\nbpoints = numCvs
    CArray::SetCount(*Me\a_positions, *Me\nbpoints)
    CArray::SetCount(*Me\a_colors, *Me\nbpoints)
    CArray::SetCount(*Me\a_normals, *Me\nbpoints)
    CArray::SetCount(*Me\a_widths, *Me\nbpoints)
    CArray::SetCount(*Me\a_numVertices, 1)
    CArray::SetCount(*Me\a_numSamples, 1)
    Define i
    Define p.v3f32
    Define c.v3f32
    Define n.v3f32
    Define w.f
    Define offset.v3f32
    Vector3::Set(offset, 0,1,0)
    Vector3::Set(c, 1,0,0)
    Vector3::Set(n, 0,0,1)
    For i=0 To *Me\nbpoints-1
      Vector3::AddInPlace(p, offset)
      p\x + (1 - 2 *Random_0_1()) * 10
      p\y + (1 - 2 *Random_0_1()) * 10
      p\z + (1 - 2 *Random_0_1()) * 10
      CArray::SetValue(*Me\a_positions, i, @p)
      Vector3::Set(c, Random_0_1(), Random_0_1(), Random_0_1())
      CArray::SetValue(*Me\a_colors, i, @c)
      CArray::SetValue(*Me\a_normals, i, @n)
      CArray::SetValueF(*Me\a_widths, i, 0.1)
    Next
    CArray::SetValueL(*Me\a_numVertices, 0, *Me\nbpoints)
    CArray::SetValueL(*Me\a_numSamples, 0, 64)
    ComputeNormals(*Me)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Random N Curves
  ;---------------------------------------------------------
  Procedure RandomNCurves(*Me.CurveGeometry_t, N.i, numCVs.i)
    *Me\nbpoints = N * numCVs
   
    CArray::SetCount(*Me\a_positions, *Me\nbpoints)
    CArray::SetCount(*Me\a_colors, *Me\nbpoints)
    CArray::SetCount(*Me\a_normals, *Me\nbpoints)
    CArray::SetCount(*Me\a_widths, *Me\nbpoints)
    CArray::SetCount(*Me\a_numVertices, N)
    CArray::SetCount(*Me\a_numSamples, N)
    Define i, j, base = 0
    Define p.v3f32
    Define color.v3f32
    Define norm.v3f32
    Define w.f = 0.01
    Define offset.v3f32
    Define dec.f = 1.0 / (numCVs-1) * 0.1
    Define t1.v3f32, t2.v3f32
    Define upv.v3f32
    Vector3::Set(upv, 1,0,0)
    Vector3::Set(color, 1,0,0)
    Vector3::Set(norm, 0,0,1)
    For i=0 To N-1
      Math::UniformPointOnSphere(@offset)
      For j=0 To numCVs -1
        Vector3::AddInPlace(p, offset)
        p\x + (1 - 2 * Random_0_1())
        p\y + (1 - 2 * Random_0_1())
        p\z + (1 - 2 * Random_0_1())
        
        CArray::SetValue(*Me\a_positions, j+base, @p)
        Vector3::Set(color, Random_0_1(), Random_0_1(), Random_0_1())
        CArray::SetValue(*Me\a_colors, j+base, @color)
        CArray::SetValue(*Me\a_normals, j+base, @norm)
        CArray::SetValueF(*Me\a_widths, j+base, 0.1)
      Next

      CArray::SetValueL(*Me\a_numVertices, i, numCVs)
      Vector3::Set(p, 0,0,0)
      
      base + numCVs
    Next
    
    ComputeNormals(*Me)
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.CurveGeometry_t)
    ;---[ Clean all geometry datas ]---------------------------------
    CArray::Delete(*a_positions)
    CArray::Delete(*a_velocities)
    CArray::Delete(*a_numVertices)
    CArray::Delete(*a_baseVertices)
    CArray::Delete(*a_samples)
    CArray::Delete(*a_numSamplesPerCurve)
    
    CArray::Delete(*a_width)
    CArray::Delete(*a_uvs)
    CArray::Delete(*a_normals)
    
    If *a_weights : CArray::Delete(*a_weights) : EndIf
    If *a_orders : CArray::Delete(*a_orders) : EndIf
    If *a_knots : CArray::Delete(*a_knots) : EndIf
   
    ;---[ Deallocate Memory ]----------------------------------------
    ClearStructure(*Me,CurveGeometry_t)
    FreeMemory(*Me)
  EndProcedure

    
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.CurveGeometry_t = AllocateMemory(SizeOf(CurveGeometry_t))
    InitializeStructure(*Me,CurveGeometry_t)
    *Me\parent = *parent
    *Me\a_positions = CArray::newCArrayV3F32()
    *Me\a_colors = CArray::newCArrayV3F32()
    *Me\a_velocities = CArray::newCArrayV3F32()
    *Me\a_numVertices = CArray::newCArrayLong()
    *Me\a_numSamples = CArray::newCArrayLong()
    
    *Me\a_widths = CArray::newCArrayFloat()
    *Me\a_uvs = CArray::newCArrayV2F32()
    *Me\a_normals = CArray::newCArrayV3F32()
    
    RandomNCurves(*Me, 256, 6)
    ;RandomOneCurve(*Me, 8)
    ComputeSamples(*Me)
    ProcedureReturn *Me
  EndProcedure
  ;}
  
  
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 226
; FirstLine = 220
; Folding = ------
; EnableXP
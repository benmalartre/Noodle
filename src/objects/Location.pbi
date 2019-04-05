; ============================================================================
;  Location Object Module Implementation
; ============================================================================
XIncludeFile "Geometry.pbi"
XIncludeFile "../core/Array.pbi"
DeclareModule Location
  UseModule Geometry
  UseModule Math
  Declare GetPosition(*Me.Location_t)
  Declare GetNormal(*Me.Location_t)
  Declare GetSmoothedNormal(*Me.Location_t)
  Declare GetColor(*Me.Location_t)
  Declare GetAttribute(*Me.Location_t,attribute.s)
  Declare Update(*Me.Location_t)
  Declare SetTriangleID(*Me.Location_t,ID.i=-1)
  Declare SetUVW(*Me.Location_t,u.f=0.0,v.f=0.0,w.f=0.0)
  Declare Init(*Me.Location_t, *geom.Geometry::Geometry_t,*t.Transform::Transform_t,tid.i=-1,u.f=0.0,v.f=0.0,w.f=0.0)
  Declare ClosestPoint( *Me.Location_t, *A.v3f32, *B.v3f32, *C.v3f32, *P.v3f32, *distance, maxDistance.f=Math::#F32_MAX)
  Declare BarycentricInterpolate(*Me.Location_t, *datas.CArray::CArrayT, *output)
  DataSection
    LocationVT:
  EndDataSection
  
EndDeclareModule

Module Location
  UseModule Math
  
  ;---------------------------------------------------------
  ; Barycentrix Interpolate
  ;---------------------------------------------------------
  Procedure BarycentricInterpolate(*Me.Geometry::Location_t, *datas.CArray::CarrayT, *output)

  
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    Protected a,b,c
    
    a = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2)
    b = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1)
    c = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3)
    
    Select *datas\type
      Case CArray::#ARRAY_BOOL
        Define.b ba, bb, bc
        ba = Carray::GetValueB(*datas, a)
        bb = CArray::GetValueB(*datas, b)
        bc = CArray::GetValueB(*datas, c)
        PokeB(*output, Bool(ba * *Me\uvw\x + bb * *Me\uvw\y + bc * *Me\uvw\z>0))
        
      Case CArray::#ARRAY_LONG
        Define.l la, lb, lc
        la = Carray::GetValueL(*datas, a)
        lb = CArray::GetValueL(*datas, b)
        lc = CArray::GetValueL(*datas, c)
        
        PokeL(*output, la * *Me\uvw\x + lb * *Me\uvw\y + lc * *Me\uvw\z)
        
      Case CArray::#ARRAY_INT
        Define.i ia, ib, ic
        ia = Carray::GetValueI(*datas, a)
        ib = CArray::GetValueI(*datas, b)
        ic = CArray::GetValueI(*datas, c)
        
        PokeI(*output, ia * *Me\uvw\x + ib * *Me\uvw\y + ic * *Me\uvw\z)
        
      Case CArray::#ARRAY_FLOAT
        Define.f fa, fb, fc
        fa = Carray::GetValueF(*datas, a)
        fb = CArray::GetValueF(*datas, b)
        fc = CArray::GetValueF(*datas, c)
        
        PokeF(*output, fa * *Me\uvw\x + fb * *Me\uvw\y + fc * *Me\uvw\z)
        
      Case CArray::#ARRAY_V2F32
        Define.v2f32 *v2a, *v2b, *v2c
        *v2a = Carray::GetValue(*datas, a)
        *v2b = CArray::GetValue(*datas, b)
        *v2c = CArray::GetValue(*datas, c)
        
        Define *v2o.v2f32 = *output
        Vector2::Set(*v2o, 0, 0)
        Vector2::ScaleAddInPlace(*v2o, *v2a, *Me\uvw\x)
        Vector2::ScaleAddInPlace(*v2o, *v2b, *Me\uvw\y)
        Vector2::ScaleAddInPlace(*v2o, *v2c, *Me\uvw\z)
        
      Case CArray::#ARRAY_V3F32
        Define.v3f32 *v3a, *v3b, *v3c
        *v3a = Carray::GetValue(*datas, a)
        *v3b = CArray::GetValue(*datas, b)
        *v3c = CArray::GetValue(*datas, c)
        
        Define *v3o.v3f32 = *output
        Vector3::Set(*v3o, 0, 0, 0)
        Vector3::ScaleAddInPlace(*v3o, *v3a, *Me\uvw\x)
        Vector3::ScaleAddInPlace(*v3o, *v3b, *Me\uvw\y)
        Vector3::ScaleAddInPlace(*v3o, *v3c, *Me\uvw\z)
        
      Case CArray::#ARRAY_V4F32
        Define.v4f32 *v4a, *v4b, *v4c
        *v4a = Carray::GetValue(*datas, a)
        *v4b = CArray::GetValue(*datas, b)
        *v4c = CArray::GetValue(*datas, c)
        
        Define *v4o.v4f32 = *output
        Vector4::Set(*v4o, 0, 0, 0, 0)
        Vector4::ScaleAddInPlace(*v4o, *v4a, *Me\uvw\x)
        Vector4::ScaleAddInPlace(*v4o, *v4b, *Me\uvw\y)
        Vector4::ScaleAddInPlace(*v4o, *v4c, *Me\uvw\z)
        
      Case CArray::#ARRAY_C4F32
        Define.v4f32 *v4a, *v4b, *v4c
        *v4a = Carray::GetValue(*datas, a)
        *v4b = CArray::GetValue(*datas, b)
        *v4c = CArray::GetValue(*datas, c)
        
        Define *v4o.v4f32 = *output
        Vector4::Set(*v4o, 0, 0, 0, 0)
        Vector4::ScaleAddInPlace(*v4o, *v4a, *Me\uvw\x)
        Vector4::ScaleAddInPlace(*v4o, *v4b, *Me\uvw\y)
        Vector4::ScaleAddInPlace(*v4o, *v4c, *Me\uvw\z)
        
      Case CArray::#ARRAY_Q4F32
        Define.q4f32 *q4a, *q4b, *q4c
        *q4a = Carray::GetValue(*datas, a)
        *q4b = CArray::GetValue(*datas, b)
        *q4c = CArray::GetValue(*datas, c)
        
        Define *q4o.q4f32 = *output
        Vector4::Set(*q4o, 0, 0, 0, 0)
        Quaternion::Slerp(*q4o, *q4a, *q4b, *Me\uvw\x)
        Quaternion::Slerp(*q4o, *q4o, *q4c, *Me\uvw\y)

    EndSelect

  EndProcedure
    
  ;---------------------------------------------------------
  ; Get Position
  ;---------------------------------------------------------
  Procedure GetPosition(*Me.Geometry::Location_t)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
  
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    Protected a,b,c
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define *indices = *geom\a_triangleindices\data
      Define tid.i = *Me\tid
      Define *positions = *geom\a_positions\data
      Define *uvw = *Me\uvw
      Define *out = *Me\p
      
      ! mov rdx, [p.p_indices]            ; move indices to edx register
      ! mov rsi, [p.p_positions]          ; move positions to rsi register
      ! mov rdi, [p.p_out]                ; move output position to rdi register
      
      ! mov ecx, [p.v_tid]                ; move triangle index to edx register
      ! imul rcx, 12                      ; offset to desired triangle
      ! add rdx, rcx
      
      ! mov eax, [rdx]                    ; get value for desired point A
      ! imul rax, 16                      ; compute offset in position array
      ! movaps xmm2, [rsi + rax]          ; load point A to xmm2
      ! add rdx, 4                        ; offset next item
      
      ! mov eax, [rdx]             ; get value for desired point B
      ! imul rax, 16                      ; compute offset in position array
      ! movaps xmm1, [rsi + rax]          ; load point B to xmm1
      ! add rdx, 4                        ; offset next item
      
      ! mov eax, [rdx]             ; get value for desired point B
      ! imul rax, 16                      ; compute offset in position array
      ! movaps xmm0, [rsi + rax]          ; load point C to xmm0
      ! add rdx, 4                        ; offset next item
      
      ! mov rsi, [p.p_uvw]                ; load barycentric weights
      ! movups xmm3, [rsi]                
      ! movaps xmm4, xmm3                 ; duplicate them 
      ! movaps xmm5, xmm3                 ; duplicate them 
      
      ! shufps xmm3, xmm3, 00000000b      ; u u u u
      ! shufps xmm4, xmm4, 01010101b      ; v v v v
      ! shufps xmm5, xmm5, 10101010b      ; w w w w
      
      ! mulps xmm0, xmm3                  ; weight multiply vertex a posittion
      ! mulps xmm1, xmm4                  ; weight multiply vertex b posittion
      ! mulps xmm2, xmm5                  ; weight multiply vertex c posittion
      
      ! addps xmm0, xmm1                  ; add together
      ! addps xmm0, xmm2                  ; add together
      
      ! movups [rdi], xmm0                ; send back to memory
      
    CompilerElse
      a = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2)
      b = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1)
      c = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3)
      
      *a = CArray::GetValue(*geom\a_positions,a)
      *b = CArray::GetValue(*geom\a_positions,b)
      *c = CArray::GetValue(*geom\a_positions,c)
      
      ; Position : P= wA + uB + vC
      Vector3::Set(*Me\p,0,0,0)
      Vector3::Scale(x,*a, *Me\uvw\x)
      Vector3::AddInPlace(*Me\p,x)
      Vector3::Scale(x,*b, *Me\uvw\y)
      Vector3::AddInPlace(*Me\p,x)
      Vector3::Scale(x,*c, *Me\uvw\z)
      Vector3::AddInPlace(*Me\p,x)

    CompilerEndIf
    
    Vector3::MulByMatrix4InPlace(*Me\p,*Me\t\m)
    

  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Normal
  ;---------------------------------------------------------
  Procedure GetNormal(*Me.Location_t)
  
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    Define.v3f32 *a,*b,*c,ab,ac
    Define a = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2)
    Define b = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1)
    Define c = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3)
    
    *a = CArray::GetValue(*geom\a_positions,a)
    *b = CArray::GetValue(*geom\a_positions,b)
    *c = CArray::GetValue(*geom\a_positions,c)

    Vector3::Sub(ab,*b,*a)
    Vector3::Sub(ac,*c,*a)
    
    Vector3::NormalizeInPlace(ab)
    Vector3::NormalizeInPlace(ac)
    Vector3::Cross(*Me\n,ab,ac)
  ;   Vector3::MulByMatrix4InPlace(*Me\n,*Me\t\GetMatrix())
    Vector3::NormalizeInPlace(*Me\n)
    ;   Vector3::MulByQuaternionInPlace(*Me\n,*Me\t\GetQuaternion())
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Smoothed Normal
  ;---------------------------------------------------------
  Procedure GetSmoothedNormal(*Me.Location_t)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
  
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
  ;   *a = *geom\a_pointnormals\GetValue(*geom\a_triangleindices\GetValue(*Me\tid*3))
  ;   *b = *geom\a_pointnormals\GetValue(*geom\a_triangleindices\GetValue(*Me\tid*3+1))
  ;   *c = *geom\a_pointnormals\GetValue(*geom\a_triangleindices\GetValue(*Me\tid*3+2))
    *a = CArray::GetValue(*geom\a_normals,*Me\tid*3)
    *b = CArray::GetValue(*geom\a_normals,*Me\tid*3+1)
    *c = CArray::GetValue(*geom\a_normals,*Me\tid*3+2)
    
  ;   Normal :
    Vector3::Set(*Me\n,0,0,0)
    Vector3::Scale(x,*a,*Me\uvw\x)
    Vector3::AddInPlace(*Me\n,x)
    Vector3::Scale(x,*b,*Me\uvw\y)
    Vector3::AddInPlace(*Me\n,x)
    Vector3::Scale(x,*c,*Me\uvw\z)
    Vector3::AddInPlace(*Me\n,x)
;     Vector3::MulByMatrix4InPlace(*Me\n,*Me\t)

  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Color
  ;---------------------------------------------------------
  Procedure GetColor(*Me.Location_t)
    Define.c4f32 *a,*b,*c
    Define.c4f32 x
  
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    *a = CArray::GetValue(*geom\a_colors,*Me\tid*3)
    *b = CArray::GetValue(*geom\a_colors,*Me\tid*3+1)
    *c = CArray::GetValue(*geom\a_colors,*Me\tid*3+2)
    
    ; Color : P= wA + uB + vC
    Vector3::Set(*Me\c,0,0,0)
    Vector3::Scale(x,*a,*Me\uvw\z)
    Vector3::AddInPlace(*Me\c,x)
    Vector3::Scale(x,*b,*Me\uvw\x)
    Vector3::AddInPlace(*Me\c,x)
    Vector3::Scale(x,*c,*Me\uvw\y)
    Vector3::AddInPlace(*Me\c,x)
  
  ;   ; Color
  ;   Color4_Set(*Me\n,0,0,0,0)
  ;   Color4_Scale(@x,*a,*Me\u)
  ;   Color4_AddInPlace(*Me\c,@x)
  ;   Color4_Scale(@x,*b,*Me\v)
  ;   Color4_AddInPlace(*Me\c,@x)
  ;   Color4_Scale(@x,*c,1-(*Me\u+*Me\v))
  ;   Color4_AddInPlace(*Me\c,@x)
    
    ProcedureReturn(*Me\c)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Interpolated Attribute
  ;---------------------------------------------------------
  Procedure GetAttribute(*Me.Location_t,attribute.s)
  
  EndProcedure
  
  ;---------------------------------------------------------
  ; Update
  ;---------------------------------------------------------
  Procedure Update(*Me.Location_t)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
    Define.v3f32 ab,ac
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    *a = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3))
    *b = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1))
    *c = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2))
    
    ; Position
    Vector3::Set(*Me\p,0,0,0)
    Vector3::Scale(x,*a,*Me\uvw\x)
    Vector3::AddInPlace(*Me\p,x)
    Vector3::Scale(x,*b,*Me\uvw\y)
    Vector3::AddInPlace(*Me\p,x)
    Vector3::Scale(x,*c,*Me\uvw\z)
    Vector3::AddInPlace(*Me\p,x)
    
    Vector3::MulByMatrix4InPlace(*Me\p, *Me\t\m)
    
    ; Normal
    Vector3::Sub(ab,*b,*a)
    Vector3::Sub(ac,*c,*a)
    Vector3::Cross(*Me\n,ab,ac)

    Vector3::NormalizeInPlace(*Me\n)
    
    Vector3::MulByMatrix4InPlace(*Me\n, *Me\t\m)
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Set Triangle ID
  ;------------------------------------------------------------------
  Procedure SetTriangleID(*Me.Location_t,ID.i=-1)
    If Not *Me : ProcedureReturn : EndIf
    *Me\tid = ID
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Set UVW
  ;------------------------------------------------------------------
  Procedure SetUVW(*Me.Location_t,u.f=0.0,v.f=0.0,w.f=0.0)
    If Not *Me : ProcedureReturn : EndIf
    Vector3::Set(*Me\uvw, u, v, w)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Closest Point
  ;------------------------------------------------------------------
  Procedure ClosestPoint( *Me.Location_t, *A.v3f32, *B.v3f32, *C.v3f32, *P.v3f32, *distance, maxDistance.f=Math::#F32_MAX)
    
    Protected edge0.v3f32
    Protected edge1.v3f32
    
    Vector3::Sub(edge0, *B, *A)
    Vector3::Sub(edge1, *C, *A)
    
    Protected v0.v3f32
    Vector3::Sub(v0, *A, *P)
    
    Define.f a,b,c,d,e
    a = Vector3::Dot(edge0, edge0)
    b = Vector3::Dot(edge0, edge1)
    c = Vector3::Dot(edge1, edge1)
    d = Vector3::Dot(edge0, v0)
    e = Vector3::Dot(edge1, v0)
    
    Define.f det, s, t
    det = a*c - b*b
    s = b*e - c*d
    t = b*d - a*e
    
    If ( s + t < det )
      If ( s < 0.0)
        If ( t < 0.0 )
          If ( d < 0.0 )
            s = -d/a
            CLAMP( s, 0.0, 1.0 )
            t = 0.0
          Else
            s = 0.0
            t = -e/c
            CLAMP( t, 0.0, 1.0 )
          EndIf
        Else
          s = 0.0
          t = -e/c
          CLAMP( t, 0.0, 1.0 )
        EndIf 
      ElseIf ( t < 0.0 )
        s = -d/a
        CLAMP( s, 0.0, 1.0 )
        t = 0.0
      Else
        Define invDet.f = 1.0 / det
        s * invDet
        t * invDet
      EndIf
     Else
      If ( s < 0.0 )
        Define tmp0.f = b+d
        Define tmp1.f = c+e
        If ( tmp1 > tmp0 )
          Define numer.f = tmp1 - tmp0
          Define denom.f = a-2*b+c
          s = numer/denom
          CLAMP( s, 0.0, 1.0 )
          t = 1-s
        Else
          t = -e/c
          CLAMP( t, 0.0, 1.0 )
          s = 0.0
        EndIf
      ElseIf ( t < 0.0 )
        If ( a+d > b+e )
          Define numer.f = c+e-b-d
          Define denom.f = a-2*b+c
          s = numer/denom
          CLAMP( s, 0.0, 1.0)
          t = 1-s
        Else
          s = -e/c
          CLAMP( s, 0.0, 1.0 )
          t = 0.0
        EndIf
      Else
        Define numer.f = c+e-b-d
        Define denom.f = a-2*b+c
        s = numer/denom
        CLAMP( s, 0.0, 1.0 )
        t = 1.0 - s
      EndIf
    EndIf
  
    Protected closest.v3f32, delta.v3f32
    Vector3::SetFromOther(closest, *A)
    Vector3::ScaleInPlace(edge0, s)
    Vector3::ScaleInPlace(edge1, t)
    Vector3::AddInPlace(closest, edge0)
    Vector3::AddInPlace(closest, edge1)
    
    Vector3::Sub(delta, *p, closest)
    d.f = Vector3::Length(delta)
    
    If d < maxDistance And d < PeekF(*distance)
      Vector3::SetFromOther(*Me\p, closest)
      Vector3::Set(*Me\uvw, 1.0- s - t, s, t)
      PokeF(*distance, d)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  
  EndProcedure
  
  
  ;---------------------------------------------
  ;  INIT
  ;---------------------------------------------
  Procedure.i Init(*Me.Location_t, *geom.Geometry::Geometry_t,*t.Transform::Transform_t,tid.i=-1,u.f=0.0,v.f=0.0,w.f=0.0)
    
    ; ----[ Initialize ]--------------------------------------------------------
    *Me\tid = tid
    *Me\geometry = *geom
    Vector3::Set(*Me\uvw, u, v, w)
    *Me\t = *t
    If *Me\geometry And *Me\tid>-1
      Update(*Me)
    EndIf
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 16
; Folding = ---
; EnableXP
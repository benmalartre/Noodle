; ============================================================================
;  Location Object Module Implementation
; ============================================================================
XIncludeFile "../core/Array.pbi"
XIncludeFile "Geometry.pbi"

DeclareModule Location
  UseModule Geometry
  UseModule Math
  Declare GetPosition(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
  Declare GetNormal(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
  Declare GetSmoothedNormal(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
  Declare GetColor(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
  Declare GetAttribute(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t,attribute.s, *m.m4f32)
  Declare Update(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
  Declare SetTriangleID(*Me.Location_t,ID.i=-1)
  Declare SetUVW(*Me.Location_t,u.f=0.0,v.f=0.0,w.f=0.0)
  Declare Init(*Me.Location_t, *geom.Geometry::Geometry_t, *m.m4f32,tid.i=-1,u.f=0.0,v.f=0.0,w.f=0.0)
  Declare ClosestPoint( *Me.Location_t, *A.v3f32, *B.v3f32, *C.v3f32, *P.v3f32, *distance, maxDistance.f=Math::#F32_MAX)
  Declare BarycentricInterpolate(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *datas.CArray::CArrayT, *output)
  Declare GetValue(*Me.Geometry::Location_t, *geom.Geometry::Geometry_t, *Array.CArray::CArrayT, *result)

  DataSection
    LocationVT:
  EndDataSection
  

  Macro GETVERTEXINDEX(_location, _geom, _index)
    CArray::GetValueL(_geom\a_triangleindices, _location\tid * 3 + (_index))
  EndMacro
   
EndDeclareModule

Module Location
  UseModule Math
  UseModule Types
  
  ;---------------------------------------------------------
  ; Get Value
  ;---------------------------------------------------------
  Procedure GetValue(*Me.Geometry::Location_t, *geom.Geometry::Geometry_t, *Array.CArray::CArrayT, *result)
    Select *geom\type
      Case Geometry::#Polymesh
        Define *mesh.Geometry::PolymeshGeometry_t = *geom
        Define u.f = *Me\uvw\u
        Define v.f = *Me\uvw\v
        Define w.f = *Me\uvw\w
        
        Define a
        Select *array\type
          Case #TYPE_BOOL
            Define b1.b = CArray::GetValueB(*array,GETVERTEXINDEX(*Me, *mesh,0))
            Define b2.b = CArray::GetValueB(*array,GETVERTEXINDEX(*Me, *mesh,1))
            Define b3.b = CArray::GetValueB(*array,GETVERTEXINDEX(*Me, *mesh,2))
            If u < v And u < 1 - (u + v)
              PokeB(*result, b1)
            ElseIf u > v And v < 1 - (u + v)
              PokeB(*result, b2)
            Else
              PokeB(*result, b2)
            EndIf
            
          Case #TYPE_INT
            Define i1.i = CArray::GetValueI(*array,GETVERTEXINDEX(*Me, *mesh,0))
            Define i2.i = CArray::GetValueI(*array,GETVERTEXINDEX(*Me, *mesh,1))
            Define i3.i = CArray::GetValueI(*array,GETVERTEXINDEX(*Me, *mesh,2))
            If u < v And u < 1 - (u + v)
              PokeI(*result, b1)
            ElseIf u > v And v < 1 - (u + v)
              PokeI(*result, b2)
            Else
              PokeI(*result, b2)
            EndIf
            
          Case #TYPE_FLOAT
            Define f1.f = CArray::GetValueF(*array,GETVERTEXINDEX(*Me, *mesh,0))
            Define f2.f = CArray::GetValueF(*array,GETVERTEXINDEX(*Me, *mesh,1))
            Define f3.f = CArray::GetValueF(*array,GETVERTEXINDEX(*Me, *mesh,2))
            
            PokeF(*result, f1 * u + f2 * v + f3 * 1 - (u+v))
            
          Case #TYPE_V2F32
            Define *v2f1.v2f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,0))
            Define *v2f2.v2f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,1))
            Define *v2f3.v2f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,2))
            Define *v2o.v2f32 = *result
            
            *v2o\x = *v2f1\x * u + *v2f2\x * v + *v2f3\x * 1 - (u+v)
            *v2o\y = *v2f1\y * u + *v2f2\y * v + *v2f3\y * 1 - (u+v)
            
          Case #TYPE_V3F32
            Define *v3f1.v3f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,0))
            Define *v3f2.v3f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,1))
            Define *v3f3.v3f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,2))
            Define *v3o.v3f32 = *result
            
            *v3o\x = *v3f1\x * u + *v3f2\x * v + *v3f3\x * 1 - (u+v)
            *v3o\y = *v3f1\y * u + *v3f2\y * v + *v3f3\y * 1 - (u+v)
            *v3o\z = *v3f1\z * u + *v3f2\z * v + *v3f3\z * 1 - (u+v)
            
          Case #TYPE_V4F32
            Define *v4f1.v4f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,0))
            Define *v4f2.v4f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,1))
            Define *v4f3.v4f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,2))
            Define *v4o.v4f32 = *result
            
            *v4o\x = *v4f1\x * u + *v4f2\x * v + *v4f3\x * 1 - (u+v)
            *v4o\y = *v4f1\y * u + *v4f2\y * v + *v4f3\y * 1 - (u+v)
            *v4o\z = *v4f1\z * u + *v4f2\z * v + *v4f3\z * 1 - (u+v)
            *v4o\w = *v4f1\w * u + *v4f2\w * v + *v4f3\w * 1 - (u+v)
            
          Case #TYPE_C4F32
            Define *c4f1.c4f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,0))
            Define *c4f2.c4f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,1))
            Define *c4f3.c4f32 = CArray::GetValue(*array, GETVERTEXINDEX(*Me, *mesh,2))
            Define *c4o.c4f32 = *result
            
            *c4o\r = *c4f1\r * u + *c4f2\r * v + *c4f3\r * 1 - (u+v)
            *c4o\g = *c4f1\g * u + *c4f2\g * v + *c4f3\g * 1 - (u+v)
            *c4o\b = *c4f1\b * u + *c4f2\b * v + *c4f3\b * 1 - (u+v)
            *c4o\a = *c4f1\a * u + *c4f2\a * v + *c4f3\a * 1 - (u+v)
            
            
        EndSelect
        
    EndSelect
    
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Barycentrix Interpolate
  ;---------------------------------------------------------
  Procedure BarycentricInterpolate(*Me.Geometry::Location_t, *geom.Geometry::PolymeshGeometry_t, *datas.CArray::CarrayT, *output)

    Protected a,b,c
    
    a = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2)
    b = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1)
    c = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3)
    
    Select *datas\type
      Case #TYPE_BOOL
        Define.b ba, bb, bc
        ba = Carray::GetValueB(*datas, a)
        bb = CArray::GetValueB(*datas, b)
        bc = CArray::GetValueB(*datas, c)
        PokeB(*output, Bool(ba * *Me\uvw\x + bb * *Me\uvw\y + bc * *Me\uvw\z>0))
        
      Case #TYPE_LONG
        Define.l la, lb, lc
        la = Carray::GetValueL(*datas, a)
        lb = CArray::GetValueL(*datas, b)
        lc = CArray::GetValueL(*datas, c)
        
        PokeL(*output, la * *Me\uvw\x + lb * *Me\uvw\y + lc * *Me\uvw\z)
        
      Case #TYPE_INT
        Define.i ia, ib, ic
        ia = Carray::GetValueI(*datas, a)
        ib = CArray::GetValueI(*datas, b)
        ic = CArray::GetValueI(*datas, c)
        
        PokeI(*output, ia * *Me\uvw\x + ib * *Me\uvw\y + ic * *Me\uvw\z)
        
      Case #TYPE_FLOAT
        Define.f fa, fb, fc
        fa = Carray::GetValueF(*datas, a)
        fb = CArray::GetValueF(*datas, b)
        fc = CArray::GetValueF(*datas, c)
        
        PokeF(*output, fa * *Me\uvw\x + fb * *Me\uvw\y + fc * *Me\uvw\z)
        
      Case #TYPE_V2F32
        Define.v2f32 *v2a, *v2b, *v2c
        *v2a = Carray::GetValue(*datas, a)
        *v2b = CArray::GetValue(*datas, b)
        *v2c = CArray::GetValue(*datas, c)
        
        Define *v2o.v2f32 = *output
        Vector2::Set(*v2o, 0, 0)
        Vector2::ScaleAddInPlace(*v2o, *v2a, *Me\uvw\x)
        Vector2::ScaleAddInPlace(*v2o, *v2b, *Me\uvw\y)
        Vector2::ScaleAddInPlace(*v2o, *v2c, *Me\uvw\z)
        
      Case #TYPE_V3F32
        Define.v3f32 *v3a, *v3b, *v3c
        *v3a = Carray::GetValue(*datas, a)
        *v3b = CArray::GetValue(*datas, b)
        *v3c = CArray::GetValue(*datas, c)
        
        Define *v3o.v3f32 = *output
        Vector3::Set(*v3o, 0, 0, 0)
        Vector3::ScaleAddInPlace(*v3o, *v3a, *Me\uvw\x)
        Vector3::ScaleAddInPlace(*v3o, *v3b, *Me\uvw\y)
        Vector3::ScaleAddInPlace(*v3o, *v3c, *Me\uvw\z)
        
      Case #TYPE_V4F32
        Define.v4f32 *v4a, *v4b, *v4c
        *v4a = Carray::GetValue(*datas, a)
        *v4b = CArray::GetValue(*datas, b)
        *v4c = CArray::GetValue(*datas, c)
        
        Define *v4o.v4f32 = *output
        Vector4::Set(*v4o, 0, 0, 0, 0)
        Vector4::ScaleAddInPlace(*v4o, *v4a, *Me\uvw\x)
        Vector4::ScaleAddInPlace(*v4o, *v4b, *Me\uvw\y)
        Vector4::ScaleAddInPlace(*v4o, *v4c, *Me\uvw\z)
        
      Case #TYPE_C4F32
        Define.v4f32 *v4a, *v4b, *v4c
        *v4a = Carray::GetValue(*datas, a)
        *v4b = CArray::GetValue(*datas, b)
        *v4c = CArray::GetValue(*datas, c)
        
        Define *v4o.v4f32 = *output
        Vector4::Set(*v4o, 0, 0, 0, 0)
        Vector4::ScaleAddInPlace(*v4o, *v4a, *Me\uvw\x)
        Vector4::ScaleAddInPlace(*v4o, *v4b, *Me\uvw\y)
        Vector4::ScaleAddInPlace(*v4o, *v4c, *Me\uvw\z)
        
      Case #TYPE_Q4F32
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
  Procedure GetPosition(*Me.Geometry::Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
  
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
      
      ! mov eax, [rdx]                    ; get value for desired point B
      ! imul rax, 16                      ; compute offset in position array
      ! movaps xmm1, [rsi + rax]          ; load point B to xmm1
      ! add rdx, 4                        ; offset next item
      
      ! mov eax, [rdx]                    ; get value for desired point B
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
    
    Vector3::MulByMatrix4InPlace(*Me\p,*m)
    

  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Normal
  ;---------------------------------------------------------
  Procedure GetNormal(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
  
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
  Procedure GetSmoothedNormal(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
  
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
  Procedure GetColor(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
    Define.c4f32 *a,*b,*c
    Define.c4f32 x
  
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
  Procedure GetAttribute(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t,attribute.s, *m.m4f32)
  
  EndProcedure
  
  ;---------------------------------------------------------
  ; Update
  ;---------------------------------------------------------
  Procedure Update(*Me.Location_t, *geom.Geometry::PolymeshGeometry_t, *m.m4f32)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
    Define.v3f32 ab,ac
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
    
    Vector3::MulByMatrix4InPlace(*Me\p, *m)
    
    ; Normal
    Vector3::Sub(ab,*b,*a)
    Vector3::Sub(ac,*c,*a)
    Vector3::Cross(*Me\n,ab,ac)

    Vector3::NormalizeInPlace(*Me\n)
    
    Vector3::MulByMatrix4InPlace(*Me\n, *m)
    
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
    
    Protected squaredDist.f = Pow(PeekF(*distance), 2)
    Protected edge0.v3f32
    Protected edge1.v3f32
    
    ; early reject too far triangles
    Vector3::Sub(edge0, *A, *P)
    If Vector3::LengthSquared(edge0) > squaredDist
      Vector3::Sub(edge0, *B, *P)
      If Vector3::LengthSquared(edge0) > squaredDist
        Vector3::Sub(edge0, *C, *P)
        If Vector3::LengthSquared(edge0) > squaredDist
          ProcedureReturn #False
        EndIf
      EndIf
    EndIf
    
    
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
            s = CLAMP( s, 0.0, 1.0 )
            t = 0.0
          Else
            s = 0.0
            t = -e/c
            t = CLAMP( t, 0.0, 1.0 )
          EndIf
        Else
          s = 0.0
          t = -e/c
          t = CLAMP( t, 0.0, 1.0 )
        EndIf 
      ElseIf ( t < 0.0 )
        s = -d/a
        s = CLAMP( s, 0.0, 1.0 )
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
          s = CLAMP( s, 0.0, 1.0 )
          t = 1-s
        Else
          t = -e/c
          t = CLAMP( t, 0.0, 1.0 )
          s = 0.0
        EndIf
      ElseIf ( t < 0.0 )
        If ( a+d > b+e )
          Define numer.f = c+e-b-d
          Define denom.f = a-2*b+c
          s = numer/denom
          s = CLAMP( s, 0.0, 1.0)
          t = 1-s
        Else
          s = -e/c
          s = CLAMP( s, 0.0, 1.0 )
          t = 0.0
        EndIf
      Else
        Define numer.f = c+e-b-d
        Define denom.f = a-2*b+c
        s = numer/denom
        s = CLAMP( s, 0.0, 1.0 )
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
    d.f = Vector3::LengthSquared(delta)
    
    If d < maxDistance * maxDistance And d < squaredDist
      Vector3::SetFromOther(*Me\p, closest)
      Vector3::Set(*Me\uvw, 1.0- s - t, s, t)
      PokeF(*distance, Sqr(d))
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
    Vector3::Set(*Me\uvw, u, v, w)
    If *geom And *Me\tid>-1
      Update(*Me, *geom, *t)
    EndIf
  EndProcedure
 
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 221
; FirstLine = 155
; Folding = ---
; EnableXP
XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"


DeclareModule MathUtils
  UseModule Math
  Declare TransformPositionArray(*io.CArray::CArrayV3F32,*points.CArray::CArrayV3F32,*m.m4f32)
  Declare TransformPositionArrayInPlace(*points.CArray::CArrayV3F32,*m.m4f32)
  Declare BuildCircleSection(*io.CArray::CArrayV3F32, nbp.i=12, radius.f=1.0,start_angle.f=0.0,end_angle.f=360.0)
  Declare BuildMatrixArray(*io.CArray::CArrayM4F32,*a.v3f32,*b.v3f32,*c.v3f32,*d.v3f32,*up.v3f32)
  Declare RotateVector(*v.v3f32,*q.q4f32,*io.v3f32)
  Declare DirectionToRotation(*io.m3f32,*dir.v3f32,*up.v3f32=#Null)
  Declare EvenlyInterpolate1D(A.f, B.f, N.i, *mem)
  Declare EvenlyInterpolate2D(*A.v2f32, *B.v2f32, N.i, *mem)
  Declare EvenlyInterpolate3D(*A.v3f32, *B.v3f32, N.i, *mem)
  Declare EvenlyInterpolate4D(*A.v4f32, *B.v4f32, N.i, *mem)
EndDeclareModule

Module MathUtils
  UseModule Math
 
  ;  Transform Position Array
  ; ----------------------------------------------------------------------------
  Procedure TransformPositionArray(*io.CArray::CArrayV3F32,*points.CArray::CArrayV3F32,*m.m4f32)
    Protected i
    Protected nb = CArray::GetCount(*points)
    Protected v.v3f32
    CArray::SetCount(*io,nb)
    Protected *v.v3f32
    
    For i=0 To nb-1
      *v = CArray::GetValue(*points,i)
      Vector3::MulByMatrix4(v,*v,*m)
      CArray::SetValue(*io,i,v)
    Next
  EndProcedure
  
  ;  Transform Position Array In Place
  ; ----------------------------------------------------------------------------
  Procedure TransformPositionArrayInPlace(*points.CArray::CArrayV3F32,*m.m4f32)
    Protected i
    Protected nb = CArray::GetCount(*points)
    Protected *v.v3f32
    For i=0 To nb-1
      *v = CArray::GetValue(*points,i)
      Vector3::MulByMatrix4InPlace(*v,*m)
    Next
  EndProcedure

  ;  Build Circle Section
  ; ----------------------------------------------------------------------------
  Procedure BuildCircleSection(*io.CArray::CArrayV3F32, nbp.i=12, radius.f=1.0,start_angle.f=0.0,end_angle.f=360.0)
  
    Protected q.q4f32
    Protected axis.v3f32
    Protected r.v3f32
    Vector3::Set(axis,0,1,0)
    Vector3::Set(r,radius,0,0)
    Protected *p.v3f32
    Protected angle.f
    Protected i=0
    Protected st.f
  
    CArray::SetCount(*io,nbp)
    st = (end_angle-start_angle)/(nbp-1)
    For i=0 To nbp-1
      angle = start_angle + i* st
      *p = CArray::GetValue(*io,i)
      Quaternion::SetFromAxisAngle(q,axis,Radian(angle))
      Vector3::MulByQuaternion(*p,r,q)
      CArray::SetValue(*io,i,*p)
    Next
  
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Build Matrix Array
  ; ----------------------------------------------------------------------------
  Procedure BuildMatrixArray(*io.CArray::CArrayM4F32,*a.v3f32,*b.v3f32,*c.v3f32,*d.v3f32,*up.v3f32)
    Protected i
    Protected p.v3f32
    Protected o.v3f32
    Protected nb = CArray::GetCount(*io)
    
    Protected st.f = 1.0/ (nb-1)
    Protected u.f
    Protected previous.v3f32
    Protected delta.v3f32
    Protected up.v3f32,side.v3f32
    Protected q.q4f32
    Protected t.Transform::Transform_t
    
    
    Vector3::SetFromOther(previous,*a)
    Vector3::SetFromOther(up,*up)
    
    For i=0 To nb-1
      u = i* st
      Vector3::BezierInterpolate(p,*a,*b,*c,*d,u)
  
      ;Orientation
      If i>0
        Vector3::Sub(delta,p,previous)
        Vector3::NormalizeInPlace(delta)
        Vector3::Cross(side,*up,delta)
        Vector3::Cross(up,delta,side)
        Vector3::NormalizeInPlace(up)
        Quaternion::LookAt(t\t\rot,delta,up)
        Vector3::SetFromOther(*up,up)
      EndIf
      
      ; Scale
      ;     Define r.f = 1 - i*st
      Define r.f = 1+Random(10)*0.01
      Vector3::Set(t\t\scl,r,r,r)
     
      ;Position
      Vector3::SetFromOther(t\t\pos,p)
      Transform::UpdateMatrixFromSRT(@t)
      CArray::SetValue(*io,i,t\m)
      
      If i=1
        Matrix4::SetTranslation(t\m,@previous)
        CArray::SetValue(*io,0,t\m)
      EndIf
      Vector3::SetFromOther(previous,p)
    Next

  EndProcedure
  
  ;-------------------------------------------------------------------
  ; Rotate Vector
  ;-------------------------------------------------------------------
  Procedure RotateVector(*v.v3f32,*q.q4f32,*io.v3f32)
    Protected len.f = Vector3::Length(*v)
    Protected vn.v3f32
    Protected q2.q4f32
    
    Vector3::Normalize(vn,*v)
    Quaternion::Conjugate(q2,*q)
    
    Protected vecQuat.q4f32, resQuat.q4f32
    
    Quaternion::Set(vecQuat,vn\x,vn\y,vn\z,1.0)
    Quaternion::Multiply(resQuat,vecQuat,q2)
    Quaternion::Multiply(resQuat,*q,resQuat)
    
    Vector3::Set(*io,resQuat\x,resQuat\y,resQuat\z)
    Vector3::SetLength(*io,len)
  EndProcedure
  
  ;-------------------------------------------------------------------
  ; Direction To Rotation
  ;-------------------------------------------------------------------
  Procedure DirectionToRotation(*io.m3f32,*dir.v3f32,*up.v3f32=#Null)
    If *up=#Null
      Define up.v3f32
      Vector3::Set(up,0,1,0)
      *up = @up
    EndIf
    
    Define.v3f32 xaxis, yaxis, zaxis
    Vector3::Normalize(zaxis,*dir)
    Vector3::Cross(xaxis,*up,zaxis)
    Vector3::NormalizeInPlace(xaxis)
    
    Vector3::Cross(yaxis,zaxis,xaxis)
    Vector3::NormalizeInPlace(yaxis)
    
    *io\v[0] = xaxis\x
    *io\v[3] = yaxis\x
    *io\v[6] = zaxis\x
    
    *io\v[1] = xaxis\y
    *io\v[4] = yaxis\y
    *io\v[7] = zaxis\y
    
    *io\v[2] = -xaxis\z
    *io\v[5] = -yaxis\z
    *io\v[8] = -zaxis\z
    
  EndProcedure
  
  
  ;-------------------------------------------------------------------
  ; Orient2D
  ;-------------------------------------------------------------------
  ; If Orient2D(A, B, C) > 0, C lies to the left of the directed line AB. 
  ; Equivalently, the triangle ABC is oriented counterclockwise
  ; If ORIENT2D(A, B, C) < 0, C lies To the right of the directed line AB
  ; And the triangle ABC is oriented clockwise
  ; If ORIENT2D(A, B, C) = 0, the three points are collinear
  ; The actual value returned by ORIENT2D(A, B, C) corresponds to twice the signed area of the triangle
  ; ABC (positive If ABC is counterclockwise, otherwise negative)
  ;-------------------------------------------------------------------
  Procedure.f Orient2D(*a.v2f32, *b.v2f32, *c.v2f32)
    Define.f acx, bcx, acy, bcy;
  
    acx = *a\x - *c\x
    bcx = *b\x - *c\x
    acy = *a\y - *c\y
    bcy = *b\y - *c\y
    ProcedureReturn acx * bcy - acy * bcx
  EndProcedure
  
  ;-------------------------------------------------------------------
  ; Orient3D
  ;-------------------------------------------------------------------
  ; If ORIENT3D(A, B, C, D) < 0, D lies above the supporting plane of triangle
  ; ABC, in the sense that ABC appears in counterclockwise order when viewe from D
  ; If ORIENT3D(A, B, C, D) > 0, D instead lies below the plane of ABC
  ; If ORIENT3D(A, B, C, D) = 0, the four points are coplanar
  ; The value returned by ORIENT3D(A, B, C, D) corresponds to six times the signed volume
  ; of the tetrahedron formed by the four points
  ;-------------------------------------------------------------------
  Procedure.f Orient3D(*a.v3f32, *b.v3f32, *c.v3f32, *d.v3f32)
    Define.f adx, bdx, cdx
    Define.f ady, bdy, cdy
    Define.f adz, bdz, cdz

    adx = *a\x - *d\x
    bdx = *b\x - *d\x
    cdx = *c\x - *d\x
    ady = *a\y - *d\y
    bdy = *b\y - *d\y
    cdy = *c\y - *d\y
    adz = *a\z - *d\z
    bdz = *b\z - *d\z
    cdz = *c\z - *d\z

    ProcedureReturn adx * (bdy * cdz - bdz * cdy) + bdx * (cdy * adz - cdz * ady) + cdx * (ady * bdz - adz * bdy)
  EndProcedure
  
  ;-------------------------------------------------------------------
  ; In Circle Test
  ;-------------------------------------------------------------------
  ; Return a positive value If the point pd lies inside the
  ; circle passing through pa, pb, And pc; a negative value if
  ; it lies outside; and zero if the four points are cocircular.
  ; The points pa, pb, And pc must be in counterclockwise
  ; order, Or the sign of the result will be reversed.
  ;-------------------------------------------------------------------
  Procedure.f InCircle(*a.v2f32, *b.v3f32, *c.v3f32, *d.v3f32)
    Define.f adx, ady, bdx, bdy, cdx, cdy
    Define.f abdet, bcdet, cadet
    Define.f alift, blift, clift
  
    adx = *a\x - *d\x
    ady = *a\y - *d\y
    bdx = *b\x - *d\x
    bdy = *b\y - *d\y
    cdx = *c\x - *d\x
    cdy = *c\y - *d\y
  
    abdet = adx * bdy - bdx * ady
    bcdet = bdx * cdy - cdx * bdy
    cadet = cdx * ady - adx * cdy
    alift = adx * adx + ady * ady
    blift = bdx * bdx + bdy * bdy
    clift = cdx * cdx + cdy * cdy
  
    ProcedureReturn alift * bcdet + blift * cadet + clift * abdet
  EndProcedure

  ;-------------------------------------------------------------------
  ; In Sphere Test
  ;-------------------------------------------------------------------
  ; Return a positive value if the point pe lies inside the
  ; sphere passing through pa, pb, pc, And pd; a negative value
  ; If it lies outside; and zero if the five points are
  ; cospherical.  The points pa, pb, pc, And pd must be ordered
  ; so that they have a positive orientation (As defined by
  ; orient3d()), or the sign of the result will be reversed.
  ;-------------------------------------------------------------------
  Procedure.f InSphere(*a.v3f32, *b.v3f32, *c.v3f32, *d.v3f32, *e.v3f32)
    Define.f aex, bex, cex, dex
    Define.f aey, bey, cey, dey
    Define.f aez, bez, cez, dez
    Define.f alift, blift, clift, dlift
    Define.f ab, bc, cd, da, ac, bd
    Define.f abc, bcd, cda, dab
  
    aex = *a\x - *e\x
    bex = *b\x - *e\x
    cex = *c\x - *e\x
    dex = *d\x - *e\x
    aey = *a\y - *e\y
    bey = *b\y - *e\y
    cey = *c\y - *e\y
    dey = *d\y - *e\y
    aez = *a\z - *e\z
    bez = *b\z - *e\z
    cez = *c\z - *e\z
    dez = *d\z - *e\z
  
    ab = aex * bey - bex * aey
    bc = bex * cey - cex * bey
    cd = cex * dey - dex * cey
    da = dex * aey - aex * dey
  
    ac = aex * cey - cex * aey
    bd = bex * dey - dex * bey
  
    abc = aez * bc - bez * ac + cez * ab
    bcd = bez * cd - cez * bd + dez * bc
    cda = cez * da + dez * ac + aez * cd
    dab = dez * ab + aez * bd + bez * da
  
    alift = aex * aex + aey * aey + aez * aez
    blift = bex * bex + bey * bey + bez * bez
    clift = cex * cex + cey * cey + cez * cez
    dlift = dex * dex + dey * dey + dez * dez
  
    ProcedureReturn (dlift * abc - clift * dab) + (blift * cda - alift * bcd)
  EndProcedure
  
  Procedure EvenlyInterpolate1D(A.f, B.f, N.i, *mem)
    For i=0 To N-1
      PokeF(*mem + i * 4, A + i * (B-A) / N)
    Next
  EndProcedure
  
  Procedure EvenlyInterpolate2D(*A.v2f32, *B.v2f32, N.i, *mem)
    Define *v.v2f32
    Define.f blend = 1.0 / N
    For i=0 To N-1
      *v = *mem + i*SizeOf(v2f32)
      LINEAR_INTERPOLATE(*mem, *A\x, *B\x, blend * i)
      LINEAR_INTERPOLATE(*mem, *A\y, *B\y, blend * i)
    Next
  EndProcedure
  
  Procedure EvenlyInterpolate3D(*A.v3f32, *B.v3f32, N.i, *mem)
    Define *v.v3f32
    Define.f blend = 1.0 / N
    For i=0 To N-1
      *v = *mem + i*SizeOf(v3f32)
      LINEAR_INTERPOLATE(*mem, *A\x, *B\x, blend * i)
      LINEAR_INTERPOLATE(*mem, *A\y, *B\y, blend * i)
      LINEAR_INTERPOLATE(*mem, *A\z, *B\z, blend * i)
    Next
  EndProcedure
  
  Procedure EvenlyInterpolate4D(*A.v4f32, *B.v4f32, N.i, *mem)
    Define *v.v4f32
    Define.f blend = 1.0 / N
    For i=0 To N-1
      *v = *mem + i*SizeOf(v4f32)
      LINEAR_INTERPOLATE(*mem, *A\x, *B\x, blend * i)
      LINEAR_INTERPOLATE(*mem, *A\y, *B\y, blend * i)
      LINEAR_INTERPOLATE(*mem, *A\z, *B\z, blend * i)
      LINEAR_INTERPOLATE(*mem, *A\w, *B\w, blend * i)
    Next
  EndProcedure
  


EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 8
; Folding = ---
; EnableXP
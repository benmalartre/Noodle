

XIncludeFile "../../core/Math.pbi"
UseModule Math


Procedure.s ArrayString(*A, nb)
  Protected *v.v3f32
  Protected s.s
  If nb > 12
    For i=0 To 5
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","+StrF(*v\w,3)+","
    Next
    For i=nb-7 To nb-1
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","+StrF(*v\w,3)+","
    Next
  Else
    For i=0 To nb-1
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","+StrF(*v\w,3)+","
    Next
  EndIf
    
  ProcedureReturn s
EndProcedure


Procedure Compare(*A1, *A2, nb)
  Protected *v1.v3f32, *v2.v3f32
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(v3f32)
    *v2 = *A2 + i * SizeOf(v3f32)
    If Abs(*v1\x - *v2\x) > 0.0001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\y - *v2\y) > 0.0001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\z - *v2\z) > 0.0001
      ProcedureReturn #False
    EndIf 
  Next
  
  ProcedureReturn #True
EndProcedure

; ---------------------------------------------------------------
;  VECTOR3 MUL BY MATRIX4
; ---------------------------------------------------------------
Procedure MulByMatrix4(*v.v3f32,*o.v3f32,*m.m4f32)
    ! mov rax, [p.p_v]
    ! mov rcx, [p.p_o]
    ! mov rdx, [p.p_m]
    
    ; load point
    ! movups  xmm0, [rcx]               ; d c b a
    ! movaps  xmm1, xmm0                ; d c b a       
    ! movaps  xmm2, xmm0                ; d c b a
    ! movaps  xmm3, xmm0                ; d c b a
    
    ; shuffle point
    ! shufps  xmm0, xmm0,0              ; a a a a 
    ! shufps  xmm1, xmm1,01010101b      ; b b b b
    ! shufps  xmm2, xmm2,10101010b      ; c c c c
    ! shufps  xmm3, xmm3,11111111b      ; d d d d
    
    ; load matrix
    ! movups  xmm4, [rdx]               ; m04 m03 m02 m01
    ! movups  xmm5, [rdx+16]            ; m14 m13 m12 m11
    ! movups  xmm6, [rdx+32]            ; m24 m23 m22 m21
    ! movups  xmm7, [rdx+48]            ; m34 m33 m32 m31
    
    ; packed multiplication
    ! mulps   xmm0, xmm4                ; a * row1
    ! mulps   xmm1, xmm5                ; b * row2
    ! mulps   xmm2, xmm6                ; c * row3
    
    ; packed addition
    ! addps   xmm0, xmm1                
    ! addps   xmm0, xmm2
    ! addps   xmm0, xmm7
    
    ; packed determinant division
    ! movaps xmm1, xmm0
    ! shufps xmm1, xmm1, 11111111b
    ! divps xmm0, xmm1
  
    ! movups [rax], xmm0                ; back to memory
EndProcedure


Macro MMulByMatrix4(_v,_o,_m)
  Define _x.f,_y.f,_z.f,_w.f
;   x = *o\x * *m\v[0] + *o\y * *m\v[1] + *o\z * *m\v[2] + *m\v[3]
;   y = *o\x * *m\v[4] + *o\y * *m\v[5] + *o\z * *m\v[6] + *m\v[7]
;   z = *o\x * *m\v[8] + *o\y * *m\v[9] + *o\z * *m\v[10] + *m\v[11]
;   w = *o\x * *m\v[12] + *o\y * *m\v[13] + *o\z * *m\v[15] + *m\v[15]
;   *v\x = x/w
;   *v\y = y/w
;   *v\z = z/w
  _x = _o\x * _m\v[0] + _o\y * _m\v[4] + _o\z * _m\v[8] + _m\v[12]
  _y = _o\x * _m\v[1] + _o\y * _m\v[5] + _o\z * _m\v[9] + _m\v[13]
  _z = _o\x * _m\v[2] + _o\y * _m\v[6] + _o\z * _m\v[10] + _m\v[14]
  _w = _o\x * _m\v[3] + _o\y * _m\v[7] + _o\z * _m\v[11] + _m\v[15]
  _v\x = _x/_w
  _v\y = _y/_w
  _v\z = _z/_w
EndMacro


EnableExplicit

Define nb = 12800000
Define m.m4f32, *v.v3f32, v.v3f32, o.v3f32


m\v[0] = 0.5
m\v[1] = 0.33
m\v[2] = 0
m\v[3] = 0
m\v[4] = 0.5
m\v[5] = 0.5
m\v[6] = 0
m\v[7] = 0.2
m\v[8] = 0
m\v[9] = 0
m\v[10] = 1
m\v[11] = 0
m\v[12] = 0
m\v[13] = 0
m\v[14] = 0
m\v[15] = 1


m\v[12] = 3.3
m\v[13] = 7.25
m\v[14] = 1.007


o\x=0
o\y=1
o\z = 0

v\x = 0.5
v\y = 0.5
v\z = 2

Define *V1 = AllocateMemory(nb * SizeOf(v3f32))
Define i
For i=0 To nb-1 : *v = *V1 + i * SizeOf(v3f32) : CopyMemory(v, *v, SizeOf(v3f32)) : Next

Define T.q = ElapsedMilliseconds()
For i=0 To nb-1
  *v = *V1 + i * SizeOf(v3f32) 
  MMulByMatrix4(*v, v, m)
Next
Define T1.q = ElapsedMilliseconds() - T


Define *V2 = AllocateMemory(nb * SizeOf(v3f32))
For i=0 To nb-1 : *v = *V2 + i * SizeOf(v3f32) : CopyMemory(v, *v, SizeOf(v3f32)) : Next

Define T.q = ElapsedMilliseconds()
For i=0 To nb-1
  *v = *V2 + i * SizeOf(v3f32) 
  MulByMatrix4(*v, v, m)
Next
Define T2.q = ElapsedMilliseconds() - T

MessageRequester("MULTIPLY", Str(T1)+" ---> "+Str(T2)+" EQUALS : "+Str(Compare(*V1, *V2, nb))+Chr(10)+
                             ArrayString(*V1, nb)+Chr(10)+
                             ArrayString(*V2, nb))


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 2
; Folding = -
; EnableXP
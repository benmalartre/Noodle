XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"

UseModule Math


Macro FINDMINMAX(x0,x1,x2,min,max)
  min = x0
  max = x0
  If(x1<min) : min=x1 : ElseIf(x1>max) : max=x1 : EndIf
  If(x2<min) : min=x2 : ElseIf(x2>max) : max=x2 : EndIf
EndMacro 

DataSection 
  Data.f 0
EndDataSection

Procedure.b TriangleTouchBoxPB(*box.v3f32, *a.v3f32, *b.v3f32, *c.v3f32, *output.v3f32)
 ;      use separating axis theorem To test overlap between triangle And box
;      need To test For overlap in these directions:
;      
;      1) the {x,y,z}-directions (actually, since we use the AABB of the triangle
;      we do Not even need To test these)
;      2) normal of the triangle
;      3) crossproduct(edge from triangle, {x,y,z}-direction)
;      
;      this gives 3x3=9 more tests 
  Define.f min,max,p0,p1,p2,rad,fex,fey,fez
  
  ; compute triangle edges
  Define.v3f32 e0
  Vector3::Sub(e0, *b, *a)

  Define.v3f32 e1
  Vector3::Sub(e1, *c, *b)
  
  Define.v3f32 e2
  Vector3::Sub(e2, *a, *c)
  
  FINDMINMAX(*a\x,*b\x,*c\x,min,max)
  If(min>*box\x Or max<-*box\x) : Debug "FAIL 1" : ProcedureReturn #False : EndIf
  
 ; test in Y-direction
  FINDMINMAX(*a\y,*b\y,*c\y,min,max)
  If(min>*box\y Or max<-*box\y) : Debug "FAIL 2" : ProcedureReturn #False : EndIf
  
  ; test in Z-direction
  FINDMINMAX(*a\z,*b\z,*c\z,min,max)
  If(min>*box\z Or max<-*box\z) : Debug "FAIL 3" : ProcedureReturn #False : EndIf
  
  ; test If the box intersects the plane of the triangle
  ; compute plane equation of triangle: normal*x+d=0
  Protected normal.v3f32 
  Vector3::Cross(normal, e0, e1)
  
  ProcedureReturn #True
  
  Define.v3f32 vmin,vmax
  Define.f v
  v = *a\x
  If normal\x > 0.0 :  vmin\x = -*box\x - v : vmax\x = *box\x - v : Else : vmin\x = *box\x -v : vmax\x = -*box\x - v : EndIf
  v = *a\y
  If normal\y > 0.0 :  vmin\y = -*box\y - v : vmax\y = *box\y - v : Else : vmin\y = *box\y -v : vmax\y = -*box\y - v : EndIf
  v = *a\z
  If normal\z > 0.0 :  vmin\z = -*box\z - v : vmax\z = *box\z - v : Else : vmin\z = *box\z -v : vmax\z = -*box\z - v : EndIf
  
  If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
  If Vector3::Dot(normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
EndProcedure



Procedure.b TriangleTouchBox(*box.v3f32, *a.v3f32, *b.v3f32, *c.v3f32, *output.v3f32)
  
  ; ---------------------------------------------------------------------------------
  ; load points
  ; ---------------------------------------------------------------------------------
  ! mov rax, [p.p_a]
  ! movups xmm0, [rax]            ; move point a to xmm0
  ! movaps xmm1, xmm0             ; move point a to xmm1
  ! movaps xmm15, xmm1             ; make a copy in xmm8
  ! mov rax, [p.p_b]
  ! movups xmm2, [rax]            ; move point b to xmm2
  ! movaps xmm14, xmm2             ; make a copy in xmm9
  ! mov rax, [p.p_c]
  ! movups xmm3, [rax]            ; move point c to xmm3
  ! movaps xmm13, xmm3            ; make a copy in xmm10
  
  ; ---------------------------------------------------------------------------------
  ; load box
  ; ---------------------------------------------------------------------------------
  ! mov rcx, [p.p_box]            
  ! movups xmm12, [rcx]            ; move box half size to xmm4
  ! movaps xmm4, xmm12             ; copy to xmm4
  ! movaps xmm5, xmm12             ; copy to xmm5
  
  ! mov r8, math.l_sse_1111_negate_mask  
  ! movups  xmm6, [r8]            ; load 1111 negate mask stored in r8
  ! mulps xmm5, xmm6              ; -x -y -z -w (-boxhalfsize)
  
  ; ---------------------------------------------------------------------------------
  ; find min/max
  ; ---------------------------------------------------------------------------------
  ! minps xmm0, xmm2              ; packed minimum
  ! minps xmm0, xmm3              ; packed minimum
    
  ! maxps xmm1, xmm2              ; packed maximum
  ! maxps xmm1, xmm3              ; packed maximum
  
  ; ---------------------------------------------------------------------------------
  ; early axis rejection
  ; ---------------------------------------------------------------------------------
  ! cmpps xmm4, xmm0, 1           ; packed compare boxhalfsize < minimum
  ! movmskps r12, xmm4            ; get comparison result
  
  ! cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
  ! jg no_intersection                        
  
  ! cmpps xmm1, xmm5, 1           ; packed compare maximum < -boxhalfsize
  ! movmskps r12, xmm1                
  
  ! cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
  ! jg no_intersection       
  
  ; ---------------------------------------------------------------------------------
  ; triangle-box intersection
  ; ---------------------------------------------------------------------------------
  !   movaps xmm0, xmm15
  !   movaps xmm1, xmm14
  
  ; ---------------------------------------------------------------------------------
  ;  compute edges
  ; ---------------------------------------------------------------------------------
  !   subps xmm0, xmm1              ; compute edge0
  !   subps xmm1, xmm13             ; compute edge1
  
  !   movaps xmm2,xmm0              ; copies
  !   movaps xmm3,xmm1
  
  ; ---------------------------------------------------------------------------------
  ; compute triangle normal
  ; ---------------------------------------------------------------------------------
  !   shufps xmm0,xmm0,00001001b    ; exchange 2 and 3 element (V1)
  !   shufps xmm1,xmm1,00010010b    ; exchange 1 and 2 element (V2)
  !   mulps  xmm0,xmm0
         
  !   shufps xmm2,xmm2,00010010b    ; exchange 1 and 2 element (V1)
  !   shufps xmm3,xmm3,00001001b    ; exchange 2 and 3 element (V2)
  !   mulps  xmm2,xmm3
        
  !   subps  xmm0,xmm2             ; xmm0 contains triangle plane normal
  
  ; ---------------------------------------------------------------------------------
  ; check side
  ; ---------------------------------------------------------------------------------
  !   xorps xmm6, xmm6
  !   cmpps xmm6, xmm0 , 1            ; check 0 < normal
  !   movmskps r12, xmm6
  
  !   movaps xmm4, xmm12            ; copy boxhalfsize to xmm7
  !   movaps xmm5, xmm12            ; copy boxhalfsize to xmm7 
  
  !   movups  xmm6, [r8]            ; load 1111 negate mask stored in r8
  !   mulps xmm5, xmm6              ; -x -y -z -w (-boxhalfsize)
  
  !   subps xmm4, xmm15             ; box - p0
  !   subps xmm5, xmm15             ; -box - p0
  !   movaps xmm6, xmm4
  
  !   cmp r12, 0
  !   je case_0
  
  !   cmp r12, 1
  !   je case_1
  
  !   cmp r12, 2
  !   je case_2
  
  !   cmp r12, 3
  !   je case_3
  
  !   cmp r12, 4
  !   je case_4
  
  !   cmp r12, 5
  !   je case_5
  
  !   cmp r12, 6
  !   je case_6
  
  !   cmp r12, 7
  !   je case_7
  
  ! case_0:
  !   blendps xmm4, xmm5, 0                   ; vmin = -boxx-p0x, -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm5, xmm6, 7                   ; vmax = boxx-p0x,   boxy-p0y,  boxz-p0z,  boxw-p0w
  !   jmp normal_dot
  
  ! case_1:
  !   blendps xmm4, xmm5, 1                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm5, xmm6, 6                   ; vmax = -boxx-p0x,  boxy-p0y,  boxz-p0z,  boxw-p0w
  !   jmp normal_dot
  
  ! case_2:
  !   blendps xmm4, xmm5, 2                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm5, xmm6, 5                   ; vmax =  boxx-p0x,  -boxy-p0y, boxz-p0z,  boxw-p0w
  !   jmp normal_dot
  
  ! case_3:
  !   blendps xmm4, xmm5, 3                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm5, xmm6, 4                   ; vmax = -boxx-p0x, -boxy-p0y, boxz-p0z,  boxw-p0w
  !   jmp normal_dot
  
  ! case_4:
  !   blendps xmm4, xmm5, 4                   ; vmin = -boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm5, xmm6, 3                   ; vmax =  boxx-p0x,  boxy-p0y,  -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_5:
  !   blendps xmm4, xmm5, 5                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm5, xmm6, 2                   ; vmax = -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_6:
  !   blendps xmm4, xmm5, 6                   ; vmin = -boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm5, xmm6, 1                   ; vmax =  boxx-p0x,  boxy-p0y,  -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_7:
  !   blendps xmm4, xmm5, 7
  !   blendps xmm5, xmm6, 0
  !   jmp normal_dot
  
  
  ! normal_dot:
  !   jmp normal_dot_min
  
  ; ---------------------------------------------------------------------------------
  ; normal dot vmin > 0 ?
  ; ---------------------------------------------------------------------------------
  ! normal_dot_min:
  !   movups xmm0, [rax]
  !   movups xmm1, [rdx]
  !   mulps xmm0, xmm1
  !   haddps xmm0, xmm0
  !   haddps xmm0, xmm0
  !   movss [p.v_d], xmm0 
  
  ! normal_dot_max:
  
  
  
;   !   movss xmm0, [rax]
;   !   mulss xmm0, [rdx]
;   !   movss xmm1, [rax+4]
;   !   mulss xmm1, [rdx+4]
;   !   addss xmm0, xmm1
;   !   movss xmm2, [rax+8]
;   !   mulss xmm2, [rdx+8]
;   !   addss xmm0, xmm2
;     
; ;   ! mov rax, [p.p_a]
; ;   ! mov rdx, [p.p_b]
;   ! movss xmm0, [rax]
;   ! mulss xmm0, [rdx]
;   ! movss xmm1, [rax+4]
;   ! mulss xmm1, [rdx+4]
;   ! addss xmm0, xmm1
;   ! movss xmm2, [rax+8]
;   ! mulss xmm2, [rdx+8]
;   ! addss xmm0, xmm2
;   
; 
;   ! normal_dot:
  
  Define v.l

  ! mov [p.v_v], r12
  
  Debug "Normal Mask "+Str(v)
  ProcedureReturn #True
;   ; test If the box intersects the plane of the triangle
;   ; compute plane equation of triangle: normal*x+d=0
;   Protected normal.v3f32 
;   Vector3::Cross(normal, e0, e1)
;   
;   Define.v3f32 vmin,vmax
;   Define.f v
;   v = v0\x
;   If normal\x > 0.0 :  
;   vmin\x = -*boxhalfsize\x - v 
;   vmax\x = *boxhalfsize\x - v 
; Else 
;   vmin\x = *boxhalfsize\x -v 
;   vmax\x = -*boxhalfsize\x - v 
; EndIf
;   v = v0\y
;   If normal\y > 0.0 
;   vmin\y = -*boxhalfsize\y - v 
;   vmax\y = *boxhalfsize\y - v 
; Else
;   vmin\y = *boxhalfsize\y -v
;   vmax\y = -*boxhalfsize\y - v 
; EndIf
;   v = v0\z
;   If normal\z > 0.0 :  vmin\z = -*boxhalfsize\z - v : vmax\z = *boxhalfsize\z - v : Else : vmin\z = *boxhalfsize\z -v : vmax\z = -*boxhalfsize\z - v : EndIf
;   
;   If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
;   If Vector3::Dot(normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
;   ProcedureReturn #True
;   
  ! no_intersection:
  ProcedureReturn #False
EndProcedure


Define a.v3f32, b.v3f32, c.v3f32

a\x = -1
a\y = 0.5
a\z = 0.25

b\x = -0.5
b\y = 1
b\z = 0.2

c\x = 1.6
c\y = -0.3
c\z = 0.2

Define box.v3f32, result.v3f32
box\x = 2
box\y = 2
box\z = 2


Define i
Define nb = 2000000
Define *out1 = AllocateMemory(nb)
Define *out2 = AllocateMemory(nb)

Define T.q = ElapsedMilliseconds()
For i = 0 To nb -1
  PokeB(*out1 + i, TriangleTouchBoxPB(box, a, b, c, result))
Next
Define T1.q = ElapsedMilliseconds() - T

Define hit.b
T.q = ElapsedMilliseconds()
For i = 0 To nb -1
  hit = TriangleTouchBox(box, a, b, c, result)
  PokeB(*out2 + i, hit)
  Debug StrF(result\x)+","+StrF(result\y)+","+StrF(result\z)
Next

Define T2.q = ElapsedMilliseconds() - T

MessageRequester("MIN/MAX", Str(T1)+ " vs "+Str(T2)+" : "+Str(CompareMemory(*out1, *out2, nb)))


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 156
; FirstLine = 138
; Folding = -
; EnableXP
; Constant = #USE_SSE=1
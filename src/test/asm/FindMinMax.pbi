XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"
XIncludeFile "E:/Projects/RnD/Noodle/src/core/Array.pbi"

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

Procedure.i  NumHits(*mem, nb.i)
  Protected n = 0
  
  For i=0 To nb - 1
    If PeekB(*mem+i) : n + 1 :EndIf
  Next
  ProcedureReturn n
EndProcedure


Procedure.b TriangleTouchBoxPB(*box.v3f32, *a.v3f32, *b.v3f32, *c.v3f32)
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
  If(min>*box\x Or max<-*box\x) : ProcedureReturn #False : EndIf
  
 ; test in Y-direction
  FINDMINMAX(*a\y,*b\y,*c\y,min,max)
  If(min>*box\y Or max<-*box\y) : ProcedureReturn #False : EndIf
  
  ; test in Z-direction
  FINDMINMAX(*a\z,*b\z,*c\z,min,max)
  If(min>*box\z Or max<-*box\z) : ProcedureReturn #False : EndIf
  
  ; test If the box intersects the plane of the triangle
  ; compute plane equation of triangle: normal*x+d=0
  Protected normal.v3f32 
  Vector3::Cross(normal, e0, e1)
  Vector3::Echo(e0, "e0")
  Vector3::Echo(e1, "e1")
  Define.v3f32 vmin,vmax
  Define tmp.v3f32

  Define.f v
  v = *a\x
  If normal\x > 0.0 :  vmin\x = -*box\x - v : vmax\x = *box\x - v : Else : vmin\x = *box\x -v : vmax\x = -*box\x - v : EndIf
  v = *a\y
  If normal\y > 0.0 :  vmin\y = -*box\y - v : vmax\y = *box\y - v : Else : vmin\y = *box\y -v : vmax\y = -*box\y - v : EndIf
  v = *a\z
  If normal\z > 0.0 :  vmin\z = -*box\z - v : vmax\z = *box\z - v : Else : vmin\z = *box\z -v : vmax\z = -*box\z - v : EndIf
  
  Vector3::Echo(normal, "N")
  
  Vector3::Echo(vmin, "MINIMUM")
  Vector3::Echo(vmax, "MAXIMUM")
  
  Vector3::Set(tmp, Vector3::Dot(normal, vmin),0,0)
  Vector3::Echo(tmp, "DMIN")
  
  Vector3::Set(tmp, Vector3::Dot(normal, vmax),0,0)
  Vector3::Echo(tmp, "DMAX")
  
  If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
  If Vector3::Dot(normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
EndProcedure



Procedure.b TriangleTouchBox(*box.v3f32, *a.v3f32, *b.v3f32, *c.v3f32)
  ; ---------------------------------------------------------------------------------
  ; load points
  ; ---------------------------------------------------------------------------------
  ! mov rax, [p.p_a]
  ! movups xmm0, [rax]            ; move point a to xmm0
  ! movaps xmm1, xmm0             ; move point a to xmm1
  ! movaps xmm15, xmm1            ; make a copy in xmm15
  ! mov rax, [p.p_b]
  ! movups xmm2, [rax]            ; move point b to xmm2
  ! movaps xmm14, xmm2            ; make a copy in xmm14
  ! mov rax, [p.p_c]
  ! movups xmm3, [rax]            ; move point c to xmm3
  ! movaps xmm13, xmm3            ; make a copy in xmm13
  
  ; ---------------------------------------------------------------------------------
  ; load box
  ; ---------------------------------------------------------------------------------
  ! mov rcx, [p.p_box]            
  ! movups xmm12, [rcx]           ; move box half size to xmm12
  ! movaps xmm4, xmm12            ; copy to xmm4
  ! movaps xmm5, xmm12            ; copy to xmm5
  
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
  !   movaps xmm0, xmm14          ; copy p1 to xmm0
  !   movaps xmm1, xmm13          ; copy p2 to xmm1
  
  ; ---------------------------------------------------------------------------------
  ;  compute edges
  ; ---------------------------------------------------------------------------------
  !   subps xmm0, xmm15             ; compute edge0 (p1 - p0)
  !   subps xmm1, xmm14             ; compute edge1 (p2 - p1)
  
  !   movaps xmm2,xmm0              ; copy edge0 to xmm2
  !   movaps xmm3,xmm1              ; copy edge1 to xmm3
  
  ; ---------------------------------------------------------------------------------
  ; compute triangle normal
  ; ---------------------------------------------------------------------------------
  !   shufps xmm0,xmm0,00001001b    ; exchange 2 and 3 element (V1)
  !   shufps xmm1,xmm1,00010010b    ; exchange 1 and 2 element (V2)
  !   mulps  xmm0,xmm1
         
  !   shufps xmm2,xmm2,00010010b    ; exchange 1 and 2 element (V1)
  !   shufps xmm3,xmm3,00001001b    ; exchange 2 and 3 element (V2)
  !   mulps  xmm2,xmm3
        
  !   subps  xmm0,xmm2              ; xmm0 contains triangle plane normal

  ; ---------------------------------------------------------------------------------
  ; check side
  ; ---------------------------------------------------------------------------------
  !   xorps xmm6, xmm6
  !   cmpps xmm6, xmm0 , 1          ; check 0 < normal
  !   movmskps r12, xmm6
  
  !   movaps xmm4, xmm12            ; copy boxhalfsize to xmm7
  !   movaps xmm5, xmm12            ; copy boxhalfsize to xmm5 
  
  !   movups  xmm6, [r8]            ; load 1111 negate mask stored in r8
  !   mulps xmm5, xmm6              ; -x -y -z -w (-boxhalfsize)
  
  !   subps xmm4, xmm15             ; box - p0
  !   subps xmm5, xmm15             ; -box - p0
  !   movaps xmm6, xmm4             ; make a copy
  
  !   cmp r12, 8
  !   jb case_low
  !   jmp case_up
  
  ; ---------------------------------------------------------------------------------
  ; case 0-7
  ; ---------------------------------------------------------------------------------
  ! case_low:
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
  
  ; ---------------------------------------------------------------------------------
  ; case 8-15
  ; ---------------------------------------------------------------------------------
  ! case_up:
  !   cmp r12, 8
  !   je case_8
  
  !   cmp r12, 9
  !   je case_9
  
  !   cmp r12, 10
  !   je case_10
  
  !   cmp r12, 11
  !   je case_11
  
  !   cmp r12, 12
  !   je case_12
  
  !   cmp r12, 13
  !   je case_13
  
  !   cmp r12, 14
  !   je case_14
  
  !   cmp r12, 15
  !   je case_15
  
  ; ---------------------------------------------------------------------------------
  ; cases
  ; ---------------------------------------------------------------------------------
  ! case_0:
  !   blendps xmm4, xmm5, 0                    ; vmin = boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 15                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z,  -boxw-p0w
  !   jmp normal_dot
  
  ! case_1:
  !   blendps xmm4, xmm5, 1                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 14                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_2:
  !   blendps xmm4, xmm5, 2                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 13                   ; vmax =  -boxx-p0x, boxy-p0y, -boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_3:
  !   blendps xmm4, xmm5, 3                   ; vmin = -boxx-p0x, -boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 12                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  -boxw-p0w
  !   jmp normal_dot
  
  ! case_4:
  !   blendps xmm4, xmm5, 4                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 11                  ; vmax = -boxx-p0x, -boxy-p0y, boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_5:
  !   blendps xmm4, xmm5, 5                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 10                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_6:
  !   blendps xmm4, xmm5, 6                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 9                   ; vmax = -boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_7:
  !   blendps xmm4, xmm5, 7                   ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 8                   ; vmax = boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_8:
  !   blendps xmm4, xmm5, 8                   ; vmin = boxx-p0x, boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 7                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_9:
  !   blendps xmm4, xmm5, 9                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 6                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_10:
  !   blendps xmm4, xmm5, 10                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 5                   ; vmax =  -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_11:
  !   blendps xmm4, xmm5, 11                   ; vmin =-boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 4                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  boxw-p0w
  !   jmp normal_dot
  
  ! case_12:
  !   blendps xmm4, xmm5, 12                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 3                   ; vmax =  -boxx-p0x, -boxy-p0y,  boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_13:
  !   blendps xmm4, xmm5, 13                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 2                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_14:
  !   blendps xmm4, xmm5, 14                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 1                   ; vmax =  -boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_15:
  !   blendps xmm4, xmm5, 15                  ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 0                   ; vmax = boxx-p0x, boxy-p0y, boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! normal_dot:
  !   jmp normal_dot_min
  
  ; ---------------------------------------------------------------------------------
  ; normal dot vmin > 0 ?
  ; ---------------------------------------------------------------------------------
  ! normal_dot_min:
  !   movups xmm7, xmm0                       ; copy normal to xmm7
  !   mulps xmm7, xmm4                        ; compute normal dot vmin
  !   haddps xmm7, xmm7
  !   haddps xmm7, xmm7
  !   xorps xmm8, xmm8
  
  !   ucomiss xmm8, xmm7                       ; 0<=vmin
  !   jb no_intersection                      ; branch if greater
  !   jmp normal_dot_max                      ; branch if lower
  
  
  ; ---------------------------------------------------------------------------------
  ; normal dot vmax >= 0 ?
  ; ---------------------------------------------------------------------------------
  ! normal_dot_max:
  !   movups xmm7, xmm0                       ; copy normal to xmm7
  !   mulps xmm7, xmm6                        ; compute normal dot vmax
  !   haddps xmm7, xmm7
  !   haddps xmm7, xmm7                       ; dot 
  !   xorps xmm8, xmm8
  !   comiss xmm8, xmm7                      ; packed compare
  !   jbe intersection                        ; 0 < vmax
  !   jmp no_intersection                    ; branch if lower
  
  ; ---------------------------------------------------------------------------------
  ; triangle intersect box
  ; ---------------------------------------------------------------------------------
  ! intersection:
  ProcedureReturn #True
  
  ; ---------------------------------------------------------------------------------
  ; triangle does NOT intersect box
  ; ---------------------------------------------------------------------------------
  ! no_intersection:
  ProcedureReturn #False
  
EndProcedure


Define a.v3f32, b.v3f32, c.v3f32

a\x = -1
a\y = 10.5
a\z = 0.25

b\x = -0.5
b\y = 11
b\z = 0.2

c\x = 1.6
c\y = 10.3
c\z = 0.2

Define box.v3f32, result.v3f32
box\x = 10
box\y = 10
box\z = 10



Define i
Define nb = 12000000
Define *out1 = AllocateMemory(nb)
Define *out2 = AllocateMemory(nb)

Define *tris.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
CArray::SetCount(*tris, nb * 3)

Define *v.v3f32

For i=0 To nb -1
  For j=0 To 2
    *v = CArray::GetValue(*tris, i*3+j)
    Vector3::Set(*v, (Random(100)-200)*0.1,  (Random(100)-200)*0.1, (Random(100)-200)*0.1)
  Next

Next


Define T.q = ElapsedMilliseconds()
Define.v3f32 *a, *b, *c
For i = 0 To nb -1
  *a = CArray::GetValue(*tris, i*3)
  *b = CArray::GetValue(*tris, i*3+1)
  *c = CArray::GetValue(*tris, i*3+2)
  PokeB(*out1 + i, TriangleTouchBoxPB(box, *a, *b, *c))
Next
Define T1.q = ElapsedMilliseconds() - T

Define hit.b
T.q = ElapsedMilliseconds()
For i = 0 To nb -1
  *a = CArray::GetValue(*tris, i*3)
  *b = CArray::GetValue(*tris, i*3+1)
  *c = CArray::GetValue(*tris, i*3+2)
  PokeB(*out2 + i, TriangleTouchBox(box, *a, *b, *c))
  
  Debug StrF(*a\x)+","+StrF(*a\y)+","+StrF(*a\z)
Next

Define T2.q = ElapsedMilliseconds() - T
Define n1 = NumHits(*out1, nb)
Define n2 = NumHits(*out2, nb)

MessageRequester("MIN/MAX", Str(T1)+ " vs "+Str(T2)+" : "+Str(CompareMemory(*out1, *out2, nb))+Chr(10)+
                            "NUM HITS : "+Str(n1)+Chr(10)+
                            "NUM HITS : "+Str(n2)+Chr(10))


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 87
; FirstLine = 60
; Folding = -
; EnableXP
; Constant = #USE_SSE=1
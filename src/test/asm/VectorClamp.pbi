Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection
  sse_1111_value:
  Data.f 1, 1, 1, 1
  sse_0000_value:
  Data.f 0, 0, 0, 0
EndDataSection

Macro MCLAMP(x,min,max)
  If (x<min)
    x = min 
  ElseIf (x>max)
    x = max 
  EndIf
EndMacro

Procedure.f CLAMP(x.f,min.f,max.f)
  If (x<min)
    ProcedureReturn min 
  ElseIf (x>max)
    ProcedureReturn max 
  Else 
    ProcedureReturn x
  EndIf
EndProcedure

Procedure.f CLAMPSSE(x.f, min.f, max.f)
  Define result.f
  ! movss xmm0, [p.v_x]  
  ! movss xmm1, [p.v_min]
  ! movss xmm2, [p.v_max]
  ! comiss xmm0, xmm1
  ! jb clamp_sse_return_min
  ! comiss xmm0, xmm2
  ! jg clamp_sse_return_max
  ! movss [p.v_result], xmm0
  ! jmp clamp_sse_ret
  
  ! clamp_sse_return_min:
  !   movss [p.v_result], xmm1
  !   jmp clamp_sse_ret
  
  ! clamp_sse_return_max:
  !   movss [p.v_result], xmm2
  !   jmp clamp_sse_ret
  
  ! clamp_sse_ret:
  ProcedureReturn result
EndProcedure

Procedure.f CLAMPSSE2(x.f, min.f, max.f)
  
  Define result.f
  
  ! movss xmm0, [p.v_x]
  ! movss xmm1, [p.v_min]
  ! movss xmm2, [p.v_max]
  
  ! call clamp_0_to_1
  ProcedureReturn result
  
  ; clamp function (will clamp xmm1 first element betwenn 0 and 1)
  ! clamp_0_to_1:
  !   movups xmm1, [l_sse_0000_value]
  !   movups xmm2, [l_sse_1111_value]
  !   comiss xmm0, xmm1
  !   jb clamp_0_to_1_return_min
  !   comiss xmm2, xmm0
  !   jb clamp_0_to_1_return_max
  !   ret

  ! clamp_0_to_1_return_min:
  !   movss xmm0, xmm1
  !   ret
  
  ! clamp_0_to_1_return_max:
  !   movss xmm0, xmm2
  !   ret
  
EndProcedure

Procedure Vector3Clamp(*v.v3f32, min.f, max.f)
  MCLAMP(*v\x, min, max)
  MCLAMP(*v\y, min, max)
  MCLAMP(*v\z, min, max)
EndProcedure

  
Procedure Vector3ClampSSE(*v.v3f32, min.f, max.f)
  ! mov rsi, [p.p_v]                  
  ! movups xmm0, [rsi]                ; load vector
  ! movaps xmm1, xmm0                 ; make a copy
  
  ! movss xmm2, [p.v_min]
  ! movss xmm3, [p.v_max]
  ! shufps xmm2, xmm2, 00000000b
  ! shufps xmm3, xmm3, 00000000b
  
  ! movups xmm4, [l_sse_1111_value]   ; load 1111 value vec
  
  ! movaps xmm5, xmm0
  ! cmpps xmm5, xmm2, 1               ; compare mask min < v
  ! movaps xmm6, xmm4                 ; copy 1111 value vec
  ! andps xmm6, xmm5                  ; create multiplication mask
  ! mulps xmm2, xmm6                  ; multiply min by mult mask
  
  ! movaps xmm5, xmm0
  ! cmpps xmm5, xmm3, 5               ; compare mask max >= v
  ! movaps xmm7, xmm4                 ; copy 1111 value vec
  ! andps xmm7, xmm5                  ; create multiplication mask
  ! mulps xmm3, xmm7                  ; multiply max by mult mask
  
  ! addps xmm2, xmm3
  
  ! movaps xmm5, xmm4                 ; create min reverse mask
  ! subps xmm5, xmm6                  ; 1 - mask1 (revert it)
  ! mulps xmm0, xmm5
  
  ! movaps xmm5, xmm4                 ; create min reverse mask
  ! subps xmm5, xmm7                  ; 1 - mask2 (revert it)
  ! mulps xmm0, xmm5

  ! addps xmm0, xmm2
  
  ! movups [rsi], xmm0
  
EndProcedure

Define numTests = 100000000
Define i
Define x.f

Define v.v3f32

Define T1.q = ElapsedMilliseconds()
For i=0 To numTests-1
  x=i
    CLAMP(x, 12.2265, 27.66666)
;   Vector3Clamp(v, 0,1)
Next
Define E1.q = ElapsedMilliseconds() - T1

Define T2.q = ElapsedMilliseconds()
For i=0 To numTests-1
  x=i
  CLAMPSSE(x, 12.2265, 27.66666)
;   Vector3ClampSSE(v, 0,1)
Next
Define E2.q = ElapsedMilliseconds() - T2

Define T3.q = ElapsedMilliseconds()
For i=0 To numTests-1
  x=i
  CLAMPSSE2(x, 12.2265, 27.66666)
;   Vector3ClampSSE(v, 0,1)
Next
Define E3.q = ElapsedMilliseconds() - T3

MessageRequester("CLAMP", "BASIC : "+StrD(E1)+" vs SSE : "+StrD(E2)+" vs SSE : "+StrD(E3))

; Define v.v3f32
; v\x = 12
; v\y = 1
; v\z = 21
; 
; Vector3_Clamp(v,2,11)
; Debug v\x
; Debug v\y
; Debug v\z
; Debug v\w
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 70
; FirstLine = 33
; Folding = --
; EnableXP
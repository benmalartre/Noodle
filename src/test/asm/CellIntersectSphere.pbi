XIncludeFile "../../core/Time.pbi"

Time::Init()

Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection 
  sse_zero_vec:
  Data.f 0, 0, 0, 0
EndDataSection

Procedure.b IntersectSphereSSE(*bmin.v3f32, *bmax.v3f32, *center.v3f32, radius.f)

  ! mov rsi, [p.p_center]             ; load sphere center in cpu
  ! movups xmm0, [rsi]
  ! mov rsi, [p.p_bmin]               ; load box min in cpu
  ! movups xmm1, [rsi]
  ! mov rsi, [p.p_bmax]               ; load box max in cpu
  ! movups xmm2, [rsi]
  ! movss xmm3, [p.v_radius]          ; load radius in cpu
  ! mulps xmm3, xmm3                  ; square radius : r2
  
  ! movaps xmm4, xmm0                 ; copy center in xmm4
  ! subps xmm4, xmm1                  ; center - box min

  ! movaps xmm5, xmm0                 ; copy center in xmm5
  ! subps xmm5, xmm2                  ; center - box max
  
  ! mulps xmm4, xmm4                  ; square center - box min
  ! mulps xmm5, xmm5                  ; square center - box max
 
  ! movaps xmm6, xmm0                 ; copy sphere center in xmm6
  ! cmpps xmm6, xmm1, 1               ; compare center < box min
 
  ! movaps xmm7, xmm0                 ; copy sphere center in xmm7
  ! cmpps xmm7, xmm2, 6               ; compare center > box max
  
  ! andps xmm4, xmm6                  ; reset according to comparison mask
  ! andps xmm5, xmm7                  ; reset according to comparison mask
  
  ! movups xmm8, [l_sse_zero_vec]
  ! blendps xmm4, xmm8, 1000b         ; reset fourth bit
  ! blendps xmm5, xmm8, 1000b         ; reset fourth bit
  
  ! addps xmm4, xmm5                  ; add together
  ! haddps xmm4, xmm4                 ; horizontal add first pass
  ! haddps xmm4, xmm4                 ; horizontal add second pass
  
  ! comiss xmm4, xmm3                 ; compare dmin <= r2
  ! jbe cell_intersection
  ! jmp no_cell_intersection
  
  ! cell_intersection:
  ProcedureReturn #True
  
  ! no_cell_intersection:
  ProcedureReturn #False

EndProcedure

Procedure.b IntersectSphere(*bmin.v3f32, *bmax.v3f32, *center.v3f32, radius.f)
  Define r2.f = radius * radius
  Define dmin.f = 0
  If *center\x < *bmin\x : dmin + Pow(*center\x-*bmin\x, 2)
  ElseIf *center\x > *bmax\x : dmin + Pow(*center\x-*bmax\x, 2)
  EndIf
  
  If *center\y < *bmin\y : dmin + Pow(*center\y-*bmin\y, 2)
  ElseIf *center\y > *bmax\y : dmin + Pow(*center\y-*bmax\y, 2)
  EndIf
  
  If *center\z < *bmin\z : dmin + Pow(*center\z-*bmin\z, 2)
  ElseIf *center\z > *bmax\z : dmin + Pow(*center\z-*bmax\z, 2)
  EndIf
  ProcedureReturn Bool(dmin <= r2)
    
EndProcedure

Define bmin.v3f32, bmax.v3f32
bmin\x = -1.33
bmin\y = -1
bmin\z = -1.75

bmax\x = 1.333
bmax\y = 1.26
bmax\z = 1.75

Define numTests = 1000000

Define T1.d = Time::Get()
RandomSeed(666)
Define i
Define center.v3f32
Dim hits1.b(numTests)
Define numHits1.i = 0
For i=0 To numTests-1
  center\x = Random(50) - 25
  center\y = Random(50) - 25
  center\z = Random(50) - 25
  hits1(i) = IntersectSphere(bmin, bmax, center, 1)
  If hits1(i) : numHits1 + 1 : EndIf
Next
Define E1.d = Time::Get() - T1

Define T2.d = Time::Get()
RandomSeed(666)
Dim hits2.b(numTests)
Define numHits2.i = 0
For i=0 To numTests-1
  center\x = Random(50) - 25
  center\y = Random(50) - 25
  center\z = Random(50) - 25
  hits2(i) = IntersectSphereSSE(bmin, bmax, center, 1)
  If hits2(i) : numHits2 + 1 : EndIf
Next
Define E2.d = Time::Get() - T2

MessageRequester("INTERSECT SPHERE", "NUM TESTS : "+Str(numTests)+Chr(10)+
                                     "TIME : "+StrD(E1)+" vs "+StrD(E2)+Chr(10)+
                                     "EQUAL : "+CompareMemory(@hits1(0), @hits2(0), numTests)+Chr(10)+
                                     "NUM HITS : "+Str(numHits1)+" vs "+Str(numHits2))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 112
; FirstLine = 68
; Folding = -
; EnableXP
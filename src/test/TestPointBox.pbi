XIncludeFile "../core/Application.pbi"

Procedure.b ContainsPointSSE(*Me.Geometry::Box_t,*p.Math::v3f32)
  ! mov rsi, [p.p_Me]
  ! mov rdi, [p.p_p]
  ! movups xmm0, [rsi]              ; load box origin in xmm0
  ! movaps xmm1, xmm0               ; make a copy in xmm1
  ! movups xmm2, [rsi + 16]         ; load box extend in xmm2
  ! movups xmm3, [rdi]              ; load pnt in xmm3
  ! movaps xmm4, xmm3               ; make a copy in xmm4
  ! subps xmm0, xmm2                ; compute box min
  ! addps xmm1, xmm2                ; compute box max
  
  ! cmpps xmm3, xmm0, 5             ; compare p >= bmin
  ! cmpps xmm4, xmm1, 2             ; compare p <= bmax
  
  ! movmskps r8, xmm3               ; move comparison mask to r8 register
  ! movmskps r9, xmm4               ; move comparison mask to r9 register

  ! add r8, r9                      ; if all the comparison test succeeded
  ! cmp r8, 30                      ; we should have 30 in r8
  ! je contains_point_sse           ; point in box  
  ! jmp not_contains_point_sse      ; point outside of box
  
  ! contains_point_sse:             ; point in box  
  ProcedureReturn #True
  
  ! not_contains_point_sse:         ; point outside of box
  ProcedureReturn #False
EndProcedure

Procedure.b ContainsPointPB(*Me.Geometry::Box_t,*p.Math::v3f32)
  ProcedureReturn Bool(*p\x>=*Me\origin\x-*Me\extend\x And *p\x <= *Me\origin\x+*Me\extend\x And
                       *p\y>=*Me\origin\y-*Me\extend\y And *p\y <= *Me\origin\y+*Me\extend\y And
                       *p\z>=*Me\origin\z-*Me\extend\z And *p\z <= *Me\origin\z+*Me\extend\z)
EndProcedure
    
Procedure NumHits(mem, nb)
  Define i, cnt=0
  For i=0 To nb-1
    cnt + PeekB(mem+i)
  Next

  ProcedureReturn cnt
EndProcedure


Time::Init()

Define numTests = 1024
Define i
Define box.Geometry::Box_t
Define *pnt.Math::v3f32
Define *pnts = AllocateMemory(numTests * SizeOf(Math::v3f32))

RandomSeed(666)
Vector3::Set(box\origin, 0,0.5,0)
Vector3::Set(box\extend, 0.5,0.5,0.5)

For i=0 To numTests - 1
  *pnt = *pnts + i * SizeOf(Math::v3f32)
  Vector3::Set(*pnt, Math::Random_Neg1_1(), Math::Random_Neg1_1(), Math::Random_Neg1_1())
Next

Define mem1 = AllocateMemory(numTests)
Define mem2 = AllocateMemory(numTests)
Define numHits1 = 0
Define numHits2 = 0
Define S1.d = Time::Get()
For i=0 To numTests - 1
  If ContainsPointPB(box, *pnts + i * SizeOf(Math::v3f32))
    PokeB(mem1 + i, #True)
    numHits1 + 1
  EndIf
  
Next
Define E1.d = Time::Get() - S1
Define S2.d = Time::Get()

For i=0 To numTests - 1
  If ContainsPointSSE(box, *pnts + i * SizeOf(Math::v3f32))
    PokeB(mem2 + i, #True)
    numHits2 + 1
  EndIf
  
Next
Define E2.d = Time::Get() - S2

Define cmp.b = #True
For i=0 To numTests - 1
  If PeekB(mem1 + i ) <> PeekB(mem2 + i )
    cmp = #False
    Break
  EndIf
Next

MessageRequester("POINT IN BOX: "+Str(numTests), "TIME : "+StrD(E1)+" vs "+StrD(E2)+Chr(10)+
                                                 "HITS : "+Str(numHits1)+" vs "+Str(numHits2)+Chr(10)+
                                                 "CMP : "+CompareMemory(mem1, mem2, numTests))

; Define mem1 = AllocateMemory(numTests)
; Define mem2 = AllocateMemory(numTests)
;   
; Define S1.d = Time::Get()
; For i=0 To numTests - 1
;   PokeB(mem1+i, IntersectBoxPB(box, boxes(i)))
; Next
; Define E1.d = Time::Get() - S1
; 
; Define S2.d = Time::Get()
; For i=0 To numTests - 1
;   PokeB(mem2+i, IntersectBoxSSE(box, boxes(i)))
; Next
; Define E2.d = Time::Get() - S2
; 
; Define numHits1 = NumHits(mem1, numTests)
; Define numHits2 = NumHits(mem2, numTests)


; MessageRequester("BOX", StrD(E1)+" vs "+StrD(E2)+" : "+CompareMemory(mem1, mem2, numTests )+"("+Str(numHits1)+","+Str(numHits2)+")")
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 49
; Folding = -
; EnableXP
XIncludeFile "../core/Application.pbi"

Procedure.f SquareDistanceSSE(*Me.Geometry::Box_t, *p.Math::v3f32)
  Define result.f
  ! mov rsi, [p.p_Me]
  ! xorps xmm0, xmm0
  ! xorps xmm1, xmm1
  ! xorps xmm2, xmm2
  
  ! movups xmm0, [rsi]              ; load box origin in xmm0
  ! movups xmm1, [rsi + 16]         ; load box extend in xmm1
  ! mov rsi, [p.p_p]
  ! movups xmm2, [rsi]              ; load pnt in xmm2
  
  ! movaps xmm3, xmm0               ; copy box origin in xmm3
  ! subps xmm3, xmm1                ; compute box min
  ! movaps xmm4, xmm0               ; copy box origin in xmm4
  ! addps xmm4, xmm1                ; compute box max
  
  ! movaps xmm5, xmm3               ; make a copy of bmin in xmm5
  ! subps xmm5, xmm2                ; bmin - pnt
  ! mulps xmm5, xmm5                ; square it
  
  ! movaps xmm6, xmm2               ; make a copy of pnt in xmm6
  ! subps xmm6, xmm4                ; pnt - bmax
  ! mulps xmm6, xmm6                ; square it
  
  ! movaps xmm7, xmm2               ; make a copy of pnt in xmm7
  ! cmpps xmm2, xmm3, 1             ; get pnt < bmin comparison mask (mask1)
  ! cmpps xmm7, xmm4, 6             ; get pnt > bmax comparison mask (mask2)   
  
  ! andps xmm5, xmm2                ; packed and with mask1
  ! andps xmm6, xmm7                ; packed and with mask2
  
  ! addps xmm5, xmm6                ; add masked values
  ! movaps xmm1, xmm5               ; copy in xmm1
  ! shufps xmm1, xmm1, 11101110b    ; shuffle component for horizontal add
  ! addps xmm1, xmm5                ; add shuffled components
  ! movaps xmm2, xmm1               ; copy in xmm2
  ! shufps xmm2, xmm2, 01010101b    ; shuffle component for horizontal add
  ! addps  xmm1, xmm2               ; add shuffled components  

  ! movss [p.v_result], xmm1        ; move first value back to memory
  ProcedureReturn result
EndProcedure

Macro SquareDistance1D(_v, _bmin, _bmax)
  If (_v) < (_bmin) : result + Pow((_bmin) - (_v), 2) : EndIf          
  If (_v) > (_bmax) : result + Pow((_v) - (_bmax), 2) : EndIf
EndMacro
  
Procedure.f SquareDistancePB(*Me.Geometry::Box_t, *p.Math::v3f32)   
  ; Squared distance
  Protected result.f = 0.0
  
  SquareDistance1D( *p\x, *Me\origin\x-*Me\extend\x, *Me\origin\x+*Me\extend\x)
  SquareDistance1D( *p\y, *Me\origin\y-*Me\extend\y, *Me\origin\y+*Me\extend\y)
  SquareDistance1D( *p\z, *Me\origin\z-*Me\extend\z, *Me\origin\z+*Me\extend\z)
  ProcedureReturn result
EndProcedure

Procedure NumHits(mem, nb)
  Define i, cnt=0
  For i=0 To nb-1
    cnt + PeekB(mem+i)
  Next

  ProcedureReturn cnt
EndProcedure

Procedure.f MaxError(mem1, mem2, nb)
  Define maxError.f
  Define error.f
  Define i
  For i=0 To nb-1
    error = Abs(PeekF(mem1 + i * 4) - PeekF(mem2 + i * 4))
    If error > maxError
      maxError = error
    EndIf
  Next
  ProcedureReturn MaxError
EndProcedure



Time::Init()

Define numTests = 12800000
Define i
Define box.Geometry::Box_t
Define *pnt.Math::v3f32
Define *pnts = AllocateMemory(numTests * SizeOf(Math::v3f32))

Dim boxes.Geometry::Box_t(numTests)
RandomSeed(666)
Vector3::Set(box\origin, 0,0,0)
Vector3::Set(box\extend, 1,1,1)

For i=0 To numTests - 1
  Vector3::Set(boxes(i)\origin,Math::Random_Neg1_1()*4, Math::Random_Neg1_1()*4, Math::Random_Neg1_1()*4)
  Vector3::Set(boxes(i)\extend, 0.5,0.5,0.5)
  *pnt = *pnts + i * SizeOf(Math::v3f32)
  Vector3::Set(*pnt, Math::Random_Neg1_1(), Math::Random_Neg1_1(), Math::Random_Neg1_1())
Next

Define mem1 = AllocateMemory(numTests * 4)
Define mem2 = AllocateMemory(numTests * 4)

Define S1.d = Time::Get()
Define distance.f
For i=0 To numTests - 1
  *pnt = *pnts + i * SizeOf(Math::v3f32)
  distance = SquareDistancePB(boxes(i), *pnt)
  PokeF(mem1 + i * 4, distance)
Next
Define E1.d = Time::Get() - S1
Define S2.d = Time::Get()
RandomSeed(666)
Debug "--------------"
For i=0 To numTests - 1
  *pnt = *pnts + i * SizeOf(Math::v3f32)
  distance = SquareDistanceSSE(boxes(i), *pnt)
  PokeF(mem2 + i * 4, distance)
Next
Define E2.d = Time::Get() - S2

Define cmp.b = #True
For i=0 To numTests - 1
  If Abs(PeekF(mem1 + i * 4) - PeekF(mem2 + i * 4)) > 0.01
    cmp = #False
    Break
  EndIf
Next

MessageRequester("SQUARED DISTANCE : "+Str(numTests), StrD(E1)+" vs "+StrD(E2)+" : "+Str(cmp)+" MAX ERROR : "+StrD(MaxError(mem1, mem2, numTests))); )+"("+Str(numHits1)+","+Str(numHits2)+")")

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
; CursorPosition = 32
; FirstLine = 9
; Folding = -
; EnableXP
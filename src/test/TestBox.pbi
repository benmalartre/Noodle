
XIncludeFile "../core/Application.pbi"


Procedure.b IntersectBoxPB(*Me.Geometry::Box_t,*other.Geometry::Box_t)
  If *Me\origin\x + *Me\extend\x < *other\origin\x - *other\extend\x :ProcedureReturn #False : EndIf
  If *Me\origin\y + *Me\extend\y < *other\origin\y - *other\extend\y :ProcedureReturn #False : EndIf
  If *Me\origin\z + *Me\extend\z < *other\origin\z - *other\extend\z :ProcedureReturn #False : EndIf
  If *Me\origin\x - *Me\extend\x > *other\origin\x + *other\extend\x :ProcedureReturn #False : EndIf
  If *Me\origin\y - *Me\extend\y > *other\origin\y + *other\extend\y :ProcedureReturn #False : EndIf
  If *Me\origin\z - *Me\extend\z > *other\origin\z + *other\extend\z :ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure


Procedure.b IntersectBoxSSE(*Me.Geometry::Box_t,*other.Geometry::Box_t)
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    ! mov rsi, [p.p_Me]
    ! movups xmm0, [rsi]              ; load box origin in xmm0
    ! movaps xmm1, xmm0               ; make a copy in xmm1
    ! movups xmm2, [rsi+16]           ; load box extend in xmm4
    
    ! mov rsi, [p.p_other]
    ! movups xmm3, [rsi]              ; load other origin in xmm2
    ! movaps xmm4, xmm3               ; make a copy in xmm3
    ! movups xmm5, [rsi+16]           ; load other extend in xmm5
    
    ! subps xmm0, xmm2                ; box origin - box extend (box min)
    ! addps xmm1, xmm2                ; box origin + box extend (box max)
    
    ! subps xmm3, xmm5                ; other origin - other extend (other min)
    ! addps xmm4, xmm5                ; other origin + other extend (other max)
    
    ! cmpps xmm1, xmm3, 1             ; compare box max < other min
    ! movmskps r9, xmm1               ; if any of these test if true
    ! cmp r9, 0                       ; there is no intersection
    ! jne no_box_box_intersection
      
    ! cmpps xmm4, xmm0, 1             ; compare  other max < box min
    ! movmskps r9, xmm4               ; if any of these test if true
    ! cmp r9, 0                       ; there is no intersection
    ! jne no_box_box_intersection
    
    ! box_box_intersection:
    ProcedureReturn #True
    
    ! no_box_box_intersection:
    ProcedureReturn #False
  CompilerElse
    ProcedureReturn #False
  CompilerEndIf
  
EndProcedure


Procedure NumHits(mem, nb)
  Define i, cnt=0
  For i=0 To nb-1
    cnt + PeekB(mem+i)
  Next
  ProcedureReturn cnt
EndProcedure


Time::Init()

Define numTests = 1000000
Define i
Define box.Geometry::Box_t
Dim boxes.Geometry::Box_t(numTests)

Vector3::Set(box\origin, 0,0,0)
Vector3::Set(box\extend, 1,1,1)

For i=0 To numTests - 1
  Vector3::Set(boxes(i)\origin,Math::Random_Neg1_1()*4, Math::Random_Neg1_1()*4, Math::Random_Neg1_1()*4)
  Vector3::Set(boxes(i)\extend, 0.5,0.5,0.5)
Next

Define mem1 = AllocateMemory(numTests)
Define mem2 = AllocateMemory(numTests)
  
Define S1.d = Time::Get()
For i=0 To numTests - 1
  PokeB(mem1+i, IntersectBoxPB(box, boxes(i)))
Next
Define E1.d = Time::Get() - S1

Define S2.d = Time::Get()
For i=0 To numTests - 1
  PokeB(mem2+i, IntersectBoxSSE(box, boxes(i)))
Next
Define E2.d = Time::Get() - S2

Define numHits1 = NumHits(mem1, numTests)
Define numHits2 = NumHits(mem2, numTests)


MessageRequester("BOX", StrD(E1)+" vs "+StrD(E2)+" : "+CompareMemory(mem1, mem2, numTests )+"("+Str(numHits1)+","+Str(numHits2)+")")
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 16
; FirstLine = 12
; Folding = -
; EnableXP
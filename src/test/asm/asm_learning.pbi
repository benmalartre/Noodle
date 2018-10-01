
XIncludeFile "E:\Projects\RnD\Noodle\src\core\Time.pbi"

Structure Vector3f
  x.f
  y.f
  z.f
EndStructure

Procedure PBLoop(nbp.i, *points, *avg.Vector3f)
  Define i
  Define x.f
  Define *point.Vector3f
  *avg\x = 0
  *avg\y = 0
  *avg\z = 0
  For i=0 To nbp-1
    *point = *points + i * 12
    *avg\x + *point\x
    *avg\y + *point\y
    *avg\z + *point\z
  Next
;   *avg\x / nbp
;   *avg\y / nbp
;   *avg\z / nbp
EndProcedure

Procedure.f AsmLoop(nbp.i, *points, *avg.Vector3f) 
  *avg\x = 0
  *avg\y = 0
  *avg\z = 0

  !MOVSS xmm0, [p.p_avg]
;   !MOVSS xmm1, [p.p_avg+4]
;   !MOVSS xmm3, [p.p_avg+8]
  
  !MOV ecx, [p.v_nbp]
  !MOV eax, 0
  !MOV edx, [p.p_points]
  !FORLOOP:
  !ADDSS xmm0, [edx]
;   !ADDSS xmm1, [edx]
;   !ADDSS xmm3, [edx]
;   !ADD eax, 12
  !DEC ecx
  !JNZ FORLOOP
  !MOVSS [p.p_avg], xmm0
;   !MOVSS [p.p_avg+4], xmm1
;   !MOVSS [p.p_avg+8], xmm3
  
;   *avg\x / nbp
;   *avg\y / nbp
;   *avg\z / nbp
;   ProcedureReturn x
EndProcedure

Procedure ASMTest()
  !MOV %1, %%rax
  "MOV %2, %%rdx \n"

  "MOVUPS (%%rax), %%xmm0 \n"
  "MOVUPS (%%rdx), %%xmm1 \n"
  "ADDPS %%xmm0, %%xmm1 \n"

  "MOVUPS %%xmm1, %0 \n"

  :"=g"(vec[i])       //wyjscie
  :"g"(v1[i]), "g"(v2[i]) //wejscie
  :"%rax", "%rdx"
EndProcedure
          

nbp = 12
*points = AllocateMemory(SizeOf(Vector3f) * nbp)
*p.Vector3f
For i=0 To nbp-1
  *p = *points + i * SizeOf(Vector3f)
  *p\x = Random(1024)
  *p\y = Random(1024)
  *p\z = Random(1024)
Next

avg.Vector3f
Time::Init()
OpenConsole()
T.d = Time::Get()
PBLoop(nbp, *points, @avg)
PBT.d = Time::get() - T

PrintN("PB ---> "+StrD(PBT))
PrintN(StrF(avg\x)+","+StrF(avg\y)+","+StrF(avg\z))

T.d = Time::get()
resultASM.f = AsmLoop(nbp, *points, @avg)
ASMT.d = Time::get() - T

PrintN("ASM ---> "+StrD(ASMT))
PrintN(StrF(avg\x)+","+StrF(avg\y)+","+StrF(avg\z))

Input()
CloseConsole()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 34
; FirstLine = 17
; Folding = -
; EnableXP
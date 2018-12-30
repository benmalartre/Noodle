XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../core/Time.pbi"
XIncludeFile "../../objects/Geometry.pbi"
XIncludeFile "../../objects/Triangle.pbi"

UseModule Math
; UseModule Geometry

Time::Init()


; Define numTris = 4
Define numTris = 10000000

Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
CArray::SetCount(*positions, numTris * 3)
Define *indices.CArray::CArrayLong = CArray::newCArrayLong()
CArray::SetCount(*indices, numTris*3)
Define *elements.CArray::CArrayLong = CArray::newCArrayLong()
CArray::SetCount(*elements, numTris)

Define *hits = AllocateMemory(numTris)
Global box.Geometry::Box_t

Vector3::Set(box\origin, 0,0,0)
Vector3::Set(box\extend,2,2,2)

; ax bx az bz

RandomSeed(2)
Define i
Define *p.v3f32

; CopyMemory(?problematic_tris, *positions, 12 * SizeOf(v3f32))
; For i=0 To numTris - 1
;   PokeL(*indices + (i*3+0)*4, i*3+0)
;   PokeL(*indices + (i*3+1)*4, i*3+1)
;   PokeL(*indices + (i*3+2)*4, i*3+2)
; Next

For i=0 To numTris - 1
  *p = *positions\data + (i*3)*SizeOf(v3f32)
  Vector3::Set(*p, Random(50)-25, Random(50)-25, Random(50)-25)
  PokeL(*indices\data + (i*3)*4, i*3)
  
  *p = *positions\data + (i*3+1)*SizeOf(v3f32)
  Vector3::Set(*p, Random(50)-25, Random(50)-25, Random(50)-25)
;   Vector3::Set(*p, 0.1, 1, 0.1)
  PokeL(*indices\data + (i*3+1)*4, i*3+1)
  
  *p = *positions\data + (i*3+2)*SizeOf(v3f32)
  Vector3::Set(*p, Random(50)-25, Random(50)-25, Random(50)-25)
;   Vector3::Set(*p, 0.55, 0,-0.66)
  PokeL(*indices\data + (i*3+2)*4, i*3+2)
  CArray::SetValueL(*elements, i, i)
Next

Procedure Divergence(*A, *B, nb)
  Define diverge.i = 0
  Define i
 
  For i = 0 To nb - 1
    If PeekB(*A+i) <> PeekB(*B+i)
      diverge + 1
    EndIf
  Next
  ProcedureReturn diverge
EndProcedure

Procedure.i Problematic(*X, *Y, nb, *positions)
  Define *a.Math::v3f32, *b.Math::v3f32, *c.Math::v3f32
  Define pblm.i = 0
  Define output.v3f32
  For i = 0 To nb - 1
    If PeekB(*X+i) <> PeekB(*Y+i)
      *a = *positions + (i*3) * SizeOf(Math::v3f32)
      *b = *positions + (i*3+1) * SizeOf(Math::v3f32)
      *c = *positions + (i*3+2) * SizeOf(Math::v3f32)
      pblm + 1
    EndIf
    
  Next
  ProcedureReturn pblm
EndProcedure


Define output1.v3f32
Define output2.v3f32

Define.v3f32 *a, *b, *c
Define pbs.s, asms.s
Dim touch1.b(numTris)
Dim touch2.b(numTris)
Define hits1 = 0
Define hits2 = 0
Define hits3 = 0

Define msg1.s
Define.v3f32 tmp1, tmp2
Define T.d = Time::get()
For i=0 To numTris - 1
  *a = CArray::GetValue(*positions, i*3)
  *b = CArray::GetValue(*positions, i*3+1)
  *c = CArray::GetValue(*positions, i*3+2)

 If Triangle::Touch(box, *a, *b, *c): hits1 + 1 : EndIf
  
; ;   pbs + Str(PeekB(*touch1+i))+" : "+StrF(output1\x,3)+","+StrF(output1\y,3)+","+StrF(output1\z,3)+","+StrF(output1\_unused,3)+Chr(10)
Next
Define T1.d = Time::Get() - T
; Define msg2.s
; T = Time::Get()
; For i=0 To numTris - 1
;   *a = *positions + (i*3)*SizeOf(v3f32)
;   *b = *positions + (i*3+1)*SizeOf(v3f32)
;   *c = *positions + (i*3+2)*SizeOf(v3f32)
;   touch2(i) = Triangle::TouchSSE(box, *a, *b, *c)
;   If touch2(i) : hits2 + 1 : EndIf
; ;   asms + Str(PeekB(*touch2+i))+ " : "+StrF(output2\x,3)+","+StrF(output2\y,3)+","+StrF(output2\z,3)+","+StrF(output2\_unused,3)+Chr(10)
; Next
; Define T2.d = Time::Get() - t

T = Time::Get()
hits2 = Triangle::TouchArray(*positions\data, *indices\data, *elements\data, numTris, box, *hits)
Define T3.d = Time::Get() - T

For i=0 To numTris - 1
  hits3 + PeekB(*hits+i)
Next

Define msg.s = "EQUAL : "+Str(CompareMemory(@touch1(0), @touch2(0), numTris))+Chr(10)
msg + "HITS 1 : "+Str(hits1)+", HITS 2 : "+Str(hits2)+", HITS 3 : "+Str(hits3)+Chr(10)
msg+ StrD(T1)+" vs "+StrD(T2)+" vs "+StrD(T3)+Chr(10)
msg + "PROBLEMATICS : "+Str(Problematic(@touch1(0), @touch2(0), numTris, *positions\data))+Chr(10)
msg + "USE SSE : "+Str(#USE_SSE)


MessageRequester("Touch",msg)
; Debug pbs
; Debug "-----------------------------------------------------"
; Debug asms
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 3
; Folding = -
; EnableXP
; DisableDebugger
; Constant = #USE_SSE=1
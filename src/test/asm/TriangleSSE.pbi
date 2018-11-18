XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"
XIncludeFile "E:/Projects/RnD/Noodle/src/core/Time.pbi"
XIncludeFile "E:/Projects/RnD/Noodle/src/objects/Geometry.pbi"
XIncludeFile "E:/Projects/RnD/Noodle/src/objects/Triangle.pbi"

UseModule Math
; UseModule Geometry

Time::Init()


; Define numTris = 4
Define numTris = 12800000

Define *positions = AllocateMemory(numTris * 3 * SizeOf(v3f32))
Define *indices = AllocateMemory(numTris * 12)
Define *hits = AllocateMemory(numTris)
Global box.Geometry::Box_t

Vector3::Set(box\origin, 0,0,0)
Vector3::Set(box\extend,0.5,0.5,0.5)

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
  *p = *positions + (i*3)*SizeOf(v3f32)
  Vector3::Set(*p, -0.55, 0, 0.66)
  Vector3::Set(*p, Random(50)-100, Random(50)-100, Random(50)-100)
  Vector3::ScaleInPlace(*p, 0.01)
  PokeL(*indices + (i*3)*4, i*3)
  
  *p = *positions + (i*3+1)*SizeOf(v3f32)
  Vector3::Set(*p, Random(50)-100, Random(50)-100, Random(50)-100)
  Vector3::ScaleInPlace(*p, 0.01)
;   Vector3::Set(*p, 0.1, 1, 0.1)
  PokeL(*indices + (i*3+1)*4, i*3+1)
  
  *p = *positions + (i*3+2)*SizeOf(v3f32)
  Vector3::Set(*p, Random(50)-100, Random(50)-100, Random(50)-100)
  Vector3::ScaleInPlace(*p, 0.01)
;   Vector3::Set(*p, 0.55, 0,-0.66)
  PokeL(*indices + (i*3+2)*4, i*3+2)
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
Define T.d = Time::get()
Define msg1.s
For i=0 To numTris - 1
  *a = *positions + (i*3)*SizeOf(v3f32)
  *b = *positions + (i*3+1)*SizeOf(v3f32)
  *c = *positions + (i*3+2)*SizeOf(v3f32)
  touch1(i) = Triangle::Touch(box, *a, *b, *c)
  If touch1(i) : hits1 + 1 : EndIf
  
;   pbs + Str(PeekB(*touch1+i))+" : "+StrF(output1\x,3)+","+StrF(output1\y,3)+","+StrF(output1\z,3)+","+StrF(output1\_unused,3)+Chr(10)
Next
Define T1.d = Time::Get() - t
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
Triangle::TouchArray(*positions, *indices, numTris, box, *hits)
Define T3.d = Time::Get() - t

For i=0 To numTris - 1
  hits3 + PeekB(*hits+i)
Next

Define msg.s = "EQUAL : "+Str(CompareMemory(@touch1(0), @touch2(0), numTris))+Chr(10)
msg + "HITS 1 : "+Str(hits1)+", HITS 2 : "+Str(hits2)+", HITS 3 : "+Str(hits3)+Chr(10)
msg+ StrD(T1)+" vs "+StrD(T2)+" vs "+StrD(T3)+Chr(10)
msg + "PROBLEMATICS : "+Str(Problematic(@touch1(0), @touch2(0), numTris, *positions))

MessageRequester("Touch",msg)
; Debug pbs
; Debug "-----------------------------------------------------"
; Debug asms

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 106
; FirstLine = 78
; Folding = -
; EnableXP
; DisableDebugger
; Constant = #USE_SSE=1
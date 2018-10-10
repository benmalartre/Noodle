#USE_SSE = #True
XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"

UseModule Math

Procedure.s Vector3ArrayString(*A, nb)
  Protected *v.v3f32
  Protected s.s
  If nb > 12
    For i=0 To 5
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
    For i=nb-7 To nb-1
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
  Else
    For i=0 To nb-1
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
  EndIf
    
  ProcedureReturn s
EndProcedure

Procedure CompareVector3Array(*A1, *A2, nb)
  Protected *v1.v3f32, *v2.v3f32
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(v3f32)
    *v2 = *A2 + i * SizeOf(v3f32)
    If Abs(*v1\x - *v2\x) > 0.001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\y- *v2\y) > 0.001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\z - *v2\z) > 0.001
      ProcedureReturn #False
    EndIf
  Next
  
  ProcedureReturn #True
EndProcedure


Macro LinearInterpolate(_v,_a,_b,_blend)
  _v\x = (1-_blend) * _a\x + _blend * _b\x
  _v\y = (1-_blend) * _a\y + _blend * _b\y
  _v\z = (1-_blend) * _a\z + _blend * _b\z
EndMacro

Macro LinearInterpolateInPlace(_v,_o,_blend)
  _v\x = (1-_blend) * _v\x + _blend * _o\x
  _v\y = (1-_blend) * _v\y + _blend * _o\y
  _v\z = (1-_blend) * _v\z + _blend * _o\z
EndMacro

Define a.v3f32, b.v3f32, c.v3f32
a\x = -10
a\y = -10
a\z = -10

b\x = 10
b\y = 10
b\z = 10

Define nb = 320000000
Define *A = AllocateMemory(nb * SizeOf(v3f32))
Define *B = AllocateMemory(nb * SizeOf(v3f32))

Define T.q = ElapsedMilliseconds()
Define z.f = 1.0/nb
Define blend.f
Define *v.v3f32
For x=0 To nb
  *v= *A + x*SizeOf(v3f32)
  Vector3::LinearInterpolate(*v, a, b, x * z)
Next
Define T1.q = ElapsedMilliseconds() - T


Define T.q = ElapsedMilliseconds()
Define z.f = 1.0/nb
For x=0 To nb
  *v= *B + x*SizeOf(v3f32)
  LinearInterpolate(*v, a, b, x * z)
Next
Define T2.q = ElapsedMilliseconds() - T

MessageRequester("Linear Interpolate", Str(T1)+" vs "+Str(T2)+ " = "+Str(CompareVector3Array(*A, *B, nb)))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 68
; FirstLine = 33
; Folding = -
; EnableXP
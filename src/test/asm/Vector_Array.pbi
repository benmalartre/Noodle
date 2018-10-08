Structure Vector3f
  x.f
  y.f
  z.f
EndStructure

Procedure Vector3_Array_Allocate(numPoints.i)
  Protected sv.i =  SizeOf(Vector3f)
  Protected *p = AllocateMemory(numPoints * sv)
  Protected i
  Protected *v.Vector3f
  For i = 0 To numPoints - 1
    *v = *p + i * sv
    *v\x = Random(65565) / 65565
    *v\y = Random(65565) / 65565
    *v\z = Random(65565) / 65565
  Next
  ProcedureReturn *p
EndProcedure

Procedure Vector3_Array_Free(*p)
  FreeMemory(*p)
EndProcedure  

Procedure Vector3_Array_Average(*p, numPoints.i, *accum.Vector3f)
  Protected i
  Protected sv.i =  SizeOf(Vector3f)
  Protected *v.Vector3f
  For i= 0 To numPoints - 1
    *v = *p + i * sv
    *accum\x + *v\x
    *accum\y + *v\y
    *accum\z + *v\z
  Next
  *accum\x / numPoints
  *accum\y / numPoints
  *accum\z / numPoints
EndProcedure


Define accum.Vector3f
Define numPoints.i = 1024
Define *points = Vector3_Array_Allocate(numPoints)
Vector3_Array_Average(*points, numPoints.i, @accum)
Debug "ACCUM : "+StrF(accum\x)+", "+StrF(accum\y)+", "+StrF(accum\z)
Vector3_Array_Free(*points)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 7
; Folding = -
; EnableXP
; DisableDebugger
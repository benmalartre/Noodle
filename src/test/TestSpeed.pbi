XIncludeFile "E:\Projects\RnD\Noodle\src\core\Time.pbi"

Structure Vector3
  x.f
  y.f
  z.f
EndStructure


Procedure AveragePosition(*points, numPoints.i,*avg.Vector3)
  Protected *point.Vector3
  *avg\x = 0 
  *avg\y = 0
  *avg\z = 0
  Protected ratio.f = 1.0 / numPoints
  Protected i
  Protected cnt = numPoints - 1
  For i=0 To cnt
    *point = *points + i * SizeOf(Vector3)
    *avg\x + *point\x
    *avg\y + *point\y
    *avg\z + *point\z
  Next
  
  *avg\x * ratio
  *avg\y * ratio
  *avg\z * ratio 
EndProcedure

Procedure AveragePositionASM(*points, numPoints.i, *avg.Vector3)
  *avg\x = 0 
  *avg\y = 0
  *avg\z = 0
  Protected ratio.f = 1.0 / numPoints
  Protected i
  Protected cnt = numPoints - 1
  Define.f x, y, z

  EnableASM
  !MOV eax, [p.p_points]
  !MOV ecx, [p.v_numPoints]
  !MOV ebx, 0
  
  !ForLoop:
  
  !INC ebx
  !
	!FLDZ				; st0 <- 0
	
; 	! mov eax, [p.p_Buffer]
; ! mov ecx, $ffffffff
; ! mov dword [eax], ecx
; ! mov ecx, $fefefefe
; ! mov dword [eax+4], ecx
; ! mov ecx, $fdfdfdfd
; ! mov dword [eax+8], ecx
; 	!FLD	dword [p.p_points + ebx*4]	; st0 <- new value, st1 <- sum of previous
; 	!FADD				; st0 <- sum of new plus previous sum
; 	!INC	ebx
; 	!LOOP	FOR

;   !FLD dword [p.v_x]
;   !FADD st0, [p.p_points]
;   !fadd [*avg\x], 1.5
;   !fadd [*avg\y], 1.5
;   !fadd [*avg\z], 1.5
  DisableASM
ProcedureReturn

;   MOV ecx, numPoints
;   MOV eax, x
;   !fuckinloop:
;   ADD eax, 1
; ;   ADD *avg\x, 1
; ;   ADD *avg\y, 1
; ;   ADD *avg\z, 1
;   !dec ecx
;   !jnz fuckinloop
;   MOV x, eax
  DisableASM
  *avg\x = x
;   *avg\x * ratio
;   *avg\y * ratio
;   *avg\z * ratio 
EndProcedure


Time::Init()

Define numPoints = 20000000
Dim points.Vector3(numPoints)

For i=0 To numPoints - 1
  points(i)\x = Random(1024) - 512
  points(i)\y = Random(1024) - 512
  points(i)\z = Random(1024) - 512
Next

Define avg.Vector3


Define T.d = Time::Get()
AveragePosition(@points(0)\x, numPoints, @avg)
Define computeT.d = Time::Get() - T

MessageRequester("TIME", "COMPUTE : "+StrD(computeT)+Chr(10)+
                         "AVG : ("+StrF(avg\x)+","+StrF(avg\y)+","+StrF(avg\z)+Chr(10))
T.d = Time::Get()
AveragePositionASM(@points(0)\x, numPoints, @avg)
Define computeT.d = Time::Get() - T

MessageRequester("TIME", "COMPUTE : "+StrD(computeT)+Chr(10)+
                         "AVG : ("+StrF(avg\x)+","+StrF(avg\y)+","+StrF(avg\z)+Chr(10))
FreeArray(points())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 46
; FirstLine = 16
; Folding = -
; EnableXP
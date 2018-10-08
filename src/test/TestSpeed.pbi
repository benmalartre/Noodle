XIncludeFile "E:\Projects\RnD\Noodle\src\core\Time.pbi"
XIncludeFile "E:\Projects\RnD\Noodle\src\core\Math.pbi"
XIncludeFile "E:\Projects\RnD\Noodle\src\objects\Geometry.pbi"
XIncludeFile "E:\Projects\RnD\Noodle\src\objects\Triangle.pbi"
Structure Vector3
  x.f
  y.f
  z.f
EndStructure

Structure __mm128_Vector3
  x.f
  y.f
  z.f
  w.f
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

Procedure Compare(*A1, *A2, nb)
  Protected *v1.Vector3, *v2.Vector3
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(Vector3)
    *v2 = *A2 + i * SizeOf(__mm128_Vector3)
    If Abs(*v1\x - *v2\x) > 0.0000001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\y - *v2\y) > 0.0000001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\z - *v2\z) > 0.0000001
      ProcedureReturn #False
    EndIf
  Next
  
  ProcedureReturn #True
EndProcedure



Time::Init()

; Define numPoints = 20000000
; Dim points.Vector3(numPoints)
; 
; For i=0 To numPoints - 1
;   points(i)\x = Random(1024) - 512
;   points(i)\y = Random(1024) - 512
;   points(i)\z = Random(1024) - 512
; Next
; 
; Define avg.Vector3
; 
; 
; Define T.d = Time::Get()
; AveragePosition(@points(0)\x, numPoints, @avg)
; Define computeT.d = Time::Get() - T
; 
; MessageRequester("TIME", "COMPUTE : "+StrD(computeT)+Chr(10)+
;                          "AVG : ("+StrF(avg\x)+","+StrF(avg\y)+","+StrF(avg\z)+Chr(10))
; T.d = Time::Get()
; AveragePositionASM(@points(0)\x, numPoints, @avg)
; Define computeT.d = Time::Get() - T
; 
; MessageRequester("TIME", "COMPUTE : "+StrD(computeT)+Chr(10)+
;                          "AVG : ("+StrF(avg\x)+","+StrF(avg\y)+","+StrF(avg\z)+Chr(10))
; FreeArray(points())


Procedure PolygonSoup(numTris.i)
  Define *positions = AllocateMemory(numTris * 9 * 4)
	Define offset = 0
	For i = 0  To  numTris -1

		PokeF(*positions + offset, (Random(1024) / 1024) * 50 - 25)
		PokeF(*positions + offset + 4, (Random(1024) / 1024) * 50 - 25)
		PokeF(*positions + offset + 8, (Random(1024) / 1024) * 50 - 25)
		offset +12
	Next
	
	ProcedureReturn *positions
EndProcedure
	
Define numTris.i = 10000000
Define size_soup.i = numTris * 9 * 4
Define size_soup_aligned.i = numTris * 12 * 4

Define *soup1 = PolygonSoup(numTris)
Define *soup2 = AllocateMemory(size_soup_aligned)
For i=0 To numTris
  CopyMemory(*soup1 + (i*3) *SizeOf(Vector3), *soup2 + (i*3) * SizeOf(__mm128_Vector3), SizeOf(Vector3))
  CopyMemory(*soup1 + (i*3+1) *SizeOf(Vector3), *soup2 + (i*3+1) * SizeOf(__mm128_Vector3), SizeOf(Vector3))
  CopyMemory(*soup1 + (i*3+2) *SizeOf(Vector3), *soup2 + (i*3+2) * SizeOf(__mm128_Vector3), SizeOf(Vector3))

Define numIndices = (numTris * 3)
Dim indices.l(numIndices)
For i=0 To  numIndices - 1
  indices(i) = i
Next

Define center.Math::v3f32
Define halfsize.Math::v3f32
Vector3::Set(center,0, 7, 0)
Vector3::Set(halfsize,0.5, 0.5, 0.5)
Define tri.Geometry::Triangle_t
Define.d startT = Time::Get()

Define numHits = 0;
Define offset = 0 ;
; Define ID
; EnableASM
; MOV rcx, numTris
; DisableASM
; ; ! mov rbx, v_offset
; !tri_touch_loop:
; EnableASM
; MOVQ tri\ID, ID
; DisableASM
; !push rcx
; 
; ;   If Triangle::Touch(@tri, *soup, @center, @halfsize) 
; ; 	  numHits + 1
; ; 	EndIf
; !pop rcx
; !   dec rcx
; !   jnz tri_touch_loop 
Define touch.b
For i = 0 To  numTris - 1
	tri\ID = i
	
	tri\vertices[0] = offset
	tri\vertices[1] = offset + 1
	tri\vertices[2] = offset + 2
	offset + 3

	If Triangle::Touch(tri, *soup1, center, halfsize) 
	  numHits + 1
	EndIf
Next

Define elapsed.d = (Time::Get() - startT)

startT = Time::Get()
Dim touches.b(numTris)
Triangle::TouchArray(*soup2, @indices(0), numTris, center, halfsize, @touches(0))
Define elapsed2.d = (Time::Get() - startT)


MessageRequester("Octree",
                 "NUM TRIANGLES : " +Str( numTris ) + Chr(10)+
                 "NUM HITS : " +Str(numHits) + Chr(10)+
                 "TOOK : " +StrD(elapsed)  +", "+StrD(elapsed2)+Chr(10)+
                 "EQUALS : "+Str(Compare(*soup1, *soup2, numTris)))                ;

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 100
; FirstLine = 77
; Folding = -
; EnableXP
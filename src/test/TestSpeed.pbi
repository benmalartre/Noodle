XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Triangle.pbi"

UseModule Math

Procedure AveragePosition(*points, numPoints.i,*avg.v3f32)
  Protected *point.v3f32
  *avg\x = 0 
  *avg\y = 0
  *avg\z = 0
  Protected ratio.f = 1.0 / numPoints
  Protected i
  Protected cnt = numPoints - 1
  For i=0 To cnt
    *point = *points + i * SizeOf(v3f32)
    *avg\x + *point\x
    *avg\y + *point\y
    *avg\z + *point\z
  Next
  
  *avg\x * ratio
  *avg\y * ratio
  *avg\z * ratio 
EndProcedure

Procedure AveragePositionASM(*points, numPoints.i, *avg.v3f32)
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
  Protected *v1.v3f32, *v2.v3f32
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(v3f32)
    *v2 = *A2 + i * SizeOf(v3f32)
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
  Define *positions = Memory::AllocateAlignedMemory(numTris * 3 * SizeOf(v3f32))
	Define offset = 0
	For i = 0  To  numTris -1

		PokeF(*positions + offset, (Random(1024) / 1024) * 50 - 25)
		PokeF(*positions + offset + 4, (Random(1024) / 1024) * 50 - 25)
		PokeF(*positions + offset + 8, (Random(1024) / 1024) * 50 - 25)
		offset + SizeOf(v3f32)
	Next
	
	ProcedureReturn *positions
EndProcedure
	
Define numTris.i = 12000000
Define size_soup.i = numTris * 3 * SizeOf(v3f32)

Define *soup = PolygonSoup(numTris)
Define numIndices = (numTris * 3)
Dim indices.l(numIndices)
For i=0 To  numIndices - 1
  indices(i) = i
Next
; 
Define box.Geometry::Box_t


Vector3::Set(box\origin,0, 7, 0)
Vector3::Set(box\extend,0.5, 0.5, 0.5)


Define numHits1 = 0, numHits2 = 0
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
Define.d startT = Time::Get()
Define.v3f32 *a, *b, *c
For i = 0 To  numTris - 1
	*a = *soup + (i * 3) * SizeOf(v3f32)
	*b = *soup + (i * 3 + 1) * SizeOf(v3f32)
	*c = *soup + (i * 3 + 2) * SizeOf(v3f32)
	offset + 3

	If Triangle::TouchPB(box, *a, *b, *c) 
	  numHits1 + 1
	EndIf
Next

Define elapsed.d = (Time::Get() - startT)

Define.d startT = Time::Get()
Define.v3f32 *a, *b, *c
For i = 0 To  numTris - 1
	*a = *soup + (i * 3) * SizeOf(v3f32)
	*b = *soup + (i * 3 + 1) * SizeOf(v3f32)
	*c = *soup + (i * 3 + 2) * SizeOf(v3f32)
	offset + 3

	If Triangle::Touch(box, *a, *b, *c) 
	  numHits2 + 1
	EndIf
Next

Define elapsed2.d = (Time::Get() - startT)

; Dim touches.b(numTris)
; startT = Time::Get()
; numHits2 = Triangle::TouchArray(*soup1, @indices(0), numTris, center, halfsize, @touches(0))
; Define elapsed2.d = (Time::Get() - startT)


MessageRequester("Octree",
                 "NUM TRIANGLES : " +Str( numTris ) + Chr(10)+
                 "NUM HITS : " +Str(numHits1) + ","+Str(numHits2)+Chr(10)+
                 "TOOK : " +StrD(elapsed)  +", "+StrD(elapsed2)+Chr(10)+"NUM HITS : "+Str(numHits))
;                  "EQUALS : "+Str(Compare(*soup1, *soup2, numTris)))                ;
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 148
; FirstLine = 137
; Folding = -
; EnableXP
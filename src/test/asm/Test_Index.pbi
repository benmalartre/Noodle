XIncludeFile "../../core/Array.pbi"
XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../core/Time.pbi"
XIncludeFile "../../core/Slot.pbi"
XIncludeFile "../../objects/Polymesh.pbi"

Time::Init()
Define *indices.CArray::CArrayLong = CArray::newCArrayLong()
Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
CArray::SetCount(*indices,12)
CArray::SetCount(*positions,6)

Define *v.Math::v3f32
For i=0 To 5
  *v = CArray::GetValue(*positions, i)
  Vector3::Set(*v, Random(2048), Random(2048), Random(2048))
Next

For i=0 To 11
  CArray::SetValueL(*indices, i, Random(5,0))
Next

Procedure.l AtIndex(*data, size.i, index.i)
  Define output.l

  ! mov rsi, [p.p_data]                 ; move indices to esi register
  ! mov rax, [p.v_size]                 ; move item size to eax register
  ! mov rcx, [p.v_index]                ; move item index to ecx register
  ! mul rcx                             ; mul size * index to get memory offset
  ! add rsi, rax                        ; add to memory pointer, shiffting in array  
  ! mov rdi, [rsi]                      ; get value in edi rgister        
  ! mov [p.v_output], rdi               ; mov evalue to memory

  ProcedureReturn output
EndProcedure

Procedure PositionAtIndex(*positions, *indices, index.l, size.l)
  ! mov eax, [p.v_index]              ; load index value
  ! mov edx, 4                        ; index item size
  ! imul eax, edx                     ; compute offset (index * size)
  
  ! mov esi, [p.p_indices]            ; load indices array
  ! add esi, eax                      ; offset to desired item
  
  ! mov ecx, [esi]                    ; get value for desired item
  ! mov edx, [p.v_size]               ; load v3f32 size
  ! imul ecx, edx                     ; compute offset in position array
 
  ! mov rax, [p.p_positions]          ; load positions array
  ! add rax, rcx                      ; offset to desired item
  ProcedureReturn
EndProcedure

Procedure SetPolygonNormals(numPolygons.l, *facecount, *normals, *polygonnormals)
  Define nbv.i
  Define nbt.i
  ; ---------------------------------------------------------------------------------
  ; set polygon normals
  ; ---------------------------------------------------------------------------------
  ! mov ecx, [p.v_numPolygons]
  ! mov edx, [p.p_facecount]
  ! mov rsi, [p.p_normals] 
  ! mov rdi, [p.p_polygonnormals] 
  
  ! loop_set_polygon_normals2:
  !   mov eax, [edx]                          ; get num vertices for this polygon
  !   add edx, 4                              ; increment face count for next polygon
  !   mov r11, -2
  !   add r11, rax                            ; compute num tris
  !   xorps xmm0, xmm0
  
  !   loop_per_polygon_triangle2:
  !     movups xmm1, [rsi]
  !     addps xmm0, xmm1
  !     add rsi, 48
  !     dec r11
  !     jg loop_per_polygon_triangle2
  
  ; ---------------------------------------------------------------------------------
  ; normalize in place
  ; ---------------------------------------------------------------------------------
  !   movaps xmm6, xmm0                 ; copy normal in xmm6
  !   mulps xmm0, xmm0                  ; square it
  !   movaps xmm7, xmm0                 ; copy in xmm7
  !   shufps xmm7, xmm7, 01001110b      ; shuffle component z w x y
  !   addps xmm0, xmm7                  ; packed addition
  !   movaps xmm7, xmm0                 ; copy in xmm7  
  !   shufps xmm7, xmm7, 00010001b      ; shuffle componennt y x y x
  !   addps xmm0, xmm7                  ; packed addition
  !   rsqrtps xmm0, xmm0                ; reciproqual root square (length)
  !   mulps xmm0, xmm6                  ; multiply by intila vector
  
  !   movups [rdi], xmm0
  !   add rdi, 16
  
  !   dec ecx
  !   jg loop_set_polygon_normals2
EndProcedure

      
; Define v.Math::v3f32
; For i=0 To 11
;   Debug "--------------------------------------------------------------------"
;   *v = CArray::GetValue(*positions, CArray::GetValueL(*indices, i))
;   Vector3::Echo(*v, "ARRAY :")
;   *v = PositionAtIndex(*positions\data, *indices\data, i,16)
;   Vector3::Echo(*v, "ASM   :")
; Next

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("test", Shape::#SHAPE_BUNNY)
Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
CArray::SetCount(*geom\a_polygonnormals, *geom\nbpolygons)
SetPolygonNormals(*geom\nbpolygons, *geom\a_facecount\data, *geom\a_normals\data, *geom\a_polygonnormals\data)
Debug "OK"
; CArray::Echo(*geom\a_polygonnormals, "Polygon Normals")
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 79
; FirstLine = 45
; Folding = -
; EnableXP
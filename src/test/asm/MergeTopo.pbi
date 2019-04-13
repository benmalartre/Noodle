
XIncludeFile "../../core/Time.pbi"
XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../objects/Topology.pbi"

UseModule Math
UseModule Geometry


;-----------------------------------------------------------------------------
; Merge
;-----------------------------------------------------------------------------
Procedure TopologyMergePB(*o.Topology_t,*t1.Topology_t,*t2.Topology_t)
  Protected f1 = CArray::GetCount(*t1\faces)
  Protected f2 = CArray::GetCount(*t2\faces)
  Protected v1 = CArray::GetCount(*t1\vertices)
  Protected v2 = CArray::GetCount(*t2\vertices)
  Protected v.v3f32
  Protected f.l
  Protected i
  
  ;Reallocate Memory
  CArray::SetCount(*o\vertices,v1+v2)
  CArray::SetCount(*o\faces,f1+f2)

  CopyMemory(*t1\vertices\data,*o\vertices\data,v1*SizeOf(v))
  CopyMemory(*t2\vertices\data,*o\vertices\data+v1*SizeOf(v),v2*SizeOf(v))
  
  CopyMemory(*t1\faces\data,CArray::GetPtr(*o\faces,0),f1*SizeOf(f))
  
  Protected x
  For i=0 To f2-1
    x = CArray::GetValueL(*t2\faces,i)
    If x>-2
      CArray::SetValueL(*o\faces,i+f1,x+v1)
    Else
      CArray::SetValueL(*o\faces,i+f1,-2)
    EndIf
  Next
 
EndProcedure

Procedure TopologyMergeSSE(*o.Topology_t,*t1.Topology_t,*t2.Topology_t)
  UseModule Math
  Protected f1 = CArray::GetCount(*t1\faces)
  Protected f2 = CArray::GetCount(*t2\faces)
  Protected v1 = CArray::GetCount(*t1\vertices)
  Protected v2 = CArray::GetCount(*t2\vertices)
  Protected v.v3f32
  Protected f.l
  Protected i
  
  ;Reallocate Memory
  CArray::SetCount(*o\vertices,v1+v2)
  CArray::SetCount(*o\faces,f1+f2)

  CopyMemory(*t1\vertices\data,*o\vertices\data,v1*SizeOf(v))
  CopyMemory(*t2\vertices\data,*o\vertices\data+v1*SizeOf(v),v2*SizeOf(v))
  
  CopyMemory(*t1\faces\data,CArray::GetPtr(*o\faces,0),f1*SizeOf(f))

  Define *dst = CArray::GetPtr(*o\faces)
  Define *src = CArray::GetPtr(*t2\faces)
  ! mov rcx, [p.v_f2]                       ; topo 2 indices size
  ! mov rax, [p.v_f1]                       ; topo 1 indices size
  ! mov rsi, [p.p_src]                      ; topo 2 indices ptr
  ! mov rdi, [p.p_dst]                      ; topo1 indices ptr
  ! imul rax, 4                             ; start offset in output array    

  ! movdqu xmm0, [p.v_v1]                   ; load offset in xmm0
  ! pshufd xmm0, xmm0, 0                    ; shuffle offset, offset, offset, offset
  ! movdqu xmm7, [math.l_sse_1111_sign_mask]; load sign mask
  ! movdqu xmm1, [math.l_sse_minusonei_vec] ; load-1, -1, -1, -1 in xmm1
  
  ! loop_merge_topo:
  !   movdqu	xmm2, [rsi]                   ; move four indices to xmm2
  !   movdqa xmm3, xmm2                     ; make a copy in xmm3
  
  !   pcmpgtd xmm3, xmm1                    ; packed compare indices > 0 
  !   pmulld xmm3, xmm0                     ; inverted masked offsets
  !   pmulld xmm3, xmm7                     ; negate offset
  !   paddd xmm2, xmm3                      ; add offset to original values
  !   movdqu [rdi + rax], xmm2              ; send back to memory
  
  !   add rdi, 4                            ; increment destination
  !   add rsi, 4                            ; increment source
  !   dec rcx                               ; decrement counter
  !   jnz loop_merge_topo                   ; next indices
EndProcedure

;-------------------------------------------------------------------------------
; Merge In Place
;-------------------------------------------------------------------------------
Procedure TopologyMergeInPlacePB(*t.Topology_t,*o.Topology_t)
  Protected f1.i = CArray::GetCount(*t\faces)
  Protected f2.i = CArray::GetCount(*o\faces)
  Protected v1.i = CArray::GetCount(*t\vertices)
  Protected v2.i = CArray::GetCount(*o\vertices)
  Protected v.v3f32
  Protected f.i,i.i
  
  ;Reallocate Memory
  CArray::SetCount(*t\vertices,v1+v2)
  CArray::SetCount(*t\faces,f1+f2)

  CopyMemory(CArray::GetPtr(*o\vertices,0),CArray::GetPtr(*t\vertices,v1),v2*SizeOf(v))
  
  If f1>0
    For i=0 To f2-1
      f=CArray::GetValueL(*o\faces,i)
      If f >-2
        f+v1
        CArray::SetValueL(*t\faces,i+f1,f)
      Else 
          CArray::SetValueL(*t\faces,i+f1,-2)
      EndIf
    Next
  Else
    CArray::Copy(*t\faces,*o\faces)
  EndIf
EndProcedure


;-------------------------------------------------------------------------------
; Merge In Place
;-------------------------------------------------------------------------------
Procedure TopologyMergeInPlaceSSE(*t.Topology_t,*o.Topology_t)
  Protected f1.i = CArray::GetCount(*t\faces)
  Protected f2.i = CArray::GetCount(*o\faces)
  Protected v1.i = CArray::GetCount(*t\vertices)
  Protected v2.i = CArray::GetCount(*o\vertices)
  Protected v.v3f32
  Protected f.i,i.i
  
  ;Reallocate Memory
  CArray::SetCount(*t\vertices,v1+v2)
  CArray::SetCount(*t\faces,f1+f2)

  CopyMemory(CArray::GetPtr(*o\vertices,0),CArray::GetPtr(*t\vertices,v1),v2*SizeOf(v))
  
  If f1>0
    Define *f1 = CArray::GetPtr(*t\faces)
    Define *f2 = CArray::GetPtr(*o\faces)
    ! mov rcx, [p.v_f2]                       ; topo 2 indices size
    ! mov rax, [p.v_f1]                       ; topo 1 indices size
    ! mov rsi, [p.p_f2]                       ; topo 2 indices ptr
    ! mov rdi, [p.p_f1]                       ; topo1 indices ptr
    ! imul rax, 4                             ; start offset in output array    
  
    ! movdqu xmm0, [p.v_v1]                   ; load offset in xmm0
    ! pshufd xmm0, xmm0, 0                    ; shuffle offset, offset, offset, offset
    ! movdqu xmm1, [math.l_sse_minusonei_vec] ; load -1, -1, -1, -1 in xmm1
    ! movdqu xmm7, [math.l_sse_1111_sign_mask]; load sign mask for absolute value
    
    ! loop_merge_topo_in_place:
    !   movdqu	xmm2, [rsi]                   ; move four indices to xmm2
    !   movdqa xmm3, xmm2                     ; make a copy in xmm3
    !   pcmpgtd xmm3, xmm1                    ; packed compare indices > 0 
    !   pmulld xmm3, xmm0                     ; inverted masked offsets
    !   pmulld xmm3, xmm7                     ; negate offset
    !   paddd xmm2, xmm3                      ; add offset to original values
    !   movdqu [rdi + rax], xmm2              ; send back to memory
    
    !   add rdi, 4                            ; increment destination
    !   add rsi, 4                            ; increment source
    !   dec rcx                               ; decrement counter
    !   jnz loop_merge_topo_in_place          ; next indices
  Else
    CArray::Copy(*t\faces,*o\faces)
  EndIf
EndProcedure

; ---------------------------------------------------------------------------------
;   MERGE ARRAY
; --------------------------------------------------------------------------------- 
Procedure TopologyMergeArrayPB(*o.Topology_t,*topos.CArray::CArrayPtr)
  Protected nbt = CArray::GetCount(*topos)

  Protected Dim v_offsets.l(nbt)
  Protected Dim f_offsets.l(nbt)
  Protected Dim f_counts.l(nbt)

  Protected v_offset = 0
  Protected f_offset = 0
  Protected t
  Protected *topo.Topology_t
  Protected v.v3f32
  Protected f.l
  Protected i
  For t=0 To nbt-1
    *topo = CArray::GetValuePtr(*topos ,t)

    v_offsets(t) = v_offset
    f_offsets(t) = f_offset
    f_counts(t) = CArray::GetCount(*topo\faces)
    v_offset + CArray::GetCount(*topo\vertices)
    f_offset + CArray::GetCount(*topo\faces)
  Next

  ;Reallocate Memory
  CArray::SetCount(*o\vertices,v_offset)
  CArray::SetCount(*o\faces,f_offset)
  
  For t=0 To nbt-1
    *topo = CArray::GetValuePtr(*topos,t)
    CopyMemory(*topo\vertices\data,CArray::GetPtr(*o\vertices,v_offsets(t)),CArray::GetCount(*topo\vertices)*SizeOf(v))

    If t=0
      CopyMemory(*topo\faces\data,CArray::GetPtr(*o\faces,f_offsets(t)),CArray::GetCount(*topo\faces)*SizeOf(f))
    Else
      For i=0 To f_counts(t)-1
        f = PeekL(*topo\faces\data + 4 * i)
        If f>-2
          PokeL(*o\faces\data + (i+f_offsets(t))*4, f+v_offsets(t))
        Else
          PokeL(*o\faces\data+ (i+f_offsets(t))*4, -2)
        EndIf
      Next
    EndIf
  Next
EndProcedure

; ---------------------------------------------------------------------------------
;   MERGE ARRAY
; --------------------------------------------------------------------------------- 
Procedure TopologyMergeArraySSE(*o.Topology_t,*topos.CArray::CArrayPtr)
  Protected nbt = CArray::GetCount(*topos)

  Protected Dim v_offsets.l(nbt)
  Protected Dim f_offsets.l(nbt)
  Protected Dim f_counts.l(nbt)

  Protected v_offset = 0
  Protected f_offset = 0
  Protected t
  Protected *topo.Topology_t
  Protected v.v3f32
  Protected f.l
  Protected i
  For t=0 To nbt-1
    *topo = CArray::GetValuePtr(*topos ,t)

    v_offsets(t) = v_offset
    f_offsets(t) = f_offset
    f_counts(t) = CArray::GetCount(*topo\faces)
    v_offset + CArray::GetCount(*topo\vertices)
    f_offset + CArray::GetCount(*topo\faces)
  Next

  ;Reallocate Memory
  CArray::SetCount(*o\vertices,v_offset)
  CArray::SetCount(*o\faces,f_offset)
    
  Define offsetdata = OffsetOf(CArray::CArrayT\data)
  Define offsetcount = OffsetOf(CArray::CArrayT\itemCount)
  Define offsetvertices = OffsetOf(Geometry::Topology_t\vertices)
  Define offsetfaces = OffsetOf(Geometry::Topology_t\faces)
  Define *outfaces = *o\faces\data
  For t=0 To nbt-1
    *topo = CArray::GetValuePtr(*topos,t)
    CopyMemory(*topo\vertices\data,CArray::GetPtr(*o\vertices,v_offsets(t)),CArray::GetCount(*topo\vertices)*SizeOf(v))
  Next
 
  ! mov rcx, [p.v_nbt]                      ; load topo count
  ! mov rax, [p.a_v_offsets]                ; load topo vertices offset
  ! mov rdx, [p.a_f_counts]                 ; load topo faces count
  ! mov rdi, [p.p_outfaces]                 ; load output faces
  
  ! mov r8, [p.v_offsetdata]                ; load offset to array data
  ! mov r9, [p.v_offsetvertices]            ; load offset to topology vertices
  ! mov r10, [p.v_offsetfaces]              ; load offset to topology faces
  
  ! mov r11, [p.p_topos]                    ; mov topos to r11 register
  ! add r11, r8                             ; offset to datas
  ! mov r12, [r11]                          ; topos\data to r12 register
  
  ! movdqu xmm1, [math.l_sse_minusonei_vec] ; load -1, -1, -1, -1 in xmm1

  ! loop_merge_topo_array:
  !   mov r13, [r12]                        ; load current topo in r13 register
  !   mov r11, [r13 + r10]                  ; load current topo faces in r11 register
  !   add r11, r8                           ; offset to datas
  !   mov rsi, [r11]                        ; topo\faces\data to src register
  !   mov r14d, [rdx]                       ; load current topo face count
  
  !   movss xmm0, [eax]                     ; load current topo vertices offset in xmm0
  !   pshufd xmm0, xmm0, 0                  ; shuffle offset, offset, offset, offset

  ! loop_merge_topo_array_one_topo:
  !   movdqu	xmm2, [rsi]                   ; move four indices to xmm2
  !   movdqa xmm3, xmm2                     ; make a copy in xmm3
  !   pcmpgtd xmm3, xmm1                    ; packed compare indices > 0 
  !   pmulld xmm3, xmm0                     ; inverted masked offsets
  !   pmulld xmm3, xmm1                     ; negate offset
  !   paddd xmm2, xmm3                      ; add offset to original values
  !   movdqu [rdi], xmm2                    ; send back to memory
   
  !   add rdi, 4                            ; increment destination
  !   add rsi, 4                            ; increment source
  
  !   dec r14                               ; decrement current topo indices counter
  !   jnz loop_merge_topo_array_one_topo    ; next indices
  
  ! loop_merge_topo_array_next_topo:
  !   add rax, 4                            ; offset in face offsets array
  !   add rdx, 4                            ; offset in face count array
  !   add r12, 8                            ; next topo address
  !   dec rcx                               ; decrement counter
  !   jnz loop_merge_topo_array             ; next topo
EndProcedure


Procedure TopoInfos(*topo.Geometry::Topology_t)
  Define *v = *topo\vertices\data
  Define *f = *topo\faces\data
  
  Debug "TOPO ADDRESS : "+Str(*topo)
  Debug "VERTICES ADDRESS : "+Str(*topo\vertices)
  Debug "INDICES ADDRESS : "+Str(*topo\faces)
  Debug *v
  Debug *f
  Debug "VERTICES DATA OFFSET : "+Str(*v - *topo)
  Debug "INDICES DATA OFFSET : "+Str(*f - *topo)
  
  Define offsetv = OffsetOf(Geometry::Topology_t\vertices); + OffsetOf(CArray::CArrayT\data)
  Define offsetf = OffsetOf(Geometry::Topology_t\faces); + OffsetOf(CArray::CArrayT\data)
  
;   Define v, f
;   ! mov rsi, {[p.p_topo]
;   ! 
EndProcedure

Procedure TopologyCompare(*t1.Geometry::Topology_t, *t2.Geometry::Topology_t)
  If *t1\faces\itemCount <> *t2\faces\itemCount
    MessageRequester("TOPO", "MISMATCH NUM FACES")
     ProcedureReturn #False
  ElseIf *t1\vertices\itemCount <> *t2\vertices\itemCount
    MessageRequester("TOPO", "MISMATCH NUM VERTICES")
     ProcedureReturn #False
  Else
    Define i
    For i=0 To *t1\faces\itemCount - 1
      If CArray::GetValueL(*t1\faces, i)  <> CArray::GetValueL(*t2\faces, i)
        MessageRequester("TOPO", "MISMATCH STRUCTURE AT INDEX "+Str(i))
        ProcedureReturn #False
      EndIf
     Next
  EndIf
  ProcedureReturn #True
EndProcedure


Time::Init()

Define *topo.Geometry::Topology_t = Topology::New()
Topology::Sphere(*topo, 1,128,64)

Define nb = 2048
Define *matrices.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
Define *m.m4f32
Define q.q4f32
CArray::SetCount(*matrices, nb)

For i=0 To nb - 1
  *m = Carray::GetValue(*matrices, i)
  Matrix4::SetIdentity(*m)
  Quaternion::Randomize(q)
  Matrix4::SetFromQuaternion(*m, q)
Next

Define *topos.CArray::CArrayPtr = CArray::newCArrayPtr()
Define *output1.Geometry::Topology_t = Topology::New()
Define *output2.Geometry::Topology_t = Topology::New()
Topology::TransformArray(*topo, *matrices, *topos)

; Topology::Cube(*topo1)
; Define *topo2.Geometry::Topology_t = Topology::New(*topo1)
; 
; Define *topo3.Geometry::Topology_t = Topology::New()
; Define *topo4.Geometry::Topology_t = Topology::New()
; 
Define startT.d = Time::get()
TopologyMergeArrayPB(*output1, *topos)
Define elapsedT1.d = Time::Get() - startT

Define startT.d = Time::get()
TopologyMergeArraySSE(*output2, *topos)
Define elapsedT2.d = Time::Get() - startT


MessageRequester("T", StrD(elapsedT1)+","+StrD(elapsedT2)+":"+TopologyCompare(*output1, *output2))
; MessageRequester("EQUAL", Str(TopologyCompare(*topo3, *topo4)))
; 
; TopoInfos(*topo)
; Define *topo1 = CreateTopo(3)
; Define *topo2 = CreateTopo(4)
; EchoTopo(*topo1)
; EchoTopo(*topo2)
; 
; *topo1 = MergeTopo(*topo1, *topo2)
; EchoTopo(*topo1)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 311
; FirstLine = 298
; Folding = --
; EnableXP
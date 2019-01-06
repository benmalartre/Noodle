
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

Define *topo1.Geometry::Topology_t = Topology::New()
Topology::Sphere(*topo1, 1,128,64)
; Topology::Cube(*topo1)
Define *topo2.Geometry::Topology_t = Topology::New(*topo1)

Define *topo3.Geometry::Topology_t = Topology::New()
Define *topo4.Geometry::Topology_t = Topology::New()

Define nb = 1024
Define startT.d = Time::get()
For i=0 To nb - 1
  TopologyMergePB(*topo3, *topo1, *topo2)
Next
Define elapsedT1.d = Time::Get() - startT

Define startT.d = Time::get()
For i=0 To nb - 1
  TopologyMergeSSE(*topo4, *topo1, *topo2)
Next
Define elapsedT2.d = Time::Get() - startT



CARray::Echo(*topo3\faces, "TOPO1")
CARray::Echo(*topo4\faces, "TOPO2")
MessageRequester("T", StrD(elapsedT1)+","+StrD(elapsedT2))
MessageRequester("EQUAL", Str(TopologyCompare(*topo3, *topo4)))
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
; CursorPosition = 169
; FirstLine = 136
; Folding = --
; EnableXP
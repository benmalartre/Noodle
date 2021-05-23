XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Utils.pbi"
XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/Geometry.pbi"

; ========================================================================================
;   TOPOLOGY MODULE DECLARATION
; ========================================================================================
DeclareModule Topology
  UseModule Geometry
  UseModule Math
  Declare New(*other.Topology_t = #Null)
  Declare Delete(*Me.Topology_t)
  Declare Set(*topo.Topology_t,*vertices.CArray::CArrayV3F32,*faces.CArray::CArrayLong)
  Declare Clear(*topo.Topology_t)
  Declare Copy(*topo.Topology_t,*other.Topology_t)
  Declare Transform(*topo.Topology_t,*m.m4f32)
  Declare TransformArray(*topo.Topology_t,*matrices.CArray::CArrayM4F32,*topo_array.CArray::CArrayPtr)
  Declare Merge(*o.Topology_t,*t1.Topology_t,*t2.Topology_t)
  Declare MergeInPlace(*t.Topology_t,*o.Topology_t)
  Declare MergeArray(*o.Topology_t,*topos.CArray::CArrayPtr)
  Declare Extrusion(*topo.Topology_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32,closed.b)
  Declare Cap(*topo.Topology_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32,ID.i=0,reusepoints.b=#True,flip.b=#False)
  Declare Update(*topo.Topology_t, *vertices.CArray::CArrayV3F32)
  Declare Cube(*topo.Topology_t,radius.f=1,u.i=1,v.i=1,w.i=1)
  Declare Sphere(*topo.Topology_t,radius.f=1,lats.i=8,longs.i=8)
  Declare Grid(*topo.Topology_t,radius.f=1,u.i=12,v.i=12)
  Declare Cylinder(*topo.Topology_t,radius.f,u.i=8,v.i=1,w.i=0,captop.b=#True,capbottom.b=#True)
  Declare Bunny(*topo.Topology_t)
  Declare Teapot(*topo.Topology_t)
  Declare Torus(*topo.Topology_t)
  
EndDeclareModule

; ========================================================================================
;   TOPOLOGY MODULE IMPLEMENTATION
; ========================================================================================
Module Topology
  UseModule Geometry
  
  ; ----------------------------------------------------------------------------
  ;   DESTRUCTOR
  ; ----------------------------------------------------------------------------
  Procedure Delete(*Me.Topology_t)
    CArray::Delete(*Me\vertices)
    CArray::Delete(*Me\faces)
    ClearStructure(*Me,Topology_t)
    FreeMemory(*Me)
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;   CONSTRUCTOR
  ; ----------------------------------------------------------------------------
  Procedure.i New(*other.Topology_t = #Null)
    Protected *Me.Topology_t = AllocateMemory(SizeOf(Topology_t))
    InitializeStructure(*Me,Topology_t)
    *Me\vertices = CArray::newCArrayV3F32()
    *Me\faces = CArray::newCArrayLong()
    If *other
      CArray::Copy(*Me\vertices,*other\vertices)
      CArray::Copy(*Me\faces,*other\faces)
    EndIf
    
    ProcedureReturn *Me
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   SET
  ; ----------------------------------------------------------------------------
  Procedure Set(*topo.Topology_t,*vertices.CArray::CArrayV3F32,*faces.CArray::CArrayLong) 
    If CArray::GetCount(*vertices)>0
      CArray::Copy(*topo\vertices,*vertices)
      CArray::Copy(*topo\faces,*faces)
    Else
      Clear(*topo)
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   UPDATE
  ; ----------------------------------------------------------------------------
  Procedure Update(*topo.Topology_t,*vertices.CArray::CArrayV3F32) 
    If CArray::GetCount(*vertices)>0 And *vertices\itemCount = *topo\vertices\itemCount
      CArray::Copy(*topo\vertices,*vertices)
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   CLEAR
  ; ----------------------------------------------------------------------------
  Procedure Clear(*topo.Topology_t)
    CArray::SetCount(*topo\vertices,0)
    CArray::SetCount(*topo\faces,0)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   COPY
  ; ----------------------------------------------------------------------------
  Procedure Copy(*topo.Topology_t,*other.Topology_t)
    Set(*topo,*other\vertices,*other\faces)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   TRANSFORM
  ; ----------------------------------------------------------------------------
  Procedure Transform(*topo.Topology_t,*m.m4f32)
    Protected p.v3f32
    Protected i
    Protected *p.v3f32
    CompilerIf Defined(USE_SEE, #PB_Constant) And #USE_SSE
      Define *positions = *topo\vertices\data
      Define nbp.i = CArray::GetCount(*topo\vertices)
      ! mov rax, [p.p_positions]
      ! mov rdx, [p.p_m]
      ! mov rcx, [p.v_nbp]
      
      ! movups  xmm4, [rdx]                 ; load matrix row 0
      ! movups  xmm5, [rdx+16]              ; load matrix row 1
      ! movups  xmm6, [rdx+32]              ; load matrix row 2
      ! movups  xmm7, [rdx+48]              ; load matrix row 3
      
      ! loop_transform_topo:
      !   movaps  xmm0, [rax]               ; d c b a
      !   movaps  xmm1, xmm0                ; d c b a       
      !   movaps  xmm2, xmm0                ; d c b a
      !   movaps  xmm3, xmm0                ; d c b a
    
      !   shufps  xmm0, xmm0,0              ; a a a a 
      !   shufps  xmm1, xmm1,01010101b      ; b b b b
      !   shufps  xmm2, xmm2,10101010b      ; c c c c
      !   shufps  xmm3, xmm3,11111111b      ; d d d d
    
      !   mulps   xmm0, xmm4
      !   mulps   xmm1, xmm5
      !   mulps   xmm2, xmm6
    
      !   addps   xmm0, xmm1
      !   addps   xmm0, xmm2
      !   addps   xmm0, xmm7
      
      !   movaps xmm1, xmm0
      !   shufps xmm1, xmm1, 11111111b
      !   divps xmm0, xmm1
    
      !   movaps [rax], xmm0
      !   add rax, 16
      !   dec rcx
      !   jnz loop_transform_topo
      
    CompilerElse
      For i=0 To CArray::GetCount(*topo\vertices)-1
        *p = CArray::GetValue(*topo\vertices,i)
        Vector3::MulByMatrix4InPlace(*p,*m)
      Next
    CompilerEndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   TRANSFORM ARRAY
  ; ----------------------------------------------------------------------------
  Procedure TransformArray(*topo.Topology_t,*matrices.CArray::CArrayM4F32,*topo_array.CArray::CArrayPtr)
    Protected *t.Topology_t
    Protected *m.m4f32
    Protected i
    For i=0 To CArray::GetCount(*matrices)-1
      *t = New(*topo)
      *m = CArray::GetValue(*matrices,i)
      Transform(*t, *m)
      CArray::AppendPtr(*topo_array,*t)
    Next i
  EndProcedure
  
  
  ; -----------------------------------------------------------------------------
  ;   MERGE
  ; -----------------------------------------------------------------------------
  Procedure Merge(*o.Topology_t,*t1.Topology_t,*t2.Topology_t)
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
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
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
      !   movss	xmm2, [rsi]                     ; move four indices to xmm2
      !   movdqa xmm3, xmm2                     ; make a copy in xmm3
      
      !   pcmpgtd xmm3, xmm1                    ; packed compare indices > 0 
      !   pmulld xmm3, xmm0                     ; inverted masked offsets
      !   pmulld xmm3, xmm7                     ; negate offset
      !   paddd xmm2, xmm3                      ; add offset to original values
      !   movss [rdi + rax], xmm2               ; send back to memory
      
      !   add rdi, 4                            ; increment destination
      !   add rsi, 4                            ; increment source
      !   dec rcx                               ; decrement counter
      !   jnz loop_merge_topo                   ; next indices
    CompilerElse
      Protected x
      For i=0 To f2-1
        x = CArray::GetValueL(*t2\faces,i)
        If x>-2
          CArray::SetValueL(*o\faces,i+f1,x+v1)
        Else
          CArray::SetValueL(*o\faces,i+f1,-2)
        EndIf
      Next
    CompilerEndIf
  EndProcedure
  
  ; -------------------------------------------------------------------------------
  ;   MERGE IN PLACE
  ; -------------------------------------------------------------------------------
  Procedure MergeInPlace(*t.Topology_t,*o.Topology_t)
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
      CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
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
        !   movss	xmm2, [rsi]                     ; move four indices to xmm2
        !   movdqa xmm3, xmm2                     ; make a copy in xmm3
        !   pcmpgtd xmm3, xmm1                    ; packed compare indices > 0 
        !   pmulld xmm3, xmm0                     ; inverted masked offsets
        !   pmulld xmm3, xmm7                     ; negate offset
        !   paddd xmm2, xmm3                      ; add offset to original values
        !   movss [rdi + rax], xmm2               ; send back to memory
        
        !   add rdi, 4                            ; increment destination
        !   add rsi, 4                            ; increment source
        !   dec rcx                               ; decrement counter
        !   jnz loop_merge_topo_in_place          ; next indices
      CompilerElse
        For i=0 To f2-1
          f=CArray::GetValueL(*o\faces,i)
          If f >-2
            f+v1
            CArray::SetValueL(*t\faces,i+f1,f)
          Else 
              CArray::SetValueL(*t\faces,i+f1,-2)
          EndIf
        Next
      CompilerEndIf
    Else
      CArray::Copy(*t\faces,*o\faces)
    EndIf
  EndProcedure
  
  ; ---------------------------------------------------------------------------------
  ;   MERGE ARRAY
  ; --------------------------------------------------------------------------------- 
  Procedure MergeArray(*o.Topology_t,*topos.CArray::CArrayPtr)
    Protected nbt = CArray::GetCount(*topos)
    Protected *v_offsets = AllocateMemory(nbt*4)
    Protected *f_offsets =  AllocateMemory(nbt*4)
    Protected *f_counts = AllocateMemory(nbt*4)

    Protected v_offset = 0
    Protected f_offset = 0
    Protected t
    Protected *topo.Topology_t
    Protected f.l
    Protected i
    For t=0 To nbt-1
      *topo = CArray::GetValuePtr(*topos ,t)
      PokeL(*v_offsets +t*4, v_offset)
      PokeL(*f_offsets +t*4, f_offset)
      PokeL(*f_counts + t*4, CArray::GetCount(*topo\faces))
      v_offset + CArray::GetCount(*topo\vertices)
      f_offset + CArray::GetCount(*topo\faces)
    Next

    ;Reallocate Memory
    CArray::SetCount(*o\vertices,v_offset)
    CArray::SetCount(*o\faces,f_offset)
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      
      Define offsetdata = OffsetOf(CArray::CArrayT\data)
      Define offsetcount = OffsetOf(CArray::CArrayT\itemCount)
      Define offsetvertices = OffsetOf(Geometry::Topology_t\vertices)
      Define offsetfaces = OffsetOf(Geometry::Topology_t\faces)
      Define *outfaces = *o\faces\data
      
      For t=0 To nbt-1
        *topo = CArray::GetValuePtr(*topos,t)
        CopyMemory(*topo\vertices\data,
                   CArray::GetPtr(*o\vertices,PeekL(*v_offsets+t*4)),
                   CArray::GetCount(*topo\vertices)*SizeOf(v3f32))
      Next
      
      ! mov rcx, [p.v_nbt]                      ; load topo count
      ! mov rax, [p.p_v_offsets]                ; load topo vertices offset
      ! mov rdx, [p.p_f_counts]                 ; load topo faces count
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
      
      !   movdqu xmm0, [rax]                     ; load current topo vertices offset in xmm0
      !   pshufd xmm0, xmm0, 0                  ; shuffle offset, offset, offset, offset
   
      ! loop_merge_topo_array_one_topo:
      !   movss	xmm2, [rsi]                   ; move four indices to xmm2
      !   movdqa xmm3, xmm2                     ; make a copy in xmm3
      !   pcmpgtd xmm3, xmm1                    ; packed compare indices > 0 
      !   pmulld xmm3, xmm0                     ; inverted masked offsets
      !   pmulld xmm3, xmm1                     ; negate offset
      !   paddd xmm2, xmm3                      ; add offset to original values
      !   movss [rdi], xmm2                    ; send back to memory
       
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
      
    CompilerElse
      
      For t=0 To nbt-1
        *topo = CArray::GetValuePtr(*topos,t)
        CopyMemory(*topo\vertices\data,
                   CArray::GetPtr(*o\vertices,PeekL(*v_offsets + t*4)),
                   CArray::GetCount(*topo\vertices)*SizeOf(v3f32))
  
        If t=0
          CopyMemory(*topo\faces\data,
                     CArray::GetPtr(*o\faces,PeekL(*f_offsets+t*4)),
                     CArray::GetCount(*topo\faces)*SizeOf(f))
        Else
          For i=0 To PeekL(*f_counts+t*4)-1
            f = PeekL(*topo\faces\data + 4 * i)
            If f>-2
              PokeL(*o\faces\data + (i+PeekL(*f_offsets+t*4))*4, f+PeekL(*v_offsets+t*4))
            Else
              PokeL(*o\faces\data+ (i+PeekL(*f_offsets+t*4))*4, -2)
            EndIf
          Next
        EndIf
      Next
    CompilerEndIf
    
    FreeMemory(*v_offsets)
    FreeMemory(*f_offsets)
    FreeMemory(*f_counts)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   EXTRUSION
  ; ----------------------------------------------------------------------------
  Procedure Extrusion(*topo.Topology_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32,closed.b)
    If CArray::GetCount(*points)<2 Or CArray::GetCount(*section)<2: ProcedureReturn : EndIf

    Protected p.v3f32
    Protected is,ip
    Protected *oP.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
    CArray::Copy(*oP,*section)
    Protected so.i = CArray::GetCount(*section)
    Protected *extrusion.Topology_t = Topology::New()
  
    Protected offset = 0
    Protected cnt = 0
    Protected indices.s
    Protected *m.m4f32
    CArray::SetCount(*extrusion\vertices,0)
    CArray::SetCount(*extrusion\faces,0)
    If Not closed
      For ip=0 To CArray::GetCount(*points)-1
        *m = CArray::GetValue(*points,ip)
        ;Matrix4_TransposeInPlace(*m)
        MathUtils::TransformPositionArray(*oP,*section,*m)
    
        CArray::AppendArray(*extrusion\vertices,*oP)
        If ip>0
          For is=0 To CArray::GetCount(*section)-2
            CArray::AppendL(*extrusion\faces,cnt+is)
            CArray::AppendL(*extrusion\faces,cnt+is+1)
            CArray::AppendL(*extrusion\faces,cnt+is+1+so)
            CArray::AppendL(*extrusion\faces,cnt+is+so)
            CArray::AppendL(*extrusion\faces,-2)
          Next
          cnt+so
        EndIf
      Next
    Else
      ; Pop Last duplicated vertex
      CArray::SetCount(*section,CArray::GetCount(*section)-1)
      For ip=0 To CArray::GetCount(*points)-1
        *m = CArray::GetValue(*points,ip)
        ;Matrix4_TransposeInPlace(*m)
        MathUtils::TransformPositionArray(*oP,*section,*m)
    
        CArray::AppendArray(*extrusion\vertices,*oP)
        Protected last = CArray::GetCount(*section)
        If ip>0
          For is=0 To CArray::GetCount(*section)-2
            CArray::AppendL(*extrusion\faces,cnt+is)
            CArray::AppendL(*extrusion\faces,cnt+is+1)
            CArray::AppendL(*extrusion\faces,cnt+is+1+so)
            CArray::AppendL(*extrusion\faces,cnt+is+so)
            CArray::AppendL(*extrusion\faces,-2)
          Next
          ;Append Last Face
          CArray::AppendL(*extrusion\faces,cnt+last)
          CArray::AppendL(*extrusion\faces,cnt)
          CArray::AppendL(*extrusion\faces,cnt+so)
          CArray::AppendL(*extrusion\faces,cnt+last+so)
          CArray::AppendL(*extrusion\faces,-2)
          cnt+so
        EndIf
      Next
    EndIf

    MergeInPlace(*topo,*extrusion)
    Delete(*extrusion)
    CArray::Delete(*oP)
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   CAP
  ; ----------------------------------------------------------------------------
  Procedure Cap(*topo.Topology_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32,ID.i=0,reusepoints.b=#True,flip.b=#False)
    If reusepoints
      Protected *m.m4f32 = CArray::GetValue(*points,ID)
      Protected p.v3f32
      
      Vector3::MulByMatrix4InPlace(p,*m)
      CArray::Append(*topo\vertices,@p)
      Protected pID = CArray::GetCount(*topo\vertices)-1
 
      Protected u = CArray::GetCount(*points)
      Protected v = CArray::GetCount(*section)-1
      Protected base.i = ID * u * v
      
      Protected nbt = CArray::GetCount(*section)
      If Not flip
        For i=0 To nbt-1
          CArray::AppendL(*topo\faces,pID)
          CArray::AppendL(*topo\faces,ID*(v+1) + (base+i+1)%v)
          CArray::AppendL(*topo\faces,ID*(v+1) + (base+i)%v)
          CArray::AppendL(*topo\faces,-2)
        Next
      Else
        For i=0 To nbt-1
          CArray::AppendL(*topo\faces,ID*(v+1) + (base+i)%v)
          CArray::AppendL(*topo\faces,ID*(v+1) + (base+i+1)%v)
          CArray::AppendL(*topo\faces,pID)
          CArray::AppendL(*topo\faces,-2)
        Next
        
      EndIf
    Else
   
    EndIf
  EndProcedure
  
  
  ; ---------------------------------------------------------
  ;   CUBE
  ; ---------------------------------------------------------
   Procedure Cube(*topo.Topology_t,radius.f=1,u.i=1,v.i=1,w.i=1)
  
    Protected x = 0
    CArray::SetCount(*topo\vertices,8)
    CArray::SetCount(*topo\faces,30)
  
    Protected p.v3f32
    Protected l.f = radius*0.5
  
    Vector3::Set(p,l,l,l)
    CArray::SetValue(*topo\vertices,0,p)
    Vector3::Set(p,l,l,-l)
    CArray::SetValue(*topo\vertices,1,p)
    Vector3::Set(p,-l,l,-l)
    CArray::SetValue(*topo\vertices,2,p)
    Vector3::Set(p,-l,l,l)
    CArray::SetValue(*topo\vertices,3,p)
    Vector3::Set(p,l,-l,l)
    CArray::SetValue(*topo\vertices,4,p)
    Vector3::Set(p,l,-l,-l)
    CArray::SetValue(*topo\vertices,5,p)
    Vector3::Set(p,-l,-l,-l)
    CArray::SetValue(*topo\vertices,6,p)
    Vector3::Set(p,-l,-l,l)
    CArray::SetValue(*topo\vertices,7,p)
    
    
    ;Face
    CArray::SetValueL(*topo\faces,0,3)
    CArray::SetValueL(*topo\faces,1,2)
    CArray::SetValueL(*topo\faces,2,1)
    CArray::SetValueL(*topo\faces,3,0)
    CArray::SetValueL(*topo\faces,4,-2)
    
    CArray::SetValueL(*topo\faces,5,2)
    CArray::SetValueL(*topo\faces,6,6)
    CArray::SetValueL(*topo\faces,7,5)
    CArray::SetValueL(*topo\faces,8,1)
    CArray::SetValueL(*topo\faces,9,-2)
    
    CArray::SetValueL(*topo\faces,10,6)
    CArray::SetValueL(*topo\faces,11,7)
    CArray::SetValueL(*topo\faces,12,4)
    CArray::SetValueL(*topo\faces,13,5)
    CArray::SetValueL(*topo\faces,14,-2)
    
    CArray::SetValueL(*topo\faces,15,7)
    CArray::SetValueL(*topo\faces,16,3)
    CArray::SetValueL(*topo\faces,17,0)
    CArray::SetValueL(*topo\faces,18,4)
    CArray::SetValueL(*topo\faces,19,-2)
    
    CArray::SetValueL(*topo\faces,20,1)
    CArray::SetValueL(*topo\faces,21,5)
    CArray::SetValueL(*topo\faces,22,4)
    CArray::SetValueL(*topo\faces,23,0)
    CArray::SetValueL(*topo\faces,24,-2)
    
    CArray::SetValueL(*topo\faces,25,7)
    CArray::SetValueL(*topo\faces,26,6)
    CArray::SetValueL(*topo\faces,27,2)
    CArray::SetValueL(*topo\faces,28,3)
    CArray::SetValueL(*topo\faces,29,-2)
    
    *topo\dirty = #True
  EndProcedure
  
  ; ---------------------------------------------------------
  ;     SPHERE
  ; ---------------------------------------------------------
  Procedure Sphere(*topo.Topology_t,radius.f=1,lats.i=8,longs.i=8)
    Protected nbp = (longs-2)*lats+2
    
    CArray::SetCount(*topo\vertices,nbp)
    ; Vertices Position
    Protected i, j, k
    Protected p.v3f32
    Define.f lat,y,yr,lng,x,z
    
    For i = 0 To longs-1
      lng = #F32_PI *(-0.5 + i/(longs-1))
      y = radius * Sin(lng)
      yr = radius * Cos(lng)
      If i=0
        Vector3::Set(p,0,-radius,0)
        CArray::SetValue(*topo\vertices,0,p)
  
  
      ElseIf i = longs-1
        Vector3::Set(p,0,radius,0)
        CArray::SetValue(*topo\vertices,nbp-1,p)
  
  
      Else
        For j = 0 To lats-1
          lat = 2*#F32_PI * ((j-1)*(1/lats))
          x = Cos(lat)
          z = Sin(lat)
          Vector3::Set(p,x*yr,y,z*yr)
          k = (i-1)*lats+j+1
          CArray::SetValue(*topo\vertices,k,p)
  
        Next j
      EndIf
    Next i
    
    
    ; Face Indices
    Protected nbf = (longs-1)*lats
    Protected nbi = (longs-3)*lats*4 + 2*lats*3
    
    Define counter = 0
    CArray::SetCount(*topo\faces,nbf+nbi)
    
    Define.i i1,i2,i3,i4,offset
  
    For i=0 To longs-2
      For j=0 To lats-1
        If i=0
          i1 = 0
          i2 = j+1
          i3 = (j+1)%lats+1
          CArray::SetValueL(*topo\faces,offset,i3)
          CArray::SetValueL(*topo\faces,offset+1,i2)
          CArray::SetValueL(*topo\faces,offset+2,i1)
          CArray::SetValueL(*topo\faces,offset+3,-2)
  
          offset+4
          counter +4
        ElseIf i= longs-2
          i1 = nbp-1
          i2 = nbp - lats +j-1
          If j=lats-1
            i3 = nbp - lats-1
          Else
            i3 = nbp - lats+j
          EndIf
          
          CArray::SetValueL(*topo\faces,offset,i1)
          CArray::SetValueL(*topo\faces,offset+1,i2)
          CArray::SetValueL(*topo\faces,offset+2,i3)
          CArray::SetValueL(*topo\faces,offset+3,-2)
  
          offset+4
          counter+4
  
        Else
          i1 = (i-1)*lats+j+1
          i4 = i1+lats
          
          If j=lats-1
            i2 = i1-lats+1
            i3 = i1+1
          Else
            i2 = i1+1
            i3 = i1+lats+1
          EndIf
          
          CArray::SetValueL(*topo\faces,offset,i1)
          CArray::SetValueL(*topo\faces,offset+1,i2)
          CArray::SetValueL(*topo\faces,offset+2,i3)
          CArray::SetValueL(*topo\faces,offset+3,i4)
          CArray::SetValueL(*topo\faces,offset+4,-2)
          
          offset+5
          counter+5
  
        EndIf
        
        
      Next j
    Next i
   
    *topo\dirty = #True
  EndProcedure
  
  ; ---------------------------------------------------------
  ;     GRID
  ; ---------------------------------------------------------
  Procedure Grid(*topo.Topology_t,radius.f=1,u.i=12,v.i=12)
    Math::MAXIMUM(u,2)
    Math::MAXIMUM(v,2)
    
    Protected nbp = (u-1)*(v-1)
  
    CArray::SetCount(*topo\vertices,u*v)
    CArray::SetCount(*topo\faces,nbp*5)
    
    Protected x,z
    Define.f stepx, stepz
    stepx = radius*1/(u-1)
    stepz = radius*1/(v-1)
    
    Protected pos.v3f32
    For z=0 To v-1
      For x=0 To u-1
        Vector3::Set(pos,-0.5*radius+x*stepx,0,-0.5*radius+z*stepz)
        CArray::SetValue(*topo\vertices,z*u+x,pos)
      Next x
    Next z
    
    Protected index = 0
    Protected offset=0

    For z=0 To v-2
      For x=0 To u-2
        index = z*u+x
        CArray::SetValueL(*topo\faces,offset+0,index)
        CArray::SetValueL(*topo\faces,offset+1,index+1)
        CArray::SetValueL(*topo\faces,offset+2,index+u+1)
        CArray::SetValueL(*topo\faces,offset+3,index+u)
        CArray::SetValueL(*topo\faces,offset+4,-2)
        offset + 5
      Next x
    Next z
    *topo\dirty = #True

  EndProcedure
  
  ; --------------------------------------------------------------
  ;   CYLINDER
  ; --------------------------------------------------------------
  Procedure Cylinder(*topo.Topology_t,radius.f,u.i=8,v.i=1,w.i=0,captop.b=#True,capbottom.b=#True)

    CArray::SetCount(*topo\vertices,0)
    CArray::SetCount(*topo\faces,0)
    
    Protected p.v3f32
    Protected c.v3f32
    Protected q.q4f32
    Protected s.f = 360 / u
    Protected t.f = 1/v
    Protected nbp = u* (v+1)
    Protected bc.v3f32
    Protected tc.v3f32
    Protected i,j
    Vector3::Set(bc,0,-1,0)
    Vector3::Set(tc,0,1,0)
    

    For i=0 To v
      
      Vector3::LinearInterpolate(c,bc,tc,i*t)
      For j=0 To u-1
          
        Quaternion::SetFromAxisAngleValues(q,0,1,0,Radian(j*s))
        Vector3::Set(p,0,0,1)
        Vector3::MulByQuaternionInPlace(p,q)
        Vector3::AddInPlace(p,c)
        CArray::Append(*topo\vertices,p)
      Next
      
    Next
    
    
    Protected nbf = u*v
    Protected base.i
    Protected p1.l,p2.l,p3.l,p4.l
    For i=0 To v-1
      For j=0 To u-1
        If j <= u-2
          p1 = base+j+u
          p2 = base+(j+1)+u
          p3 = base+(j+1)
          p4 = base+j
        Else
          p1 = base+j+u
          p2 = base+u
          p3 = base
          p4 = base+j
        EndIf
        
        CArray::AppendL(*topo\faces,p1)
        CArray::AppendL(*topo\faces,p2)
        CArray::AppendL(*topo\faces,p3)
        CArray::AppendL(*topo\faces,p4)
        CArray::AppendL(*topo\faces,-2)
        
      Next j
      base + u
    Next i
    
    If captop
;       Vector3::SetFromOther(  
    EndIf
    
    *topo\dirty = #True
  
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   BUNNY
  ; ---------------------------------------------------------
  Procedure Bunny(*topo.Topology_t)
   
    Define v=0
    Define p.v3f32
    CArray::SetCount(*topo\vertices,Shape::#BUNNY_NUM_VERTICES)
  
    CopyMemory(SHAPE::GetVertices(Shape::#SHAPE_BUNNY),CArray::GetPtr(*topo\vertices,0),Shape::#BUNNY_NUM_VERTICES * CArray::GetItemSize(*topo\vertices))
  
    
    Define i.i
    Define l.l
    CArray::SetCount(*topo\faces,Shape::#BUNNY_NUM_INDICES+Shape::#BUNNY_NUM_TRIANGLES)
    Define id=0
    Define t
    For t=0 To Shape::#BUNNY_NUM_TRIANGLES-1
      For i=0 To 2
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_BUNNY)+t*3*SizeOf(l))
        CArray::SetValueL(*topo\faces,id,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_BUNNY)+(t*3+1)*SizeOf(l))
        CArray::SetValueL(*topo\faces,id+1,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_BUNNY)+(t*3+2)*SizeOf(l))
        CArray::SetValueL(*topo\faces,id+2,l)
      Next i
      CArray::SetValueL(*topo\faces,id+3,-2)
      id+4
    Next t
    *topo\dirty = #True
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   TEAPOT
  ; ---------------------------------------------------------
  Procedure Teapot(*topo.Topology_t)

    Define v=0
    Define p.v3f32
    CArray::SetCount(*topo\vertices,Shape::#TEAPOT_NUM_VERTICES)
  
    CopyMemory(SHAPE::GetVertices(Shape::#SHAPE_TEAPOT),
               CArray::GetPtr(*topo\vertices,0),
               Shape::#TEAPOT_NUM_VERTICES * CArray::GetItemSize(*topo\vertices))
  
    
    Define i.i
    Define l.l
    CArray::SetCount(*topo\faces,Shape::#TEAPOT_NUM_TRIANGLES*4)
    Define id=0
    Define t
    For t=0 To Shape::#TEAPOT_NUM_TRIANGLES-1
      For i=0 To 2
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TEAPOT)+t*3*SizeOf(l))
        CArray::SetValueL(*topo\faces,id+2,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TEAPOT)+t*3*SizeOf(l)+SizeOf(l))
        CArray::SetValueL(*topo\faces,id+1,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TEAPOT)+t*3*SizeOf(l)+2*SizeOf(l))
        CArray::SetValueL(*topo\faces,id,l)
      Next i
      
      CArray::SetValueL(*topo\faces,id+3,-2)
      id+4
    Next t
    *topo\dirty = #True
  EndProcedure
  
  ; ---------------------------------------------------------
  ;     TORUS
  ; ---------------------------------------------------------
  Procedure Torus(*topo.Topology_t)
    Define v=0
    Define p.v3f32
    CArray::SetCount(*topo\vertices,Shape::#TORUS_NUM_VERTICES)
  
    CopyMemory(SHAPE::GetVertices(Shape::#SHAPE_TORUS),
               CArray::GetPtr(*topo\vertices,0),
               Shape::#TORUS_NUM_VERTICES * CArray::GetItemSize(*topo\vertices))
  
    
    Define i.i
    Define l.l
    CArray::SetCount(*topo\faces,Shape::#TORUS_NUM_INDICES+Shape::#TORUS_NUM_TRIANGLES)
    Define id=0
    Define t
    For t=0 To Shape::#TORUS_NUM_TRIANGLES-1
      For i=0 To 2
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(l))
        CArray::SetValueL(*topo\faces,id+2,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(l)+SizeOf(l))
        CArray::SetValueL(*topo\faces,id+1,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(l)+2*SizeOf(l))
        CArray::SetValueL(*topo\faces,id,l)
      Next i
      
      CArray::SetValueL(*topo\faces,id+3,-2)
      id+4
    Next t
    *topo\dirty = #True
  EndProcedure
 
  
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 460
; FirstLine = 456
; Folding = -----
; EnableXP
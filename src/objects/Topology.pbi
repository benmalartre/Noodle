XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Utils.pbi"
XIncludeFile "../objects/Geometry.pbi"

;========================================================================================
; Topology Module Declaration
;========================================================================================
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
EndDeclareModule

;========================================================================================
; Topology Module Implementation
;========================================================================================
Module Topology
  UseModule Geometry
  
  ;----------------------------------------------------------------------------
  ; Destuctor
  ;----------------------------------------------------------------------------
  Procedure Delete(*Me.Topology_t)
    CArray::Delete(*Me\vertices)
    CArray::Delete(*Me\faces)
    ClearStructure(*Me,Topology_t)
    FreeMemory(*Me)
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ;  Constructor
  ;----------------------------------------------------------------------------
  Procedure.i New(*other.Topology_t = #Null)
    ; Allocate Memory
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
  ;  Set
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
  ;  Update
  ; ----------------------------------------------------------------------------
  Procedure Update(*topo.Topology_t,*vertices.CArray::CArrayV3F32) 
    If CArray::GetCount(*vertices)>0 And *vertices\itemCount = *topo\vertices\itemCount
      CArray::Copy(*topo\vertices,*vertices)
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Clear
  ; ----------------------------------------------------------------------------
  Procedure Clear(*topo.Topology_t)
    CArray::SetCount(*topo\vertices,0)
    CArray::SetCount(*topo\faces,0)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Copy
  ; ----------------------------------------------------------------------------
  Procedure Copy(*topo.Topology_t,*other.Topology_t)
    Set(*topo,*other\vertices,*other\faces)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Transform
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
  ;  Transform Array
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
  
  
  ;-----------------------------------------------------------------------------
  ; Merge
  ;-----------------------------------------------------------------------------
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
  
  ;-------------------------------------------------------------------------------
  ; Merge In Place
  ;-------------------------------------------------------------------------------
  Procedure MergeInPlace(*t.Topology_t,*o.Topology_t)
    Protected f1 = CArray::GetCount(*t\faces)
    Protected f2 = CArray::GetCount(*o\faces)
    Protected v1 = CArray::GetCount(*t\vertices)
    Protected v2 = CArray::GetCount(*o\vertices)
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
  
  ;---------------------------------------------------------------------------------
  ; Merge Array
  ;--------------------------------------------------------------------------------- 
  Procedure MergeArray(*o.Topology_t,*topos.CArray::CArrayPtr)
    Protected nbt = CArray::GetCount(*topos)

    Protected Dim v_offsets(nbt)
    Protected Dim f_offsets(nbt)
    Protected Dim f_counts(nbt)
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
  
  ; ----------------------------------------------------------------------------
  ;  Extrusion
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
        Utils::TransformPositionArray(*oP,*section,*m)
    
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
        Utils::TransformPositionArray(*oP,*section,*m)
    
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
          CArray::AppendL(*extrusion\faces,cnt+so               )
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
  ;  Cap
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
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 67
; FirstLine = 58
; Folding = ---
; EnableXP
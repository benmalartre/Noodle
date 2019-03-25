XIncludeFile "../../core/Array.pbi"
XIncludeFile "../../core/Memory.pbi"
XIncludeFile "../../core/Time.pbi"

Procedure TestCopyArray(*src.CArray::CArrayT, *dst.CArray::CArrayT, useSSE.b = #False)
  
  If *src\itemCount 
    If *dst\data
      *dst\data = Memory::ReAllocateAlignedMemory(*dst\data, CArray::GetSize(*dst), CArray::GetSize(*src))
    Else
      *dst\data = Memory::AllocateAlignedMemory(CArray::GetSize(*src))
    EndIf 
  Else
    If *dst\data
      *dst\data = Memory::FreeAlignedMemory(*dst\data, CArray::GetSize(*dst))
      *dst\data = #Null
    EndIf 
    *dst\type = *src\type
    *dst\itemCount = 0
    ProcedureReturn
  EndIf
  *dst\type = *src\type
  *dst\itemCount = *src\itemCount
  
  If useSSE:
    Define 
    Define itemcount = *src\itemCount
    Define itemsize = *src\itemSize
    Define *srcdata = *src\data
    Define *dstdata = *dst\data

    ! mov rsi, [p.p_srcdata]          ; rsi = pointer To source Data
    ! mov rdi, [p.p_dstdata]          ; rdi = pointer To dest         
    ! mov rcx,[p.v_itemcount]         ; rcx = element count
    
    ;  now we can start moving 
    ! xor r8, r8                      ; rbx =0
    ! add rax,8                       ; rax = @data
    ! @@loop:
    !   mov rax,[rsi+r8]               ; get Data from source
    !   mov [rdi+r8], rsi              ; copy it To dest
    !   add r8, 8                      ; 8 bytes at a time
    !   dec rcx                        ; is rbx> number of bytes?
    !   jnz @@loop 
    ; Done copying.

;     Select *src\type
;       Case CArray::#ARRAY_BOOL
;         
;       Case CArray::#ARRAY_FLOAT
;         ! mov rdi, [p.p_dstdata]
;         ! mov rsi, [p.p_srcdata]
;         ! mov rcx, [p.v_itemcount]
;         ! loop_copy_memory_float:
;         !   movups xmm0, [rsi]
;         !   movups [rdi], xmm0
;         !   add rsi, 4
;         !   add rdi, 4
;         !   dec rcx
;         !   jnz loop_copy_memory_float
;         ProcedureReturn
;         
;       Case CArray::#ARRAY_LONG
;         ! mov rdi, [p.p_dstdata]
;         ! mov rsi, [p.p_srcdata]
;         ! mov rcx, [p.v_itemcount]
;         ! loop_copy_memory_long:
;         !   movdqu xmm0, [rsi]
;         !   movdqu [rdi], xmm0
;         !   add rsi, 4
;         !   add rdi, 4
;         !   dec rcx
;         !   jnz loop_copy_memory_long
;         ProcedureReturn
;         
;       Case CArray::#ARRAY_V3F32
;         ! mov rdi, [p.p_dstdata]
;         ! mov rsi, [p.p_srcdata]
;         ! mov rcx, [p.v_itemcount]
;         ! loop_copy_memory_v3f32:
;         !   movaps xmm0, [rsi]
;         !   movaps [rdi], xmm0
;         !   add rsi, 16
;         !   add rdi, 16
;         !   dec rcx
;         !   jnz loop_copy_memory_v3f32
; 
;         ProcedureReturn
;     EndSelect    
  Else
    CopyMemory(*src\data, *dst\data, CArray::GetSize(*src))
  EndIf
EndProcedure


Procedure.f CompareArray(*A.CArray::CArrayT, *B.CArray::CArrayT)
  Define maxError.f = 0
  If *A\itemCount <> *B\itemCount Or *A\itemSize <> *B\itemSize
    ProcedureReturn -1
  EndIf
  
  Define error.f = -1
  For i = 0 To CArray::GetCount(*A)-1
    error = Abs(PeekF(*A\data + i * SizeOf(Math::v3f32) ) - PeekF(*B\data + i * SizeOf(Math::v3f32) ))
    Debug error
    If error > maxError : maxError = error : EndIf
    error = Abs(PeekF(*A\data + i * SizeOf(Math::v3f32) +4) - PeekF(*B\data + i * SizeOf(Math::v3f32) +4 ))
    Debug error
    If error > maxError : maxError = error : EndIf
    error = Abs(PeekF(*A\data + i * SizeOf(Math::v3f32) +8) - PeekF(*B\data + i * SizeOf(Math::v3f32) +8))
    Debug error
    If error > maxError : maxError = error : EndIf
;     error = Abs(PeekF(*A\data + i * SizeOf(Math::v3f32) +12) - PeekF(*B\data + i * SizeOf(Math::v3f32) +12))
;     Debug error
;     If error > maxError : maxError = error : EndIf
  Next
  ProcedureReturn maxError
EndProcedure

Time::Init()

Define nb = 12800000
Define *A.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
CArray::SetCount(*A, nb)
Define *p.Math::v3f32
For i=0 To nb-1
  *p = CArray::GetValue(*A, i)
  *p\x = Math::Random_0_1()
  *p\y = Math::Random_0_1()
  *p\z = Math::Random_0_1()
Next

Define *B.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
Define *C.CArray::CArrayV3F32 = CArray::newCArrayV3F32()

Define startT.d=Time::Get()
TestCopyArray(*A, *B, #False)
Define elapsed1.d = Time::Get() - startT

Define startT.d=Time::Get()
TestCopyArray(*A, *C, #True)
Define elapsed2.d = Time::Get() - startT


MessageRequester("COPY", StrD(elapsed1)+", "+StrD(elapsed2)+": MAX DIFFERENCE : "+StrF(CompareArray(*B, *C)))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 25
; Folding = -
; EnableXP
XIncludeFile "../../core/Time.pbi"

Time::Init()

Macro MyCopyMemory(in,out,length)
  EnableASM
  MOV rax, in
  MOV rdi, out
  MOV rcx, length
  DisableASM
! loop_copy_memory:
!   movups xmm0,[rax]
!   movups [rdi],xmm0
!   add rax,16
!   add rdi,16
!   dec rcx
!   jg loop_copy_memory
EndMacro

Macro MyCopyMemoryAligned(in,out,length)
EnableASM
  MOV rax, in
  MOV rdi, out
  MOV rcx, length
  DisableASM
!  xor r9, r9
! loop_copy_memory_aligned:
!   movaps xmm0, [rax + r9]
!   movaps [rdi + r9], xmm0
!   add r9, 16
!   dec rcx
!   jg loop_copy_memory_aligned
EndMacro


#Count=5000
#Size= 1024*1024
mem1=AllocateMemory(#Size+15)
mem2=AllocateMemory(#Size+15)
mem1=mem1+(16-(mem1%16))
mem2=mem2+(16-(mem2%16))


qTimeA.d=0
qTimeZ.d=0

qTimeA = Time::Get()
For i=0 To #Count
  CopyMemory(mem1,mem2,#Size)
Next  
qTimeZ = Time::Get()

qTime1.d=qTimeZ-qTimeA


qTimeA = Time::Get()
For i=0 To #Count
  CopyMemory_(mem2,mem1,#Size)
Next  
qTimeZ = Time::Get()
qTime2.d=qTimeZ-qTimeA


l=#Size/16

qTimeA = Time::get()
For i=0 To #Count
  MyCopyMemory(mem1,mem2,l)
Next  
qTimeZ = Time::Get()
qTime3.d=qTimeZ-qTimeA


qTimeA = Time::get()
For i=0 To #Count
  MyCopyMemoryAligned(mem1,mem2,l)
Next  
qTimeZ = Time::Get()
qTime4.d=qTimeZ-qTimeA


MessageRequester("CopyMemory test","CopyMemory : "+ StrD(qTime1)+Chr(10)+
                                   "CopyMemory_ : "+ StrD(qTime2)+Chr(10)+
                                   "SSE : "+ StrD(qTime3)+Chr(10)+
                                   "SSE_Aligned : "+ StrD(qTime4))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 36
; FirstLine = 5
; Folding = -
; EnableXP
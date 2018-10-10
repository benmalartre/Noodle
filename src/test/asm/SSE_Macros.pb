;////////////////////////////////////////////////////////////////
;//
;// Filename: SSE.pbi
;// Version: 1.0.0.0
;// Date: 10-19-06
;// Author: Steven (Dreglor) Garcia
;//
;////////////////////////////////////////////////////////////////

;
;This Include is handy tool for any SSE and/or SSE2 programmer it wraps the more useful SSE instructions to simple macros
;and procedures. It also includes some procedures that helpful when using SSE instructions.
;don't forget to enable inline ASM before compiling
;

;-Structures

;
;SSE Registers are 128 bit wide, they can be cut up in 2 ways so that muiltable data can fit inside the same register
;4 floats Or 2 doubles. this data can be operated on all at once, making it nice to get alot of stuff done quickly
;Note: That these structures self align some times but not always but it is a good idea to assume that there are not either poke them into
;the SSE register (which is slower then if pushed).
;

Structure SSE32 ;SSE, for 32 bit Handling
  StructureUnion
    Float1.f ;For set data
    x.f ;For vectors
    r.f ;For colors
  EndStructureUnion
  StructureUnion
    Float2.f
    y.f
    g.f
  EndStructureUnion
  StructureUnion
    Float3.f
    z.f
    b.f
  EndStructureUnion
  StructureUnion
    Float4.f
    w.f
    a.f
  EndStructureUnion
EndStructure

Structure SSE64 ;SSE2, for 64 bit Handling
  StructureUnion
    Double1.d ;For set data
  EndStructureUnion
  StructureUnion
    Double2.d
  EndStructureUnion
EndStructure

Structure SSE ;All-Purpose SSE Access
  StructureUnion
    Fields8.SSE64 ;it would be easier if we could nest structure unions
    Fields4.SSE32
  EndStructureUnion
EndStructure

;- Macros

;Force a pointer To be 16 byte Aligned
Macro Align16(pointer)
  (((pointer) + 15) &~ $0F)
EndMacro

Macro FreeAlignedMemory(MemoryBlock, Size)
  FreeMemory(MemoryBlock - PeekB(MemoryBlock + Size + 1))
EndMacro

;Tranportation of SSE data
;Must be a Aligned Pointer
Macro PushSSE(SSEVariable, Register = 0) ;A fast version of PokeSSE
  EnableASM
  MOV rax, SSEVariable
  DisableASM
  !movaps xmm#Register, [rax]
EndMacro

Macro PopSSE(SSEVariable, Register = 0) ;A fast version of PeekSSE
  EnableASM
  MOV rax, SSEVariable
  DisableASM
  !movaps [rax], xmm#Register
EndMacro

;If The Variable is not a direct pointer then you will have to use these
Macro PushSSEClean(SSEVariable, Register = 0) ;A fast version of PokeSSE
  _Pointer = SSEVariable
  EnableASM
  MOV rax, _Pointer
  DisableASM
  !movaps xmm#Register, [rax]
EndMacro

Macro PopSSEClean(SSEVariable, Register = 0) ;A fast version of PeekSSE
  _Pointer = SSEVariable
  EnableASM
  MOV rax, _Pointer
  DisableASM
  !movaps [rax], xmm#Register
EndMacro

;the pointer doesn't have to be aligned
Macro PokeSSE(SSEVariable, Register = 0)
  EnableASM
  MOV rax, SSEVariable
  DisableASM
  !movups xmm#Register, [rax]
EndMacro

Macro PeekSSE(SSEVariable, Register = 0)
  EnableASM
  MOV rax, SSEVariable
  DisableASM
  !movups [rax], xmm#Register
EndMacro

;If The Variable is not a direct pointer then you will have to use these
Macro PokeSSEClean(SSEVariable, Register = 0)
  _Pointer = SSEVariable
  EnableASM
  MOV rax, _Pointer
  DisableASM
  !movups xmm#Register, [rax]
EndMacro

Macro PeekSSEClean(SSEVariable, Register = 0)
  _Pointer = SSEVariable
  EnableASM
  MOV rax, _Pointer
  DisableASM
  !movups [rax], xmm#Register
EndMacro

;the many ways to move data
;the low high stuff is really reversed here to make the SSE Structure correct when operating
;with low and high
Macro CopySSE(SourceRegister, DestinationRegister)
  !movaps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro CopyLowSSE(SourceRegister, DestinationRegister)
  !movhps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro CopyHighSSE(SourceRegister, DestinationRegister)
  ;movsd dst, src
  !movlps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro CopyLowToHighSSE(SourceRegister, DestinationRegister)
  !movhlps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro CopyHighToLowSSE(SourceRegister, DestinationRegister)
  !movlhps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro InterweaveFromLowSSE(SourceRegister, DestinationRegister)
  !unpckhps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro InterweaveFromHighSSE(SourceRegister, DestinationRegister)
  !unpcklps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro ShuffleSSE(SourceRegister, DestinationRegister, ShuffleMask) ;use binary (no % prefix)
  !shufps xmm#DestinationRegister, xmm#DestinationRegister, ShuffleMask#b
EndMacro

Macro BroadcastSSEFloat1(SourceRegister, DestinationRegister)
  !movaps xmm#DestinationRegister, xmm#SourceRegister
  ShuffleSSE(DestinationRegister, DestinationRegister, 00000000)
EndMacro

Macro BroadcastSSEFloat2(SourceRegister, DestinationRegister)
  !movaps xmm#DestinationRegister, xmm#SourceRegister
  ShuffleSSE(DestinationRegister, DestinationRegister, 01010101)
EndMacro

Macro BroadcastSSEFloat3(SourceRegister, DestinationRegister)
  !movaps xmm#DestinationRegister, xmm#SourceRegister
  ShuffleSSE(DestinationRegister, DestinationRegister, 10101010)
EndMacro

Macro BroadcastSSEFloat4(SourceRegister, DestinationRegister)
  !movaps xmm#DestinationRegister, xmm#SourceRegister
  ShuffleSSE(DestinationRegister, DestinationRegister, 11111111)
EndMacro

;here are some useful debugging procedures
Macro DebugSSERegisterAsFloat(Register = 0)
  _TempDebug32.SSE32
  PopSSEClean(_TempDebug32, Register)
  Debug StrF(_TempDebug32\Float1) + ", " + StrF(_TempDebug32\Float2) + ", " + StrF(_TempDebug32\Float3) + ", " + StrF(_TempDebug32\Float4)
EndMacro

Macro DebugSSERegisterAsDouble(Register = 0)
  _TempDebug64.SSE64
  PopSSEClean(_TempDebug64, Register)
  Debug StrD(_TempDebug64\Double1) + ", " +StrD(_TempDebug64\Double2)
EndMacro

;
;The Entire Instruction set is not represented here nor is it as flexable as writing them by hand
;the instructions take only 2 parameters; Destination and Source. the source register can an address
;pointer but these macros don't allow that to make it easier it will be couple cycles longer to push
;then operate on the Register
;please not that what ever is in DestinationRegister will be destroyed and be over written with the result
;

;SSE Instructions
;Arithmetic
Macro AddSingleFloat(SourceRegister, DestinationRegister)
  !addss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SubtractSingleFloat(SourceRegister, DestinationRegister)
  !subss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MulitplySingleFloat(SourceRegister, DestinationRegister)
  !mulss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro DivideSingleFloat(SourceRegister, DestinationRegister)
  !divss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SqrSingleFloat(SourceRegister, DestinationRegister)
  !sqrtss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MaximizeSingleFloat(SourceRegister, DestinationRegister)
  !maxss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MinimizeSingleFloat(SourceRegister, DestinationRegister)
  !minss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro AddFloats(SourceRegister, DestinationRegister)
  !addps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SubtractFloats(SourceRegister, DestinationRegister)
  !subps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MulitplyFloats(SourceRegister, DestinationRegister)
  !mulps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro DivideFloats(SourceRegister, DestinationRegister)
  !divps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SqrFloats(SourceRegister, DestinationRegister)
  !sqrtps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MaximizeFloats(SourceRegister, DestinationRegister)
  !maxps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MinimizeFloats(SourceRegister, DestinationRegister)
  !minps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

;Recipicol
Macro RcpSingleFloat(SourceRegister, DestinationRegister)
  !rcpss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro RSqrSingleFloat(SourceRegister, DestinationRegister)
  !rsqrtss xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro RcpFloats(SourceRegister, DestinationRegister)
  !rcpps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro RcpSqrFloats(SourceRegister, DestinationRegister)
  !rsqrtps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro CompareIsEqualSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 0
EndMacro

Macro CompareIsLesserSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 1
EndMacro

Macro CompareIsLesserOrEqualSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 2
EndMacro

Macro CompareIsUnorderedSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 3
EndMacro

Macro CompareIsNotEqualSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 4
EndMacro

Macro CompareIsNotLesserSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 5
EndMacro

Macro CompareIsNotLesserOrEqualSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 6
EndMacro

Macro CompareIsOrderedSingleFloat(SourceRegister, DestinationRegister)
  !cmpss xmm#DestinationRegister, xmm#SourceRegister, 7
EndMacro

Macro CompareIsEqualFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 0
EndMacro

Macro CompareIsLesserFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 1
EndMacro

Macro CompareIsLesserOrEqualFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 2
EndMacro

Macro CompareIsUnorderedFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 3
EndMacro

Macro CompareIsNotEqualFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 4
EndMacro

Macro CompareIsNotLesserFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 5
EndMacro

Macro CompareIsNotLesserOrEqualFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 6
EndMacro

Macro CompareIsOrderedFloats(SourceRegister, DestinationRegister)
  !cmpps xmm#DestinationRegister, xmm#SourceRegister, 7
EndMacro

Macro AndSSE(SourceRegister, DestinationRegister) ;Operates on all 128bits
  !andps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro NandSSE(SourceRegister, DestinationRegister) ;Operates on all 128bits
  !andnps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro OrSSE(SourceRegister, DestinationRegister) ;Operates on all 128bits
  !orps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro XorSSE(SourceRegister, DestinationRegister) ;Operates on all 128bits
  !xorps xmm#DestinationRegister, xmm#SourceRegister
EndMacro

;SSE2 Instructions
;Arithmetic
Macro AddSingleDouble(SourceRegister, DestinationRegister)
  !addsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SubtractSingleDouble(SourceRegister, DestinationRegister)
  !subsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MulitplySingleDouble(SourceRegister, DestinationRegister)
  !mulsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro DivideSingleDouble(SourceRegister, DestinationRegister)
  !divsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SqrSingleDouble(SourceRegister, DestinationRegister)
  !sqrtsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MaximizeSingleDouble(SourceRegister, DestinationRegister)
  !maxsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MinimizeSingleDouble(SourceRegister, DestinationRegister)
  !minsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro AddDoubles(SourceRegister, DestinationRegister)
  !addpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SubtractDoubles(SourceRegister, DestinationRegister)
  !subpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MulitplyDoubles(SourceRegister, DestinationRegister)
  !mulpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro DivideDoubles(SourceRegister, DestinationRegister)
  !divpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro SqrDoubles(SourceRegister, DestinationRegister)
  !sqrtpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MaximizeDoubles(SourceRegister, DestinationRegister)
  !maxpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro MinimizeDoubles(SourceRegister, DestinationRegister)
  !minpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

;Recipicol
Macro RcpSingleDouble(SourceRegister, DestinationRegister)
  !rcpsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro RSqrSingleDouble(SourceRegister, DestinationRegister)
  !rsqrtsd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro RcpDoubles(SourceRegister, DestinationRegister)
  !rcppd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

Macro RcpSqrDoubles(SourceRegister, DestinationRegister)
  !rsqrtpd xmm#DestinationRegister, xmm#SourceRegister
EndMacro

;Logical

Macro CompareIsEqualSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 0
EndMacro

Macro CompareIsLesserSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 1
EndMacro

Macro CompareIsLesserOrEqualSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 2
EndMacro

Macro CompareIsUnorderedSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 3
EndMacro

Macro CompareIsNotEqualSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 4
EndMacro

Macro CompareIsNotLesserSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 5
EndMacro

Macro CompareIsNotLesserOrEqualSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 6
EndMacro

Macro CompareIsOrderedSingleDouble(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 7
EndMacro

Macro CompareIsEqualDoubles(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 0
EndMacro

Macro CompareIsLesserDoubles(SourceRegister, DestinationRegister)
  !cmpsd xmm#DestinationRegister, xmm#SourceRegister, 1
EndMacro

Macro CompareIsLesserOrEqualDoubles(SourceRegister, DestinationRegister)
  !cmppd xmm#DestinationRegister, xmm#SourceRegister, 2
EndMacro

Macro CompareIsUnorderedDoubles(SourceRegister, DestinationRegister)
  !cmppd xmm#DestinationRegister, xmm#SourceRegister, 3
EndMacro

Macro CompareIsNotEqualDoubles(SourceRegister, DestinationRegister)
  !cmppd xmm#DestinationRegister, xmm#SourceRegister, 4
EndMacro

Macro CompareIsNotLesserDoubles(SourceRegister, DestinationRegister)
  !cmppd xmm#DestinationRegister, xmm#SourceRegister, 5
EndMacro

Macro CompareIsNotLesserOrEqualDoubles(SourceRegister, DestinationRegister)
  !cmppd xmm#DestinationRegister, xmm#SourceRegister, 6
EndMacro

Macro CompareIsOrderedDoubles(SourceRegister, DestinationRegister)
  !cmppd xmm#DestinationRegister, xmm#SourceRegister, 7
EndMacro

Macro ShiftLeftSSE(SourceRegister, Value) ;Operates on all 128bits
  !pslldq xmm#DestinationRegister, Value
EndMacro

Macro ShiftRightSSE(SourceRegister, Value) ;Operates on all 128bits
  !psrldq xmm#DestinationRegister, Value
EndMacro

;- Procedures

Procedure IsAligned(pointer)
  If pointer % 16 = 0
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; 
;Because allocating memory and aligning it causes memory leaks when freed later,
;This is one way of handling 16 byte aligned memory blocks, althought proably not the best way to do so,
;what it does is it allocates memory with a 16 bytes extra then it aligns the memory block.
;it will always have at least one byte at the end of the memory block this is where the offset is stored
;so when we go to free the memory block it will read the ending byte push the pointer back to the orignal
;pointer was and free from there other wise it will free the aligned block and leave up to 15 bytes
;this may not seam like a lot but when you have alot of this happing the left overs stack up
;and it is not good practice to leave leaks such as theses.
;

Procedure AllocateAlignedMemory(Size.l)
  pointer = AllocateMemory(Size + 16)
  ReturningPointer = Align16(pointer)
  PokeB(ReturningPointer + Size + 1, (pointer % 16))
  ProcedureReturn ReturningPointer
EndProcedure

Procedure ReAllocateAlignedMemory(MemoryBlock.l, Size.l)
  pointer = ReAllocateMemory(MemoryBlock, Size + 16)
  ReturningPointer = Align16(pointer)
  PokeB(ReturningPointer + Size + 1, pointer % 16)
  ProcedureReturn ReturningPointer
EndProcedure

;Instruction Set Checks
Procedure CheckSSE()
  FeatureFlags.i
  !MOV rax, 1
  !CPUID
  !MOV p.v_FeatureFlags, rdx
  ProcedureReturn (FeatureFlags >> 25) & 1
EndProcedure

Procedure CheckSSE2()
  FeatureFlags.i
  !MOV rax, 1
  !CPUID
  !MOV p.v_FeatureFlags, rdx
  ProcedureReturn (FeatureFlags >> 26) & 1
EndProcedure 















;SSE Example

;IncludeFile "SSE.pbi"

Structure MatrixRow
  Col.f[4]
EndStructure

Structure Matrix
  Row.MatrixRow[4]
EndStructure

Structure Vector
  x.f
  y.f
  z.f
  w.f
EndStructure

;matrix is represented as such
;  c1  c2  c3  c4
;r1 0   0   0   0
;r2 0   0   0   0
;r3 0   0   0   0
;r4 0   0   0   0
;

;Matrix Transform

;PureBasic method
Procedure MatrixTransformPB(*Matrix.Matrix, *Vector.Vector, *Output.Vector)
  ;Nothing special here
  *Output\x = *Matrix\Row[0]\Col[0] * *Vector\x + *Matrix\Row[0]\Col[1] * *Vector\y + *Matrix\Row[0]\Col[2] * *Vector\z + *Matrix\Row[0]\Col[3] * *Vector\w
  *Output\y = *Matrix\Row[1]\Col[0] * *Vector\x + *Matrix\Row[1]\Col[1] * *Vector\y + *Matrix\Row[1]\Col[2] * *Vector\z + *Matrix\Row[1]\Col[3] * *Vector\w
  *Output\z = *Matrix\Row[2]\Col[0] * *Vector\x + *Matrix\Row[2]\Col[1] * *Vector\y + *Matrix\Row[2]\Col[2] * *Vector\z + *Matrix\Row[2]\Col[3] * *Vector\w
  *Output\w = *Matrix\Row[3]\Col[0] * *Vector\x + *Matrix\Row[3]\Col[1] * *Vector\y + *Matrix\Row[3]\Col[2] * *Vector\z + *Matrix\Row[3]\Col[3] * *Vector\w
EndProcedure

Procedure MatrixTransformSSE(*Matrix.Matrix, *Vector.Vector, *Output.Vector)
  ;
  ;I am no SSE wizard I have to look up 90% of the instructions to make sure what there doing it correct
  ;so this is possabily the worst way about doing this but, still, obtaining ~70% increase is impressive
  ;if you want to redo this procedure the correct way and get the best out of SSE the look no further than here
  ;http://www.cortstratton.org/articles/OptimizingForSSE.php
  ;


  PushSSEClean(*Matrix\Row[0], 0)
  PushSSEClean(*Matrix\Row[1], 1)
  PushSSEClean(*Matrix\Row[2], 2)
  PushSSEClean(*Matrix\Row[3], 3)

  PushSSE(*Vector, 4)

  ;Muiltiply the vector to the matrix rows
  MulitplyFloats(4, 0)
  MulitplyFloats(4, 1)
  MulitplyFloats(4, 2)
  MulitplyFloats(4, 3)

  ;add up the rows
  CopySSE(0, 4)
  ShuffleSSE(4, 0, 01001110)
  AddFloats(4, 0)
  CopySSE(0, 4)
  ShuffleSSE(4, 0, 00010001)
  AddFloats(4, 0)

  CopySSE(1, 4)
  ShuffleSSE(4, 1, 01001110)
  AddFloats(4, 1)
  CopySSE(1, 4)
  ShuffleSSE(4, 1, 00010001)
  AddFloats(4, 1)

  CopySSE(2, 4)
  ShuffleSSE(4, 2, 01001110)
  AddFloats(4, 2)
  CopySSE(2, 4)
  ShuffleSSE(4, 2, 00010001)
  AddFloats(4, 2)

  CopySSE(3, 4)
  ShuffleSSE(4, 3, 01001110)
  AddFloats(4, 3)
  CopySSE(3, 4)
  ShuffleSSE(4, 3, 00010001)
  AddFloats(4, 3)

  ;mash the rows sum of the rows into once SSE register
  CopySSE(0, 4)
  CopySSE(2, 5)
  InterweaveFromLowSSE(1, 4)
  InterweaveFromLowSSE(3, 5)
  CopyHighSSE(4, 5)
  PopSSE(*Output, 5)
EndProcedure


;check to see if SSE is available if not end the program
If CheckSSE() = #False
  MessageRequester("Error", "SSE Instructions where not detected on this computer and are needed", #MB_ICONERROR)
  End
EndIf

;for the older hardware users,
;if SSE2 is not available then just show a message (because it isn't required to run this example)
If CheckSSE2() = #False
  MessageRequester("Info", "SSE Instructions where not detected on this computer but are not needed", #MB_ICONWARNING)
EndIf

;set up the test values
*TestMatrix.Matrix = AllocateAlignedMemory(SizeOf(Matrix))
*TestMatrix\Row[0]\Col[0] = 1
*TestMatrix\Row[0]\Col[1] = 2
*TestMatrix\Row[0]\Col[2] = 3
*TestMatrix\Row[0]\Col[3] = 4

*TestMatrix\Row[1]\Col[0] = 5
*TestMatrix\Row[1]\Col[1] = 6
*TestMatrix\Row[1]\Col[2] = 7
*TestMatrix\Row[1]\Col[3] = 8

*TestMatrix\Row[2]\Col[0] = 9
*TestMatrix\Row[2]\Col[1] = 10
*TestMatrix\Row[2]\Col[2] = 11
*TestMatrix\Row[2]\Col[3] = 12

*TestMatrix\Row[3]\Col[0] = 13
*TestMatrix\Row[3]\Col[1] = 14
*TestMatrix\Row[3]\Col[2] = 15
*TestMatrix\Row[3]\Col[3] = 16

*TestVector.Vector = AllocateAlignedMemory(SizeOf(Vector))
*TestVector\x = 1
*TestVector\y = 2
*TestVector\z = 3
*TestVector\w = 4

*Output.Vector = AllocateAlignedMemory(SizeOf(Vector))

startPB = ElapsedMilliseconds()
For i=0 To 100000000
  MatrixTransformPB(*TestMatrix, *TestVector, *Output)
Next
EndPB = ElapsedMilliseconds()

startSSE = ElapsedMilliseconds()
For i=0 To 100000000
  MatrixTransformSSE(*TestMatrix, *TestVector, *Output)
Next
EndSSE = ElapsedMilliseconds()

;it is good practice to free allocated memory before ending the program
FreeAlignedMemory(*TestMatrix, SizeOf(Matrix))
FreeAlignedMemory(*TestVector, SizeOf(Vector))
FreeAlignedMemory(*Output, SizeOf(Vector))

;show the advatage SSE has
MessageRequester("Info","Purebasic Timming: " + Str(EndPB - startPB) + Chr(10) + "SSE Timming: " + Str(EndSSE - startSSE))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 151
; FirstLine = 142
; Folding = ------------------
; EnableXP
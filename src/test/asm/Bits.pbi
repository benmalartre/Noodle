DeclareModule Bits
EnableASM
CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
   Macro SetBit(Integer,bit)
      MOV eax, Integer
      MOV ebx, bit
      BTS eax, ebx
      MOV Integer,eax
   EndMacro
   
   Macro ResetBit(Integer,bit)
      MOV eax, Integer
      MOV ebx, bit
      BTR eax, ebx
      MOV Integer,eax
   EndMacro
   
   Macro ToggleBit(Integer,bit)
      MOV eax, Integer
      MOV ebx, bit
      BTC eax,ebx
      MOV Integer, eax
   EndMacro
   
   Procedure.b GetBit(Integer, bit)
      MOV ebx, bit
      BT Integer, ebx
      SETC al
      ProcedureReturn
   EndProcedure
   
   Macro ReadBit(Integer, bit,Result)
      MOV ebx, bit
      BT Integer, ebx
      SETC al
      MOV Result,al
   EndMacro
   
CompilerElse
   
   Macro SetBit(Integer,bit)
      MOV rax, Integer
      MOV rbx, bit
      BTS rax, rbx
      MOV Integer,rax
   EndMacro
   
   Macro ResetBit(Integer,bit)
      MOV rax, Integer
      MOV rbx, bit
      BTR rax, rbx
      MOV Integer,rax
   EndMacro
   
   Macro ToggleBit(Integer,bit)
      MOV rax, Integer
      MOV rbx, bit
      BTC rax,rbx
      MOV Integer, rax
   EndMacro
         
   Macro ReadBit(Integer, bit,Result)
      MOV rbx, bit
      BT Integer, rbx
      SETC al
      MOV Result,al
   EndMacro
   DisableASM
   Declare.b GetBit(Integer, bit)
   
 CompilerEndIf
EndDeclareModule

Module Bits
  EnableASM
  Procedure.b GetBit(Integer, bit)
    MOV rbx, bit
    BT Integer, rbx
    SETC al
    ProcedureReturn
  EndProcedure
  DisableASM
    
EndModule

Define x.i
EnableASM
For i = 0 To 63
  If Random(1000) > 500
    Bits::SetBit(x,i)
  Else
    Bits::ResetBit(x, i)
  EndIf
Next
DisableASM
Debug Bin(x)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 86
; FirstLine = 39
; Folding = ---
; EnableXP
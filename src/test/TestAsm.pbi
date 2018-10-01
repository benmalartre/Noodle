XIncludeFile "E:\Projects\RnD\Noodle\src\core\Time.pbi"

#NUM_POINTS = 10000000

Procedure PBLoop()

Define.d T = Time::Get()
Define x, y, i
For i = 0 To #NUM_POINTS
  x+i
Next

MessageRequester("TOOK", StrD(Time::Get()- t)+" seconds : "+Str(x)+", "+Str(y))
EndProcedure

Procedure ASMLoop(numPoints.i)
  EnableASM
  Define.d T = Time::get()
  Define.i x, y, i =numPoints 
  x=0
  y=0
  
  !mov ecx, 0
  MOV qword eax, x
  !fuckinloop:
  ADD eax, ecx
  !inc ecx
  !cmp ecx, [p.v_numPoints]
  !jne fuckinloop
  MOV x, eax
  DisableASM
  
  MessageRequester("TOOK", StrD(Time::Get()- t)+" seconds : "+Str(x)+", "+Str(y))
EndProcedure


Time::Init()

PBLoop()
ASMLoop(#NUM_POINTS)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 23
; Folding = -
; EnableXP
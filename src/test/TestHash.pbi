XIncludeFile "../core/Time.pbi"


Structure CharArray 
  c.c[0] 
EndStructure 

Procedure Hash1(str.s)

  Protected hash = 5381
  Protected c
  Protected *a.CharArray
  Protected n = Len(str) - 1
  *a = @str
  
  For i = 0 To n:
    hash = ((hash << 5) + hash) + c
  Next
  ProcedureReturn hash
EndProcedure

Procedure Hash2(str.s)

  Protected hash = 5381
  Protected c
  Protected *a.CharArray
  Protected n = Len(str) - 1
  *a = @str
  
  For i = 0 To n:
     hash = hash * 33 + c 
  Next
  ProcedureReturn hash
EndProcedure


Time::Init()

Define z.s = "kgrzegrisxvqhswgdvksxz ebtuzabedtiazuegswkgndisyaCTXEIUAZWEQWBI<N6F IWUSXO7EwbtnetgqsnougkjqhdgxazuegqsukyfdisqvxckqK!uzôa>W?Elxqnf gondzqxelrynwqoi,x"
Define N = 1000000
Define i

Define *mem1 = AllocateMemory(N * #PB_Integer)
Define *mem2 = AllocateMemory(N * #PB_Integer)

Define.d s1 = Time::Get()
For i = 0 To N:
  PokeI(*mem1 + i * #PB_Integer, Hash1(z))
Next
Define.d e1 = Time::Get()

Define.d s2 = Time::Get()
For i = 0 To N:
  PokeI(*mem2 + i * #PB_Integer, Hash2(z))
Next
Define.d e2 = Time::Get()

MessageRequester("Shift vs Mul", StrD(e1 - s1) + " vs "+StrD(e2 - s2))

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 38
; Folding = -
; EnableXP
; EnableUnicode
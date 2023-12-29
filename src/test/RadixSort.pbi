#SIZE = 2048


Dim _data(#SIZE)

For i = 0 To #SIZE
  _data(i) = Random(2147483647)
Next

Macro _GetDigit(number, digit)
  Int(Mod(Round(number / Pow(10, digit), #PB_Round_Down), 10))
EndMacro

Procedure EchoArray(Array _data.i(1))
  For i = 0 To ArraySize(_data())
    Debug _data(i)
  Next  
EndProcedure

  
Procedure.i _GetMaxLength(Array _data.i(1))
  Define result.i = 0
  Define current.i
  For i = 0 To ArraySize(_data())
    current = Round(Log10(_data(i)) + 1, #PB_Round_Down)
    If current > result:
      result = current
    EndIf
  Next
  ProcedureReturn result
EndProcedure


Procedure CountSort(Array _data.i(1), e.i)
  Define n = ArraySize(_data())
  Dim output.i(n)
  Dim count(10)
  
  ; store occurence count
  For i = 0 To n : count((_data(i)/e)%10) + 1 : Next
  ; compute digit output position 
  For i = 1 To 9 : count(i) + count(i - 1) : Next 
  ; build output array
  For i = n To 0 Step -1 
    output(count((_data(i) / e) % 10) - 1) = _data(i)
    count((_data(i) / e) % 10) - 1
  Next
  ; update input array
  For i =0 To n : _data(i) = output(i) : Next
  
EndProcedure

Procedure RadixSort(Array _data(1))
  Define maxLength.i = _GetMaxLength(_data())
  For i = 0 To maxLength - 1
    CountSort(_data(), Int(Pow(10, i+1)))
  Next  
  
  
EndProcedure

Debug "--------------------"
EchoArray(_data())
RadixSort(_data.i())
Debug "--------------------"

EchoArray(_data())







; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 50
; FirstLine = 11
; Folding = -
; EnableXP
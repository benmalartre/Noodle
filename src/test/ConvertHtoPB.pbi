
Procedure.s ConvertH(filename.s)
  Protected file = ReadFile(#PB_Any, filename)
  If file
    Protected output.s = ""
    Protected line.s
    Protected cnt.i
    Protected replaced.s, field.s
    While Not Eof(file)
      line = ReadString(file)
      line = RTrim(line)
      cnt = CountString(line, ",")
      If Not Right(line, 1) = ","
        cnt + 1
      EndIf
      
      replaced = "Data.i "
      For i=1 To cnt
        field = StringField(line, i, ",")
        field = ReplaceString(field, "{","")
        field = ReplaceString(field, "}","")
        field = ReplaceString(field, "0x00", "$")+", "
        ;replaced + Str(Val(field)) + ", "
        replaced + field
      Next
      
      If Right(replaced, 1) = ","
        replaced = Left(replaced, Len(replaced)-1)
      EndIf
      
      output+replaced+Chr(10)
    Wend  
    ProcedureReturn output
  Else
    ProcedureReturn ""
  EndIf
 
EndProcedure


Define r.s = ConvertH("E:\Projects\RnD\Noodle\src\test\hilbert.txt")
Debug r
; file = ReadFile(#PB_Any, "E:\Projects\RnD\Noodle\src\test\polygonizer_table.txt")
; output.s = ""
; While Not Eof(file)
;   line.s = ReadString(file)
;   cnt.i = CountString(line, ",")
;   replaced.s = ""
;   For i=1 To cnt
;     h.s = StringField(line, i, ",")
;     h = LTrim(h)
;     h = RTrim(h)
;     h = ReplaceString(h, "0x", "$")
;     replaced + Str(Val(h))+", "
;   Next
;   replaced = RTrim(replaced)
;   If Right(replaced, 1) = ","
;     replaced = Left(replaced, Len(replaced)-1)
;   EndIf
;   
;   
;   output + "Data.i "+ replaced +Chr(10)
; Wend  
; 
; Debug output

; file = ReadFile(#PB_Any, "E:\Projects\RnD\Noodle\src\test\polygonizer_tri_table.txt")
; output.s = ""
; While Not Eof(file)
;   line.s = ReadString(file)
;   cnt.i = CountString(line, ",")
;   replaced.s = "Data.i "
;   For i=1 To cnt
;     field.s = StringField(line, i, ",")
;     field = ReplaceString(field, "{","")
;     field = ReplaceString(field, "}","")
;     replaced + Str(Val(field)) + ", "
;   Next
;   
; ;   replaced.s = ReplaceString(line, "{", "", #PB_String_CaseSensitive, 1, cnt)
; ;   cnt.i = CountString(line, "}")
; ;   replaced.s = ReplaceString(replaced, "}", "", #PB_String_CaseSensitive, 1, cnt)
;   replaced = RTrim(replaced)
;   If Right(replaced, 1) = ","
;     replaced = Left(replaced, Len(replaced)-1)
;   EndIf
;   
;   
;   output+replaced+Chr(10)
; Wend  
; 
; Debug output

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 15
; Folding = -
; EnableXP


Structure SQLFunction_t
  protoname.s
  funcname.s
  args.s
EndStructure

NewList functions.SQLFunction_t()

Procedure.s GetFunctionName(line.s)
  ProcedureReturn LTrim( StringField(line, 1, "("), " ")
EndProcedure

Procedure.s GetFunctionArgs(line.s)
  ProcedureReturn "("+RTrim( StringField(line, 2, "("), " ")
EndProcedure

Procedure.s GetProtoName(funcname.s)
  Define numUnderscore = CountString(funcname, "_")
  ProcedureReturn "PFN"+UCase(RemoveString(funcname,"_",#PB_String_CaseSensitive, 1, numUnderscore))
EndProcedure

If ReadFile(0, "E:\Projects\RnD\Noodle\src\datas\MySQLFunctions.txt")
  While Eof(0) = 0           ; Boucle tant que la fin du fichier n'est pas atteinte. (Eof = 'End Of File') 
    AddElement(functions())
    Define line.s = ReadString(0)      ; Affiche du fichier
    With functions()
      \funcname = GetFunctionName(line)
      \args = GetFunctionArgs(line)
      \protoname = GetProtoName(\funcname)
    EndWith
  Wend
  CloseFile(0)               ; Ferme le fichier précédemment ouvert
  
  file = OpenFile(#PB_Any, "E:\Projects\RnD\Noodle\src\datas\MySQLPBImport.txt")
  WriteStringN(file, "; PROTOTYPES")
  
  ForEach functions()
    WriteStringN(file, "PrototypeC "+functions()\protoname+functions()\args)
  Next
  
  WriteStringN(file, "; IMPORT")
  WriteStringN(file, "ImportC")
  ForEach functions()
    WriteStringN(file, "  Global "+functions()\funcname+"."+functions()\protoname+" = GetFunction(mySQLLib, "+Chr(34)+functions()\funcname+Chr(34)+")")
  Next
  WriteStringN(file, "EndImport")
  
  CloseFile(file)
Else
  Debug "File NOT Found!!"  
EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 39
; Folding = -
; EnableXP
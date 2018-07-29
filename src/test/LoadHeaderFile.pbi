Structure HBlock_t
  c_start.i 
  c_end.i
  isLeaf.b
  *parent.HBlock_t
  
EndStructure

Structure HLoader_t
  *buffer
  List lines.s()
  List *blocks.HBlock_t()
  *block.HBlock_t
  level.i
EndStructure

Procedure PrintBlock(*loader.HLoader_t, *block.HBlock_t)
  If *block\isLeaf
    Debug "### BLOCK"
    Debug PeekS(*block\c_start, *block\c_end - *block\c_start, #PB_UTF8)
  EndIf
  
EndProcedure


Procedure LoadHeaderFile(filename.s)
  Protected *loader.HLoader_t = AllocateMemory(SizeOf(HLoader_t))
  InitializeStructure(*loader, HLoader_t)
  *loader\block  =#Null
  
  Protected file = ReadFile(#PB_Any, filename)
  *loader\buffer = AllocateMemory(Lof(file))
  Protected *buffer.Byte = *loader\buffer
  Protected *base = *buffer
  Protected nbLines = 0
  Protected len.i = 0
  ReadData(file, *loader\buffer, Lof(file))
  While *buffer\b <> 0
    If *buffer\b = #LF
      AddElement(*loader\lines())
      *loader\lines() = PeekS(*base, len-1, #PB_UTF8)
      *base = *buffer+1
      nbLines+1
      len = 0
    ElseIf *buffer\b = 123
      Debug "Opening Block at "+Str(*buffer)
      Define *block.HBlock_t = AllocateMemory(SizeOf(HBlock_t))
      *block\isLeaf = #True
      *block\c_start = *buffer
      If *loader\block
        *loader\block\isLeaf = #False
        *block\parent = *loader\block
      Else
        *block\parent = #Null
      EndIf
      
      *loader\block = *block
      *loader\level + 1
      AddElement(*loader\blocks())
      *loader\blocks() = *block
    ElseIf *buffer\b = 125
      Debug "Closing Block at "+Str(*buffer)
      *loader\block\c_end = *buffer + 1
      *loader\block = *loader\block\parent
      *loader\level - 1
    EndIf
    *buffer+1
    len + 1
  Wend
  ProcedureReturn *loader
EndProcedure



 
Define filename.s = "E:\Projects\RnD\USD\pxr\base\lib\gf\camera.h"
Define *loader.HLoader_t = LoadHeaderFile(filename)

Debug ListSize(*loader\lines())

ForEach *loader\blocks()
  PrintBlock(*loader, *loader\blocks())
Next


;   *buffer.i = AllocateMemory(ReadData(Lof()))
; While *Buffer\b <> 0
;   If *Buffer\b = 10
;     NbLines+1
;   EndIf
;   *Buffer+1
; Wend
; FreeMemory(*Buffer)
; EndStructure
; 
; 
; Define filename.s = "E:\Projects\RnD\USD\pxr\base\lib\gf\camera.h"
; 
; If ReadFile(0, filename)   ; Si le fichier peut être lu , on continue...
;   
;     While Eof(0) = 0           ; Boucle tant que la fin du fichier n'est pas atteinte. (Eof = 'End Of File') 
;       Debug ReadString(0)      ; Affiche du fichier
;     Wend
;     CloseFile(0)               ; Ferme le fichier précédemment créé ou ouvert
;   Else
;     MessageRequester("Information","Impossible d'ouvrir le fichier!")
;   EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 24
; FirstLine = 6
; Folding = -
; EnableXP
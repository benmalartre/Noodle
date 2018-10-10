
Define folder.s = "E:/Projects/RnD/Noodle/src/test/asm/"
Define input_file.s = "UnalignedShapes.pbi"
Define output_file.s = "AlignedShapes.pbi"

NewList lines.s()
Define file = ReadFile(#PB_Any, folder+input_file, #PB_UTF8)
While Eof(file) = 0
  AddElement(lines())
  lines() = ReadString(file)
Wend
CloseFile(file)

ForEach lines()
  If FindString(lines(), "Data.GLfloat") Or FindString(lines(), "Data.f")
    lines() + ",0.0"
  EndIf
Next

Define file = OpenFile(#PB_Any, folder+output_file, #PB_UTF8)
ForEach lines()
  WriteStringN(file, lines(), #PB_UTF8)
Next

CloseFile(file)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 16
; EnableXP
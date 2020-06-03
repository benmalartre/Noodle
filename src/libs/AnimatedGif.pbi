DeclareModule AnimatedGif

  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "E:\Projects\RnD\gif-h\build\AnimatedGif\x64\Release\AnimatedGif.lib"
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS  
    ;___________________________________________________________________________
    ;  MacOSX
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  
   CompilerEndIf
    
    AnimatedGif_Init(filename.p-utf8, width.l, height.l, delay.f)
    AnimatedGif_Term(*writer)
    AnimatedGif_AddFrame(*writer, *datas)
  EndImport
EndDeclareModule

Module AnimatedGif
  
EndModule

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 30
; Folding = -
; EnableXP
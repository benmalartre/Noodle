﻿DeclareModule Font
  
  ; ---------------------------------------------------------
  ;   STRUCTURE
  ; ---------------------------------------------------------
  Structure Font_t
    name.s
    size.i
    font.i
  EndStructure
  
  Global *CURRENT_FONT.Font_t
  Global Dim *FONTS.Font_t(0)
  
  Declare Init()
  Declare Term()
  
EndDeclareModule

Module Font

  ; ---------------------------------------------------------
  ;   DRAW
  ; ---------------------------------------------------------
  Procedure Init()
    RegisterFontFile("E:/Projects\RnD/PureBasic/IconMaker/fonts/OpenSans-Regular.ttf")
    Define font.i = LoadFont(#PB_Any, "OpenSans-Regular", 12) ; Maintenant, nous pouvons charger la police, le système d'exploitation la connait
    *CURRENT_FONT = AllocateMemory(SizeOf(Font_t))
    *CURRENT_FONT\name = "OpenSans-Regular"
    *CURRENT_FONT\font = font
    *CURRENT_FONT\size = 12
    
    ReDim *FONTS(1)
    *FONTS(0) = *CURRENT_FONT
  EndProcedure

  Procedure Term()
    Define numFonts.i = ArraySize(*FONTS())
    Define i
    For i=0 To numFonts-1
      If IsFont(*FONTS(i)\font) : FreeFont(*FONTS(i)\font) : EndIf
      FreeMemory(*Fonts(i))
    Next
  EndProcedure
  
EndModule

Font::Init()

Debug Font::*CURRENT_FONT\name +" : "+Str(Font::*CURRENT_FONT\font)

Font::Term()

Debug "ALL IS FINE..."
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 25
; Folding = -
; EnableXP
; EnablePurifier
DeclareModule Font
  
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
    RegisterFontFile("../../fonts/Arial/arial.ttf")
    Define font.i = LoadFont(#PB_Any, "OpenSans-Regular", 12)
    *CURRENT_FONT = AllocateStructure(Font_t)
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
      FreeStructure(*Fonts(i))
    Next
  EndProcedure
  
EndModule

Font::Init()

Debug Font::*CURRENT_FONT\name +" : "+Str(Font::*CURRENT_FONT\font)

Font::Term()

; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 52
; Folding = -
; EnableXP
; EnablePurifier
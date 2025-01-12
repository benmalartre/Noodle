XIncludeFile "../core/PDF.pbi"

Define LinkID.i
Define File$ = "/Users/malartrebenjamin/Documents/RnD/tests/test.pdf"

#PDF = 1

If PDF::Create(#PDF)
  
  PDF::AddPage(#PDF)
  
  LinkID = PDF::AddLinkURL(#PDF, "https://www.purebasic.com/")
  
  PDF::Image(#PDF, "../../textures/callisto.jpg", 10,  10, 30, 0, LinkID)
  PDF::Image(#PDF, "../../textures/earth.jpg", 10, 110, 60, 0, LinkID)
  PDF::Image(#PDF, "../../textures/jupiter.jpg", 10, 210, 80, 0, LinkID)
  
  PDF::Close(#PDF, File$)
EndIf

RunProgram(File$)
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 13
; EnableXP
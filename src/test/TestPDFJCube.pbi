XIncludeFile "..\core\PDF.pbi"

Define LinkID.i, File$ = "C:\Users\benjamin\Downloads\PDF\pbPDF-JCube.pdf"
Define source.s = "/Users/benmalartre/Downloads/jcube-nda-malartre.pdf"

#PDF = 1

If PDF::
; If PDF::Create(#PDF)
;   
;   PDF::AddPage(#PDF)
;   
;   LinkID = PDF::AddLinkURL(#PDF, "https://www.purebasic.com/")
;   
;   PDF::Image(#PDF, "C:\Users\benjamin\Downloads\PDF\PureBasic.png", 10,  10, 30, 0, LinkID)
;   PDF::Image(#PDF, "C:\Users\benjamin\Downloads\PDF\PureBasic.jpg", 10, 110, 60, 0, LinkID)
;   PDF::Image(#PDF, "C:\Users\benjamin\Downloads\PDF\PureBasic.jp2", 10, 210, 80, 0, LinkID)
;   
;   PDF::Close(#PDF, File$)
; EndIf

RunProgram(source)
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 7
; EnableXP
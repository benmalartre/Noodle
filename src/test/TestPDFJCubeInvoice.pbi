XIncludeFile "../core/PDF.pbi"

Define.s Options
;Define File$="pbPDF-Acroforms.pdf"

Define File$ = "/Users/benmalartre/Documents/Documents/JCube-Invoice.pdf"
#PDF = 1

Define header.s
header = "DATE: March 11, 2020"+Chr(10)+Chr(10)

header + "FROM:"+Chr(10)
header + "Benjamin-Quentin Jonas Malartre"+Chr(10)
header + "19 Rue Etienne Dolet"+Chr(10)
header + "75020 Paris"+Chr(10)
header + "FRANCE"+Chr(10)+Chr(10)

header + "To:"+Chr(10)
header + "J Cube Inc"+Chr(10)
header + "Address: 10F Sangyo Boeki Center"+Chr(10)
header + "2 Yamashita-cho Naka-ku, Yokohama"+Chr(10)
header + "Kanagawa 231-0023, Japan"+Chr(10)+Chr(10)



Define body.s
body = "=============================================================================="+Chr(10)+Chr(10)
body + "INVOICE"+Chr(10)+Chr(10)
body + "DESCRIPTION:"Chr(10)
body + "Consulting Work for V-Ray Procedural for Multiverse | USD"+Chr(10)+Chr(10)

body + "FEE AMOUNT: 240.000 JPY"+Chr(10)
body + "JAPAN SALES TAX: 0 JPY"+Chr(10)
body + "TOTAL: 240.000 JPY"+Chr(10)+Chr(10)

body + "IBAN: FR76 3000 3006 5900 0518 3221 148"+Chr(10)
body + "BIC-ADDRESSE SWIFT: SOGEFRPP"+Chr(10)+Chr(10)

body = "=============================================================================="+Chr(10)+Chr(10)
signature.s = "/Users/benmalartre/Documents/Documents/signature.jpg"
If PDF::Create(#PDF)
  
  Define link = PDF::AddLinkURL(#PDF, "http://benmalartre.free.fr/")
  PDF::AddPage(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "", 12)
  PDF::MultiCell(#PDF, header, 120, 10, #False, PDF::#LeftAlign, #False)
  
  PDF::MultiCell(#PDF, body, 240, 10, #False, PDF::#LeftAlign, #False)
  
  PDF::Ln(#PDF)
  PDF::Ln(#PDF)
  
  PDF::Image(#PDF, signature, 128)
;   PDF::Image(#PDF, signature, 10,  10, 30, 0, link)
  
  PDF::Close(#PDF, File$)
  
EndIf

RunProgram(File$)


; Define LinkID.i
; Define File$ = "/Users/benmalartre/Documents/Documents/Fin_Bail.pdf"
; 
; #PDF = 1
; 
; If PDF::Create(#PDF)
;   
;   PDF::AddPage(#PDF)
;   
;   ;LinkID = PDF::AddLinkURL(#PDF, "https://www.purebasic.com/")
;   PDF::PlaceText(#PDF, "Fin de bail location meublé", 60, 40)
; ;   PDF::Image(#PDF, "C:\Users\benjamin\Downloads\PDF\PureBasic.png", 10,  10, 30, 0, LinkID)
; ;   PDF::Image(#PDF, "C:\Users\benjamin\Downloads\PDF\PureBasic.jpg", 10, 110, 60, 0, LinkID)
; ;   PDF::Image(#PDF, "C:\Users\benjamin\Downloads\PDF\PureBasic.jp2", 10, 210, 80, 0, LinkID)
;   
;   PDF::Close(#PDF, File$)
; EndIf
; 
; RunProgram(File$)
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 9
; EnableXP
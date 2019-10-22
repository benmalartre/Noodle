XIncludeFile "../core/PDF.pbi"

Define.s Options
;Define File$="pbPDF-Acroforms.pdf"

Define File$ = "/Users/benmalartre/Documents/Documents/Fin_Bail.pdf"
#PDF = 1

Define body.s
body = "    Je, soussigné Benjamin-Quentin Jonas Malartre,"+Chr(10)
body + "atteste avoir mis fin au bail de la location du meublé de Claire Nazikian, situé au 19 rue Etienne Dolet 75020."+Chr(10)
body + "Nous avons procédé a l'état des lieux et à la restitution des clefs le Dimanche 13 Octobre."+Chr(10)
body + "Pour justifier et faire valoir ce que de droit."+Chr(10)


signature.s = "/Users/benmalartre/Documents/Documents/signature.jpg"
If PDF::Create(#PDF)
  
  Define link = PDF::AddLinkURL(#PDF, "http://benmalartre.free.fr/")
  PDF::AddPage(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "B", 10)
  PDF::Ln(#PDF)
  PDF::Cell(#PDF, "Benjamin-Quentin Jonas Malartre", 80, 6, #False, PDF::#NextLine, PDF::#LeftAlign)
  PDF::Cell(#PDF, "3 Rue Sous-les-Orgues", 80, 6, #False, PDF::#NextLine, PDF::#LeftAlign)
  PDF::Cell(#PDF, "63490 Usson", 80, 6, #False, PDF::#NextLine, PDF::#LeftAlign)
  PDF::Cell(#PDF, "Doha le 19/10/2019", 80, 10, #False, PDF::#NextLine, PDF::#LeftAlign)
  PDF::Ln(#PDF)
  PDF::Ln(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "B", 18) 
  PDF::Cell(#PDF, "Fin de bail de location d'un meublé", #PB_Default, #PB_Default, #False, PDF::#NextLine, PDF::#CenterAlign)
  
  PDF::Ln(#PDF)
  PDF::Ln(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "", 11)
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
; CursorPosition = 40
; FirstLine = 15
; EnableXP
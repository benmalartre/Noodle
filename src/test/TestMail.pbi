 InitNetwork()

If CreateMail(0, "benmalartre@free.fr", "Salut Tare")
  AddMailRecipient(0, "benmalartre@free.fr", #PB_Mail_To)
  AddMailAttachment(0, "Image", "E:/Mediatek/ID/IMG_3102.jpg", "image/jpeg")
  
  Debug SendMail(0, "smtp.free.fr", 587, #PB_Mail_UseSSL, "benmalartre", "bendover2000")
EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 4
; EnableXP
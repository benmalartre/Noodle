
InitNetwork()
Structure FTPCredential_t
  username.s
  password.s
EndStructure

Procedure FTPCredential(*credential.FTPCredential_t)

  Define width = 300
  Define height = 100
  Define label_width = 60
  Define line_height = 24
  Define padding = 10
  Define input_width = width - (2 * padding + label_width) 
  Define button_height = 25
 
  Define window = OpenWindow(#PB_Any, 0,0,width,height,"Credential", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  AddKeyboardShortcut(window, #PB_Shortcut_Return, 15)
  Define usernamelabel = TextGadget(#PB_Any, padding, padding + 4, label_width, line_height,"Username :")
  Define username = StringGadget(#PB_Any,padding + label_width,padding, input_width,line_height,"")
  Define passwordlabel = TextGadget(#PB_Any, padding, 2*padding + line_height + 4,label_width,line_height,"Password :")
  Define password = StringGadget(#PB_Any,padding + label_width, 2*padding + line_height, input_width  ,line_height,"", #PB_String_Password)
  Define button = ButtonGadget(#PB_Any,padding,height-30,width-2*padding,button_height,"OK")
  Define close = #False
  Repeat
    event = WaitWindowEvent()
    If event = #PB_Event_Gadget
      If EventGadget() = username
        *credential\username = GetGadgetText(username)
      ElseIf EventGadget() = password
        *credential\password = GetGadgetText(password)
      ElseIf EventGadget() = button
        close = #True
      EndIf
    ElseIf event = #PB_Event_Menu
      If EventMenu() = 15
        close = #True
        EndIf
    EndIf
  Until event = #PB_Event_CloseWindow Or close
  CloseWindow(window)
  
EndProcedure

Define credential.FTPCredential_t
FTPCredential(credential)

If OpenFTP(0, "ftpperso.free.fr", credential\username, credential\password, #PB_Ignore,21)
  
  Debug GetFTPDirectory(0)
  SetFTPDirectory(0,"/images/")
  Debug GetFTPDirectory(0)
  ExamineFTPDirectory(0)
  
  Define file.s = OpenFileRequester("Choose a file to send", "", "*.*", 0)
  Debug file
 
  Define size = FileSize(file)
   
  Define ftpFile.s = GetFilePart(file)
  Debug ftpFile
  
;   result = SendFTPFile(0, OpenFileRequester("Choose a file to send", "", "*.*", 0), ftpFile, 1)
;   Debug result
  
;   Repeat
;     status = FTPProgress(0)
;     Delay(300)
;   Until status = -3 Or status = -2
;   
;   If status = #PB_FTP_Error
;     Debug "Error Uploading File"
;   ElseIf status = #PB_FTP_Finished
;     Debug "Success uploading file"
;   EndIf
  
  If SendFTPFile(0, file, ftpFile, #ASYNCH)
   
    Repeat
      Select FTPProgress(0)
        Case #PB_FTP_Started ;Valeur -1
          Debug "Start upload"
       
        Case #PB_FTP_Finished ;valeur -3
          Debug "End upload"
          Break
         
        Case #PB_FTP_Error ;Valeur -2 
          Debug "Error " + ftpFile
          Break
         
        Default
          Debug "Progress of the current file transfer" + Str(size - FTPProgress(0)) + " Octets"
         
      EndSelect 
      Delay(100) 
    ForEver 
   
  EndIf
  

  Debug "finished"
  
Else
  MessageRequester("Error", "Can't connect to the FTP server")
EndIf

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 53
; FirstLine = 36
; Folding = -
; EnableXP
;==========================================================================
; P3RV CONSOLE CLIENT
;==========================================================================
Enumeration
  #MODE_IDLE
  #MODE_WRITE
  #MODE_READ
EndEnumeration

#BUFFER_SIZE = 1024
Global CURRENT_PATH.s
Global IP_ADRESS.s = "192.168.1.41"
Global PORT_ID   = 6832
Global DISK_NAME.s = "C:\"
Global COLOR_BG = 8
Global COLOR_FG = 8
Global COLOR_LBL = 7
Global COLOR_TXT = 15

If InitNetwork() = 0
  MessageRequester("Error", "Can't initialize the network !", 0)
  End
EndIf

Procedure DrawItem(index.i, label.s, value.s)
  ConsoleLocate(0,index)
  ConsoleColor(COLOR_LBL,COLOR_BG)
  Print(label+":")
  ConsoleColor(COLOR_TXT,COLOR_FG)
  Print(value)
EndProcedure

Procedure Draw()
  Define str.s = RSet("",80,"#")
  ConsoleColor(COLOR_LBL,COLOR_BG)
  ConsoleLocate(0,0)
  PrintN(str)
  ConsoleLocate(0,2)
  PrintN(str)
  ConsoleLocate(0,4)
  PrintN(str)
  ConsoleLocate(0,6)
  PrintN(str)
  DrawItem(3, "STATUS", "connected")
  DrawItem(4, "IP ADDRESS", IP_ADRESS)
  DrawItem(5, "PORT ID", Str(PORT_ID))

EndProcedure


;-------- open console --------
OpenConsole()                                  ; First we must open a console
ConsoleTitle ("P3RV Console")                  ; Now we can give the opened console a Titlename ;)                                                  
EnableGraphicalConsole(1)
                                                                                                
;-------- ip address and port number --------
;"192.168.1.41" 
ConsoleLocate (2,2)                            ; x y position 
Print ("Please enter ip adress(ie: 192.168.1.41):   ") ; Ask for ip adress
;IP_ADRESS = Input()

ConsoleLocate (2,4)                          ; x y position 
Print ("Please enter port index(ie: 6832): "); Ask for port index
;PORT_ID = Val(Input())

ConsoleLocate(2, 16)
Print("Connect to ip address "+IP_ADRESS+" on port "+Str(PORT_ID))
connectionID = OpenNetworkConnection(IP_ADRESS, PORT_ID)
Define *buffer = AllocateMemory(#BUFFER_SIZE)
mode = #MODE_IDLE

Draw()

If connectionID
  mode = #MODE_WRITE
 
  quit = #False
  While Not quit
    If mode = #MODE_WRITE
      cmd.s = Input()
      If LCase(cmd) = "quit"
        quit = #True
      ElseIf Left(LCase(cmd), 2) = "cd"
        MessageRequester("CMD", "CHNAGE DIR")
        If FindString(cmd, ":\", 0) = 0
          CURRENT_PATH + Right(cmd, Len(cmd)-3)+"\"
          cmd = "cd "+CURRENT_PATH
          MessageRequester("CMD", cmd)
        Else
          CURRENT_PATH = Right(cmd, Len(cmd)-3)+"\"
        EndIf
        
        SendNetworkString(connectionID, cmd, #PB_UTF8)
      Else
        mode = #MODE_READ
        SendNetworkString(connectionID, cmd, #PB_UTF8)
      EndIf
    Else
      
      event = NetworkClientEvent(connectionID)
      Select event
        Case #PB_NetworkEvent_Data
          recieved = #False
          result.s = ""
          While Not recieved
            status =  ReceiveNetworkData(connectionID, *buffer, #BUFFER_SIZE)
            If status = -1 Or status < #BUFFER_SIZE
              recieved = #True
            EndIf
            result + PeekS(*buffer)
          Wend
          
          MessageRequester("SERVER RESPONSE", result, 0)
          mode = #MODE_WRITE
      EndSelect
    EndIf
    
    
    
  Wend    
  
  CloseNetworkConnection(ConnectionID)
Else
  For i=0 To 15
    ConsoleColor (i,0)                         ; Change ForGround text color (max 15) in every loop         
    ConsoleLocate (24,4+i)                     ; x y position 
    Print ("connection failed")                 ; Print our text
  Next
EndIf
  
End   

; IDE Options = PureBasic 5.62 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 83
; FirstLine = 57
; Folding = -
; EnableXP
; Executable = ..\..\build\windows\Client.exe
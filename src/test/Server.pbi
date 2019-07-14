Procedure.s RemoteCommand(cmd.s)
  Define exe.s = "cmd.exe"
  Define prg = RunProgram(exe, "?/c "+cmd,"",#PB_Program_Hide | #PB_Program_Open |#PB_Program_Read)
  Define output.s
  While ProgramRunning(prg)
    output + ReadProgramString(prg, #PB_UTF8)
  Wend
  CloseProgram(prg)
  ProcedureReturn output
EndProcedure

ProcedureDLL EnableAdminShares(value.b)
  Define cmd.s = "REG ADD "+Chr(34)+"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system"+Chr(34)+" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d "+Str(value)+" /f"
  RemoteCommand(cmd)
EndProcedure

ProcedureDLL.b WriteAccess(*path, value.b=#True)
  Define filename.s = PeekS(*path, -1, #PB_UTF8)
  If FileSize(filename) <> -1
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If value
        If SetFileAttributes(filename,  #PB_FileSystem_Normal)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
        
      Else
        If SetFileAttributes(filename,  #PB_FileSystem_ReadOnly)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      EndIf
      
      
    CompilerElse
      If value
        SetFileAttributes(filename,  #PB_FileSystem_WriteAll)
      Else
        
      EndIf
    CompilerEndIf
    
      
;     If value
;       Define cmd.s = "icacls "+Chr(34)+filename+Chr(34)+" /grant :r "+Chr(34)+user+Chr(34)+":(d,wdac)"
;     Else
;       Define cmd.s = "icacls "+Chr(34)+filename+Chr(34)+" /deny "+Chr(34)+user+Chr(34)+":(d,wdac)"
;     EndIf
;     
;     MessageRequester("WRITE ACCESS CMD", cmd)
;     Define result.s = RemoteCommand(cmd)
;     MessageRequester("RESULT", result)
  Else
     ProcedureReturn #False
  EndIf
  
EndProcedure

ProcedureDLL TakeOwn(*path)
  Define filename.s = PeekS(*path, -1, #PB_UTF8)
  If FileSize(filename) <> -1
    Define cmd.s = "takeown /f "+Chr(34)+filename+Chr(34)+" /R /D O"
    Define result.s = RemoteCommand(cmd)
    MessageRequester("RESULT", cmd+Chr(13)+result)
  EndIf
  
EndProcedure

ProcedureDLL ActivateFirewall(active.c)
  Define cmd.s = "cmd.exe"
  Define state.s
  If active = 0
    state = "?/c netsh advfirewall set currentprofile state off"
    ;state = "?/c netsh firewall set opmode disable"
  Else
    state = "?/c netsh advfirewall set currentprofile state on"
    ;state = "?/c netsh firewall set opmode enable"
  EndIf
  Define prg = RunProgram(cmd, state,"",#PB_Program_Hide | #PB_Program_Open |#PB_Program_Wait)
EndProcedure


ProcedureDLL StartServer(*address, port.i)
  If InitNetwork() = 0
    ProcedureReturn -1
  EndIf
  
  Define bufferSize = 1000
  Define *buffer = AllocateMemory(bufferSize)

  ;Define window = OpenWindow(#PB_Any, 0,0,258,258,"P3RV SERVER")
  MessageRequester("CONNECT", PeekS(*address, -1, #PB_UTF8 )+" : "+Str( port ))
  Define server = CreateNetworkServer(#PB_Any, port, #PB_Network_TCP|#PB_Network_IPv4, PeekS(*address, -1, #PB_UTF8 )) 
  If server
    Repeat
      event = NetworkServerEvent()
    
      If event
      
        clientID = EventClient()
    
        Select event
        
          Case #PB_NetworkEvent_Connect
            client = EventClient()            
    
          Case #PB_NetworkEvent_Data
            ReceiveNetworkData(clientID, *buffer, bufferSize)
            Define result.s = RemoteCommand(PeekS(*buffer, -1, #PB_UTF8))
            SendNetworkData(clientID, @result, Len(result))
    
          Case #PB_NetworkEvent_Disconnect
            quit = 1
      
        EndSelect
      EndIf
      
      ForEver
      ;Until quit = 1 Or WaitWindowEvent(10) = #PB_Event_CloseWindow
      ;Until WaitWindowEvent(10) = #PB_Event_CloseWindow
    
    MessageRequester("PureBasic - Server", "Click to quit the server.", 0)
    
    CloseNetworkServer(server)
  Else
    MessageRequester("Error", "Can't create the server (port in use ?).", 0)
  EndIf
EndProcedure

ProcedureDLL StopServer(server.i)
  CloseNetworkServer(server)
EndProcedure

; IDE Options = PureBasic 5.62 (Windows - x64)
; ExecutableFormat = Shared dll
; CursorPosition = 93
; FirstLine = 71
; Folding = --
; EnableXP
; Executable = ..\..\build\windows\server.dll
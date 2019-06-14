
ProcedureDLL ActivateFirewall(active.c)
  Define cmd.s = "cmd.exe"
  Define state.s
  If active = 0
    ;state = "?/c netsh advfirewall set currentprofile state off"
    state = "?/c netsh firewall set opmode disable"
  Else
    ;state = "?/c netsh advfirewall set currentprofile state on"
    state = "?/c netsh firewall set opmode enable"
  EndIf
  Define prg = RunProgram(cmd, state,"",#PB_Program_Hide | #PB_Program_Open |#PB_Program_Wait)
EndProcedure

ProcedureDLL ActivateFirewall(active.c)
  Define cmd.s = "cmd.exe"
  Define state.s
  If active = 0
    ;state = "?/c netsh advfirewall set currentprofile state off"
    state = "?/c netsh firewall set opmode disable"
  Else
    ;state = "?/c netsh advfirewall set currentprofile state on"
    state = "?/c netsh firewall set opmode enable"
  EndIf
  Define prg = RunProgram(cmd, state,"",#PB_Program_Hide | #PB_Program_Open |#PB_Program_Wait)
EndProcedure




; IDE Options = PureBasic 5.62 (Windows - x64)
; ExecutableFormat = Shared dll
; CursorPosition = 14
; Folding = -
; EnableXP
; Executable = ..\..\build\windows\firewall.dll
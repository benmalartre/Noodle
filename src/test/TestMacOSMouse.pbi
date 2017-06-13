window = OpenWindow(#PB_Any,0,0,800,600,"Test Mac Mouse")
gadget = OpenGLGadget(#PB_Any,0,0,800,600)
lmb = #False
mmb = #False
rmb = #False
;GetGadgetAttribute(
Repeat
  e = WaitWindowEvent()
  If e = #PB_Event_Gadget
    If EventGadget() = gadget
      Select EventType()
        Case #PB_EventType_LeftButtonDown
          lmb = #True
          Debug "Left Button Down"
        Case #PB_EventType_LeftButtonUp
          lmb = #False
          Debug "Left Button Up"
        Case #PB_EventType_RightButtonDown
          rmb = #True
          Debug "Right Button Down"
        Case #PB_EventType_RightButtonUp
          rmb = #False
          Debug "Right Button Up"
        Case #PB_EventType_MiddleButtonDown
          mmb = #True
          Debug "Middle Button Down"
        Case #PB_EventType_MiddleButtonUp
          rmb = #False
          Debug "Middle Button Up"
        Case #PB_EventType_MouseMove
          If lmb : Debug "Mouse Move LEFT button down" 
          ElseIf mmb : Debug "Mouse Move MIDDLE button down" 
          ElseIf rmb : Debug "Mouse Move RIGHT button down"
          Else : Debug "Mouse Move Walhou!!" : EndIf
      EndSelect
      
    EndIf
    
  EndIf
  
Until e = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 33
; FirstLine = 10
; EnableUnicode
; EnableXP
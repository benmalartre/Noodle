window = OpenWindow(#PB_Any, 0,0,800,600,"TEST",#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
gadget = OpenGLGadget(#PB_Any, 0,0,800,600)

Repeat 
  e = WaitWindowEvent()
  Select e
    Case #PB_Event_Gadget
      Debug "EVENT GADGET : "+Str(e)
      
    Case #PB_Event_ActivateWindow
      Debug "EVENT ACTIVATE WINDOW : "+Str(e)
    Case #PB_Event_CloseWindow
      Debug "EVENT CLOSE WINDOW : "+Str(e)
    Case #PB_Event_DeactivateWindow
      Debug "EVENT DEACTIVATE WINDOW : "+Str(e)
    Case #PB_Event_FirstCustomValue
      Debug "EVENT FIRST CUSTOM VALUE: "+Str(e)
    Case #PB_Event_GadgetDrop
      Debug "EVENT GADGET DROP: "+Str(e)
    Case #PB_Event_LeftClick
      Debug "EVENT LEFT CLICK : "+Str(e)
    Case #PB_Event_LeftDoubleClick
      Debug "EVENT LEFT DOUBLE CLICK : "+Str(e)
    Case #PB_Event_MaximizeWindow
      Debug "EVENT MAXIMIZE WINDOW : "+Str(e)
    Case #PB_Event_Menu
      Debug "EVENT MENU : "+Str(e)
    Case #PB_Event_MinimizeWindow
      Debug "EVENT MINIMIZE WINDOW : "+Str(e)
    Case #PB_Event_MoveWindow
      Debug "EVENT MOVE WINDOW : "+Str(e)
    Case #PB_Event_None
      Debug "EVENT NONE : "+Str(e)
    Case #PB_Event_Repaint
      Debug "EVENT REPAINT : "+Str(e)
    Case #PB_Event_RestoreWindow
      Debug "EVENT RESTORE WINDOW : "+Str(e)
    Case #PB_Event_RightClick
      Debug "EVENT RIGHT CLICK : "+Str(e)
    Case #PB_Event_SizeWindow
      Debug "EVENT SIZE WINDOW : "+Str(e)
    Case #PB_Event_SysTray
      Debug "EVENT SYS TRAY : "+Str(e)
    Case #PB_Event_Timer
      Debug "EVENT TIMER : "+Str(e)
    Case #PB_Event_WindowDrop
      Debug "EVENT WINDOW DROP : "+Str(e)
    Default 
      Debug "UNKNOWN EVENT : "+Str(e)
      
  EndSelect
  
Until e = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.61 (Linux - x64)
; CursorPosition = 5
; EnableXP
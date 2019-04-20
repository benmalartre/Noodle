XIncludeFile "../ui/Window.pbi"

Define *window.Window::Window_t = Window::New("TEST WINDOW",0,0,800,600, #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
Define *child.Window::Window_t = Window::TearOff(*window, 0,0,400,400)
Repeat
  event = WaitWindowEvent()
  If EventWindow() = *window\ID
    Window::OnEvent(*window, event)
    Debug "MAIN WINDOW EVENT"
  ElseIf EventWindow() = *child\ID
    Window::OnEvent(*child, event)
    Debug "CHILD WINDOW EVENT"
  EndIf
  
Until event = #PB_Event_CloseWindow


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 11
; EnableXP
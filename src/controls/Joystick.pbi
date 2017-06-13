XIncludeFile "../libs/GLFW.pbi"
;======================================================================
; JOYSTICK MODULE DECLARATION
;======================================================================
DeclareModule Joystick
  Structure JoystickAxis_t
    ID.i
    horizontal.f
    vertical.f
  EndStructure

  Structure JoystickButton_t
    ID.i
    pressed.b  
  EndStructure
  
  Structure Joystick_t
    valid.b
    List axis.JoystickAxis_t()
    List buttons.JoystickButton_t()
    ID.i
  EndStructure
  
  Declare New(ID.i)
  Declare Delete(*Me.Joystick_t)
  Declare GetAxis(*Me.Joystick_t)
  Declare GetButtons(*Me.Joystick_t)
  Declare GetNbAxis(*Me.Joystick_t)
  Declare GetNbButtons(*Me.Joystick_t)
  Declare TestAxis(*Me.Joystick_t,ID)
EndDeclareModule

;======================================================================
; JOYSTICK MODULE IMPLEMENTATION
;======================================================================
Module Joystick
  ;--------------------------------------------------------------------
  ; Constructor
  ;--------------------------------------------------------------------
  Procedure New(ID)
    Protected *Me.Joystick_t = AllocateMemory(SizeOf(Joystick_t))
    InitializeStructure(*Me,Joystick_t)
      *Me\ID = ID
      If GLFW::glfwJoystickPresent(ID)
        ; Get Axis
        ;--------------------------------------------------------------
        Protected axisCount.i
        GLFW::glfwGetJoystickAxes(*Me\ID, @axisCount)
        Protected i
        For i=0 To axisCount/2-1
          AddElement(*Me\axis())
          *Me\axis()\ID = i
        Next
        
        ; Get Buttons
        ;--------------------------------------------------------------
        Protected buttonCount.i
        GLFW::glfwGetJoystickButtons(*Me\ID, @buttonCount)
        For i=0 To buttonCount-1
          AddElement(*Me\buttons())
          *Me\buttons()\ID = i
        Next
        
      *Me\valid = #True
    EndIf
    
    ProcedureReturn *Me
    
  EndProcedure
  
  ;--------------------------------------------------------------------
  ; Destructor
  ;--------------------------------------------------------------------
  Procedure Delete(*Me.Joystick_t)
    ClearStructure(*Me,Joystick_t)
    FreeMemory(*Me)  
  EndProcedure
  
  ;--------------------------------------------------------------------
  ; Get Axis
  ;--------------------------------------------------------------------
  Procedure GetAxis(*Me.Joystick_t)
    Define axisBuf
    Define axisCount
    Define f.f
    Define offset = 0
    Define i
    If *Me\valid
      axisBuf = GLFW::glfwGetJoystickAxes(*Me\ID, @axisCount)
      ForEach *Me\axis()
        *Me\axis()\horizontal = PeekF(axisBuf + (0+offset)*SizeOf(f))
        *Me\axis()\vertical = PeekF(axisBuf + (1+offset)*SizeOf(f))
        offset+2
        Debug "Axis 1 Horizontal : "+StrF(*Me\axis()\horizontal)
        Debug "Axis 1 Vertical : "+StrF(*Me\axis()\vertical)
      Next

    EndIf
    
    
  EndProcedure
  
  Procedure TestAxis(*Me.Joystick_t,ID.i)
  EndProcedure
  
  
  ;--------------------------------------------------------------------
  ; Get Buttons
  ;--------------------------------------------------------------------
  Procedure GetButtons(*Me.Joystick_t)
    Define buttonCount
    Define buttonData = GLFW::glfwGetJoystickButtons(*Me\ID, @buttonCount)
    Define i = 0
    Define c.c
    ForEach *Me\buttons()
      *Me\buttons()\pressed = PeekC(buttonData+i*SizeOf(c))
      Debug "Button ID : "+Str(i)+" : "+Str(*Me\buttons()\pressed)
      i+1
    Next
    
  EndProcedure
  
  ;--------------------------------------------------------------------
  ; Get Nb Axis
  ;--------------------------------------------------------------------
  Procedure GetNbAxis(*Me.Joystick_t)
    ProcedureReturn ListSize(*Me\axis())
  EndProcedure
  
  ;--------------------------------------------------------------------
  ; Get Nb Buttons
  ;--------------------------------------------------------------------
  Procedure GetNbButtons(*Me.Joystick_t)
    ProcedureReturn ListSize(*Me\buttons())
  EndProcedure
  
  
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 49
; FirstLine = 47
; Folding = --
; EnableUnicode
; EnableXP
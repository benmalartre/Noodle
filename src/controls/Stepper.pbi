XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"

UsePNGImageDecoder()

DeclareModule ControlStepper
  
  Structure ControlStepper_t Extends Control::Control_t
    value.d
    txt.i
    input.i
    up.i
    down.i
    steps.d
  EndStructure
  
  Interface IControlStepper Extends Control::IControl
  EndInterface
  
  Declare New(*object.Object::Object_t,name.s,x.i,y.i,width.i,height.i,steps.d=0.1)
  Declare Delete(*Me.ControlStepper_t)
  Declare Event(*Me.ControlStepper_t,event.i,*datas.Control::EventTypeDatas_t=#Null)
  DataSection 
    ControlStepperVT: 
    Data.i @Event()
    Data.i @Delete()
    
    VIControlStepper_up_img_btn:  
      IncludeBinary "../../ico/up_btn.png"
    VIControlStepper_down_img_btn:
      IncludeBinary "../../ico/down_btn.png"
  EndDataSection
  
  Global controlstepper_img_up.i
  Global  controlstepper_img_down.i
  
EndDeclareModule


Module ControlStepper
  ;------------------------------------------------
  ; Global
  ;------------------------------------------------
  controlstepper_img_up = CatchImage(#PB_Any,?VIControlStepper_up_img_btn)
  controlstepper_img_down = CatchImage(#PB_Any,?VIControlStepper_down_img_btn)
  
  Procedure New(*object.Object::Object_t,name.s,x.i,y.i,width.i,height.i,steps.d=0.1)
    Protected *Me.ControlStepper_t = AllocateStructure(ControlStepper_t)
    Object::INI(ControlStepper)
    *Me\object = *object
    *Me\name = name
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width
    *Me\sizY = height
    *Me\steps = steps
    *Me\txt = TextGadget(#PB_Any,*Me\posX+4,*Me\posY+10,*Me\sizX/3,25,*Me\name)
    *Me\input = StringGadget(#PB_Any,*Me\posX+*Me\sizX/3,*Me\posY,2**Me\sizX/3-25,25,"0.0",#PB_String_Numeric)
    *Me\up = ButtonImageGadget(#PB_Any,*Me\posX+*Me\sizX-25,*Me\posY+2,20,10,ImageID(controlstepper_img_up))
    *Me\down = ButtonImageGadget(#PB_Any,*Me\posX+*Me\sizX-25,*Me\posY+13,20,10,ImageID(controlstepper_img_down))
    
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.ControlStepper_t)
    If IsGadget(*Me\input) : FreeGadget(*Me\input) : EndIf
    If IsGadget(*Me\txt) : FreeGadget(*Me\txt) : EndIf
    If IsGadget(*Me\up) : FreeGadget(*Me\up) : EndIf
    If IsGadget(*Me\down) : FreeGadget(*Me\down) : EndIf
    Object::TERM(ControlStepper)
  EndProcedure
  
  Procedure Event(*Me.ControlStepper_t,event.i,*datas.Control::EventTypeDatas_t=#Null)

    Select event
      Case #PB_Event_Gadget
        Debug "Event Gadget..."
        Select EventGadget()
          Case *Me\input
            Debug *Me\name+" INPUT Event"
            *Me\value = ValD(GetGadgetText(*Me\input))
            PostEvent(Globals::#EVENT_PARAMETER_CHANGED,WindowEvent(),*Me\object)
          Case *Me\up
            *Me\value + *Me\steps
            SetGadgetText(*Me\input,StrD(*Me\value,3))
            PostEvent(Globals::#EVENT_PARAMETER_CHANGED,WindowEvent(),*Me\object)
            Debug *Me\name+" UP Event"
          Case *Me\down
            *Me\value - *Me\steps
            SetGadgetText(*Me\input,StrD(*Me\value,3))
            PostEvent(Globals::#EVENT_PARAMETER_CHANGED,WindowEvent(),*Me\object)
            Debug *Me\name+" DOWN Event"
        EndSelect
        
        
    EndSelect
    
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 69
; FirstLine = 43
; Folding = -
; EnableXP
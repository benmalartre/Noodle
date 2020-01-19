  XIncludeFile "../libs/STK.pbi"
  XIncludeFile "../core/Application.pbi"
  XIncludeFile "../core/Notes.pbi"
  XIncludeFile "../core/Callback.pbi"
  XIncludeFile "../core/Control.pbi"
  XIncludeFile "../controls/Slider.pbi"
  
  
  Global *app.Application::Application_t
  Global *stream.STK::Stream
  Global NewList *generators.STK::Generator()
  Global NewList *sliders.ControlSlider::ControlSlider_t()
  Global *ui.PropertyUI::PropertyUI_t 
  Global *p.ControlProperty::ControlProperty_t
  
  Globals::Init()
  Controls::Init()
  Time::Init()
  UIColor::Init()
  
  Global frequency.f = Notes::NoteAt(2, Notes::#NOTE_SI)
  Global frequency2.f = Notes::NoteAt(3, Notes::#NOTE_RE)
  
  Procedure OnFrequencyChange(*gen.STK::Generator, *slider.ControlSlider::ControlSlider_t)
    STK::SetGeneratorScalar(*gen, STK::#GEN_FREQUENCY, *slider\value) 
  EndProcedure
  Callback::DECLARECALLBACK(OnFrequencyChange, Arguments::#PTR, Arguments::#PTR)
  
  Global counter.i = 0
  Global running = #False
  Global down.b
  ; Update
  ;-----------------------------------------------------
  Procedure Update(*app.Application::Application_t, event.i)
    counter +1
    Define key.i
  ;   If counter % 100 = 0
  ;     Debug "FUCKé"
  ;     STK::SetGeneratorScalar(*generator, STK::#GEN_FREQUENCY, Notes::NoteAt(Random(8), Random(12)))
  ;     STK::SetGeneratorScalar(*generator2, STK::#GEN_FREQUENCY, Notes::NoteAt(Random(8), Random(12)))
  ;   EndIf
    
  ;   STK::SetGeneratorScalar(*generator, STK::#GEN_FREQUENCY, frequency) 
  ;   STK::SetGeneratorScalar(*generator2, STK::#GEN_FREQUENCY, frequency2) 
    If event = #PB_Event_Gadget And EventGadget() = *p\gadgetID
      Select EventType()
        Case #PB_EventType_KeyDown
          key = GetGadgetAttribute(*p\gadgetID, #PB_Canvas_Key)
          If key = #PB_Shortcut_Return
            
            If running
              STK::StreamStop(*stream)
              
              running = #False  
            Else
              Define numRoots =  STK::StreamNumRoots(*stream)
              Define result.b = STK::StreamStart(*stream)
              running = #True
            EndIf
          ElseIf key = #PB_Shortcut_Space
            ; STK::EnvelopeKeyOn(*envelope) 
          EndIf
        Case #PB_EventType_LeftButtonDown
          down = #True
        Case #PB_EventType_LeftButtonUp
          down=#False
        Case #PB_EventType_MouseMove
  ;           If down
  ;             mx = GetGadgetAttribute(*p\gadgetID, #PB_Canvas_MouseX)
  ;             v = mx / width
  ;             STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, STK::NoteAt(Random(3)+2, Random(STK::#NUM_NOTES)))
  ;             STK::SetNodeVolume(*wave, 100)
  ;             
  ;           EndIf
          
      EndSelect
    EndIf 
  EndProcedure
  
  Procedure Update2(*app.Application::Application_t, event.i)
    Debug "UPDATE 2"
  EndProcedure
  
  
  Procedure BuildApp(numGenerators)
    *app = Application::New("Test Generator",1024,720,#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    *ui = PropertyUI::New(*app\window\main, "STK", #Null)
    OpenGadgetList(*ui\container)
    *p = ControlProperty::New(#Null,"STK","STK",0,0,WindowWidth(*app\window\ID, #PB_Window_InnerCoordinate), WindowHeight(*app\window\ID, #PB_Window_InnerCoordinate)) 
    AddElement(*ui\props())
    *ui\props() = *p
    *ui\prop = *p
    ControlProperty::AppendStart(*p)
      
    Define baseFrequency = 128
    For i=0 To numGenerators-1     
      Define *generator.STK::Generator= STK::AddGenerator(*stream, STK::#GENERATOR_SINEWAVE, baseFrequency, #True)
      AddElement(*generators())
      *generators() = *generator
      baseFrequency + Random(128)
      
      
      Define *slider.ControlSlider::ControlSlider_t = ControlProperty::AddSliderControl(*p, "Slider"+Str(i), "Slider"+Str(i), baseFrequency,64, 1024, #Null) 
      Signal::CONNECTCALLBACK(*slider\on_change, OnFrequencyChange, *generator, *slider)
      AddElement(*sliders())
     *sliders = *slider
    Next
    
    ControlProperty::AppendStop(*p)
    CloseGadgetList()
    
    STK::StreamStart(*stream)
    running = #True
    Application::Loop(*app, @Update())
    ProcedureReturn *app
  EndProcedure
  
  Procedure DeleteApp(*app.Application::Application_t)
    running = #False
    STK::StreamStop(*stream)
    
    ForEach *generators()
      STK::RemoveNode(*stream, *generators())
    Next
    ClearList(*generators())
    
    PropertyUI::Delete(*ui)
    Debug "DELETED APP!!!"
  
  EndProcedure
  
  STK::Initialize()
  *stream.STK::Stream = STK::StreamSetup(STK::*DAC, 1)
  STK::SetNodeVolume(*stream, 1.0)
  
  For i=0 To 12
    *app = BuildApp(Random(5)+2)
    DeleteApp(*app)
  Next
  
  
  
  ;STK::StreamStop(*stream)
  STK::StreamClean(*stream)
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 96
; FirstLine = 85
; Folding = -
; EnableXP
XIncludeFile "../libs/STK.pbi"
XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Callback.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../controls/Slider.pbi"

Globals::Init()
Controls::Init()
Time::Init()
UIColor::Init()

Global *app.Application::Application_t
Global *ui.PropertyUI::PropertyUI_t 
Global *DAC.STK::RtAudio = STK::Init()
Global *stream.STK::Stream = STK::StreamSetup(*DAC)
Global *wave.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_ASYMP, 64, #True)
STK::SetGeneratorScalar(*wave, STK::#GEN_TAU, 1.0)
STK::SetGeneratorScalar(*wave, STK::#GEN_T60, 3.66)

Procedure OnFrequencyChange(*wave.STK::Generator, frequency.f)
  STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, frequency)
EndProcedure
Callback::DECLARECALLBACK(OnFrequencyChange, Arguments::#PTR, Arguments::#FLOAT)

Procedure Update(*app.Application::Application_t)
  
;     event = WaitWindowEvent()
;     If event = #PB_Event_Gadget And EventGadget() = canvas
;       Select EventType()
;         Case #PB_EventType_KeyDown
;           key = GetGadgetAttribute(canvas, #PB_Canvas_Key)
;           If key = #PB_Shortcut_Return
;             If running
;               STK::GeneratorStreamStop(*stream)
;               running = #False  
;               DrawCanvas()
;             Else
;               Define result.b = STK::GeneratorStreamStart(*stream)
;               running = #True
;               DrawCanvas()
;             EndIf
;           ElseIf key = #PB_Shortcut_Space
;             ; STK::EnvelopeKeyOn(*envelope) 
;           EndIf
;         Case #PB_EventType_LeftButtonDown
;           down = #True
;         Case #PB_EventType_LeftButtonUp
;           down=#False
;         Case #PB_EventType_MouseMove
;           If down
;             mx = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
;             v = mx / width
;             STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, STK::NoteAt(Random(3)+2, Random(STK::#NUM_NOTES)))
; 
;           EndIf
;           
;       EndSelect
;     EndIf 
;   Until event = #PB_Event_CloseWindow
; 


EndProcedure

*app = Application::New("Test STK",1024,720,#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  
Global *DAC.STK::RtAudio = STK::Init()
Global *stream.STK::Stream = STK::StreamSetup(*DAC)
Global *wave.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_SINEWAVE, 128, #True)

*ui = PropertyUI::New(*app\window\main, "STK", #Null)
OpenGadgetList(*ui\container)

Define *p.ControlProperty::ControlProperty_t = ControlProperty::New(#Null,"STK","STK",0,0,WindowWidth(*app\window\ID, #PB_Window_InnerCoordinate), WindowHeight(*app\window\ID, #PB_Window_InnerCoordinate)) 
AddElement(*ui\props())
*ui\props() = *p
*ui\prop = *p
    
ControlProperty::AppendStart(*p)
Define i
For i=0 To 7
  ControlProperty::AddSliderControl(*p, "Slider"+Str(i+1), "Slider"+Str(i+1), i*10, #Null) 
Next

  
ControlProperty::AppendStop(*p)

CloseGadgetList()

STK::StreamStart(*stream)
Application::Loop(*app, @Update())

STK::StreamClean(*stream)
STK::Terminate()


; STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, 64)
; STK::SetGeneratorScalar(*wave, STK::#GEN_PHASE, 1.0)
; STK::SetNodeVolume(*wave, 0.5)
; Global *envelope.STK::Envelope = STK::AddEnvelope(*stream, STK::#ADSR_GENERATOR, *wave, #True)
; 
; STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TIME, 0.01)
; STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TARGET, 1)
; STK::SetEnvelopeScalar(*envelope, STK::#ENV_DECAY_TIME, 0.02)
; STK::SetEnvelopeScalar(*envelope, STK::#ENV_RELEASE_TIME, 0.1)

;Global *effect.STK::Effect = STK::AddEffect(*stream, STK::#EFFECT_JCREV, *envelope, #True)
;STK::SetEffectScalar(*effect, STK::#EFFECT_MIX, 0.2)
; STK::SetEffectScalar(*effect, STK::#EFFECT_T60, 0.5)
; Global *mixer.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SCALEADD, *envelope, *effect, #True)
; STK::SetArythmeticScalar(*mixer, 0.5)
; Global *adsr.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#ADSR_GENERATOR, 180)
; Global *blit.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#BLIT_GENERATOR, 180)
; 
; Global *wave1.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 66, #False)
; Global *wave2.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 120, #False)
; Global *wave3.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 120, #False)

; Global *lfo1.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 0.5, #False)
; 
; Global *adder1.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SHIFT, *wave1, *lfo1, #False)
; STK::SetArythmeticScalar(*adder1, 2)
; Global *adder2.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave2, *lfo1, #False)
; STK::SetArythmeticScalar(*adder2, 8)
; 
; Global *mixer.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_BLEND, *adder1, *adder2, #False)
; STK::SetArythmeticScalar(*mixer, 0.5)
; 

; 
; Global *final.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SCALEADD, *mixer, *effect, #True)
; STK::SetArythmeticScalar(*final, 2)

; Global *adder3.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave3, *lfo1, #False)
; 
; Global *adder1.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY *wave1, *lfo1, #False)
; STK::SetArythmeticScalar(*adder1, 32)

; Global *lfo2.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 2, #False)
; Global *adder2.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave2, *lfo2, #False)
; 
; Global *mixer.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MIX, *adder1, *adder2, #True)
; STK::SetArythmeticScalar(*mixer, 0.5)

; Global *wave1.STK::Generator = STK::AddGenerator(*stream, STK::#MODULATE_GENERATOR, 226, #False)
; Global *lfo1.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 8, #False)
; Global *adder1.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave1, *lfo1, #True)
; Global *stream.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#BLITSAW_GENERATOR, 120)
; Global *stream.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#BLITSAW_GENERATOR, 320)

Procedure DrawCanvas()
  StartDrawing(CanvasOutput(canvas))
  If running
    Box(0,0,WIDTH, HEIGHT, RGB(128,255,128))
  Else
    Box(0,0,WIDTH, HEIGHT, RGB(255,128,128))
  EndIf
  StopDrawing()
EndProcedure

DrawCanvas()
Global down.b
Define mx.i, v.f
If *stream
  Repeat
    event = WaitWindowEvent()
    If event = #PB_Event_Gadget And EventGadget() = canvas
      Select EventType()
        Case #PB_EventType_KeyDown
          key = GetGadgetAttribute(canvas, #PB_Canvas_Key)
          If key = #PB_Shortcut_Return
            Debug "ENTER PRESSED"
            If running
              STK::StreamStop(*stream)
              running = #False  
              DrawCanvas()
            Else
              Define result.b = STK::StreamStart(*stream)
              ; STK::EnvelopeKeyOn(*envelope)
              running = #True
              DrawCanvas()
            EndIf
          ElseIf key = #PB_Shortcut_Space
            ; STK::EnvelopeKeyOn(*envelope) 
          EndIf
        Case #PB_EventType_LeftButtonDown
          down = #True
        Case #PB_EventType_LeftButtonUp
          down=#False
        Case #PB_EventType_MouseMove
          If down
            mx = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
            v = mx / width
            STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, v * 220 +60)
            Debug "FREQUENCY : "+Str(v *220 + 60)
;             STK::SetArythmeticScalar(*final, v)
;             STK::SetEffectScalar(*rev, v, STK::#EFFECT_MIX)
;             STK::SetArythmeticScalar(*adder1, v)
;             STK::SetArythmeticScalar(*adder1, v*4)
          EndIf
          
      EndSelect
    EndIf 
  Until event = #PB_Event_CloseWindow

  STK::StreamClean(*stream)
  STK::Term(*DAC)
Else
  MessageRequester("STK", "FAIL TO START GENERATOR STREAM")
EndIf
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 72
; FirstLine = 147
; Folding = -
; EnableXP
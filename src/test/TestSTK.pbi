XIncludeFile "../libs/STK.pbi"
XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Notes.pbi"
XIncludeFile "../core/Callback.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../controls/Slider.pbi"

Globals::Init()
Controls::Init()
Time::Init()
UIColor::Init()

Global note.i = Notes::#NOTE_DO
Global numVoices = 5
Global baseOctave = 3

Global *app.Application::Application_t
Global *ui.PropertyUI::PropertyUI_t 
Global *stream.STK::Stream
Global *p.ControlProperty::ControlProperty_t
Global running.b = #False
Global counter.i = 0
Global NewList *waves.STK::Generator()

; Slider Frequency Callback
;-----------------------------------------------------
Procedure OnFrequencyChange(*control.ControlSlider::ControlSlider_t, *wave.STK::Generator)
  Debug Notes::NoteAt(Random(8), Random(12))
  STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, Notes::NoteAt(Random(8), Random(12)))
EndProcedure
Callback::DECLARECALLBACK(OnFrequencyChange, Arguments::#PTR, Arguments::#FLOAT)

; Slider Octave Callback
;-----------------------------------------------------
Procedure OnOctaveChange(*control.ControlSlider::ControlSlider_t, *wave.STK::Generator)
  Debug "SLIDE CHANGE : "+*control\name+" ---> "+Str(*control\value)+" : "+Str(*wave)
  baseOctave = *control\value
EndProcedure
Callback::DECLARECALLBACK(OnOctaveChange, Arguments::#PTR, Arguments::#INT)



; Update Note On Tick
;-----------------------------------------------------
Procedure UpdateOnTime()
  If counter%60 = 0
    Define octave = baseOctave
    ForEach *waves()
      Debug Notes::NoteAt(octave, note)
      STK::SetGeneratorScalar(*waves(), STK::#GEN_FREQUENCY, Notes::NoteAt(octave, note))
      octave + 1
    Next
    note + 1
    If note > Notes::#NUM_NOTES
      note = 0
    EndIf
  EndIf
  counter +1
EndProcedure



Procedure Update(*app.Application::Application_t, event.i)
  
  UpdateOnTime()
  
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

*app = Application::New("Test STK",1024,720,#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  
STK::Initialize()
*stream.STK::Stream = STK::StreamSetup(STK::*DAC, 1)
STK::SetNodeVolume(*stream, 0.5)

*ui = PropertyUI::New(*app\window\main, "STK", #Null)
OpenGadgetList(*ui\container)

*p = ControlProperty::New(#Null,"STK","STK",0,0,WindowWidth(*app\window\ID, #PB_Window_InnerCoordinate), WindowHeight(*app\window\ID, #PB_Window_InnerCoordinate)) 
AddElement(*ui\props())
*ui\props() = *p
*ui\prop = *p

ControlProperty::AppendStart(*p)
Define i
Define base_frequency = 128

For i=0 To numVoices-1
  Define *wave.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_SINGWAVE, base_frequency, #True)
  
;     STK::SetGeneratorScalar(*wave, STK::#GEN_TAU, 1.0)
;     STK::SetGeneratorScalar(*wave, STK::#GEN_T60, 3.66)
;     STK::SetNodeVolume(*wave,0.666)
    
    AddElement(*waves())
    *waves() = *wave
   
;   Define *noise.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_NOISE, 128, #True)
;   STK::SetNodeVolume(*noise, 12)
;   STK::SetGeneratorScalar(*noise, STK::#GEN_SEED, 7)

;     Define *slider.ControlSlider::ControlSlider_t = ControlProperty::AddSliderControl(*p, "Slider"+Str(i+1), "Slider"+Str(i+1), base_frequency,64, 1024, #Null) 
;     ;     Signal::CONNECTCALLBACK(*slider\on_change, OnOctaveChange, *slider, *waves())
;     Signal::CONNECTCALLBACK(*slider\on_change, OnFrequencyChange, *slider, *wave)
    base_frequency * 2
Next

  
ControlProperty::AppendStop(*p)

CloseGadgetList()

STK::StreamStart(*stream)
running = #True
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
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 135
; FirstLine = 110
; Folding = -
; EnableXP
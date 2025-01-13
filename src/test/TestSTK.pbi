XIncludeFile "../libs/STK.pbi"
XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Notes.pbi"
XIncludeFile "../core/Callback.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Sequencer.pbi"
XIncludeFile "../controls/Slider.pbi"

Globals::Init()
Time::Init()
UIColor::Init()

#NUM_VOICES = 1
Global note.i = Notes::#NOTE_DO
Global baseOctave = 0

Global *app.Application::Application_t
Global *ui.PropertyUI::PropertyUI_t 
Global *stream.STK::Stream

Global *p.ControlProperty::ControlProperty_t
Global running.b = #False
Global counter.i = 0
Global NewList *waves.STK::Generator()
Global *sequencer.Sequencer::Sequencer_t

; Slider Frequency Callback
;-----------------------------------------------------
Procedure OnFrequencyChange(*control.ControlSlider::ControlSlider_t, *track.Sequencer::Track_t)
  ;STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, *control\value)
  *track\offset = Notes::Closest(*control\value)
EndProcedure
Callback::DECLARE_CALLBACK(OnFrequencyChange, Types::#TYPE_PTR, Types::#TYPE_PTR)

; Slider Frequency Callback
;-----------------------------------------------------
Procedure OnLFOChange(*control.ControlSlider::ControlSlider_t, *wave.STK::Generator)
  STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, *control\value)
EndProcedure
Callback::DECLARE_CALLBACK(OnLFOChange, Types::#TYPE_PTR, Types::#TYPE_PTR)

; Slider Octave Callback
;-----------------------------------------------------
Procedure OnOctaveChange(*control.ControlSlider::ControlSlider_t, *wave.STK::Generator)
  Debug "SLIDE CHANGE : "+*control\name+" ---> "+Str(*control\value)+" : "+Str(*wave)
  baseOctave = *control\value
EndProcedure
Callback::DECLARE_CALLBACK(OnOctaveChange, Types::#TYPE_PTR, Types::#TYPE_INT)

; Update Note On Tick
;-----------------------------------------------------
Procedure UpdateOnTime(*sequencer.Sequencer::Sequencer_t)
  For i = O To #NUM_VOICES - 1
    SelectElement(*waves(), i)
    Define frequency.f = Sequencer::GetFrequency(*sequencer\tracks(i))
    Define amplitude.f = Sequencer::GetAmplitude(*sequencer\tracks(i))
    STK::SetGeneratorScalar(*waves(), STK::#GEN_FREQUENCY, frequency)
    STK::SetNodeVolume(*waves(), amplitude)
  Next
EndProcedure

Procedure Update(*app.Application::Application_t, event.i)
  
    UpdateOnTime(*sequencer)
  
;     If event = #PB_Event_Gadget And EventGadget() = *p\gadgetID
;       Select EventType()
;         Case #PB_EventType_KeyDown
;           key = GetGadgetAttribute(*p\gadgetID, #PB_Canvas_Key)
;           If key = #PB_Shortcut_Return
;             
;             If running
;               STK::StreamStop(*stream)
;               
;               running = #False  
;             Else
;               Define numRoots =  STK::StreamNumRoots(*stream)
;               Define result.b = STK::StreamStart(*stream)
;               running = #True
;             EndIf
;           ElseIf key = #PB_Shortcut_Space
;             ; STK::EnvelopeKeyOn(*envelope) 
;           EndIf
;         Case #PB_EventType_LeftButtonDown
;           down = #True
;         Case #PB_EventType_LeftButtonUp
;           down=#False
;         Case #PB_EventType_MouseMove
; ;           If down
; ;             mx = GetGadgetAttribute(*p\gadgetID, #PB_Canvas_MouseX)
; ;             v = mx / width
; ;             STK::SetGeneratorScalar(*wave, STK::#GEN_FREQUENCY, STK::NoteAt(Random(3)+2, Random(STK::#NUM_NOTES)))
; ;             STK::SetNodeVolume(*wave, 100)
; ;             
; ;           EndIf
;           
;       EndSelect
;     EndIf 
EndProcedure

*app = Application::New("Test STK",1024,720,#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  
STK::Initialize()
*stream.STK::Stream = STK::StreamSetup(STK::*DAC, 2)
Debug "STREAM : "+Str(*stream)
;STK::SetNodeVolume(*stream, 0.5)

*ui = PropertyUI::New(*app\window\main, "STK")
PropertyUI::AppendStart(*ui)

*p = ControlProperty::New(*ui,"STK","STK",0,0,WindowWidth(*app\window\ID, #PB_Window_InnerCoordinate), WindowHeight(*app\window\ID, #PB_Window_InnerCoordinate)) 
PropertyUI::AddProperty(*ui, *p)

ControlProperty::AppendStart(*p)
Define i, j
Define *track.Sequencer::Track_t
Define *note.Sequencer::Note_t
Define offset.f = -62

*sequencer = Sequencer::New(60, 3)

;   #C0	  = 16.35   ; DO
;   #Db0  = 17.32   ; DO#
;   #D0	  = 18.35   ; RE
;   #Eb0  = 19.45   ; MIb
;   #E0	  = 20.60   ; MI
;   #F0	  = 21.83   ; FA
;   #Gb0  = 23.12   ; FA#
;   #G0	  = 24.50   ; SOL
;   #Ab0  = 25.96   ; SOL#
;   #A0	  = 27.50   ; LA
;   #Bb0  = 29.14   ; SIb
;   #B0	  = 30.87   ; SI


; BASS
Define *wave.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_BLITSAW, Notes::#C2, #True)
Define *track_bass.Sequencer::Track_t = Sequencer::AddTrack(*sequencer)
*track_bass\offset = offset

For j=0 To 3
  Sequencer::AddNote(*track_bass, j * 512 + 0, 128, Notes::#C1, 1)
  Sequencer::AddNote(*track_bass, j * 512 + 256, 64, Notes::#C1, 1)
  Sequencer::AddNote(*track_bass, j * 512 + 374, 64, Notes::#E1, 1)
Next
Sequencer::SampleTrack(*sequencer, *track_bass)

AddElement(*waves())
*waves() = *wave

Define *slider.ControlSlider::ControlSlider_t = ControlProperty::AddSliderControl(*p, "Slider"+Str(i+1), "Slider"+Str(i+1), offset, -64, 128, #Null) 
;     Signal::CONNECTCALLBACK(*slider\on_change, OnOctaveChange, *slider, *waves())
Callback::CONNECT_CALLBACK(*slider\on_change, OnFrequencyChange, *slider, *track_bass)
base_frequency * 2

; ; DRUM
; *wave.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_NOISE, Notes::#C0, #True)
; Define *track_drum.Sequencer::Track_t = Sequencer::AddTrack(*sequencer)
; *track_drum\offset = offset
; 
; For j=0 To 3
;   Sequencer::AddNote(*track_drum, j * 512 + 64, 32, Notes::#C0, 1)
;   Sequencer::AddNote(*track_drum, j * 512 + 192, 32, Notes::#C0, 0.5)
;   Sequencer::AddNote(*track_drum, j * 512 + 224, 32, Notes::#C0, 1)
;   Sequencer::AddNote(*track_drum, j * 512 + 256, 32, Notes::#C0, 0.25)
; Next
; Sequencer::SampleTrack(*sequencer, *track_drum)
; 
; AddElement(*waves())
; *waves() = *wave
;   Define *noise.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_NOISE, 128, #True)
;   STK::SetNodeVolume(*noise, 12)
;   STK::SetGeneratorScalar(*noise, STK::#GEN_SEED, 7)

; Define *slider.ControlSlider::ControlSlider_t = ControlProperty::AddSliderControl(*p, "Slider"+Str(i+1), "Slider"+Str(i+1), offset, -64, 220, #Null) 
; ;     Signal::CONNECTCALLBACK(*slider\on_change, OnOctaveChange, *slider, *waves())
; Signal::CONNECTCALLBACK(*slider\on_change, OnFrequencyChange, *slider, *track_drum)

    

; 
Define *carrier.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_BLITSAW, Notes::#C2, #False)

; AddElement(*waves())
; *waves() = *carrier
; 
Define *lfo.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_BLITSAW, 6, #False)
Define *offset.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SHIFT, *lfo, #Null, #False)
Define *arythmetic.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SCALEADD, *offset, *carrier, #True)
STK::SetNodeVolume(*lfo, 1)

Debug STK::SetArythmeticScalar
Debug *offset
Debug *arythmetic
STK::SetArythmeticScalar(*offset, 0.5)
STK::SetArythmeticScalar(*arythmetic, 0.5)

;   Define *noise.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_NOISE, 128, #True)
;   STK::SetNodeVolume(*noise, 12)
;   STK::SetGeneratorScalar(*noise, STK::#GEN_SEED, 7)

; 
Define *slider.ControlSlider::ControlSlider_t = ControlProperty::AddSliderControl(*p, "Slider"+Str(i+1), "Slider"+Str(i+1), 66, 32, 1024, #Null) 
;     Signal::CONNECTCALLBACK(*slider\on_change, OnOctaveChange, *slider, *waves())
Callback::CONNECT_CALLBACK(*slider\on_change, OnLFOChange, *slider, *carrier)


Define *slider.ControlSlider::ControlSlider_t = ControlProperty::AddSliderControl(*p, "Slider"+Str(i+1), "Slider"+Str(i+1), 16, 0, 128, #Null) 
;     Signal::CONNECTCALLBACK(*slider\on_change, OnOctaveChange, *slider, *waves())
Callback::CONNECT_CALLBACK(*slider\on_change, OnLFOChange, *slider, *lfo)

Debug *stream
MessageRequester("NUM ROOTS", Str(STK::StreamNumRoots(*stream)))
  
ControlProperty::AppendStop(*p)
PropertyUI::AppendStop(*ui)

Sequencer::Start(*sequencer)
STK::StreamStart(*stream)
running = #True
Application::Loop(*app, @Update(), 0)

Debug *stream
Debug *generator
Debug *generator2

ForEach *waves()
  STK::RemoveNode(*stream, *waves())
Next

STK::StreamClean(*stream)
STK::Terminate()
Sequencer::Stop(*sequencer)


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
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 103
; FirstLine = 69
; Folding = -
; EnableXP
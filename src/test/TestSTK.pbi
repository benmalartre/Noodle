XIncludeFile "../libs/STK.pbi"

Global WIDTH = 800
Global HEIGHT = 600



Global *DAC.STK::RtAudio = STK::Init()
Debug *DAC
Global *stream.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC)
Debug *stream
Global *wave.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 128, #False)
Global *envelope.STK::Envelope = STK::AddEnvelope(*stream, STK::#ADSR_GENERATOR, *wave, #True)

STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TIME, 0.01)
STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TARGET, 1)
STK::SetEnvelopeScalar(*envelope, STK::#ENV_DECAY_TIME, 0.02)
STK::SetEnvelopeScalar(*envelope, STK::#ENV_RELEASE_TIME, 0.1)

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


Global event.i
Global window.i = OpenWindow(#PB_Any, 0,0,WIDTH,HEIGHT,"STK")
Global canvas.i = CanvasGadget(#PB_Any, 0, 0, WIDTH, HEIGHT, #PB_Canvas_Keyboard)
Global running.b = #False


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
              STK::GeneratorStreamStop(*stream)
              running = #False  
              DrawCanvas()
            Else
              Define result.b = STK::GeneratorStreamStart(*stream)
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
            STK::SetGeneratorScalar(*wave, STK::#GENERATOR_FREQUENCY, v * 220 +60)
            Debug "FREQUENCY : "+Str(v *220 + 60)
;             STK::SetArythmeticScalar(*final, v)
;             STK::SetEffectScalar(*rev, v, STK::#EFFECT_MIX)
;             STK::SetArythmeticScalar(*adder1, v)
;             STK::SetArythmeticScalar(*adder1, v*4)
          EndIf
          
      EndSelect
    EndIf 
  Until event = #PB_Event_CloseWindow

  STK::GeneratorStreamClean(*stream)
  STK::STK
Else
  MessageRequester("STK", "FAIL TO START GENERATOR STREAM")
EndIf


; 
; If *sine
;   Debug "START : "+Str(STK::SineStreamStart(*sine))
;   Define N = 0
;   While N < 1024000000
;     N + 1
;   Wend
;   
;   Debug "STOP : "+Str(STK::SineStreamStop(*sine))
;   Debug "CLEAN : "+Str(Stk::STKSineStreamClean(*sine))
; Else
;   Debug "FAIL TO START DAC"
; EndIf
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 126
; FirstLine = 110
; Folding = -
; EnableXP
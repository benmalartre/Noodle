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

;Global rawwave.s = "/Users/benmalartre/Documents/RnD/STK/rawwaves/snardrum.raw"
Global rawwave.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/waves/B747/V1.WAV"
Global rawwave2.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/waves/B777/Autopilot Disconnect.wav"
;Global rawwave.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/waves/Generic Tones/400Hz.wav"

Global *app.Application::Application_t
Global *stream.STK::Stream
Global *generator.STK::Generator


STK::Initialize()
*stream.STK::Stream = STK::StreamSetup(STK::*DAC, 1)

STK::SetNodeVolume(*stream, 1.0)

;*wave = STK::AddGenerator(*stream, STK::#GENERATOR_BLIT, 180, #True)
*generator.STK::Generator= STK::AddGenerator(*stream, STK::#GENERATOR_BLITSAW, Notes::NoteAt(4, Notes::#NOTE_SI), #True)
*generator2.STK::Generator = STK::AddGenerator(*stream, STK::#GENERATOR_SINEWAVE, Notes::NoteAt(3, Notes::#NOTE_RE), #True)
STK::StreamStart(*stream)

STK::SetGeneratorType(*generator, STK::#GENERATOR_SINEWAVE)
; STK::SetReaderScalar(*reader, STK::#READER_RATE, 2)
STK::SetGeneratorType(*generator2, STK::#GENERATOR_NOISE)
; STK::SetReaderScalar(*reader2, STK::#READER_RATE, 0.5)
; STK::SetReaderFilename(*reader, rawwave2)
Define window = OpenWindow(#PB_Any,0,0, 100, 100, "Test Generator")

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow
; STK::DeleteNode(*reader)
STK::StreamStop(*stream)
STK::StreamClean(*stream)
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 34
; FirstLine = 10
; EnableXP
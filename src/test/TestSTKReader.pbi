XIncludeFile "../libs/STK.pbi"
XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Notes.pbi"
XIncludeFile "../core/Callback.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../controls/Slider.pbi"

Globals::Init()
Time::Init()
UIColor::Init()

Global rawwave.s = "/Users/benmalartre/Documents/RnD/STK/rawwaves/snardrum.raw"
;Global rawwave.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/waves/B747/V1.WAV"
Global rawwave2.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/waves/B777/Autopilot Disconnect.wav"
;Global rawwave.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/waves/Generic Tones/400Hz.wav"
;Global rawwave.s = "E:/Projects/RnD/Noodle/waves/B747/V1.WAV"
;Global rawwave2.s = "E:\Projects\RnD\Noodle\waves\B777\Autopilot Disconnect.wav"

Global *app.Application::Application_t
Global *stream.STK::Stream
Global *reader.STK::Reader
Global *wave.STK::Generator

STK::Initialize()
*stream.STK::Stream = STK::StreamSetup(STK::*DAC, 1)

;STK::SetNodeVolume(*stream, 1.0)
Debug *stream
Debug rawwave
Debug STK::AddReader
*reader.STK::Reader = STK::AddReader(*stream, rawwave, #True)
*reader2.STK::Reader = STK::AddReader(*stream, rawwave2, #True)
STK::SetNodeVolume(*reader, 1.0)
STK::SetReaderScalar(*reader, STK::#READER_RATE, 0.25)
STK::StreamStart(*stream)

STK::SetReaderMode(*reader, STK::#READER_FILELOOP)
STK::SetReaderScalar(*reader, STK::#READER_RATE, 2)
STK::SetReaderMode(*reader2, STK::#READER_FILELOOP)
STK::SetReaderScalar(*reader2, STK::#READER_RATE, 0.5)
STK::SetReaderFilename(*reader2, rawwave2)
Define window = OpenWindow(#PB_Any,0,0, 100, 100, "Test Reader")

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow
; STK::DeleteNode(*reader)
STK::StreamStop(*stream)
STK::StreamClean(*stream)
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 29
; FirstLine = 8
; EnableXP
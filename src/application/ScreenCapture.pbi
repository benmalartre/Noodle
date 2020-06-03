;================================================================================================
; CAPTURE TO GIF (WINDOWS ONLY)
;================================================================================================

; XIncludeFile "../core/ScreenCapture.pbi"
; XIncludeFile "../core/Vector.pbi"
; XIncludeFile "../ui/Window.pbi"
; XIncludeFile "../ui/PropertyUI.pbi"
; ; XIncludeFile "../ui/View.pbi"
; XIncludeFile "../controls/Property.pbi"
; XIncludeFile "../controls/Icon.pbi"
; XIncludeFile "../controls/Font.pbi"
; 
; Globals::Init()
; Font::Init()
; 
; Define *window.Window::Window_t = Window::New("ScreenCapture",200,200,400,100)
; Define *property.PropertyUI::PropertyUI_t = PropertyUI::New(*window\main,"Property",#Null)
; Define *controls.ControlProperty::ControlProperty_t = ControlProperty::New( *property, "Controls", "Controls",0,0,400,100)
; ControlProperty::AppendStart(*controls)
; ControlProperty::AddBoolControl(*controls, "Fuck","Fuck", #False, #Null)
; ControlProperty::AddFloatControl(*controls, "Suck", "Suck", 32, #Null)
; ; Define *record = ControlIcon::New(*controls\gadgetID, "Record", ControlIcon::#Icon_Play)
; ; Define *test = ControlButton::New(*controls\gadgetID, "FCK")
; ControlProperty::AppendStop(*controls)
; Define event.i
; 
; Repeat
;   event = WaitWindowEvent(1/60)
;   PropertyUI::OnEvent(*property, event)
; ;   Window::OnEvent(*window, event)
;   
; ;   PropertyUI::Draw(*property)
; Until event = #PB_Event_CloseWindow

XIncludeFile "../core/Application.pbi"

#WIDTH = 400
#HEIGHT = 100

Structure ScreenCaptureControl_t
  *property.ControlProperty::ControlProperty_t
  *icon.ControlIcon::ControlIcon_t
  *label.ControlText::ControlText_t
  *browser.ControlButton::ControlButton_t
  *filename.ControlEdit::ControlEdit_t
EndStructure

Global *app.Application::Application_t
Global control.ScreenCaptureControl_t

Declare ConnectRecordSignal(*ctrl.ScreenCaptureControl_t)
Declare ConnectStopSignal(*ctrl.ScreenCaptureControl_t)

Procedure OnStop(*ctrl.ScreenCaptureControl_t)
  ControlIcon::PlayIcon(*ctrl\icon)
  Control::Invalidate(*ctrl\icon)
  Signal::RemoveSlot(*ctrl\icon\on_click, 0)
  ConnectRecordSignal(*ctrl)
EndProcedure
Callback::DECLARECALLBACK(OnStop, Arguments::#PTR)

Procedure OnRecord(*ctrl.ScreenCaptureControl_t)
  ControlIcon::RecordIcon(*ctrl\icon)
  Control::Invalidate(*ctrl\icon)
  Signal::RemoveSlot(*ctrl\icon\on_click, 0)
  ConnectStopSignal(*ctrl)
  ;AddWindowTimer(EventWindow(), 
EndProcedure
Callback::DECLARECALLBACK(OnRecord, Arguments::#PTR)

Procedure ConnectRecordSignal(*ctrl.ScreenCaptureControl_t)
  Signal::CONNECTCALLBACK(*ctrl\icon\on_click, OnRecord, *ctrl)
EndProcedure

Procedure ConnectStopSignal(*ctrl.ScreenCaptureControl_t)
  Signal::CONNECTCALLBACK(*ctrl\icon\on_click, OnStop, *ctrl)
EndProcedure


Procedure OnBrowse(*ctrl.ScreenCaptureControl_t)
  Define folder.s = PathRequester("Choose Folder", "")
  MessageRequester("FOLDER : ", folder)
EndProcedure
Callback::DECLARECALLBACK(OnBrowse, Arguments::#PTR)

Procedure AddControls(*Me.ScreenCaptureControl_t)  
  *Me\property = ControlProperty::New(*app\window\main, "Control", "Control",0,0,#WIDTH, #HEIGHT)
  ControlProperty::AppendStart(*Me\property)
  *Me\icon = ControlIcon::New( *Me\property ,"Record", ControlIcon::#Icon_Play, #False, #False , 10, 10, 32, 32 )
  Signal::CONNECTCALLBACK(*Me\icon\on_click, OnRecord, *Me)
  ControlProperty::Append(*Me\property, *Me\icon)
 
;   *Me\label = ControlText::New(*Me\property, "Label", "Filename :", #False, 100, 10, 60, 30)
;   ControlProperty::Append(*Me\property, *Me\label)
;   
;    *Me\filename = ControlEdit::New(*Me\property, "Filename", "", #False, 160, 10, 200, 60)
;    ControlProperty::Append(*Me\property, *Me\filename)
;    *Me\browser = ControlButton::New(*Me\property, "Browse", "...", #False, 220, 10, 32,32)
;    Signal::CONNECTCALLBACK(*Me\browser\on_click, OnBrowse, *Me)
;    ControlProperty::Append(*Me\property, *Me\browser)
  
;   ControlProperty::RowEnd(*app\property)
;   
;   *app\folder.ControlEdit::ControlEdit_t = ControlProperty::AddStringControl(*app\property, "Folder", "", #Null)
;   Signal::CONNECTCALLBACK(*app\folder\on_change, OnFolderChange, *app, *app\folder)
;   *app\filename.ControlEdit::ControlEdit_t = ControlProperty::AddStringControl(*app\property, "Filename", "", #Null)
;   Signal::CONNECTCALLBACK(*app\filename\on_change, OnFilenameChange, *app, *app\filename)
;   
  
  
  ControlProperty::AppendStop(*Me\property)
  ControlProperty::Init(*Me\property)
      

EndProcedure


Procedure Update()
EndProcedure

Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()

*app = Application::New("ScreenCapture", #WIDTH, #HEIGHT)

AddControls(control)
Application::Loop(*app,@Update())




; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 118
; FirstLine = 70
; Folding = --
; EnableXP
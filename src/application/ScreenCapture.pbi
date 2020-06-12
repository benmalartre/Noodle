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
#HEIGHT = 84

Structure ScreenCaptureControl_t
  *ui.PropertyUI::PropertyUI_t
  *property.ControlProperty::ControlProperty_t
  *button.ControlIcon::ControlIcon_t
  
  *folder_group.ControlGroup::ControlGroup_t
  *folder.ControlEdit::ControlEdit_t
  *browser.ControlButton::ControlButton_t
  
  *filename_group.ControlGroup::ControlGroup_t
  *filename.ControlEdit::ControlEdit_t
  *extension.ControlText::ControlText_t
  
EndStructure

Global *app.Application::Application_t
Global control.ScreenCaptureControl_t

Declare ConnectRecordSignal(*ctrl.ScreenCaptureControl_t)
Declare ConnectStopSignal(*ctrl.ScreenCaptureControl_t)

Procedure OnStop(*ctrl.ScreenCaptureControl_t)
  ControlIcon::PlayIcon(*ctrl\button)
  Control::Invalidate(*ctrl\button)
  Signal::RemoveSlot(*ctrl\button\on_click, 0)
  ConnectRecordSignal(*ctrl)
EndProcedure
Callback::DECLARECALLBACK(OnStop, Arguments::#PTR)

Procedure OnRecord(*ctrl.ScreenCaptureControl_t)
  ControlIcon::RecordIcon(*ctrl\button)
  Control::Invalidate(*ctrl\button)
  Signal::RemoveSlot(*ctrl\button\on_click, 0)
  ConnectStopSignal(*ctrl)
EndProcedure
Callback::DECLARECALLBACK(OnRecord, Arguments::#PTR)

Procedure ConnectRecordSignal(*ctrl.ScreenCaptureControl_t)
  Signal::CONNECTCALLBACK(*ctrl\button\on_click, OnRecord, *ctrl)
EndProcedure

Procedure ConnectStopSignal(*ctrl.ScreenCaptureControl_t)
  Signal::CONNECTCALLBACK(*ctrl\button\on_click, OnStop, *ctrl)
EndProcedure

Procedure OnBrowse(*ctrl.ScreenCaptureControl_t)
  Define folder.s = PathRequester("Choose Folder", "")
  MessageRequester("FOLDER : ", folder)
EndProcedure
Callback::DECLARECALLBACK(OnBrowse, Arguments::#PTR)

Procedure AddControls(*Me.ScreenCaptureControl_t)  
  *Me\ui = PropertyUI::New(*app\window\main, "UI", #Null)
  PropertyUI::AppendStart(*Me\ui)
  
  *Me\property = *Me\ui\prop
  ControlProperty::Clear(*Me\property)
  Control::SetPercentage(*Me\property, 100, 100)
  ControlProperty::AppendStart(*Me\property)
  ControlProperty::RowStart(*Me\property)
  
  *Me\folder_group = ControlGroup::New(*Me\property, "FolderGroup", "Folder :",0,10,300,#HEIGHT-20)
  ControlGroup::AppendStart(*Me\folder_group)
  
  ControlGroup::RowStart(*Me\folder_group)
  *Me\folder = ControlEdit::New(*Me\property, "Folder", "", #False, 80, 20, 200, 30)
  ControlGroup::Append(*Me\folder_group, *Me\folder)
  
  *Me\browser = ControlButton::New(*Me\property, "Browse", "...", #False, #False, 320, 20, 40 , 30)
  Signal::CONNECTCALLBACK(*Me\browser\on_click, OnBrowse, *Me)
  ControlGroup::Append(*Me\folder_group, *Me\browser)
  
  ControlGroup::RowEnd(*Me\folder_group)
  ControlGroup::AppendStop(*Me\folder_group)
  ControlProperty::Append(*Me\property, *Me\folder_group)
  
  *Me\filename_group = ControlGroup::New(*Me\property, "FilenameGroup", "Filename :", 300,10,300,#HEIGHT-20)
  ControlGroup::AppendStart(*Me\filename_group)
  
  ControlGroup::RowStart(*Me\filename_group)
  *Me\filename = ControlEdit::New(*Me\filename_group, "Filename", "", #False, 80, 20, 200, 30)
  ControlGroup::Append(*Me\filename_group, *Me\filename)
  
  *Me\extension = ControlText::New(*Me\filename_group, "Extension", ".gif", #False, 280, 30, 60, 30)
  ControlGroup::Append(*Me\filename_group, *Me\extension)
  
  ControlGroup::RowEnd(*Me\filename_group)
  ControlGroup::AppendStop(*Me\filename_group)
  ControlProperty::Append(*Me\property, *Me\filename_group)
     
  *Me\button = ControlIcon::New( *Me\property ,"Record", ControlIcon::#Icon_Play, #False, #False , 360, 13, 60, 60 )
  Signal::CONNECTCALLBACK(*Me\button\on_click, OnRecord, *Me)
  ControlProperty::Append(*Me\property, *Me\button)
  
  ControlProperty::RowEnd(*Me\property)
  ControlProperty::AppendStop(*Me\property)
  Control::Invalidate(*Me\property)
  
  PropertyUI::AppendStop(*Me\ui)
  
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
; UIColor::SetTheme(UIColor::#DARK_THEME)
AddControls(control)

Application::Loop(*app,@Update())




; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 154
; FirstLine = 101
; Folding = --
; EnableXP
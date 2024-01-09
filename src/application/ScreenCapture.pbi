;================================================================================================
; CAPTURE TO GIF (WINDOWS ONLY)
;================================================================================================

XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/ScreenCapture.pbi"

#WIDTH = 500
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

Declare ConnectRecordCallback(*ctrl.ScreenCaptureControl_t)
Declare ConnectStopCallback(*ctrl.ScreenCaptureControl_t)

Procedure.s GetSettingsFile()
  Define home.s = GetHomeDirectory() + Globals::SLASH + "ScreenCapture"
  Define dir = ExamineDirectory(#PB_Any, home, "*.settings")
  If Not dir : CreateDirectory(home)
  Else : FinishDirectory(dir) : EndIf
 
  ProcedureReturn home+Globals::SLASH+"settings.txt"
EndProcedure

Procedure.s GetInitialFolder()
  Define filename.s = GetSettingsFile()
  Define file = ReadFile(#PB_Any, filename)
  Define folder.s = GetPathPart(filename)
  If Not file 
    file = CreateFile(#PB_Any, filename) 
    WriteString(file, folder)
  Else 
    folder = ReadString(file)
  EndIf
  CloseFile(file)
  ProcedureReturn folder
EndProcedure


Procedure OnStop(*ctrl.ScreenCaptureControl_t)
  ControlIcon::PlayIcon(*ctrl\button)
  Control::Invalidate(*ctrl\button)
  Callback::RemoveSlot(*ctrl\button\on_click, 0)
  ConnectRecordCallback(*ctrl)
EndProcedure
Callback::DECLARECALLBACK(OnStop, Args::#PTR)

Procedure OnRecord(*ctrl.ScreenCaptureControl_t)
  ControlIcon::RecordIcon(*ctrl\button)
  Control::Invalidate(*ctrl\button)
  Callback::RemoveSlot(*ctrl\button\on_click, 0)
  ConnectStopCallback(*ctrl)
EndProcedure
Callback::DECLARECALLBACK(OnRecord, Args::#PTR)

Procedure ConnectRecordCallback(*ctrl.ScreenCaptureControl_t)
  Callback::CONNECTCALLBACK(*ctrl\button\on_click, OnRecord, *ctrl)
EndProcedure

Procedure ConnectStopCallback(*ctrl.ScreenCaptureControl_t)
  Callback::CONNECTCALLBACK(*ctrl\button\on_click, OnStop, *ctrl)
EndProcedure

Procedure OnBrowse(*ctrl.ScreenCaptureControl_t)
  Define initialFolder.s = GetInitialFolder()
  Define folder.s = PathRequester("Choose Folder", initialFolder)
  If folder
    file = CreateFile(#PB_Any, GetSettingsFile())
    WriteString(file, folder)
    CloseFile(file)
    *ctrl\folder\value = folder
    Control::Invalidate(*ctrl\folder)
  EndIf
EndProcedure
Callback::DECLARECALLBACK(OnBrowse, Args::#PTR)

Procedure AddControls(*Me.ScreenCaptureControl_t)  
  Define initialFolder.s = GetInitialFolder()
  *Me\ui = PropertyUI::New(*app\window\main, "UI", #Null)
  PropertyUI::AppendStart(*Me\ui)
  
  *Me\property = *Me\ui\prop
  ControlProperty::Clear(*Me\property)
  Control::SetPercentage(*Me\property, 100, 100)
  ControlProperty::AppendStart(*Me\property)
  ControlProperty::RowStart(*Me\property)
  
  *Me\folder_group = ControlGroup::New(*Me\property, "FolderGroup", "Folder :",0,10,300,#HEIGHT-20)
  ControlGroup::AppendStart(*Me\folder_group)
  Control::SetPercentage(*Me\folder_group, 70, 100)
  
  ControlGroup::RowStart(*Me\folder_group)
  *Me\folder = ControlEdit::New(*Me\property, "Folder", initialFolder, #False, 80, 20, 200, 30)
  ControlGroup::Append(*Me\folder_group, *Me\folder)
  
  *Me\browser = ControlButton::New(*Me\property, "Browse", "...", #False, #False, 320, 20, 40 , 30)
  Callback::CONNECTCALLBACK(*Me\browser\on_click, OnBrowse, *Me)
  ControlGroup::Append(*Me\folder_group, *Me\browser)
  Control::SetFixed(*Me\browser, 100, -1)
  
  ControlGroup::RowEnd(*Me\folder_group)
  ControlGroup::AppendStop(*Me\folder_group)
  ControlProperty::Append(*Me\property, *Me\folder_group)
  
  *Me\filename_group = ControlGroup::New(*Me\property, "FilenameGroup", "Filename :", 300,10,300,#HEIGHT-20)
  ControlGroup::AppendStart(*Me\filename_group)
  Control::SetPercentage(*Me\filename_group, 30, 100)
  
  ControlGroup::RowStart(*Me\filename_group)
  *Me\filename = ControlEdit::New(*Me\filename_group, "Filename", "capture", #False, 80, 20, 200, 30)
  ControlGroup::Append(*Me\filename_group, *Me\filename)
  
  *Me\extension = ControlText::New(*Me\filename_group, "Extension", ".gif", #False, 280, 25, 60, 30)
  ControlGroup::Append(*Me\filename_group, *Me\extension)
  
  ControlGroup::RowEnd(*Me\filename_group)
  ControlGroup::AppendStop(*Me\filename_group)
  ControlProperty::Append(*Me\property, *Me\filename_group)
     
  *Me\button = ControlIcon::New( *Me\property ,"Record", ControlIcon::#Icon_Play, #False, #False , 360, 13, 60, 60 )
  Callback::CONNECTCALLBACK(*Me\button\on_click, OnRecord, *Me)
  ControlProperty::Append(*Me\property, *Me\button)
  
  ControlProperty::RowEnd(*Me\property)
  ControlProperty::AppendStop(*Me\property)
  Control::Invalidate(*Me\property)
  
  PropertyUI::AppendStop(*Me\ui)
  
EndProcedure


Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()

*app = Application::New("ScreenCapture", #WIDTH, #HEIGHT)
UIColor::SetTheme(UIColor::#DARK_THEME)
AddControls(control)

Application::Loop(*app,#Null, 0.1)




; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 86
; FirstLine = 74
; Folding = --
; EnableXP
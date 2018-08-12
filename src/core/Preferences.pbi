XIncludeFile "Arguments.pbi"

; DeclareModule Preferences
;   
;   Declare AddPreferences(*args.Argument_t)
; ;   Global preferences_directory.s
; ;   
; ;   Structure Preference_t
; ;     name.s
; ;     value.s
; ;   EndStructure
; ;   
; ;   Structure PreferenceFile_t
; ;     filename.s
; ;     List *preferences.Preference_t()
; ;   EndStructure
; ;   
; ;   Global 
;   
; EndDeclareModule

; If CreatePreferences(GetTemporaryDirectory()+"Preferences.prefs")
;   PreferenceGroup("Global")
;     WritePreferenceString("ApplicationName", "MP3 Player")
;     WritePreferenceString("Version", "1.1b")
; 
;   PreferenceComment(" This is the Window dimension")
;   PreferenceComment("")
; 
;   PreferenceGroup("Window")
;     WritePreferenceLong ("WindowX", 123)
;     WritePreferenceLong ("WindowY", 124)
;     WritePreferenceFloat("WindowZ", -125.5)
; 
;   ClosePreferences()
; EndIf
; 
; 
; OpenPreferences(GetTemporaryDirectory()+"Preferences.prefs")
; 
;   PreferenceGroup("Window")
;     Debug ReadPreferenceLong ("WindowX", 0)
;     Debug ReadPreferenceLong ("WindowY", 0)
;     Debug ReadPreferenceFloat("WindowZ", 0)
;     
;   PreferenceGroup("Global")
;     Debug ReadPreferenceString("ApplicationName", "")
;     Debug ReadPreferenceString("Version", "")
;     
; ClosePreferences()

Procedure AddPreference(category.s, key.s, *value.Arguments::Argument_t)
  PreferenceGroup(category)
  Select *value\type
    Case Arguments::#ARGS_BYTE
      WritePreferenceInteger(key, *value\a)
    Case Arguments::#ARGS_BOOL
      WritePreferenceInteger(key, *value\b)
    Case Arguments::#ARGS_CHAR
      WritePreferenceInteger(key, *value\c)
    Case Arguments::#ARGS_INT
      WritePreferenceInteger(key, *value\i)
    Case Arguments::#ARGS_LONG
      WritePreferenceLong(key, *value\l)
    Case Arguments::#ARGS_FLOAT
      WritePreferenceFloat(key, *value\f)
    Case Arguments::#ARGS_DOUBLE
      WritePreferenceDouble(key, *value\d)
    Case Arguments::#ARGS_V2F32
      WritePreferenceString(key, Vector2::ToString(*value\v2))
    Case Arguments::#ARGS_V3F32
      WritePreferenceString(key, Vector3::ToString(*value\v3))
    Case Arguments::#ARGS_V4F32
      ;       WritePreferenceString(key, Vector4::ToString(*value\v4))
      Debug "Vector4 Preference NOT Supported!!!"
    Case Arguments::#ARGS_C4F32
      WritePreferenceString(key, Color::ToString(*value\c4))
    Case Arguments::#ARGS_Q4F32
      WritePreferenceString(key, Quaternion::ToString(*value\q4))
    Case Arguments::#ARGS_M3F32
      WritePreferenceString(key, Matrix3::ToString(*value\m3))
    Case Arguments::#ARGS_M4F32
      WritePreferenceString(key, Matrix4::ToString(*value\m4))
    Case Arguments::#ARGS_PTR
      Debug "Pointer Preference NOT Supported!!!"
    Case Arguments::#ARGS_STRING
      WritePreferenceString(key, *value\str)
    Case Arguments::#ARGS_ARRAY
      Debug "Array Preference NOT Supported!!!"
  EndSelect
  
  
EndProcedure
  
Procedure GetPreference(category.s, key.s)

EndProcedure

  
Define preference_file_name.s = "preferences.prefs"
If CreatePreferences(preference_file_name)
  Define arg.Arguments::Argument_t
  Define category.s = "Libraries"
  Define name.s = "Use Bullet"
  Define use_bullet.b = #False
  arg\type = Arguments::#ARGS_BOOL
  arg\b = use_bullet
  AddPreference(category, "Use Bullet",@arg)
  
  arg\type = Arguments::#ARGS_V3F32
  Vector3::Set(arg\v3, 3,3,3)
  AddPreference("Scene", "Default Light Position",@arg)
  
  arg\type = Arguments::#ARGS_BOOL
  arg\b = #True
  AddPreference(category, "Use Alembic",@arg)
  ClosePreferences()
EndIf

If OpenPreferences(preference_file_name)
  ; Examen des Groupes
  ExaminePreferenceGroups()
  ; Pour chaque groupe
  While NextPreferenceGroup()
    Debug PreferenceGroupName(); On récupère son nom
    ; Examen des Clés pour le groupe en cours  
      ExaminePreferenceKeys()
    ; Pour chaque clé  
    While  NextPreferenceKey()                          
      Debug  Chr(9)+PreferenceKeyName() + " = " + PreferenceKeyValue(); On récupère son nom et sa valeur
    Wend

  Wend

  ;   PreferenceGroup("Librtaries")
  ;     Debug ReadPreferenceLong ("WindowX", 0)
  ;     Debug ReadPreferenceLong ("WindowY", 0)
  ;     Debug ReadPreferenceFloat("WindowZ", 0)
  ;     
  ;   PreferenceGroup("Global")
  ;     Debug ReadPreferenceString("ApplicationName", "")
  ;     Debug ReadPreferenceString("Version", "")
      
  ClosePreferences()
EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 103
; FirstLine = 92
; Folding = -
; EnableXP
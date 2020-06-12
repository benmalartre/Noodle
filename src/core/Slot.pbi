DeclareModule Slot
  Enumeration
    #SLOT_BOOL
    #SLOT_INT
    #SLOT_FLOAT
    #SLOT_STRING
    #SLOT_COLOR
    #SLOT_ENUM
  EndEnumeration
  
  Structure SlotKeyValue_t
    name.s
    value.i
  EndStructure
  
  Structure Slot_t
    type.i
    *datas
    Array items.SlotKeyValue_t(0)
    str.s
  EndStructure
  
  Declare Init(*attr.Slot_t, type.i, *datas)

EndDeclareModule

Module Slot
  Procedure Init(*attr.Slot_t, type.i, *datas)
    *attr\type = type
    *attr\datas = *datas
    *attr\str = ""
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 18
; Folding = -
; EnableXP
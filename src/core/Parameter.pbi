DeclareModule Parameter
  Enumeration 
    #Parameter_Boolean
    #Parameter_Integer
    #Parameter_Float
    #Parameter_String
  EndEnumeration
  
  Structure Parameter_t
    type.i
    StructureUnion
      value_b.b
      value_i.i
      value_f.f
      value_d.d
    EndStructureUnion
    value_str.s
    
    StructureUnion
      soft_min_value_i.i
      soft_min_value_f.f
      soft_min_value_d.d
    EndStructureUnion
    StructureUnion
      soft_max_value_i.i
      soft_max_value_f.f
      soft_max_value_d.d
    EndStructure
    
    StructureUnion
      hard_min_value_i.i
      hard_min_value_f.f
      hard_min_value_d.d
    EndStructureUnion
    StructureUnion
      hard_max_value_i.i
      hard_max_value_f.f
      hard_max_value_d.d
    EndStructure
  EndStructure
  
  Declare New(type.i,value.d,soft_min.d,soft_max.d,hard_min.d,hard_max.d)
  Declare Delete(*Me.Parameter_t)
  Declare.b GetValueB(*Me.Parameter_t)
  Declare.i GetValueI(*Me.Parameter_t)
  Declare.f GetValueF(*Me.Parameter_t)
  Declare.d GetValueD(*Me.Parameter_t)
  Declare SetValueB(*Me.Parameter_t,value.b)
  Declare SetValueI(*Me.Parameter_t,value.b)
  Declare SetValueF(*Me.Parameter_t,value.f)
  Declare SetValueD(*Me.Parameter_t,value.d)
EndDeclareModule


Module Parameter
  Procedure New(type.i,value.d,soft_min.d,soft_max.d,hard_min.d,hard_max.d)
    Protected *Me.Parameter_t = AllocateMemory(SizeOf(Parameter_t))
    *Me\type = type
    ProcedureReturn 
  EndProcedure
  
  Procedure Delete(*Me.Parameter_t)
    FreeMemory(*Me)
  EndProcedure
  
  Procedure.b GetValueB(*Me.Parameter_t)
    ProcedureReturn *Me\value_b
  EndProcedure
  
  Procedure.i GetValueI(*Me.Parameter_t)
    ProcedureReturn *Me\value_i
  EndProcedure
  
  Procedure.f GetValueF(*Me.Parameter_t)
    ProcedureReturn *Me\value_f
  EndProcedure
  
  Procedure.d GetValueD(*Me.Parameter_t)
    ProcedureReturn *Me\value_d
  EndProcedure
  
  Procedure SetValueB(*Me.Parameter_t,value.b)
    *Me\value_b = value
  EndProcedure
  
  Procedure SetValueI(*Me.Parameter_t,value.b)
    *Me\value_i = value
  EndProcedure
    
  Procedure SetValueF(*Me.Parameter_t,value.f)
    *Me\value_f = value
  EndProcedure
  
  Procedure SetValueD(*Me.Parameter_t,value.d)
    *Me\value_d = value
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 57
; FirstLine = 39
; Folding = ---
; EnableUnicode
; EnableXP
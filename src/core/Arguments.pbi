; ================================================================================
; ARGUMENTS MODULE DECLARATION
; ================================================================================
DeclareModule Arguments
  UseModule Math
  
  Enumeration
    #BYTE
    #BOOL
    #CHAR
    #INT
    #LONG
    #FLOAT
    #DOUBLE
    #V2F32
    #V3F32
    #V4F32
    #C4F32
    #Q4F32
    #M3F32
    #M4F32
    #PTR
    #STRING
    #ARRAY
  EndEnumeration
  
  Global Dim S_ARGS_TYPE.s(17)
  S_ARGS_TYPE(0)  = "BYTE"
  S_ARGS_TYPE(1)  = "BOOL"
  S_ARGS_TYPE(2)  = "CHAR"
  S_ARGS_TYPE(3)  = "INT"
  S_ARGS_TYPE(4)  = "LONG"
  S_ARGS_TYPE(5)  = "FLOAT"
  S_ARGS_TYPE(6)  = "DOUBLE"
  S_ARGS_TYPE(7)  = "V2F32"
  S_ARGS_TYPE(8)  = "V3F32"
  S_ARGS_TYPE(9)  = "V4F32"
  S_ARGS_TYPE(10) = "C4F32"
  S_ARGS_TYPE(11) = "Q4F32"
  S_ARGS_TYPE(12) = "M3F32"
  S_ARGS_TYPE(13) = "M4F32"
  S_ARGS_TYPE(14) = "PTR"
  S_ARGS_TYPE(15) = "STRING"
  S_ARGS_TYPE(16) = "ARRAY"
  
  ; ------------------------------------------------------------------------------
  ; ARGUMENT STRUCTURE
  ; ------------------------------------------------------------------------------
  Structure Argument_t
    StructureUnion
      a.a
      b.b
      c.c
      i.i
      l.l
      f.f
      d.d
      v2f.v2f32
      v3f.v3f32
      v4f.v4f32
      c4f.c4f32
      q4f.q4f32
      m3f.m3f32
      m4f.m4f32
      *p
    EndStructureUnion
    str.s
    type.c
  EndStructure
  
  ; ------------------------------------------------------------------------------
  ; ARGUMENTS STRUCTURE
  ; ------------------------------------------------------------------------------
  Structure Arguments_t
    Array args.Argument_t(0)
  EndStructure
  
  ; ------------------------------------------------------------------------------
  ; DECLARE
  ; ------------------------------------------------------------------------------
  Declare Copy(*dst.Arguments_t, *src.Arguments_t)
  Declare New(numArguments.i=0)
  Declare Delete(*args.Arguments_t)
  
  ; ------------------------------------------------------------------------------
  ; MACROS
  ; ------------------------------------------------------------------------------
  Macro VALUE_NAME(_name, _type)
    _name#VALUE#_type
  EndMacro

  Macro CREATEVALUE(_name, _type)
    Define Arguments::VALUENAME(_name, _type)._type
  EndMacro

  Macro CREATEVALUEPTR(_name)
    Define *_name#VALUE
  EndMacro

  Macro ARGCREATEVALUE(_funcname, _arg, _type, _index)
    Define __s.s = Globals::TOSTRING(_arg)
    Define __name.s = Globals::TOSTRING(_funcname#ARG#_index)
    Define __type.s = StringField(__s, 2, ".")
    
    If __type = "a"
      Arguments::CREATEVALUE(__name, a)
      _type = #ARGS_BYTE
    ElseIf __type = "b"
      Arguments::CREATEVALUE(__name, b)
      _type = #ARGS_BYTE
    ElseIf __type = "c"
      Arguments::CREATEVALUE(__name, c)
      _type =  #ARGS_CHAR
    ElseIf __type = "d"
      Arguments::CREATEVALUE(__name, d)
      _type =  #ARGS_DOUBLE
    ElseIf __type = "f"
      Arguments::CREATEVALUE(__name, f)
      _type =  #ARGS_FLOAT
    ElseIf __type = "i"
      Arguments::CREATEVALUE(__name, i)
      _type =  #ARGS_INT
    ElseIf __type = "l"
      Arguments::CREATEVALUE(__name, l)
      _type =  #ARGS_LONG
    ElseIf __type = "v2f32"
      Arguments::CREATEVALUE(__name, v2f32)
      _type =  #ARGS_V2F32
    ElseIf __type = "v3f32"
      Arguments::CREATEVALUE(__name, v3f32)
      _type =  #ARGS_V3F32
    ElseIf __type = "v4f32"
      Arguments::CREATEVALUE(__name, v4f32)
      _type =  #ARGS_V4F32
    ElseIf __type = "c4f32"
      Arguments::CREATEVALUE(__name, c4f32)
      _type = #ARGS_C4F32
    ElseIf __type = "q4f32"
      Arguments::CREATEVALUE(__name, q4f32)
      _type = #ARGS_Q4f32
    ElseIf __type = "m3f32"
      Arguments::CREATEVALUE(__name, m3f32)
      _type = #ARGS_M3F32
    ElseIf __type = "m4f32"
      Arguments::CREATEVALUE(__name, m4f32)
      _type = #ARGS_QUATERNION
    ElseIf __type = "m3f32"
      Arguments::CREATEVALUE(__name, s)
      _type = #PB_String
    Else
      Arguments::CREATEVALUEPTR(__name)
      _type = #PB_Integer
    EndIf
   
  EndMacro
  
  Macro GET(_v)
    CompilerSelect _type
      CompilerCase #ARGS_BYTE
        _A\args(_index)\b
      CompilerCase #PB_Byte
        _A\args(_index)\b
      CompilerCase #PB_Long
        _A\args(_index)\l
      CompilerCase #PB_Integer
        _A\args(_index)\i
      CompilerCase #PB_Float
        _A\args(_index)\f
      CompilerCase #PB_Double
        _A\args(_index)\d
    CompilerEndSelect
  EndMacro
  
  ; PASS ATRIBUTE VALUE
  Macro PASS(_arg, _value)
    CompilerSelect TypeOf(_arg)
      CompilerCase #PB_String
        _arg = Globals::QUOTE()_value#Globals::QUOTE()
      CompilerDefault
        _arg = _value
    CompilerEndSelect
  EndMacro
  
  ; SET EXISTING ATTRIBUTE
  Declare SET_INTERNAL(*args.Arguments::Arguments_t, type.l, size.i, index.i, *value)

  Macro SET(_args, _index, _value)
    CompilerIf TypeOf(value) = #PB_Structure
       Arguments::SET_INTERNAL(_args, #PB_Structure, #PB_Integer, _index, _value)
    CompilerElse
      Arguments::ADD_INTERNAL(_args, TypeOf(_value), SizeOf(_value), _index, @value)
    CompilerEndIf
  EndMacro

  Declare ADD_INTERNAL(*args.Arguments::Arguments_t, Type.l, size.i, *value)
  
  ; ADD NEW ATTRIBUTE
  Macro ADD(_args, value)
    CompilerIf TypeOf(value) = #PB_Structure
       Arguments::ADD_INTERNAL(_args, #PB_Structure, #PB_Integer, value)
    CompilerElse
      Arguments::ADD_INTERNAL(_args, TypeOf(value), SizeOf(value), @value)
    CompilerEndIf
  EndMacro
  
  ; DECLARE ATTRIBUTE
  Macro DECL(_type, _index)
    CompilerSelect _type
      CompilerCase Arguments::#BYTE
        __arg__#_index.a
      CompilerCase Arguments::#BOOL
        __arg__#_index.b
      CompilerCase Arguments::#CHAR
        __arg__#_index.c
      CompilerCase Arguments::#DOUBLE
        __arg__#_index.d
      CompilerCase Arguments::#FLOAT
        __arg__#_index.f
      CompilerCase Arguments::#INT
        __arg__#_index.i
      CompilerCase Arguments::#LONG
        __arg__#_index.l
      CompilerCase Arguments::#V2F32
        __arg__#_index.Math::v2f32
      CompilerCase Arguments::#V3F32
        __arg__#_index.Math::v3f32
      CompilerCase Arguments::#V4F32
        __arg__#_index.Math::v4f32
      CompilerCase Arguments::#C4F32
        __arg__#_index.Math::c4f32
      CompilerCase Arguments::#Q4F32
        __arg__#_index.Math::q4f32
      CompilerCase Arguments::#M3F32
        __arg__#_index.Math::cm3f32
      CompilerCase Arguments::#M4F32
        __arg__#_index.Math::m4f32
      CompilerCase Arguments::#STRING
        __arg__#_index.s
      CompilerDefault
        *__arg__#_index
    CompilerEndSelect
  EndMacro

EndDeclareModule

; ================================================================================
; ARGUMENTS MODULE IMPLEMENTATION
; ================================================================================
Module Arguments
  ; ------------------------------------------------------------------------------
  ; CONSTRUCTOR
  ; ------------------------------------------------------------------------------
  Procedure New(numArguments.i=0)
    Protected *args.Arguments_t = AllocateStructure(Arguments_t)
    ReDim *args\args(numArguments)
    ProcedureReturn *args
  EndProcedure
  
  ; ------------------------------------------------------------------------------
  ; DESTRUCTOR
  ; ------------------------------------------------------------------------------
  Procedure Delete(*args.Arguments_t)
    FreeStructure(*args)
  EndProcedure
  
  Procedure Copy(*dst.Arguments_t, *src.Arguments_t)
    Define nb = ArraySize(*src\args())
    ReDim *dst\args(nb)
    Define i
    For i=0 To nb-1
      *dst\args(i)\type = *src\args(i)\type
      Select *src\args(i)\type
        Case #BYTE
          *dst\args(i)\a = *src\args(i)\a
        Case #BOOL
          *dst\args(i)\b = *src\args(i)\b
        Case #CHAR
          *dst\args(i)\c = *src\args(i)\c
        Case #INT
          *dst\args(i)\i = *src\args(i)\i
        Case #LONG
          *dst\args(i)\l = *src\args(i)\l
        Case #FLOAT
          *dst\args(i)\f = *src\args(i)\f
        Case #DOUBLE
          *dst\args(i)\d = *src\args(i)\d
        Case #V2F32
          *dst\args(i)\v2f\x = *src\args(i)\v2f\x
          *dst\args(i)\v2f\y = *src\args(i)\v2f\y
        Case #V3F32
          *dst\args(i)\v3f\x = *src\args(i)\v3f\x
          *dst\args(i)\v3f\y = *src\args(i)\v3f\y
          *dst\args(i)\v3f\z = *src\args(i)\v3f\z
        Case #V4F32
          *dst\args(i)\v4f\x = *src\args(i)\v4f\x
          *dst\args(i)\v4f\y = *src\args(i)\v4f\y
          *dst\args(i)\v4f\z = *src\args(i)\v4f\z
          *dst\args(i)\v4f\w = *src\args(i)\v4f\w
        Case #C4F32
          *dst\args(i)\v4f\r = *src\args(i)\v4f\r
          *dst\args(i)\v4f\g = *src\args(i)\v4f\g
          *dst\args(i)\v4f\b = *src\args(i)\v4f\b
          *dst\args(i)\v4f\a = *src\args(i)\v4f\a
        Case #Q4F32
          *dst\args(i)\v4f\x = *src\args(i)\v4f\x
          *dst\args(i)\v4f\y = *src\args(i)\v4f\y
          *dst\args(i)\v4f\z = *src\args(i)\v4f\z
          *dst\args(i)\v4f\w = *src\args(i)\v4f\w
        Case #M3F32
          For i=0 To 8
            *dst\args(i)\m3f\v[i] = *src\args(i)\m3f\v[i]
          Next
        Case #M4F32
          For i=0 To 15
            *dst\args(i)\m3f\v[i] = *src\args(i)\m3f\v[i]
          Next
        Case #STRING
          *dst\args(i)\str = *src\args(i)\str
          *dst\args(i)\p = @*dst\args(i)\str
        Case #ARRAY
          *dst\args(i)\p = *src\args(i)\p
      EndSelect
    Next
  EndProcedure
  
  Procedure ADD_INTERNAL(*args.Arguments::Arguments_t, Type.l, size.i, *value)
    Protected index = ArraySize(*args\args())
    ReDim *args\args(index + 1)
    
    With *args\args(index)
      \type = Type
      If (Type = #PB_String)
        \str = PeekS(*value)
      Else
        CopyMemory(*value, @*args\args(index)+ OffsetOf(Arguments::Argument_t\a), size)
      EndIf
    EndWith
  EndProcedure
  
   Procedure SET_INTERNAL(*args.Arguments::Arguments_t, Type.l, size.i, index.i, *value)
    Protected numArgs = ArraySize(*args\args())
    If index >= 0 Or index < numArgs
      With *args\args(index)
        \type = Type
        If (Type = #PB_String)
          \str = PeekS(*value)
        Else
          CopyMemory(*value, @*args\args(index)+ OffsetOf(Arguments::Argument_t\a), size)
        EndIf
      EndWith
    EndIf
    
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 263
; FirstLine = 249
; Folding = ---
; EnableXP
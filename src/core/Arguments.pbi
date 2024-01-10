XIncludeFile "Types.pbi"
; ================================================================================
; ARGS MODULE DECLARATION
; ================================================================================
DeclareModule Args
  UseModule Math
  UseModule Types
  
  ; ------------------------------------------------------------------------------
  ; ARGUMENT STRUCTURE
  ; ------------------------------------------------------------------------------
  Structure Arg_t
    StructureUnion
      b.b
      c.c
      i.i
      l.l
      f.f
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
  Structure Args_t
    Array args.Arg_t(0)
  EndStructure
  
  ; ------------------------------------------------------------------------------
  ; DECLARE
  ; ------------------------------------------------------------------------------
  Declare Copy(*dst.Args_t, *src.Args_t)
  Declare New(numArgs.i=0)
  Declare Delete(*args.Args_t)
  
  ; ------------------------------------------------------------------------------
  ; MACROS
  ; ------------------------------------------------------------------------------
  Macro VALUE_NAME(_name, _type)
    _name#VALUE#_type
  EndMacro

  Macro CREATEVALUE(_name, _type)
    Define Args::VALUENAME(_name, _type)._type
  EndMacro

  Macro CREATEVALUEPTR(_name)
    Define *_name#VALUE
  EndMacro

  Macro ARGCREATEVALUE(_funcname, _arg, _type, _index)
    Define __s.s = Globals::TOSTRING(_arg)
    Define __name.s = Globals::TOSTRING(_funcname#ARG#_index)
    Define __type.s = StringField(__s, 2, ".")
    
    If __type = "a"
      Args::CREATEVALUE(__name, a)
      _type = #TYPE_BYTE
    ElseIf __type = "b"
      Args::CREATEVALUE(__name, b)
      _type = #TYPE_BYTE
    ElseIf __type = "c"
      Args::CREATEVALUE(__name, c)
      _type =  #TYPE_CHAR
    ElseIf __type = "f"
      Args::CREATEVALUE(__name, f)
      _type =  #TYPE_FLOAT
    ElseIf __type = "i"
      Args::CREATEVALUE(__name, i)
      _type =  #TYPE_INT
    ElseIf __type = "l"
      Args::CREATEVALUE(__name, l)
      _type =  #TYPE_LONG
    ElseIf __type = "v2f32"
      Args::CREATEVALUE(__name, v2f32)
      _type =  #TYPE_V2F32
    ElseIf __type = "v3f32"
      Args::CREATEVALUE(__name, v3f32)
      _type =  #TYPE_V3F32
    ElseIf __type = "v4f32"
      Args::CREATEVALUE(__name, v4f32)
      _type =  #TYPE_V4F32
    ElseIf __type = "c4f32"
      Args::CREATEVALUE(__name, c4f32)
      _type = #TYPE_C4F32
    ElseIf __type = "q4f32"
      Args::CREATEVALUE(__name, q4f32)
      _type = #TYPE_Q4f32
    ElseIf __type = "m3f32"
      Args::CREATEVALUE(__name, m3f32)
      _type = #TYPE_M3F32
    ElseIf __type = "m4f32"
      Args::CREATEVALUE(__name, m4f32)
      _type = #TYPE_QUATERNION
    ElseIf __type = "m3f32"
      Args::CREATEVALUE(__name, s)
      _type = #PB_String
    Else
      Args::CREATEVALUEPTR(__name)
      _type = #PB_Integer
    EndIf
   
  EndMacro
  
  Macro GET(_v)
    CompilerSelect _type
      CompilerCase #TYPE_BYTE
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
  Declare SET_INTERNAL(*args.Args::Args_t, type.l, size.i, index.i, *value)

  Macro SET(_args, _index, _value)
    CompilerIf TypeOf(value) = #PB_Structure
       Args::SET_INTERNAL(_args, #PB_Structure, #PB_Integer, _index, _value)
    CompilerElse
      Args::ADD_INTERNAL(_args, TypeOf(_value), SizeOf(_value), _index, @value)
    CompilerEndIf
  EndMacro

  Declare ADD_INTERNAL(*args.Args::Args_t, Type.l, size.i, *value)
  
  ; ADD NEW ATTRIBUTE
  Macro ADD(_args, value)
    CompilerIf TypeOf(value) = #PB_Structure
       Args::ADD_INTERNAL(_args, #PB_Structure, #PB_Integer, value)
    CompilerElse
      Args::ADD_INTERNAL(_args, TypeOf(value), SizeOf(value), @value)
    CompilerEndIf
  EndMacro
  
  ; DECLARE ATTRIBUTE
  Macro DECL(_type, _index)
    CompilerSelect _type
      CompilerCase Types::#TYPE_BOOL
        __arg__#_index.b
      CompilerCase Types::#TYPE_CHAR
        __arg__#_index.c
      CompilerCase Types::#TYPE_FLOAT
        __arg__#_index.f
      CompilerCase Types::#TYPE_INT
        __arg__#_index.i
      CompilerCase Types::#TYPE_LONG
        __arg__#_index.l
      CompilerCase Types::#TYPE_V2F32
        __arg__#_index.Math::v2f32
      CompilerCase Types::#TYPE_V3F32
        __arg__#_index.Math::v3f32
      CompilerCase Types::#TYPE_V4F32
        __arg__#_index.Math::v4f32
      CompilerCase Types::#TYPE_C4F32
        __arg__#_index.Math::c4f32
      CompilerCase Types::#TYPE_Q4F32
        __arg__#_index.Math::q4f32
      CompilerCase Types::#TYPE_M3F32
        __arg__#_index.Math::cm3f32
      CompilerCase Types::#TYPE_M4F32
        __arg__#_index.Math::m4f32
      CompilerCase Types::#TYPE_STR
        __arg__#_index.s
      CompilerDefault
        *__arg__#_index
    CompilerEndSelect
  EndMacro

EndDeclareModule

; ================================================================================
; ARGUMENTS MODULE IMPLEMENTATION
; ================================================================================
Module Args
  UseModule Types
  ; ------------------------------------------------------------------------------
  ; CONSTRUCTOR
  ; ------------------------------------------------------------------------------
  Procedure New(numArgs.i=0)
    Protected *args.Args_t = AllocateStructure(Args_t)
    ReDim *args\args(numArgs)
    ProcedureReturn *args
  EndProcedure
  
  ; ------------------------------------------------------------------------------
  ; DESTRUCTOR
  ; ------------------------------------------------------------------------------
  Procedure Delete(*args.Args_t)
    FreeStructure(*args)
  EndProcedure
  
  Procedure Copy(*dst.Args_t, *src.Args_t)
    Define nb = ArraySize(*src\args())
    ReDim *dst\args(nb)
    Define i
    For i=0 To nb-1
      *dst\args(i)\type = *src\args(i)\type
      Select *src\args(i)\type
        Case #TYPE_BOOL
          *dst\args(i)\b = *src\args(i)\b
        Case #TYPE_CHAR
          *dst\args(i)\c = *src\args(i)\c
        Case #TYPE_INT
          *dst\args(i)\i = *src\args(i)\i
        Case #TYPE_LONG
          *dst\args(i)\l = *src\args(i)\l
        Case #TYPE_FLOAT
          *dst\args(i)\f = *src\args(i)\f
        Case #TYPE_V2F32
          *dst\args(i)\v2f\x = *src\args(i)\v2f\x
          *dst\args(i)\v2f\y = *src\args(i)\v2f\y
        Case #TYPE_V3F32
          *dst\args(i)\v3f\x = *src\args(i)\v3f\x
          *dst\args(i)\v3f\y = *src\args(i)\v3f\y
          *dst\args(i)\v3f\z = *src\args(i)\v3f\z
        Case #TYPE_V4F32
          *dst\args(i)\v4f\x = *src\args(i)\v4f\x
          *dst\args(i)\v4f\y = *src\args(i)\v4f\y
          *dst\args(i)\v4f\z = *src\args(i)\v4f\z
          *dst\args(i)\v4f\w = *src\args(i)\v4f\w
        Case #TYPE_C4F32
          *dst\args(i)\v4f\r = *src\args(i)\v4f\r
          *dst\args(i)\v4f\g = *src\args(i)\v4f\g
          *dst\args(i)\v4f\b = *src\args(i)\v4f\b
          *dst\args(i)\v4f\a = *src\args(i)\v4f\a
        Case #TYPE_Q4F32
          *dst\args(i)\v4f\x = *src\args(i)\v4f\x
          *dst\args(i)\v4f\y = *src\args(i)\v4f\y
          *dst\args(i)\v4f\z = *src\args(i)\v4f\z
          *dst\args(i)\v4f\w = *src\args(i)\v4f\w
        Case #TYPE_M3F32
          For i=0 To 8
            *dst\args(i)\m3f\v[i] = *src\args(i)\m3f\v[i]
          Next
        Case #TYPE_M4F32
          For i=0 To 15
            *dst\args(i)\m3f\v[i] = *src\args(i)\m3f\v[i]
          Next
        Case #TYPE_STR
          *dst\args(i)\str = *src\args(i)\str
          *dst\args(i)\p = @*dst\args(i)\str
      EndSelect
    Next
  EndProcedure
  
  Procedure ADD_INTERNAL(*args.Args::Args_t, Type.l, size.i, *value)
    Protected index = ArraySize(*args\args())
    ReDim *args\args(index + 1)
    
    With *args\args(index)
      \type = Type
      If (Type = #PB_String)
        \str = PeekS(*value)
      Else
        CopyMemory(*value, @*args\args(index), size)
      EndIf
    EndWith
  EndProcedure
  
   Procedure SET_INTERNAL(*args.Args::Args_t, Type.l, size.i, index.i, *value)
    Protected numArgs = ArraySize(*args\args())
    If index >= 0 Or index < numArgs
      With *args\args(index)
        \type = Type
        If (Type = #PB_String)
          \str = PeekS(*value)
        Else
          CopyMemory(*value, @*args\args(index), size)
        EndIf
      EndWith
    EndIf
    
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 169
; FirstLine = 6
; Folding = ---
; EnableXP
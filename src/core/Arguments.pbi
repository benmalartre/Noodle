XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"

; ================================================================
; ARGUMENTS MODULE DECLARATION
; ================================================================
DeclareModule Arguments
  UseModule Math
  Enumeration
    #ARGS_BYTE
    #ARGS_BOOL
    #ARGS_CHAR
    #ARGS_INT
    #ARGS_LONG
    #ARGS_FLOAT
    #ARGS_DOUBLE
    #ARGS_V2F32
    #ARGS_V3F32
    #ARGS_V4F32
    #ARGS_C4F32
    #ARGS_Q4F32
    #ARGS_M3F32
    #ARGS_M4F32
    #ARGS_PTR
    #ARGS_STRING
    #ARGS_ARRAY

  EndEnumeration
  
  Global Dim S_ARGS_TYPE.s(17)
  S_ARGS_TYPE(0) = "BYTE"
  S_ARGS_TYPE(1) = "BOOL"
  S_ARGS_TYPE(2) = "CHAR"
  S_ARGS_TYPE(3) = "INT"
  S_ARGS_TYPE(4) = "LONG"
  S_ARGS_TYPE(5) = "FLOAT"
  S_ARGS_TYPE(6) = "DOUBLE"
  S_ARGS_TYPE(7) = "V2F32"
  S_ARGS_TYPE(8) = "V3F32"
  S_ARGS_TYPE(9) = "V4F32"
  S_ARGS_TYPE(10) = "C4F32"
  S_ARGS_TYPE(11) = "Q4F32"
  S_ARGS_TYPE(12) = "M3F32"
  S_ARGS_TYPE(13) = "M4F32"
  S_ARGS_TYPE(14) = "PTR"
  S_ARGS_TYPE(15) = "STRING"
  S_ARGS_TYPE(16) = "ARRAY"

  Structure Argument_t
    name.s
    type.i
    StructureUnion
      a.a
      b.b
      c.c
      i.i
      l.l
      f.f
      d.d
      v2.v2f32
      v3.v3f32
      c4.c4f32
      q4.q4f32
      m3.m3f32
      m4.m4f32
      *ptr
      *array.CArray::CArrayT
    EndStructureUnion
    str.s
  EndStructure
  
  Structure Arguments_t
    List *args.Argument_t()
    nb.i
  EndStructure
  
  Declare New()
  Declare Delete(*args.Arguments_t)
  Declare Echo(*args.Arguments_t)
  Declare Clear(*args.Arguments_t)
  
  Declare AddByte(*args.Arguments_t,name.s,value.a)
  Declare AddBool(*args.Arguments_t,name.s,value.b)
  Declare AddChar(*args.Arguments_t,name.s,value.c)
  Declare AddInt(*args.Arguments_t,name.s,value.i)
  Declare AddLong(*args.Arguments_t,name.s,value.l)
  Declare AddFloat(*args.Arguments_t,name.s,value.f)
  Declare AddDouble(*args.Arguments_t,name.s,value.d)
  Declare AddString(*args.Arguments_t,name.s,str.s)
  Declare AddV2F32(*args.Arguments_t,name.s,*value.v2f32)
  Declare AddV3F32(*args.Arguments_t,name.s,*value.v3f32)
  Declare AddC4F32(*args.Arguments_t,name.s,*value.c4f32)
  Declare AddQ4F32(*args.Arguments_t,name.s,*value.q4f32)
  Declare AddM3F32(*args.Arguments_t,name.s,*value.m3f32)
  Declare AddM4F32(*args.Arguments_t,name.s,*value.m4f32)
  Declare AddPtr(*args.Arguments_t,name.s,*ptr)
  Declare AddArray(*args.Arguments_t,name.s,*array.CArray::CArrayT)

  Declare SetByte(*args.Arguments_t,name.s,value.a,id.i)
  Declare SetBool(*args.Arguments_t,name.s,value.b,id.i)
  Declare SetChar(*args.Arguments_t,name.s,value.c,id.i)
  Declare SetInt(*args.Arguments_t,name.s,value.i,id.i)
  Declare SetLong(*args.Arguments_t,name.s,value.l,id.i)
  Declare SetFloat(*args.Arguments_t,name.s,value.f,id.i)
  Declare SetDouble(*args.Arguments_t,name.s,value.d,id.i)
  Declare SetString(*args.Arguments_t,name.s,str.s,id.i)
  Declare SetV2F32(*args.Arguments_t,name.s,*value.v2f32,id.i)
  Declare SetV3F32(*args.Arguments_t,name.s,*value.v3f32,id.i)
  Declare SetC4F32(*args.Arguments_t,name.s,*value.c4f32,id.i)
  Declare SetQ4F32(*args.Arguments_t,name.s,*value.q4f32,id.i)
  Declare SetM3F32(*args.Arguments_t,name.s,*value.m3f32,id.i)
  Declare SetM4F32(*args.Arguments_t,name.s,*value.m4f32,id.i)
  Declare SetPtr(*args.Arguments_t,name.s,*ptr,id.i)
  
  Declare Copy(*dest.Argument_t,*source.Argument_t)
;   Declare GetByName(*args.Arguments_t)

;   Declare DeleteArgByID(*args.Arguments_t,id.i)
;   Declare DeleteArgByName(*args.Arguments_t,id.i)
;   
EndDeclareModule

; ================================================================
; ARGUMENTS MODULE IMPLEMENTATION
; ================================================================
Module Arguments
  ; CONSTRUCTOR
  ;---------------------------------------------------------------
  Procedure New()
    Protected *args.Arguments_t = AllocateMemory(SizeOf(Arguments_t))
    InitializeStructure(*args,Arguments_t)
    ProcedureReturn *args  
  EndProcedure
  
  ; DESTRUCTOR
  ;---------------------------------------------------------------
  Procedure Delete(*args.Arguments_t)
    
    ForEach *args\args()
      ClearStructure(*args\args(),Argument_t)
      FreeMemory(*args\args())
    Next
    ClearStructure(*args,Arguments_t)
    FreeMemory(*args)
    
  EndProcedure
  
  ; ECHO
  ;---------------------------------------------------------------
  Procedure Echo(*args.Arguments_t)
    Protected x = 0
    ForEach *args\args()
      Debug "------------------------------------ARGUMENT ID "+Str(x)
      x+1
      Debug *args\args()\name
      Debug S_ARGS_TYPE(*args\args()\type)
      Select *args\args()\type
        Case #ARGS_BYTE
          Debug "Value BYTE : "+Str(*args\args()\a)
        Case #ARGS_BOOL
          Debug "Value BOOL : "+Str(*args\args()\b)
        Case #ARGS_CHAR
          Debug "Value CHAR : "+Str(*args\args()\b)
        Case #ARGS_INT
          Debug "Value INT : "+Str(*args\args()\i)
        Case #ARGS_LONG
          Debug "Value LONG : "+Str(*args\args()\l)
        Case #ARGS_FLOAT
          Debug "Value FLOAT : "+Str(*args\args()\f)
        Case #ARGS_DOUBLE
          Debug "Value DOUBLE : "+Str(*args\args()\d)
        Case #ARGS_V2F32
          With *args\args()\v2
            Debug "Value VECTOR2 : "+StrF(\x)+","+StrF(\y)
          EndWith
        Case #ARGS_V3F32
          With *args\args()\v3
            Debug "Value VECTOR3 : "+StrF(\x)+","+StrF(\y)+","+StrF(\z)
          EndWith
        Case #ARGS_C4F32
          With *args\args()\c4
            Debug "Value COLOR : "+StrF(\r)+","+StrF(\g)+","+StrF(\b)+","+StrF(\a)
          EndWith
        Case #ARGS_Q4F32
          With *args\args()\q4
            Debug "Value QUATERNION : "+StrF(\w)+","+StrF(\x)+","+StrF(\y)+","+StrF(\z)
          EndWith
        Case #ARGS_M3F32
          With *args\args()\m3
            Debug "Value MAtrix3 : "+StrF(\v[0])+","+StrF(\v[1])+","+StrF(\v[2])+","+StrF(\v[3])+StrF(\v[4])+","+StrF(\v[5])+","+StrF(\v[6])+","+StrF(\v[7])+StrF(\v[8])+","+StrF(\v[9])+","+StrF(\v[10])+","+StrF(\v[11])
          EndWith
          
        Case #ARGS_M4F32
          With *args\args()\m3
            Debug "Value MAtrix4 : "+StrF(\v[0])+","+StrF(\v[1])+","+StrF(\v[2])+","+StrF(\v[3])+StrF(\v[4])+","+StrF(\v[5])+","+StrF(\v[6])+","+StrF(\v[7])+StrF(\v[8])+","+StrF(\v[9])+","+StrF(\v[10])+","+StrF(\v[11])+StrF(\v[12])+StrF(\v[13])+","+StrF(\v[14])+","+StrF(\v[15])
          EndWith
          
        Case #ARGS_STRING
          Debug "Value STRING : "+*args\args()\str
        Case #ARGS_PTR
          Debug "Value PTR : "+Str(*args\args()\ptr)
      EndSelect
      
    Next
  EndProcedure
  
  ; DESTRUCTOR
  ;---------------------------------------------------------------
  Procedure Clear(*args.Arguments_t)
    ForEach *args\args()
      ClearStructure(*args\args(),Argument_t)
      FreeMemory(*args\args())
    Next
  EndProcedure
  
  
  ; ADD BYTE
  ;---------------------------------------------------------------
  Procedure AddByte(*args.Arguments_t,name.s,value.a)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_BYTE
    *arg\name = name
    *arg\a = value
    
    AddElement(*args\args())
    *args\args() = *arg
    *args\nb + 1
  EndProcedure
  
  ; ADD BOOL
  ;---------------------------------------------------------------
  Procedure AddBool(*args.Arguments_t,name.s,value.b)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_BOOL
    *arg\name = name
    *arg\b = value
    
    AddElement(*args\args())
    *args\args() = *arg
    *args\nb + 1
  EndProcedure
  
  ; ADD CHAR
  ;---------------------------------------------------------------
  Procedure AddChar(*args.Arguments_t,name.s,value.c)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_CHAR
    *arg\name = name
    *arg\c = value
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD INT
  ;---------------------------------------------------------------
  Procedure AddInt(*args.Arguments_t,name.s,value.i)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_INT
    *arg\name = name
    *arg\i = value
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD LONG
  ;---------------------------------------------------------------
  Procedure AddLong(*args.Arguments_t,name.s,value.l)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_LONG
    *arg\name = name
    *arg\l = value
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD FLOAT
  ;---------------------------------------------------------------
  Procedure AddFloat(*args.Arguments_t,name.s,value.f)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_FLOAT
    *arg\name = name
    *arg\f = value
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD DOUBLE
  ;---------------------------------------------------------------
  Procedure AddDouble(*args.Arguments_t,name.s,value.d)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_DOUBLE
    *arg\name = name
    *arg\d = value
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD V2F32
  ;---------------------------------------------------------------
  Procedure AddV2F32(*args.Arguments_t,name.s,*value.v2f32)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_V2F32
    *arg\name = name
    Vector2::SetFromOther(*arg\v2,*value)
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD V3F32
  ;---------------------------------------------------------------
  Procedure AddV3F32(*args.Arguments_t,name.s,*value.v3f32)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_V3F32
    *arg\name = name
    Vector3::SetFromOther(*arg\v3,*value)
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD C4F32
  ;---------------------------------------------------------------
  Procedure AddC4F32(*args.Arguments_t,name.s,*value.c4f32)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_C4F32
    *arg\name = name
    Color::SetFromOther(*arg\c4,*value)
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD Q4F32
  ;---------------------------------------------------------------
  Procedure AddQ4F32(*args.Arguments_t,name.s,*value.q4f32)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_Q4F32
    *arg\name = name
    Quaternion::SetFromOther(*arg\q4,*value)
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
  ; ADD M3F32
  ;---------------------------------------------------------------
  Procedure AddM3F32(*args.Arguments_t,name.s,*value.m3f32)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_M3F32
    *arg\name = name
    Matrix3::SetFromOther(*arg\m3,*value)
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
   ; ADD M4F32
  ;---------------------------------------------------------------
  Procedure AddM4F32(*args.Arguments_t,name.s,*value.m4f32)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_M4F32
    *arg\name = name
    Matrix4::SetFromOther(*arg\m4,*value)
    
   AddElement(*args\args())
   *args\args() = *arg
   *args\nb + 1
  EndProcedure
  
   ; ADD STRING
  ;---------------------------------------------------------------
  Procedure AddString(*args.Arguments_t,name.s,str.s)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_STRING
    *arg\name = name
    *arg\str = str
    
    AddElement(*args\args())
    *args\args() = *arg
    *args\nb + 1
  EndProcedure
  
  ; ADD PTR
  ;---------------------------------------------------------------
  Procedure AddPtr(*args.Arguments_t,name.s,*ptr)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_PTR
    *arg\name = name
    *arg\ptr = *ptr
    
    AddElement(*args\args())
    *args\args() = *arg
    *args\nb + 1
  EndProcedure
  
  ; ADD ARRAY
  ;---------------------------------------------------------------
  Procedure AddArray(*args.Arguments_t,name.s,*array.CArray::CArrayT)
    Protected *arg.Argument_t = AllocateMemory(SizeOf(Argument_t))
    *arg\type = #ARGS_ARRAY
    *arg\name = name
    *arg\array = *array
    
    AddElement(*args\args())
    *args\args() = *arg
    *args\nb + 1
  EndProcedure
  
  ; SET BYTE
  ;---------------------------------------------------------------
  Procedure SetByte(*args.Arguments_t,name.s,value.a,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_BYTE
      *arg\name = name
      *arg\a = value
    EndIf
  EndProcedure
  
  ;  SET BOOL
  ;---------------------------------------------------------------
  Procedure SetBool(*args.Arguments_t,name.s,value.b,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_BOOL
      *arg\name = name
      *arg\b = value
    EndIf
  EndProcedure
  
  ;  SET CHAR
  ;---------------------------------------------------------------
  Procedure SetChar(*args.Arguments_t,name.s,value.c,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_CHAR
      *arg\name = name
      *arg\c = value
    EndIf
  EndProcedure
  
  ;  SET INT
  ;---------------------------------------------------------------
  Procedure SetInt(*args.Arguments_t,name.s,value.i,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_INT
      *arg\name = name
      *arg\i = value
    EndIf
  EndProcedure
  
  ;  SET LONG
  ;---------------------------------------------------------------
  Procedure SetLong(*args.Arguments_t,name.s,value.l,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_LONG
      *arg\name = name
      *arg\l = value
    EndIf
  EndProcedure
  
  ;  SET FLOAT
  ;---------------------------------------------------------------
  Procedure SetFloat(*args.Arguments_t,name.s,value.f,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_FLOAT
      *arg\name = name
      *arg\f = value
    EndIf
  EndProcedure
  
  ;  SET DOUBLE
  ;---------------------------------------------------------------
  Procedure SetDouble(*args.Arguments_t,name.s,value.d,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_DOUBLE
      *arg\name = name
      *arg\d = value
    EndIf
  EndProcedure
  
  ;  SET V2F32
  ;---------------------------------------------------------------
  Procedure SetV2F32(*args.Arguments_t,name.s,*value.v2f32,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_V2F32
      *arg\name = name
      Vector2::SetFromOther(*arg\v2,*value)
    EndIf
  EndProcedure
  
  ;  SET V3F32
  ;---------------------------------------------------------------
  Procedure SetV3F32(*args.Arguments_t,name.s,*value.v3f32,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_V3F32
      *arg\name = name
      Vector3::SetFromOther(*arg\v3,*value)
    EndIf
  EndProcedure
  
;   ;  SET V4F32
;   ;---------------------------------------------------------------
;   Procedure SetV4F32(*args.Arguments_t,name.s,*value.v4f32,id.i)
;     If SelectElement(*args\args(),id)
;       Protected *arg.Argument_t = *args\args()
;       *arg\type = #ARGS_V4F32
;       *arg\name = name
;       Vector4::SetFromOther(*arg\d,*value)
;     EndIf
;   EndProcedure
  
  ;  SET C4F32
  ;---------------------------------------------------------------
  Procedure SetC4F32(*args.Arguments_t,name.s,*value.c4f32,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_C4F32
      *arg\name = name
      Color::SetFromOther(*arg\c4,*value)
    EndIf
  EndProcedure
  
  ;  SET Q4F32
  ;---------------------------------------------------------------
  Procedure SetQ4F32(*args.Arguments_t,name.s,*value.q4f32,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_Q4F32
      *arg\name = name
      Quaternion::SetFromOther(*arg\q4,*value)
    EndIf
  EndProcedure
  
  ;  SET M3F32
  ;---------------------------------------------------------------
  Procedure SetM3F32(*args.Arguments_t,name.s,*value.m3f32,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_M3F32
      *arg\name = name
      Matrix3::SetFromOther(*arg\m3,*value)
    EndIf
  EndProcedure
  
  ;  SET M4F32
  ;---------------------------------------------------------------
  Procedure SetM4F32(*args.Arguments_t,name.s,*value.m4f32,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_M4F32
      *arg\name = name
      Matrix4::SetFromOther(*arg\m4,*value)
    EndIf
  EndProcedure
  
  ;  SET M4F32
  ;---------------------------------------------------------------
  Procedure SetPtr(*args.Arguments_t,name.s,*value,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_PTR
      *arg\name = name
      *arg\ptr =*value
    EndIf
  EndProcedure
  
  ;  SET M4F32
  ;---------------------------------------------------------------
  Procedure SetString(*args.Arguments_t,name.s,value.s,id.i)
    If SelectElement(*args\args(),id)
      Protected *arg.Argument_t = *args\args()
      *arg\type = #ARGS_STRING
      *arg\name = name
      *arg\str = value
    EndIf
  EndProcedure
  
  ;  Copy
  ;---------------------------------------------------------------
  Procedure Copy(*dest.Argument_t,*src.Argument_t)
    *dest\type = *src\type
    *dest\name = *src\name
    Select *dest\type
      Case #ARGS_BYTE
        *dest\a = *src\a
      Case #ARGS_BOOL
        *dest\b = *src\b
      Case #ARGS_CHAR
        *dest\c = *src\c
      Case #ARGS_LONG
        *dest\l = *src\l
      Case #ARGS_INT
        *dest\i = *src\i
      Case #ARGS_FLOAT
        *dest\f = *src\f
      Case #ARGS_DOUBLE
        *dest\d = *src\d
      Case #ARGS_V2F32
        CopyMemory(*src\v2,*dest\v2,SizeOf(v2f32))
      Case #ARGS_V3F32
        CopyMemory(*src\v3,*dest\v3,SizeOf(v3f32))
;       Case #ARGS_V4F32
;         CopyMemory(*src\v4,*dest\v4,SizeOf(v4f32))
      Case #ARGS_C4F32
        CopyMemory(*src\c4,*dest\c4,SizeOf(c4f32))
      Case #ARGS_Q4F32
        CopyMemory(*src\q4,*dest\q4,SizeOf(q4f32))
      Case #ARGS_M3F32
        CopyMemory(*src\m3,*dest\m3,SizeOf(m3f32))
      Case #ARGS_M4F32
        CopyMemory(*src\m4,*dest\m4,SizeOf(m4f32))
      Case #ARGS_PTR
        *dest\ptr = *src\ptr
      Case #ARGS_ARRAY
        *dest\array = *src\array
      Case #ARGS_STRING
        *dest\str = *src\str
        
    EndSelect
    
  EndProcedure
  
  
EndModule
; 
; UseModule Math
; 
; window = OpenWindow(#PB_Any,0,0,800,600,"")
; Repeat
;   Define *args.Arguments::Arguments_t = Arguments::New()
;   Arguments::AddBool(*args,"Head",#True)
;   Arguments::AddBool(*args,"Hip",#False)
;   Arguments::AddString(*args,"Message","Hello this is an argument message!")
;   Define *mem = AllocateMemory(12000)
;   Arguments::AddPtr(*args,"Memory Pointer",*mem)
;   
;   Define v.v3f32
;   Vector3::Set(v,3.33,4.56,7.258)
;   Arguments::AddV3F32(*args,"Vec3",@v)
;   
;   Arguments::Echo(*args)
;   Arguments::Delete(*args)
; Until WaitWindowEvent() = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 574
; FirstLine = 529
; Folding = -------
; EnableXP
; EnableUnicode
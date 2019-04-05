XIncludeFile "Math.pbi"
XIncludeFile "Globals.pbi"
XIncludeFile "Array.pbi"
XIncludeFile "Object.pbi"


; ============================================================================
;  ATTRIBUTES MODULE DECLARATION
; ============================================================================
DeclareModule Attribute
  UseModule Math
  ; Node Data IO Types
  Enumeration
    #ATTR_TYPE_UNDEFINED        = %0000000000000000000000000
    #ATTR_TYPE_NEW              = %0000000000000000000000001
    #ATTR_TYPE_BOOL             = %0000000000000000000000010
    #ATTR_TYPE_LONG             = %0000000000000000000000100
    #ATTR_TYPE_INTEGER          = %0000000000000000000001000
    #ATTR_TYPE_ENUM             = %0000000000000000000010000
    #ATTR_TYPE_FLOAT            = %0000000000000000000100000
    #ATTR_TYPE_VECTOR2          = %0000000000000000001000000
    #ATTR_TYPE_VECTOR3          = %0000000000000000010000000
    #ATTR_TYPE_VECTOR4          = %0000000000000000100000000
    #ATTR_TYPE_COLOR            = %0000000000000001000000000
    #ATTR_TYPE_ROTATION         = %0000000000000010000000000
    #ATTR_TYPE_QUATERNION       = %0000000000000100000000000
    #ATTR_TYPE_MATRIX3          = %0000000000001000000000000
    #ATTR_TYPE_MATRIX4          = %0000000000010000000000000
    #ATTR_TYPE_STRING           = %0000000000100000000000000
    #ATTR_TYPE_SHAPE            = %0000000001000000000000000
    #ATTR_TYPE_TOPOLOGY         = %0000000010000000000000000
    #ATTR_TYPE_GEOMETRY         = %0000000100000000000000000
    #ATTR_TYPE_LOCATION         = %0000001000000000000000000
    #ATTR_TYPE_EXECUTE          = %0000010000000000000000000
    #ATTR_TYPE_GROUP            = %0000100000000000000000000
    #ATTR_TYPE_REFERENCE        = %0001000000000000000000000
    #ATTR_TYPE_FILE             = %0010000000000000000000000
    #ATTR_TYPE_AUDIO            = %0100000000000000000000000
    #ATTR_TYPE_CUSTOM           = %1000000000000000000000000
    #ATTR_TYPE_POLYMORPH        = %0000011111111111111111100
  EndEnumeration
  
  Enumeration
    #ATTR_TYPE_FRAMEBUFFER = 65
    #ATTR_TYPE_TEXTURE 
    #ATTR_TYPE_UNIFORM
    #ATTR_TYPE_SHADER
    #ATTR_TYPE_3DOBJECT
  EndEnumeration
  
  ; Node Data Structure
  Enumeration
    #ATTR_STRUCT_SINGLE
    #ATTR_STRUCT_ARRAY
    #ATTR_STRUCT_ANY
  EndEnumeration
  
  ; Node Data Context
  Enumeration
    #ATTR_CTXT_SINGLETON
    #ATTR_CTXT_COMPONENT0D
    #ATTR_CTXT_COMPONENT1D
    #ATTR_CTXT_COMPONENT2D
    #ATTR_CTXT_COMPONENT0D2D
    #ATTR_CTXT_GENERATOR
    #ATTR_CTXT_ANY
  EndEnumeration
  
  ; Colors
  #ATTR_COLOR_UNDEFINED         = $000000
  #ATTR_COLOR_BOOL              = $0066FF
  #ATTR_COLOR_INTEGER           = $116633
  #ATTR_COLOR_ENUM              = $119933
  #ATTR_COLOR_FLOAT             = $33CC33
  #ATTR_COLOR_VECTOR2           = $00CCFF
  #ATTR_COLOR_VECTOR3           = $00FFFF
  #ATTR_COLOR_VECTOR4           = $66FFFF
  #ATTR_COLOR_COLOR             = $0000FF
  #ATTR_COLOR_ROTATION          = $FFFFCC
  #ATTR_COLOR_QUATERNION        = $FFFF66
  #ATTR_COLOR_MATRIX3           = $FFFF00
  #ATTR_COLOR_MATRIX4           = $FFCC33
  #ATTR_COLOR_STRING            = $FF99CC
  #ATTR_COLOR_SHAPE             = $9933FF
  #ATTR_COLOR_TOPOLOGY          = $CCCCCC
  #ATTR_COLOR_GEOMETRY          = $6633FF
  #ATTR_COLOR_LOCATION          = $775555
  #ATTR_COLOR_EXECUTE           = $777777
  #ATTR_COLOR_REFERENCE         = $CC6611
  #ATTR_COLOR_FRAMEBUFFER       = $FF6600
  #ATTR_COLOR_TEXTURE           = $FF8844       
  #ATTR_COLOR_UNIFORM           = $FFCCAA 
  #ATTR_COLOR_SHADER            = $FFFFCC
  #ATTR_COLOR_3DOBJECT          = $00DDFF 
  #ATTR_COLOR_AUDIO             = $AA22CC
  #ATTR_COLOR_FILE              = $FF9933
  #ATTR_COLOR_CUSTOM            = $DDDDDD
  
  #ATTR_COLOR_BACKGROUND        = $666666
  #ATTR_COLOR_InputBackground   = $999999
  #ATTR_COLOR_InputEdit         = $FFFFFF
  #ATTR_COLOR_BorderUnselected  = $222222
  #ATTR_COLOR_BorderSelected    = $999999
  #ATTR_COLOR_SliderLeft        = $888888
  #ATTR_COLOR_SliderRight       = $555555
  #ATTR_COLOR_Text              = $111111
  #ATTR_COLOR_Title             = $221111
  #ATTR_COLOR_TitleBackground   = 1973790
  #ATTR_COLOR_PropertyBackground= 3289650

  Structure Attribute_t Extends Object::Object_t
    name.s
    datatype.i
    datastructure.i
    datacontext.i
    *data     ; Pointer to data
    atomic.b
    constant.b
    readonly.b
    writable.b
    dirty.b
  EndStructure
  
  Macro GetValue(_attribute)
    Select attribute\datatype
      Case #ATTR_TYPE_BOOL
        CArray::GetValueB(_attribute\data,0)
      Case #ATTR_TYPE_CHAR
        CArray::GetValueB(_attribute\data,0)
      Case #ATTR_TYPE_LONG
        CArray::GetValueL(_attribute\data,0)
      Case #ATTR_TYPE_INTEGER
        CArray::GetValueI(_attribute\data,0)
      Case #ATTR_TYPE_FLOAT
        CArray::GetValueF(_attribute\data,0)
      Case #ATRT_TYPE_DOUBLE
        CArray::GetValueD(_attribute\data,0)
    EndSelect
  EndMacro
  
  Declare New(name.s,datatype.i,datastructure.i,datacontext.i,*Data,atomic.b,read_only.b,constant.b,writable.b=#True)
  Declare Delete(*attribute.Attribute_t)
  Declare GetSize(*attribute.Attribute_t)
  Declare Get(*attribute.Attribute_t,*out_datas)
  Declare.s GetAsString(*attribute.Attribute_t)
  Declare.s GetAsBase64(*attribute.Attribute_t)
  Declare Set(*attribute.Attribute_t,*in_datas)
  Declare SetFromString(*attribute.Attribute_t,in_string.s)
  Declare SetFromBase64(*attribute.Attribute_t,in_base64.s)
  Declare ReadOnly(*attribute.Attribute_t)
  Declare PassThrough(*src.Attribute_t, *dst.Attribute_t)
;   Declare GetValue(*attribute.Attribute_t)
  Global CLASS.Class::Class_t
  
  DataSection:
    AttributeVT:
  EndDataSection
  
EndDeclareModule


; ============================================================================
;  ATTRIBUTES MODULE IMPLEMENTATION
; ============================================================================
Module Attribute
  UseModule Math
  ;---------------------------------------------------------------------------
  ; Get Size
  ;---------------------------------------------------------------------------
  Procedure GetSize(*attribute.Attribute_t)
    Protected *a.CArray::CArrayT
    Select *attribute\datastructure
      Case #ATTR_STRUCT_SINGLE
        Select *attribute\datacontext
          Case #ATTR_CTXT_SINGLETON
            ProcedureReturn 1
          Default
            *a = *attribute\data
            ProcedureReturn CArray::GetCount(*a)
        EndSelect
      Case #ATTR_STRUCT_ARRAY
        Select *attribute\datacontext
          Case #ATTR_CTXT_SINGLETON
            *a = *attribute\data
            ProcedureReturn CArray::GetCount(*a)
          Default
            ProcedureReturn 0
        EndSelect
    EndSelect
    
  ;   Select *attribute\datastructure
  ;     Case #ATTR_STRUCT_SINGLE
  ;       Select *attribute\datatype
  ;         ;Boolean
  ;         Case #ATTR_TYPE_BOOL
  ;           Select *attribute\datacontext
  ;             Case #ATTR_CTXT_SINGLETON
  ;               ProcedureReturn 1
  ;             Default
  ;               Protected bArray.CArrayBoo = *attribute\data
  ;               ProcedureReturn bArray\GetCount()
  ;           EndSelect
  ;           
  ;     Case #ATTR_STRUCT_ARRAY
  ;       
  ;   EndSelect
  ;   
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get
  ;---------------------------------------------------------------------------
  Procedure Get(*attribute.Attribute_t,*out_datas)
    
    Protected *out_data.CArray::CArrayT = *out_datas
    Protected *attr_data.CArray::CArrayT = *attribute\data
    CArray::SetCount(*out_data,CArray::GetCount(*attr_data))
    CArray::Copy(*out_data,*attr_data)
;     Select *attribute\datatype
;       Case #ATTR_TYPE_BOOL
;         Protected b_out_datas.CArray::CArrayBool = *out_datas 
;         Protected b_attr_datas.CArray::CArrayBool = *attribute\data
;         CArray::SetCount(b_out_datas,CArray::GetCount(attr_datas)
;         CArray::Copy(v_out_datas,attr_datas)
;       Case #ATTR_TYPE_LONG
;       Case #ATTR_TYPE_INTEGER
;       Case #ATTR_TYPE_FLOAT
;       Case #ATTR_TYPE_VECTOR3
;         Protected v_out_datas.CArray::CArrayV3F32 = *out_datas 
;         Protected attr_datas.CArray::CArrayV3F32 = *attribute\data
;         CArray::SetCount(v_out_datas,CArray::GetCount(attr_datas)
;         CArray::Copy(v_out_datas,attr_datas)
;         
;     EndSelect
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get As String
  ;---------------------------------------------------------------------------
  Procedure.s GetAsString(*attribute.Attribute_t)
    Protected it.i
    Protected out_string.s
    Debug "Get Attribute As String "+*attribute\name
    
    Select *attribute\datastructure
      Case #ATTR_STRUCT_SINGLE
        If *attribute\datacontext = #ATTR_CTXT_SINGLETON
          Select *attribute\datatype
            Case #ATTR_TYPE_BOOL
              out_string = Str(PeekB(*attribute\data))
            Case #ATTR_TYPE_INTEGER
              out_string = Str(PeekI(*attribute\data))
            Case #ATTR_TYPE_FLOAT
              out_string =StrF(PeekF(*attribute\data))
            Case #ATTR_TYPE_VECTOR2
              Protected v2.v2f32
              CopyMemory(*attribute\data,@v2,SizeOf(v2))
              out_string = "("+StrF(v2\x)+","+StrF(v2\y)+")"
            Case #ATTR_TYPE_VECTOR3
              Protected v3.v3f32
              CopyMemory(*attribute\data,v3,SizeOf(v3))
              out_string = "("+StrF(v3\x)+","+StrF(v3\y)+","+StrF(v3\z)+")"
            Case #ATTR_TYPE_QUATERNION
              Protected q.q4f32
              CopyMemory(*attribute\data,q,SizeOf(q))
              out_string = "("+StrF(q\x)+","+StrF(q\y)+","+StrF(q\z)+","+StrF(q\w)+")"
            Case #ATTR_TYPE_Matrix4
              Protected m4.m4f32
              CopyMemory(*attribute\data,m4,SizeOf(m4))
              out_string = "("+StrF(m4\v[0])+","+StrF(m4\v[1])+","+StrF(m4\v[2])+","+StrF(m4\v[3])+","+
                           StrF(m4\v[4])+","+StrF(m4\v[5])+","+StrF(m4\v[6])+","+StrF(m4\v[7])+","+
                           StrF(m4\v[8])+","+StrF(m4\v[9])+","+StrF(m4\v[10])+","+StrF(m4\v[11])+","+
                           StrF(m4\v[12])+","+StrF(m4\v[13])+","+StrF(m4\v[14])+","+StrF(m4\v[15])+")"
            Case #ATTR_TYPE_AUDIO
              out_string = "(Audio Attribute is NOT serializable)"
              
            Case #ATTR_TYPE_FILE
              out_string = PeekS(*attribute\data)
              
          EndSelect
        Else
         Select *attribute\datatype
          Case #ATTR_TYPE_BOOL
            Protected *b_datas.CArray::CArrayBool = *attribute\data
            For it=0 To CArray::GetCount(*b_datas)-1
              out_string +Str(CArray::GetValueB(*b_datas,it))+","
            Next
            
            Case #ATTR_TYPE_LONG
            Protected *l_datas.CArray::CArrayLong = *attribute\data
            For it=0 To CArray::GetCount(*l_datas)-1
              out_string +Str(CArray::GetValueL(*l_datas,it))+","
            Next
   
          Case #ATTR_TYPE_INTEGER
            Protected *i_datas.CArray::CArrayInt = *attribute\data
            For it=0 To CArray::GetCount(*i_datas)-1
              out_string +Str(CArray::GetValueI(*i_datas,it))+","
            Next
          Case #ATTR_TYPE_FLOAT
            Protected *f_datas.CArray::CArrayFloat = *attribute\data
            For it=0 To CArray::GetCount(*f_datas)-1
              out_string +StrF(CArray::GetValueF(*f_datas,it))+","
            Next
          Case #ATTR_TYPE_VECTOR2
            Protected *v2_datas.CArray::CArrayV2F32 = *attribute\data
            Protected *v2.v2f32
            For it=0 To CArray::GetCount(*v2_datas)-1
              *v2 = CArray::GetValue(*v2_datas, it)
              out_string +"("+StrF(*v2\x)+","+StrF(*v2\y)+"),"
            Next
            
          Case #ATTR_TYPE_VECTOR3
            Protected *v3_datas.CArray::CArrayV3F32 = *attribute\data
            Protected *v3.v3f32
            For it=0 To CArray::GetCount(*v3_datas)-1
              *v3 = CArray::GetValue(*v3_datas,it)
              out_string +"("+StrF(*v3\x)+","+StrF(*v3\y)+","+StrF(*v3\z)+"),"
            Next
            
          Case #ATTR_TYPE_QUATERNION
            Protected *q_datas.CArray::CArrayQ4F32 = *attribute\data
            Protected *q.q4f32
            For it=0 To CArray::GetCount(*q_datas)-1
              *q = CArray::GetValue(*q_datas,it)
              out_string +"("+StrF(*q\x)+","+StrF(*q\y)+","+StrF(*q\z)+","+StrF(*q\w)+"),"
            Next
            
          Case #ATTR_TYPE_MATRIX4
            Protected *m4_datas.CArray::CArrayQ4F32 = *attribute\data
            Protected *m4.m4f32
            For it=0 To CArray::GetCount(*m4_datas)-1
              *m4 = CArray::GetValue(*m4_datas,it)
              out_string +"("+StrF(*m4\v[0])+","+StrF(*m4\v[1])+","+StrF(*m4\v[2])+","+StrF(*m4\v[3])+","+
                          StrF(*m4\v[4])+","+StrF(*m4\v[5])+","+StrF(*m4\v[6])+","+StrF(*m4\v[7])+","+
                          StrF(*m4\v[8])+","+StrF(*m4\v[9])+","+StrF(*m4\v[10])+","+StrF(*m4\v[11])+","+
                          StrF(*m4\v[12])+","+StrF(*m4\v[13])+","+StrF(*m4\v[14])+","+StrF(*m4\v[15])+"),"
            Next
        EndSelect
        ;Remove Last Character
          out_string = Left(out_string,Len(out_string)-1)
        EndIf
      
        ProcedureReturn out_string 
        
        
      ; 2D Array
      Case #ATTR_STRUCT_ARRAY
        If *attribute\datacontext = #ATTR_CTXT_SINGLETON
          Select *attribute\datatype
          Case #ATTR_TYPE_BOOL
            *b_datas.CArray::CArrayBool = *attribute\data
            For it=0 To CArray::GetCount(*b_datas)-1
              out_string +Str(PeekB(CArray::GetValue(*b_datas,it)))+","
            Next
          Case #ATTR_TYPE_LONG
             *l_datas.CArray::CArrayLong = *attribute\data
            For it=0 To CArray::GetCount(*l_datas)-1
              out_string +Str(PeekL(CArray::GetValue(*l_datas,it)))+","
            Next
   
          Case #ATTR_TYPE_INTEGER
             *i_datas.CArray::CArrayInt = *attribute\data
            For it=0 To CArray::GetCount(*i_datas)-1
              out_string +Str(PeekI(CArray::GetValue(*i_datas,it)))+","
            Next
          Case #ATTR_TYPE_FLOAT
             *f_datas.CArray::CArrayFloat = *attribute\data
            For it=0 To CArray::GetCount(*f_datas)-1
              out_string +StrF(PeekF(CArray::GetValue(*f_datas,it)))+","
            Next
            
          Case #ATTR_TYPE_VECTOR3
             *v3_datas.CArray::CArrayV3F32 = *attribute\data
             *v3.v3f32
            For it=0 To CArray::GetCount(*v3_datas)-1
              *v3 = CArray::GetValue(*v3_datas,it)
              out_string +"("+StrF(*v3\x)+","+StrF(*v3\y)+","+StrF(*v3\z)+"),"
            Next
          EndSelect
        Else
        out_string = Left(out_string,Len(out_string)-1)
        EndIf
        ProcedureReturn out_string 
    EndSelect
    
   
  EndProcedure
  
  ;-----------------------------------------------------
  ; Get As Base64
  ;-----------------------------------------------------
  Procedure.s GetAsBase64(*attribute.Attribute_t)
    
   Protected it.i
   Protected out_string.s
   Protected size_t.i
   Protected *mem 
    
    
    Select *attribute\datastructure
      Case #ATTR_STRUCT_SINGLE
        If *attribute\datacontext = #ATTR_CTXT_SINGLETON
          Select *attribute\datatype
            Case #ATTR_TYPE_BOOL
              out_string = Str(PeekB(*attribute\data))
            Case #ATTR_TYPE_INTEGER
              out_string = Str(PeekI(*attribute\data))
            Case #ATTR_TYPE_FLOAT
              out_string =StrF(PeekF(*attribute\data))
            Case #ATTR_TYPE_VECTOR2
              Protected v2.v2f32
              CopyMemory(*attribute\data,@v2,SizeOf(v2))
              out_string = "("+StrF(v2\x)+","+StrF(v2\y)+")"
            Case #ATTR_TYPE_VECTOR3
              Protected v3.v3f32
              CopyMemory(*attribute\data,@v3,SizeOf(v3))
              out_string = "("+StrF(v3\x)+","+StrF(v3\y)+","+StrF(v3\z)+")"
            Case #ATTR_TYPE_QUATERNION
              Protected q.q4f32
              CopyMemory(*attribute\data,@q,SizeOf(q))
              out_string = "("+StrF(q\x)+","+StrF(q\y)+","+StrF(q\z)+","+StrF(q\w)+")" 
            Case #ATTR_TYPE_MATRIX4
              Protected m4.m4f32
              CopyMemory(*attribute\data,@m4,SizeOf(m4))
              out_string = "("+StrF(m4\v[0])+","+StrF(m4\v[1])+","+StrF(m4\v[2])+","+StrF(m4\v[3])+","+
                           StrF(m4\v[4])+","+StrF(m4\v[5])+","+StrF(m4\v[6])+","+StrF(m4\v[7])+","+
                           StrF(m4\v[8])+","+StrF(m4\v[9])+","+StrF(m4\v[10])+","+StrF(m4\v[11])+","+
                           StrF(m4\v[12])+","+StrF(m4\v[13])+","+StrF(m4\v[14])+","+StrF(m4\v[15])+")"
          EndSelect
          
        Else
            Protected *baseArray.CArray::CArrayT = *attribute\data
            size_t = CArray::GetCount(*baseArray) * CArray::GetItemSize(*baseArray)
            If size_t>0
              CompilerIf #PB_Compiler_Version < 560
                out_string = Space(size_t*1.4)
                Base64Encoder(CArray::GetPtr(*baseArray,0),size_t,@out_string,size_t*1.4)
              CompilerElse
                out_string = Base64Encoder(CArray::GetPtr(*baseArray,0),size_t)
              CompilerEndIf
              
            EndIf
           
        EndIf
        
      ; 2D Array
      Case #ATTR_STRUCT_ARRAY
        If *attribute\datacontext = #ATTR_CTXT_SINGLETON
          *baseArray.CArray::CArrayT = *attribute\data
            size_t = CArray::GetCount(*baseArray) * CArray::GetItemSize(*baseArray)
            If size_t>0
              CompilerIf #PB_Compiler_Version < 560
                out_string = Space(size_t*1.4)
                Base64Encoder(CArray::GetPtr(*baseArray,0),size_t,@out_string,size_t*1.4)
              CompilerElse
                out_string = Base64Encoder(CArray::GetPtr(*baseArray,0),size_t)
              CompilerEndIf
              
          EndIf
        Else
        
        EndIf
    EndSelect
    ProcedureReturn out_string 
  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Set
  ;-----------------------------------------------------
  Procedure Set(*attribute.Attribute_t,*in_datas)
    Select *attribute\datastructure
      Case #ATTR_STRUCT_SINGLE
        Select *attribute\datatype
          Case #ATTR_TYPE_BOOL
            Select *attribute\datacontext
              Case #ATTR_CTXT_SINGLETON
                PokeB(*attribute\data,PeekB(*in_datas))
              Default
                Protected *bOutArray.CArray::CArrayBool = *attribute\data
                Protected *bInArray.CArray::CArrayBool = *in_datas
                CArray::SetCount(*bOutArray,CArray::GetCount(*bInArray))
                CArray::Copy(*bOutArray,*bInArray)

                
            EndSelect
            
          Case #ATTR_TYPE_INTEGER
          Case #ATTR_TYPE_FLOAT
          Case #ATTR_TYPE_VECTOR3
            Protected *v_in_datas.CArray::CArrayV3F32 = *in_datas
            Protected *attr_datas.CArray::CArrayV3F32 = *attribute\data
            CArray::SetCount(*attr_datas,CArray::GetCount(*v_in_datas))
            CArray::Copy(*attr_datas,*v_in_datas)
            
        EndSelect
      Case #ATTR_STRUCT_ARRAY
        
    EndSelect
    
  EndProcedure
  
  ;-----------------------------------------------------
  ; Set From String
  ;-----------------------------------------------------
  Procedure SetFromString(*attribute.Attribute_t,in_string.s)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Set From Base64
  ;-----------------------------------------------------
  Procedure SetFromBase64(*attribute.Attribute_t,in_base64.s)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Read Only
  ;-----------------------------------------------------
  Procedure ReadOnly(*attribute.Attribute_t)
    ProcedureReturn *attribute\readonly
  EndProcedure

  ;-----------------------------------------------------
  ; Copy
  ;-----------------------------------------------------
  Procedure PassThrough(*src.Attribute_t, *dst.Attribute_t)
    Debug "PASS THROUGH CALLED : "+*src\name +" ---> "+*dst\name
    If *src\atomic And *dst\atomic
      Select *src\datatype
        Case Attribute::#ATTR_TYPE_BOOL
          PokeB(*dst\data, PeekB(*dst\data))
        Case Attribute::#ATTR_TYPE_LONG
          PokeL(*dst\data, PeekL(*dst\data))
        Case Attribute::#ATTR_TYPE_INTEGER
          PokeI(*dst\data, PeekI(*dst\data))
        Case Attribute::#ATTR_TYPE_FLOAT
          PokeF(*dst\data, PeekF(*dst\data))
        Case Attribute::#ATTR_TYPE_VECTOR2
          CopyMemory(*src\data, *dst\data, SizeOf(Math::v2f32))
        Case Attribute::#ATTR_TYPE_VECTOR3
          CopyMemory(*src\data, *dst\data, SizeOf(Math::v3f32))
        Case Attribute::#ATTR_TYPE_VECTOR4
          CopyMemory(*src\data, *dst\data, SizeOf(Math::v4f32))
        Case Attribute::#ATTR_TYPE_COLOR
          CopyMemory(*src\data, *dst\data, SizeOf(Math::c4f32))
        Case Attribute::#ATTR_TYPE_QUATERNION
          CopyMemory(*src\data, *dst\data, SizeOf(Math::q4f32))
        Case Attribute::#ATTR_TYPE_MATRIX3
          CopyMemory(*src\data, *dst\data, SizeOf(Math::m3f32))
        Case Attribute::#ATTR_TYPE_MATRIX4
          CopyMemory(*src\data, *dst\data, SizeOf(Math::m4f32))
        Case Attribute::#ATTR_TYPE_LOCATION
          CopyMemory(*src\data, *dst\data, SizeOf(Math::locf32))
        Default
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
            CopyMemory(*src\data, *dst\data, 4)
          CompilerElse
            CopyMemory(*src\data, *dst\data, 8)
          CompilerEndIf 
      EndSelect
    ElseIf Not *src\atomic And Not *dst\atomic
      If CArray::GetCount(*src\data) : CArray::Copy(*dst\data,*src\data) : EndIf
    Else
      If *src\atomic
        Define *dstArray.CArray::CArrayT = *dst\data
        CopyMemory(*src\data,*dstArray\data, *dstArray\itemSize)
      Else
        Define *srcArray.CArray::CArrayT = *src\data
        CopyMemory(*srcArray\data,*dst\data, *srcArray\itemSize)
      EndIf

    EndIf

  EndProcedure
  
  
  ;-----------------------------------------------------------------------------
  ; Destructor
  ;-----------------------------------------------------------------------------
  Procedure Delete(*Me.Attribute_t)
    ClearStructure(*Me,Attribute_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  Procedure New(name.s,datatype.i,datastructure.i,datacontext.i,*ptr,atomic.b,read_only.b,constant.b,writable.b=#True)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Attribute_t = AllocateMemory(SizeOf(Attribute_t))
    Object::INI(Attribute)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\datatype      = datatype
    *Me\datastructure = datastructure
    *Me\datacontext   = datacontext
    *Me\data          = *ptr
    *Me\name          = name
    *Me\atomic        = atomic
    *Me\constant      = constant
    *Me\readonly      = read_only
    *Me\writable      = writable
   
    ProcedureReturn *Me
    
  EndProcedure
  
  Class::DEF( Attribute )
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 526
; FirstLine = 521
; Folding = ----
; EnableXP
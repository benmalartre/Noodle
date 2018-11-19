XIncludeFile "Math.pbi"
XIncludeFile "Memory.pbi"

;========================================================================================
; CArray Module Declaration
;========================================================================================
DeclareModule CArray
  UseModule Math
  Enumeration
    #ARRAY_BOOL
    #ARRAY_CHAR
    #ARRAY_INT
    #ARRAY_LONG
    #ARRAY_FLOAT
    #ARRAY_PTR
    #ARRAY_V2F32
    #ARRAY_V3F32
    #ARRAY_C4F32
    #ARRAY_C4U8
    #ARRAY_Q4F32
    #ARRAY_M3F32
    #ARRAY_M4F32
    #ARRAY_TRF32
    #ARRAY_STR
  EndEnumeration
  
  #SIZE_BOOL  = 1
  #SIZE_CHAR  = 2
  #SIZE_LONG  = 4
  #SIZE_FLOAT = 4
  #SIZE_DOUBLE= 8
  
  CompilerIf #PB_Compiler_Version = #PB_Processor_x86
    #SIZE_INT   = 4
    #SIZE_PTR   = 4
  CompilerElse
    #SIZE_INT   = 8
    #SIZE_PTR   = 8
  CompilerEndIf
  #SIZE_V2F32 = 8
  
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    #SIZE_V3F32 = 16
    #SIZE_TRF32 = 48
  CompilerElse
    #SIZE_V3F32 = 12
    #SIZE_TRF32 = 40
  CompilerEndIf  
  
  #SIZE_C4F32 = 16
  #SIZE_C4U8  = 4
  #SIZE_Q4F32 = 16
  #SIZE_M3F32 = 36
  #SIZE_M4F32 = 64
  
  Structure CArrayT
    type.i
    itemSize.i
    itemCount.i
    aligned.b
    *data
  EndStructure
  
  Structure CArrayBool Extends CArrayT
  EndStructure
  
  Structure CArrayChar Extends CArrayT
  EndStructure
  
  Structure CArrayInt Extends CArrayT
  EndStructure
  
  Structure CArrayLong Extends CArrayT
  EndStructure
  
  Structure CArrayFloat Extends CArrayT
  EndStructure
  
  Structure CArrayV2F32 Extends CArrayT
  EndStructure
  
  Structure CArrayV3F32 Extends CArrayT
  EndStructure
  
  Structure CArrayC4F32 Extends CArrayT
  EndStructure
  
  Structure CArrayC4U8 Extends CArrayT
  EndStructure
  
  Structure CArrayQ4F32 Extends CArrayT
  EndStructure
  
  Structure CArrayM3F32 Extends CArrayT
  EndStructure
  
  Structure CArrayM4F32 Extends CArrayT
  EndStructure
  
  Structure CArrayTRF32 Extends CArrayT
  EndStructure
  
  Structure CArrayPtr Extends CArrayT
  EndStructure
  
  Structure CArrayStr Extends CArrayT
    List _str.s()
  EndStructure
  
  ;----------------------------------------------------------------
  ; GetValue
  ;----------------------------------------------------------------
  Macro GetValue(_array,_index)
      (_array\data+ ((_index) * _array\itemSize))
  EndMacro
  
  ;----------------------------------------------------------------
  ; GetValueB
  ;----------------------------------------------------------------
  Macro GetValueB(_array,_index)
    PeekB(_array\data+((_index)* _array\itemSize))
  EndMacro
  
  ;----------------------------------------------------------------
  ; GetValueC
  ;----------------------------------------------------------------
  Macro GetValueC(_array,_index)
    PeekC(_array\data+((_index)* _array\itemSize))
  EndMacro
  
  ;----------------------------------------------------------------
  ; GetValueI
  ;----------------------------------------------------------------
  Macro GetValueI(_array,_index)
    PeekI(_array\data+((_index)* _array\itemSize))
  EndMacro
  
  ;----------------------------------------------------------------
  ; GetValueL
  ;----------------------------------------------------------------
  Macro GetValueL(_array,_index)
    PeekL(_array\data+((_index) * _array\itemSize))
  EndMacro
  
  ;----------------------------------------------------------------
  ; GetValueF
  ;----------------------------------------------------------------
  Macro GetValueF(_array,_index)
    PeekF(_array\data+((_index)* _array\itemSize))
  EndMacro
  
  
  ;----------------------------------------------------------------
  ; GetValueD
  ;----------------------------------------------------------------
  Macro GetValueD(_array,_index)
    PeekD(_array\data+((_index)* _array\itemSize))
  EndMacro
  
  ;----------------------------------------------------------------
  ; GetValuePtr
  ;----------------------------------------------------------------
  Macro GetValuePtr(_array,_index)
    PeekI(_array\data+((_index)* _array\itemSize))
  EndMacro
  
  ;----------------------------------------------------------------
  ; SetValue
  ;----------------------------------------------------------------
  Macro SetValue(_array,_index,_value)
     Define *__value_ptr = _value
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount
        CopyMemory(*__value_ptr,_array\data+(_index)* _array\itemSize,_array\itemSize)
      EndIf
    CompilerElse
      CopyMemory(*__value_ptr,_array\data+(_index)* _array\itemSize,_array\itemSize)
    CompilerEndIf
  EndMacro
 
  ;----------------------------------------------------------------
  ; SetValueB
  ;----------------------------------------------------------------
  Macro SetValueB(_array,_index,_value)
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount
        PokeB(_array\data+(_index)* _array\itemSize,_value)
      EndIf
    CompilerElse
      PokeB(_array\data+(_index)* _array\itemSize,_value)
    CompilerEndIf
  EndMacro
  
   ;----------------------------------------------------------------
  ; SetValueC
  ;----------------------------------------------------------------
  Macro SetValueC(_array,_index,_value)
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount 
        PokeC(_array\data+(_index)* _array\itemSize,_value)
      EndIf
    CompilerElse
      PokeC(_array\data+(_index)* _array\itemSize,_value)
    CompilerEndIf
  EndMacro
  
  ;----------------------------------------------------------------
  ; SetValueI
  ;----------------------------------------------------------------
  Macro SetValueI(_array,_index,_value)
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount 
        PokeI(_array\data+(_index)* _array\itemSize,_value)
      EndIf
    CompilerElse
      PokeI(_array\data+(_index)* _array\itemSize,_value)
    CompilerEndIf
  EndMacro
  
  ;----------------------------------------------------------------
  ; SetValueL
  ;----------------------------------------------------------------
  Macro SetValueL(_array,_index,_value)
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount 
        PokeL(_array\data+(_index)* _array\itemSize,_value)
      EndIf
    CompilerElse
      PokeL(_array\data+(_index)* _array\itemSize,_value)
    CompilerEndIf
  EndMacro
  
  ;----------------------------------------------------------------
  ; SetValueF
  ;----------------------------------------------------------------
  Macro SetValueF(_array,_index,_value)
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount 
        PokeF(_array\data+(_index)* _array\itemSize,_value)
      EndIf
    CompilerElse
      PokeF(_array\data+(_index)* _array\itemSize,_value)
    CompilerEndIf
  EndMacro
  
  ;----------------------------------------------------------------
  ; SetValuePtr
  ;----------------------------------------------------------------
  Macro SetValuePtr(_array,_index,_value)
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount 
        PokeI(_array\data+(_index)* _array\itemSize,_value)
      EndIf
    CompilerElse
      PokeI(_array\data+(_index)* _array\itemSize,_value)
    CompilerEndIf
  EndMacro
  
  ;----------------------------------------------------------------
  ; SetValueStr
  ;----------------------------------------------------------------
  Macro SetValueStr(_array,_index,_value)
    Define *__sa.CArray::CArrayStr = _array
    CompilerIf Defined(ARRAY_GUARDED, #PB_Constant)
      If _index>=0 And _index<_array\itemCount 
        SelectElement(*__sa\_str(), _index)
        *__sa\_str() = _value
      EndIf
    CompilerElse
      SelectElement(*__sa\_str(), _index)
      *__sa\_str() = _value
    CompilerEndIf
  EndMacro
  
  Declare GetPtr(*array.CArrayT, index.i=0)
  Declare.s GetValueStr(*array.CArrayStr, index.i=0)
  Declare.s GetAsString(*array.CArrayT, label.s="")
  Declare Copy(*array.CArrayT, *src.CArrayT)
  Declare Append(*array.CArrayT,*value)
  Declare AppendB(*array.CArrayT,value.b)
  Declare AppendC(*array.CArrayT,value.c)
  Declare AppendI(*array.CArrayT,value.i)
  Declare AppendL(*array.CArrayT,value.l)
  Declare AppendF(*array.CArrayT,value.f)
  Declare AppendPtr(*array.CArrayT,*value)
  Declare AppendStr(*array.CArrayT,value.s)
  Declare AppendArray(*array.CArrayT,*other.CArrayT)
  Declare AppendUnique(*array.CArrayT,*unique)
  Declare AppendUniqueStr(*array.CArrayT,unique.s)
  Declare Fill(*array.CArrayT, *value)
  Declare FillB(*array.CArrayT, b.b)
  Declare FillC(*array.CArrayT, c.c)
  Declare FillL(*array.CArrayT, l.l)
  Declare FillI(*array.CArrayT, i.i)
  Declare FillF(*array.CArrayT, f.f)
  Declare GetCount(*array.CArrayT)
  Declare SetCount(*array.CArrayT,count.i)
  Declare GetItemSize(*array.CArrayT)
  Declare Delete(*array.CArrayT)
  Declare Find(*array,*value,*ID)
  Declare Remove(*array,ID)
  Declare Echo(*array.CArrayT, label.s="")
  Declare Alert(*array.CArrayT, label.s="")
  
  Declare newCArrayBool()
  Declare newCArrayChar()
  Declare newCArrayInt()
  Declare newCArrayLong()
  Declare newCArrayFloat()
  Declare newCArrayV2F32()
  Declare newCArrayV3F32()
  Declare newCArrayC4U8()
  Declare newCArrayC4F32()
  Declare newCArrayQ4F32()
  Declare newCArrayM3F32()
  Declare newCArrayTRF32()
  Declare newCArrayM4F32()
  Declare newCArrayPtr()
  Declare newCArrayStr()
EndDeclareModule

;========================================================================================
; CArray Module Implementation
;========================================================================================
Module CArray
  
  ;----------------------------------------------------------------
  ; GetPtr
  ;----------------------------------------------------------------
  Procedure GetPtr(*array.CArrayT, index.i = 0)
    ProcedureReturn *array\data + index * *array\itemSize
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValueStr
  ;----------------------------------------------------------------
  Procedure.s GetValueStr(*array.CArrayStr, index.i=0)
    SelectElement(*array\_str(),index)
    ProcedureReturn *array\_str()
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Copy
  ;----------------------------------------------------------------
  Procedure Copy(*array.CArray::CArrayT,*src.CArray::CArrayT)
    If Not *array\itemCount = *src\itemCount Or Not *array\itemSize = *src\itemSize
      *array\itemSize = *src\itemSize
      CArray::SetCount(*array,*src\itemCount)
    EndIf
    
    CopyMemory(*src\data,*array\data,*src\itemCount * *src\itemSize)
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Get Item SIze
  ;----------------------------------------------------------------
  Procedure GetItemSize(*array.CArrayT)
    ProcedureReturn *array\itemSize 
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Append
  ;----------------------------------------------------------------
  Procedure Append(*array.CArrayT,*item)
    
    Protected nb = *array\itemCount
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(*array\itemSize)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * *array\itemSize + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1) * *array\itemSize)
    EndIf
    
    CopyMemory(*item,*array\data + nb * *array\itemSize, *array\itemSize)
    *array\itemCount + 1

  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendB
  ;----------------------------------------------------------------
  Procedure AppendB(*array.CArrayT,item.b)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(#SIZE_BOOL)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * #SIZE_BOOL + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1)* #SIZE_BOOL)
    EndIf
    
    PokeB(*array\data+nb* *array\itemSize,item)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendC
  ;----------------------------------------------------------------
  Procedure AppendC(*array.CArrayT,item.c)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(#SIZE_CHAR)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * #SIZE_CHAR + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1)* #SIZE_CHAR)
    EndIf
    
    PokeC(*array\data+nb* *array\itemSize,item)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendI
  ;----------------------------------------------------------------
  Procedure AppendI(*array.CArrayT,item.i)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(#SIZE_INT)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * #SIZE_INT + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1)* #SIZE_INT)
    EndIf
    
    PokeI(*array\data+nb* *array\itemSize,item)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendL
  ;----------------------------------------------------------------
  Procedure AppendL(*array.CArrayT,item.l)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(#SIZE_LONG)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * #SIZE_LONG + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1)* #SIZE_LONG)
    EndIf
    
    PokeL(*array\data+nb* *array\itemSize,item)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendF
  ;----------------------------------------------------------------
  Procedure AppendF(*array.CArrayT,item.f)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(#SIZE_FLOAT)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * #SIZE_FLOAT + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1)* #SIZE_FLOAT)
    EndIf
    
    PokeF(*array\data+nb* *array\itemSize,item)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendPtr
  ;----------------------------------------------------------------
  Procedure AppendPtr(*array.CArrayT,*item)
    Protected nb = *array\itemCount
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(#SIZE_PTR)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * #SIZE_PTR + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1)* #SIZE_PTR)
    EndIf
    
    PokeI(*array\data+nb* #SIZE_PTR,*item)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendStr
  ;----------------------------------------------------------------
  Procedure AppendStr(*array.CArrayT,item.s)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = Memory::AllocateAlignedMemory(#SIZE_PTR)
    Else
      Define *oldmemory = *array\data - PeekB(*array\data + nb * #SIZE_PTR + 1)
      *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nb+1)* #SIZE_PTR)
    EndIf
    
    Protected *sa.CArrayStr = *array
    AddElement(*sa\_str())
    *sa\_str() = item
    PokeI(*array\data+nb* *array\itemSize,@*sa\_str())
    *array\itemCount + 1
  EndProcedure
  
  
  ;----------------------------------------------------------------
  ; AppendArray
  ;----------------------------------------------------------------
  Procedure AppendArray(*array.CArrayT,*other.CArrayT)
    Protected nba = *array\itemCount
    Protected nbo = *other\itemCount
    
    If *array\itemSize = *other\itemSize
      If *array\data = #Null
        *array\data = Memory::AllocateAlignedMemory(nbo* *array\itemSize)
      Else
        Define *oldmemory = *array\data - PeekB(*array\data + nba * *array\itemSize + 1)
        *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,(nbo+nba)* *array\itemSize)
      EndIf
      
      CopyMemory(*other\data,*array\data+nba* *array\itemSize,nbo * *array\itemSize)
      *array\itemCount + nbo
      
      If *array\type = #ARRAY_STR
        Protected *saa.CArrayStr = *array
        Protected *sao.CArrayStr = *other
        
        LastElement(*saa\_str())
        ForEach *sao\_str()
          AddElement(*saa\_str())
          *saa\_str() = *sao\_str()
        Next
      EndIf
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendUnique
  ;----------------------------------------------------------------
  Procedure AppendUnique(*array.CArrayT,*unique)
    Protected nbi = *array\itemCount
    Protected i
    Protected *mem
    If *array\type < #ARRAY_V2F32
      Select *array\type
        Case #ARRAY_BOOL
          AppendB(*array,PeekB(*unique))
          
        Case #ARRAY_CHAR
          For i = 0 To nbi-1
            If PeekC(*unique) = CArray::GetValueC(*array,i)
              ; Item Already in Array
              ProcedureReturn 
            EndIf
          Next
          AppendC(*array,PeekC(*unique))
          
        Case #ARRAY_INT
           For i = 0 To nbi-1
            If PeekI(*unique) = CArray::GetValueI(*array,i)
              ; Item Already in Array
              ProcedureReturn 
            EndIf
          Next
          AppendI(*array,PeekI(*unique))
          
        Case #ARRAY_LONG
           For i = 0 To nbi-1
            If PeekL(*unique) = CArray::GetValueL(*array,i)
              ; Item Already in Array
              ProcedureReturn 
            EndIf
          Next
          AppendL(*array,PeekL(*unique))
          
        Case #ARRAY_FLOAT
           For i = 0 To nbi-1
            If PeekF(*unique) = CArray::GetValueF(*array,i)
              ; Item Already in Array
              ProcedureReturn 
            EndIf
          Next
          AppendF(*array,PeekF(*unique))
          
        Case #ARRAY_PTR
          For i = 0 To nbi-1
            If *unique = CArray::GetValuePtr(*array,i)
              ; Item Already in Array
              ProcedureReturn 
            EndIf
          Next
          AppendPtr(*array,*unique)
      EndSelect
      
      
    Else
        
      For i = 0 To nbi-1
        If *unique = CArray::GetValueI(*array,i)
          ; Item Already in Array
          ProcedureReturn 
        EndIf
        
      Next
      Append(*array,*unique)
    EndIf
    
    
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendUniqueSTr
  ;----------------------------------------------------------------
  Procedure AppendUniqueStr(*array.CArrayT,unique.s)
    If Not *array\type = #ARRAY_STR : ProcedureReturn : EndIf
    Protected  *array_str.CArray::CArrayStr = *array
    Protected nbi = *array\itemCount
    Protected i

    For i = 0 To nbi-1
      If unique = CArray::GetValueStr(*array_str,i)
        ; Item Already in Array
        ProcedureReturn 
      EndIf
    Next
    AppendStr(*array_str,unique)   
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Fill
  ;----------------------------------------------------------------
  Procedure Fill(*array.CArrayT,*value)
    If *array\type = #ARRAY_STR : ProcedureReturn : EndIf
    
    Protected i
    For i = 0 To *array\itemCount-1
      CopyMemory(*value, GetPtr(*array, i),GetItemSize(*array))
    Next
  EndProcedure
  
  ;----------------------------------------------------------------
  ; FillA
  ;----------------------------------------------------------------
  Procedure FillB(*array.CArrayT,b.b)
    If Not *Array\type = #ARRAY_BOOL : ProcedureReturn : EndIf
    
    Protected i
    For i = 0 To *array\itemCount-1
      PokeB(GetPtr(*array, i), b)
    Next
  EndProcedure
 
  
  ;----------------------------------------------------------------
  ; FillC
  ;----------------------------------------------------------------
  Procedure FillC(*array.CArrayT,c.c)
    If Not *Array\type = #ARRAY_CHAR : ProcedureReturn : EndIf
    
    Protected i
    For i = 0 To *array\itemCount-1
      PokeC(GetPtr(*array, i), c)
    Next
  EndProcedure
  
  ;----------------------------------------------------------------
  ; FillL
  ;----------------------------------------------------------------
  Procedure FillL(*array.CArrayT,l.l)
    If Not *Array\type = #ARRAY_LONG : ProcedureReturn : EndIf
    
    Protected i
    For i = 0 To *array\itemCount-1
      PokeL(GetPtr(*array, i), l)
    Next
  EndProcedure
  
  ;----------------------------------------------------------------
  ; FillI
  ;----------------------------------------------------------------
  Procedure FillI(*array.CArrayT,i.i)
    If Not *Array\type = #ARRAY_INT : ProcedureReturn : EndIf
    
    Protected j
    For j = 0 To *array\itemCount-1
      PokeI(GetPtr(*array, j), i)
    Next
  EndProcedure
  
  ;----------------------------------------------------------------
  ; FillF
  ;----------------------------------------------------------------
  Procedure FillF(*array.CArrayT,f.f)
    If Not *Array\type = #ARRAY_FLOAT : ProcedureReturn : EndIf
    
    Protected j
    For j = 0 To *array\itemCount-1
      PokeF(GetPtr(*array, j), f)
    Next
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetCount
  ;----------------------------------------------------------------
  Procedure GetCount(*array.CArrayT)
    ProcedureReturn *array\itemCount
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetCount
  ;----------------------------------------------------------------
  Procedure SetCount(*array.CArrayT,count.i)
    If count = 0
      If *array\data And MemorySize(*array\data)
        Memory::FreeAlignedMemory(*array\data, *array\itemCount * *array\itemSize)
        *array\data = #Null
      EndIf
      *array\itemCount = 0
    Else
      If Not count = *array\itemCount 
        If *array\data = #Null
          *array\data = Memory::AllocateAlignedMemory(count * *array\itemSize)
        Else
          Define *oldmemory = *array\data - PeekB(*array\data + *array\itemCount * *array\itemSize + 1)
          *array\data = Memory::ReAllocateAlignedMemory(*oldmemory,count* *array\itemSize)
        EndIf
        *array\itemCount = count
      EndIf
    EndIf
    
    If *array\type = #Array_STR
      Protected i
      Protected *sa.CArrayStr = *array
      Protected size.i = ListSize(*sa\_str())
      If count>size
        For i=0 To count-size-1
          AddElement(*sa\_str())
        Next
      Else
        LastElement(*sa\_str())
        For i=0 To size-count-1
          DeleteElement(*sa\_str())
        Next   
      EndIf
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Find
  ;----------------------------------------------------------------
  Procedure Find(*array.CArrayT,*value,*ID)
    Protected i
    If *array\type < #ARRAY_PTR
      Select *array\type
        Case #ARRAY_BOOL
          For i=0 To GetCount(*array)-1
            If GetValueB(*array,i) = PeekB(*value)
              PokeI(*ID,i)
              Break
            EndIf
          Next
          
        Case #ARRAY_CHAR
          For i=0 To GetCount(*array)-1
            If GetValueC(*array,i) = PeekC(*value)
              PokeI(*ID,i)
              Break
            EndIf
          Next
          
        Case #ARRAY_LONG
          For i=0 To GetCount(*array)-1
            If GetValueL(*array,i) = PeekL(*value)
              PokeI(*ID,i)
              Break
            EndIf
          Next
          
        Case #ARRAY_INT
          For i=0 To GetCount(*array)-1
            If GetValueI(*array,i) = PeekI(*value)
              PokeI(*ID,i)
              Break
            EndIf
          Next
          
        Case #ARRAY_FLOAT
          For i=0 To GetCount(*array)-1
            If GetValueF(*array,i) = PeekF(*value)
              PokeI(*ID,i)
              Break
            EndIf
          Next
      EndSelect
    Else
      For i=0 To GetCount(*array)-1
        If GetValuePtr(*array,i) = *value
          PokeI(*ID,i)
          Break
        EndIf
      Next
    EndIf
    
    
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Remove
  ;----------------------------------------------------------------
  Procedure Remove(*array.CArrayT,ID)
    Protected i
    If *array\type < #ARRAY_PTR
      Select *array\type
        Case #ARRAY_BOOL
          For i=ID To GetCount(*array)-2
            SetValueB(*array,i,GetValueB(*array,i+1))
          Next
          
        Case #ARRAY_CHAR
          For i=ID To GetCount(*array)-2
            SetValueC(*array,i,GetValueC(*array,i+1))
          Next
          
        Case #ARRAY_LONG
          For i=ID To GetCount(*array)-2
            SetValueL(*array,i,GetValueL(*array,i+1))
          Next
          
        Case #ARRAY_INT
          For i=ID To GetCount(*array)-2
            SetValueI(*array,i,GetValueI(*array,i+1))
          Next
          
        Case #ARRAY_FLOAT
          For i=ID To GetCount(*array)-2
            SetValueF(*array,i,GetValueF(*array,i+1))
          Next
      EndSelect
      
    Else
      For i=ID To GetCount(*array)-2
        SetValuePtr(*array,i,GetValuePtr(*array,i+1))
      Next
    EndIf  
    SetCount(*array,GetCount(*array)-1)
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Get As String
  ;----------------------------------------------------------------
  Procedure.s GetAsString(*array.CArrayT, label.s="")
    Protected datas.s
    If Not label = ""
      datas +"------------- ARRAY -------------"+Chr(10)
    Else
      datas +"------------- "+label+" -------------"+Chr(10)
    EndIf
    Protected i
    Select *array\type
      Case #ARRAY_BOOL
        datas+"TYPE: BOOL"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        For i=0 To *array\itemCount-1
          datas+Str(GetValueB(*array, i))+","
        Next
      Case #ARRAY_CHAR
        datas+"TYPE: CHAR"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        For i=0 To *array\itemCount-1
          datas+Str(GetValueC(*array,i))+","
        Next
      Case #ARRAY_INT
        datas+"TYPE: INT"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        For i=0 To *array\itemCount-1
          datas+Str(GetValueI(*array,i))+","
        Next
      Case #ARRAY_LONG
        datas+"TYPE: LONG"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        For i=0 To *array\itemCount-1
          datas+Str(GetValueL(*array,i))+","
        Next
      Case #ARRAY_FLOAT
        datas+"TYPE: FLOAT"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        For i=0 To *array\itemCount-1
          datas+StrF(GetValueF(*array,i))+","
        Next
      Case #ARRAY_V2F32
        datas+"TYPE: VECTOR_2"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        Protected *v2.Math::v2f32
        For i=0 To *array\itemCount-1
          *v = GetValue(*array, i)
          datas+"("+StrF(*v2\x)+","+StrF(*v2\y)+")"+Chr(10)
        Next
      Case #ARRAY_V3F32
        datas+"TYPE: VECTOR_3"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        Protected *v3.Math::v3f32
        For i=0 To *array\itemCount-1
          *v3 = GetValue(*array, i)
          datas+"("+StrF(*v3\x)+","+StrF(*v3\y)+","+StrF(*v3\z)+")"+Chr(10)
        Next
      Case #ARRAY_C4F32
        datas+"TYPE: COLOR"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        Protected *c4.Math::c4f32
        For i=0 To *array\itemCount-1
          *c4 = GetValue(*array, i)
          datas+"("+StrF(*c4\r)+","+StrF(*c4\g)+","+StrF(*c4\b)+","+StrF(*c4\a)+")"+Chr(10)
        Next
      Case #ARRAY_C4U8
        datas+"TYPE: C4U8"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        Protected *c4u.Math::c4u8
        For i=0 To *array\itemCount-1
          *c4u = GetValue(*array, i)
          datas+"("+Str(*c4u\r)+","+Str(*c4u\g)+","+Str(*c4u\b)+","+Str(*c4u\a)+")"+Chr(10)
        Next
      Case #ARRAY_M3F32
        datas+"TYPE: MATRIX_3"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
        Protected *m3.Math::m3f32
        For i=0 To *array\itemCount-1
          *m3 = GetValue(*array, i)
          datas+"("+StrF(*m3\v[0])+","+StrF(*m3\v[1])+","+StrF(*m3\v[2])+
                 StrF(*m3\v[3])+","+StrF(*m3\v[4])+","+StrF(*m3\v[4])+
                 StrF(*m3\v[5])+","+StrF(*m3\v[6])+","+StrF(*m3\v[7])+")"+Chr(10)
        Next
      Case #ARRAY_M4F32
        datas+"TYPE: MATRIX_4"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
      Case #ARRAY_Q4F32
        datas+"TYPE: QUATERNION"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
      Case #ARRAY_TRF32
        datas+"TYPE: TRANSFORM"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
      Case #ARRAY_STR
        datas+"TYPE: STRING"+Chr(10)
        datas +"NUM ITEMS : "+Str(*array\itemCount)+Chr(10)
      Case #ARRAY_PTR
    EndSelect
    datas + "---------------------------------------------"
    ProcedureReturn datas
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Echo
  ;----------------------------------------------------------------
  Procedure Echo(*array.CArrayT, label.s="")
    Debug GetAsString(*array, label)
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Alert
  ;----------------------------------------------------------------
  Procedure Alert(*array.CArrayT, label.s="")
    MessageRequester("DATAS : "+label, GetAsString(*array, label))
  EndProcedure
  
  
  ;----------------------------------------------------------------
  ; CArrayBool
  ;----------------------------------------------------------------
  Procedure newCArrayBool()
    Protected *array.CArrayBool = AllocateMemory(SizeOf(CArrayBool))
    *array\type = #ARRAY_BOOL
    *array\itemCount = 0
    *array\itemSize = #SIZE_BOOL
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayChar
  ;----------------------------------------------------------------
  Procedure newCArrayChar()
    Protected *array.CArrayChar = AllocateMemory(SizeOf(CArrayChar))
    *array\type = #ARRAY_CHAR
    *array\itemCount = 0
    *array\itemSize = #SIZE_CHAR
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayInt
  ;----------------------------------------------------------------
  Procedure newCArrayInt()
    Protected *array.CArrayInt = AllocateMemory(SizeOf(CArrayInt))
    *array\type = #ARRAY_INT
    *array\itemCount = 0
    *array\itemSize = #SIZE_INT
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayLong
  ;----------------------------------------------------------------
  Procedure newCArrayLong()
    Protected *array.CArrayLong = AllocateMemory(SizeOf(CArrayLong))
    *array\type = #ARRAY_LONG
    *array\itemCount = 0
    *array\itemSize = #SIZE_LONG
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayFloat
  ;----------------------------------------------------------------
  Procedure newCArrayFloat()
    Protected *array.CArrayFloat = AllocateMemory(SizeOf(CArrayFloat))
    *array\type = #ARRAY_FLOAT
    *array\itemCount = 0
    *array\itemSize = #SIZE_FLOAT
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayV2F32
  ;----------------------------------------------------------------
  Procedure newCArrayV2F32()
    Protected *array.CArrayV2F32 = AllocateMemory(SizeOf(CArrayV2F32))
    *array\type = #ARRAY_V2F32
    *array\itemCount = 0
    *array\itemSize = #SIZE_V2F32
    *array\data = #Null
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayV3F32
  ;----------------------------------------------------------------
  Procedure newCArrayV3F32()
    Protected *array.CArrayV3F32 = AllocateMemory(SizeOf(CArrayV3F32))
    *array\type = #ARRAY_V3F32
    *array\itemCount = 0
    *array\itemSize = #SIZE_V3F32
    *array\data = #Null
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayC4U8
  ;----------------------------------------------------------------
  Procedure newCArrayC4U8()
    Protected *array.CArrayC4U8 = AllocateMemory(SizeOf(CArrayC4U8))
    *array\type = #ARRAY_C4U8
    *array\itemCount = 0
    *array\itemSize = #SIZE_C4U8
    ProcedureReturn *array
  EndProcedure
  
  
  ;----------------------------------------------------------------
  ; CArrayC4F32
  ;----------------------------------------------------------------
  Procedure newCArrayC4F32()
    Protected *array.CArrayC4F32 = AllocateMemory(SizeOf(CArrayC4F32))
    *array\type = #ARRAY_C4F32
    *array\itemCount = 0
    *array\itemSize = #SIZE_C4F32
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayQ4F32
  ;----------------------------------------------------------------
  Procedure newCArrayQ4F32()
    Protected *array.CArrayQ4F32 = AllocateMemory(SizeOf(CArrayQ4F32))
    *array\type = #ARRAY_Q4F32
    *array\itemCount = 0
    *array\itemSize = #SIZE_Q4F32
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayM3F32
  ;----------------------------------------------------------------
  Procedure newCArrayM3F32()
    Protected *array.CArrayM3F32 = AllocateMemory(SizeOf(CArrayM3F32))
    *array\type = #ARRAY_M3F32
    *array\itemCount = 0
    *array\itemSize = #SIZE_M3F32
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayM4F32
  ;----------------------------------------------------------------
  Procedure newCArrayM4F32()
    Protected *array.CArrayM4F32 = AllocateMemory(SizeOf(CArrayM4F32))
    *array\type = #ARRAY_M4F32
    *array\itemCount = 0
    *array\itemSize = #SIZE_M4F32
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayTRF32
  ;----------------------------------------------------------------
  Procedure newCArrayTRF32()
    Protected *array.CArrayTRF32 = AllocateMemory(SizeOf(CArrayTRF32))
    *array\type = #ARRAY_TRF32
    *array\itemCount = 0
    *array\itemSize = #SIZE_TRF32
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayPtr
  ;----------------------------------------------------------------
  Procedure newCArrayPtr()
    Protected *array.CArrayPtr = AllocateMemory(SizeOf(CArrayPtr))
    *array\type = #ARRAY_PTR
    *array\itemCount = 0
    *array\itemSize = #SIZE_PTR
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayStr
  ;----------------------------------------------------------------
  Procedure newCArrayStr()
    Protected *array.CArrayStr = AllocateMemory(SizeOf(CArrayStr))
    InitializeStructure(*array,CArrayStr)
    *array\type = #ARRAY_STR
    *array\itemCount = 0
    *array\itemSize = #SIZE_PTR
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Destructor
  ;----------------------------------------------------------------
  Procedure Delete(*array.CArrayT)
    If *Array\type = #ARRAY_STR
      ClearStructure(*array,CArrayStr)
    EndIf
    
    FreeMemory(*array)
  EndProcedure
  
EndModule

  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 466
; FirstLine = 462
; Folding = -----------
; EnableXP
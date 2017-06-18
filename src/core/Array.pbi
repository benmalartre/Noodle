XIncludeFile "Math.pbi"

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
  
  Structure CArrayT
    type.i
    itemSize.i
    itemCount.i
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
    List str.s()
  EndStructure
  
  Declare GetPtr(*array.CArrayT,index.i)
  Declare GetValue(*array.CArrayT, index.i)
  Declare.b GetValueB(*array.CArrayT,index.i)
  Declare.c GetValueC(*array.CArrayT,index.i)
  Declare.i GetValueI(*array.CArrayT,index.i)
  Declare.l GetValueL(*array.CArrayT,index.i)
  Declare.f GetValueF(*array.CArrayT,index.i)
  Declare.i GetValuePtr(*array.CArrayT,index.i)
  Declare.s GetValueStr(*array.CArrayT,index.i)
  Declare SetValue(*array.CArrayT, index.i, *value)
  Declare SetValueB(*array.CArrayT,index.i,value.b)
  Declare SetValueC(*array.CArrayT,index.i,value.c)
  Declare SetValueI(*array.CArrayT,index.i,value.i)
  Declare SetValueL(*array.CArrayT,index.i,value.l)
  Declare SetValueF(*array.CArrayT,index.i,value.f)
  Declare SetValuePtr(*array.CArrayT,index.i,*value)
  Declare SetValueStr(*array.CArrayT,index.i,value.s)
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
  Declare GetCount(*array.CArrayT)
  Declare SetCount(*array.CArrayT,count.i)
  Declare GetItemSize(*array.CArrayT)
  Declare Copy(*array.CArrayT,*src.CArrayT)
  Declare Delete(*array.CArrayT)
  Declare Find(*array,*value,*ID)
  Declare Remove(*array,ID)
  
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
  Procedure GetPtr(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      ProcedureReturn *array\data+offset
    EndIf
  EndProcedure
  
   ;----------------------------------------------------------------
  ; Get Item SIze
  ;----------------------------------------------------------------
  Procedure GetItemSize(*array.CArrayT)
    ProcedureReturn *Array\itemSize 
  EndProcedure
  
  ;----------------------------------------------------------------
  ;Copy
  ;----------------------------------------------------------------
  Procedure Copy(*array.CArrayT,*src.CArrayT)
    If Not *array\itemCount = *src\itemCount Or Not *array\itemSize = *src\itemSize
      *array\itemSize = *src\itemSize
      SetCount(*array,*src\itemCount)
    EndIf
    
    CopyMemory(*src\data,*array\data,*src\itemCount * *src\itemSize)
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValue
  ;----------------------------------------------------------------
  Procedure GetValue(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
       offset.i = index* *array\itemSize

        ProcedureReturn *array\data+offset

    EndIf
    
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValueB
  ;----------------------------------------------------------------
  Procedure.b GetValueB(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
       offset.i = index* *array\itemSize
        ProcedureReturn PeekB(*Array\data+offset)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValueC
  ;----------------------------------------------------------------
  Procedure.c GetValueC(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
       offset.i = index* *array\itemSize
        ProcedureReturn PeekC(*Array\data+offset)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValueI
  ;----------------------------------------------------------------
  Procedure.i GetValueI(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
       offset.i = index* *array\itemSize
        ProcedureReturn PeekI(*Array\data+offset)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValueL
  ;----------------------------------------------------------------
  Procedure.l GetValueL(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
       offset.i = index* *array\itemSize
        ProcedureReturn PeekL(*Array\data+offset)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValueL
  ;----------------------------------------------------------------
  Procedure.f GetValueF(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
       offset.i = index* *array\itemSize
        ProcedureReturn PeekF(*Array\data+offset)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValuePtr
  ;----------------------------------------------------------------
  Procedure GetValuePtr(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
       offset.i = index* *array\itemSize
       ProcedureReturn PeekI(*Array\data+offset)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; GetValuePtr
  ;----------------------------------------------------------------
  Procedure.s GetValueStr(*array.CArrayT,index.i)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      Protected *sa.CArrayStr = *array
      SelectElement(*sa\Str(),index)
      ProcedureReturn *sa\Str()
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetValue
  ;----------------------------------------------------------------
  Procedure SetValue(*array.CArrayT,index.i,*value)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      CopyMemory(*value,*array\data+offset,*array\itemSize)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetValueB
  ;----------------------------------------------------------------
  Procedure SetValueB(*array.CArrayT,index.i,value.b)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      PokeB(*array\data+offset,value)
      ;CopyMemory(@value,*array\data+offset,*array\itemSize)
    EndIf
  EndProcedure
  
   ;----------------------------------------------------------------
  ; SetValueC
  ;----------------------------------------------------------------
  Procedure SetValueC(*array.CArrayT,index.i,value.c)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      PokeC(*array\data+offset,value)
      ;CopyMemory(@value,*array\data+offset,*array\itemSize)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetValueI
  ;----------------------------------------------------------------
  Procedure SetValueI(*array.CArrayT,index.i,value.i)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      PokeI(*array\data+offset,value)
      ;CopyMemory(@value,*array\data+offset,*array\itemSize)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetValueL
  ;----------------------------------------------------------------
  Procedure SetValueL(*array.CArrayT,index.i,value.l)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      PokeL(*array\data+offset,value)
      ;CopyMemory(@value,*array\data+offset,*array\itemSize)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetValueF
  ;----------------------------------------------------------------
  Procedure SetValueF(*array.CArrayT,index.i,value.f)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      PokeF(*array\data+offset,value)
;       CopyMemory(@value,*array\data+offset,*array\itemSize)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetValuePtr
  ;----------------------------------------------------------------
  Procedure SetValuePtr(*array.CArrayT,index.i,*value)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      PokeI(*array\data+offset,*value)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; SetValueStr
  ;----------------------------------------------------------------
  Procedure SetValueStr(*array.CArrayT,index.i,value.s)
    If index>=0 And index<*array\itemCount
      offset.i = index* *array\itemSize
      Protected *sa.CArrayStr = *array
      SelectElement(*sa\Str(),index)
      *sa\Str() = value
      PokeI(*array\data+offset,@*sa\Str())
;       CopyMemory(@value,*array\data+offset,*array\itemSize)
    EndIf
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Append
  ;----------------------------------------------------------------
  Procedure Append(*array.CArrayT,*item)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
    EndIf
    
    CopyMemory(*item,*array\data+nb* *array\itemSize,*array\itemSize)
    *array\itemCount = nb +1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendB
  ;----------------------------------------------------------------
  Procedure AppendB(*array.CArrayT,item.b)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
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
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
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
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
    EndIf
    
    PokeI(*array\data+nb* *array\itemSize,item)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendI
  ;----------------------------------------------------------------
  Procedure AppendL(*array.CArrayT,item.l)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
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
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
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
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
    EndIf
    
    PokeI(*array\data+nb* *array\itemSize,*item)
    ;CopyMemory(*item, *array\data+nb* *array\itemSize, *array\itemSize)
    *array\itemCount + 1
  EndProcedure
  
  ;----------------------------------------------------------------
  ; AppendStr
  ;----------------------------------------------------------------
  Procedure AppendStr(*array.CArrayT,item.s)
    Protected nb = *array\itemCount
    
    If *array\data = #Null
      *array\data = AllocateMemory(1* *array\itemSize)
    Else
      *array\data = ReAllocateMemory(*array\data,(nb+1)* *array\itemSize)
    EndIf
    
    Protected *sa.CArrayStr = *array
    AddElement(*sa\Str())
    *sa\Str() = item
    PokeI(*array\data+nb* *array\itemSize,@*sa\Str())
    *array\itemCount + 1
  EndProcedure
  
  
  ;----------------------------------------------------------------
  ; AppendArray
  ;----------------------------------------------------------------
  Procedure AppendArray(*array.CArrayT,*other.CArrayT)
    Protected nba = *array\itemCount
    Protected nbo = *other\itemCount
    
    If *array\type = #ARRAY_STR
      Protected *saa.CArrayStr = *array
      Protected *sao.CArrayStr = *other
      
      LastElement(*saa\Str())
      ForEach *sao\Str()
        AddElement(*saa\Str())
        *saa\Str() = *sao\Str()
      Next
     
    ElseIf *Array\itemSize = *other\itemSize
      If *array\data = #Null
        *array\data = AllocateMemory(nbo* *array\itemSize)
      Else
        *array\data = ReAllocateMemory(*array\data,(nbo+nba)* *array\itemSize)
      EndIf
      
      CopyMemory(*other\data,*array\data+nba* *array\itemSize,nbo * *array\itemSize)
      *array\itemCount + nbo
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
    
    Protected nbi = *array\itemCount
    Protected i

    For i = 0 To nbi-1
      If unique = CArray::GetValueStr(*array,i)
        ; Item Already in Array
        ProcedureReturn 
      EndIf
    Next
    AppendStr(*array,unique)   
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
        FreeMemory(*array\data)
        *Array\data = #Null
      EndIf
      *array\itemCount = 0
    Else
      If Not count = *array\itemCount 
        *array\itemCount = count
        If *array\data = #Null
          *array\data = AllocateMemory(count * *array\itemSize)
        Else
          *array\data = ReAllocateMemory(*array\data,count* *array\itemSize)
        EndIf
      EndIf
    EndIf
    
    If *array\type = #Array_STR
      Protected i
      Protected *sa.CArrayStr = *array
      If count>ListSize(*sa\Str())
        For i=0 To count-ListSize(*sa\Str())-1
          AddElement(*sa\Str())
        Next
      Else
        LastElement(*sa\Str())
        For i=0 To ListSize(*sa\Str())-count-1
          DeleteElement(*sa\Str())
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
  ; CArrayBool
  ;----------------------------------------------------------------
  Procedure newCArrayBool()
    Protected *array.CArrayBool = AllocateMemory(SizeOf(CArrayBool))
    Protected b.b
    *array\type = #ARRAY_BOOL
    *array\itemCount = 0
    *array\itemSize = SizeOf(b)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayChar
  ;----------------------------------------------------------------
  Procedure newCArrayChar()
    Protected *array.CArrayChar = AllocateMemory(SizeOf(CArrayChar))
    Protected c.c
    *array\type = #ARRAY_CHAR
    *array\itemCount = 0
    *array\itemSize = SizeOf(c)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayInt
  ;----------------------------------------------------------------
  Procedure newCArrayInt()
    Protected *array.CArrayInt = AllocateMemory(SizeOf(CArrayInt))
    Protected i.i
    *array\type = #ARRAY_INT
    *array\itemCount = 0
    *array\itemSize = SizeOf(i)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayLong
  ;----------------------------------------------------------------
  Procedure newCArrayLong()
    Protected *array.CArrayLong = AllocateMemory(SizeOf(CArrayLong))
    Protected l.l
    *array\type = #ARRAY_LONG
    *array\itemCount = 0
    *array\itemSize = SizeOf(l)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayFloat
  ;----------------------------------------------------------------
  Procedure newCArrayFloat()
    Protected *array.CArrayFloat = AllocateMemory(SizeOf(CArrayFloat))
    Protected f.f
    *array\type = #ARRAY_FLOAT
    *array\itemCount = 0
    *array\itemSize = SizeOf(f)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayV2F32
  ;----------------------------------------------------------------
  Procedure newCArrayV2F32()
    Protected *array.CArrayV2F32 = AllocateMemory(SizeOf(CArrayV2F32))
    *array\type = #ARRAY_V2F32
    *array\itemCount = 0
    *array\itemSize = SizeOf(v2f32)
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
    *array\itemSize = SizeOf(v3f32)
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
    *array\itemSize = SizeOf(c4u8)
    ProcedureReturn *array
  EndProcedure
  
  
  ;----------------------------------------------------------------
  ; CArrayC4F32
  ;----------------------------------------------------------------
  Procedure newCArrayC4F32()
    Protected *array.CArrayC4F32 = AllocateMemory(SizeOf(CArrayC4F32))
    *array\type = #ARRAY_C4F32
    *array\itemCount = 0
    *array\itemSize = SizeOf(c4f32)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayQ4F32
  ;----------------------------------------------------------------
  Procedure newCArrayQ4F32()
    Protected *array.CArrayQ4F32 = AllocateMemory(SizeOf(CArrayQ4F32))
    *array\type = #ARRAY_Q4F32
    *array\itemCount = 0
    *array\itemSize = SizeOf(q4f32)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayM3F32
  ;----------------------------------------------------------------
  Procedure newCArrayM3F32()
    Protected *array.CArrayM3F32 = AllocateMemory(SizeOf(CArrayM3F32))
    *array\type = #ARRAY_M3F32
    *array\itemCount = 0
    *array\itemSize = SizeOf(m3f32)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayM4F32
  ;----------------------------------------------------------------
  Procedure newCArrayM4F32()
    Protected *array.CArrayM4F32 = AllocateMemory(SizeOf(CArrayM4F32))
    *array\type = #ARRAY_M4F32
    *array\itemCount = 0
    *array\itemSize = SizeOf(m4f32)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayTRF32
  ;----------------------------------------------------------------
  Procedure newCArrayTRF32()
    Protected *array.CArrayTRF32 = AllocateMemory(SizeOf(CArrayTRF32))
    *array\type = #ARRAY_TRF32
    *array\itemCount = 0
    *array\itemSize = SizeOf(trf32)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayPtr
  ;----------------------------------------------------------------
  Procedure newCArrayPtr()
    Protected *array.CArrayPtr = AllocateMemory(SizeOf(CArrayPtr))
    Protected i.i
    *array\type = #ARRAY_PTR
    *array\itemCount = 0
    *array\itemSize = SizeOf(i)
    ProcedureReturn *array
  EndProcedure
  
  ;----------------------------------------------------------------
  ; CArrayStr
  ;----------------------------------------------------------------
  Procedure newCArrayStr()
    Protected *array.CArrayStr = AllocateMemory(SizeOf(CArrayStr))
    InitializeStructure(*array,CArrayStr)
    Protected s.i
    *array\type = #ARRAY_STR
    *array\itemCount = 0
    *array\itemSize = SizeOf(s)
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

  
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 93
; FirstLine = 80
; Folding = ---------
; EnableXP
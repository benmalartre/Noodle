XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule CArray

; Define *array.CArrayV3F32 = CArray::newCArrayV3F32()
; Define a.v3f32
; Define i
; For i=0 To 12
;   Vector3::Set(a,0,i,0)
;   CArray::Append(*array,a)
; Next
; 
; Define *b.v3f32 
; Debug "Array Size : "+Str(CArray::GetCount(*array)-1)
; For i=0 To CArray::GetCount(*array)-1
;   *b = CArray::GetValue(*array,i)
;   Vector3::ScaleInPlace(*b,10)
;   Vector3::Echo(*b)
; Next
; 
; CArray::SetCount(*array,33)
; Debug "Array Size : "+Str(CArray::GetCount(*array))
; For i=0 To CArray::GetCount(*array)-1
;   *b = CArray::GetValue(*array,i)
;   Vector3::ScaleInPlace(*b,0.1)
;   Vector3::Echo(*b)
; Next

DataSection
  label:
  Data.i 1,2,3,4
  Data.i 5,6,7,8
  Data.i 9,10,11,12
  
  label2:
  Data.f 1,2,3,4
  Data.f 5,6,7,8
  Data.f 9,10,11,12
EndDataSection

; Debug "====================== ARRAY INTEGER  FROM DATASECTION =============================="
; Define *array2.CArrayInt = CArray::newCArrayInt()
; Define x.i
; Define i
; CArray::SetCount(*array2,12)
; *array2\data = ?label
; 
; 
; For i=0 To CArray::GetCount(*array2)-1
;   x = PeekI(CArray::GetValue(*array2,i))
;  Debug x
; Next
; 
; Debug "====================== ARRAY FLOAT  FROM DATASECTION =============================="
; Define *array3.CArrayInt = CArray::newCArrayFloat()
; Define f.f
; CArray::SetCount(*array3,12)
; *array3\data = ?label2
; 
; 
; For i=0 To CArray::GetCount(*array3)-1
;   f = PeekF(CArray::GetValue(*array3,i))
;   Debug f
;   
; Next

Debug "====================== ARRAY PTR =============================="
Define *array4.CArrayPtr = CArray::newCArrayPtr()
CArray::SetCount(*array4,0)
Define x
For x=0 To 4
  Define *mesh.Polymesh::Polymesh_t =Polymesh::New("Test"+Str(x+1),Shape::#SHAPE_CUBE)
  CArray::AppendUnique(*array4,*mesh)
  ;CArray::SetValueI(*array4,x,*mesh)
  Debug *mesh
Next
Debug "---------------------------------"
For x=0 To CArray::GetCount(*array4)-1
  Define *mesh.Polymesh::Polymesh_t = CArray::GetValuePtr(*array4,x)
  Debug *mesh\name
  
Next

CArray::SetCount(*array4,0)

Define x
For x=0 To 13
  Define *mesh.Polymesh::Polymesh_t =Polymesh::New("Test"+Str(x+1),Shape::#SHAPE_CUBE)
  CArray::AppendPtr(*array4,*mesh)
  ;CArray::SetValueI(*array4,x,*mesh)
  Debug *mesh
Next
Debug "---------------------------------"
For x=0 To CArray::GetCount(*array4)-1
  Define *mesh.Polymesh::Polymesh_t = CArray::GetValuePtr(*array4,x)
  Debug *mesh\name
  
Next

Debug "====================== ARRAY APPEND =============================="
Define *array5.CArrayBool = CArray::newCArrayBool()
CArray::SetCount(*array5,5)
Define x
For x=0 To 4
  ;CArray::SetValueI(*array4,x,*mesh)
CArray::SetValueB(*array5,x,#True)
Next

Define *array6.CArrayFloat = CARray::newCArrayBool()
CArray::SetCount(*array6,6)

CArray::AppendArray(*array5,*array6)

For x=0 To CArray::GetCount(*array5)-1
  Debug "Boolean ID "+Str(x)+" : "+Str(CArray::GetValueB(*array5,x))
  
Next

Debug "====================== ARRAY STRING =============================="
Define *array7.CArrayStr = CArray::newCArrayStr()
CArray::SetCount(*array7,7)
Define x
For x=0 To CArray::GetCount(*array7) -1
  ;CArray::SetValueI(*array4,x,*mesh)
CArray::SetValueStr(*array7,x,"Hello World")
Next

CArray::SetCount(*array7,13)
For x=7 To CArray::GetCount(*array7) -1
  ;CArray::SetValueI(*array4,x,*mesh)
CArray::SetValueStr(*array7,x,"Dlrow olleh")
Next

Define *array8.CArrayStr = CArray::newCArrayStr()
CArray::SetCount(*array8,3)
Define x
For x=0 To CArray::GetCount(*array8) -1
CArray::SetValueStr(*array8,x,"10100110")
Next
CArray::AppendArray(*array7,*array8)

For x=0 To CArray::GetCount(*array7)-1
  Debug "String ID "+Str(x)+" : "+CArray::GetValueStr(*array7,x)
  
Next

Define nb = 64
Define *ptrArray.CArray::CArrayPtr = CArray::newCArrayPtr()
CArray::InitializeReferences(*ptrArray,nb,Geometry::PointOnCurve_t)

Debug "ITEM COUNT : "+*ptrArray\itemCount
Debug "ITEM SIZE : "+*ptrArray\itemSize
Debug "TOTAL SIZE : "+Str(*ptrArray\itemCount * *ptrArray\itemSize)

For i=0 To nb-1
  Define *pc.Geometry::PointOnCurve_t = CArray::GetValuePtr(*ptrArray, i)
  *pc\cid = i
  *pc\u = Random(1000)*0.001
Next

CArray::DeleteReferences(*ptrArray)
CArray::Delete(*ptrArray)
;
; Debug "====================== ARRAY FLOAT =============================="
; Define *array5.CArrayFloat = CArray::newCArrayFloat()
; CArray::SetCount(*array5,0)
; Define x
; For x=0 To 4
;   CArray::AppendF(*array5,x*2.336)
;   ;CArray::SetValueI(*array4,x,*mesh)
;   Debug *mesh
; Next
; Debug "---------------------------------"
; For x=0 To CArray::GetCount(*array5)-1
;   Define f.f = CArray::GetValueF(*array5,x)
;   Debug f
;   
; Next
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 162
; FirstLine = 109
; EnableXP
; EnableUnicode
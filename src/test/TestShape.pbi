XIncludeFile "../core/Time.pbi"
XIncludeFile "../objects/Shapes.pbi"


Time::Init()

Define *shape1.Shape::Shape_t = Shape::New(Shape::#SHAPE_CUBE)
Define *shape2.Shape::Shape_t = Shape::New(Shape::#SHAPE_CUBE)

Define mem_size = *shape1\positions\itemCount * 12
Define i
Define numIter = 1200000

Define T.d = Time::Get()
For i = 0 To numIter
  Shape::RecomputeNormals(*shape1)
Next
Define E1.d = Time::Get() - T
; 
; Define T.d = Time::Get()
; For i = 0 To numIter
;   Shape::RecomputeNormalsSSE(*shape2)
; Next
; Define E2.d = Time::Get() - T

Procedure CompareNormals(*a, *b , nb)
  Define i 
  For i=0 To nb -1
    If Abs(PeekF(*a+i*4) - PeekF(*b+i*4)) > 0.0001
      ProcedureReturn #False
    EndIf
  Next
  ProcedureReturn #True
      
EndProcedure

  


CArray::Echo(*shape1\normals)
CArray::Echo(*shape2\normals)
MessageRequester("Test Shape", StrD(E1)+" vs "+StrD(E2)+Chr(10)+
                               CompareNormals(*shape1\normals\data, *shape2\normals\data, *shape1\positions\itemCount))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 23
; Folding = -
; EnableXP
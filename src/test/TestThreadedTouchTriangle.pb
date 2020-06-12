XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Triangle.pbi"
XIncludeFile "../objects/Polymesh.pbi"

; TouchArray(*positions, *indices, numTris.i, *box.Geometry::Box_t, *hits)
UseModule Math

Structure ThreadData_t
  threadID.i
  *positions
  *indices
  *elements
  count.i
  *box.Geometry::Box_t
  *hits
EndStructure

Procedure ThreadedTriangleArrayTouchCell(*datas.ThreadData_t)
  Triangle::TouchArray(*datas\positions, *datas\indices, *datas\elements, *datas\count, *datas\box, *datas\hits)
EndProcedure

Procedure NumHits(*hits, nb)
  Define accum = 0
  For i=0 To nb-1
    If PeekB(*hits+i) : accum + 1 : EndIf
  Next
  ProcedureReturn accum
EndProcedure


Time::Init()

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Test", Shape::#Shape_Sphere)
Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
PolymeshGeometry::SphereTopology(*geom, 12, 1024,1024)
PolymeshGeometry::Set2(*geom, *geom\topo)

Global box.Geometry::Box_t 
Vector3::Set(box\origin, 0,0,0)
Vector3::Set(box\extend, 10,10,10)

Global *hits1 = AllocateMemory(*geom\nbtriangles)
Global *hits2 = AllocateMemory(*geom\nbtriangles)
Global *elements = AllocateMemory(*geom\nbtriangles * 4)
Define i
For i=0 To *geom\nbtriangles - 1 : PokeL(*elements + i*4, i) : Next

; BRUTE FORCE
Define startT1.d = Time::Get()
; Define i
; Define i
; Define.v3f32 *a, *b, *c
; Define a,b,c
; Define v3s = SizeOf(v3f32)
; For i=0 To *geom\nbtriangles - 1
;   a = CArray::GetValueL(*geom\a_triangleindices, i*3)
;   b = CArray::GetValueL(*geom\a_triangleindices, i*3+1)
;   c = CArray::GetValueL(*geom\a_triangleindices, i*3+2)
;   *a = CArray::GetValue(*geom\a_positions, a)
;   *b = CArray::GetValue(*geom\a_positions, b)
;   *c = CArray::GetValue(*geom\a_positions, c)
;   If Triangle::Touch( box, *a, *b, *c)
;     PokeB(*hits1 + i, #True)
;   EndIf
; Next
Triangle::TouchArray(*geom\a_positions\data, *geom\a_triangleindices\data, *elements, *geom\nbtriangles, box, *hits1)
Define elapsedT1.d = Time::Get() - startT1
; THREADED
Define numThreads.i = 4
Dim threadDatas.threadData_t(numThreads)
Dim threads.i(numThreads)
Define numTris = *geom\nbtriangles
Define numTriPerThread = Round(numTris / numThreads, #PB_Round_Down)

Define startT2.d = Time::Get()
For i=0 To ArraySize(threadDatas())-1
  With threadDatas(i)
    \box = box
    \threadID = i
    \count = numTriPerThread
    \hits = *hits2 + i * numTriPerThread
    \positions = *geom\a_positions\data
    \indices = *geom\a_triangleindices\data
    \elements = *elements + (i*4*numTriPerThread)
  EndWith
  threads(i) = CreateThread(@ThreadedTriangleArrayTouchCell(), threadDatas(i))
Next

For i = 1 To numThreads - 1    ;Wait for all threads to finish... not sure if this is the bes way
 If IsThread(threads(i)) 
   WaitThread(threads(i))
 EndIf   
Next 

Define elapsedT2.d = Time::Get() - startT2

MessageRequester("THREADED", 
                 StrD(elapsedT1)+" vs "+StrD(elapsedT2)+
                 " : "+Str(CompareMemory(*hits1, *hits2, *geom\nbtriangles))+
                 ", "+Str(NumHits(*hits1, *geom\nbtriangles))+
                 ", "+Str(NumHits(*hits2, *geom\nbtriangles))+Chr(10)+
                 "NUM TRIANGLES : "+Str(*geom\nbtriangles))




; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 2
; Folding = -
; EnableXP
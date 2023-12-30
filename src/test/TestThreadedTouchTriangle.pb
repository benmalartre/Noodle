XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Box.pbi"
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


Procedure.s Payload(numThreads.i, *geom.Geometry::PolymeshGeometry_t, *box.Geometry::Box_t)
  Define *hits = AllocateMemory(*geom\nbtriangles)
  Define *elements = AllocateMemory(*geom\nbtriangles * 4)
  Define i
  For i=0 To *geom\nbtriangles - 1 : PokeL(*elements + i * 4, i) : Next
  
  Dim threadDatas.ThreadData_t(numThreads)
  Dim threads.i(numThreads)
  Define numTris = *geom\nbtriangles
  Define numTriPerThread = Round(numTris / numThreads, #PB_Round_Down)
  Define numTriLastThread = *geom\nbtriangles - (numThreads - 1) * numTriPerThread

  Define startT.d = Time::Get()
  For i=0 To numThreads-1
    With threadDatas(i)
      \box = *box
      \threadID = i
      If i < numThreads -1
        \count = numTriPerThread
      Else
        \count = numTriLastThread
      EndIf 
      \hits = *hits + i * numTriPerThread
      \positions = *geom\a_positions\data
      \indices = *geom\a_triangleindices\data
      \elements = *elements + (i*4*numTriPerThread)
    EndWith
    threads(i) = CreateThread(@ThreadedTriangleArrayTouchCell(), threadDatas(i))
  Next
  
  working = #True
  While working
    working = #False
    For i = 0 To numThreads - 1    ;Wait for all threads to finish... not sure if this is the bes way
      If IsThread(threads(i)) 
        working=#True
      EndIf
    Next
  Wend  
  
  
  Define elapsedT.d = Time::Get() - startT
  
  ProcedureReturn "NUM THREAD : "+Str(numThreads) +" : " + Chr(10) + 
                                  StrD(elapsedT) + " seconds (" +
                                  Str(NumHits(*hits, *geom\nbtriangles)) +
                                  " hits)"
    
EndProcedure

Time::Init()

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Test", Shape::#Shape_Sphere)
Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
PolymeshGeometry::SphereTopology(*geom, 12, 1024,1024)
PolymeshGeometry::Set2(*geom, *geom\topo)

Global box.Geometry::Box_t 
Vector3::Set(box\origin, 0,0,0)
Vector3::Set(box\extend, 10,10,10)


Define N.i = 1
Define result1.s = Payload(N, *geom, box)

N = 2
Define result2.s = Payload(N, *geom, box)

N = 4
Define result3.s = Payload(N, *geom, box)

N = 8
Define result4.s = Payload(N, *geom, box)

N = 16
Define result5.s = Payload(N, *geom, box)

N = 32
Define result6.s = Payload(N, *geom, box)

N = 64
Define result7.s = Payload(N, *geom, box)
MessageRequester("Intersect "+Str(*geom\nbtriangles) + " Triangles", 
                 result1 + Chr(10) + 
                 result2 + Chr(10) + 
                 result3 + Chr(10) + 
                 result4 + Chr(10) + 
                 result5 + Chr(10) + 
                 result6 + Chr(10) +
                 result7)






; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 39
; Folding = -
; EnableXP
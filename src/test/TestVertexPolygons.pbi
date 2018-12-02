XIncludeFile "../objects/PolymeshGeometry.pbi"
XIncludeFile "../core/Slot.pbi"

  ; ----------------------------------------------------------------------------
  ;  Compute Vertex Polygons
  ; ----------------------------------------------------------------------------
  Procedure TestComputeVertexPolygons1(*mesh.Geometry::PolymeshGeometry_t)
    
    Protected i, j, k, nbv, base, total, last
    Protected Dim indices.Geometry::VertexPolygonIndices_t(*mesh\nbpoints)
    For i=0 To *mesh\nbpoints-1
      InitializeStructure(indices(i), Geometry::VertexPolygonIndices_t)
    Next
    
    base=0
    total = 0

    For i=0 To *mesh\nbpolygons-1
      
      nbv = CArray::GetValueL(*mesh\a_facecount, i)
      
      For j=0 To nbv-1
        k = CArray::GetValueL(*mesh\a_faceindices,(base+j))
        last = ArraySize(indices(k)\polygons())
        ReDim indices(k)\polygons(last+1)
        indices(k)\polygons(last) = i
        total+1
      Next j
      base+nbv
    Next i
        
    CArray::SetCount(*mesh\a_vertexpolygoncount, *mesh\nbpoints)
    CArray::SetCount(*mesh\a_vertexpolygonindices, total)
    
    For i=0 To ArraySize(indices())-1
      Define s.s = ""
      For j=0 To ArraySize(indices(i)\polygons())-1
        s + Str(indices(i)\polygons(j))+","
      Next
      Debug "Vertex "+Str(i)+" : "+s
    Next
    
    
    Protected nbp, index
    base = 0
    For i=0 To *mesh\nbpoints-1
      nbp = ArraySize(indices(i)\polygons())
      Debug "VERETX "+Str(i)+" NUM POLY : "+Str(nbp)
      CArray::SetValueL(*mesh\a_vertexpolygoncount, i, nbp)
      For j=0 To nbp-1
        CArray::SetValueL(*mesh\a_vertexpolygonindices, base+j-1, indices(i)\polygons(j))
        Debug "Vertex Polygon"+Str(base+j) +" : Added "+Str(indices(i)\polygons(j))
      Next
      base + nbp
      ClearStructure(indices(i), Geometry::VertexPolygonIndices_t)
    Next
    FreeArray(indices())

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Recompute Vertex Polygons
  ; ----------------------------------------------------------------------------
  Procedure TestComputeVertexPolygons2(*mesh.Geometry::PolymeshGeometry_t)
    Protected i, j, k, nbv, base, total
    Protected Dim indices.s(*mesh\nbpoints)
    base=0
    total = 0

    For i=0 To *mesh\nbpolygons-1
      nbv = CArray::GetValueL(*mesh\a_facecount, i)
      For j=0 To nbv-1
        k = CArray::GetValueL(*mesh\a_faceindices,(base+j))
        indices(k) + Str(i)+","
        total+1
      Next j
      base+nbv
    Next i
        
    CArray::SetCount(*mesh\a_vertexpolygoncount, *mesh\nbpoints)
    CArray::SetCount(*mesh\a_vertexpolygonindices, total)
    
     For i=0 To ArraySize(indices())-1
      Debug "Vertex "+Str(i)+" : "+indices(i)
    Next
    
    Protected nbp, index
    base = 0
    For i=0 To *mesh\nbpoints-1
      nbp = CountString(indices(i),",")
      Debug "VERETX "+Str(i)+" NUM POLY : "+Str(nbp)
      CArray::SetValueL(*mesh\a_vertexpolygoncount, i, nbp)
      For j=1 To nbp
        index = Val(StringField(indices(i),j,","))
        CArray::SetValueL(*mesh\a_vertexpolygonindices, base+j-1, index)
        Debug "Vertex Polygon"+Str(base+j-1) +" : Added "+Str(index)
      Next
      base + nbp
    Next

  EndProcedure
  
  Define *geom.Geometry::PolymeshGeometry_t = PolymeshGeometry::New(Shape::#SHAPE_GRID)
  TestComputeVertexPolygons1(*geom)
  Debug "---------------------------------------------------------------"
  TestComputeVertexPolygons2(*geom)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 51
; FirstLine = 33
; Folding = -
; EnableXP
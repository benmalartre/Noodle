
XIncludeFile "../core/Array.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Vertex.pbi"
XIncludeFile "../objects/Edge.pbi"
XIncludeFile "../objects/Polygon.pbi"
XIncludeFile "../objects/Sample.pbi"
XIncludeFile "../objects/Topology.pbi"
XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/Location.pbi"
XIncludeFile "../objects/Object3D.pbi"
;========================================================================================
; PolymeshGeometry Module Declaration
;========================================================================================
DeclareModule PolymeshGeometry
  UseModule Geometry
  UseModule Math
  Declare New(*parent,shape.i=Shape::#SHAPE_CUBE)
  Declare Delete(*geom.PolymeshGeometry_t)
  ;Declare Init(*geom.PolymeshGeometry_t)
  Declare GetDualGraph(*geom.PolymeshGeometry_t)
  Declare ResetVisitedTags(*mesh.PolymeshGeometry_t)
  Declare GetUVWSFromPosition(*geom.PolymeshGeometry_t,normalize.b=#False)
  Declare GetUVWSFromExtrusion(*geom.PolymeshGeometry_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32)
  Declare GetUVWSPerPolygons(*geom.PolymeshGeometry_t)
  Declare RecomputeNormals(*mesh.PolymeshGeometry_t,smooth.f=0.5)
  Declare RecomputeTangents(*mesh.PolymeshGeometry_t)
  Declare InvertNormals(*mesh.PolymeshGeometry_t)
  Declare RecomputeTriangles(*mesh.PolymeshGeometry_t)
  Declare RecomputeEdges(*mesh.PolymeshGeometry_t)
  Declare RecomputeVertexPolygons(*mesh.PolymeshGeometry_t)
  Declare Clear(*mesh.PolymeshGeometry_t)
  Declare GetTopology(*mesh.PolymeshGeometry_t)
  Declare SetColors(*mesh.PolymeshGeometry_t,*color.c4f32= #Null)
  Declare Set2(*mesh.PolymeshGeometry_t,*topo.Topology_t)
  Declare Set(*mesh.PolymeshGeometry_t,*vertices.CArray::CArrayV3F32,*faces.CArray::CArrayInt)
  Declare SetFromOther(*geom.PolymeshGeometry_t,*other.PolymeshGeometry_t)
  Declare Reset(*geom.PolymeshGeometry_t)
  Declare SetColors(*mesh.PolymeshGeometry_t,*color.c4f32= #Null)
  Declare EnvelopeColors(*mesh.PolymeshGeometry_t,*weights.CArray::CArrayC4F32,*indices.CArray::CArrayC4U8,nbdeformers.i)
  Declare UpdateColors(*mesh.PolymeshGeometry_t)
  Declare RandomColorByPolygon(*mesh.PolymeshGeometry_t,*color.c4f32 = #Null,randomize.f = 0.5)
  Declare Extrusion(*geom.PolymeshGeometry_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32)
  Declare GetPointsPosition(*mesh.PolymeshGeometry_t,*io_pos.CArray::CArrayV3F32)
  Declare GetPointsNormal(*mesh.PolymeshGeometry_t,*io_norm.CArray::CArrayV3F32)
  Declare SetPointsPosition(*mesh.PolymeshGeometry_t,*io_pos.CArray::CArrayV3F32)
  Declare SetPointsNormal(*mesh.PolymeshGeometry_t,*io_pos.CArray::CArrayV3F32)
  Declare ToShape(*Me.PolymeshGeometry_t,*shape.Shape::Shape_t)
  Declare BunnyTopology(*topo.Topology_t)
  Declare TeapotTopology(*topo.Topology_t)
  Declare TorusTopology(*topo.Topology_t)
  Declare CubeTopology(*topo.Topology_t,radius.f,u.i,v.i,w.i)
  Declare CylinderTopology(*topo.Topology_t,radius.f,u.i=8,v.i=1,w.i=0,captop.b=#True,capbottom.b=#True)
  Declare DiscTopology(*topo.Topology_t,radius.f,u.i=8)
  Declare SphereTopology(*topo.Topology_t,radius.f=1,lats.i=8,longs.i=8)
  Declare GridTopology(*topo.Topology_t,radius.f,u.i,v.i)
  Declare InitSampling(*mesh.PolymeshGeometry_t)
  Declare Sample(*mesh.PolymeshGeometry_t, *t.Transform::Transform_t, numSamples, *io.CArray::CArrayV3F32)
  Declare ExtrudePolygons(*mesh.PolymeshGeometry_t, *polygons.CArray::CArrayLong, distance.f, separate.b)
  Declare.b GetClosestLocation(*mesh.PolymeshGeometry_t, *p.v3f32, *cp.Geometry::Location_t, *distance, maxDistance.f=#F32_MAX)
EndDeclareModule

;========================================================================================
; PolymeshGeometry Module Implementation
;========================================================================================
Module PolymeshGeometry
  UseModule Geometry
  UseModule Math
  ; ----------------------------------------------------------------------------
  ;  Get Dual Graph
  ; ----------------------------------------------------------------------------
  Procedure GetDualGraph(*mesh.PolymeshGeometry_t)
 
    Protected *vertex.Geometry::Vertex_t
    Protected *edge.Geometry::Edge_t
    Protected *polygon.Geometry::Polygon_t
    Protected *sample.Geometry::Sample_t
    Protected a,b,c,i,j,k,base

    ; Clear Old Sample Datas
    For i=0 To CArray::GetCount(*mesh\a_samples)-1
      *sample = CArray::GetValuePtr(*mesh\a_samples,i)
      FreeMemory(*sample)
    Next
    
    ; Clear Old Vertices Datas
    For i=0 To  CArray::GetCount(*mesh\a_vertices)-1
      *vertex = CArray::GetValuePtr(*mesh\a_vertices,i)
      FreeMemory(*vertex)
    Next
    
    ; Clear Old Edges Datas
    For i=0 To  CArray::GetCount(*mesh\a_edges)-1
      *edge = CArray::GetValuePtr(*mesh\a_edges,i)
      FreeMemory(*edge)
    Next
    
    ; Clear Old Polygons Datas
    For i=0 To  CArray::GetCount(*mesh\a_polygons)-1
      *polygon = CArray::GetValuePtr(*mesh\a_polygons,i)
      FreeMemory(*polygon)
    Next
    
    ; Get Vertices
    CArray::SetCount(*mesh\a_vertices, *mesh\nbpoints)
    For i=0 To *mesh\nbpoints-1
      *vertex = Vertex::New(i)
      CArray::SetValuePtr(*mesh\a_vertices, i,*vertex)
      Vector3::SetFromOther(*vertex\position ,CArray::GetValue(*mesh\a_positions,i))
    Next i
   
    Protected cnt=0
    ; Get Vertices Neighbors
    CArray::SetCount(*mesh\a_samples, *mesh\nbsamples)
    For i=0 To *mesh\nbtriangles-1
      
      a = CArray::GetValueL(*mesh\a_triangleindices,i*3)
      b = CArray::GetValueL(*mesh\a_triangleindices,i*3+1)
      c = CArray::GetValueL(*mesh\a_triangleindices,i*3+2)
      
      For j=0 To 2
        *vertex = CArray::GetValuePtr(*mesh\a_vertices,CArray::GetValueL(*mesh\a_triangleindices,i*3+j))
        *sample = Sample::New(cnt)
       
        CArray::SetValuePtr(*mesh\a_samples, cnt, *sample)
        CArray::AppendPtr(*vertex\samples, *sample)

        Select j
          Case 0
            CArray::AppendUnique(*vertex\neighbors, CArray::GetValuePtr(*mesh\a_vertices, b))
            CArray::AppendUnique(*vertex\neighbors, CArray::GetValuePtr(*mesh\a_vertices, c))
          Case 1
            CArray::AppendUnique(*vertex\neighbors, CArray::GetValuePtr(*mesh\a_vertices, a))
            CArray::AppendUnique(*vertex\neighbors, CArray::GetValuePtr(*mesh\a_vertices, c))
          Case 2
            CArray::AppendUnique(*vertex\neighbors, CArray::GetValuePtr(*mesh\a_vertices, a))
            CArray::AppendUnique(*vertex\neighbors, CArray::GetValuePtr(*mesh\a_vertices, b))
        EndSelect
        cnt+1
      Next j
    Next i
    
    ; Get Polygons
    CArray::SetCount(*mesh\a_polygons, *mesh\nbpolygons)
    Protected *indices.CArray::CArrayLong = CArray::newCArrayLong()
    Protected nbv
    base=0
    For i=0 To *mesh\nbpolygons-1
      nbv = CArray::GetValueL(*mesh\a_facecount,i)
      CArray::SetCount(*indices, nbv)
      
      For j=0 To nbv-1
        CArray::SetValueL(*indices, j, CArray::GetValueL(*mesh\a_faceindices, base+j))
      Next
      base+nbv
      *polygon = Polygon::New(*mesh, *indices, i)
      CArray::SetValuePtr(*mesh\a_polygons, i, *polygon)
      CArray::SetCount(*polygon\edges, nbv)
    Next
    CArray::Delete(*indices)
    
    ; Get Unique Edges
    Protected NewMap *uniqueEdges.Geometry::Edge_t()
    Protected edgeKey.s
    Protected edgeID.i = 0
    Protected p, x
    base=0
    For i=0 To *mesh\nbpolygons-1
      nbv = CArray::GetValueL(*mesh\a_facecount, i)
      For j=0 To nbv-1
        a = CArray::GetValueL(*mesh\a_faceindices,base+j)
        b = CArray::GetValueL(*mesh\a_faceindices,base+((j+1)%nbv))
        
        If a>b
          edgeKey = Str(b)+","+Str(a)
        Else
          edgeKey = Str(a)+","+Str(b)
        EndIf
        
        If Not FindMapElement(*uniqueEdges(), edgeKey)
          AddMapElement(*uniqueEdges(), edgeKey)
          *uniqueEdges() = Edge::New(*mesh, edgeID, a, b)
          edgeID + 1
        EndIf
        *polygon = CArray::GetValuePtr(*mesh\a_polygons, i)
        CArray::AppendUnique(*uniqueEdges()\polygons, *polygon)
        For k=0 To CArray::GetCount(*polygon\edges)-1
          If CArray::GetValuePtr(*polygon\edges, k) = #Null
            CArray::SetValuePtr(*polygon\edges, k, *uniqueEdges())
            Break
          EndIf 
        Next
      Next j
      base+nbv
    Next i
    
    Protected numUniqueEdges.i = MapSize(*uniqueEdges())
    CArray::SetCount(*mesh\a_edgeindices, numUniqueEdges*2)
    *mesh\nbedges = numUniqueEdges
    
    i=0
    CArray::SetCount(*mesh\a_edges, *mesh\nbedges)
    ForEach *uniqueEdges()
      *vertex = CArray::GetValuePtr(*uniqueEdges()\vertices, 0)
      CArray::AppendPtr(*vertex\edges, *uniqueEdges())
      *vertex = CArray::GetValuePtr(*uniqueEdges()\vertices, 1)
      CArray::AppendPtr(*vertex\edges, *uniqueEdges())
      CArray::SetValuePtr(*mesh\a_edges, i, *uniqueEdges())
      *vertex = CArray::GetValuePtr(*uniqueEdges()\vertices, 0)
      CArray::SetValueL(*mesh\a_edgeindices, i*2, *vertex\id)
      *vertex = CArray::GetValuePtr(*uniqueEdges()\vertices, 1)
      CArray::SetValueL(*mesh\a_edgeindices, i*2+1, *vertex\id)
      i+1
    Next
    
    ; Update Vertex Data
    Protected nbvpi = 0
    For i=0 To *mesh\nbpolygons-1
      *polygon = CArray::GetValuePtr(*mesh\a_polygons,i)
      For j=0 To CArray::GetCount(*polygon\vertices)-1
        *vertex = CArray::GetValuePtr(*polygon\vertices, j)
        CArray::AppendPtr(*vertex\polygons, *polygon)
        nbvpi+1
      Next
    Next
    
    ; Update Edge Data
    Protected *neighbor.Geometry::Edge_t
    For i=0 To *mesh\nbedges-1
      *edge = CArray::GetValuePtr(*mesh\a_edges,i)
      For j=0 To 1
        *vertex = CArray::GetValuePtr(*edge\vertices, j)
        For k=0 To CArray::GetCount(*vertex\edges)-1
          *neighbor = CArray::GetValuePtr(*vertex\edges, k)
          If Not *neighbor = *edge
            CArray::AppendPtr(*edge\neighbors, *neighbor)
          EndIf
        Next 
      Next
    Next
    
    ; Update Vertex Polygon Data
    CArray::SetCount(*mesh\a_vertexpolygoncount, *mesh\nbpoints)
    CArray::SetCount(*mesh\a_vertexpolygonindices, nbvpi)
    Protected nbvp
    base=0
    For i=0 To *mesh\nbpoints-1
      *vertex = CArray::GetValuePtr(*mesh\a_vertices, i)
      nbvp = CArray::GetCount(*vertex\polygons)
      CArray::SetValueL(*mesh\a_vertexpolygoncount, i, nbvp)
      For j=0 To nbvp-1
        *polygon = CArray::GetValuePtr(*vertex\polygons, j)
        CArray::SetValueL(*mesh\a_vertexpolygonindices, base+j, *polygon\id)
      Next
      base + nbvp
    Next
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Reset Visited Tags
  ; ----------------------------------------------------------------------------
  Procedure ResetVisitedTags(*mesh.PolymeshGeometry_t)

    Protected i
    Protected *vertex.Vertex_t
    For i=0 To CArray::GetCount(*mesh\a_vertices)-1
      *vertex = CArray::GetValue(*mesh\a_vertices,i)
      If *vertex : *vertex\visited = #False : EndIf
    Next i
    
  EndProcedure
  
  
  
  Procedure GetUVWSFromPosition(*geom.PolymeshGeometry_t,normalize.b=#False)
    
    Protected cnt=0
    Define.f h,w
    Protected a,b,c,i
  
    
    Define.v3f32 bmin,bmax
    If normalize
      Geometry::ComputeBoundingBox(*geom)
      Vector3::Sub(@bmin, *geom\bbox\origin, *geom\bbox\extend)
      Vector3::Add(@bmax, *geom\bbox\origin, *geom\bbox\extend)
      ; Normalized UVs
      Define.v3f32 va,vb,vc,offset,scl,delta
      
      Vector3::Sub(@delta,@bmax,@bmin)
      
      Define.v3f32 *va,*vb,*vc
      
       For i=0 To CArray::GetCount(*geom\a_triangleindices)/3-1
        a = CArray::GetValueL(*geom\a_triangleindices,i*3)
        b = CArray::GetValueL(*geom\a_triangleindices,i*3+1)
        c = CArray::GetValueL(*geom\a_triangleindices,i*3+2)
    
        
        *va = CArray::GetValue(*geom\a_positions,a)
        *vb = CArray::GetValue(*geom\a_positions,b)
        *vc = CArray::GetValue(*geom\a_positions,c)
        
        va\x = RESCALE(*va\x,bmin\x,bmax\x,0,1)
        va\y = RESCALE(*va\y,bmin\y,bmax\y,0,1)
        va\z = RESCALE(*va\z,bmin\z,bmax\z,0,1)
         
        vb\x = RESCALE(*vb\x,bmin\x,bmax\x,0,1)
        vb\y = RESCALE(*vb\y,bmin\y,bmax\y,0,1)
        vb\z = RESCALE(*vb\z,bmin\z,bmax\z,0,1)
        
        vc\x = RESCALE(*vc\x,bmin\x,bmax\x,0,1)
        vc\y = RESCALE(*vc\y,bmin\y,bmax\y,0,1)
        vc\z = RESCALE(*vc\z,bmin\z,bmax\z,0,1)
         
        CArray::SetValuePtr(*geom\a_uvws,cnt,@va)
        CArray::SetValuePtr(*geom\a_uvws,cnt+1,@vb)
        CArray::SetValuePtr(*geom\a_uvws,cnt+2,@vc) 
        cnt+3
      Next i
      
    Else
    
      ;UVs
       For i=0 To CArray::GetCount(*geom\a_triangleindices)/3-1
        a = CArray::GetValueL(*geom\a_triangleindices,i*3)
        b = CArray::GetValueL(*geom\a_triangleindices,i*3+1)
        c = CArray::GetValueL(*geom\a_triangleindices,i*3+2)
    
        CArray::SetValuePtr(*geom\a_uvws,cnt,CArray::GetValue(*geom\a_positions,a))
        CArray::SetValuePtr(*geom\a_uvws,cnt+1,CArray::GetValue(*geom\a_positions,b))
        CArray::SetValuePtr(*geom\a_uvws,cnt+2,CArray::GetValue(*geom\a_positions,c)) 
        cnt+3
      Next i
    EndIf
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get UVWs from Extrusion
  ; ----------------------------------------------------------------------------
  Procedure GetUVWSFromExtrusion(*geom.PolymeshGeometry_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32)
    Protected nbu.i = CArray::GetCount(*points)-1
    Protected nbv.i = CArray::GetCount(*section)-1
    
    Protected incru.f = 1 / (nbu)
    Protected incrv.f = 1 / (nbv)
    
    Protected i,a,b,c,cnt
    Protected cu.f = 0
    Protected cv.f = 0
    
    Protected u.i,v.i
    Protected uvws.v3f32
    i=0
    For u=0 To nbu-1
      For v=0 To nbv-1
      
        Vector3::Set(@uvws,(u)*incru,0,(v)*incrv)
        CArray::SetValue(*geom\a_uvws,i,@uvws)
        Vector3::Set(@uvws,(u)*incru,0,(v+1)*incrv)
        CArray::SetValue(*geom\a_uvws,i+1,@uvws)
        Vector3::Set(@uvws,(u+1)*incru,0,(v)*incrv)
        CArray::SetValue(*geom\a_uvws,i+2,@uvws) 
        
        Vector3::Set(@uvws,(u)*incru,0,(v+1)*incrv)
        CArray::SetValue(*geom\a_uvws,i+3,@uvws)
        Vector3::Set(@uvws,(u+1)*incru,0,(v+1)*incrv)
        CArray::SetValue(*geom\a_uvws,i+4,@uvws)
        Vector3::Set(@uvws,(u+1)*incru,0,(v)*incrv)
        CArray::SetValue(*geom\a_uvws,i+5,@uvws) 
  
        i+6
      Next
    Next 
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get UVWs per Polygons
  ; ----------------------------------------------------------------------------
  Procedure GetUVWSPerPolygons(*geom.PolymeshGeometry_t)
    Protected nbf = CArray::GetCount(*geom\a_facecount)
    Protected p
    Protected nbp
    For p=0 To nbf-1
      ;*geom\a_faceindices
    Next
    
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  Recompute Normals
  ; ----------------------------------------------------------------------------
  Procedure RecomputeNormals(*mesh.PolymeshGeometry_t,smooth.f=0.5)
    
    Protected i,j,a,b,c,base
    Protected ab.v3f32, ac.v3f32,n.v3f32, norm.v3f32
    Protected *n.v3f32
  
    Protected *n1.v3f32
    Protected cnt = 0
  
    Vector3::Set(@n,0,0,0)

    ; First Triangle Normals
    For i=0 To *mesh\nbtriangles-1
      a = CArray::GetValueL(*mesh\a_triangleindices,i*3)
      b = CArray::GetValueL(*mesh\a_triangleindices,i*3+1)
      c = CArray::GetValueL(*mesh\a_triangleindices,i*3+2)
      Vector3::Sub(@ab,CArray::GetValue(*mesh\a_positions,a),CArray::GetValue(*mesh\a_positions,b))
      Vector3::Sub(@ac,CArray::GetValue(*mesh\a_positions,b),CArray::GetValue(*mesh\a_positions,c))
  
      Vector3::Cross(@norm,@ac,@ab)
      Vector3::NormalizeInPlace(@norm)
      CArray::SetValue(*mesh\a_normals,cnt,@norm)
      CArray::SetValue(*mesh\a_normals,cnt+1,@norm)
      CArray::SetValue(*mesh\a_normals,cnt+2,@norm)

      cnt+3
    Next i
    
    ; Then Polygons Normals
    Protected nbv, nbt
    CArray::SetCount(*mesh\a_polygonnormals, *mesh\nbpolygons)
    For i=0 To*mesh\nbpolygons-1
      nbv = CArray::GetvalueL(*mesh\a_facecount, i)
      nbt = nbv-2
      Vector3::Set(@n, 0,0,0)
      For j=0 To nbt-1
        Vector3::AddInPlace(@n, CArray::GetValue(*mesh\a_normals, base+j*3))
      Next
      Vector3::NormalizeInPlace(@n)
      CArray::SetValue(*mesh\a_polygonnormals, i, @n)
      base+nbt*3
    Next
    
    ; Finaly Vertex Normals
    If Carray::GetCount(*mesh\a_vertexpolygoncount) <> *mesh\nbpoints
      RecomputeVertexPolygons(*mesh)
    EndIf
    
    Protected nbp, index
    base = 0
    For i=0 To *mesh\nbpoints-1
      nbp = CArray::GetValueL(*mesh\a_vertexpolygoncount, i)
      Vector3::Set(@n, 0,0,0)
      For j=0 To nbp-1
        index = CArray::GetValueL(*mesh\a_vertexpolygonindices, base+j)
        Vector3::AddInPlace(@n, CArray::GetValue(*mesh\a_polygonnormals, index))
      Next
      Vector3::ScaleInPlace(@n, 1/nbp)
      CArray::SetValue(*mesh\a_pointnormals, i, @n)
      base + nbp
    Next
    
    ; Display Normals
    For i=0 To *mesh\nbsamples-1
      *n = CArray::GetValue(*mesh\a_pointnormals, CArray::GetValueL(*mesh\a_triangleindices, i))
      CArray::SetValue(*mesh\a_normals, i, *n)
    Next
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Recompute Tangents
  ; ----------------------------------------------------------------------------
  Procedure RecomputeTangents(*mesh.PolymeshGeometry_t)
    Protected i,a,b,c
    Protected ab.v3f32, ac.v3f32,t.v3f32, tan.v3f32
    Protected tab.v3f32,tac.v3f32
    Define.v3f32 *t1,*t2,*t3
    Protected *n.v3f32
  
    Protected *n1.v3f32
    Protected cnt = 0
    Protected r.f
  
    Vector3::Set(@t,0,0,0)
  
    For i=0 To CArray::GetCount(*mesh\a_tangents)-1
      CopyMemory(@t,CArray::GetPtr(*mesh\a_tangents,i),CArray::GetItemSize(*mesh\a_tangents))
    Next
    
    ; //	sum tangents per-triangle:
    ; First Triangle Normals
    For i=0 To *mesh\nbtriangles-1
      a = CArray::GetValueL(*mesh\a_triangleindices,i*3)
      b = CArray::GetValueL(*mesh\a_triangleindices,i*3+1)
      c = CArray::GetValueL(*mesh\a_triangleindices,i*3+2)
  
      Vector3::Sub(@ab,CArray::GetValue(*mesh\a_positions,a),CArray::GetValue(*mesh\a_positions,b))
      Vector3::Sub(@ac,CArray::GetValue(*mesh\a_positions,a),CArray::GetValue(*mesh\a_positions,c))
      
      Vector3::Sub(@tab,CArray::GetValue(*mesh\a_uvws,i*3+1),CArray::GetValue(*mesh\a_uvws,i*3))
      Vector3::Sub(@tac,CArray::GetValue(*mesh\a_uvws,i*3+2),CArray::GetValue(*mesh\a_uvws,i*3))
      
      r = 1;/(tab\x*tac\y - tab\y * tac\x)
      Vector3::Set(@tan,(tac\y*ab\x - tab\y * ac\x)*r,(tac\y*ab\y - tab\y * ac\y)*r,(tac\y*ab\z - tab\y * ac\z)*r)
      
      *t1 = CArray::GetValue(*mesh\a_tangents,i*3)
      Vector3::AddInPlace(*t1,@tan)
      
      *t2 = CArray::GetValue(*mesh\a_tangents,i*3+1)
      Vector3::AddInPlace(*t2,@tan)
      
      *t3 = CArray::GetValue(*mesh\a_tangents,i*3+2)
      Vector3::AddInPlace(*t3,@tan)

    Next
    Protected *tan.v3f32
    For i=0 To CArray::GetCount(*mesh\a_tangents)-1
      *tan = CArray::GetValue(*mesh\a_tangents,i)
      Vector3::NormalizeInPlace(*tan)
    Next
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Invert Normals
  ; ----------------------------------------------------------------------------
  Procedure InvertNormals(*mesh.PolymeshGeometry_t)
    Define i
    Define *norm.v3f32
    For i=0 To CArray::GetCount(*mesh\a_normals)-1
      *norm = CArray::GetValue(*mesh\a_normals,i)
      Vector3::ScaleInPlace(*norm,-1)
      
    Next i
    For i=0 To CArray::GetCount(*mesh\a_pointnormals)-1
      *norm = CArray::GetValue(*mesh\a_pointnormals,i)
      Vector3::ScaleInPlace(*norm,-1)
      
    Next i
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Recompute Triangles
  ; ----------------------------------------------------------------------------
  Procedure RecomputeTriangles(*mesh.PolymeshGeometry_t)
    Protected x,y,z,z2, nbv, nbt
    Define.v3f32 ab,ac,norm
  
    ; Rebuild triangle Data
    ;-----------------------------------
    Protected a, b, c, last , cnt
    z=0
    cnt=0
  
    ; Loop per Polygons
    ;------------------------------------
    For x=0 To *mesh\a_facecount\itemCount-1

      ;Get Nb Vertices
      nbv = PeekL(*mesh\a_facecount\data + x*4)

      ;Get Nb Triangles
      nbt = nbv-2
      ;Get Last Point
      last = z+nbv-1
      
      
      ;Store Triangles Data
      ;-----------------------------------
      For y=0 To nbt-1
        a = PeekL(*mesh\a_faceindices\data + (z+y) * 4)
        b = PeekL(*mesh\a_faceindices\data + (z+y+1) * 4)
        c = PeekL(*mesh\a_faceindices\data + last * 4)
        
        PokeL(*mesh\a_triangleindices\data + cnt * 4, a)
        PokeL(*mesh\a_triangleindices\data + (cnt+1) * 4,b)
        PokeL(*mesh\a_triangleindices\data + (cnt+2) * 4,c)
  
        cnt+3
  
      Next y
      z+nbv
    Next x
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Recompute Edges
  ; ----------------------------------------------------------------------------
  Procedure RecomputeEdges(*mesh.PolymeshGeometry_t)
    ; Get Unique Edges
    Protected NewMap uniqueEdges.i()
    Protected edgeKey.s
    Protected edgeID.i = 0
    Protected i, a, b, base
    
    base=0
    For i=0 To *mesh\nbpolygons-1
      nbv = CArray::GetValueL(*mesh\a_facecount, i)
      For j=0 To nbv-1
        a = CArray::GetValueL(*mesh\a_faceindices,base+j)
        b = CArray::GetValueL(*mesh\a_faceindices,base+((j+1)%nbv))
        
        If a>b
          edgeKey = Str(b)+","+Str(a)
        Else
          edgeKey = Str(a)+","+Str(b)
        EndIf

        AddMapElement(uniqueEdges(), edgeKey, #PB_Map_NoElementCheck)
      Next j
      base+nbv
    Next i
    
    Protected numUniqueEdges.i = MapSize(uniqueEdges())
    CArray::SetCount(*mesh\a_edgeindices, numUniqueEdges*2)
    *mesh\nbedges = numUniqueEdges
    i=0
    ForEach uniqueEdges()
      edgeKey = MapKey(uniqueEdges())
      CArray::SetValueL(*mesh\a_edgeindices, i*2, Val(StringField(edgeKey,1,",")))
      CArray::SetValueL(*mesh\a_edgeindices, i*2+1, Val(StringField(edgeKey,2,",")))
      i+1
    Next  
    ClearMap(uniqueEdges())
    FreeMap(uniqueEdges())
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Recompute Vertex Polygons
  ; ----------------------------------------------------------------------------
  Procedure RecomputeVertexPolygons(*mesh.PolymeshGeometry_t)
    Protected i, j, k, nbv, base, total
    Protected Dim indices.s(*mesh\nbpoints)
    base=0
    total = 0
    For i=0 To *mesh\nbpolygons-1
      nbv = CArray::GetValueL(*mesh\a_facecount, i)
      For j=0 To nbv-1
        k = CArray::GetValueL(*mesh\a_faceindices,base+j)
        indices(k) + Str(i)+","
        total+1
      Next j
      base+nbv
    Next i
    
    Debug indices
    
    CArray::SetCount(*mesh\a_vertexpolygoncount, *mesh\nbpoints)
    CArray::SetCount(*mesh\a_vertexpolygonindices, total)
    
    Protected nbp, index
    base = 0
    For i=0 To *mesh\nbpoints-1
      nbp = CountString(indices(i),",")
      CArray::SetValueL(*mesh\a_vertexpolygoncount, i, nbp)
      For j=1 To nbp
        index = Val(StringField(indices(i),j,","))
        CArray::SetValueL(*mesh\a_vertexpolygonindices, base+j-1, index)
      Next
      base + nbp
    Next

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Implementation
  ; ----------------------------------------------------------------------------
  Procedure Clear(*mesh.PolymeshGeometry_t)

    Protected i
    Protected *vertex.Vertex_t
;     If CArray::GetCount(*mesh\a_vertices)
;       For i=0 To CArray::GetCount(*mesh\a_vertices)-1
;         *vertex = CArray::GetValue(*mesh\a_vertices,i)
;         If *vertex : Vertex::Delete(*vertex) : EndIf
;       Next i
;     EndIf
    
;     Protected *edge.CEdge
;     For i=0 To *mesh\a_edges\GetCount()-1
;       *edge = *mesh\a_edges\GetValue(i)
;     Next i
;     *mesh\a_edges\SetCount(0)
;     
;     Protected *polygon.CPolygon
;     If *mesh\a_polygons\GetCount()
;       For i=0 To *mesh\a_polygons\GetCount()-1
;         *polygon = *mesh\a_polygons\GetValue(i)
;       Next i
;     EndIf
;     *mesh\a_polygons\SetCount(0)
;     
;     Protected *sample.CSample
;     If *mesh\a_samples\GetCount()
;       For i=0 To *mesh\a_samples\GetCount()-1
;         *sample = *mesh\a_samples\GetValue(i)
;         *sample\InstanceDestroy()
;       Next i
;     EndIf
    
    CArray::SetCount(*mesh\a_edgeindices,0)
    CArray::SetCount(*mesh\a_vertices,0)
    CArray::SetCount(*mesh\a_samples,0)
    CArray::SetCount(*mesh\a_colors,0)
    CArray::SetCount(*mesh\a_normals,0)
    CArray::SetCount(*mesh\a_positions,0)
    CArray::SetCount(*mesh\a_pointnormals,0)
    CArray::SetCount(*mesh\a_velocities,0)
    CArray::SetCount(*mesh\a_triangleindices,0)
    CArray::SetCount(*mesh\a_uvws,0)
    CArray::SetCount(*mesh\a_pointnormals,0)
    CArray::SetCount(*mesh\a_facecount,0)
    CArray::SetCount(*mesh\a_faceindices,0)
  
  EndProcedure
  
 
  ;---------------------------------------------------------
  ; Set 2 (From Topo Data Block)
  ;---------------------------------------------------------
  Procedure Set2(*mesh.PolymeshGeometry_t,*topo.Topology_t)
    
    ; Clear Old Memory
    Clear(*mesh)
    Topology::Copy(*mesh\topo, *topo)
    
    ; ReAllocate Memory
    Protected i
    Protected nbp = CArray::GetCount(*topo\vertices)

    CArray::SetCount(*mesh\a_positions,nbp)
    CArray::SetCount(*mesh\a_velocities,nbp)
    CArray::SetCount(*mesh\a_pointnormals,nbp)
    *mesh\nbpoints = nbp
    
    Protected *vertex.Geometry::Vertex_t
    Protected color.c4f32
    Protected normal.v3f32
    Protected pos.v3f32
    
    If CArray::GetCount(*topo\vertices)
      CopyMemory(CArray::GetPtr(*topo\vertices,0),CArray::GetPtr(*mesh\a_positions,0),nbp* CArray::GetItemSize(*topo\vertices))
    EndIf
    
    
    Protected vid
    Protected counter=0
    Protected started=0
    Protected nbi=0,nbf=0,nbt=0
    
    For i=0 To CArray::GetCount(*topo\faces)-1
      If CArray::GetValueL(*topo\faces,i) = -2
        nbt +(counter-2)
        counter=0
        nbf+1
      Else
        counter+1
        nbi+1
      EndIf
    Next
    
    CArray::SetCount(*mesh\a_facecount,nbf)
    CArray::SetCount(*mesh\a_faceindices,nbi)
    *mesh\nbtriangles = nbt
    
    *mesh\nbsamples = *mesh\nbtriangles*3
    CArray::SetCount(*mesh\a_triangleindices,*mesh\nbsamples)
    CArray::SetCount(*mesh\a_normals,*mesh\nbsamples)
    CArray::SetCount(*mesh\a_tangents,*mesh\nbsamples)
    CArray::SetCount(*mesh\a_colors,*mesh\nbsamples)
    CArray::SetCount(*mesh\a_uvws,*mesh\nbsamples)
    
    
    nbf=0
    nbi=0
    For i=0 To CArray::GetCount(*topo\faces)-1
      vid = CArray::GetValueL(*topo\faces,i)
      If  vid = -2
        CArray::SetValueL(*mesh\a_facecount,nbf,counter)
        nbf+1
        counter = 0
      Else
        CArray::SetValueL(*mesh\a_faceindices,nbi,vid)
        nbi+1
        counter+1
      EndIf
    Next i
    *mesh\nbpolygons = CArray::GetCount(*mesh\a_facecount)
    
    ; Recompute Polymesh datas
    RecomputeTriangles(*mesh)
    RecomputeEdges(*mesh)
    RecomputeVertexPolygons(*mesh)
;     ; GetDualGraph(*mesh)
    RecomputeNormals(*mesh,1)

    ; UVs
    GetUVWSFromPosition(*mesh,#True)
;     
;     ; Tangents
;     RecomputeTangents(*mesh)
;     
    ;Color
    Color::Set(@color,0.33,0.33,0.33,1.0);
    SetColors(*mesh,@color)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set
  ;---------------------------------------------------------
  Procedure Set(*mesh.PolymeshGeometry_t,*vertices.CArray::CArrayV3F32,*faces.CArray::CArrayLong)

    ; Copy Topo Data
    Topology::Set(*mesh\topo,*vertices,*faces)
    ; Rebuild Geometry
    Set2(*mesh,*mesh\topo)
  
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Set From Other
  ;---------------------------------------------------------
  Procedure SetFromOther(*geom.PolymeshGeometry_t,*other.PolymeshGeometry_t)
    *geom\nbpoints = *other\nbpoints
    *geom\nbpolygons = *other\nbpolygons
    *geom\nbedges = *other\nbedges
    *geom\nbtriangles = *other\nbtriangles
;     *geom\a_positions\Copy(*other\a_positions)
;     *geom\a_facecount\Copy(*other\a_facecount)
;     *geom\a_faceindices\Copy(*other\a_faceindices)
    PolymeshGeometry::GetTopology(*other)
    Topology::Copy(*geom\base,*other)
    Set2(*geom,*geom\base)
    
    
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Reset
  ;---------------------------------------------------------
  Procedure Reset(*geom.PolymeshGeometry_t)
    
    If Not CArray::GetCount(*geom\topo\vertices) = CArray::GetCount(*geom\base\vertices) Or Not CArray::GetCount(*geom\topo\faces) = CArray::GetCount(*geom\base\faces)
      Set2(*geom,*geom\base)
    Else
      SetPointsPosition(*geom,*geom\base\vertices)
      ;SetPointsNormal(*geom,*geom\base\normals)
      RecomputeNormals(*geom)
    EndIf 

  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Point Position
  ;---------------------------------------------------------
  Procedure SetPointsPosition(*mesh.PolymeshGeometry_t,*v.CArray::CArrayV3F32)
    Protected nbp = *mesh\nbpoints
    
    ; ---[ Check Nb Points ]--------------------------------
    If CArray::GetCount(*v) = nbp
      ; ---[ Set Point Position ]---------------------------
      CArray::Copy(*mesh\a_positions,*v)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Point Normal
  ;---------------------------------------------------------
  Procedure SetPointsNormal(*mesh.PolymeshGeometry_t,*v.CArray::CArrayV3F32)

    Protected nbs = *mesh\nbsamples
    
    ; ---[ Check Nb Samples ]--------------------------------
    If CArray::GetCount(*v) = nbs
      ; ---[ Set Sample Normal ]---------------------------
      Protected i
      For i=0 To nbs-1
        CArray::SetValue(*mesh\a_normals,i,CArray::GetValue(*v,i))
      Next 
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Point Color
  ;---------------------------------------------------------
  Procedure SetColors(*mesh.PolymeshGeometry_t,*color.c4f32= #Null);,*v.CArrayV3F32)
    Protected nbs = *mesh\nbsamples
    
    ; ---[ Set Point Normal ]---------------------------
    Protected i
    Protected c.c4f32
    Define.f r,g,b
   
    If *color
      r = *color\r
      g = *color\g
      b = *color\b
    Else
      r = Random(100)*0.01
      g = 0.5
      b = 0.1
    EndIf
    
    Color::Set(@c,r,g,b,1)
    For i=0 To nbs-1
      
      CArray::SetValue(*mesh\a_colors,i,@c)
    Next 
     
  EndProcedure
  
  ;---------------------------------------------------------
  ; Update Point Color
  ;---------------------------------------------------------
  Procedure UpdateColors(*mesh.PolymeshGeometry_t)
    Protected i,v
    Protected *vertex.Vertex_t

  ;   
  ;   For i=0 To *mesh\a_tritosample\GetCount()-1
  ;     v = *mesh\a_triangleindices\GetValue(i)  
  ;     *vertex = *mesh\a_vertices\GetValue(v)
  ;     *mesh\a_colors\SetValue(*mesh\a_tritosample\GetValue(i),*vertex\color)
  ;   Next
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Envelope Colors
  ;---------------------------------------------------------
  Procedure EnvelopeColors(*mesh.PolymeshGeometry_t,*weights.CArray::CArrayC4F32,*indices.CArray::CArrayC4U8,nbdeformers.i)
    Protected i
    Protected x,z
    Protected *colors.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
    Protected *color.c4f32
    Protected *ids.c4u8
    CArray::SetCount(*colors,nbdeformers)
    For i=0 To nbdeformers-1
      *color = CArray::GetValue(*colors,i)
      Color::Set(*color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
    Next
    
    
    For i=0 To *mesh\nbsamples-1
      ; Get Associated vertex Index
      x = CArray::GetValueL(*mesh\a_triangleindices,i)
      ; Get ID of first bone
      *ids = CArray::GetValue(*indices,x)
      z = *ids\r
      
      ; Set Sample Color
      CArray::SetValue(*mesh\a_colors,i,CArray::GetValue(*colors,z))
    Next
    CArray::Delete(*colors)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Point Color
  ;---------------------------------------------------------
  Procedure SetVerticesColor(*mesh.PolymeshGeometry_t,*in.CArray::CArrayPtr,*color.c4f32)
    Protected *vertex.Vertex_t
    Protected v
    Protected r.f = 1/255
    
    For v=0 To CArray::GetCount(*in)-1
      *vertex = CArray::GetValuePtr(*in,v)
      Color::Set(*vertex\color,*color\r*r,*color\g*r,*color\b*r,*color\a*r)
    Next v
    
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Random Color By Polygon
  ;---------------------------------------------------------
  Procedure RandomColorByPolygon(*mesh.PolymeshGeometry_t,*color.c4f32 = #Null,randomize.f = 0.5)
    Protected f
    Protected nbv,v
    Protected color.c4f32
    Color::Set(@color,0.5,0.5,0.5,1.0)
    If *color <> #Null
      Color::Set(@color,*color\r,*color\g,*color\b,*color\a)
    EndIf
    
    Protected tid = 0
    Protected nbt = 0
    For f=0 To CArray::GetCount(*mesh\a_facecount)-1
      nbv = CArray::GetValueL(*mesh\a_facecount,f)
      nbt = nbv-2
      If *color <> #Null
        Color::Set(@color,*color\r,*color\g,*color\b,*color\a)
      EndIf
      Color::Randomize(@color)
      For v=0 To nbt-1
        CArray::SetValue(*mesh\a_colors,tid+2,@color)
        CArray::SetValue(*mesh\a_colors,tid+1,@color)
        CArray::SetValue(*mesh\a_colors,tid,@color)
        tid+3
      Next
     
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Extrusion
  ;---------------------------------------------------------
  Procedure Extrusion(*geom.PolymeshGeometry_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32)
    If CArray::GetCount(*points)<=2 Or CArray::GetCount(*section)<2: ProcedureReturn : EndIf
  
    Topology::Extrusion(*geom\topo,*points,*section,#False)
    Set2(*geom,*geom\topo)
    GetUVWSFromExtrusion(*geom,*points,*section)
  
  EndProcedure
  
  ;---------------------------------------------------------
  ; Extrude Polygons
  ;---------------------------------------------------------
  Procedure ExtrudePolygons(*mesh.PolymeshGeometry_t, *polygons.CArray::CArrayLong, distance.f, separate.b)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Closest Location
  ;---------------------------------------------------------
  Procedure.b GetClosestLocation(*mesh.PolymeshGeometry_t, *p.v3f32, *loc.Geometry::Location_t, *distance, maxDistance.f=#F32_MAX)
    Protected hit.b=#False
    Protected distance.f, minDistance.f = Math::#F32_MAX
    Define.l a,b,c
    Define.v3f32 *a, *b, *c
    Define i
    For i = 0 To *mesh\nbtriangles - 1
      a = CArray::GetValueL(*mesh\a_triangleindices, i*3)
      b = CArray::GetValueL(*mesh\a_triangleindices, i*3+1)
      c = CArray::GetValueL(*mesh\a_triangleindices, i*3+2)
      *a = CArray::GetValue(*mesh\a_positions, a)
      *b = CArray::GetValue(*mesh\a_positions, b)
      *c = CArray::GetValue(*mesh\a_positions, c)
      Location::ClosestPoint(*loc, *a, *b, *c, *p, @minDistance)
    Next
    PokeF(*distance, minDistance)
    ProcedureReturn #True
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Update
  ;---------------------------------------------------------
  Procedure Update(*mesh.PolymeshGeometry_t)
  
    Protected *pos.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
    GetPointsPosition(*mesh,*pos)
    
    Protected i
    Protected offset.v3f32
    Protected pos.v3f32
    Vector3::Set(@offset,0,0.02,0.01)
    For i = 0 To *mesh\nbpoints-1
      Vector3::Add(@pos,CArray::GetValue(*pos,i),@offset)
      CArray::SetValue(*pos,i,@pos)
    Next i
    SetPointsPosition(*mesh,*pos)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Nb Samples
  ;---------------------------------------------------------
  Procedure.i GetNbSamples(*mesh.PolymeshGeometry_t)
    ProcedureReturn *mesh\nbsamples
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Get Nb Edges
  ;---------------------------------------------------------
  Procedure.i GetNbEdges(*mesh.PolymeshGeometry_t)
    ProcedureReturn *mesh\nbedges
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Nb Points
  ;---------------------------------------------------------
  Procedure.i GetNbPolygons(*mesh.PolymeshGeometry_t)
    ProcedureReturn *mesh\nbpolygons
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Nb Triangles
  ;---------------------------------------------------------
  Procedure.i GetNbTriangles(*mesh.PolymeshGeometry_t)
    ProcedureReturn *mesh\nbtriangles
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Get Point Position
  ;---------------------------------------------------------
  Procedure GetPointsPosition(*mesh.PolymeshGeometry_t,*io_pos.CArray::CArrayV3F32)

    CArray::Copy(*io_pos,*mesh\a_positions)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Point Normal
  ;---------------------------------------------------------
  Procedure GetPointsNormal(*mesh.PolymeshGeometry_t,*io_norm.CArray::CArrayV3F32)

    CArray::Copy(*io_norm,*mesh\a_normals)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Triangle Area (given three edges length)
  ;---------------------------------------------------------
  Procedure.f TriangleArea(a.f, b.f, c.f)
	  Protected p.f = (a + b + c) / 2.0
	  ProcedureReturn Sqr(p*(p - a)*(p - b)*(p - c))
  EndProcedure
  
  ;---------------------------------------------------------
  ; Compute Polygon Areas
  ;---------------------------------------------------------
  Procedure ComputePolygonAreas(*mesh.PolymeshGeometry_t)

    Protected nbv, nbt, last
    Protected a, b, c, t = 0
    Protected x, y, z=0
    Protected area.f, tArea.f
    *mesh\totalArea = 0.0
    Protected ab.v3f32, ac.v3f32, bc.v3f32
    CArray::SetCount(*mesh\a_triangleareas, *mesh\nbtriangles)
    CArray::SetCount(*mesh\a_polygonareas, *mesh\nbpolygons)
    
  
    ; Loop Per Polygon
    ;------------------------------------
    For x=0 To CArray::GetCount(*mesh\a_facecount)-1

      ; Get Nb Vertices
      nbv = CArray::GetValueL(*mesh\a_facecount,x)

      ; Get Nb Triangles
      nbt = nbv-2
      ; Get Last Point
      last = z+nbv-1
      ;Reset Area
      area = 0
      ; Compute and Store Area
      For y=0 To nbt-1
        a = CArray::GetValueL(*mesh\a_faceindices,z+y)
        b = CArray::GetValueL(*mesh\a_faceindices,z+y+1)
        c = CArray::GetValueL(*mesh\a_faceindices,last)
        
        Vector3::Sub(@ab, CArray::GetValue(*mesh\a_positions, b), CArray::GetValue(*mesh\a_positions, a))
        Vector3::Sub(@ac, CArray::GetValue(*mesh\a_positions, c), CArray::GetValue(*mesh\a_positions, a))
        Vector3::Sub(@bc, CArray::GetValue(*mesh\a_positions, c), CArray::GetValue(*mesh\a_positions, b))
        tArea = TriangleArea(Vector3::Length(@ab), Vector3::Length(@ac), Vector3::Length(@bc))
        CArray::SetValueF(*mesh\a_triangleareas, t, tArea)
        t + 1
        area + tArea
      Next y
      *mesh\totalArea + area
      CArray::SetValueF(*mesh\a_polygonareas, x, area)
      z+nbv
    Next x

  EndProcedure
  
  ;---------------------------------------------------------
  ; Init Sampling
  ;---------------------------------------------------------
  Procedure InitSampling(*mesh.PolymeshGeometry_t)
    ComputePolygonAreas(*mesh)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Init Sampling
  ;---------------------------------------------------------
  Procedure Sample(*mesh.PolymeshGeometry_t, *t.Transform::Transform_t, numSamples, *io.CArray::CArrayV3F32)
    Protected r.f
    Protected loc.Geometry::Location_t
    loc\geometry = *mesh
    loc\t = *t
    CArray::SetCount(*io, numSamples)
    Protected i, j
    For i=0 To numSamples - 1
      r = Random_0_1() * *mesh\totalArea
      For j=0 To *mesh\nbtriangles - 1
        If r < CArray::GetValueF(*mesh\a_triangleareas, j)
          loc\u=Random_0_1()
          loc\v=Random_0_1()
          If loc\u + loc\v > 1
            loc\u = 1-loc\u
            loc\v = 1-loc\v
          EndIf
          loc\w = 1-loc\u-loc\v
          loc\tid = j
          CArray::SetValue(*io, i, Location::GetPosition(@loc))
          Break
        Else
          r - CArray::GetValueF(*mesh\a_triangleareas, j)
        EndIf
      Next
    Next
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Visit Neighbors
  ;---------------------------------------------------------
  Procedure VisitNeighbors(*in.CArray::CArrayPtr,*out.CArray::CArrayPtr,islandID.i)
    
    
    Protected *neighbors.CArray::CArrayPtr
    Protected *vertex.Vertex_t
    Protected *neighbor.Vertex_t
    Protected v,n
    For v=0 To CArray::GetCount(*in)-1
      *vertex = CArray::GetValuePtr(*in,v)
      *neighbors = *vertex\neighbors
      For n=0 To CArray::GetCount(*neighbors)-1
        *neighbor = CArray::GetValuePtr(*neighbors,n)
        If Not *neighbor\visited
          *neighbor\visited = #True
          *neighbor\islandid = islandID
          CArray::Append(*out,*neighbor)
        EndIf
        
      Next n
      
    Next v
    
  EndProcedure
  
  Procedure GetPolygonIslands(*mesh.PolymeshGeometry_t)
  
    ResetVisitedTags(*mesh)
    Protected nbIslands = 0
    Protected *in.CArray::CArrayPtr = CArray::newCArrayPtr()
    Protected *out.CArray::CArrayPtr = CArray::newCArrayPtr()
    Protected *vertex.Vertex_t
    Protected v
    Protected closed.b=#False
    Protected color.c4f32
    
;     For v=0 To *mesh\nbpoints-1
;       *vertex = CArray::GetValue(*mesh\a_vertices,v)
;       If Not *vertex\visited
;       
;         Color::Set(@color,Random(255),Random(255),Random(255),255)
;         *vertex\visited = #True
;         *vertex\islandid = nbIslands
;         CArray::SetCount(*in,0)
;         CArray::Append(*in,*vertex)
;         closed = #False
;         While Not closed
;           SetVerticesColor(*mesh,*in,@color)
;           VisitNeighbors(*in,*out,nbIslands)
;           If Not CArray::GetCount(*out)
;             closed = #True
;           Else
;             CArray::Copy(*in,*out)
;             CArray::SetCount(*out,0)
;           EndIf
;         Wend
;         nbIslands+1
;       EndIf
;     Next v
    
    ;OPolymeshGeometry_UpdateColors(*mesh)
  EndProcedure

  ;---------------------------------------------------------
  ; Topology Attribute
  ;---------------------------------------------------------
  Procedure GetTopology(*geom.PolymeshGeometry_t)
    Protected i,j,src_offset,dst_offset,nbv
    Protected *topo.Topology_t = *geom\topo
    Protected size_t.i
    Protected f.f
    nbv = CArray::GetCount(*geom\a_positions)
    If nbv>3:
      CArray::SetCount(*topo\vertices,nbv)
      CArray::Copy(*topo\vertices,*geom\a_positions)
      
      Protected nbf = CArray::GetCount(*geom\a_faceindices) + CArray::GetCount(*geom\a_facecount)
  
      CArray::SetCount(*topo\faces,nbf)
      src_offset = 0
      dts_offset = 0
      For i=0 To CArray::GetCount(*geom\a_facecount)-1
        nbv = CArray::GetValueL(*geom\a_facecount,i)
        CopyMemory(CArray::GetPtr(*geom\a_faceindices, src_offset), CArray::GetPtr(*topo\faces, dst_offset), nbv * CArray::GetItemSize(*topo\faces))
        src_offset + nbv 
        dst_offset + (nbv+1)
        CArray::SetValueL(*topo\faces,dst_offset+nbv,-2)

      Next i
    EndIf
    
    ProcedureReturn *topo
      
  EndProcedure
  
  ;---------------------------------------------------------
  ; Bunny Primitive
  ;---------------------------------------------------------
  Procedure BunnyTopology(*topo.Topology_t)
   
    Define v=0
    Define p.v3f32
    CArray::SetCount(*topo\vertices,Shape::#BUNNY_NUM_VERTICES)
  
    CopyMemory(SHAPE::GetVertices(Shape::#SHAPE_BUNNY),CArray::GetPtr(*topo\vertices,0),Shape::#BUNNY_NUM_VERTICES * CArray::GetItemSize(*topo\vertices))
  
    
    Define i.i
    Define l.l
    CArray::SetCount(*topo\faces,Shape::#BUNNY_NUM_INDICES+Shape::#BUNNY_NUM_TRIANGLES)
    Define id=0
    Define t
    For t=0 To Shape::#BUNNY_NUM_TRIANGLES-1
      For i=0 To 2
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_BUNNY)+t*3*SizeOf(l))
        CArray::SetValueL(*topo\faces,id,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_BUNNY)+t*3*SizeOf(l)+SizeOf(l))
        CArray::SetValueL(*topo\faces,id+1,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_BUNNY)+t*3*SizeOf(l)+2*SizeOf(l))
        CArray::SetValueL(*topo\faces,id+2,l)
      Next i
      
      CArray::SetValueL(*topo\faces,id+3,-2)
      id+4
    Next t
    *topo\dirty = #True
  EndProcedure
  
  ;---------------------------------------------------------
  ; Teapot Primitive
  ;---------------------------------------------------------
  Procedure TeapotTopology(*topo.Topology_t)
  
   
    Define v=0
    Define p.v3f32
    CArray::SetCount(*topo\vertices,Shape::#TEAPOT_NUM_VERTICES)
  
    CopyMemory(SHAPE::GetVertices(Shape::#SHAPE_TEAPOT),CArray::GetPtr(*topo\vertices,0),Shape::#TEAPOT_NUM_VERTICES * CArray::GetItemSize(*topo\vertices))
  
    
    Define i.i
    Define l.l
    CArray::SetCount(*topo\faces,Shape::#TEAPOT_NUM_INDICES+Shape::#TEAPOT_NUM_TRIANGLES)
    Define id=0
    Define t
    For t=0 To Shape::#TEAPOT_NUM_TRIANGLES-1
      For i=0 To 2
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TEAPOT)+t*3*SizeOf(l))
        CArray::SetValueL(*topo\faces,id+2,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TEAPOT)+t*3*SizeOf(l)+SizeOf(l))
        CArray::SetValueL(*topo\faces,id+1,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TEAPOT)+t*3*SizeOf(l)+2*SizeOf(l))
        CArray::SetValueL(*topo\faces,id,l)
      Next i
      
      CArray::SetValueL(*topo\faces,id+3,-2)
      id+4
    Next t
    *topo\dirty = #True
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Torus Primitive
  ;---------------------------------------------------------
  Procedure Torus(*geom.PolymeshGeometry_t)
  
    Define *vertices.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
    Define *indices.CArray::CArrayInt = CArray::newCArrayInt()
    
    Define v=0
    Define p.v3f32
    CArray::SetCount(*vertices,Shape::#TORUS_NUM_VERTICES)
    For v=0 To Shape::#TORUS_NUM_VERTICES-1
      CopyMemory(Shape::?shape_torus_positions+v*SizeOf(p),@p,SizeOf(p))
      CArray::SetValue(*vertices,v,@p)
    Next v
    
    Define i,i2
    CArray::SetCount(*indices,Shape::#TORUS_NUM_INDICES+Shape::#TORUS_NUM_TRIANGLES)
    
    Define id=0
    Define t

    For t=0 To Shape::#TORUS_NUM_TRIANGLES-1
      For i=0 To 2
        i2 = PeekL(Shape::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(i))
        CArray::SetValueL(*indices,id,i2)
        i2 = PeekL(Shape::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(i)+SizeOf(i))
         CArray::SetValueL(*indices,id+1,i2)
        i2 = PeekL(Shape::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(i)+2*SizeOf(i))
         CArray::SetValueL(*indices,id+2,i2)
      Next i
      
       CArray::SetValueL(*indices,id+3,-2)
      id+4
    Next t
    
    Set(*geom,*vertices,*indices)
    CArray::Delete(*vertices)
    CArray::Delete(*indices)
  EndProcedure
  
  Procedure TorusTopology(*topo.Topology_t)
  
   Define v=0
    Define p.v3f32
    CArray::SetCount(*topo\vertices,Shape::#TORUS_NUM_VERTICES)
  
    CopyMemory(SHAPE::GetVertices(Shape::#SHAPE_TORUS),CArray::GetPtr(*topo\vertices,0),Shape::#TORUS_NUM_VERTICES * CArray::GetItemSize(*topo\vertices))
  
    
    Define i.i
    Define l.l
    CArray::SetCount(*topo\faces,Shape::#TORUS_NUM_INDICES+Shape::#TORUS_NUM_TRIANGLES)
    Define id=0
    Define t
    For t=0 To Shape::#TORUS_NUM_TRIANGLES-1
      For i=0 To 2
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(l))
        CArray::SetValueL(*topo\faces,id+2,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(l)+SizeOf(l))
        CArray::SetValueL(*topo\faces,id+1,l)
        l = PeekL(SHAPE::GetFaces(Shape::#SHAPE_TORUS)+t*3*SizeOf(l)+2*SizeOf(l))
        CArray::SetValueL(*topo\faces,id,l)
      Next i
      
      CArray::SetValueL(*topo\faces,id+3,-2)
      id+4
    Next t
    *topo\dirty = #True
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Cube Shape Primitive
  ;---------------------------------------------------------
  Procedure Cube(*geom.PolymeshGeometry_t,length.f=1.0,u=10,v=10,w=10)
  
    Protected x = 0
    If *geom\nbpoints <> 8
      *geom\nbpoints = 8
      CArray::SetCount(*geom\a_positions,*geom\nbpoints)
    EndIf
    
    If *geom\nbpolygons <> 6
      *geom\nbpolygons = 6
;       CArray::SetCount(*geom\a_polygons,*geom\nbpoints)
    EndIf
    
    If *geom\nbsamples <> 24
      *geom\nbsamples = 24
;       CArray::SetCount(*geom\a_polygons,*geom\nbpoints)
       CArray::SetCount(*geom\a_normals,*geom\nbsamples)
       CArray::SetCount(*geom\a_colors,*geom\nbsamples)
       CArray::SetCount(*geom\a_uvws,*geom\nbsamples)
    EndIf
  
    Protected p.v3f32
    Protected l.f = length*0.5
    
    ; ---[ Vertices ]---------------------------
    Vector3::Set(@p,l,l,l)
    CArray::SetValue(*geom\a_positions,0,@p)
    Vector3::Set(@p,l,l,-l)
    CArray::SetValue(*geom\a_positions,1,@p)
    Vector3::Set(@p,-l,l,-l)
    CArray::SetValue(*geom\a_positions,2,@p)
    Vector3::Set(@p,-l,l,l)
    CArray::SetValue(*geom\a_positions,3,@p)
    Vector3::Set(@p,l,-l,l)
    CArray::SetValue(*geom\a_positions,4,@p)
    Vector3::Set(@p,l,-l,-l)
    CArray::SetValue(*geom\a_positions,5,@p)
    Vector3::Set(@p,-l,-l,-l)
    CArray::SetValue(*geom\a_positions,6,@p)
    Vector3::Set(@p,-l,-l,l)
    CArray::SetValue(*geom\a_positions,7,@p)
    
    CArray::SetCount(*geom\a_faceindices,24)
    
    ; ---[ Face ]--------------------------------
    CArray::SetValueL(*geom\a_faceindices,0,3)
    CArray::SetValueL(*geom\a_faceindices,1,2)
    CArray::SetValueL(*geom\a_faceindices,2,1)
    CArray::SetValueL(*geom\a_faceindices,3,0)
    
    CArray::SetValueL(*geom\a_faceindices,4,2)
    CArray::SetValueL(*geom\a_faceindices,5,6)
    CArray::SetValueL(*geom\a_faceindices,6,5)
    CArray::SetValueL(*geom\a_faceindices,7,1)
    
    CArray::SetValueL(*geom\a_faceindices,8,6)
    CArray::SetValueL(*geom\a_faceindices,9,7)
    CArray::SetValueL(*geom\a_faceindices,10,4)
    CArray::SetValueL( *geom\a_faceindices,11,5)
    
    CArray::SetValueL(*geom\a_faceindices,12,7)
    CArray::SetValueL(*geom\a_faceindices,13,3)
    CArray::SetValueL(*geom\a_faceindices,14,0)
    CArray::SetValueL(*geom\a_faceindices,15,4)
    
    CArray::SetValueL(*geom\a_faceindices,16,1)
    CArray::SetValueL(*geom\a_faceindices,17,5)
    CArray::SetValueL(*geom\a_faceindices,18,4)
    CArray::SetValueL(*geom\a_faceindices,19,0)
    
    CArray::SetValueL(*geom\a_faceindices,20,7)
    CArray::SetValueL(*geom\a_faceindices,21,6)
    CArray::SetValueL(*geom\a_faceindices,22,2)
    CArray::SetValueL(*geom\a_faceindices,23,3)
    
    ; ---[ UVWs ]--------------------------------
    Protected i
    Protected *v.v3f32
    Protected offset.v3f32
    For i=0 To *geom\nbsamples-1
      Select Mod(i,6)
        Case 0
          Vector3::Set(@p,0,0,0);
        Case 1
          Vector3::Set(@p,1,0,0)
        Case 2
          Vector3::Set(@p,1,1,0)
        Case 3
          Vector3::Set(@p,0,0,0)
      EndSelect
      CArray::SetValue(*geom\a_uvws,i,@p)
     
    Next i
    
    
    ;Count
    CArray::SetCount(*geom\a_facecount,6)
    CArray::SetValueL(*geom\a_facecount,0,4)
    CArray::SetValueL(*geom\a_facecount,1,4)
    CArray::SetValueL(*geom\a_facecount,2,4)
    CArray::SetValueL(*geom\a_facecount,3,4)
    CArray::SetValueL(*geom\a_facecount,4,4)
    CArray::SetValueL(*geom\a_facecount,5,4)
    
    Protected color.c4f32
    Color::Set(@color,1,0,0,1);
    SetColors(*geom,@color)
    RecomputeTriangles(*geom)
    RecomputeNormals(*geom,1)
    GetTopology(*geom)
    
  EndProcedure
  
  Procedure CubeTopology(*topo.Topology_t,radius.f,u.i,v.i,w.i)
  
    Protected x = 0
    CArray::SetCount(*topo\vertices,8)
    CArray::SetCount(*topo\faces,30)
  
    Protected p.v3f32
    Protected l.f = radius*0.5
  
    Vector3::Set(@p,l,l,l)
    CArray::SetValue(*topo\vertices,0,@p)
    Vector3::Set(@p,l,l,-l)
    CArray::SetValue(*topo\vertices,1,@p)
    Vector3::Set(@p,-l,l,-l)
    CArray::SetValue(*topo\vertices,2,@p)
    Vector3::Set(@p,-l,l,l)
    CArray::SetValue(*topo\vertices,3,@p)
    Vector3::Set(@p,l,-l,l)
    CArray::SetValue(*topo\vertices,4,@p)
    Vector3::Set(@p,l,-l,-l)
    CArray::SetValue(*topo\vertices,5,@p)
    Vector3::Set(@p,-l,-l,-l)
    CArray::SetValue(*topo\vertices,6,@p)
    Vector3::Set(@p,-l,-l,l)
    CArray::SetValue(*topo\vertices,7,@p)
    
    
    ;Face
    CArray::SetValueL(*topo\faces,0,3)
    CArray::SetValueL(*topo\faces,1,2)
    CArray::SetValueL(*topo\faces,2,1)
    CArray::SetValueL(*topo\faces,3,0)
    CArray::SetValueL(*topo\faces,4,-2)
    
    CArray::SetValueL(*topo\faces,5,2)
    CArray::SetValueL(*topo\faces,6,6)
    CArray::SetValueL(*topo\faces,7,5)
    CArray::SetValueL(*topo\faces,8,1)
    CArray::SetValueL(*topo\faces,9,-2)
    
    CArray::SetValueL(*topo\faces,10,6)
    CArray::SetValueL(*topo\faces,11,7)
    CArray::SetValueL(*topo\faces,12,4)
    CArray::SetValueL(*topo\faces,13,5)
    CArray::SetValueL(*topo\faces,14,-2)
    
    CArray::SetValueL(*topo\faces,15,7)
    CArray::SetValueL(*topo\faces,16,3)
    CArray::SetValueL(*topo\faces,17,0)
    CArray::SetValueL(*topo\faces,18,4)
    CArray::SetValueL(*topo\faces,19,-2)
    
    CArray::SetValueL(*topo\faces,20,1)
    CArray::SetValueL(*topo\faces,21,5)
    CArray::SetValueL(*topo\faces,22,4)
    CArray::SetValueL(*topo\faces,23,0)
    CArray::SetValueL(*topo\faces,24,-2)
    
    CArray::SetValueL(*topo\faces,25,7)
    CArray::SetValueL(*topo\faces,26,6)
    CArray::SetValueL(*topo\faces,27,2)
    CArray::SetValueL(*topo\faces,28,3)
    CArray::SetValueL(*topo\faces,29,-2)
    
    *topo\dirty = #True
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Sphere Shape Primitive
  ;---------------------------------------------------------
  Procedure Sphere(*geom.PolymeshGeometry_t,radius.f=1,lats.i=8,longs.i=8)
  
    
    Protected nbp = (longs-2)*lats+2
    
    CArray::SetCount(*geom\a_positions,nbp)
    CArray::SetCount(*geom\a_pointnormals,nbp)
    *geom\nbpoints = nbp
    
    ; Vertices Position
    Protected i, j, k
    Protected p.v3f32
    Define.f lat,y,yr,lng,x,z
    
    For i = 0 To longs-1
      lng = #F32_PI *(-0.5 + i/(longs-1))
      y = radius * Sin(lng)
      yr = radius * Cos(lng)
      If i=0
        Vector3::Set(@p,0,-radius,0)
        CArray::SetValue(*geom\a_positions,0,@p)
  
      ElseIf i = longs-1
        Vector3::Set(@p,0,radius,0)
        CArray::SetValue(*geom\a_positions,nbp-1,@p)
  
      Else
        For j = 0 To lats-1
          lat = 2*#F32_PI * ((j-1)*(1/lats))
          x = Cos(lat)
          z = Sin(lat)
          Vector3::Set(@p,x*yr,y,z*yr)
          k = (i-1)*lats+j+1
          CArray::SetValue(*geom\a_positions,k,@p)
        Next j
      EndIf
    Next i
    
    
    ; Face Indices
    CArray::SetCount(*geom\a_facecount,(longs-1)*lats)
    CArray::SetCount(*geom\a_faceindices,(longs-3)*lats*4 + 2*lats*3)
    *geom\nbpolygons = (longs-1)*lats
    
    
    Define.i i1,i2,i3,i4,fcount, icount
    *geom\nbsamples = 0
    For i=0 To longs-2
      For j=0 To lats-1
        If i=0
          i1 = 0
          i2 = j+1
          i3 = (j+1)%lats+1
          CArray::SetValueL(*geom\a_facecount,j,3)
          CArray::SetValueL(*geom\a_faceindices,j*3,i3)
          CArray::SetValueL(*geom\a_faceindices,j*3+1,i2)
          CArray::SetValueL(*geom\a_faceindices,j*3+2,i1)
          *geom\nbsamples +3
          icount + 3
          fcount + 1
        ElseIf i= longs-2
          i1 = nbp-1
          i2 = nbp - lats +j-1
          If j=lats-1
            i3 = nbp - lats-1
          Else
            i3 = nbp - lats+j
          EndIf
          
          CArray::SetValueL(*geom\a_facecount,fcount,3)
          CArray::SetValueL(*geom\a_faceindices,icount,i1)
          CArray::SetValueL(*geom\a_faceindices,icount+1,i2)
          CArray::SetValueL(*geom\a_faceindices,icount+2,i3)
          *geom\nbsamples +3
          icount + 3
          fcount + 1
        Else
          i1 = (i-1)*lats+j+1
          i4 = i1+lats
          
          If j=lats-1
            i2 = i1-lats+1
            i3 = i1+1
          Else
            i2 = i1+1
            i3 = i1+lats+1
          EndIf
          
          CArray::SetValueL(*geom\a_facecount,fcount,4)
          CArray::SetValueL(*geom\a_faceindices,icount,i1)
          CArray::SetValueL(*geom\a_faceindices,icount+1,i2)
          CArray::SetValueL(*geom\a_faceindices,icount+2,i3)
          CArray::SetValueL(*geom\a_faceindices,icount+3,i4)
          *geom\nbsamples +4
          icount + 4
          fcount + 1
        EndIf
        
        
      Next j
    Next i
    
    CArray::SetCount(*geom\a_normals,*geom\nbsamples)
    CArray::SetCount(*geom\a_colors,*geom\nbsamples)
    CArray::SetCount(*geom\a_uvws,*geom\nbsamples)
    *geom\nbtriangles = *geom\nbsamples/3
    
  
    
    Protected color.c4f32
    Color::Set(@color,Random(255)/255,Random(255)/255,Random(255)/255,1.0)
   SetColors(*geom,@color)
    RecomputeTriangles(*geom)
    RecomputeNormals(*geom,1)
  
    GetTopology(*geom)
    
    ;UVs
    GetUVWSFromPosition(*geom)
  
  
  EndProcedure
  
  Procedure SphereTopology(*topo.Topology_t,radius.f=1,lats.i=8,longs.i=8)
  
    Protected nbp = (longs-2)*lats+2
    
    CArray::SetCount(*topo\vertices,nbp)
    ; Vertices Position
    Protected i, j, k
    Protected p.v3f32
    Define.f lat,y,yr,lng,x,z
    
    For i = 0 To longs-1
      lng = #F32_PI *(-0.5 + i/(longs-1))
      y = radius * Sin(lng)
      yr = radius * Cos(lng)
      If i=0
        Vector3::Set(@p,0,-radius,0)
        CArray::SetValue(*topo\vertices,0,@p)
  
  
      ElseIf i = longs-1
        Vector3::Set(@p,0,radius,0)
        CArray::SetValue(*topo\vertices,nbp-1,@p)
  
  
      Else
        For j = 0 To lats-1
          lat = 2*#F32_PI * ((j-1)*(1/lats))
          x = Cos(lat)
          z = Sin(lat)
          Vector3::Set(@p,x*yr,y,z*yr)
          k = (i-1)*lats+j+1
          CArray::SetValue(*topo\vertices,k,@p)
  
        Next j
      EndIf
    Next i
    
    
    ; Face Indices
    Protected nbf = (longs-1)*lats
    Protected nbi = (longs-3)*lats*4 + 2*lats*3
    
    Define counter = 0
    CArray::SetCount(*topo\faces,nbf+nbi)
    
    Define.i i1,i2,i3,i4,offset
  
    For i=0 To longs-2
      For j=0 To lats-1
        If i=0
          i1 = 0
          i2 = j+1
          i3 = (j+1)%lats+1
          CArray::SetValueL(*topo\faces,offset,i3)
          CArray::SetValueL(*topo\faces,offset+1,i2)
          CArray::SetValueL(*topo\faces,offset+2,i1)
          CArray::SetValueL(*topo\faces,offset+3,-2)
  
          offset+4
          counter +4
        ElseIf i= longs-2
          i1 = nbp-1
          i2 = nbp - lats +j-1
          If j=lats-1
            i3 = nbp - lats-1
          Else
            i3 = nbp - lats+j
          EndIf
          
          CArray::SetValueL(*topo\faces,offset,i1)
          CArray::SetValueL(*topo\faces,offset+1,i2)
          CArray::SetValueL(*topo\faces,offset+2,i3)
          CArray::SetValueL(*topo\faces,offset+3,-2)
  
          offset+4
          counter+4
  
        Else
          i1 = (i-1)*lats+j+1
          i4 = i1+lats
          
          If j=lats-1
            i2 = i1-lats+1
            i3 = i1+1
          Else
            i2 = i1+1
            i3 = i1+lats+1
          EndIf
          
          CArray::SetValueL(*topo\faces,offset,i1)
          CArray::SetValueL(*topo\faces,offset+1,i2)
          CArray::SetValueL(*topo\faces,offset+2,i3)
          CArray::SetValueL(*topo\faces,offset+3,i4)
          CArray::SetValueL(*topo\faces,offset+4,-2)
          
          offset+5
          counter+5
  
        EndIf
        
        
      Next j
    Next i
   
    *topo\dirty = #True
  EndProcedure
  
  
  
  ;--------------------------------------------------------------
  ; Grid Shape
  ;--------------------------------------------------------------
  Procedure Grid(*geom.PolymeshGeometry_t,sizX.f=1,sizZ.f=1,u.i=8,v.i=8)
    
    *geom\nbpoints = u*v
    *geom\nbedges = 0
    *geom\nbpolygons = (u-1)*(v-1)
    *geom\nbsamples = *geom\nbpolygons *6
    
    CArray::SetCount(*geom\a_positions,*geom\nbpoints)
    CArray::SetCount(*geom\a_pointnormals,*geom\nbpoints)
    CArray::SetCount(*geom\a_normals,*geom\nbsamples)
    CArray::SetCount(*geom\a_colors,*geom\nbsamples)
    CArray::SetCount(*geom\a_uvws,*geom\nbsamples)
    CArray::SetCount(*geom\a_triangleindices,*geom\nbsamples)
    
  
    *geom\nbtriangles = *geom\nbpolygons * 2
    
    CArray::SetCount(*geom\a_faceindices,*geom\nbpolygons * 4)
    CArray::SetCount(*geom\a_facecount,*geom\nbpolygons)
    
    Protected x,z
    Define.f stepx, stepz
    stepx = sizX*1/(u-1)
    stepz = sizZ*1/(v-1)
    
    Protected pos.v3f32
    Protected i
    
    ; Point Position
    For x=0 To u-1
      For z=0 To v-1
        Vector3::Set(@pos,-0.5*sizX+x*stepx,0,-0.5*sizZ+z*stepz)
        CArray::SetValue(*geom\a_positions,x*u+z,@pos)
      Next z
    Next x
    
    ; Polygonal Description
    Protected column, row
    For x=0 To *geom\nbpolygons-1
      column = x/(u-1)*u
      row = x%(u-1)
     
      CArray::SetValueL(*geom\a_faceindices,x*4+3,column+row)
      CArray::SetValueL(*geom\a_faceindices,x*4+2,column+row+1)
      CArray::SetValueL(*geom\a_faceindices,x*4+1,column+row+u+1)
      CArray::SetValueL(*geom\a_faceindices,x*4+0,column+row+u)
      CArray::SetValueL(*geom\a_facecount,x,4)  
    Next x
    
    ; Update Geometry
    Protected color.c4f32
    RecomputeTriangles(*geom)
    RecomputeNormals(*geom,1)
    GetTopology(*geom)
   
    ;Color
    Color::Set(@color,1,Random(255)/255,Random(255)/255,Random(255)/255);
    SetColors(*geom,@color)
    
    ;UVWs
    GetUVWSFromPosition(*geom,#True)
   
  EndProcedure
  
  
  Procedure GridTopology(*topo.Topology_t,radius.f,u.i,v.i)
    Math::MAXIMUM(u,2)
    Math::MAXIMUM(v,2)
    
    Protected nbp = (u-1)*(v-1)
    Protected nbs = nbp *4
  
    CArray::SetCount(*topo\vertices,u*v)
    CArray::SetCount(*topo\faces,nbp+nbs)
    
    Protected x,z
    Define.f stepx, stepz
    stepx = radius*1/(u-1)
    stepz = radius*1/(v-1)
    
    Protected pos.v3f32
    For x=0 To u-1
      For z=0 To v-1
        Vector3::Set(@pos,-0.5*radius+x*stepx,0,-0.5*radius+z*stepz)
        CArray::SetValue(*topo\vertices,x*u+z,@pos)
      Next z
    Next x
    
    Protected column, row
    Protected offset=0
  ;   For z=0 To v-2
  ;     For x=0 To u-2
  ;       column = x
  ;       *topo\faces\SetValue(x+z*u*5,0)
  ;       *topo\faces\SetValue(x+z*u*5+1,1)
  ;       *topo\faces\SetValue(x*v+z*u*5+1,u+1)
  ;       *topo\faces\SetValue(x*v+z*u*5,u)
  ;     Next
  ;   Next
    
    For x=0 To nbp-1
      column = x/(u-1)*u
      row = x%(u-1)
      CArray::SetValueL(*topo\faces,offset+3,column+row)
      CArray::SetValueL(*topo\faces,offset+2,column+row+1)
      CArray::SetValueL(*topo\faces,offset+1,column+row+u+1)
      CArray::SetValueL(*topo\faces,offset+0,column+row+u)
      CArray::SetValueL(*topo\faces,offset+4,-2)
      offset + 5
    Next x
    *topo\dirty = #True
  EndProcedure
  
  Procedure GridUVWs(*mesh.PolymeshGeometry_t,radius.f,u.i,v.i)
    
  EndProcedure
  
  ;--------------------------------------------------------------
  ; Random Grid(Holes)Shape
  ;--------------------------------------------------------------
  Procedure RandomGrid(*mesh.PolymeshGeometry_t,width.f,height.f,cellsize.f,probability.f=0.5)
    Protected nbx.i, nby.i
    Protected spx.f,spy.f
    Protected nbcells.i
    Define.v3f32 a,b,c,d
    
    nbx = Round(width / cellsize,#PB_Round_Down)
    nby = Round(height / cellsize,#PB_Round_Down)
    
    nbcells = nbx*nby
    spx = width/nbx
    spy = height/nby
    
    Protected *topo.Topology_t = Topology::New()
    Define x,y
    Define r.f
    Define counter
    For x=0 To nbx-1
      For y=0 To nby-1
        r = Random(1000)*0.001
        If r<probability
          ; Add Vertices
          Vector3::Set(@a,x*spx-width*0.5,0,y*spy-height*0.5)
          Vector3::Set(@b,(x+1)*spx-width*0.5,0,y*spy-height*0.5)
          Vector3::Set(@c,x*spx-width*0.5,0,(y+1)*spy-height*0.5)
          Vector3::Set(@d,(x+1)*spx-width*0.5,0,(y+1)*spy-height*0.5)
          CArray::Append(*topo\vertices,a)
          CArray::Append(*topo\vertices,b)
          CArray::Append(*topo\vertices,c)
          CArray::Append(*topo\vertices,d)
  
          
          ;Add Faces
          CArray::AppendL(*topo\faces,counter)
          CArray::AppendL(*topo\faces,counter+1)
          CArray::AppendL(*topo\faces,counter+3)
          CArray::AppendL(*topo\faces,counter+2)
          CArray::AppendL(*topo\faces,-2)
          counter + 4
  
        EndIf
        
      Next y
    Next x
    
    Set2(*mesh,*topo) 
    Topology::Delete(*topo)
  EndProcedure
  
  ;--------------------------------------------------------------
  ; Cylinder Shape
  ;--------------------------------------------------------------
  Procedure Cylinder(*geom.PolymeshGeometry_t,sizX.f=0.25,sizZ.f=1,u.i=8,v.i=4,w=1)
  ;   
  ;   *geom\nbpoints = u*v
  ;   *geom\nbedges = 0
  ;   *geom\nbpolygons = (u-1)*(v-1)
  ;   *geom\nbsamples = *geom\nbpolygons *4
  ;   
  ;   *geom\a_positions\SetCount(*geom\nbpoints)
  ;   *geom\a_normals\SetCount(*geom\nbsamples)
  ;   *geom\a_colors\SetCount(*geom\nbsamples)
  ;   
  ;   *geom\a_faceindices\SetCount(*geom\nbpolygons * 4)
  ;   *geom\a_facecount\SetCount(*geom\nbpolygons)
  ;   
  ;   Protected x,z
  ;   Define.f stepx, stepz
  ;   stepx = sizX*1/(u-1)
  ;   stepz = sizZ*1/(v-1)
  ;   
  ;   Protected pos.v3f32
  ;   For x=0 To u-1
  ;     For z=0 To v-1
  ;       Vector3_Set(@pos,-0.5*sizX+x*stepx,Random(4)-2,-0.5*sizZ+z*stepz)
  ;       *geom\a_positions\SetValue(x*u+z,@pos)
  ;     Next z
  ;   Next x
  ;   
  ;   Protected column, row
  ;   For x=0 To *geom\nbpolygons-1
  ;     column = x/(u-1)*u
  ;     row = x%(u-1)
  ;     *geom\a_faceindices\SetValue(x*4+3,column+row)
  ;     *geom\a_faceindices\SetValue(x*4+2,column+row+1)
  ;     *geom\a_faceindices\SetValue(x*4+1,column+row+u+1)
  ;     *geom\a_faceindices\SetValue(x*4+0,column+row+u)
  ;     *geom\a_facecount\SetValue(x,4)  
  ;   Next x
  ;   
  ;   OPolymeshGeometry_RecomputeTriangles(*geom)
  ;   OPolymeshGeometry_RecomputeNormals(*geom)
  EndProcedure
  
  ;--------------------------------------------------------------
  ; Cylinder Topology
  ;--------------------------------------------------------------
  Procedure CylinderTopology(*topo.Topology_t,radius.f,u.i=8,v.i=1,w.i=0,captop.b=#True,capbottom.b=#True)

    CArray::SetCount(*topo\vertices,0)
    CArray::SetCount(*topo\faces,0)
    
    Protected p.v3f32
    Protected c.v3f32
    Protected q.q4f32
    Protected s.f = 360 / u
    Protected t.f = 1/v
    Protected nbp = u* (v+1)
    Protected bc.v3f32
    Protected tc.v3f32
    Protected i,j
    Vector3::Set(@bc,0,-1,0)
    Vector3::Set(@tc,0,1,0)
    

    For i=0 To v
      
      Vector3::LinearInterpolate(@c,@bc,@tc,i*t)
      For j=0 To u-1
          
        Quaternion::SetFromAxisAngleValues(@q,0,1,0,Radian(j*s))
        Vector3::Set(@p,0,0,1)
        Vector3::MulByQuaternionInPlace(@p,@q)
        Vector3::AddInPlace(@p,@c)
        CArray::Append(*topo\vertices,p)
      Next
      
    Next
    
    
    Protected nbf = u*v
    Protected base.i
    Protected p1.l,p2.l,p3.l,p4.l
    For i=0 To v-1
      For j=0 To u-1
        If j <= u-2
          p1 = base+j+u
          p2 = base+(j+1)+u
          p3 = base+(j+1)
          p4 = base+j
        Else
          p1 = base+j+u
          p2 = base+u
          p3 = base
          p4 = base+j
        EndIf
        
        CArray::AppendL(*topo\faces,p1)
        CArray::AppendL(*topo\faces,p2)
        CArray::AppendL(*topo\faces,p3)
        CArray::AppendL(*topo\faces,p4)
        CArray::AppendL(*topo\faces,-2)
        
      Next j
      base + u
    Next i
    
    If captop
;       Vector3::SetFromOther(  
    EndIf
    
    *topo\dirty = #True
  
  EndProcedure
  
  ; Procedure OPolymeshGeometry_GridTopology(*topo.CTopology_t,radius.f,u.i,v.i)
  ;   u = Max(u,2)
  ;   v = Max(v,2)
  ;   
  ;   Protected nbp = (u-1)*(v-1)
  ;   Protected nbs = nbp *4
  ; 
  ;   *topo\vertices\SetCount(u*v)
  ;   *topo\faces\SetCount(nbp+nbs)
  ;   
  ;   Protected x,z
  ;   Define.f stepx, stepz
  ;   stepx = radius*1/(u-1)
  ;   stepz = radius*1/(v-1)
  ;   
  ;   Protected pos.v3f32
  ;   For x=0 To u-1
  ;     For z=0 To v-1
  ;       Vector3_Set(@pos,-0.5*radius+x*stepx,0,-0.5*radius+z*stepz)
  ;       *topo\vertices\SetValue(x*u+z,@pos)
  ;     Next z
  ;   Next x
  ;   
  ;   Protected column, row
  ;   Protected offset
  ;   For x=0 To nbp-1
  ;     column = x/(u-1)*u
  ;     row = x%(u-1)
  ;     *topo\faces\SetValue(offset+3,column+row)
  ;     *topo\faces\SetValue(offset+2,column+row+1)
  ;     *topo\faces\SetValue(offset+1,column+row+u+1)
  ;     *topo\faces\SetValue(offset+0,column+row+u)
  ;     *topo\faces\SetValue(offset+4,-2)
  ;     offset + 5
  ;   Next x
  ; EndProcedure
  
  ;--------------------------------------------------------------
  ; Disc Shape
  ;--------------------------------------------------------------
  Procedure Disc(*geom.PolymeshGeometry_t,radius.f=1.0,u.i=8,v.i=1)
  ;   
    *geom\nbpoints = u +1
    *geom\nbtriangles = u
    *geom\nbedges = 0
    *geom\nbpolygons = u
    *geom\nbsamples = *geom\nbpolygons *3
    
    CArray::SetCount(*geom\a_positions,*geom\nbpoints)
    CArray::SetCount(*geom\a_pointnormals,*geom\nbpoints)
    CArray::SetCount(*geom\a_normals,*geom\nbsamples)
    CArray::SetCount(*geom\a_colors,*geom\nbsamples)
    CArray::SetCount(*geom\a_uvws,*geom\nbsamples)
    CArray::SetCount(*geom\a_triangleindices,*geom\nbsamples)
    
    CArray::SetCount(*geom\a_faceindices,*geom\nbpolygons * 3)
    CArray::SetCount(*geom\a_facecount,*geom\nbpolygons)
    
    Protected x.v3f32
    Protected p.v3f32
    Vector3::Set(@p,0,0,1)
    Protected q.q4f32
    Protected i
    Protected incr.f = 1/u*360
    CArray::SetValue(*geom\a_positions,0,@x)
    For i=0 To u-1
      Quaternion::SetFromAxisAngleValues(@q,0,1,0,Radian(i*incr))
      Vector3::MulByQuaternion(@x,@p,@q)
      CArray::SetValue(*geom\a_positions,i+1,@x)
      CArray::SetValueL(*geom\a_faceindices,i*3,0)
      CArray::SetValueL(*geom\a_faceindices,i*3+1,i+1)
      CArray::SetValueL(*geom\a_faceindices,i*3+2,Mod(i+1,u)+1)
      CArray::SetValueL(*geom\a_facecount,i,3)
    Next 
    
    ; Update Geometry
    Protected color.c4f32
    RecomputeTriangles(*geom)
    RecomputeNormals(*geom,1)
    GetTopology(*geom)
   
    ;Color
  ;   Color4_Set(@color,1,Random(255)/255,Random(255)/255,Random(255)/255);
  ;   OPolymeshGeometry_SetColors(*geom,@color)
  ;   
  ;   UVWs
    
  ;   
  ;   Protected x,z
  ;   Define.f stepx, stepz
  ;   stepx = sizX*1/(u-1)
  ;   stepz = sizZ*1/(v-1)
  ;   
  ;   Protected pos.v3f32
  ;   For x=0 To u-1
  ;     For z=0 To v-1
  ;       Vector3_Set(@pos,-0.5*sizX+x*stepx,Random(4)-2,-0.5*sizZ+z*stepz)
  ;       *geom\a_positions\SetValue(x*u+z,@pos)
  ;     Next z
  ;   Next x
  ;   
  ;   Protected column, row
  ;   For x=0 To *geom\nbpolygons-1
  ;     column = x/(u-1)*u
  ;     row = x%(u-1)
  ;     *geom\a_faceindices\SetValue(x*4+3,column+row)
  ;     *geom\a_faceindices\SetValue(x*4+2,column+row+1)
  ;     *geom\a_faceindices\SetValue(x*4+1,column+row+u+1)
  ;     *geom\a_faceindices\SetValue(x*4+0,column+row+u)
  ;     *geom\a_facecount\SetValue(x,4)  
  ;   Next x
  ;   
  ;   OPolymeshGeometry_RecomputeTriangles(*geom)
  ;   OPolymeshGeometry_RecomputeNormals(*geom)
  EndProcedure
  
  Procedure DiscTopology(*topo.Topology_t,radius.f,u.i=8)
    *topo\dirty = #True
  EndProcedure
  
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.PolymeshGeometry_t)

    
    ;---[ Clean all geometry datas ]---------------------------------
    Clear(*Me)
  
    Topology::Delete(*Me\topo)
    
    CArray::Delete(*Me\a_uvws)
    CArray::Delete(*Me\a_colors)
    CArray::Delete(*Me\a_pointnormals)
    CArray::Delete(*Me\a_polygonnormals)
    CArray::Delete(*Me\a_tangents)
    CArray::Delete(*Me\a_normals)
    CArray::Delete(*Me\a_velocities)
    CArray::Delete(*Me\a_positions)
    CArray::Delete(*Me\a_edgeindices)
    CArray::Delete(*Me\a_triangleindices)
    CArray::Delete(*Me\a_facecount)
    CArray::Delete(*Me\a_faceindices)
    CArray::Delete(*Me\a_vertexpolygoncount)
    CArray::Delete(*Me\a_vertexpolygonindices)
    CArray::Delete(*Me\a_polygonareas)
    CArray::Delete(*Me\a_triangleareas)
;     CArray::Delete(*Me\a_polygons)
;     CArray::Delete(*Me\a_edges)
;     CArray::Delete(*Me\a_vertices)
;     CArray::Delete(*Me\a_samples)
    ;---[ Deallocate Memory ]----------------------------------------
    ClearStructure(*Me,PolymeshGeometry_t)
    FreeMemory(*Me)
  EndProcedure
  
  ;---------------------------------------------
  ;  To Shape
  ;---------------------------------------------
  Procedure ToShape(*Me.PolymeshGeometry_t,*shape.Shape::Shape_t)
;     *shape\nbp = *Me\nbpoints
;     *shape\nbt = *Me\nbtriangles
;     
;     CArray::Copy(*shape\positions,*Me\a_positions)
;     CArray::Copy(*shape\normals,*Me\a_pointnormals)
;     CArray::SetCount(*shape\colors,*shape\nbt)
;     Shape::SetUVWs(*shape)
;     CArray::Copy(*shape\indices,*Me\a_triangleindices)
;     CArray::Copy(*shape\uvws,*Me\a_uvws)
;     CArray::Copy(*Shape\colors,*Me\a_colors)
    
    *shape\nbp = *Me\nbtriangles*3
    *shape\nbt = *Me\nbtriangles
    CArray::SetCount(*shape\positions,*shape\nbp)
    
    Define i
    Define *v.v3f32
    For i=0 To *shape\nbp-1
      *v = CArray::GetValue(*Me\a_positions,CArray::GetValueL(*Me\a_triangleindices,i))
      CArray::SetValue(*shape\positions,i,*v)
    Next

    CArray::Copy(*shape\normals,*Me\a_normals)
    CArray::Copy(*shape\uvws,*Me\a_uvws)
    CArray::Copy(*shape\indices,*Me\a_triangleindices)
    
    Protected c.v3f32
    Protected *c.c4f32
    CArray::SetCount(*shape\colors,*shape\nbp)
    For i=0 To *shape\nbp-1
      *c = CArray::GetValue(*Me\a_colors,i)
      Vector3::Set(@c,*c\r,*c\g,*c\b)
      CArray::SetValue(*shape\colors,i,@c)
    Next
    *shape\indexed = #False
  EndProcedure
  
    
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(*parent,shape.i=Shape::#Shape_Cube)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.PolymeshGeometry_t = AllocateMemory(SizeOf(PolymeshGeometry_t))
    InitializeStructure(*Me,PolymeshGeometry_t)
    *Me\parent = *parent
    *Me\a_vertices = CArray::newCArrayPtr()
    *Me\a_edges = CArray::newCArrayPtr()
    *Me\a_polygons = CArray::newCArrayPtr()
    *Me\a_samples = CArray::newCArrayPtr()
    *Me\a_faceindices = CArray::newCArrayLong()
    *Me\a_facecount = CArray::newCArrayLong()
    *Me\a_triangleindices = CArray::newCArrayLong()
    *Me\a_edgeindices = CArray::newCArrayLong()
    *Me\a_positions = CArray::newCArrayV3F32()
    *Me\a_velocities = CArray::newCArrayV3F32()
    *Me\a_normals = CArray::newCArrayV3F32()
    *Me\a_tangents = CArray::newCArrayV3F32()
    *Me\a_pointnormals = CArray::newCArrayV3F32()
    *Me\a_polygonnormals = CArray::newCArrayV3F32()
    *Me\a_uvws = CArray::newCArrayV3F32()
    *Me\a_colors = CArray::newCArrayC4F32()
    *Me\a_vertexpolygoncount = CArray::newCArrayLong()
    *Me\a_vertexpolygonindices = CArray::newCArrayLong()
    *Me\a_polygonareas = CArray::newCArrayFloat()
    *Me\a_triangleareas = CArray::newCArrayFloat()
    
  ;   *Me\base = newCPolymeshTopology()
    *Me\topo  = Topology::New()
    *Me\base = Topology::New()
    *Me\shapetype = shape
    
    If shape = Shape::#SHAPE_NONE
      *Me\nbpoints = 0
      *Me\nbindices = 0
      *Me\nbsamples = 0
      *Me\nbtriangles = 0
      *Me\nbpolygons = 0
    Else

      ; ----[ Initial Topology ]--------------------------------------------------
    
      Select shape
        Case Shape::#SHAPE_GRID
          GridTopology(*Me\base,10,10,10)
        Case Shape::#SHAPE_CYLINDER
          CylinderTopology(*Me\base,1,6,1,10)
        Case Shape::#SHAPE_CUBE
          CubeTopology(*Me\base,1,10,10,10)
        Case Shape::#SHAPE_SPHERE
          SphereTopology(*Me\base,0.5,12,8)
        Case Shape::#SHAPE_GRID
          GridTopology(*Me\base,1,10,10)
        Case Shape::#SHAPE_TORUS
          TorusTopology(*Me\base)
        Case Shape::#SHAPE_BUNNY
          BunnyTopology(*Me\base)
        Case Shape::#SHAPE_TEAPOT
          TeapotTopology(*Me\base)
      EndSelect
      
      Set2(*Me,*Me\base)
    EndIf

    ProcedureReturn *Me
  EndProcedure
  ;}
  
  
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 1039
; FirstLine = 1023
; Folding = ----fw--v--
; EnableXP
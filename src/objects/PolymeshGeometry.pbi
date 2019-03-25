
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
  Declare GetUVWSFromPosition(*geom.PolymeshGeometry_t,normalize.b=#False)
  Declare GetUVWSFromExtrusion(*geom.PolymeshGeometry_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32)
  Declare GetUVWSPerPolygons(*geom.PolymeshGeometry_t)
  Declare ComputeNormals(*mesh.PolymeshGeometry_t,smooth.f=0.5)
  Declare ComputeTangents(*mesh.PolymeshGeometry_t)
  Declare InvertNormals(*mesh.PolymeshGeometry_t)
  Declare ComputeTriangles(*mesh.PolymeshGeometry_t)
  Declare ComputeHalfEdges(*mesh.PolymeshGeometry_t)
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
  Declare RandomColorByIsland(*mesh.PolymeshGeometry_t)
  Declare Extrusion(*geom.PolymeshGeometry_t,*points.CArray::CArrayM4F32,*section.CArray::CArrayV3F32)
  Declare GetPointsPosition(*mesh.PolymeshGeometry_t,*io_pos.CArray::CArrayV3F32)
  Declare GetPointsNormal(*mesh.PolymeshGeometry_t,*io_norm.CArray::CArrayV3F32)
  Declare SetPointsPosition(*mesh.PolymeshGeometry_t,*io_pos.CArray::CArrayV3F32)
  Declare SetPointsNormal(*mesh.PolymeshGeometry_t,*io_pos.CArray::CArrayV3F32)
  Declare ToShape(*Me.PolymeshGeometry_t,*shape.Shape::Shape_t)
  Declare BunnyTopology(*Me.PolymeshGeometry_t)
  Declare TeapotTopology(*Me.PolymeshGeometry_t)
  Declare TorusTopology(*Me.PolymeshGeometry_t)
  Declare CubeTopology(*Me.PolymeshGeometry_t,radius.f=1,u.i=1,v.i=1,w.i=1)
  Declare CylinderTopology(*Me.PolymeshGeometry_t,radius.f,u.i=8,v.i=1,w.i=0,captop.b=#True,capbottom.b=#True)
  Declare DiscTopology(*Me.PolymeshGeometry_t,radius.f,u.i=8)
  Declare SphereTopology(*Me.PolymeshGeometry_t,radius.f=1,lats.i=8,longs.i=8)
  Declare GridTopology(*Me.PolymeshGeometry_t,radius.f=1,u.i=12,v.i=12)
  Declare InitSampling(*mesh.PolymeshGeometry_t)
  Declare Sample(*mesh.PolymeshGeometry_t, *t.Transform::Transform_t, numSamples, *io.CArray::CArrayV3F32)
  Declare ExtrudePolygons(*mesh.PolymeshGeometry_t, *polygons.CArray::CArrayLong, distance.f, separate.b)
  Declare.b GetClosestLocation(*mesh.PolymeshGeometry_t, *p.v3f32, *cp.Geometry::Location_t, *distance, maxDistance.f=#F32_MAX)
  Declare ComputeIslands(*mesh.PolymeshGeometry_t)
  Declare GetVertexNeighbors(*mesh.Geometry::PolymeshGeometry_t, index.i, *neighbors.CArray::CArrayLong)
  Declare GrowVertexNeighbors(*mesh.Geometry::PolymeshGeometry_t, *vertices.CArray::CArrayLong)
  Declare ShrinkVertexNeighbors(*mesh.Geometry::PolymeshGeometry_t, *vertices.CArray::CArrayLong)
EndDeclareModule

;========================================================================================
; PolymeshGeometry Module Implementation
;========================================================================================
Module PolymeshGeometry
  UseModule Geometry
  UseModule Math
  
  ; ----------------------------------------------------------------------------
  ;  Get UVWs from Position
  ; ----------------------------------------------------------------------------
  Procedure GetUVWSFromPosition(*geom.PolymeshGeometry_t,normalize.b=#False)
    
    Protected cnt=0
    Define.f h,w
    Protected a,b,c,i
    
    Define.v3f32 bmin,bmax
    If normalize
    
      Vector3::Sub(bmin, *geom\bbox\origin, *geom\bbox\extend)
      Vector3::Add(bmax, *geom\bbox\origin, *geom\bbox\extend)
      ; Normalized UVs
      Define.v3f32 va,vb,vc,offset,scl,delta
      
      Vector3::Sub(delta,bmax,bmin)
      
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
         
        CArray::SetValuePtr(*geom\a_uvws,cnt,va)
        CArray::SetValuePtr(*geom\a_uvws,cnt+1,vb)
        CArray::SetValuePtr(*geom\a_uvws,cnt+2,vc) 
        cnt+3
      Next i
      
    Else
    
      ;UVs
       For i=0 To CArray::GetCount(*geom\a_triangleindices)/3-1
        a = CArray::GetValueL(*geom\a_triangleindices,i*3)
        b = CArray::GetValueL(*geom\a_triangleindices,i*3+1)
        c = CArray::GetValueL(*geom\a_triangleindices,i*3+2)
    
        CArray::SetValue(*geom\a_uvws,cnt,CArray::GetValue(*geom\a_positions,a))
        CArray::SetValue(*geom\a_uvws,cnt+1,CArray::GetValue(*geom\a_positions,b))
        CArray::SetValue(*geom\a_uvws,cnt+2,CArray::GetValue(*geom\a_positions,c)) 
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
      
        Vector3::Set(uvws,(u)*incru,0,(v)*incrv)
        CArray::SetValue(*geom\a_uvws,i,uvws)
        Vector3::Set(uvws,(u)*incru,0,(v+1)*incrv)
        CArray::SetValue(*geom\a_uvws,i+1,uvws)
        Vector3::Set(uvws,(u+1)*incru,0,(v)*incrv)
        CArray::SetValue(*geom\a_uvws,i+2,uvws) 
        
        Vector3::Set(uvws,(u)*incru,0,(v+1)*incrv)
        CArray::SetValue(*geom\a_uvws,i+3,uvws)
        Vector3::Set(uvws,(u+1)*incru,0,(v+1)*incrv)
        CArray::SetValue(*geom\a_uvws,i+4,uvws)
        Vector3::Set(uvws,(u+1)*incru,0,(v)*incrv)
        CArray::SetValue(*geom\a_uvws,i+5,uvws) 
  
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
  ;  Compute Normals
  ; ----------------------------------------------------------------------------
  Procedure ComputeNormals(*mesh.PolymeshGeometry_t,smooth.f=0.5)
    If Not *mesh\nbpoints Or Not *mesh\nbtriangles : ProcedureReturn : EndIf
    
    Protected i,j,base
    Protected ab.v3f32, ac.v3f32,n.v3f32, norm.v3f32
    Protected *n.v3f32
  
    Protected *n1.v3f32
    Protected cnt = 0
  
    Vector3::Set(n,0,0,0)
    CArray::SetCount(*mesh\a_polygonnormals, *mesh\nbpolygons)
    
    ; First Triangle Normals
    Define.v3f32 *a, *b, *c
    Define nbv, nbt, nbp

    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define *positions = *mesh\a_positions\data
      Define *indices = *mesh\a_triangleindices\data
      Define *normals = *mesh\a_normals\data
      Define *polygonnormals = *mesh\a_polygonnormals\data
      Define *pointnormals = *mesh\a_pointnormals\data
      Define numPoints = *mesh\nbpoints
      Define numTris = *mesh\nbtriangles
      Define numPolygons = *mesh\nbpolygons
      Define numSamples = *mesh\nbsamples
      Define *facecount = *mesh\a_facecount\data
      Define *faceindices = *mesh\a_faceindices\data
      Define *vertexpolygoncount = *mesh\a_vertexpolygoncount\data
      Define *vertexpolygonindices = *mesh\a_vertexpolygonindices\data
      
      ! mov rdx, [p.p_indices]              ; move indices to edx register
      ! mov rsi, [p.p_positions]            ; move positions to rsi register
      ! mov rdi, [p.p_normals]              ; move normals to rdi register
      
      ! mov r9, 16                          ; move item size to eax register
      ! mov rcx, [p.v_numTris]              ; move num triangles to edx register

      ! loop_compute_triangle_normal:
      !   mov eax, [rdx]             ; get value for desired point A
      !   imul rax, r9                      ; compute offset in position array
      !   mov r10, rsi                      ; load positions array
      !   add r10, rax                      ; offset to desired item
      !   movaps xmm2, [r10]                ; load point A to xmm0
      !   movaps xmm3, xmm2                 ; copy point A to xmm1
      !   add rdx, 4                        ; offset next item
      
      !   mov eax, [rdx]             ; get value for desired point B
      !   imul rax, r9                      ; compute offset in position array
      !   mov r10, rsi
      !   add r10, rax                      ; offset to desired item
      !   movaps xmm0, [r10]                ; load point B to xmm2
      !   add rdx, 4                        ; offset next item
      
      !   mov eax, [rdx]                    ; get value for desired point B
      !   imul rax, r9                      ; compute offset in position array
      !   mov r10, rsi
      !   add r10, rax                      ; offset to desired item
      !   movaps xmm1, [r10]                ; load point C to xmm3
      !   add rdx, 4                        ; offset next item
      
      !   subps xmm0, xmm2                  ; compute vector AB
      !   subps xmm1, xmm3                  ; compute vector AC
      
      ; ---------------------------------------------------------------------------------
      ; cross product
      ; ---------------------------------------------------------------------------------
      !   movaps xmm2,xmm0                  ; copy vec AB to xmm2
      !   movaps xmm3,xmm1                  ; copy vec AC to xmm3
        
      !   shufps xmm2,xmm2,00001001b        ; exchange 2 and 3 element (a)
      !   shufps xmm3,xmm3,00010010b        ; exchange 1 and 2 element (b)
      !   mulps  xmm2,xmm3
               
      !   shufps xmm0,xmm0,00010010b        ; exchange 1 and 2 element (a)
      !   shufps xmm1,xmm1,00001001b        ; exchange 2 and 3 element (b)
      !   mulps  xmm0,xmm1
              
      !   subps  xmm0,xmm2                  ; cross product triangle normal
      
      ; ---------------------------------------------------------------------------------
      ; normalize in place
      ; ---------------------------------------------------------------------------------
      !   movaps xmm6, xmm0                 ; copy normal in xmm6
      !   mulps xmm0, xmm0                  ; square it
      !   movaps xmm7, xmm0                 ; copy in xmm7
      !   shufps xmm7, xmm7, 01001110b      ; shuffle component z w x y
      !   addps xmm0, xmm7                  ; packed addition
      !   movaps xmm7, xmm0                 ; copy in xmm7  
      !   shufps xmm7, xmm7, 00010001b      ; shuffle componennt y x y x
      !   addps xmm0, xmm7                  ; packed addition
      !   rsqrtps xmm0, xmm0                ; reciproqual root square (length)
      !   mulps xmm0, xmm6                  ; multiply by intila vector
      
      !   jmp set_triangle_normals
      
      ; ---------------------------------------------------------------------------------
      ; next triangle
      ; ---------------------------------------------------------------------------------
      ! next_triangle:
      !   dec rcx                           ; decrement triangle counter
      !   jg loop_compute_triangle_normal   ; loop next triangle
      ! jmp init_polygon_normals
      
      ; ---------------------------------------------------------------------------------
      ; set triangle normals
      ; ---------------------------------------------------------------------------------
      ! set_triangle_normals:
      !   mov r11, 3                        ; reset triangle vertex counter
      !   loop_set_triangle_normals:
      !     movaps [rdi], xmm0              ; move memory
      !     add rdi, r9                     ; offset in normals array
      !     dec r11                         ; decrement vertex counter
      !     jg loop_set_triangle_normals    ; loop triangle vertices
      !   jmp next_triangle                 ; jump next triangle
      
      ; ---------------------------------------------------------------------------------
      ; set polygon normals
      ; ---------------------------------------------------------------------------------
      ! init_polygon_normals:
      !   mov rcx, [p.v_numPolygons]
      !   mov rdx, [p.p_facecount]
      !   mov rsi, [p.p_normals] 
      !   mov rdi, [p.p_polygonnormals] 
      
      ! set_polygon_normals:
      !   mov eax, [rdx]                          ; get num vertices for this polygon
      !   add rdx, 4                              ; increment face count for next polygon
      !   mov r11, -2                             ; load -2 value in r11
      !   add r11, rax                            ; compute num tris (num vertices - 2)
      !   xorps xmm0, xmm0                        ; reset xmm0
      
      ! loop_polygon_normals:
      !   movaps xmm1, [rsi]                      ; load triangle normal
      !   addps xmm0, xmm1                        ; accumulate in xmm0
      !   add rsi, 48                             ; next triangle normal
      !   dec r11                                 ; decrement tri counter
      !   jg loop_polygon_normals                 ; loop next triangle
      
      ; ---------------------------------------------------------------------------------
      ; normalize in place
      ; ---------------------------------------------------------------------------------
      ! movaps xmm6, xmm0                         ; copy normal in xmm6
      ! mulps xmm0, xmm0                          ; square it
      ! movaps xmm7, xmm0                         ; copy in xmm7
      ! shufps xmm7, xmm7, 01001110b              ; shuffle component z w x y
      ! addps xmm0, xmm7                          ; packed addition
      ! movaps xmm7, xmm0                         ; copy in xmm7  
      ! shufps xmm7, xmm7, 00010001b              ; shuffle componennt y x y x
      ! addps xmm0, xmm7                          ; packed addition
      ! rsqrtps xmm0, xmm0                        ; reciproqual root square (length)
      ! mulps xmm0, xmm6                          ; multiply by intila vector
       
      ; ---------------------------------------------------------------------------------
      ; set polygon normal
      ; ---------------------------------------------------------------------------------
      ! movaps [rdi], xmm0                        ; send back polygon normal to memory
      ! add rdi, 16                               ; next polygon normal
      
      ! dec rcx                                   ; decrement polygon counter
      ! jg set_polygon_normals                    ; loop per polygon
      
      ; ---------------------------------------------------------------------------------
      ; average point normal
      ; ---------------------------------------------------------------------------------
      ! init_average_point_normals:
      !   mov rcx, [p.v_numPoints]
      !   mov rdx, [p.p_vertexpolygoncount]
      !   mov rax, [p.p_vertexpolygonindices]
      !   mov rsi, [p.p_polygonnormals] 
      !   mov rdi, [p.p_pointnormals] 
      
      ! set_average_point_normals:
      !   mov r11d, [rdx]                         ; get num polygons for this vertex
      !   add rdx, 4                              ; increment vertex polygon count for next vertex
      !   xorps xmm0, xmm0                        ; reset xmm0
      
      ! loop_average_point_normals:
      !   mov r12d, [rax]                         ; load polygon index
      !   add rax, 4
      !   imul r12, 16
      !   movaps xmm1, [rsi + r12]                ; load polygon normal
      !   addps xmm0, xmm1                        ; accumulate in xmm0
      !   dec r11d                                ; decrement polygon counter
      !   jg loop_average_point_normals           ; loop next polygon
      
      ; ---------------------------------------------------------------------------------
      ; normalize in place
      ; ---------------------------------------------------------------------------------
      ! movaps xmm6, xmm0                 ; copy normal in xmm6
      ! mulps xmm0, xmm0                  ; square it
      ! movaps xmm7, xmm0                 ; copy in xmm7
      ! shufps xmm7, xmm7, 01001110b      ; shuffle component z w x y
      ! addps xmm0, xmm7                  ; packed addition
      ! movaps xmm7, xmm0                 ; copy in xmm7  
      ! shufps xmm7, xmm7, 00010001b      ; shuffle componennt y x y x
      ! addps xmm0, xmm7                  ; packed addition
      ! rsqrtps xmm0, xmm0                ; reciproqual root square (inverse length)
      ! mulps xmm0, xmm6                  ; multiply by intila vector
      
      ; ---------------------------------------------------------------------------------
      ; set point normal
      ; ---------------------------------------------------------------------------------
      ! movaps [rdi], xmm0
      ! add rdi, 16
      
      ! dec rcx
      ! jg set_average_point_normals
      
      ; ---------------------------------------------------------------------------------
      ; display normal
      ; ---------------------------------------------------------------------------------
      ! init_display_normals:
      !   mov rcx, [p.v_numSamples]
      !   mov rax, [p.p_indices]
      !   mov rsi, [p.p_pointnormals] 
      !   mov rdi, [p.p_normals] 
      
      ! loop_display_normals:
      !   mov r12d, [rax]                         ; load vertex index
      !   add rax, 4
      !   imul r12, 16
      !   movaps xmm0, [rsi + r12]                ; load point normal
      !   movaps [rdi], xmm0
      !   add rdi, 16
      
      !   dec rcx
      !   jg loop_display_normals

    CompilerElse
      ; first compute triangle normals
      For i=0 To *mesh\nbtriangles-1
        *a = CArray::GetValue(*mesh\a_positions,CArray::GetValueL(*mesh\a_triangleindices,(i*3)))
        *b = CArray::GetValue(*mesh\a_positions,CArray::GetValueL(*mesh\a_triangleindices,(i*3+1)))
        *c = CArray::GetValue(*mesh\a_positions,CArray::GetValueL(*mesh\a_triangleindices,(i*3+2)))
        
        Vector3::Sub(ab,*a,*b)
        Vector3::Sub(ac,*a,*c)
        
        Vector3::Cross(norm,ac,ab)
        Vector3::NormalizeInPlace(norm)
        CArray::SetValue(*mesh\a_normals,cnt,norm)
        CArray::SetValue(*mesh\a_normals,cnt+1,norm)
        CArray::SetValue(*mesh\a_normals,cnt+2,norm)
  
        cnt+3
      Next i
      
      ; then polygons normals
      Define *n.v3f32
      CArray::SetCount(*mesh\a_polygonnormals, *mesh\nbpolygons)
      For i=0 To*mesh\nbpolygons-1
        nbv = CArray::GetvalueL(*mesh\a_facecount, i)
        nbt = nbv-2
        Vector3::Set(n, 0,0,0)
        For j=0 To nbt-1
          *n = CArray::GetValue(*mesh\a_normals, base+j*3)
          Vector3::AddInPlace(n, *n)
        Next
        Vector3::NormalizeInPlace(n)
        CArray::SetValue(*mesh\a_polygonnormals, i, n)
        base+nbt*3
      Next
      
      ; average point normals
      base = 0
      For i=0 To *mesh\nbpoints-1
        nbp = CArray::GetValueL(*mesh\a_vertexpolygoncount, i)
        Vector3::Set(n, 0,0,0)
        For j=0 To nbp-1
          index = CArray::GetValueL(*mesh\a_vertexpolygonindices, base+j)
          *n = CArray::GetValue(*mesh\a_polygonnormals, index)
          Vector3::AddInPlace(n, *n)
        Next
        Vector3::ScaleInPlace(n, 1/nbp)
        CArray::SetValue(*mesh\a_pointnormals, i, n)
        base + nbp
      Next
      
      ; display normals ( per samples )
      For i=0 To *mesh\nbsamples-1
        *n = CArray::GetValue(*mesh\a_pointnormals, CArray::GetValueL(*mesh\a_triangleindices, i))
        CArray::SetValue(*mesh\a_normals, i, *n)
      Next

    CompilerEndIf


  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Compute Tangents
  ; ----------------------------------------------------------------------------
  Procedure ComputeTangents(*mesh.PolymeshGeometry_t)
    Protected i,a,b,c
    Protected ab.v3f32, ac.v3f32,t.v3f32, tan.v3f32
    Protected tab.v3f32,tac.v3f32
    Define.v3f32 *t1,*t2,*t3
    Protected *n.v3f32
  
    Protected *n1.v3f32
    Protected cnt = 0
    Protected r.f
    
    ; reset tangent
    FillMemory(CArray::GetItemSize(*mesh\a_tangents) * CArray::GetCount(*mesh\a_tangents), 0)
    
    ; //	sum tangents per-triangle:
    ; First Triangle Normals
    Define.v3f32 *a, *b, *c
    Define.v3f32 *u, *v, *w
    For i=0 To *mesh\nbtriangles-1
      a = CArray::GetValueL(*mesh\a_triangleindices,i*3)
      b = CArray::GetValueL(*mesh\a_triangleindices,i*3+1)
      c = CArray::GetValueL(*mesh\a_triangleindices,i*3+2)
      
      *a = CArray::GetValue(*mesh\a_positions,a)
      *b = CArray::GetValue(*mesh\a_positions,b)
      *c = CArray::GetValue(*mesh\a_positions,c)
      
      Vector3::Sub(ab,*a,*b)
      Vector3::Sub(ac,*a, *c)
      
      *u = CArray::GetValue(*mesh\a_uvws,i*3)
      *v = CArray::GetValue(*mesh\a_uvws,i*3+1)
      *w = CArray::GetValue(*mesh\a_uvws,i*3+2)
      Vector3::Sub(tab,*v,*u)
      Vector3::Sub(tac,*w,*u)
      
      r = 1;/(tab\x*tac\y - tab\y * tac\x)
      Vector3::Set(tan,(tac\y*ab\x - tab\y * ac\x)*r,(tac\y*ab\y - tab\y * ac\y)*r,(tac\y*ab\z - tab\y * ac\z)*r)
      
      *t1 = CArray::GetValue(*mesh\a_tangents,i*3)
      Vector3::AddInPlace(*t1,tan)
      
      *t2 = CArray::GetValue(*mesh\a_tangents,i*3+1)
      Vector3::AddInPlace(*t2,tan)
      
      *t3 = CArray::GetValue(*mesh\a_tangents,i*3+2)
      Vector3::AddInPlace(*t3,tan)

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
  ;  Compute Triangles
  ; ----------------------------------------------------------------------------
  Procedure ComputeTriangles(*mesh.PolymeshGeometry_t)
    ; Rebuild triangle Data
    ;-----------------------------------
    Protected x,y,z, nbv, nbt
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
  ;  Implementation
  ; ----------------------------------------------------------------------------
  Procedure Clear(*mesh.PolymeshGeometry_t)

    Protected i
    Protected *vertex.Vertex_t
    
    CArray::SetCount(*mesh\a_edgeindices,0)
    CArray::SetCount(*mesh\a_colors,0)
    CArray::SetCount(*mesh\a_normals,0)
    CArray::SetCount(*mesh\a_tangents,0)
    CArray::SetCount(*mesh\a_positions,0)
    CArray::SetCount(*mesh\a_velocities,0)
    CArray::SetCount(*mesh\a_pointnormals,0)
    CArray::SetCount(*mesh\a_polygonnormals,0)
    CArray::SetCount(*mesh\a_velocities,0)
    CArray::SetCount(*mesh\a_triangleindices,0)
    CArray::SetCount(*mesh\a_uvws,0)
    CArray::SetCount(*mesh\a_pointnormals,0)
    CArray::SetCount(*mesh\a_facecount,0)
    CArray::SetCount(*mesh\a_faceindices,0)
    CArray::SetCount(*mesh\a_vertexpolygoncount,0)
    CArray::SetCount(*mesh\a_vertexpolygonindices,0)
    CArray::SetCount(*mesh\a_polygonareas,0)
    CArray::SetCount(*mesh\a_triangleareas,0)
    CArray::SetCount(*mesh\a_islands, 0)
    CArray::SetCount(*mesh\a_vertexhalfedge, 0)
  
  EndProcedure
  
 
  ;---------------------------------------------------------
  ; Set 2 (From Topo Data Block)
  ;---------------------------------------------------------
  Procedure Set2(*mesh.PolymeshGeometry_t,*topo.Topology_t)
    
    ; Clear Old Memory
    Clear(*mesh)
    If *topo <> *mesh\topo
      Topology::Copy(*mesh\topo, *topo)
    EndIf
    
    If Not CArray::GetCount(*topo\vertices) : ProcedureReturn : EndIf

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
    
    If CArray::GetCount(*topo\vertices) :
      CopyMemory(CArray::GetPtr(*topo\vertices,0),
                 CArray::GetPtr(*mesh\a_positions,0),
                 nbp* CArray::GetItemSize(*topo\vertices))
    EndIf
   
    Protected vid.l
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
    *mesh\nbedges = 0
    Protected Dim vertexPolygonIndices.VertexPolygonIndices_t(*mesh\nbpoints)
    Define totalVertexPolygonIndices = 0
    Define numVertexPolygonIndices
    
    CArray::SetCount(*mesh\a_vertexpolygoncount, *mesh\nbpoints)
    CArray::FillL(*mesh\a_vertexpolygoncount, 0)
    
    For i=0 To CArray::GetCount(*topo\faces)-1
      vid = CArray::GetValueL(*topo\faces,i)
      If  vid = -2
        CArray::SetValueL(*mesh\a_facecount,nbf,counter)
        nbf+1
        counter = 0
      Else
        numVertexPolygonIndices = ArraySize(vertexPolygonIndices(vid)\polygons())
        ReDim vertexPolygonIndices(vid)\polygons(numVertexPolygonIndices+1)
        vertexPolygonIndices(vid)\polygons(numVertexPolygonIndices) = nbf
        totalVertexPolygonIndices + 1
        CArray::SetValueL(*mesh\a_faceindices,nbi,vid)
        nbi+1
        counter+1
        *mesh\nbedges + 1
      EndIf
    Next i
    
    *mesh\nbpolygons = CArray::GetCount(*mesh\a_facecount)
    CArray::SetCount(*mesh\a_vertexpolygonindices, totalVertexPolygonIndices)
    
    base = 0
    For i=0 To *mesh\nbpoints-1
      nbp = ArraySize(vertexPolygonIndices(i)\polygons())
      CArray::SetValueL(*mesh\a_vertexpolygoncount, i, nbp)
      For j=0 To nbp-1
        CArray::SetValueL(*mesh\a_vertexpolygonindices, base+j, vertexPolygonIndices(i)\polygons(j)) 
      Next
      base + nbp
      FreeArray(vertexPolygonIndices(i)\polygons())
    Next
    FreeArray(vertexPolygonIndices())
    
    
    ; Compute Bounding Box
    Geometry::ComputeBoundingBox(*mesh)
    
    ; Compute Polymesh datas
    ComputeTriangles(*mesh)
    
    ; GetDualGraph(*mesh)
    ComputeNormals(*mesh,1)

    ; UVs
;     GetUVWSFromPosition(*mesh,#True)
    
    ; Tangents
;     ComputeTangents(*mesh)
    
    ;Color
    Color::Set(color,0.33,0.33,0.33,1.0)
    SetColors(*mesh,color)
    
    
    
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
      ComputeNormals(*geom)
      *geom\dirty = #True
    EndIf 

  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Point Position
  ;---------------------------------------------------------
  Procedure SetPointsPosition(*mesh.PolymeshGeometry_t,*v.CArray::CArrayV3F32)
    Protected nbp = *mesh\nbpoints
    
    ; ---[ Check Nb Points ]--------------------------------
    If CArray::GetCount(*v) = nbp And nbp > 0
      CArray::Copy(*mesh\a_positions, *v)
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
      CArray::Copy(*mesh\a_normals,*v)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Point Color
  ;---------------------------------------------------------
  Procedure SetColors(*mesh.PolymeshGeometry_t,*color.c4f32= #Null)
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
    
    Color::Set(c,r,g,b,1)
    For i=0 To nbs-1
      CArray::SetValue(*mesh\a_colors,i,c)
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
      Color::Set(*color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01, 1.0)
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
    Color::Set(color,0.5,0.5,0.5,1.0)
    If *color <> #Null
      Color::Set(color,*color\r,*color\g,*color\b,*color\a)
    EndIf
    
    Protected tid = 0
    Protected nbt = 0
    *color = #Null
    For f=0 To CArray::GetCount(*mesh\a_facecount)-1
      nbv = CArray::GetValueL(*mesh\a_facecount,f)
      nbt = nbv-2
      If *color <> #Null
        Color::Set(color,*color\r,*color\g,*color\b,*color\a)
      EndIf
      Color::Randomize(color)
      For v=0 To nbt-1
        CArray::SetValue(*mesh\a_colors,tid+2,color)
        CArray::SetValue(*mesh\a_colors,tid+1,color)
        CArray::SetValue(*mesh\a_colors,tid,color)
        tid+3
      Next
     
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Random Color By Island
  ;---------------------------------------------------------
  Procedure RandomColorByIsland(*mesh.PolymeshGeometry_t)
    Protected f,nbv,v,i
    CArray::SetCount(*mesh\a_colors, *mesh\nbsamples)
    Protected *colors.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
    CArray::SetCount(*colors, *mesh\nbislands)
    Define *c.c4f32
    For i=0 To *mesh\nbislands-1
      *c = CArray::GetValue(*colors, i)
      Color::Randomize(*c)  
    Next
    
    Protected tid = 0
    Protected nbt = 0
    Protected vid, offset=0
    *color = #Null
    For f=0 To CArray::GetCount(*mesh\a_facecount)-1
      nbv = CArray::GetValueL(*mesh\a_facecount,f)
      nbt = nbv-2
      vid = CArray::GetValueL(*mesh\a_faceindices, offset)
      *color = CArray::GetValue(*colors, CArray::GetValueL(*mesh\a_islands, vid))
      For v=0 To nbt-1
        CArray::SetValue(*mesh\a_colors,tid+2,*color)
        CArray::SetValue(*mesh\a_colors,tid+1,*color)
        CArray::SetValue(*mesh\a_colors,tid,*color)
        tid+3
      Next
      offset + nbv
     
    Next
    CArray::Delete(*colors)
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

    Define i
    Define tri.Geometry::Triangle_t
    For i = 0 To *mesh\nbtriangles - 1
      tri\id = i
      tri\vertices[0] = CArray::GetValueL(*mesh\a_triangleindices, i*3)
      tri\vertices[1] = CArray::GetValueL(*mesh\a_triangleindices, i*3+1)
      tri\vertices[2] = CArray::GetValueL(*mesh\a_triangleindices, i*3+2)
      
      *a = CArray::GetValue(*mesh\a_positions, tri\vertices[0])
      *b = CArray::GetValue(*mesh\a_positions, tri\vertices[1])
      *c = CArray::GetValue(*mesh\a_positions, tri\vertices[2])
      Location::ClosestPoint(*loc, *a, *b, *c, *p, @minDistance)
;       Triangle::ClosestPoint(@tri, *mesh\a_positions, *pnt , *loc\p, @*loc\u, @*loc\v, @*loc\w)
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
    Protected *p.v3f32
    Vector3::Set(offset,0,0.02,0.01)
    For i = 0 To *mesh\nbpoints-1
      *p = CArray::GetValue(*pos,i)
      Vector3::Add(pos,*p,offset)
      CArray::SetValue(*pos,i,pos)
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
    Protected *a.v3f32, *b.v3f32, *c.v3f32
  
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
        *a = CArray::GetValue(*mesh\a_positions, a)
        *b = CArray::GetValue(*mesh\a_positions, b)
        *c = CArray::GetValue(*mesh\a_positions, c)
        Vector3::Sub(ab, *b, *a)
        Vector3::Sub(ac, *c, *a)
        Vector3::Sub(bc, *c, *b)
        tArea = TriangleArea(Vector3::Length(ab), Vector3::Length(ac), Vector3::Length(bc))
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
  ; Get Next Open Edge
  ;---------------------------------------------------------
  Procedure GetNextOpenEdge(Map *openedges.Geometry::HalfEdge_t(), vid.i)
    ResetMap(*openedges())
    Define key.s
    While NextMapElement(*openedges())
      key = MapKey(*openedges())
      If vid = Val(StringField(key, 2, ","))
        Define *next.Geometry::HalfEdge_t = *openedges()
        DeleteMapElement(*openedges(), MapKey(*openedges()))
        ProcedureReturn *next
      EndIf
    Wend  
    ProcedureReturn #Null
  EndProcedure
  
  ;---------------------------------------------------------
  ; Compute Half Edges
  ;---------------------------------------------------------
  Procedure ComputeHalfEdges(*mesh.PolymeshGeometry_t)
    
    ReDim *mesh\a_halfedges(*mesh\nbedges * 2)
    Define i, j, nbv, offset = 0
    Define x, a, b
    Define key.s
    Define index.i = 0
    Define *h.Geometry::HalfEdge_t
    Define *o.Geometry::HalfEdge_t
    
    NewMap *openedges.Geometry::HalfEdge_t()
    Define numUniqueEdges = 0
    Dim uniqueEdges.Geometry::EdgeIndices_t(*mesh\nbedges)
    
    For i=0 To *mesh\nbpolygons - 1
      nbv = CArray::GetValueL(*mesh\a_facecount, i)

      For j=0 To nbv-1
        x = offset+j

        *h = *mesh\a_halfedges(x)
        a = CArray::GetValueL(*mesh\a_faceindices, offset + j)
        b = CArray::GetValueL(*mesh\a_faceindices, offset + ((j+1)%nbv))
        *h\vertex = a
        *h\face = i
        index + 1

        If FindMapElement(*openedges(), Str(b)+","+Str(a))
          *o = *openedges()
          *h\opposite_he = *o
          *o\opposite_he = *h
          DeleteMapElement(*openedges(), MapKey(*openedges()))
        Else
          uniqueEdges(numUniqueEdges)\vertices[0] = a
          uniqueEdges(numUniqueEdges)\vertices[1] = b
          numUniqueEdges + 1
          AddMapElement(*openedges(),Str(a)+","+Str(b))
          *openedges() = *h
        EndIf
       
        
        If j = 0
          *h\prev_he = *mesh\a_halfedges(offset+nbv-1)
        Else
          *h\prev_he = *mesh\a_halfedges(x-1)
        EndIf
        
        If j = nbv-1
          *h\next_he = *mesh\a_halfedges(offset)
        Else
          *h\next_he = *mesh\a_halfedges(x+1)
        EndIf

      Next
      offset+nbv
    Next
    
    ; unique edges
    *mesh\nbedges = numUniqueEdges
    CArray::SetCount(*mesh\a_edgeindices, 2*numUniqueEdges)
    For i =0 To numUniqueEdges-1
      CArray::SetValueL(*mesh\a_edgeindices, i*2, uniqueEdges(i)\vertices[0])
      CArray::SetValueL(*mesh\a_edgeindices, i*2+1, uniqueEdges(i)\vertices[1])
      i+2
    Next  
    FreeArray(uniqueEdges())
    
    Define *first.Geometry::HalfEdge_t
    Define *last.Geometry::HalfEdge_t
    Define *current.Geometry::HalfEdge_t

    If MapSize(*openedges())
      ResetMap(*openedges())
      NextMapElement(*openedges())
      *first = *openedges()
      *mesh\a_halfedges(index)\face = -1
      *mesh\a_halfedges(index)\vertex = *first\next_he\vertex
      *mesh\a_halfedges(index)\opposite_he = *first
      *first\opposite_he =  *mesh\a_halfedges(index)
      *last = *mesh\a_halfedges(index)
      index + 1
      *current = GetNextOpenEdge(*openedges(), *first\vertex)
      While *current And *current <> *first
        *mesh\a_halfedges(index)\face = -1
        *mesh\a_halfedges(index)\vertex = *current\next_he\vertex
        *mesh\a_halfedges(index)\opposite_he = *current
        *mesh\a_halfedges(index)\prev_he = *last
        *last\next_he = *mesh\a_halfedges(index)
        *current\opposite_he =  *mesh\a_halfedges(index)
        *last =  *mesh\a_halfedges(index)
        *current = GetNextOpenEdge(*openedges(), *current\vertex)
        index + 1
      Wend  
      If *current
        *first\opposite_he\prev_he = *last
        *last\next_he = *first\opposite_he
      EndIf
    EndIf
    
    ReDim *mesh\a_halfedges(index)
    CArray::SetCount(*mesh\a_vertexhalfedge, ArraySize(*mesh\a_halfedges()))
    CArray::FillL(*mesh\a_vertexhalfedge, -1)
    
    ; create vertex lookup
    For i=0 To ArraySize(*mesh\a_halfedges())-1
      index = *mesh\a_halfedges(i)\vertex
      If CArray::GetValueL(*mesh\a_vertexhalfedge, index) < 0
        CArray::SetValueL(*mesh\a_vertexhalfedge, index, i)
      EndIf
    Next
    
    FreeMap(*openedges())
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Vertex Neighbors
  ;---------------------------------------------------------
  Procedure GetVertexNeighbors(*mesh.Geometry::PolymeshGeometry_t, index.i, *neighbors.CArray::CArrayLong)
    Define *first.Geometry::HalfEdge_t
    Define *current.Geometry::HalfEdge_t

    CArray::SetCount(*neighbors, 0)

    *first = *mesh\a_halfedges(CArray::getValueL(*mesh\a_vertexhalfedge, index))
    If *first\opposite_he
      CArray::AppendL(*neighbors, *first\opposite_he\vertex)
      
      *current = *first\opposite_he\next_he
      Define closed.b = #False
      While Not *first = *current
        If *current\opposite_he
          CArray::AppendL(*neighbors, *current\opposite_he\vertex)
          *current = *current\opposite_he\next_he
          If *current = *first : closed = #True : EndIf
        Else
          *current = *first
        EndIf
      Wend
      
      If Not closed
        *current = *first\prev_he\opposite_he
        While *current
          CArray::AppendL(*neighbors, *current\vertex)
          *current = *current\prev_he\opposite_he
        Wend  
      EndIf
    EndIf
    

  EndProcedure
  
  ;---------------------------------------------------------
  ; Grow Vertex Neighbors
  ;---------------------------------------------------------
  Procedure GrowVertexNeighbors(*mesh.Geometry::PolymeshGeometry_t, *vertices.CArray::CArrayLong)
    Define *first.Geometry::HalfEdge_t
    Define *current.Geometry::HalfEdge_t
    Define *neighbors.CArray::CArrayLong = CArray::newCArrayLong()
    Dim selected.b(*mesh\nbpoints)
    Define i, j, idx
    For i=0 To CArray::GetCount(*vertices)-1
      selected(CArray::GetValueL(*vertices, i)) = #True
    Next
    
    Define *extend.CArray::CarrayLong = CArray::newCArrayLong()
    For i=0 To CArray::GetCount(*vertices)-1
      GetVertexNeighbors(*mesh, CArray::GetValueL(*vertices, i), *neighbors)  
      For j=0 To CArray::GetCount(*neighbors)-1
        idx = CArray::GetValueL(*neighbors, j)
        If Not selected(idx)
          CArray::AppendUnique(*extend, @idx)
        EndIf
      Next
    Next
    
    If *extend\itemCount : CArray::AppendArray(*vertices, *extend) : EndIf
    CArray::Delete(*extend)
    CArray::Delete(*neighbors)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Shrink Vertex Neighbors
  ;---------------------------------------------------------
  Procedure ShrinkVertexNeighbors(*mesh.Geometry::PolymeshGeometry_t, *vertices.CArray::CArrayLong)
    Define *first.Geometry::HalfEdge_t
    Define *current.Geometry::HalfEdge_t
    Define *neighbors.CArray::CArrayLong = CArray::newCArrayLong()
    Dim selected.b(*mesh\nbpoints)
    Define i, j, idx, n, x
    For i=0 To CArray::GetCount(*vertices)-1
      selected(CArray::GetValueL(*vertices, i)) = #True
    Next
    
    Define *remove.CArray::CarrayLong = CArray::newCArrayLong()
    For i=0 To CArray::GetCount(*vertices)-1
      idx = CArray::GetValueL(*vertices, i)
      GetVertexNeighbors(*mesh, idx, *neighbors)  
      n = CArray::GetCount(*neighbors)
      x = 0
      For j=0 To n-1
        x + Selected(CArray::GetValueL(*neighbors, j))
      Next
      If n <> x
        CArray::AppendL(*remove, i)
      EndIf
      
    Next
    
    If *remove\itemCount
      For i=CArray::GetCount(*remove)-1 To 0 Step -1
        CArray::Remove(*vertices, CArray::GetValueL(*remove, i))
      Next
    EndIf
    
    CArray::Delete(*remove)
    CArray::Delete(*neighbors)

  EndProcedure
  
  ;---------------------------------------------------------
  ; Compute Islands
  ;---------------------------------------------------------
  Procedure ComputeIslands(*mesh.PolymeshGeometry_t)
    
    CArray::SetCount(*mesh\a_islands, *mesh\nbpoints)
    CArray::FillL(*mesh\a_islands, 0)
    Dim visited.b(*mesh\nbpoints)
    FillMemory(@visited(0), *mesh\nbpoints, 0, #PB_Byte)
    NewList seeds.i()
    NewList nexts.i()
    Define *neighbors.CArray::CArrayLong = CArray::newCArrayLong()
    
    Define i, j, n
    Define islandIndex = 0
    Define *h.Geometry::HalfEdge_t
    For i=0 To *mesh\nbpoints-1
      If Not visited(i)
        ClearList(seeds())
        AddElement(seeds())
        seeds() = i
        While ListSize(seeds())
          ClearList(nexts())
          ForEach seeds()
            GetVertexNeighbors(*mesh, seeds(), *neighbors)
            For j=0 To CArray::GetCount(*neighbors)-1
              n = CArray::GetValueL(*neighbors, j)
              If Not visited(n)
                CArray::SetValueL(*mesh\a_islands, n, islandIndex)
                visited(n) = #True
                AddElement(nexts())
                nexts() = n
              EndIf
            Next
          Next
          CopyList(nexts(), seeds())
        Wend
       islandIndex + 1
      EndIf
      
    Next

    *mesh\nbislands = islandIndex

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
    Protected *p.v3f32
    loc\geometry = *mesh
    loc\t = *t
    CArray::SetCount(*io, numSamples)
    Protected i, j
    For i=0 To numSamples - 1
      r = Random_0_1() * *mesh\totalArea
      For j=0 To *mesh\nbtriangles - 1
        If r < CArray::GetValueF(*mesh\a_triangleareas, j)
          loc\uvw\x=Random_0_1()
          loc\uvw\y=Random_0_1()
          If loc\uvw\x + loc\uvw\y > 1
            loc\uvw\x = 1-loc\uvw\x
            loc\uvw\y = 1-loc\uvw\y
          EndIf
          loc\uvw\z = 1-loc\uvw\x-loc\uvw\y
          loc\tid = j
          *p = Location::GetPosition(loc)
          CArray::SetValue(*io, i, *p)
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
        CArray::SetValueL(*topo\faces,dst_offset+nbv,-2)
        src_offset + nbv 
        dst_offset + (nbv+1)
      Next i
    EndIf
    
    Define res.c = Mod(CArray::GetCount(*topo\faces), 4)
    If res <> 0
      For i=0 To (3-res) : CArray::AppendL(*topo\faces, -2) : Next
    EndIf

    ProcedureReturn *topo
      
  EndProcedure
  
  ;---------------------------------------------------------
  ; Bunny Primitive
  ;---------------------------------------------------------
  Procedure BunnyTopology(*geom.PolymeshGeometry_t)
    Topology::Bunny(*geom\topo)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Teapot Primitive
  ;---------------------------------------------------------
  Procedure TeapotTopology(*geom.PolymeshGeometry_t)
    Topology::Teapot(*geom\topo)
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
      CArray::SetValue(*vertices,v,p)
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
  
  Procedure TorusTopology(*geom.PolymeshGeometry_t)
    Topology::Torus(*geom\topo)
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
    Vector3::Set(p,l,l,l)
    CArray::SetValue(*geom\a_positions,0,p)
    Vector3::Set(p,l,l,-l)
    CArray::SetValue(*geom\a_positions,1,p)
    Vector3::Set(p,-l,l,-l)
    CArray::SetValue(*geom\a_positions,2,p)
    Vector3::Set(p,-l,l,l)
    CArray::SetValue(*geom\a_positions,3,p)
    Vector3::Set(p,l,-l,l)
    CArray::SetValue(*geom\a_positions,4,p)
    Vector3::Set(p,l,-l,-l)
    CArray::SetValue(*geom\a_positions,5,p)
    Vector3::Set(p,-l,-l,-l)
    CArray::SetValue(*geom\a_positions,6,p)
    Vector3::Set(p,-l,-l,l)
    CArray::SetValue(*geom\a_positions,7,p)
    
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
          Vector3::Set(p,0,0,0);
        Case 1
          Vector3::Set(p,1,0,0)
        Case 2
          Vector3::Set(p,1,1,0)
        Case 3
          Vector3::Set(p,0,0,0)
      EndSelect
      CArray::SetValue(*geom\a_uvws,i,p)
     
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
    Color::Set(color,1,0,0,1);
    SetColors(*geom,@color)
    ComputeTriangles(*geom)
    ComputeNormals(*geom,1)
    GetTopology(*geom)
    
  EndProcedure
  
  Procedure CubeTopology(*geom.PolymeshGeometry_t,radius.f=1,u.i=1,v.i=1,w.i=1)
    Topology::Cube(*geom\topo)
  EndProcedure
  
  
  ; ---------------------------------------------------------
  ;   SPHERE
  ; ---------------------------------------------------------
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
        Vector3::Set(p,0,-radius,0)
        CArray::SetValue(*geom\a_positions,0,p)
  
      ElseIf i = longs-1
        Vector3::Set(p,0,radius,0)
        CArray::SetValue(*geom\a_positions,nbp-1,p)
  
      Else
        For j = 0 To lats-1
          lat = 2*#F32_PI * ((j-1)*(1/lats))
          x = Cos(lat)
          z = Sin(lat)
          Vector3::Set(p,x*yr,y,z*yr)
          k = (i-1)*lats+j+1
          CArray::SetValue(*geom\a_positions,k,p)
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
    Color::Set(color,Random(255)/255,Random(255)/255,Random(255)/255,1.0)
   SetColors(*geom,@color)
    ComputeTriangles(*geom)
    ComputeNormals(*geom,1)
  
    GetTopology(*geom)
    
    ;UVs
    GetUVWSFromPosition(*geom)
  
  
  EndProcedure
  
  Procedure SphereTopology(*geom.PolymeshGeometry_t,radius.f=1,lats.i=8,longs.i=8)
    Topology::Sphere(*geom\topo, radius, lats, longs)
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
        Vector3::Set(pos,-0.5*sizX+x*stepx,0,-0.5*sizZ+z*stepz)
        CArray::SetValue(*geom\a_positions,x*u+z,pos)
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
    ComputeTriangles(*geom)
    ComputeNormals(*geom,1)
    GetTopology(*geom)
   
    ;Color
    Color::Set(color,1,Random(255)/255,Random(255)/255,Random(255)/255);
    SetColors(*geom,@color)
    
    ;UVWs
    GetUVWSFromPosition(*geom,#True)
   
  EndProcedure
  
  Procedure GridTopology(*geom.PolymeshGeometry_t,radius.f=1,u.i=12,v.i=12)
    Topology::Grid(*geom\topo, radius, u, v)
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
          Vector3::Set(a,x*spx-width*0.5,0,y*spy-height*0.5)
          Vector3::Set(b,(x+1)*spx-width*0.5,0,y*spy-height*0.5)
          Vector3::Set(c,x*spx-width*0.5,0,(y+1)*spy-height*0.5)
          Vector3::Set(d,(x+1)*spx-width*0.5,0,(y+1)*spy-height*0.5)
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
  ;   OPolymeshGeometry_ComputeTriangles(*geom)
  ;   OPolymeshGeometry_ComputeNormals(*geom)
  EndProcedure
  
  ;--------------------------------------------------------------
  ; Cylinder Topology
  ;--------------------------------------------------------------
  Procedure CylinderTopology(*geom.PolymeshGeometry_t,radius.f,u.i=8,v.i=1,w.i=0,captop.b=#True,capbottom.b=#True)
    Topology::Cylinder(*geom\topo, radius, u, v, w, captop, capbottom)
  EndProcedure
  
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
    Vector3::Set(p,0,0,1)
    Protected q.q4f32
    Protected i
    Protected incr.f = 1/u*360
    CArray::SetValue(*geom\a_positions,0,x)
    For i=0 To u-1
      Quaternion::SetFromAxisAngleValues(q,0,1,0,Radian(i*incr))
      Vector3::MulByQuaternion(x,p,q)
      CArray::SetValue(*geom\a_positions,i+1,x)
      CArray::SetValueL(*geom\a_faceindices,i*3,0)
      CArray::SetValueL(*geom\a_faceindices,i*3+1,i+1)
      CArray::SetValueL(*geom\a_faceindices,i*3+2,Mod(i+1,u)+1)
      CArray::SetValueL(*geom\a_facecount,i,3)
    Next 
    
    ; Update Geometry
    Protected color.c4f32
    ComputeTriangles(*geom)
    ComputeNormals(*geom,1)
    GetTopology(*geom)
 
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
    Topology::Delete(*Me\base)
    
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
    CArray::Delete(*Me\a_islands)
    CArray::Delete(*Me\a_vertexhalfedge)

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
    
    Protected c.c4f32
    Protected *c.c4f32
    CArray::SetCount(*shape\colors,*shape\nbp)
    For i=0 To *shape\nbp-1
      *c = CArray::GetValue(*Me\a_colors,i)
      Color::Set(c,*c\r,*c\g,*c\b,1)
      CArray::SetValue(*shape\colors,i,c)
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
    *Me\a_islands = CArray::newCArrayLong()
    *Me\a_vertexhalfedge = CArray::newCArrayLong()
    
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
          Topology::Grid(*Me\base,10,10,10)
        Case Shape::#SHAPE_CYLINDER
          Topology::Cylinder(*Me\base,1,6,1,10)
        Case Shape::#SHAPE_CUBE
          Topology::Cube(*Me\base,1,10,10,10)
        Case Shape::#SHAPE_SPHERE
          Topology::Sphere(*Me\base,0.5,12,8)
        Case Shape::#SHAPE_GRID
          Topology::Grid(*Me\base,1,10,10)
        Case Shape::#SHAPE_TORUS
          Topology::Torus(*Me\base)
        Case Shape::#SHAPE_BUNNY
          Topology::Bunny(*Me\base)
        Case Shape::#SHAPE_TEAPOT
          Topology::Teapot(*Me\base)
      EndSelect
      
      Set2(*Me,*Me\base)
    EndIf

    ProcedureReturn *Me
  EndProcedure
  ;}
  
  
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 275
; FirstLine = 306
; Folding = ----H9---8--
; EnableXP
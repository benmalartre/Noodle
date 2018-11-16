XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../opengl/Shader.pbi"

; ==============================================================================
;  Geometry Module Declaration
; ==============================================================================
DeclareModule Geometry
  UseModule Math
  Enumeration
    #GEOMETRY_1D
    #GEOMETRY_2D
    #GEOMETRY_3D
  EndEnumeration

  Enumeration
    #Geometry_Polymesh
    #Geometry_PointCloud
    #Geometry_Curve
  EndEnumeration
  
  Enumeration
    #LOCATION_1D
    #LOCATION_2D
    #LOCATION_3D
  EndEnumeration
  
  
  ; ============================================================================
  ;  Structures
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ; Box
  ; ----------------------------------------------------------------------------
  ;{
  Structure Box_t
    origin.v3f32
    extend.v3f32
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Line
  ; ----------------------------------------------------------------------------
  ;{
  Structure Line_t
    ; Parametric description:
    ;  l(t) = _p0 + t * _length * _dir;
    p1.v3f32
    p2.v3f32    
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Sphere
  ; ----------------------------------------------------------------------------
  ;{
  Structure Sphere_t
    center.v3f32
    radius.f
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Cylinder
  ; ----------------------------------------------------------------------------
  ;{
  Structure Cylinder_t
    position.v3f32
    axis.v3f32
    radius.f
    height.f
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Capsule
  ; ----------------------------------------------------------------------------
  ;{
  Structure Capsule_t
    *cylinder.Cylinder_t
    *head.Sphere_t
    *tail.Sphere_t
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Ray
  ; ----------------------------------------------------------------------------
  ;{
  Structure Ray_t
    origin.v3f32
    direction.v3f32
  ;   inv_origin.v3f32
    inv_direction.v3f32
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Plane
  ; ----------------------------------------------------------------------------
  ;{
  Structure Plane_t
    normal.v3f32
    distance.f
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Shape
  ; ----------------------------------------------------------------------------
  ;{
  Structure Shape_t
    type.i
    *position
    *normals
    *uvws
    *indices
    nbp.i
    nbi.i
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Sample
  ; --------------------------------------------
  ;{
  Structure Sample_t
    id.i
    *position.v3f32
    *normal.v3f32
    *uvs.v2f32
    *uvws.v3f32
    *color.v4f32
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Vertex
  ; --------------------------------------------
  ;{
  Structure Vertex_t
    id.i
    islandid.i
    selected.b
    visited.b
    position.v3f32
    normal.v3f32
    color.c4f32
    *neighbors.CArray::CArrayPtr
    *edges.CArray::CArrayPtr
    *polygons.CArray::CArrayPtr
    *triangles.CArray::CArrayPtr
    *samples.CArray::CArrayPtr
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Edge
  ; --------------------------------------------
  ;{
  Structure Edge_t
    id.i
    position.v3f32
    normal.v3f32
    *neighbors.CArray::CArrayPtr
    *vertices.CArray::CArrayPtr
    *polygons.CArray::CArrayPtr
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Triangle
  ; --------------------------------------------
  ;{
  Structure Triangle_t
    id.i
    map_id.i
    vertices.l[3]
    boundary.b
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Polygon
  ; --------------------------------------------
  ;{
  Structure Polygon_t
    id.i
    position.v3f32
    normal.v3f32
    *samples.CArray::CArrayPtr
    *neighbors.CArray::CArrayPtr
    *vertices.CArray::CArrayPtr
    *edges.CArray::CArrayPtr
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Polymesh Topology
  ; --------------------------------------------
  ;{
  Structure Topology_t
    *vertices.CArray::CArrayV3F32
    *faces.CArray::CArrayLong
    dirty.i
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Geometry Base
  ; --------------------------------------------
  ;{
   Structure Geometry_t
    bbox.Box_t
    nbpoints.i
    type.i
    *parent
    *a_positions.CArray::CArrayV3F32
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; Polymesh Geometry
  ; --------------------------------------------
  ;{
  Structure PolymeshGeometry_t Extends Geometry_t
    nbedges.i
    nbpolygons.i
    nbtriangles.i
    nbsamples.i
    nbindices.i
    shapetype.i
    dirty.b
    totalArea.f
    
    *a_velocities.CArray::CArrayV3F32
    *a_normals.CArray::CArrayV3F32
    *a_tangents.CArray::CArrayV3F32
    *a_pointnormals.CArray::CArrayV3F32
    *a_polygonnormals.CArray::CArrayV3F32
    *a_uvws.CArray::CArrayV3F32
    *a_colors.CArray::CArrayC4F32
    *a_faceindices.CArray::CArrayLong
    *a_facecount.CArray::CArrayLong
    *a_triangleindices.CArray::CArrayLong
    *a_vertexpolygoncount.CArray::CArrayLong
    *a_vertexpolygonindices.CArray::CArrayLong
    *a_edgeindices.CArray::CArrayLong
    *a_triangleareas.CArray::CArrayFloat
    *a_polygonareas.CArray::CArrayFloat
    
    *topo.Topology_t
    *base.Topology_t
    
    *a_vertices.CArray::CArrayPtr
    *a_edges.CArray::CArrayPtr
    *a_polygons.CArray::CArrayPtr
    *a_samples.CArray::CArrayPtr

  EndStructure
  ;}
  
  
  ;  PointCloud Geometry
  ; ----------------------------------------------------------------------------
  Structure PointCloudGeometry_t Extends Geometry_t
    incrementID.i
    *a_velocities.CArray::CArrayV3F32
    *a_normals.CArray::CArrayV3F32
    *a_tangents.CArray::CArrayV3F32
    *a_color.CArray::CArrayC4F32
    *a_scale.CArray::CArrayV3F32
    *a_size.CArray::CArrayFloat
    *a_indices.CArray::CArrayLong
    *a_uvws.CArray::CArrayV3F32
   
  EndStructure

  ;  Curve Geometry
  ; ----------------------------------------------------------------------------
  Structure CurveGeometry_t Extends Geometry_t
    
    *a_velocities.CArray::CArrayV3F32
    *a_numVertices.CArray::CArrayLong
    *a_numSamples.CArray::CArrayLong
    *a_colors.CArray::CArrayV3F32
    
    nbsamples.i
    curvetype.l
    wrap.l
    ubasis.l
    vbasis.l
    
    *a_widths.CArray::CArrayFloat
    *a_uvs.CArray::CArrayV2F32
    *a_normals.CArray::CArrayV3F32

    ; optional
    *a_weights.CArray::CArrayFloat
    *a_orders.CArray::CArrayChar
    *a_knots.CArray::CArrayFloat
    
  EndStructure
  
  ; Location
  ; --------------------------------------------
  Structure Location_t
    tid.i
    p.v3f32
    n.v3f32
    uvw.v3f32
    c.c4f32
    *geometry.Geometry::Geometry_t
    *t.Transform::Transform_t
  EndStructure
  
  ; PointOnMesh
  ; --------------------------------------------
  Structure PointOnMesh_t
    gid.i
    tid.i
    p.v3f32
    n.v3f32
    uvw.v3f32
    c.c4f32
    *geometry.Geometry::PolymeshGeometry_t
    *t.Transform::Transform_t
  EndStructure
  
  ; PointOnCurve
  ; --------------------------------------------
  Structure PointOnCurve_t
    cid.i
    u.f
    n.v3f32
    p.v3f32
    c.c4f32
    *geometry.Geometry::CurveGeometry_t
    *t.Transform::Transform_t
  EndStructure
  
  ; HalfEdge
  ; --------------------------------------------
  Structure HalfEdge_t
    vertex.i
    face.i
    edge.i
    opposite_he.i
    next_he.i
  EndStructure
  
  ; Element
  ; ----------------------------------------------------------------------------
  Structure Element_t
    gid.i   ; geometry index
    eid.i   ; element index
  EndStructure
  
  ; Cell
  ; ----------------------------------------------------------------------------
  Structure Cell_t
    color.v3f32
    hit.b
    Array elements.i(0)
  EndStructure
  
  
  ; Grid3D 
  ; ----------------------------------------------------------------------------
  Structure Grid3D_t
    elemType.i
    ; definition of the grid
    resolution.i[3]
    dimension.v3f32
    bbox.Box_t
    
    ; geometries
    List *geometries.Geometry_t()
    List elements.Element_t()
    
    ; cells
    numCells.i
    Array *cells.Cell_t(0)

    ; rays tested For intersection
    numRays.i
    Array rays.Ray_t(0)
    
    ; dirty (need update)
    dirty.b
    
  EndStructure
  
  Declare RecomputeBoundingBox(*geom.Geometry_t, worldSpace.b=#False, *m.m4f32=#Null)
  Declare GetNbPoints(*geom.Geometry_t)
  Declare GetParentObject3D(*Me.Geometry_t)
  Declare ConstructPlaneFromThreePoints(*Me.Plane_t, *a.v3f32, *b.v3f32, *c.v3f32)
  Declare ConstructPlaneFromPositionAndNormal(*Me.Plane_t, *position.v3f32, *normal.v3f32)
EndDeclareModule


;========================================================================================
; Geometry Module Implementation
;========================================================================================
Module Geometry
  Procedure RecomputeBoundingBox(*geom.Geometry_t, worldSpace.b=#False, *m.m4f32=#Null)
    If Not *geom Or Not *geom\nbpoints
      ProcedureReturn
    EndIf
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define *positions = *geom\a_positions\data
      Define nbp = *geom\nbpoints
      Define *origin = *geom\bbox\origin
      Define *extend = *geom\bbox\extend
      Define half.f = 0.5
      
      ; load datas to cpu
      ! mov rax, [p.p_positions]              ; pass positions address to cpu
      ! mov rcx, [p.v_nbp]                    ; pass nb of points
      ! xor r8, r8                            ; reset offset
      ! movaps xmm0, [rax]                    ; load first point in xmm0, initialize bmin
      ! movaps xmm1, xmm0                     ; copy first point in xmm1, initialize bmax
      
      ! dec rcx                               ; decrement counter
      ! jz output_compute_box                 ; if only one point exit
      ! add r8, 16                            ; increment offset (skip first point)
      
      ! mov rdx, [p.v_worldSpace]             ; local or world space bounding box
      ! cmp rdx, 0
      ! je loop_compute_box_local             ; jump to local space computation
      
      ; load world space matrix
      ! mov rdx, [p.p_m]                      ; load worldspace matrix in xmmm
      ! movups  xmm6, [rdx]                   ; load first row in xmm6  
      ! movups  xmm7, [rdx+16]                ; load second row in xmm7
      ! movups  xmm8, [rdx+32]                ; load third row in xmm8
      ! movups  xmm9, [rdx+48]                ; load fourth row in xmm9
      
      ; mul by matrix bmin and bmax
      ! movaps xmm2, xmm0                     ; d c b a
      ! movaps xmm3, xmm0                     ; d c b a   
      ! movaps xmm4, xmm0                     ; d c b a 
      
      ! shufps xmm0, xmm0, 0                  ; a a a a 
      ! shufps xmm2, xmm2, 01010101b          ; b b b b
      ! shufps xmm3, xmm3, 10101010b          ; c c c c
      ! shufps xmm4, xmm4, 11111111b          ; d d d d
 
      ! mulps  xmm0, xmm6
      ! mulps  xmm2, xmm7
      ! mulps  xmm3, xmm8
      
      ! addps  xmm0, xmm2
      ! addps  xmm0, xmm3
      ! addps  xmm0, xmm9
        
      ! movaps xmm3, xmm0
      ! shufps xmm3, xmm3, 11111111b
      ! divps xmm0, xmm3
      
      ! movaps xmm1, xmm0
      ! jmp loop_compute_box_world            ; jump to world space computation
      
      ; compute local bounding box
      ! loop_compute_box_local:
      !   movaps xmm2, [rax+r8]               ; load current point
      !   minps xmm0, xmm2                    ; packed minimum test
      !   maxps xmm1, xmm2                    ; packed maximum test

      !   add r8, 16                          ; increment offset
      !   dec rcx                             ; decrement counter
      !   jnz loop_compute_box_local          ; loop
      !   jmp output_compute_box
      
      ; compute world bounding box
      ! loop_compute_box_world:
      !   movaps xmm2, [rax+r8]               ; d c b a
      !   movaps xmm3, xmm2                   ; d c b a
      !   movaps xmm4, xmm2                   ; d c b a       
      !   movaps xmm5, xmm2                   ; d c b a
      
      !   shufps xmm2, xmm2,0                 ; a a a a 
      !   shufps xmm3, xmm3,01010101b         ; b b b b
      !   shufps xmm4, xmm4,10101010b         ; c c c c
      !   shufps xmm5, xmm5,11111111b         ; d d d d
 
      !   mulps  xmm2, xmm6
      !   mulps  xmm3, xmm7
      !   mulps  xmm4, xmm8
      
      !   addps  xmm2, xmm3
      !   addps  xmm2, xmm4
      !   addps  xmm2, xmm9
        
      !   movaps xmm3, xmm2
      !   shufps xmm3, xmm3, 11111111b
      !   divps xmm2, xmm3
      
      !   minps xmm0, xmm2                    ; packed minimum test
      !   maxps xmm1, xmm2                    ; packed maximum test

      !   add r8, 16                          ; increment offset
      !   dec rcx                             ; decrement counter
      !   jnz loop_compute_box_world          ; loop
      !   jmp output_compute_box
      
      ; output bounding box
      ! output_compute_box:                   ; output bbox
      !   movlps xmm2, [p.v_half]             ; load half value (0.5)
      !   shufps xmm2, xmm2, 0                ; fill xmm3 with half
      !   movaps xmm3, xmm0                   ; copy bmin to xmm2
      !   mulps xmm3, xmm2                    ; multiply bmin by half
      !   movaps xmm4, xmm1                   ; copy bmax to xmm2
      !   mulps xmm4, xmm2                    ; multiply bmax by half
      !   addps xmm3, xmm4                    ; add packed float
      
      !   subps xmm1, xmm0                    ; packed substraction bmax - bmin
      !   mulps xmm1, xmm2                    ; packed multiplication extend * half
      
      !   mov rdx, [p.p_origin]               ; bbox origin (unaligned)
      !   movups [rdx], xmm3                  ; set from xmm3 
      !   mov rdx, [p.p_extend]               ; bbox extend (unaligned)
      !   movups [rdx], xmm1                  ; set from xmm1
      
    CompilerElse
      Protected i
      Protected *v.v3f32
      Protected bmin.v3f32, bmax.v3f32
      Vector3::Set(bmin,#F32_MAX,#F32_MAX,#F32_MAX)
      Vector3::Set(bmax,-#F32_MAX,-#F32_MAX,-#F32_MAX)
      
      For i=0 To *geom\nbpoints-1
        *v = CArray::GetValue(*geom\a_positions,i)
    
        If worldSpace : Vector3::MulByMatrix4InPlace(*v,*m) : EndIf 
        If *v\x < bmin\x : bmin\x = *v\x : EndIf
        If *v\y < bmin\y : bmin\y = *v\y : EndIf
        If *v\z < bmin\z : bmin\z = *v\z : EndIf
        
        If *v\x > bmax\x : bmax\x = *v\x : EndIf
        If *v\y > bmax\y : bmax\y = *v\y : EndIf
        If *v\z > bmax\z : bmax\z = *v\z : EndIf
      Next i
      
      Protected *box.Geometry::Box_t = *geom\bbox
      Vector3::LinearInterpolate(*box\origin, bmin, bmax, 0.5)    
      Vector3::Sub(*box\extend, bmax, bmin)
      Vector3::ScaleInPlace(*box\extend, 0.5)
    CompilerEndIf
  EndProcedure
  
  Procedure GetNbPoints(*geom.Geometry_t)
    ProcedureReturn CArray::GetCount(*geom\a_positions)
  EndProcedure
  
  
  Procedure GetParentObject3D(*Me.Geometry_t)
    ProcedureReturn *Me\parent
  EndProcedure
  
  Procedure ConstructPlaneFromThreePoints(*Me.Plane_t, *a.v3f32, *b.v3f32, *c.v3f32)
    Protected e1.v3f32
    Protected e2.v3f32
    Vector3::Sub(e1,*b,*a)
    Vector3::Sub(e2,*c,*a)
    Vector3::Cross(*Me\normal, e1, e2)
    Vector3::NormalizeInPlace(*Me\normal)
    *Me\distance = Vector3::Dot(*Me\normal, *a)
  EndProcedure
  
  Procedure ConstructPlaneFromPositionAndNormal(*Me.Plane_t, *position.v3f32, *normal.v3f32)
    Vector3::Normalize(*Me\normal, *normal)
    *Me\distance = Vector3::Dot(*Me\normal, *position)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 455
; FirstLine = 476
; Folding = -----
; EnableXP
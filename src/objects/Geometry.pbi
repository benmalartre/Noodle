XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../opengl/Shader.pbi"

; ==============================================================================
;  Geometry Module Declaration
; ==============================================================================
DeclareModule Geometry
  Enumeration
    #GEOMETRY_1D
    #GEOMETRY_2D
    #GEOMETRY_3D
  EndEnumeration
  
  UseModule Math
  Structure Geometry_t
    nbpoints.i
    type.i
    *parent
  EndStructure
  
  
  Enumeration
    #Geometry_Polymesh
    #Geometry_PointCloud
    #Geometry_Curve
  EndEnumeration
  
  ; ============================================================================
  ;  Structures
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ; Box Instance
  ; ----------------------------------------------------------------------------
  ;{
  Structure Box_t
    p_min.v3f32
    p_max.v3f32
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; Sphere Instance
  ; ----------------------------------------------------------------------------
  ;{
  Structure Sphere_t
    p_center.v3f32
    p_radius.f
  EndStructure
  ;}
  
  ; 
  ; Ray Instance
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
  ; Plane Instance
  ; ----------------------------------------------------------------------------
  ;{
  Structure Plane_t
    origin.v3f32
    normal.v3f32
    tangent.v3f32
    binormal.v3f32
  EndStructure
  ;}
  
  ; ----------------------------------------------------------------------------
  ; CShape Instance
  ; ----------------------------------------------------------------------------
  ;{
  Structure Shape_t
  ;   type.i
  ;   a_positions.CArrayV3F32
  ;   a_indices.CArrayV3F32
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
  ; Sample Instance
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
  ; Vertex Instance
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
  ; Edge Instance
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
  ; CTriangle Instance
  ; --------------------------------------------
  ;{
  Structure Triangle_t
    id.i
    *v1.Vertex_t
    *v2.Vertex_t
    *v3.Vertex_t
    normal.v3f32
    position.v3f32
  EndStructure
  ;}
  ;}
  
  ; --------------------------------------------
  ; Polygon Instance
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
  ;}
  
  ; --------------------------------------------
  ; PolymeshTopology Instance
  ; --------------------------------------------
  ;{
  Structure Topology_t
    *vertices.CArray::CArrayV3F32
    *faces.CArray::CArrayLong
    dirty.i
  EndStructure
  ;}
  
  ; --------------------------------------------
  ; CPolymesh Instance
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
    
    *a_positions.CArray::CArrayV3F32
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

    *topo.Topology_t
    *base.Topology_t
    
    *a_vertices.CArray::CArrayPtr
    *a_edges.CArray::CArrayPtr
    *a_polygons.CArray::CArrayPtr
    *a_samples.CArray::CArrayPtr

  EndStructure
  ;}
  
  
  ;  CPointCloud Instance
  ; ----------------------------------------------------------------------------
  Structure PointCloudGeometry_t Extends Geometry_t
    incrementID.i
    *a_positions.CArray::CArrayV3F32
    *a_velocities.CArray::CArrayV3F32
    *a_normals.CArray::CArrayV3F32
    *a_tangents.CArray::CArrayV3F32
    *a_color.CArray::CArrayC4F32
    *a_scale.CArray::CArrayV3F32
    *a_size.CArray::CArrayFloat
    *a_indices.CArray::CArrayLong
    *a_uvws.CArray::CArrayV3F32
   
  EndStructure

  ;  Curve Instance
  ; ----------------------------------------------------------------------------
  Structure CurveGeometry_t Extends Geometry_t
    interpolation.i
    closed.b
    *a_positions.CArray::CArrayV3F32
    *a_samples.CArray::CArrayV3F32

  EndStructure
  
  ; Location Instance
  ; --------------------------------------------
  Structure Location_t
    tid.i
    u.f
    v.f
    w.f
    n.v3f32
    p.v3f32
    c.c4f32
    *geometry.Geometry::PolymeshGeometry_t
    *t.Transform::Transform_t
  EndStructure

  ;  Grid3D Instance
  ; ----------------------------------------------------------------------------
  Structure Grid3DTriangle_t
    *t.Triangle_t  ; original triangle
    n.v3f32         ; triangle normal
    en1.v3f32       ; edge 1 normal
    en2.v3f32       ; edge 2 normal
    en3.v3f32       ; edge 3 normal
  EndStructure
  
  
  ;  Class ( Grid3D )
  ; ----------------------------------------------------------------------------
  Structure Grid3D_t
    size.i              ;grid size
    
    xstep.d             ;cell length in x direction
    ystep.d             ;cell length in y direction
    zstep.d             ;cell length in z direction
    
    bbmin.v3f32           ; bounding box minimum
    bbmax.v3f32           ; bounding box maximum
    
    Array rays.Ray_t(0)    ; rays tested For intersection
    ;Array *grid.CArray::CArrayPtr()
  EndStructure
  
  ; Folicle )
  ; ----------------------------------------------------------------------------
  Structure Folicle_t
    radius.i              ;grid size
    nbp.i
    position.v3f32
    normal.v3f32
    orientation.q4f32
    *strandposition.CArray::CArrayV3F32
    *strandNormal.CArray::CArrayV3F32
    *strandTangent.CArray::CArrayV3F32
    *strandRadius.CArray::CArrayFloat
  EndStructure
  
  Declare GetParentObject3D(*Me.Geometry_t)
  
EndDeclareModule




;========================================================================================
; Geometry Module Implementation
;========================================================================================
Module Geometry
  
  Procedure GetParentObject3D(*Me.Geometry_t)
    ProcedureReturn *Me\parent
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 44
; FirstLine = 18
; Folding = ---
; EnableXP
XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Topology.pbi"
XIncludeFile "../objects/PolymeshGeometry.pbi"

UseModule Math

Define *topo.Geometry::Topology_t = Topology::New()

Define *topo1.Geometry::Topology_t = Topology::New()
Topology::Sphere(*topo1, 1,32,16)
Define *topo2.Geometry::Topology_t = Topology::New()
Topology::Bunny(*topo2)
Define *topo3.Geometry::Topology_t = Topology::New()
Topology::Teapot(*topo3)

; Define *matrices.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
; Define *positions.CArray::CArrayV3F32 = CARray::newCArrayV3F32()
; CArray::SetCount(*matrices, numTopos)
; Define i
; Define p.v3f32
; Define s.v3f32
; Define *m.m4f32
; Define *p.v3f32
; RandomSeed(666)
; MathUtils::BuildCircleSection(*positions, numTopos+1, 8)
; For i=0 To numTopos-1
; ;     Vector3::Set(p, Random(50)-25, Random(50)-25, Random(50)-25)
;   *m = CArray::GetPtr(*matrices, i)
;   Matrix4::SetIdentity(*m)
;   Vector3::Set(s, 1,1,1);Random(4)+2,Random(4)+2,Random(4)+2)
;   Matrix4::SetScale(*m, s)
;   *p = CArray::GetValue(*positions, i)
;   Matrix4::SetTranslation(*m,   *p)
; Next
; 
Define *topos.CArray::CArrayPtr = CArray::New(CArray::#ARRAY_PTR)
CArray::SetCount(*topos,3)
CArray::SetValuePtr(*topos,0, *topo1)
CArray::SetValuePtr(*topos,1, *topo2)
CArray::SetValuePtr(*topos,2, *topo3)
; For i=0 To 5
;   CArray::SetValuePtr(*topos, i, *topo)
; Next
; 
; ; Topology::TransformArray(*topo, *matrices, *topos)
Topology::MergeArray(*topo, *topos)
; 
; PolymeshGeometry::Set2(*geom, *topo)
; Object3D::Freeze(*mesh)
  
Topology::Delete(*topo)
Topology::Delete(*topo1)
Topology::Delete(*topo2)
Topology::Delete(*topo3)

; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 55
; EnableXP
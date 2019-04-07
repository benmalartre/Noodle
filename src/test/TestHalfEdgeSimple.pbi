XIncludeFile "../core/Application.pbi"

Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
Define *indices.CArray::CArrayLong = CArray::newCArrayLong()
Define *a.Math::v3f32, *b.Math::v3f32, *c.Math::v3f32

CArray::SetCount(*positions, 3)
*a = CArray::GetValue(*positions, 0)
Vector3::RandomizeInPlace(*a,1)
*b = CArray::GetValue(*positions, 1)
Vector3::RandomizeInPlace(*b,1)
*c = CArray::GetValue(*positions, 2)
Vector3::RandomizeInPlace(*c,1)

CArray::SetCount(*indices, 4)
CArray::SetValueL(*indices, 0, 0)
CArray::SetValueL(*indices, 1, 1)
CArray::SetValueL(*indices, 2, 2)
CArray::SetValueL(*indices, 3, -2)

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Mesh", Shape::#SHAPE_NONE)
PolymeshGeometry::Set(*mesh\geom, *positions, *indices)

Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
PolymeshGeometry::ComputeHalfEdges(*geom)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 24
; EnableXP
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Object.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../objects/Polymesh.pbi"
; XIncludeFile "../objects/Geometry.pbi"
; XIncludeFile "../objects/PolymeshGeometry.pbi"

Time::Init()

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("TOTO", Shape::#Shape_None)
Define *worldSpace.Math::m4f32 = *mesh\globalT\m
Define *T.Math::trf32 = *mesh\localT
Transform::SetTranslationFromXYZValues(*T, 12, 6, 3)
Transform::SetScaleFromXYZValues(*T, 2, 1, 0.5)
Define q.Math::q4f32
Quaternion::SetFromAxisAngleValues(q,0,0,1,Radian(90))
Transform::SetRotationFromQuaternion(*T, q)
Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
PolymeshGeometry::SphereTopology(*geom\topo,1,512,512)


PolymeshGeometry::Set2(*geom, *geom\topo)
Object3D::SetLocalTransform(*mesh, *T)
Object3D::UpdateTransform(*mesh)
Define T.d = Time::Get()
Define i
Define msg.s
For i=0 To 12:
  Geometry::ComputeBoundingBox(*geom, #True, *worldSpace)
  msg.s + StrD(Time::Get() - T)+Chr(10)
  msg + "ORIGIN : "+Vector3::ToString(*geom\bbox\origin)+Chr(10)
  msg + "EXTEND : "+Vector3::ToString(*geom\bbox\extend)+Chr(10)
  T = Time::Get()
Next

; Geometry::RecomputeBoundingBox(*geom, #False)

MessageRequester("Time", msg)


  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 29
; EnableXP
; Constant = #USE_SSE=1
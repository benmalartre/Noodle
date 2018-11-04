XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Object.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../objects/Polymesh.pbi"
; XIncludeFile "../objects/Geometry.pbi"
; XIncludeFile "../objects/PolymeshGeometry.pbi"

Time::Init()

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("TOTO", Shape::#Shape_None)


Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
PolymeshGeometry::SphereTopology(*geom\topo,1,512,512)
Define T.d = Time::Get()
PolymeshGeometry::Set2(*geom, *geom\topo)
MessageRequester("Time", StrD(Time::Get() - T))
; Geometry::ComputeBoundingBox(

  



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 14
; EnableXP
; Constant = #USE_SSE=1
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


PolymeshGeometry::Set2(*geom, *geom\topo)

Define T.d = Time::Get()
Geometry::ComputeBoundingBox(*geom)
Define msg.s = StrD(Time::Get() - T)+Chr(10)
msg + "ORIGIN : "+Vector3::ToString(*geom\bbox\origin)+Chr(10)
msg + "EXTEND : "+Vector3::ToString(*geom\bbox\extend)+Chr(10)

MessageRequester("Time", msg)


  

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 20
; EnableXP
; Constant = #USE_SSE=1
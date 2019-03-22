
XIncludeFile "../../objects/Geometry.pbi"
XIncludeFile "../../objects/Topology.pbi"




Procedure Vertices(*topo.Geometry::Topology_t)
  Define address.i
  Define dataoffset = OffsetOf(CArray::CArrayT\data)
  Define verticesoffset = OffsetOf(Geometry::Topology_t\vertices)
  Define facesoffset = OffsetOf(Geometry::Topology_t\faces)
  ! mov rax, [p.p_topo]
  ! mov r8, [p.v_dataoffset]
  ! mov r9, [p.v_verticesoffset]
  ! mov r10, [rax + r9]
  ! add r10, r8
  ! mov rsi, [r10]
  ! mov [p.v_address], rsi
  
  Debug "VERTICES : "+Str(address) +" = " +Str(*topo\vertices\data)+" ? "+Str(Bool(address = *topo\vertices\data)) 

EndProcedure



Procedure Faces(*topo.Geometry::Topology_t)
  Define address.i
  Define dataoffset = OffsetOf(CArray::CArrayT\data)
  Define verticesoffset = OffsetOf(Geometry::Topology_t\vertices)
  Define facesoffset = OffsetOf(Geometry::Topology_t\faces)
  ! mov rax, [p.p_topo]
  ! mov r8, [p.v_dataoffset]
  ! mov r9, [p.v_facesoffset]
  ! mov r10, [rax + r9]
  ! add r10, r8
  ! mov rsi, [r10]
  ! mov [p.v_address], rsi
  
  Debug "FACES : "+Str(address) +" = " +Str(*topo\faces\data)+" ? "+Str(Bool(address = *topo\faces\data)) 

EndProcedure 

  

Define *topo.Geometry::Topology_t = Topology::New()
Topology::Sphere(*topo)

Debug CArray::GetCount(*topo\vertices)

Vertices(*topo)
Faces(*topo)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 41
; Folding = -
; EnableXP
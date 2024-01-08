XIncludeFile "../core/Demo.pbi"
XIncludeFile "../core/Fibonacci.pbi"

UseModule Math

Global N = 256
Global T.f = 0
Global *fibonacci.Fibonacci::Fibonacci_t = Fibonacci::New(N)

Global mode = 1
Select mode
  Case 0
    Fibonacci::Sphere(*fibonacci)
  Case 1
    Fibonacci::Disc(*fibonacci)
EndSelect

Global *demo.DemoApplication::DemoApplication_t

Global *instancer.InstanceCloud::InstanceCloud_t = InstanceCloud::New("Instancer", Shape::#SHAPE_NONE, *fibonacci\N)
Global *geom.Geometry::PointCloudGeometry_t = *instancer\geom

Global *prototype.Polymesh::Polymesh_t = Polymesh::New("mesh",Shape::#SHAPE_BUNNY)
PolymeshGeometry::ToShape(*prototype\geom,*instancer\shape)

Define i
Define scl.v3f32
Vector3::Set(scl, 2,2,2)
Define nrm.v3f32
Vector3::Set(nrm, 0, 1, 0)

Debug "Num Fibonacci points "+Str(*fibonacci\N)
For i=0 To *fibonacci\N - 1
  CArray::SetValue(*geom\a_positions,i,CArray::GetValue(*fibonacci\positions, i))
  CArray::SetValue(*geom\a_normals,i,nrm)
  Vector3::Set(scl,0.05,0.05,0.05)
  CArray::SetValue(*geom\a_scale,i,scl)
  CArray::SetValueF(*geom\a_size,i,1.0)
Next

Define width = 1200
Define height = 800

*demo = DemoApplication::New("Test Fibonacci",width,height)
*model = Model::New("Model")
Object3D::AddChild(*model, *instancer)

Scene::AddModel(*demo\scene, *model)

 Scene::Setup(*demo\scene)

 Application::Loop(*demo, DemoApplication::@Draw())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 40
; EnableXP
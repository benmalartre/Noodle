XIncludeFile "../core/Demo.pbi"
XIncludeFile "../core/Fibonacci.pbi"

UseModule Math
UseModule DemoApplication

Structure FibonacciDemo_t Extends DemoApplication_t
  *model.Model::Model_t
  *fibonacci.Fibonacci::Fibonacci_t
  *N.ControlNumber::ControlNumber_t
  *mode.ControlCombo::ControlCombo_t
  
  *instancer.InstanceCloud::InstanceCloud_t
  *prototype.Polymesh::Polymesh_t
EndStructure
  
Procedure UpdateFibonacciDemo(*demo.FibonacciDemo_t)
  Define N = *demo\N\value_n
  Define mode = 1
  If N <> *demo\fibonacci\N
    *demo\fibonacci\N = N
    Select mode
      Case 0
        Fibonacci::Sphere(*demo\fibonacci)
      Case 1
        Fibonacci::Disc(*demo\fibonacci)
    EndSelect

    Define  *geom.Geometry::PointCloudGeometry_t = *demo\instancer\geom
    PointCloudGeometry::Init(*geom, N)
    Define i
    Define scl.v3f32
    Vector3::Set(scl, 2,2,2)
    Define nrm.v3f32
    Vector3::Set(nrm, 0, 1, 0)
    Define up.v3f32
    Vector3::Set(up, 1, 0, 0)
    
    For i=0 To N - 1
      CArray::SetValue(*geom\a_positions,i,CArray::GetValue(*demo\fibonacci\positions, i))
      CArray::SetValue(*geom\a_normals,i,nrm)
      CArray::SetValue(*geom\a_tangents,i,up)
      Vector3::Set(scl,0.05,0.05,0.05)
      CArray::SetValue(*geom\a_scale,i,scl)
      CArray::SetValueF(*geom\a_size,i,1.0)
    Next
    PointCloud::SetDirtyState(*demo\instancer, Object3D::#DIRTY_STATE_TOPOLOGY)
    *demo\scene\dirty = #True
    Scene::Update(*demo\scene)
  EndIf
EndProcedure
Callback::DECLARE_CALLBACK(Update, Types::#TYPE_PTR)

Procedure NewFibonacciDemo(name.s, width.i=1200, height=800, options=#DEMO_WITH_ALL)
  Protected *demo.FibonacciDemo_t = AllocateStructure(FibonacciDemo_t)
  Init(*demo, name, width, height, options)
  *demo\fibonacci = Fibonacci::New(1)
  *demo\updateImpl = @UpdateFibonacciDemo()
  *demo\instancer = InstanceCloud::New("instancer", Shape::#SHAPE_NONE, 1)
  *demo\prototype = Polymesh::New("prototype",Shape::#SHAPE_BUNNY)
  PolymeshGeometry::ToShape(*demo\prototype\geom,*demo\instancer\shape)
  
  *demo\model = Model::New("Model")
  Object3D::AddChild(*demo\model, *demo\instancer)

  Scene::AddModel(*demo\scene, *demo\model)
  Scene::Setup(*demo\scene)
  
  Window::OnEvent(*demo\window, Globals::#EVENT_NEW_SCENE)

  Define *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*demo\property, "Controls ", "Controls",
                                                                         0,128,*demo\property\sizX, *demo\property\sizY-128)
  ControlProperty::AppendStart(*prop)
  
  ControlProperty::AddGroup(*prop, "Group")
  *demo\N = ControlProperty::AddIntegerControl(*prop, "GSSteps", "Steps", 6, #Null)
  *demo\N\hard_min = 1
  *demo\N\hard_max = 4096
  *demo\N\soft_min = 1
  *demo\N\soft_max = 1024
  Callback::CONNECT_CALLBACK(*demo\N\on_change, Update, *demo)
  
  *demo\mode = ControlProperty::AddComboControl(*prop, "Mode", "Mode", 0, #Null)
;   *demo\mode\items
  Callback::CONNECT_CALLBACK(*demo\N\on_change, Update, *demo)
  
  ControlProperty::EndGroup(*prop)
 
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*demo\property, *prop)
  ProcedureReturn *demo
EndProcedure
  

Define width = 1200
Define height = 800

Define *demo.FibonacciDemo_t = NewFibonacciDemo("Test Fibonacci",width,height)
 Application::Loop(*demo, DemoApplication::@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 83
; FirstLine = 43
; Folding = -
; EnableXP
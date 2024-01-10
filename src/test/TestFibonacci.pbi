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
  
Procedure UpdateFibonacciDemo(*Me.FibonacciDemo_t)
  Define N = *Me\N\value_n
  Define mode = 1
  If N <> *Me\fibonacci\N
    *Me\fibonacci\N = N
    Select mode
      Case 0
        Fibonacci::Sphere(*Me\fibonacci)
      Case 1
        Fibonacci::Disc(*Me\fibonacci)
    EndSelect

    Define  *geom.Geometry::PointCloudGeometry_t = *Me\instancer\geom
    PointCloudGeometry::Init(*geom, N)
    Define i
    Define scl.v3f32
    Vector3::Set(scl, 2,2,2)
    Define nrm.v3f32
    Vector3::Set(nrm, 0, 1, 0)
    Define up.v3f32
    Vector3::Set(up, 1, 0, 0)
    
    For i=0 To N - 1
      CArray::SetValue(*geom\a_positions,i,CArray::GetValue(*Me\fibonacci\positions, i))
      CArray::SetValue(*geom\a_normals,i,nrm)
      CArray::SetValue(*geom\a_tangents,i,up)
      Vector3::Set(scl,0.05,0.05,0.05)
      CArray::SetValue(*geom\a_scale,i,scl)
      CArray::SetValueF(*geom\a_size,i,1.0)
    Next
    PointCloud::SetDirtyState(*Me\instancer, Object3D::#DIRTY_STATE_TOPOLOGY)
    *Me\scene\dirty = #True
    Scene::Update(*Me\scene)
  EndIf
EndProcedure
Callback::DECLARE_CALLBACK(Update, Types::#TYPE_PTR)

Procedure NewFibonacciDemo(name.s, width.i=1200, height=800, options=#DEMO_WITH_ALL)
  Protected *Me.FibonacciDemo_t = AllocateStructure(FibonacciDemo_t)
  Init(*Me, name, width, height, options)
  *Me\fibonacci = Fibonacci::New(1)
  *Me\updateImpl = @UpdateFibonacciDemo()
  *Me\instancer = InstanceCloud::New("instancer", Shape::#SHAPE_NONE, 1)
  *Me\prototype = Polymesh::New("prototype",Shape::#SHAPE_BUNNY)
  PolymeshGeometry::ToShape(*Me\prototype\geom,*Me\instancer\shape)
  
  *Me\model = Model::New("Model")
  Object3D::AddChild(*Me\model, *Me\instancer)

  Scene::AddModel(*Me\scene, *Me\model)
  Scene::Setup(*Me\scene)
  If *Me\explorer
    ExplorerUI::Connect(*Me\explorer, *Me\scene)
    ExplorerUI::OnEvent(*Me\explorer, Globals::#EVENT_NEW_SCENE, #Null)
  EndIf

  If *Me\property
    Define *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*Me\property, "Controls ", "Controls",
                                                                           0,128,*Me\property\sizX, *Me\property\sizY-128)
    ControlProperty::AppendStart(*prop)
    
    ControlProperty::AddGroup(*prop, "Group")
    *Me\N = ControlProperty::AddIntegerControl(*prop, "GSSteps", "Steps", 6, #Null)
    *Me\N\hard_min = 1
    *Me\N\hard_max = 4096
    *Me\N\soft_min = 1
    *Me\N\soft_max = 1024
    Callback::CONNECT_CALLBACK(*Me\N\on_change, Update, *Me)
    ControlProperty::EndGroup(*prop)
   
    ControlProperty::AppendStop(*prop)
    PropertyUI::AddProperty(*Me\property, *prop)
  EndIf
  ProcedureReturn *Me
EndProcedure
  

Define width = 1200
Define height = 800

Define *demo.FibonacciDemo_t = NewFibonacciDemo("Test Fibonacci",width,height)
 Application::Loop(*demo, DemoApplication::@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 49
; FirstLine = 42
; Folding = -
; EnableXP
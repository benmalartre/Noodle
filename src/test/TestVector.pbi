XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Vector.pbi"

Global width = 1024
Global height = 1024

UseModule Math

Global *app.Application::Application_t
Global *canvas.CanvasUI::CanvasUI_t


Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
;   Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
;   Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
;   Object3D::SetLocalTransform(*light, *t)
  
  For i=0 To 12
    Verlet::StepPhysics(*verlet, 1/60)
  Next
  
  Drawer::Flush(*drawer)
  Verlet::Draw(*verlet, *drawer)
  Verlet::Deform(*verlet)
  
  GLContext::SetContext(*app\context)
  Scene::Update(Scene::*current_scene)
  
  Application::Draw(*app, *layer, *app\camera)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  GLContext::FlipBuffer(*app\context)
  ViewportUI::Blit(*viewport, *layer\buffer)

 EndProcedure
 

Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("TestMesh",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
     
    View::SetContent(*app\window\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  GLContext::SetContext(*app\context)
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(width,height,*app\context,*app\camera)
  Application::AddLayer(*app, *layer)

  Global *root.Model::Model_t = Model::New("Model")
  

  *mesh = Polymesh::New("Bunny", Shape::#SHAPE_BUNNY)
  *drawer = Drawer::New()
  *geom.Geometry::PolymeshGeometry_t = *mesh\geom

  PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
  *verlet = Verlet::New(*mesh\geom,1)
  
  Verlet::RigGeometry(*verlet)
  
  Object3D::AddChild(*root,*mesh)
  Object3D::AddChild(*root,*drawer)
  
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  ViewportUI::SetHandleTarget(*viewport, *mesh)
  Application::Loop(*app, @Draw())


  Verlet::Delete(*verlet)
EndIf


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 2
; FirstLine = 30
; Folding = -
; EnableXP
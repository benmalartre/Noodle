XIncludeFile "../core/Application.pbi"

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *mesh.Polymesh::Polymesh_t
Global *layer.LayerDefault::LayerDefault_t
Global width, height
Global model.Math::m4f32
; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  ViewportUI::SetContext(*viewport)
;   Scene::Update(Scene::*current_scene)
  
  Protected *s.Program::Program_t = *app\context\shaders("polymesh")
  
  ViewportUI::Draw(*viewport, *app\context)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

EndProcedure

Define nbp = 12
Define nbe = 256
Define rs = 4

width = 800
height = 600


; Main
Globals::Init()
;  Bullet::Init( )
FTGL::Init()
;--------------------------------------------
If Time::Init()
 Define startT.d = Time::Get ()
 Log::Init()
 *app = Application::New("TestMesh",width,height)

 If Not #USE_GLFW
   *viewport = ViewportUI::New(*app\manager\main,"ViewportUI", *app\camera)
   *app\context = *viewport\context
   
  View::SetContent(*app\manager\main,*viewport)
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *layer)
  
  Global *root.Model::Model_t = Model::New("Model")
  
  
  
  Define *section.CArray::CArrayV3F32 = CARray::newCArrayV3F32()
  Utils::BuildCircleSection(*section, 12)
      
  Define *points.CArray::CArrayM4F32 = CArray::newCArrayM4F32()
  
  Define *m.Math::m4f32
  Define p.Math::v3f32
  Define i, j
  Define.f bx,bz
  For j=0 To nbe-1
    *mesh.Polymesh::Polymesh_t = Polymesh::New("EX"+Str(j), Shape::#SHAPE_NONE)
    
    Define _nbp = nbp+(Random(2*rs)-rs)
    CArray::SetCount(*points, _nbp)
    bx = Math::Random_Neg1_1()*32
    bz = Math::Random_Neg1_1()*32
    For i=0 To _nbp-1
      *m = CArray::GetValue(*points, i)
      Matrix4::SetIdentity(*m)
      Vector3::Set(p, Math::Random_Neg1_1()+bx, i*3, Math::Random_Neg1_1()+bz)
      Matrix4::SetTranslation(*m, p)
    Next
    
    PolymeshGeometry::Extrusion(*mesh\geom, *points, *section)
  
  Object3D::Freeze(*mesh)
  
  Object3D::AddChild(*root,*mesh)
  Next
  

  
  
  
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  Application::Loop(*app, @Draw())
EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 80
; FirstLine = 36
; Folding = -
; EnableXP
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
  
  
  GLContext::SetContext(GLContext::*SHARED_CTXT)
;   Scne::Update(Scene::*current_scene)
  
  LayerDefault::Draw(*layer, *app\scene)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  FTGL::BeginDraw(GLContext::*SHARED_CTXT\writer)
  FTGL::SetColor(GLContext::*SHARED_CTXT\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(GLContext::*SHARED_CTXT\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(GLContext::*SHARED_CTXT\writer)
  
  GLContext::FlipBuffer(GLContext::*SHARED_CTXT)

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
   *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)     
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  *layer = LayerDefault::New(width,height,*viewport\context,*app\camera)
  Application::AddLayer(*app, *layer)

  
  Global *root.Model::Model_t = Model::New("Model")
  
 
  Define *section.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
  MathUtils::BuildCircleSection(*section, 12)
      
  Define *points.CArray::CArrayM4F32 = CArray::New(CArray::#ARRAY_M4F32)
  
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

  
  Scene::AddModel(*app\scene,*root)
  Scene::Setup(*app\scene)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 16
; FirstLine = 6
; Folding = -
; EnableXP
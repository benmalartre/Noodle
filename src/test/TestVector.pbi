﻿XIncludeFile "../core/Application.pbi"
XIncludeFile "../objects/Verlet.pbi"
Global width = 1024
Global height = 1024

UseModule Math

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *layer.LayerDefault::LayerDefault_t
Global *mesh.Polymesh::Polymesh_t
Global *verlet.Verlet::Verlet_t 
Global *drawer.Drawer::Drawer_t 

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
  
  ViewportUI::SetContext(*viewport)
  Scene::Update(Scene::*current_scene)
  
  ViewportUI::Draw(*viewport, *app\context)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

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
; CursorPosition = 101
; FirstLine = 42
; Folding = -
; EnableXP
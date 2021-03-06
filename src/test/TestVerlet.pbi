﻿XIncludeFile "../core/Application.pbi"
XIncludeFile "../objects/Verlet.pbi"
Global width = 1024
Global height = 720

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
  ViewportUI::Blit(*viewport, *layer\datas\buffer)

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
     Application::SetContext(*app, *viewport\context)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  Else
    GLContext::Setup(*app\context)
    Define *shader.Program::Program_t = *app\context\shaders("polymesh")
  EndIf
  
  GLContext::SetContext(*app\context)
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
  

  *mesh = Polymesh::New("Bunny", Shape::#SHAPE_BUNNY)
;   Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
;   Topology::Grid(*geom\topo, 10,16,16)
;   PolymeshGeometry::Set2(*mesh\geom, *geom\topo)
  
  If Not #USE_GLFW
    ViewportUI::SetHandleTarget(*viewport, *mesh)
    Application::AddLayer(*app, *layer)
  EndIf
  
  Define *T.Transform::Transform_t = Object3D::GetGlobalTransform(*mesh)
  Object3D::UpdateTransform(*mesh)
  Transform::SetTranslationFromXYZValues(*T, 0,6,0)
  Define q.Math::q4f32
  Quaternion::SetFromAxisAngleValues(q,0,0.2,0.9,0.5)
  Transform::SetRotationFromQuaternion(*T, q)
  Object3D::SetGlobalTransform(*mesh, *T)
  Object3D::FreezeTransform(*mesh)
  
  *drawer = Drawer::New()
  *geom.Geometry::PolymeshGeometry_t = *mesh\geom

  PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
  *verlet = Verlet::New(*mesh\geom,1)
  
  Verlet::RigGeometry(*verlet)
  
;   Object3D::AddChild(*root,*mesh)
  Object3D::AddChild(*root,*drawer)
  
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
 
  Application::Loop(*app, @Draw(),0.1)


  Verlet::Delete(*verlet)
EndIf


; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 79
; FirstLine = 63
; Folding = -
; EnableXP
﻿XIncludeFile "../core/Application.pbi"

UseModule Math



;---------------------------------------------------
; TEST STRUCTURE
;---------------------------------------------------
Structure TestRay_t
  *mesh.Polymesh::Polymesh_t
  *drawer.Drawer::Drawer_t
  start_pos.v3f32
  end_pos.v3f32
  direction.v3f32
  ray.Geometry::Ray_t
  location.Geometry::Location_t
  uvw.v3f32
  dist.f
EndStructure

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *ray.TestRay_t
Global *bunny.Polymesh::Polymesh_t

;---------------------------------------------------
; Constructor
;---------------------------------------------------
Procedure newTestRay(*mesh.Polymesh::Polymesh_t,*start.v3f32,*end.v3f32,*c.c4f32)
  
  Protected *tr.TestRay_t = AllocateMemory(SizeOf(TestRay_t))
  
  *tr\drawer = Drawer::New("Raycast Drawer")
  *tr\drawer\overlay = #True
  ; Ray
  Vector3::SetFromOther(*tr\start_pos, *start)
  Vector3::SetFromOther(*tr\end_pos, *end)
  Vector3::Sub(*tr\direction,*end,*start)
  Vector3::NormalizeInPlace(*tr\direction)
  Ray::Set(*tr\ray, *tr\start_pos, *tr\direction)
  
  ; mesh
  *tr\mesh = *mesh
  *tr\mesh\wireframe_r = 0
  *tr\mesh\wireframe_g = 1
  *tr\mesh\wireframe_b = 0
  Scene::AddChild(Scene::*current_scene, *tr\drawer)
 

  ProcedureReturn *tr
EndProcedure


;---------------------------------------------------
; Set Position
;---------------------------------------------------
Procedure TestRay_SetPosition(*tr.TestRay_t,*pos.v3f32)

  Vector3::SetFromOther(*tr\ray\origin,*pos)
 
EndProcedure

;---------------------------------------------------
; Set Direction
;---------------------------------------------------
Procedure TestRay_SetDirection(*tr.TestRay_t, *dir.v3f32)

  Vector3::SetFromOther(*tr\ray\direction,*dir)
    
EndProcedure


;---------------------------------------------------
; UPDATE
;---------------------------------------------------
Procedure TestRay_Update(*tr.TestRay_t, *viewport.ViewportUI::ViewportUI_t)
  Drawer::Flush(*tr\drawer)
  
  Scene::*current_scene\dirty = #True
  ViewportUI::GetRay(*viewport, *tr\ray)
  Vector3::SetFromOther(*tr\start_pos, *viewport\camera\pos)

  Protected i
  Protected *a.v3f32,*b.v3f32,*c.v3f32
  Define.v3f32 a,b,c
  Protected intersect.b
  Protected *geom.Geometry::PolymeshGeometry_t = *tr\mesh\geom
  Protected *t.Transform::Transform_t = *tr\mesh\globalT
  
  Protected *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()

  CArray::SetCount(*positions, 2)
  CArray::SetValue(*positions,0, *tr\start_pos)
  CArray::SetValue(*positions,1,*tr\end_pos)
  
  Protected *pnts.Drawer::Item_t = Drawer::NewPoints(*tr\drawer, *positions)
  Drawer::SetSize(*pnts, 4)
  Protected color.c4f32
  Color::Set(@color, 1,0,0,1)
  Drawer::SetColor(*pnts, @color)
  
  Protected *line.Drawer::Item_t = Drawer::NewLine(*tr\drawer, *tr\start_pos, *tr\end_pos)
  Drawer::SetSize(*line, 2)
  Color::Set(@color, 0,1,0,1)
  Drawer::SetColor(*line, @color)
  
  Protected q.q4f32
  Protected m3.m3f32
  Protected norm.v3f32
  Protected up.v3f32
  Vector3::Set(@up,1,0,0)
  Protected dist.f = #F32_MAX
 
  
  Define.v3f32 a,b,c
  Define color.c4f32
  Color::Set(@color, 1,0,0,1)

  Protected *pnt.Drawer::Item_t
  Protected *tri.CArray::CarrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*tri, 3)
  Protected frontFacing.b
  
  Protected *red_col.c4f32 = Color::_RED()
  Debug "GEOMETRY NUM TRIANGLE S : "+Str(*geom\nbtriangles)
  For i=0 To *geom\nbtriangles-1
    *a = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, i*3+2))
    *b = Carray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, i*3+1))
    *c = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, i*3))
    
    Vector3::MulByMatrix4(@a,*a,*t\m)
    Vector3::MulByMatrix4(@b,*b,*t\m)
    Vector3::MulByMatrix4(@c,*c,*t\m)
    
    intersect.b = Ray::TriangleIntersection(*tr\ray,@a,@b,@c,@*tr\dist,*tr\uvw, @frontFacing)
    If intersect And *tr\dist<dist
      Debug "INTERSECT TRIANGLE : "+Str(i)
      CArray::SetValue(*tri, 0, @a)
      CArray::SetValue(*tri, 1, @b)
      CArray::SetValue(*tri, 2, @c)
      
      *pnt = Drawer::NewLoop(*tr\drawer, *tri)
      Drawer::SetSize(*pnt, 8)
      Drawer::SetColor(*pnt, Color::_RED())
      
      *tr\location\geometry = *geom
      *tr\location\t = *t
      *tr\location\u = *tr\uvw\x
      *tr\location\v = *tr\uvw\y
      *tr\location\w = *tr\uvw\z
      *tr\location\tid = i
      
      *pnt = Drawer::NewPoint(*tr\drawer, Location::GetPosition(*tr\location))
      Drawer::SetSize(*pnt, 8)
      Color::Set(@color, 1,1,0,1)
      Drawer::SetColor(*pnt, @color)
      
    Else

    EndIf
    
  Next
  
  CArray::Delete(*tri)
  CArray::Delete(*positions)
  
EndProcedure

Procedure AddBunny()
  Define q2.q4f32
  Quaternion::SetFromAxisAngleValues(@q2,0,0,1,Radian(45))
  *bunny = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
  Define *tb.Transform::Transform_t = *bunny\localT
  Transform::SetScaleFromXYZValues(*tb,3,3,3)
  Transform::SetRotationFromQuaternion(*tb, @q2)
  Transform::SetTranslationFromXYZValues(*tb,0.55,1,0)
  
  Scene::AddChild(Scene::*current_scene, *bunny)
  
  Object3D::SetLocalTransform(*bunny, *tb)
  Object3D::UpdateTransform(*bunny)
   
EndProcedure

Procedure AddRay()
  Define.v3f32 sp,ep
  Define.c4f32 color
  
  ;Ray 1
  Vector3::Set(@sp,2,10,0)
  Vector3::Set(@ep,0,0,0)
  
  Color::Set(@color,1,0,0,1)
  *ray = newTestRay(*bunny,@sp,@ep,@color)
EndProcedure



Procedure Draw(*app.Application::Application_t)
  
  ViewportUI::SetContext(*viewport)
  TestRay_Update(*ray, *viewport)
  Scene::Update(Scene::*current_scene)
 
  
  ViewportUI::Draw(*viewport, *app\context)
  ViewportUI::FlipBuffer(*viewport)

 EndProcedure



 Define useJoystick.b = #False
 width = 800
 height = 600
 ; Main
 Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("Test Ray Cast",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
     
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)

  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *layer)
  
  Scene::*current_scene = Scene::New()
  
  AddBunny()
  AddRay()
  
  
  Scene::Setup(Scene::*current_scene,*app\context)
  
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 142
; FirstLine = 118
; Folding = --
; EnableXP
; EnableUnicode
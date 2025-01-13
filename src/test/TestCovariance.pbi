; -----------------------------------------------------------------------------------
; Test Covariance
; -----------------------------------------------------------------------------------

XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit


Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t

Global width.i, height.i
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global *positions.CArray::CArrayV3F32 = CArray::New(Types::#TYPE_V3F32)

; -----------------------------------------------------------------------------------------
; Random Point Cloud
; -----------------------------------------------------------------------------------------
Procedure RandomPointCloud(numPoints.i, *m.m4f32)
  Protected *position.CArray::CArrayV3F32 = CArray::New(Types::#TYPE_V3F32)
  CArray::SetCount(*position, numPoints)
 
  Protected i
  Protected m.v3f32
  Protected *pos.v3f32, dir.v3f32
  For i=0 To numPoints-1
    *pos = CArray::GetValue(*position, i)
    Vector3::Set(*pos, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02)
;     Vector3::Set(dir, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02)
;     Vector3::NormalizeInPlace(@dir)
;     Vector3::Scale(*pos, @dir, Random(100)*0.01)
    Vector3::MulByMatrix4InPlace(*pos, *m)
  Next
  Protected *c.PointCloud::PointCloud_t = PointCloud::New("Datas", Shape::#SHAPE_NONE)
  Protected *g.Geometry::PointCloudGeometry_t = *c\geom
  PointCloudGeometry::AddPoints(*g, *position)
  
  CArray::Delete(*position)
  ProcedureReturn *c 
EndProcedure

; -----------------------------------------------------------------------------------------
; Draw
; -----------------------------------------------------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  GLContext::SetContext(*viewport\context)
  *app\scene\dirty= #True
  
  Scene::Update(*app\scene)
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
  
  Define writer = *viewport\context\writer
  FTGL::BeginDraw(writer)
  FTGL::SetColor(writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(writer,"Testing Covariance",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(writer)
  

  GLContext::FlipBuffer(*viewport\context)

EndProcedure

Structure _AxisSort_t
  axis.i
  det.f
EndStructure

Procedure BestFittingPlane(*drawer.Drawer::Drawer_t, *cloud.PointCloud::PointCloud_t)
  Protected *geom.Geometry::PointCloudGeometry_t = *cloud\geom
  Drawer::Flush(*drawer)
  Drawer::SetSize(*drawer, 4)
  Protected nrm.v3f32, upv.v3f32
  If *geom\nbpoints < 3
    MessageRequester("TestCovariance", "Best Fitting Plane : At least three points required!")
  Else
    Protected sum.v3f32
    Protected *p.v3f32
    Vector3::Set(sum, 0,0,0)
    Protected i.i
    For i=0 To *geom\nbpoints - 1
      *p = CArray::GetValue(*geom\a_positions,i)
      Vector3::AddInPlace(sum, *p)
    Next
    
    Protected inp.f = 1.0/*geom\nbpoints
    Protected centroid.v3f32
    Vector3::Scale(centroid, sum, inp)
    
    Protected *positions.CArray::CArrayV3F32 = CArray::New(Types::#TYPE_V3F32)
    CArray::SetCount(*positions, 1)
    CArray::SetValue(*positions, 0, centroid)
    Protected *point.Drawer::Point_t = Drawer::AddPoint(*drawer, *positions)
    *point\size = 4
    Drawer::SetColor(*point, Color::RED)

    ; calc full 3x3 covariance matrix, excluding symmetries:
    Define xx.f = 0.0
    Define xy.f = 0.0
    Define xz.f = 0.0
    Define yy.f = 0.0
    Define yz.f = 0.0
    Define zz.f = 0.0
    
    Define r.v3f32
    Define *p.v3f32
    For i=0 To *geom\nbpoints - 1
      *p = CArray::GetValue(*geom\a_positions, i)
      Vector3::Sub(r, centroid, *p)
      xx + r\x * r\x
      xy + r\x * r\y
      xz + r\x * r\z
      yy + r\y * r\y
      yz + r\y * r\z
      zz + r\z * r\z
    Next
      
    Protected det_x.f = yy * zz - yz * yz
    Protected det_y.f = xx * zz - xz * xz
    Protected det_z.f = xx * yy - xy * xy

    Protected det_max.f = det_x
    Dim axis._AxisSort_t(3)
    axis(0)\axis = 0
    axis(0)\det = det_x
    axis(1)\axis = 1
    axis(1)\det = det_y
    axis(2)\axis = 2
    axis(2)\det = det_z
    SortStructuredArray(axis(),#PB_Sort_Descending, OffsetOf(_AxisSort_t\det), #PB_Float)
        
    Select axis(0)\axis
      Case 0
        Vector3::Set(nrm, det_x, xz * yz - xy * zz, xy * yz - xz * yy)
      Case 1
        Vector3::Set(nrm, xz * yz - xy * zz, det_y, xy * xz - yz * xx)
      Case 2
        Vector3::Set(nrm, xy * yz - xz * yy, xy * xz - yz * xx, det_z)
    EndSelect
    
    Select axis(1)\axis
      Case 0
        Vector3::Set(upv, det_x, xz * yz - xy * zz, xy * yz - xz * yy)
      Case 1
        Vector3::Set(upv, xz * yz - xy * zz, det_y, xy * xz - yz * xx)
      Case 2
        Vector3::Set(upv, xy * yz - xz * yy, xy * xz - yz * xx, det_z)
    EndSelect
    
      
    Vector3::NormalizeInPlace(nrm)
    Vector3::NormalizeInPlace(upv)
    
    Define side.v3f32
    Vector3::Cross(side, nrm, upv)
    Vector3::NormalizeInPlace(side)
    Vector3::Cross(upv, side, nrm)
    Vector3::NormalizeInPlace(upv)
      
    Protected m.m4f32
    Protected scl.v3f32
    Protected rot.q4f32
    Protected t.Transform::Transform_t
    Vector3::Set(scl, 3,3,3)
    Transform::SetScale(t, scl)
    Quaternion::LookAt(rot, nrm, upv)
    Transform::SetRotationFromQuaternion(t,rot)
    Transform::SetTranslation(t,centroid)
    Transform::UpdateMatrixFromSRT(t)
    
    Matrix4::Echo(t\m, "matrix")

    Protected *matrix.Drawer::Matrix_t = Drawer::AddMatrix(*drawer, t\m)
    *matrix\size = 1

  EndIf
  
EndProcedure

; Main
Globals::Init()
FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   width = 800
   height = 600
   *app = Application::New("Test Covariance",width, height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)   
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  *layer = LayerDefault::New(800,600,*viewport\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
   
  Define *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
  
  Define ctr.v3f32, nrm.v3f32
  Vector3::Set(ctr, 0,4,0)
  Vector3::Set(nrm, 0,1,1)
  
  Define t.Transform::Transform_t
  Define q.q4f32
  Define upv.v3f32
  Vector3::Set(upv, 0,0,1)
  Quaternion::SetIdentity(q)
  Quaternion::LookAt(q, nrm, upv)
  Quaternion::Echo(q,"Q")
  Transform::SetTranslation(t, ctr)
  Transform::SetRotationFromQuaternion(t, q)
  Transform::SetScaleFromXYZValues(t, 2,0.8,1.8)
  
  Transform::UpdateMatrixFromSRT(t)
  
  Define *cloud.PointCloud::PointCloud_t = RandomPointCloud(256, t\m)
  
  PointCloudGeometry::SetSize(*cloud\geom, 5)
  
  Define i
  
  *drawer = Drawer::New("Drawer")
 
  Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root, *drawer)
  Object3D::AddChild(*root, *cloud)
  Scene::AddModel(*app\scene,*root)
  Scene::Setup(*app\scene)
  
  Define nrm.v3f32
  BestFittingPlane(*drawer, *cloud)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 116
; FirstLine = 112
; Folding = -
; EnableXP
; -----------------------------------------------------------------------------------
; Test Polygonizer
; -----------------------------------------------------------------------------------

XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../objects/Polygonizer.pbi"
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
Global *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
Global *polygonizer.Polygonizer::Grid_t
Global *geom.Geometry::PolymeshGeometry_t

Procedure MapWorldPositionToScreenSpace(*view.m4f32, *proj.m4f32, width.i, height.i, *w.v3f32, *s.v2f32)
  Protected w2s.v3f32
  Vector3::MulByMatrix4 (w2s, *w, *view)
  Vector3::MulByMatrix4InPlace(w2s, *proj)
  *s\x = width * (w2s\x + 1.0)/2.0
  *s\y = height * (1.0 - ((w2s\y + 1.0) / 2.0))
EndProcedure

Procedure DrawPolygonizer(*polygonizer.Polygonizer::Grid_t, ss.f, ratio.f)
  Protected numPoints = ArraySize(*polygonizer\points())
  
  Protected world.v3f32
  Protected screen.v2f32
  
;   Protected *view.m4f32 = Layer::GetViewMatrix(*layer)
;   Protected *proj.m4f32 = Layer::GetProjectionMatrix(*layer)
;   Protected i
;   
;   For i=0 To numPoints -1
;     Vector3::Set(@world, *polygonizer\points(i)\p[0], *polygonizer\points(i)\p[1], *polygonizer\points(i)\p[2])
;     MapWorldPositionToScreenSpace(*view, *proj, *viewport\width, *viewport\height, @world, @screen)
;     FTGL::Draw(*app\context\writer,"z",(screen\x * 2)/width - 1,1 - (screen\y * 2) /height,ss,ss*ratio)
;   Next
  
EndProcedure


; -----------------------------------------------------------------------------------------
; Draw
; -----------------------------------------------------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  ViewportUI::SetContext(*viewport)
  Scene::*current_scene\dirty= #True
  Define isolevel.f = Random(100)*0.0
;   Polygonizer::Polygonize(*polygonizer, *geom, isolevel)
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer, *app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  DrawPolygonizer(*polygonizer, ss, ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

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
   *app = Application::New("Test Polygonizer",width, height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI", *app\camera)
     *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
 
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *layer)

  Global *root.Model::Model_t = Model::New("Model")
    
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

  Define *mesh.Polymesh::Polymesh_t = Polymesh::New("BUNNY",Shape::#SHAPE_SPHERE)
  *geom = *mesh\geom
  Object3D::SetShader(*mesh,*s_polymesh)
  Object3D::AddChild(*root, *mesh)
  
  Define box.Geometry::Box_t
  Vector3::Set(box\extend, 12,12,12)

  *polygonizer = Polygonizer::CreateGrid(box, 0.25)

  Polygonizer::Polygonize(*polygonizer, *geom, 0.1)
  
  
  Object3D::Freeze(*mesh)
  
  Scene::AddModel(Scene::*current_scene, *root)
  Scene::Setup(Scene::*current_scene, *app\context)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 136
; FirstLine = 81
; Folding = -
; EnableXP
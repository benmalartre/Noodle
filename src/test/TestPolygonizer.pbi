; -----------------------------------------------------------------------------------
; Test Polygonizer
; -----------------------------------------------------------------------------------

XIncludeFile "../core/Application.pbi"
; XIncludeFile "../libs/FTGL.pbi"
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
Global *positions.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
Global *polygonizer.Polygonizer::Grid_t
Global *mesh.Polymesh::Polymesh_t 
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
;     FTGL::Draw(*viewport\context\writer,"z",(screen\x * 2)/width - 1,1 - (screen\y * 2) /height,ss,ss*ratio)
;   Next
  
EndProcedure


; -----------------------------------------------------------------------------------------
; Draw
; -----------------------------------------------------------------------------------------
Procedure Draw(*app.Application::Application_t)

  GLContext::SetContext(*viewport\context)
  Debug *app
  Debug *viewport\context
  Debug *viewport\context\ID
  *app\scene\dirty= #True
  Define isolevel.f = Random(100)*0.0

;   Polygonizer::Polygonize(*polygonizer, *geom, isolevel)
  Scene::Update(*app\scene)
  LayerDefault::Draw(*layer, *app\scene)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
;   FTGL::BeginDraw(*viewport\context\writer)
;   FTGL::SetColor(*viewport\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*viewport\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
;   DrawPolygonizer(*polygonizer, ss, ratio)
;   FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)
EndProcedure


; Main
Globals::Init()
; FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   width = 800
   height = 600
   *app = Application::New("Test Polygonizer",width, height, options)
   
   
   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
    View::SetContent(*app\window\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
 GLContext::SetContext(*viewport\context)
  *app\scene = Scene::New()
  *layer = LayerDefault::New(800,600,*viewport\context,*app\camera)
  Application::AddLayer(*app, *layer)

  Global *root.Model::Model_t = Model::New("Model")
    
  *s_wireframe = *viewport\context\shaders("simple")
  *s_polymesh = *viewport\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

  *mesh= Polymesh::New("BUNNY",Shape::#SHAPE_SPHERE)
  *geom = *mesh\geom
  Object3D::AddChild(*root, *mesh)
  
  Define box.Geometry::Box_t
  Vector3::Set(box\extend, 12,12,12)

  *polygonizer = Polygonizer::CreateGrid(box, 1.0)

  Polygonizer::Polygonize(*polygonizer, *geom, 0.1)
  PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
  PolymeshGeometry::ComputeIslands(*mesh\geom)
  PolymeshGeometry::RandomColorByIsland(*mesh\geom)
  
  Object3D::Freeze(*mesh)
    
  Scene::AddModel(*app\scene, *root)
  Scene::Setup(*app\scene)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 84
; FirstLine = 64
; Folding = -
; EnableXP
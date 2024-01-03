XIncludeFile "../core/Application.pbi"
EnableExplicit

Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()

Global *app.Application::Application_t = Application::New("Noodle",800,600,#PB_Window_SystemMenu|#PB_Window_SizeGadget)

Global WIDTH = 1024
Global HEIGHT = 1024

UseModule Math

Define *A.Polymesh::Polymesh_t = Polymesh::New("A",Shape::#SHAPE_CUBE)
*app\scene = Scene::New("ActiveScene")

; Define *B.PointCloud::PointCloud_t = PointCloud::New("B",100)
 
CompilerIf Not #USE_GLFW
  Global *main.View::View_t = *app\window\main
  Global *view.View::View_t = View::Split(*main,0,50)
  Global *view2.View::view_t = View::Split(*view\left,#PB_Splitter_Vertical,60)
  Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*view2\left,"ViewportUI", *app\camera, *app\handle)
  
  Global *prop.PropertyUI::PropertyUI_t = PropertyUI::New(*view2\right,"Property",#Null)
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  
  Global *graph.GraphUI::GraphUI_t = GraphUI::New(*view\right,"GraphUI")
  Global *property.PropertyUI::PropertyUI_t = PropertyUI::New(*view\right,"Property",*A)
CompilerEndIf


Global *model.Model::Model_t = Model::New("BOB"); Alembic::LoadABCArchive("../../abc/Skeleton.abc")
Global *meshes.CArray::CArrayPtr = CArray::New(CArray::#ARRAY_PTR)
Object3D::FindChildren(*model,"",Object3D::#Polymesh,*meshes,#True)

Define i
Define *mesh.Object3D::Object3D_t
Define *t.Transform::Transform_t
Define *tree.Tree::Tree_t
Define *node.Node::Node_t
For i=0 To CArray::GetCount(*meshes)-1
  *mesh = CArray::GetValuePtr(*meshes,i)
  *t = *mesh\localT
;   *tree = Tree::New(*mesh,"Alembic")
;   *node = Node::New(*tree,"AlembicNode")
;   Stack::AddNode(*mesh\stack,*tree,0)
;   Transform::SetTranslationFromXYZValues(*t,0,6,0)
  Object3D::SetLocalTransform(*mesh,*t)
  Object3D::UpdateTransform(*mesh,*model\globalT)
  MessageRequester("Alembic Polymesh",*mesh\name)
;   Object3D::Freeze(*mesh)
Next

; Meshes
  ;-----------------------------------------------------
Define pos.v3f32, rot.q4f32
NewList *bunnies.Polymesh::Polymesh_t()

  Define color.v3f32
  Define x,y,z
  For x = 0 To 7
    For y=0 To 3
      For z=0 To 7
        AddElement(*bunnies())
        *bunnies() = Polymesh::New("Bunny",Shape::#SHAPE_TEAPOT)
        Vector3::Set(color,Random(100)*0.005+0.5,Random(100)*0.005+0.5,Random(100)*0.005+0.5)
;         ;Shape::RandomizeColors(*bunnies()\shape,@color,0.0)
        *t = *bunnies()\localT
        Scene::AddChild(*app\scene,*bunnies())
;         Transform::SetTranslationFromXYZValues(*t,x-5,y+0.5,z-5)
;         Object3D::SetLocalTransform(*bunnies(),*t)
;         Object3D::UpdateTransform(*bunnies(),Scene::*current_scene\root\globalT)
; ;         Object3D::Freeze(*bunnies())
      Next
    Next
  Next
; For i=0 To 12
;   Define *l.Light::Light_t = Light::New("Light"+Str(i+1))
;   Define pos.Math::v3f32
;   Vector3::Set(*l\pos,(Random(200)-50)*0.1,(Random(250))*0.1,(Random(250)-50)*0.1)
;   Light::LookAt(*l)
;   *l\linear = 0.2
;   *l\quadratic = 0.05
;   Scene::AddChild(Scene::*current_scene,*l)  
; Next

; *t = *A\localT
; Transform::SetTranslationFromXYZValues(*t,0,0,0)
; Transform::SetScaleFromXYZValues(*t,200,1,200)
; Object3D::AddChild(*model,*A)
; 
;   Object3D::SetLocalTransform(*A,*t)
;   Object3D::UpdateTransform(*A,*model\globalT)
; 
;   Scene::AddModel(Scene::*current_scene,*model)
; Scene::AddChild(Scene::*current_scene,*A)
; Scene::AddChild(Scene::*current_scene,*B)

Scene::Setup(*app\scene)

Global *light.Light::Light_t = CArray::GetValuePtr(*app\scene\lights,0)
Global *default.Layer::Layer_t = LayerDefault::New(800,600,*viewport\context,*light)
LayerDefault::Setup(*default)
GLContext::AddFramebuffer(*viewport\context, *default\framebuffer)

; Global *gbuffer.Layer::Layer_t = LayerGBuffer::New(WIDTH,HEIGHT,*app\context,*app\camera)
; LayerGBuffer::Setup(*gbuffer)
; 
; 
; ; 
; Global *shadowmap.Layer::Layer_t = LayerShadowMap::New(1024,1024,*app\context,*light)
; LayerShadowMap::Setup(*shadowmap)
; 
; Light::Update(*light)
; ; Debug *app\context\shaders("simple2D")  
; Global *defered.Layer::Layer_t = LayerShadowDefered::New(WIDTH,HEIGHT,*app\context,*gbuffer\buffer,*shadowmap\buffer,*app\camera)
; LayerShadowDefered::Setup(*defered)
; Global *shadows.Layer::Layer_t = LayerShadowSimple::New(800,600,*app\context,*shadowmap\buffer,*app\camera)
; LayerShadowSimple::Setup(*shadows)
; 
; Global *bitmap.LayerBitmap::LayerBitmap_t = LayerBitmap::New(WIDTH,HEIGHT,*app\context,*app\camera)
; 
; 
; 
; Global *texture.Texture::Texture_t = Texture::NewFromSource("../../textures/shadowmap.png")
; 
; Global *ssao.LayerSSAO::LayerSSAO_t = LayerSSAO::New(WIDTH/2,HEIGHT/2,*app\context,*gbuffer\buffer,*app\camera)
; LayerSSAO::Setup(*ssao)
; New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
; MessageRequester("ShadowMap Framebuffer",Str(*shadowmap\buffer))
; MessageRequester("IDs",Str(*shadowmap\buffer\tbos(0)\textureID)+","+Str(Framebuffer::GetTex(*shadowmap\buffer,0)))
; *bitmap\bitmap = *texture\tex

Global default_layer.Layer::ILayer = *default
; Global gbuffer.Layer::ILayer = *gbuffer
; Global shadowmap.Layer::ILayer = *shadowmap
; Global defered.Layer::ILayer = *defered
; Global bitmap.Layer::ILayer = *bitmap
; Global ssao.Layer::ILayer = *ssao
; gbuffer\Update()
default_layer\Update()
; shadowmap\Update()

; defered\Update()
; shadows\Update()
; bitmap\Update()
; ssao\Update()
; PropertyUI::Setup(*property,CArray::GetValuePtr(*meshes,0))

Define datas.Control::EventTypeDatas_t
datas\x = 0
datas\y = 0
datas\width = *property\sizX
datas\height = *property\sizY

Define *c.ControlNumber::ControlNumber_t = ControlNumber::New(*A, "Param", 5, ControlNumber::#NUMBER_INTEGER, -50, 50, -10, 10, 0, 0, 80, 18 )

; GraphUI::SetContent(*graph,*tree)
; 
; Global *saver.Saver::Saver_t = Saver::New(Scene::*current_scene,"D:\Projects\RnD\PureBasic\Noodle\scenes\Save_001.scene")
; Saver::Save(*saver)

; Define *args.Arguments::Arguments_t = Arguments::New()
; Arguments::ADD(*args,"Parent",*A)
; Arguments::AddLong(*args,"Shape",Shape::#SHAPE_CUBE)
; CreatePolymeshCmd::Do(*args)


Procedure Update(*app.Application::Application_t)
  Scene::Update(*app\scene)
  default_layer\Draw  (*app\scene, *viewport\context)
;   gbuffer\Draw(*app\context  )
;   shadowmap\Draw(*app\context)
  
;   *shadows\texture = Framebuffer::GetTex(*shadowmap\buffer,0)

;   defered\Draw(*app\context)
;   *bitmap\bitmap = Framebuffer::GetTex(*defered\buffer,0)
;   bitmap\Draw(*app\context)
;   ssao\Draw(*app\context)
;   FTGL::BeginDraw(*app\context\writer)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/*app\width
;   Define ratio.f = *app\width / *app\height
;   FTGL::Draw(*app\context\writer,"Shadow Mapping Demo",-0.9,0.9,ss,ss*ratio)
;   FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
;   FTGL::EndDraw(*app\context\writer)
  
;   ViewportUI::FlipBuffer(*viewport)
EndProcedure


Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 175
; FirstLine = 125
; Folding = -
; EnableXP
;#USE_GLFW = #False
XIncludeFile "../core/Application.pbi"
Procedure ErrorHandler()
  MessageRequester("OnError test", "The following error happened: " + ErrorMessage()+Chr(10)+ErrorLine()+Chr(10)+ErrorFile())
EndProcedure

;OnErrorCall(@ErrorHandler())

EnableExplicit
UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Global WIDTH = 1200
Global HEIGHT = 600


Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()
CompilerIf #USE_ALEMBIC
  Alembic::Init()
CompilerEndIf

Procedure AddEmptyTree(*tree.Tree::Tree_t)
  Protected *r.Node::Node_t = *tree\root

  *r\posx = 800
  *r\posy = 200
EndProcedure

Procedure AddPushTree(*tree.Tree::Tree_t)
  Protected *r.Node::Node_t = *tree\root
  Protected *g1.Node::Node_t = Tree::AddNode(*tree,"GetDataNode",0,0,100,20,RGB(160,160,160))
  Protected *g2.Node::Node_t = Tree::AddNode(*tree,"GetDataNode",0,120,100,20,RGB(160,160,160))
  Protected *m.Node::Node_t = Tree::AddNode(*tree,"MultiplyByScalarNode",200,30,100,20,RGB(160,160,160))
  Protected *a.Node::Node_t = Tree::AddNode(*tree,"AddNode",400,30,100,20,RGB(160,160,160))
  Protected *s.Node::Node_t = Tree::AddNode(*tree,"SetDataNode",600,30,100,20,RGB(160,160,160))
  
  LastElement(*g1\inputs())
  NodePort::SetReference(*g1\inputs(),"Self.PointPosition")
  LastElement(*g2\inputs())
  NodePort::SetReference(*g2\inputs(),"Self.PointNormal")
  LastElement(*s\inputs())
  NodePort::SetReference(*s\Inputs(),"Self.PointPosition")
  

  FirstElement(*M\inputs())
  Tree::ConnectNodes(*tree,*tree\root,*g2\outputs(),*m\inputs(),#False)
  FirstElement(*a \inputs())
  Tree::ConnectNodes(*tree,*tree\root,*g1\outputs(),*a\inputs(),#False)
  SelectElement(*a\inputs(),1)
  Tree::ConnectNodes(*tree,*tree\root,*m\outputs(),*a\inputs(),#False)
  FirstElement(*s\inputs())
  Tree::ConnectNodes(*tree,*tree\root,*a\outputs(),*s\inputs(),#False)
  FirstElement(*r\inputs())
  Tree::ConnectNodes(*tree,*tree\root,*s\outputs(),*r\inputs(),#False)
  
  *r\posx = 800
  *r\posy = 200
EndProcedure

Procedure AddAudioTree(*tree.Tree::Tree_t)
  Protected *r.Node::Node_t = *tree\root
  Protected *dac.Node::Node_t = Tree::AddNode(*tree,"AudioDACNode",0,0,100,20,RGB(160,160,160))
  Protected *sine.Node::Node_t = Tree::AddNode(*tree,"AudioSineWaveNode",0,0,120,30,RGB(160,160,160))
  
;   SelectElement(*r\inputs(), 1)
;   Tree::ConnectNodes(*tree,*tree\root,*dac\outputs(),*r\inputs(),#False)
;   SelectElement(*dac\inputs(), 1)
;   Tree::ConnectNodes(*tree,*tree\root,*sine\outputs(),*dac\inputs(),#False)
;   Protected *g2.Node::Node_t = Tree::AddNode(*tree,"GetDataNode",0,120,100,20,RGB(160,160,160))
;   Protected *m.Node::Node_t = Tree::AddNode(*tree,"MultiplyByScalarNode",200,30,100,20,RGB(160,160,160))
;   Protected *a.Node::Node_t = Tree::AddNode(*tree,"AddNode",400,30,100,20,RGB(160,160,160))
;   Protected *s.Node::Node_t = Tree::AddNode(*tree,"SetDataNode",600,30,100,20,RGB(160,160,160))
  
;   LastElement(*g1\inputs())
;   NodePort::SetReference(*g1\inputs(),"Self.PointPosition")
;   LastElement(*g2\inputs())
;   NodePort::SetReference(*g2\inputs(),"Self.PointNormal")
;   LastElement(*s\inputs())
;   NodePort::SetReference(*s\Inputs(),"Self.PointPosition")
;   
; 
;   FirstElement(*M\inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*g2\outputs(),*m\inputs(),#False)
;   FirstElement(*a \inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*g1\outputs(),*a\inputs(),#False)
;   SelectElement(*a\inputs(),1)
;   Tree::ConnectNodes(*tree,*tree\root,*m\outputs(),*a\inputs(),#False)
;   FirstElement(*s\inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*a\outputs(),*s\inputs(),#False)
;   FirstElement(*r\inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*s\outputs(),*r\inputs(),#False)
  
  *r\posx = 800
  *r\posy = 200
EndProcedure

Scene::*current_scene = Scene::New()
Define *teapot.Object3D::Object3D_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
Define *obj.Object3D::Object3D_t = Polymesh::New("Sphere",Shape::#SHAPE_SPHERE)
; Define *teapot.Object3D::Object3D_t = Polymesh::New("Sphere",Shape::#SHAPE_TEAPOT)
; 
; PolymeshGeometry::SetFromOther(*obj\geom,*teapot\geom)
; Object3D::Freeze(*obj)

; Define *topo.Geometry::Topology_t = Topology::New()
; PolymeshGeometry::SphereTopology(*topo,1,10,10)
; PolymeshGeometry::Set2(*obj\geom,*topo)
; 
; PolymeshGeometry::GridTopology(*topo,1,10,10)
; PolymeshGeometry::Set2(*obj\geom,*topo)

Log::Message("Hello User : Beginning session "+FormatDate("%hh:%ii:%ss", Date()))

Global *tree.Tree::Tree_t = Tree::New(*obj,"Tree",Graph::#Graph_Context_Operator)

;AddEmptyTree(*tree)
; AddPushTree(*tree)
;   AddAudioTree(*tree)

Scene::AddChild(Scene::*current_scene,*obj)
Scene::AddChild(Scene::*current_scene,*teapot)

Define *app.Application::Application_t = Application::New("Graph Test",1200,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_Maximize)
UIColor::SetTheme(UIColor::#DARK_THEME)
Define *window.Window::Window_t = *app\window
Global *main.View::View_t = *window\main
Global *view.View::View_t = View::Split(*main,0,50)
Global *top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)
Global *middle.View::View_t = View::Split(*top\right,#PB_Splitter_Vertical,60)
Global *center.View::View_t = View::Split(*middle\left,#PB_Splitter_Vertical,30)
Global *bottom.View::View_t = View::Split(*view\right,#PB_Splitter_SecondFixed,60)


Global *menu.MenuUI::MenuUI_t = MenuUI::New(*top\left,"Menu")
Global *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*center\left,"Explorer")
ExplorerUI::Connect(*explorer, Scene::*current_scene)

Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*center\right,"Viewport3D", *app\camera, *app\handle)
*app\context = *viewport\context
ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)

Global *property.PropertyUI::PropertyUI_t = PropertyUI::New(*middle\right,"Property",#Null)

Global *graph.UI::IUI = GraphUI::New(*bottom\left,"Graph")
GraphUI::SetContent(*graph,*tree)
; ; ; Global *log.UI::IUI = LogUI::New(*bottom\right,"LogUI")
Global *timeline.UI::IUI = TimelineUI::New(*bottom\right,"Timeline")


GLContext::SetContext(*app\context)
;ControlExplorer::Fill(*explorer\explorer,Scene::*current_scene)
Global *layer.Layer::Layer_t = LayerDefault::New(WIDTH,HEIGHT,*app\context,*app\camera)
Application::AddLayer(*app, *layer)

Scene::Setup(Scene::*current_scene,*app\context)
Window::OnEvent(*app\window, Globals::#EVENT_NEW_SCENE)
Window::OnEvent(*app\window, #PB_Event_SizeWindow)

Scene::SelectObject(Scene::*current_scene, *teapot)
;ViewportUI::SetHandleTarget(*viewport, *teapot)

Procedure Update(*app.Application::Application_t)
  GLContext::SetContext(*app\context)
  
  Scene::Update(Scene::*current_scene)
  Application::Draw(*app, *layer, *viewport\camera)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Graph Tree",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Nb Objects : "+Str(Scene::GetNbObjects(Scene::*current_scene)),-0.9,0.7,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  

  GLContext::FlipBuffer(*app\context)
EndProcedure


Define e.i

Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 129
; FirstLine = 89
; Folding = --
; EnableXP
; Executable = glslsandbox.exe
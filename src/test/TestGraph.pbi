;#USE_GLFW = #False
XIncludeFile "../core/Application.pbi"
Procedure ErrorHandler()
  MessageRequester("OnError test", "The following error happened: " + ErrorMessage()+Chr(10)+ErrorLine()+Chr(10)+ErrorFile())
EndProcedure

OnErrorCall(@ErrorHandler())

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
Controls::Init()
Commands::Init()
UIColor::Init()
CompilerIf #USE_ALEMBIC
  Alembic::Init()
CompilerEndIf



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

Scene::*current_scene = Scene::New()
Define *obj.Object3D::Object3D_t = Polymesh::New("Sphere",Shape::#SHAPE_CYLINDER)
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

AddPushTree(*tree)


Scene::AddChild(Scene::*current_scene,*obj)

Define *app.Application::Application_t = Application::New("Graph Test",1200,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_Maximize)

Define *m.ViewManager::ViewManager_t = *app\manager
Global *main.View::View_t = *m\main
Global *view.View::View_t = View::Split(*main,0,50)
Global *top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)

Global *middle.View::View_t = View::Split(*top\right,#PB_Splitter_Vertical,60)
Global *center.View::View_t = View::Split(*middle\left,#PB_Splitter_Vertical,30)
Global *bottom.View::View_t = View::Split(*view\right,#PB_Splitter_SecondFixed,60)

Global *topmenu.TopMenuUI::TopMenuUI_t = TopMenuUI::New(*top\left,"TopMenu")
Global *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*center\left,"Explorer")
Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*center\right,"Viewport3D")
*app\context = *viewport\context
*viewport\camera = *app\camera
ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)


Global *property.PropertyUI::PropertyUI_t = PropertyUI::New(*middle\right,"Property",#Null)

Global *graph.UI::IUI = GraphUI::New(*bottom\left,"Graph")
; ; Global *log.UI::IUI = LogUI::New(*bottom\right,"LogUI")
Global *timeline.UI::IUI = TimelineUI::New(*bottom\right,"Timeline")

;View::SetContent(*s1\right,*graph)
GraphUI::SetContent(*graph,*tree)
ControlExplorer::Fill(*explorer\explorer,Scene::*current_scene)

Global *layer.Layer::ILayer = LayerDefault::New(WIDTH,HEIGHT,*app\context,*app\camera)
ViewportUI::AddLayer(*viewport, *layer)

Scene::Setup(Scene::*current_scene,*app\context)

ViewManager::OnEvent(*app\manager, #PB_Event_SizeWindow)

Procedure Update(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  
    If EventGadget() = *viewport\gadgetID
    Select EventType()
      Case #PB_EventType_KeyDown
        Protected key = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_Key)
        If key = #PB_Shortcut_Space
          Scene::Update(Scene::*current_scene)
;           Tree::Evaluate(*tree)
;           Scene::Setup(Scene::*current_scene,*app\context)
;           Scene::Update(Scene::*current_scene)
        EndIf
    EndSelect
  EndIf
  
  *layer\Draw( *app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Graph Tree",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Nb Objects : "+Str(Scene::GetNbObjects(Scene::*current_scene)),-0.9,0.7,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  CompilerIf Not #USE_GLFW
    ViewportUI::FlipBuffer(*viewport)
  CompilerEndIf
  

EndProcedure


Define e.i
Controls::SetTheme(Globals::#GUI_THEME_DARK)
Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 112
; FirstLine = 102
; Folding = -
; EnableXP
; Executable = glslsandbox.exe
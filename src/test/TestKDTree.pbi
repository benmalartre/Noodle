

XIncludeFile "../core/Application.pbi"
XIncludeFile "../objects/KDTree.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt
UseModule Shape

EnableExplicit

Global *camera.Camera::Camera_t = #Null
Global *app.Application::Application_t
Global *drawer.Drawer::Drawer_t
Global *viewport.ViewportUI::ViewportUI_t
Global *layer.LayerDefault::LayerDefault_t
Global *kdtree.KDTree::KDTree_t
Global nbp.i
Global TBuild.d, TSearch.d
Global query.KDTree::KDPoint_t
Global search.KDTree::KDSearch_t
Global *query_display.Drawer::Sphere_t
Global *search_display.Drawer::Box_t
Global TSearchKDTree.d
Global TSearchBruteForce.d

; Push Color Array
;--------------------------------------------
Procedure PushColorArray(*node.KDTree::KDNode_t,*mem)
  If Not *node : ProcedureReturn *mem : EndIf
  
  If *node\left : PushColorArray(*node\left,*mem) : EndIf
  If *node\right : PushColorArray(*node\right,*mem) : EndIf
  
  Protected *pnt.KDTree::KDPoint_t
  If *node\indices() And ListSize(*node\indices())
    ForEach *node\indices()
      *pnt = *mem + *node\indices() * SizeOf(Math::v3f32)
      *pnt\v[0] = *node\r
      *pnt\v[1] = *node\g
      *pnt\v[2] = *node\b
    Next
  EndIf
  ProcedureReturn *mem
EndProcedure

; Build Color Array
;--------------------------------------------
Procedure BuildColorArray(*tree.KDTree::KDTree_t,*mem)
  *mem = PushColorArray(*tree\root,*mem)
  ProcedureReturn *mem
EndProcedure

; Build Color Array
;--------------------------------------------
Procedure BuildQueryColorArray()
  Protected *mem = AllocateMemory(Shape::#POINT_NUM_VERTICES*4)
  Protected i,j
  Protected nbs = Shape::#POINT_NUM_VERTICES/3
  Protected *pnt.KDTree::KDPoint_t
  For i=0 To nbs-1
    *pnt = *mem+i* SizeOf(Math::v3f32)
    j=i/nbs
    Select j%3
      Case 0
        *pnt\v[0]=1
        *pnt\v[1]=0
        *pnt\v[2]=0
      Case 1
        *pnt\v[0]=0
        *pnt\v[1]=1
        *pnt\v[2]=0
      Case 2
        *pnt\v[0]=0
        *pnt\v[1]=0
        *pnt\v[2]=1
    EndSelect
  Next
  ProcedureReturn *mem
EndProcedure

; Build Position Array
;--------------------------------------------
Procedure BuildPositionAndColorArray(*tree.KDTree::KDTree_t,*mem)
  Protected i
  Protected *pnt.KDTree::KDPoint_t
  For i=0 To *tree\m_nbp-1
    *pnt = *mem+i*SizeOf(KDTree::KDPoint_t)
    *pnt\v[0] = Random(100)*0.05
    *pnt\v[1] = Random(100)*0.05
    *pnt\v[2] = Random(100)*0.05
    Color::Randomize(*pnt\color)
  Next
EndProcedure

; Resize
;--------------------------------------------
Procedure Resize(window,gadget,*camera.Camera::Camera_t)
  Protected width = WindowWidth(window,#PB_Window_InnerCoordinate)
  Protected height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
  Protected aspect.f = width/height
  Camera::SetDescription(*camera,#PB_Ignore,aspect,#PB_Ignore,#PB_Ignore)
  Camera::UpdateProjection(*camera)
EndProcedure

; DrawKDNode
;--------------------------------------------
Procedure DrawKDNode(*tree.KDTree::KDTree_t,*node.KDTree::KDNode_t)
  If *node\left
    DrawKDNode(*tree,*node\left)
    DrawKDNode(*tree,*node\right)
  Else
;     If *node\hit
      Protected m.m4f32
      Matrix4::SetIdentity(m)
      Protected min.v3f32,max.v3f32, c.v3f32,s.v3f32
      KDTree::GetBoundingBox(*tree,*node,min,max)
      Vector3::Sub(s,max,min)
  ;     Vector3::ScaleInPlace(@s,0.5)
      Vector3::LinearInterpolate(c,min,max,0.5)
      
      Matrix4::SetScale(m,s)
      Matrix4::SetTranslation(m,c)
      
      Define *box.Drawer::Box_t = Drawer::AddBox(*drawer, m)
      Define color.c4f32
      If *node\hit
        Color::Set(color, 1,1,1, 1)
      Else
        Color::Set(color, *node\r,*node\g,*node\b, 1)
      EndIf
      
      Drawer::SetColor(*box, color)
;     EndIf
  EndIf
EndProcedure

; DrawPoints
;--------------------------------------------
Procedure DrawKDPoints(*tree.KDTree::KDTree_t)
  Protected *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  Protected *colors.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
  
  CArray::SetCount(*positions, *tree\m_nbp)
  CArray::SetCount(*colors, *tree\m_nbp)
  Protected i
  Protected *p.v3f32
  Protected *c.c4f32
  
  For i=0 To *tree\m_nbp - 1
    *p = CArray::GetValue(*positions, i)
    *c = CArray::GetValue(*colors, i)
    Vector3::Set(*p, *tree\points(i)\v[0], *tree\points(i)\v[1], *tree\points(i)\v[2])
    Color::SetFromOther(*c, *tree\points(i)\color)
  Next
  
;   CopyMemory(*tree\points(0), CArray::GetPtr(*positions, 0), *tree\m_nbp * SizeOf(KDTree::KDPoint_t))
  Protected *PNT.Drawer::Point_t = Drawer::AddColoredPoints(*drawer, *positions, *colors)
  Drawer::SetSize(*PNT, 4)
  CArray::Delete(*positions)
  CArray::Delete(*colors)
EndProcedure

; DrawQuery
;--------------------------------------------
Procedure DrawKDQuery(*tree.KDTree::KDTree_t)
  Define m.m4f32
  Matrix4::SetIdentity(m)
  Define p.v3f32
  Define s.v3f32
  Vector3::Set(s,0.1,0.1,0.1)
  Vector3::Set(p, query\v[0], query\v[1], query\v[2])
  Matrix4::SetScale(m, s)
  Matrix4::SetTranslation(m, p)
  *query_display = Drawer::AddSphere(*drawer, m)
  Drawer::SetColor(*query_display, Color::_GREEN())
EndProcedure


; DrawSearch
;--------------------------------------------
Procedure DrawKDSearch(*tree.KDTree::KDTree_t)
  Define m.m4f32
  Matrix4::SetIdentity(m)
  Define p.v3f32
  Define s.v3f32
  Define*pnt.KDTree::KDPoint_t = *tree\points(search\ID)
  Vector3::Set(s,0.04,0.04,0.04)
  Vector3::Set(p, *pnt\v[0], *pnt\v[1], *pnt\v[2])
  Matrix4::SetScale(m, s)
  Matrix4::SetTranslation(m, p)
  *search_display = Drawer::AddBox(*drawer, m)
  Drawer::SetColor(*search_display, Color::_RED())
  Drawer::SetWireframe(*search_display, #False)
EndProcedure

; BruteClosest
;--------------------------------------------
Procedure BruteClosest(*tree.KDTree::KDTree_t)

  Define p.v3f32
  Define o.v3f32
  Define s.v3f32
  Define delta.v3f32
  Define m.m4f32
 
  Define i 
  Define dist.f
  Define closestDist.f = Math::#F32_MAX
  Define *pnt.KDTree::KDPoint_t
  Define closestIndex = -1
  Vector3::Set(p, query\v[0], query\v[1], query\v[2])
  Define T.d = Time::get()
  For i=0 To *tree\m_nbp - 1
    *pnt = *tree\points(i)
    Vector3::Set(o, *pnt\v[0], *pnt\v[1], *pnt\v[2])
    Vector3::Sub(delta, p, o)

    dist = Vector3::LengthSquared(delta)
    
    If dist < closestDist
      closestDist = dist
      closestIndex = i
    EndIf
  Next
  TSearchBruteForce = Time::get() - T
  If closestIndex >=0
    Define*pnt.KDTree::KDPoint_t = *tree\points(closestIndex)
    Matrix4::SetIdentity(m)
    Vector3::Set(s,0.05,0.05,0.05)
    Vector3::Set(p, *pnt\v[0], *pnt\v[1], *pnt\v[2])
    Matrix4::SetScale(m, s)
    Matrix4::SetTranslation(m, p)
    Define X = Drawer::AddSphere(*drawer, m)
    Drawer::SetColor(X, Color::_BLUE())
    Drawer::SetWireframe(X, #True)
  EndIf
  
EndProcedure


; DrawKDTree
;--------------------------------------------
Procedure DrawKDTree(*tree.KDTree::KDTree_t)
   DrawKDNode(*tree,*tree\root)
EndProcedure

; View Event
;--------------------------------------------
 Procedure OpenGLViewEvent(gadget,*query.KDTree::KDPoint_t)
   Define.f mx,my
   Define deltax.d, deltay.d
   If EventGadget() = gadget
     Select EventType()
         
       Case #PB_EventType_KeyDown
        Select GetGadgetAttribute(gadget,#PB_OpenGL_Key)
          Case #PB_Shortcut_Left
            *query\v[0]-0.1
          Case #PB_Shortcut_Right
            *query\v[0]+0.1
          Case #PB_Shortcut_Up
            *query\v[2]-0.1
          Case #PB_Shortcut_Down
            *query\v[2]+0.1
          Case #PB_Shortcut_PageUp
            *query\v[1]+0.1
          Case #PB_Shortcut_PageDown
            *query\v[1]-0.1
        EndSelect
    EndSelect
  EndIf
  Define p.v3f32
  Vector3::Set(p, *query\v[0], *query\v[1], *query\v[2])
  Matrix4::SetTranslation(*query_display\m, p)
EndProcedure

; Update
;--------------------------------------------
Procedure KDTreeUpdate()
  OpenGLViewEvent(*viewport\gadgetID, query)
  Define retID.i
  Define retDist.f
  
  Define max_distance = 1
  Define max_points = 4
  
  KDTree::ResetHit(*kdtree)
  Define T.d = Time::Get()
  KDTree::Search(*kdtree,query,search)
  TSearchKDTree = Time::Get() - T
  KDTree::SearchN(*kdtree, @query,@max_distance,max_points)
  Drawer::Flush(*drawer)
;   
; ;   DrawKDTree(*kdtree)
;   DrawKDPoints(*kdtree)
;   DrawKDSearch(*kdtree)
;   DrawKDQuery(*kdtree)
;   
  BruteClosest(*kdtree)

  
  ViewportUI::SetContext(*viewport)
  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
;   Define numCells.l
;   Octree::NumCells(*octree, @numCells)
  LayerDefault::Draw(*layer, *app\context)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*viewport\width
  Define ratio.f = *viewport\width / *viewport\height
  FTGL::Draw(*app\context\writer,"OCTREE : ",-0.9,1,ss,ss*ratio)
  FTGL::SetColor(*app\context\writer,0,0,0,1)
  FTGL::Draw(*app\context\writer,"Nb points : "+Str(nbp),-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Nb queries : "+Str(*kdtree\m_cmps),-0.9,0.85,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Time to Build KDTree : "+StrD(TBuild),-0.9,0.75,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Time to Search BruteForce : "+StrD(TSearchBruteForce),-0.9,0.7,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Time to Search Accelerated : "+StrD(TSearchKDTree),-0.9,0.6,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)
EndProcedure

; --------------------------------------------
;   Main
; --------------------------------------------
If Time::Init()
  Log::Init()
  FTGL::Init()

  *app = Application::New("KDTree",800, 800, #PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_SizeGadget)
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
    *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  *drawer = Drawer::New("KDTree_Visualizer")
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,800,*app\context,*app\camera)
  viewportUI::AddLayer(*viewport, *layer)
  Global *root.Model::Model_t = Model::New("Model")
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene, *root)
  
  nbp = 1000000
  Define pnt.KDTree::KDPoint_t
  Define *pnt.KDTree::KDPoint_t
  Define *col.KDTree::KDPoint_t
  Define i
    
  Define *pnts = AllocateMemory(nbp * SizeOf(KDTree::KDPoint_t))
  
  *kdtree = KDTree::New()
  *kdtree\m_nbp = nbp
  BuildPositionAndColorArray(*kdtree,*pnts)
  
  Define T.d = Time::Get()
  KDTree::Build(*kdtree,*pnts,nbp,12,4)
  
  TBuild.d = Time::Get()
 
  query\v[0] = 0
  query\v[1] = 0
  query\v[2] = 0
  KDTree::Search(*kdtree,query,search)
  
  Define result.s
  result = "Closest Point ID : "+Str(search\ID)+"\n"
  result + "Closest Distance : "+StrF(search\distance)+"\n"
;   result + "Num Queries : "+Str(*tree\m_cmps)+"\n"
  MessageRequester("KDTree",result)
  Define.KDTree::KDPoint_t min,max
;   KDTree::GetBoundingBox(*tree,,@min,@max)
;   DrawKDTree(*kdtree)
  DrawKDPoints(*kdtree)
  DrawKDQuery(*kdtree)
  DrawKDSearch(*kdtree)
;   
  Scene::Setup(Scene::*current_scene, *app\context)
  Application::Loop(*app, @KDTreeUpdate())

  KDTree::Delete(*kdtree)
  
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 300
; FirstLine = 283
; Folding = ---
; EnableXP
; Executable = kdtree.exe
; Debugger = Standalone
; EnableUnicode
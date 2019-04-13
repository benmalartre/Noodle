XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Tree.pbi"
XIncludeFile "../graph/Search.pbi"
XIncludeFile "../controls/Menu.pbi"
XIncludeFile "../controls/Popup.pbi"
XIncludeFile "PropertyUI.pbi"
XIncludeFile "View.pbi"

; ============================================================================
; GRAPHUI MODULE DECLARATION
; ============================================================================
DeclareModule GraphUI
  UseModule UI
  ;---------------------------------------------------------------------------
  ;  Global
  ;---------------------------------------------------------------------------
  Global graph_font_node
  Global graph_font_port
  
  ;---------------------------------------------------------------------------
  ;  INTERFACE
  ;---------------------------------------------------------------------------
  Interface IGraphUI Extends IUI
  EndInterface

  ;---------------------------------------------------------------------------
  ;  STRUCTURE
  ;---------------------------------------------------------------------------
  Structure GraphUI_t Extends UI_t
    ; Fonts
    font_node.i
    font_port.i
    font_debug.i
    
    ; Expended
    l_expended.b
    r_expended.b
    
    ; Mouse Handling
    mouseX.i           ; Current Mouse X
    mouseY.i           ; Current Mouse Y
    
    ; Translate and Scale
    canvasX.i          ; canvas position X
    canvasY.i          ; canvas position Y
    realX.i
    realY.i
  
    rectX1.i           ; Selection Rectangle LeftUpCornerX
    rectY1.i           ; Selection Rectangle LeftUpCornerY
    rectX2.i           ; Selection Rectangle RightBottomCornerX
    rectY2.i           ; Selection Rectangle RightBottomCornerY
  
    ; States
    pan.b              ; Panning
    drag.b             ; Dragging
    pick.b             ; Selecting
    connect.b
    redraw.b           ; Should Canvas be Redrawn
    depth.i            ; Current Depth inside the tree
    keydown.i          ; Previous Key Down
    
    ; Objects
    focusID.i
    *focus.Node::Node_t
    *connecter.Connexion::Connexion_t
    
    ; Tree
    *tree.Tree::Tree_t
    
    ; Visible Nodes
    List *a_visible.Node::Node_t()
    *a_selected.CArray::CArrayPtr
    
  EndStructure
  
  ;---------------------------------------------------------------------------
  ;  FORWARD DECLARATION
  ;---------------------------------------------------------------------------
  Declare New(*parent.View::View_t,name.s="GraphUI")
  Declare Delete(*Me.GraphUI_t)
  Declare Init(*Me.GraphUI_t)
  Declare OnEvent(*Me.GraphUI_t,event.i)
  Declare Term(*Me.GraphUI_t)
  
  Declare Resize(*Me.GraphUI_t)
  Declare NodeInfos(*Me.GraphUI_t)
  Declare DeleteSelected(*Me.GraphUI_t)
  Declare InspectNode(*Me.GraphUI_t,*node.Node::Node_t)
  Declare SetContent(*Me.GraphUI_t,*tree.Tree::Tree_t)
  Declare MousePosition(*Me.GraphUI_t,x.i,y.i)
  Declare.b IsNodeVisible(*Me.GraphUI_t,*n.Node::Node_t)
  Declare NodeInfos(*Me.GraphUI_t)
  Declare AddInputPort(*args.CArray::CArrayPtr)
  Declare PopUpMenu(*Me.GraphUI_t)
  Declare ChangePortName(*Me.GraphUI_t,x.i,y.i)
  Declare DeleteSelected(*Me.GraphUI_t)
  Declare StartConnecter(*Me.GraphUI_t,compound.b=#False)
  Declare TerminateConnecter(*Me.GraphUI_t)
  Declare Background(*Me.GraphUI_t)
  Declare DrawCompound(*Me.GraphUI_t)
  Declare DrawAllNodes(*Me.GraphUI_t)
  Declare GetNodeUnderMouse(*Me.GraphUI_t,x.i,y.i)
  Declare Selection(*Me.GraphUI_t,x.i,y.i,connect.b=#False)
  Declare SelectRecurse(*Me.GraphUI_t,*n.Node::Node_t)
  Declare SelectBranch(*Me.GraphUI_t,*n.Node::Node_t)
  Declare RectangleSelect(*Me.GraphUI_t)
  Declare Reset(*Me.GraphUI_t)
  Declare FrameAll(*Me.GraphUI_t)
  Declare FrameSelected(*Me.GraphUI_t)
  Declare ActivatePan(*Me.GraphUI_t)
  Declare CanvasEvent(*Me.GraphUI_t,eventID.i)
  Declare SwitchContext(*Me.GraphUI_t,*args.CArray::CArrayPtr)
  
  DataSection 
    GraphUIVT: 
    Data.i @Init()
    Data.i @OnEvent()
    Data.i @Term()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule



; ===========================================================================
;  GRAPHUI MODULE IMPLEMENTATION
; ===========================================================================
Module GraphUI
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  ;---------------------------------------------------------------------------
  ; Constructor
  ;---------------------------------------------------------------------------
  Procedure New(*parent.View::View_t,name.s="GraphUI")
    Protected *Me.GraphUI_t = AllocateMemory(SizeOf(GraphUI_t))
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
    
    InitializeStructure(*Me,GraphUI_t)
    Object::INI(GraphUI)
    *Me\name = name
    *Me\parent = *parent
    *Me\container = ContainerGadget(#PB_Any,x,y,w,h)

    *Me\gadgetID = CanvasGadget(#PB_Any,0,0,w,h,#PB_Canvas_Keyboard) 
    EnableGadgetDrop(*Me\gadgetID,#PB_Drop_Text,#PB_Drag_Copy)
    
    *Me\sizX = w
    *Me\sizY = h

    *Me\type = UI::#UI_GRAPH
    
    *Me\drag = #False
    *Me\redraw = #True
    *Me\connect = #False
    *Me\a_selected = CArray::newCArrayPtr()
   
    *Me\font_debug = LoadFont(#PB_Any,"Tahoma",10)
    
    CloseGadgetList()

    ; Init
    *Me\dirty = #True
    *Me\zoom = 1.0
    *Me\dirty = #True
    *Me\redraw = #True
    CanvasEvent(*Me,#PB_Event_SizeWindow)
    View::SetContent(*parent,*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Destructor
  ;---------------------------------------------------------------------------
  Procedure Delete(*Me.GraphUI_t)
    If IsGadget(*Me\gadgetID) : FreeGadget(*Me\gadgetID):EndIf
    If IsGadget(*Me\container) : FreeGadget(*Me\container):EndIf
    Object::TERM(GraphUI)
  EndProcedure

  ;---------------------------------------------------------------------------
  ; Init
  ;---------------------------------------------------------------------------
  Procedure Init(*Me.GraphUI_t)
    Debug "ViewportUI Init Called!!!"
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; OnEvent
  ;---------------------------------------------------------------------------
  Procedure OnEvent(*Me.GraphUI_t,event.i)
    Protected Me.IGraphUI = *Me
    
    Select event
      Case #PB_Event_Menu
        Select EventMenu()
          Case Globals::#SHORTCUT_COPY
            Debug "[ViewGraph] Copy Event"
            ; TO BE IMPLEMENTED
          Case Globals::#SHORTCUT_PASTE
            Debug "[ViewGraph] Paste Event"
            ; TO BE IMPLEMENTED
          Case Globals::#SHORTCUT_CUT
            Debug "[ViewGraph] Cut Event"
          Case Globals::#SHORTCUT_DELETE
            Debug "[ViewGraph] Delete Event"
            GraphUI::DeleteSelected(*Me)
            
          Case Globals::#SHORTCUT_NEXT
            Debug "[ViewGraph] Next Event"
          Case Globals::#SHORTCUT_PREVIOUS
            Debug "[ViewGraph] Previous Event"
          Case Globals::#SHORTCUT_TAB
            Protected windowID = EventWindow()
            Protected mx = WindowX(windowID) + WindowMouseX(windowID)
            Protected my = WindowY(windowID) + WindowMouseY(windowID)
            Define *search.NodeSearch::NodeSearch_t = NodeSearch::New(EventWindow(), mx, my)
            NodeSearch::Update(*search)
            If *search\selected

              ; Add Node
              Tree::AddNode(*Me\tree,*search\selected\name,*Me\mouseX - *Me\canvasX, *Me\mouseY - *Me\canvasY,100,50,RGB(120,120,140))
              NodeInfos(*Me)
              *Me\redraw = #True
              *Me\tree\dirty = #True
            EndIf
            
            NodeSearch::Delete(*search)
            GraphUI::CanvasEvent(*Me,#PB_Event_Repaint)
            Protected x = ListSize(*Me\tree\root\nodes())

        EndSelect
        
      Case #PB_Event_SizeWindow
        Protected *top.View::View_t = *Me\parent
        Protected width.i = *top\width
        Protected height.i = *top\height
        
        *Me\sizX = width
        *Me\sizY = height

        ResizeGadget(*Me\container,*top\x,*top\y,width,height)
        ResizeGadget(*Me\gadgetID,0,0,width,height)
        CanvasEvent(*Me,#PB_Event_SizeWindow)
        
      Case #PB_Event_Gadget
        If EventGadget() = *Me\gadgetID
            GraphUI::CanvasEvent(*Me,#PB_Event_Gadget)
        EndIf
        
      Case #PB_Event_GadgetDrop
        If EventGadget() = *Me\gadgetID
            GraphUI::CanvasEvent(*Me,#PB_Event_GadgetDrop)
        EndIf
        
    EndSelect

  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Term
  ;---------------------------------------------------------------------------
  Procedure Term(*Me.GraphUI_t)
    Debug "ViewportUI Term Called!!!"
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Resize
  ;---------------------------------------------------------------------------
  Procedure  Resize(*Me.GraphUI_t)
    *Me\posX = GadgetX(*Me\container)
    *Me\posY = GadgetY(*Me\container)
    *Me\sizX = GadgetWidth(*Me\container)
    *Me\sizY = GadgetHeight(*Me\container)
    ResizeGadget(*Me\gadgetID,0,0,*Me\sizX,*Me\sizY)    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Inspect Node
  ;---------------------------------------------------------------------------
  Procedure InspectNode(*Me.GraphUI_t,*node.Node::Node_t)
    Protected *top.View::View_t = *Me\parent

    Protected *manager.ViewManager::ViewManager_t = *top\manager
    If *node
      ForEach *manager\uis()
        If *manager\uis()\name = "Property"
          Protected *property.PropertyUI::PropertyUI_t = *manager\uis()
          If Not PropertyUI::CheckNodeExists(*property, *node)
            PropertyUI::Setup(*manager\uis(),*node)
          EndIf
          
         Break
       EndIf
     Next
    Else
      ;Open Floating *property View
;       MessageRequester("[GRAPH UI]","Inspect Node Property doesn' exists!!! Create It Floating!!!")
      Protected window = OpenWindow(#PB_Any,0,0,800,600,"NodeProperty",#PB_Window_BorderLess|#PB_Window_Tool)
      
      Repeat
      Until WaitWindowEvent() = #PB_Event_CloseWindow
      
      CloseWindow(window)
      
    EndIf
    
  EndProcedure
  
  Procedure OnDeleteTree(*Me.GraphUI_t)
    *Me\tree = #Null
    CArray::SetCount(*Me\a_selected, 0)
    ClearList(*Me\a_visible())
  EndProcedure
  Callback::DECLARECALLBACK(OnDeleteTree, Arguments::#PTR)
  
  
  ;---------------------------------------------------------------------------
  ;  Set Content
  ;---------------------------------------------------------------------------
  Procedure SetContent(*Me.GraphUI_t,*tree.Tree::Tree_t)

    If *tree
      *Me\tree = *tree
      *Me\tree\current = *tree\root
      *Me\redraw = #True
      Signal::CONNECTCALLBACK(*Me\tree\on_delete, OnDeleteTree, *Me)
    Else
      *Me\tree = #Null
       *Me\redraw = #True
      ClearList(*Me\a_visible())
    EndIf
    
    ;Resize(*Me)
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Mouse Position
  ;---------------------------------------------------------------------------
  Procedure MousePosition(*Me.GraphUI_t,x.i,y.i)
  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Is Node Visible
  ;---------------------------------------------------------------------------
  Procedure.b IsNodeVisible(*Me.GraphUI_t,*n.Node::Node_t)
    If (*n\posx+*n\width)<0 Or *n\posx>*Me\sizX Or (*n\posy+*n\height)<0 Or *n\posy>*Me\sizY
      ProcedureReturn #False
    Else
      ProcedureReturn #True
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Node Infos
  ;---------------------------------------------------------------------------
  Procedure NodeInfos(*Me.GraphUI_t)
    
    If Not *Me\tree : ProcedureReturn : EndIf
    ClearList(*Me\a_visible())
    Protected a = 0
    Protected *node.Node::Node_t
    Protected *current.Node::Node_t
    *current = *Me\tree\current
    
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    If *current And *current\isroot
      Node::ViewSize(*current)
      Node::ViewPosition(*current,*Me\canvasX,*Me\canvasY)
      ; Check For Visibility
;        If IsNodeVisible(*Me,*current)
         Graph::AttachListElement(*Me\a_visible(),*current)
;        EndIf
    EndIf
     
    
     If *Me\tree And ListSize(*current\nodes())>0
      ForEach *current\nodes()
 
 
        *node = *current\nodes()
        
        Node::ViewSize(*node)
        Node::ViewPosition(*node,*Me\canvasX,*Me\canvasY)
        ; Check Fo Visibility
;          If IsNodeVisible(*Me,*node)
           Graph::AttachListElement(*Me\a_visible(),*node)
;         EndIf
      Next
    EndIf
    StopVectorDrawing()
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Add Input Port
  ;---------------------------------------------------------------------------
  Procedure AddInputPort(*args.Arguments::Arguments_t)

;     Protected *graph.GraphUI_t = *args\args()\ptr
;     Protected *node.Node::Node_t = CArray::GetValuePtr(*args,1)
;     Protected name.s = PeekS(CArray::GetValue(*args,2))
;     Protected type.i = PeekI(CArray::GetValue(*args,3))
;     Node::AddInputPort(*node,name,type)
;     
;     *graph\dirty = #True
    
  EndProcedure
  
  Procedure Dummy()
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; PopUp Menu
  ;---------------------------------------------------------------------------
  Procedure PopUpMenu(*Me.GraphUI_t)
; ;     Protected *top.View::View_t = *Me\top
; ;     Protected *manager.ViewManager::ViewManager_t = *top\manager
; ;     Protected menu = CreatePopupMenu(#PB_Any)
; ;     
; ;     MenuItem(Globals::#MENU_IMPLODENODES,"Implode Nodes")
; ;     MenuItem(Globals::#MENU_EXPLODENODES,"Explode Nodes")
; ;     MenuBar()
; ;     MenuItem(Globals::#MENU_ADDINPUTPORT,"Add Input Port")
; ;     MenuItem(Globals::#MENU_REMOVEINPUTPORT,"Add Input Port")
; ;     MenuItem(Globals::#MENU_ADDOUTPUTPORT,"Add Output Port")
; ;     MenuItem(Globals::#MENU_REMOVEOUTPUTPORT,"Add Output Port")
; ;     
; ;     DisplayPopupMenu(menu,WindowID(*manager\window),WindowMouseX(*manager\window),WindowMouseY(*manager\window))
; 
;     
;     
;     Protected *top.View::View_t = *Me\top
;     Protected *manager.ViewManager::ViewManager_t = *top\manager
;     Protected window = *manager\window
;    
;     
;     Protected mx = WindowMouseX(window)
;     Protected my = WindowMouseY(window)
;     
;     Protected *node.Node::Node_t = *Me\focus
;     If *node
;       Protected *menu.ControlMenu::ControlSubMenu_t = ControlMenu::NewSubMenu(#Null,mx,my,"File")
;       Protected *args.Arguments::Arguments_t = Arguments::New()
;       
;       Arguments::ADD(*args,*Me\tree)
;       Arguments::ADD(*args,*Me\a_selected)
;       Arguments::ADD(*args,*Me\tree\current)
;       
;       ControlMenu::AddItem(*menu,"Create Compound",ImplodeNodesCmd::@Do(),*args)
;       ControlMenu::AddSeparator(*menu)
;       
;       
;       Arguments::PASS(*args\args(1),*node)
;       Arguments::PASS(*args\args(2),"Bool",2)
;       Arguments::PASS(*args\args(3),Attribute::#ATTR_TYPE_BOOL)
;       ControlMenu::AddItem(*menu,"Add Bool",@Dummy(),*args)
;       
;       Arguments::PASS(*args\args(1),*node,1)
;       Arguments::PASS(*args,"Float",2)
;       Arguments::PASS(*args,Attribute::#ATTR_TYPE_FLOAT,3)
;       ControlMenu::AddItem(*menu,"Add Float",@Dummy(),*args)
;       
;       Arguments::PASS(*args\args(1),*node)
;       Arguments::PASS(*args\args(2),"Vector2")
;       Arguments::PASS(*args\args(3),Attribute::#ATTR_TYPE_VECTOR2)
;       ControlMenu::AddItem(*menu,"Add Vector2",@Dummy(),*args)
;       
;       Arguments::PASS(*args,"Node",*node,1)
;       Arguments::PASS(*args,"TypeName","Vector3",2)
;       Arguments::PASS(*args,"Type",Attribute::#ATTR_TYPE_VECTOR3,3)
;       ControlMenu::AddItem(*menu,"Add Vector3",@Dummy(),*args)
;       
;       Arguments::Delete(*args)
;       
; ;       args\m[1]\type = #MU_TYPE_PTR
; ;       args\m[1]\value\vPTR = *node
; ;       args\m[2]\type = #MU_TYPE_STR
; ;       args\m[2]\value\vSTR = "Bool"
; ;       args\m[3]\type = #MU_TYPE_U32
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_BOOL
; ;       
; ;       *menu\AddItem("Add Bool",@Dumy(),@args)
; ;       args\m[2]\value\vSTR = "Integer"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_INTEGER
; ;       *menu\AddItem("Add Integer",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "Float"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_FLOAT
; ;       *menu\AddItem("Add Float",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "Vector2"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_VECTOR2
; ;       *menu\AddItem("Add Vector2",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "Vector3"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_VECTOR3
; ;       *menu\AddItem("Add Vector3",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "Vector4"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_VECTOR4
; ;       *menu\AddItem("Add Vector4",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "quaternion"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_QUATERNION
; ;       *menu\AddItem("Add Quaternion",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "Matrix3"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_MATRIX3
; ;       *menu\AddItem("Add Matrix3",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "Matrix4"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_MATRIX4
; ;       *menu\AddItem("Add Matrix4",@OViewGraph_AddInputPort(),@args)
; ;       args\m[2]\value\vSTR = "Texture"
; ;       args\m[3]\value\vU32 = #ATTR_TYPE_TEXTURE
; ;       *menu\AddItem("Add Texture",@OViewGraph_AddInputPort(),@args)
;       
; 
;       *menu\windowID = window
;       
;       ControlMenu::InitSubMenu(*menu)
;       ControlMenu::InspectSubMenu(*menu)
;       MessageRequester("GraphUI","Inspect Menu Ended")
;       ControlMenu::DeleteSubMenu(*menu)
  
;     EndIf
    
  
  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Change Port Name
  ;---------------------------------------------------------------------------
  Procedure ChangePortName(*Me.GraphUI_t,x.i,y.i)
    Protected *top.View::View_t = *Me\parent
    If *Me\focus And *Me\focus\port
      Protected mx = x+*top\x
      Protected my = y+*top\y
      
      OpenGadgetList(*me\container)
      Protected input = StringGadget(#PB_Any,mx,my,120,30,"")
      
      Protected quit = #False
      Protected event
      Repeat 
        SetActiveGadget(input)
        event = WaitWindowEvent()
        If event = #PB_Event_Menu
          If EventMenu() = Globals::#SHORTCUT_ENTER
            quit = #True
          EndIf
        EndIf
        
      Until quit = #True
      
      Protected v.s = GetGadgetText(input)
      Protected *port.NodePort::NodePort_t = *Me\focus\port
      *port\name = v
      *Me\dirty = #True
      FreeGadget(input)
    EndIf
    CloseGadgetList()
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Delete Selected
  ;---------------------------------------------------------------------------
  Procedure DeleteSelected(*Me.GraphUI_t)
    If Not *Me\tree
      Debug "NO Graph Tree in this view Graph!!!"
      ProcedureReturn
    EndIf
    
    Protected *node.Node::Node_t
    Protected inode.Node::INode
  
    ForEach *Me\tree\current\nodes()
      *node = *Me\tree\current\nodes()
      If *node\selected And Not *node\isroot
        inode = *node
        inode\Terminate()
        Tree::RemoveNode(*Me\tree,*node)
        *Me\focus = #Null
        *Me\dirty = #True
        *Me\redraw = #True
      EndIf
      
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Start Connecter
  ;---------------------------------------------------------------------------
  Procedure StartConnecter(*Me.GraphUI_t,compound.b=#False)
    
    
    Protected *p.NodePort::NodePort_t
    If compound
      *p = *Me\tree\current\port
    Else
      *p = *Me\focus\port
    EndIf
    
    If *p And *p\io = #False And *p\connected
      Protected *c.Connexion::Connexion_t = *p\connexion
      ForEach *Me\tree\current\connexions()
        If *Me\tree\current\connexions() = *c
          Break
        EndIf
        
      Next
      
      Graph::ExtractListElement(*Me\tree\current\connexions(),*c)
      *Me\connecter = Connexion::Reuse(*c)
;       Tree::DisconnectNodes(*Me\tree,*Me\tree\current,*c\start,*c\end)
;       *Me\connecter = Connexion::New(*p)
      *Me\connect = #True
    Else
                    
      If compound = #True
        *Me\connecter = Connexion::New(*Me\tree\current\port)
        *Me\connect = #True
      Else
        *Me\connecter = Connexion::New(*Me\focus\port)
        *Me\connect = #True
      EndIf
    EndIf
    
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Terminate Connecter
  ;---------------------------------------------------------------------------
  Procedure TerminateConnecter(*Me.GraphUI_t)
    If *Me\focus
      StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
      TranslateCoordinates(*Me\canvasX, *Me\canvasY)
      ScaleCoordinates(*Me\zoom, *Me\zoom)
      x = ConvertCoordinateX(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User)
      y = ConvertCoordinateY(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User)
      StopVectorDrawing()
      
      ;Check For connection succeded
      Protected s.i = Node::Pick(*Me\focus,x,y,#True)
      If s.i = Graph::#Graph_Selection_Port
        If Connexion::Connect(*Me\connecter,*Me\focus\port,#True)
          Tree::ConnectNodes(*Me\tree,*Me\tree\current,*Me\connecter\start,*Me\connecter\end,#True)
          ;OGraphTree_ConnectNodes_Do(*Me\tree,*Me\tree\current,*Me\connecter\start,*Me\connecter\end)
        EndIf
      EndIf
    Else
      If *Me\depth>0
        Protected *compound.CompoundNode::CompoundNode_t = *Me\tree\current
        s = CompoundNode::Pick(*compound,*Me\gadgetID,x,y)
        If s = Graph::#Graph_Selection_ExposeOutput
          CompoundNode::ExposePort(*compound,*Me\connecter\start)
        ElseIf s = Graph::#Graph_Selection_ExposeInput
          CompoundNode::ExposePort(*compound,*Me\connecter\start)
;             If *p\class\name = "CompoundNodePort"
;               MessageRequester("Connexion","Compound Node Port!!!")
;               CompoundNode::ExposePort(
;             Else
;           MessageRequester("GraphUI","Connect Compound Called!!!")
;           If Connexion::Connect(*Me\connecter,*compound\output_exposer,#True)
;             
;             ;Tree::ConnectNodes(*Me\tree,*Me\tree\current,*Me\connecter\start,*Me\connecter\end,#True)
;             ;OGraphTree_ConnectNodes_Do(*Me\tree,*Me\tree\current,*Me\connecter\start,*Me\connecter\end)
;           EndIf
        EndIf
      EndIf
    EndIf
    *Me\connect = #False
      *Me\redraw = #True
  
    Connexion::Delete(*Me\connecter)
    
  EndProcedure
  
  Procedure DrawZoom(*Me.GraphUI_t, f.f=0.5)
    DrawingMode(#PB_2DDrawing_Default)
    
    Protected z.f = *Me\zoom
    Protected of.f = 1.0-f
    Protected ox = 200 * z
    Protected oy = 120 * z
    Protected p1x = *Me\canvasX+ox
    Protected p1y = *Me\canvasY+oy
    Protected w = 120 * z
    Protected h = 60 * z
    
    Box(p1x,p1y,w,h, RGBA(255,0,0,255))
    Box(p1x*f+*Me\mouseX*of,p1y*f+*Me\mouseY*of,w*f,h*f,RGBA(0,255*f,0,255))
    Box(p1x*f+*Me\canvasX*of,p1y*f+*Me\canvasY*of,w*f,h*f,RGBA(0,255*f,0,255))
    
    LineXY(p1x,p1y,*Me\mouseX,*Me\mouseY, RGBA(255,255,0,255))
    LineXY(p1x+w,p1y,*Me\mouseX,*Me\mouseY, RGBA(255,255,0,255))
    LineXY(p1x,p1y+h,*Me\mouseX,*Me\mouseY, RGBA(255,255,0,255))
    LineXY(p1x+w,p1y+h,*Me\mouseX,*Me\mouseY, RGBA(255,255,0,255))
    
    Circle(p1x*f+*Me\mouseX*of,p1y*f+*Me\mouseY*of,2,RGBA(0,0,255,255))
    Circle((p1x+w)*f+*Me\mouseX*of,p1y*f+*Me\mouseY*of,2,RGBA(0,0,255,255))
    Circle(p1x*f+*Me\mouseX*of,(p1y+h)*f+*Me\mouseY*of,2,RGBA(0,0,255,255))
    Circle((p1x+w)*f+*Me\mouseX*of,(p1y+h)*f+*Me\mouseY*of,2,RGBA(0,0,255,255))
    
    LineXY(*Me\canvasX, *Me\canvasY, p1x, p1y, RGBA(255,255,0,255))
    LineXY(*Me\canvasX, *Me\canvasY, p1x+w, p1y, RGBA(255,255,0,255))
    LineXY(*Me\canvasX, *Me\canvasY, p1x, p1y+h, RGBA(255,255,0,255))
    LineXY(*Me\canvasX, *Me\canvasY, p1x+w, p1y+h, RGBA(255,255,0,255))
    
    Circle(*Me\canvasX*f+p1x*of,*Me\canvasY*f+p1y*of,2,RGBA(0,0,255,255))
    Circle(*Me\canvasX*f+(p1x+w)*of,*Me\canvasY*f+p1y*of,2,RGBA(0,0,255,255))
    Circle(*Me\canvasX*f+p1x*of,*Me\canvasY*f+(p1y+h)*of,2,RGBA(0,0,255,255))
    Circle(*Me\canvasX*f+(p1x+w)*of,*Me\canvasY*f+(p1y+h)*of,2,RGBA(0,0,255,255))
    
    LineXY(p1x*f+*Me\mouseX*of, p1y*f+*Me\mouseY*of, *Me\canvasX*of+p1x*f, *Me\canvasY*of+p1y*f, RGBA(255,255,255,255))
    Protected x = (*Me\canvasX*of+p1x*f) - (p1x*f+*Me\mouseX*of)
    Protected y = (*Me\canvasY*of+p1y*f) - (p1y*f+*Me\mouseY*of)
    Protected l.f = Sqr(x*x +y*y)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText((p1x*f+*Me\mouseX*of+*Me\canvasX*of+p1x*f)*0.5, (p1y*f+*Me\mouseY*of+*Me\canvasY*of+p1y*f)*0.5-12, StrF(l,3), RGBA(255,255,255,255))
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(p1x*f+*Me\mouseX*of,p1y*f+*Me\mouseY*of,w*f,h*f,RGBA(255,255,255,255))
    
    
    

  EndProcedure
  
  ;---------------------------------------------------------------------------
  ;Draw Background
  ;---------------------------------------------------------------------------
  Procedure Background(*Me.GraphUI_t)
    Protected iz = *Me\zoom * 100
    ; Use Pixels Drawing
    CompilerIf Not Globals::#USE_VECTOR_DRAWING
      Protected mx =0
      If *Me\depth>0 : mx = Graph::#Graph_Compound_Border : EndIf
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box( mx, 0, *Me\width-2*mx, *Me\height, UIColor::COLOR_MAIN_BG )
      
      Protected vw.i = Percentage(*Me\width,iz)
      Protected vh.i = Percentage(*Me\height,iz)
     
      ;Vertical lines
      Protected i
      For i=0 To vw
        If i%iz = 0
          Line(i+*Me\canvasX%iz,0,1,*Me\height,UIColor::COLOR_LINE_DIMMED)
        EndIf
      Next i
        
      ;Horizontal lines
      For i=0 To vh
        If i%iz = 0
          Line(mx,i+*Me\canvasY%iz,*Me\width-2*mx,1,UIColor::COLOR_LINE_DIMMED)
        EndIf
      Next i
      
      ;CenterCircle
      Circle(*Me\canvasX,*Me\canvasY,7,RGBA(255,100,100,255))
      Circle(*Me\width*0.5,*Me\height*0.5,4,RGBA(255,100,255,255))
      
      ; Mouse Circle
      Circle(*Me\mouseX,*Me\mouseY,5,RGBA(0,255,100,255))
      
    ; Use Vector Drawing
    CompilerElse
      MovePathCursor(0,0)
      AddPathBox(0, 0, *Me\sizX, *Me\sizY)
      VectorSourceColor(UIColor::COLOR_MAIN_BG )
      FillPath()
      
;       Protected vw.i = Percentage(*Me\width,iz)
;       Protected vh.i = Percentage(*Me\height,iz)
;       
;       VectorSourceColor(UIColor::COLOR_LINE_DIMMED)
;       ;Vertical lines
;       Protected i
;       Protected ix,iy
;       
;       For i=0 To vw
;         If i%iz = 0
;           ix = i+*Me\canvasX%iz
;           MovePathCursor(ix,0)
;           AddPathLine(0,*Me\height,#PB_Path_Relative)
;           StrokePath(1)
;           ;Line(i+*Me\canvasX%*Me\zoom,0,1,*Me\height,Globals::COLOR_LINE_DIMMED)
;         EndIf
;       Next i
;         
;       ;Horizontal lines
;       For i=0 To vh
;         If i%iz = 0
;           iy = i+*Me\canvasY%iz
;           MovePathCursor(0,iy,0)
;           AddPathLine(*Me\width,0,#PB_Path_Relative)
;           StrokePath(1)
;           ;Line(0,i+*Me\canvasY%*Me\zoom,*Me\width,1,Globals::COLOR_LINE_DIMMED)
;         EndIf
;       Next i
      
      ;CenterCircle
      AddPathCircle(*Me\canvasX,*Me\canvasY,12 * *Me\zoom)
      VectorSourceColor(RGBA(255,100,100,255))
      FillPath()
      
    CompilerEndIf
    
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ;Draw Navigation
  ;---------------------------------------------------------------------------
  Procedure DrawCompound(*Me.GraphUI_t)
    If *Me\depth>0 And Not *Me\tree\current\isroot
      
      Protected *compound.CompoundNode::CompoundNode_t = *Me\tree\current
      
      ; Inputs
      Box(0,0,Graph::#Graph_Compound_Border,*Me\sizY,UIColor::COLOR_TERNARY_BG)
      
      ; Outputs
      Box(GadgetWidth(*Me\gadgetID)-Graph::#Graph_Compound_Border,0,Graph::#Graph_Compound_Border,*Me\sizY,UIColor::COLOR_TERNARY_BG)

      CompoundNode::Draw(*compound,*Me\gadgetID)
 
    EndIf
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Draw Empty Tree
  ;---------------------------------------------------------------------------
  Procedure DrawEmpty(*Me.GraphUI_t)    
    CompilerIf Not Globals::#USE_VECTOR_DRAWING
      ; Default Drawing
      StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
      AddPathBox(0,0,GadgetWidth(*Me\gadgetID),GadgetHeight(*Me\gadgetID))
      VectorSourceColor(RGBA(200,200,200,255))
      FillPath()
      StopVectorDrawing()
    CompilerElse
      ; Vector Drawing
      StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
      VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_TITLE)
      AddPathBox(0,0,GadgetWidth(*Me\gadgetID),GadgetHeight(*Me\gadgetID))
      VectorSourceColor(RGBA(200,200,200,255))
      FillPath( #PB_Path_Default )
      AddPathBox(0,0,GadgetWidth(*Me\gadgetID),GadgetHeight(*Me\gadgetID))
      VectorSourceColor(RGBA(255,66,0,255))
      StrokePath(4,#PB_Path_RoundCorner)
      MovePathCursor(GadgetWidth(*Me\gadgetID)/3, GadgetHeight(*Me\gadgetID)/2,#PB_Path_Default)
      AddPathText("NO TREE")
      VectorSourceColor(RGBA(255,66,0,255))
      FillPath()
      StopVectorDrawing()
    CompilerEndIf
    
  EndProcedure
  

  
  
  ;---------------------------------------------------------------------------
  ;Draw All Nodes
  ;---------------------------------------------------------------------------
  Procedure DrawAllNodes(*Me.GraphUI_t)
   StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
   ResetCoordinates()
   Background(*Me)
   
   TranslateCoordinates(*Me\canvasX, *Me\canvasY)
   ScaleCoordinates(*Me\zoom, *Me\zoom)
     If *Me\tree
      Protected c
      Protected *connexion.Connexion::Connexion_t
      ForEach *Me\tree\current\connexions()
        *connexion = *Me\tree\current\connexions()
        ;Draw connexions
        Connexion::ViewPosition(*connexion)
        Connexion::Draw(*connexion,#False)
      Next
      
      ;Draw visible nodes
      Protected v
      Protected *visible.Node::Node_t
      ForEach *Me\a_visible()
        *visible = *Me\a_visible()
        ;Draw nodes
        Node::Draw(*visible)
      Next
    
      ;Draw Connector
      If *Me\connect
        Connexion::ViewPosition(*Me\connecter)
        Connexion::Draw(*Me\connecter,#True)
      EndIf
      
;         ;Draw Rectangle Selection
;         If *Me\pick
;           DrawingMode(#PB_2DDrawing_Outlined)
;           RoundBox(*Me\rectX1,*Me\rectY1,*Me\rectX2-*Me\rectX1,*Me\rectY2-*Me\rectY1,3,3,RGB(250,200,50))
;         EndIf
;         
      ;Debug
      VectorFont(FontID(*Me\font_debug))
      VectorSourceColor(RGBA(120,90,66,255))
      MovePathCursor(10,10)
      AddPathText("Nb Nodes : "+Str(ListSize(*Me\tree\current\nodes())-1))
      MovePathCursor(10,40)
      AddPathText("PositionX : "+Str(*Me\canvasX))
      MovePathCursor(10,50)
      AddPathText("PositionY : "+Str(*Me\canvasY))
      MovePathCursor(10,70)
      AddPathText("Zoom Factor : "+Str(*Me\zoom))
      MovePathCursor(10,80)
      AddPathText("Nb Connexions : "+Str(ListSize(*Me\tree\current\connexions())))
      MovePathCursor(10,90)
      AddPathText("Depth : "+Str(*Me\depth))        
      FillPath()
    EndIf
    
;       DrawCompound(*Me)
    
       
   StopVectorDrawing()
    
    *Me\redraw = #False
  EndProcedure
  
  
  ;---------------------------------------------------------------------------
  ; Get Node Under Mouse
  ;---------------------------------------------------------------------------
  Procedure.i GetNodeUnderMouse(*Me.GraphUI_t,x.i,y.i)
    If Not *Me\tree : ProcedureReturn Graph::#Graph_Selection_None: EndIf
    
    If *Me\depth >0 And x<Graph::#Graph_Compound_Border And y< Graph::#Graph_Compound_Border
      ProcedureReturn Graph::#Graph_Selection_Climb
    EndIf
    
    
    If Node::IsUnderMouse( *Me\tree\current,x,y)
      *Me\focus = *Me\tree\current
      ProcedureReturn Graph::#Graph_Selection_Node
    ElseIf LastElement(*Me\tree\current\nodes())
      
      Repeat
        If Node::IsUnderMouse( *Me\tree\current\nodes(),x,y)
          *Me\focus = *Me\tree\current\nodes()
          ProcedureReturn Graph::#Graph_Selection_Node
        EndIf
  
      Until PreviousElement(*Me\tree\current\nodes()) = 0
  
    EndIf
    
    *Me\focus = #Null
    ProcedureReturn Graph::#Graph_Selection_Rectangle
  EndProcedure
  
  
  ;---------------------------------------------------------------------------
  ; Clear Selection
  ;---------------------------------------------------------------------------
  Procedure.i ClearSelection(*Me.GraphUI_t)
    Protected i
    Protected *node.Node::Node_t
    For i=0 To CArray::GetCount(*Me\a_selected)-1
      *node = CArray::GetValuePtr(*Me\a_selected,i)
      *node\selected = #False
    Next i
    
    CArray::SetCount(*Me\a_selected,0)  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Select
  ;---------------------------------------------------------------------------
  Procedure.i Selection(*Me.GraphUI_t,x.i,y.i,connect.b=#False)
    Protected *focus
    Protected *top
    
    If *Me\tree\current = *Me\focus
      *top = *Me\focus
    Else
      *top = LastElement(*Me\tree\current\nodes())
      ForEach *Me\tree\current\nodes()
        If *Me\tree\current\nodes() = *Me\focus
          *focus = @*Me\tree\current\nodes()
          Break
        EndIf
      Next
    EndIf
    
    If *top = #Null : ProcedureReturn : EndIf
    
  
    If *focus  And Not *top = *focus And ListSize(*Me\tree\current\nodes())>1
      SwapElements(*Me\tree\current\nodes(), *top, *focus)
      LastElement(*Me\tree\current\nodes())
      *Me\focus = *Me\tree\current\nodes()
    EndIf
    
    If *Me\focus 
      If Not *Me\focus\selected And Not GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers) & #PB_Canvas_Control
        ClearSelection(*Me)
      EndIf
      *Me\focus\selected = #True
      CArray::AppendUnique(*Me\a_selected,*Me\focus)
    Else 
       ClearSelection(*Me)
    EndIf
    
  
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Select Branch
  ;---------------------------------------------------------------------------
  Procedure SelectRecurse(*Me.GraphUI_t,*n.Node::Node_t)
  
    Protected *node.Node::Node_t
     ForEach *n\inputs()
       If *n\inputs()\connected
;          If *n\inputs()\class\name = "CompoundNodePort"
;            MessageRequester("GraphUI SelectRecurse","CompoundNodePort Type for "
        *node = *n\inputs()\source\node
        If *node<>#Null
          CArray::AppendUnique(*Me\a_selected,*node)
          SelectRecurse(*Me,*node)
        Else
          MessageRequester("GraphUI Select Recusre","Source Noide NULL")
        EndIf
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Select Branch
  ;---------------------------------------------------------------------------
  Procedure.i SelectBranch(*Me.GraphUI_t,*n.Node::Node_t)
    CArray::SetCount(*Me\a_selected,0)
    CArray::AppendUnique(*Me\a_selected,*n)
    SelectRecurse(*Me,*n)
    
    Protected *node.Node::Node_t
    Protected i
    For i=0 To CArray::GetCount(*Me\a_selected)-1
      *node = CArray::GetValuePtr(*Me\a_selected,i)
      *node\selected = #True
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Rectangle Selection
  ;---------------------------------------------------------------------------
  Procedure RectangleSelect(*Me.GraphUI_t)
    CArray::SetCount(*Me\a_selected,0)
  
    With *Me\tree\current
      If Bool(\posx>*Me\rectX1 And \posx+\width<*Me\rectX2 And \posy>*Me\rectY1 And \posy+\height<*Me\rectY2)
        CArray::AppendUnique(*Me\a_selected,*Me\tree\current)
        \selected = #True
      Else
        \selected = #False
      EndIf
    EndWith
    
    
    ForEach *Me\tree\current\nodes()
      With *Me\tree\current\nodes()
        If Bool(\posx>*Me\rectX1 And \posx+\width<*Me\rectX2 And \posy>*Me\rectY1 And \posy+\height<*Me\rectY2)
          CArray::AppendUnique(*Me\a_selected,*Me\tree\current\nodes())
          \selected = #True
        Else
          \selected = #False
        EndIf
      EndWith  
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Reset
  ;---------------------------------------------------------------------------
  Procedure Reset(*Me.GraphUI_t)
    *Me\canvasX = *Me\sizX * 0.5
    *Me\canvasY = *Me\sizY * 0.5
    *Me\zoom = 1.0
    *Me\redraw = #True
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Frame All
  ;---------------------------------------------------------------------------
  Procedure FrameAll(*Me.GraphUI_t)
    Define.i minx,maxx,miny,maxy,width,height
    FirstElement(*Me\tree\current\nodes())
    With *Me\tree\current\nodes()
      minx = \posx
      miny = \posy
      maxx = \posx+\width
      maxy = \posy+\height
    EndWith
  
    ForEach *Me\tree\current\nodes()
      With *Me\tree\current\nodes()
        Minimum(minx,\posx) 
        Minimum(miny,\posy)
        Maximum(maxx,\posx+\width)
        Maximum(maxy,\posy+\height)
      EndWith
    Next
    
    width = maxx-minx
    height = maxy-miny
   
    *Me\canvasX = -(maxx-minx)/2
    *Me\canvasY = -(maxy-miny)/2
    *Me\zoom = (*Me\sizX/width/2 + *Me\sizY/height/2)
    MINIMUM(*Me\zoom,2.5)
    MAXIMUM(*Me\zoom,0.01)
   
    ForEach *Me\tree\current\nodes()
      Node::ViewPosition(*Me\tree\root\nodes(),*Me\canvasX,*Me\canvasY)
    Next
    
    *Me\redraw = #True
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Frame Selected
  ;---------------------------------------------------------------------------
  Procedure FrameSelected(*Me.GraphUI_t)
    Protected minx,miny,maxx, maxy
    minx = #S32_MAX
    miny = #S32_MAX
    maxx = #S32_MIN
    maxy = #S32_MIN
    Protected i
    Protected *node.Node::Node_t
    Protected msg.s
    For i=0 To CArray::GetCount(*Me\a_selected)-1
      *node = CArray::GetValuePtr(*Me\a_selected,i)
      With *node
        msg + " - "+*node\name+Chr(10)
        If minx>\posx : minx = \posx : EndIf
        If miny>\posy : miny = \posy :EndIf
        If maxx<\posx+\width : maxx = \posx+\width : EndIf
        If maxy<\posy+\width : maxy = \posy+\width : EndIf
      EndWith
    Next
    
    msg + "BBox : "+Str(minx)+","+Str(miny)+","+Str(maxx)+","+Str(maxy)
    *Me\canvasX = -(minx+maxx) * 0.5 +*Me\sizX * 0.5
    *Me\canvasY = -(miny+maxy) * 0.5 + *Me\sizY * 0.5
    *Me\zoom = 1.0
    ;MessageRequester("Frame Selected", msg)
    ForEach *Me\tree\root\nodes()
      Node::ViewPosition(*Me\tree\root\nodes(),*Me\canvasX,*Me\canvasY)
    Next
    
    *Me\redraw = #True 
    
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Activate Pan
  ;---------------------------------------------------------------------------
  Procedure ActivatePan(*Me.GraphUI_t)
    ; Pan
    SetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Hand)
    *Me\pan = #True  
  EndProcedure
  
  Procedure Pick(*Me.GraphUI_t)
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    TranslateCoordinates(*Me\canvasX, *Me\canvasY)
    ScaleCoordinates(*Me\zoom, *Me\zoom)
    PokeI(@*Me\realX, ConvertCoordinateX(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User))
    PokeI(@*Me\realY, ConvertCoordinateY(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User))
    StopVectorDrawing()
  EndProcedure
  
 
  ;---------------------------------------------------------------------------
  ;Graph View Events
  ;---------------------------------------------------------------------------
  Procedure.i CanvasEvent(*Me.GraphUI_t,eventID.i)
    
    Define x.d,y.d ,out_value
    *Me\redraw = #False
    *Me\mouseX = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
    *Me\mouseY = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
    
    ; Return value(push the command stack)
    out_value = -1
    
    If Not *Me\tree : DrawEmpty(*Me): ProcedureReturn : EndIf
    Select eventID
      ;-----------------------------------------------------------------------  
      ; Gadget Event
      ;{
      Case #PB_Event_Gadget
        Select EventType()
          ; DragStart Event
          Case #PB_EventType_DragStart
            Debug "Drag Start On View Graph!!!"
            
          ;Left Double Click Event
          Case #PB_EventType_RightButtonDown
            Define *popup.ControlPopup::ControlPopup_t = ControlPopup::New(*Me, *Me\mouseX, *Me\mouseY-32, 240, 120)
           ControlPopup::StartLoop(*popup)
            
            
          ;Left Double Click Event
          Case #PB_EventType_LeftDoubleClick
            Pick(*Me)
            GetNodeUnderMouse(*Me,*Me\realX,*Me\realY)
            If *Me\focus
               Define mode = Node::Pick(*Me\focus,*Me\realX,*Me\realY,#False)
               If mode = Graph::#Graph_Selection_Node
                 ;Inspect Current Node
                 InspectNode(*Me,*Me\focus)
                   *Me\down = #False
               ElseIf mode = Graph::#Graph_Selection_Port
                ;ChangePortName(*Me,x,y)
               EndIf
              
            EndIf

          ;Wheel Event
          Case #PB_EventType_MouseWheel

       
            StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
            TranslateCoordinates(*Me\canvasX, *Me\canvasY)
            ScaleCoordinates(*Me\zoom, *Me\zoom)
            Define ox.d = ConvertCoordinateX(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User)
            Define oy.d = ConvertCoordinateY(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User)
            Protected wheel.i = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_WheelDelta)
            
            *Me\zoom + wheel * (*Me\zoom * 250 / 1000)
            Clamp(*Me\zoom,0.01,2.5)
            
            ScaleCoordinates(*Me\zoom, *Me\zoom)
            Define nx.d = ConvertCoordinateX(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User)
            Define ny.d = ConvertCoordinateY(*Me\mouseX, *Me\mouseY, #PB_Coordinate_Device, #PB_Coordinate_User)
            StopVectorDrawing()
            
            *Me\canvasX + (nx - ox) * *Me\zoom
            *Me\canvasY + (ny - oy) * *Me\zoom

            *Me\redraw = #True

          ;Left Button Down Event
          Case #PB_EventType_LeftButtonDown     
            Pick(*Me)
            Protected modifiers.i = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)  
            If modifiers & #PB_Canvas_Alt
              If *me\pan :ProcedureReturn : EndIf
              ; Pan
              SetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Hand)
              *Me\offsetx = *Me\mouseX - *Me\canvasX
              *Me\offsety = *Me\mouseY - *Me\canvasY
              *Me\pan = #True
              ProcedureReturn
            EndIf
              
            Define s.i = GetNodeUnderMouse(*Me,*Me\realX,*Me\realY)
            If s = Graph::#Graph_Selection_Climb
              If *Me\depth>0
                *Me\tree\current = *Me\tree\current\parent
                *Me\dirty = #True
                *Me\depth-1
              EndIf
            EndIf
            
            If *Me\depth>0
              Protected *current.CompoundNode::CompoundNode_t = *Me\tree\current
;                 CompoundNode::ViewPosition(*Me\tree\current,*Me\width,*Me\height,*current\iexpand,*current\oexpand)
              Protected id=0
              Protected selected = #False
              ForEach *Me\tree\current\inputs()
                selected = Node::PickPort(*Me\tree\current,*Me\tree\current\inputs(),id,*Me\realX,*Me\realY)
                If selected 
                  If *Me\tree\current\inputs()\connected
                    MessageRequester("GraphUI","Port Already Connected ---> Diconnect")
                  Else
                    StartConnecter(*Me,#True)
                  EndIf
                  
                  Break
                EndIf
                
                id+1
                
              Next
              
            EndIf
            
            If *Me\focus
              Define mode.i = Node::Pick(*Me\focus,*Me\realX,*Me\realY,#False)
              
              Select mode
                Case Graph::#Graph_Selection_Dive
                  ClearSelection(*Me)
                  *Me\tree\current = *me\focus
                  *Me\dirty = #True
                  *Me\depth +1
                 ; selection 
                Case Graph::#Graph_Selection_Node
                  Selection(*Me,*Me\realX,*Me\realY,#False)
                  *Me\drag = #True               
                ; Connexion 
                Case Graph::#Graph_Selection_Port
                  
                  StartConnecter(*Me,#False)
                  
              EndSelect
            Else
              ;Rectangle Selection  
              *Me\rectX1 = *Me\realX
              *Me\rectY1 = *Me\realY
              *Me\rectX2 = *Me\realX
              *Me\rectY2 = *Me\realY
              *Me\pick = #True
            EndIf 
            
            *Me\redraw = #True

          ;Left Button Up Event
          Case #PB_EventType_LeftButtonUp
            Pick(*Me)
            If *Me\drag
              *Me\drag = #False
            EndIf 
            
            If *Me\connect
              If TerminateConnecter(*Me) = 1;
                out_value = 1;
              EndIf
              
            ElseIf *Me\pan
              ;Do nothing as we are panning
              *Me\pan = #False
            ElseIf *Me\pick
              *Me\rectX2 = *Me\realX
              *Me\rectY2 = *Me\realY
              RectangleSelect(*Me)
              *Me\pick = #False
              *Me\redraw = #True
            Else
              *Me\down = #False
              *Me\lastx = *Me\realX
              *Me\lasty = *Me\realY
              *Me\drag = #False
              *Me\redraw = #False
            EndIf
            
          ;Right Button Down Event
          Case #PB_EventType_RightButtonDown
            Pick(*Me)
            PopUpMenu(*Me)
            If *Me\focus
                
            EndIf
            
          ; Right Button Up Event 
          Case #PB_EventType_RightButtonUp
           PopUpMenu(*Me)
            
          ; Middle Button Button Event 
         Case #PB_EventType_MiddleButtonDown
           Pick(*Me)
            Define s.i = GetNodeUnderMouse(*Me,*Me\realX,*Me\realY)
            If *Me\focus
              SelectBranch(*Me,*Me\focus)
              *Me\redraw = #True
            EndIf
            
          ; Key Down Event
          Case #PB_EventType_KeyDown  
            If *Me\keydown : ProcedureReturn : EndIf
             Select GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key)
;                Case #PB_Shortcut_Space
;                  *me\keydown = #PB_Shortcut_Space
;                  If *me\pan :ProcedureReturn : EndIf
;                  ; Pan
;                  SetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Hand)
;                  *Me\offsetx = *Me\mouseX - *Me\canvasX
;                  *Me\offsety = *Me\mouseY - *Me\canvasY
;                  *Me\pan = #True
               Case #PB_Shortcut_A
                 *me\keydown = #PB_Shortcut_A
                 FrameAll(*Me)
               Case #PB_Shortcut_R
                 *me\keydown = #PB_Shortcut_R
                 Reset(*Me)
               Case #PB_Shortcut_F
                 *me\keydown = #PB_Shortcut_F
                 FrameSelected(*Me)
               Case #PB_Shortcut_Delete
                 *me\keydown = #PB_Shortcut_Delete
                 DeleteSelected(*Me)
               Case #PB_Shortcut_Return
                 *me\keydown = #PB_Shortcut_Return
                 If *Me\focus : GraphUI::InspectNode(*Me,*Me\focus) : EndIf
             EndSelect
             
        
          ; Key Up Event
          Case #PB_EventType_KeyUp
            *Me\keydown = #False
             Select GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key)
               Case #PB_Shortcut_Space
                 SetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Default)          
                 *Me\pan = #False
             EndSelect
           
          ; Mouse Move Event
          Case #PB_EventType_MouseMove
            If *Me\connect = #True
              Pick(*Me)
              Connexion::Drag(*Me\connecter,*Me\realX,*Me\realY)
              GetNodeUnderMouse(*Me,*Me\realX,*Me\realY)
              
              If *me\focus
                ; try to connect
                mode = Node::Pick(*Me\focus,*Me\realX,*Me\realY,#True)
                
               ;Snap head of the connexion to the port
               Select mode
                 Case Graph::#Graph_Selection_Node
                   Connexion::SetHead(*Me\connecter,*Me\focus\port)
                 Case Graph::#Graph_Selection_Port
                   If Connexion::Possible(*Me\connecter,*Me\focus\port)         
                     Connexion::SetHead(*Me\connecter,*Me\focus\port)
                   EndIf
               EndSelect
             EndIf
             
             *Me\redraw = #True
             
           ElseIf *Me\pick = #True
             Pick(*Me)
              *Me\rectX2 = *Me\realX
              *Me\rectY2 = *Me\realY
              *Me\redraw = #True
            ElseIf *Me\pan = #True
              Pick(*Me)
              *Me\canvasX = - (*Me\offsetx -*Me\mouseX)
              *Me\canvasY = - (*Me\offsety -*Me\mouseY)
              *Me\redraw = #True
            ElseIf *Me\drag = #True
              Pick(*Me)
              Protected i
              For i=0 To CArray::GetCount(*Me\a_selected)-1
                Protected *sel.Node::Node_t = CArray::GetValuePtr(*Me\a_selected,i)
                If *sel
                  Node::Drag(*sel,*Me\realX-*Me\lastx,*Me\realY-*Me\lasty)
                EndIf
              Next
              *Me\redraw = #True
            EndIf
          
          ; Lost Focus Event
          Case #PB_EventType_LostFocus
            Pick(*Me)
            If *Me\pick
              *Me\rectX2 = *Me\realX
              *Me\rectY2 = *Me\realY
              RectangleSelect(*Me)
              *Me\pick = #False
              *Me\redraw = #True
            EndIf     
      EndSelect 
      ;}  
      
      ;-----------------------------------------------------------------------  
      ; GadgetDrop Event
      ;{
      Case #PB_Event_GadgetDrop
        If *Me\tree
          Protected text.s = EventDropText()
          Tree::AddNode(*Me\tree,text,*Me\canvasX+*Me\mouseX,*Me\canvasY+*Me\mouseY,200,100,RGB(166,166,166))
          
          *Me\tree\dirty = #True
          *Me\redraw = #True
        Else
          MessageRequester("Noodle", "[Graph View] There is no current graph tree.")
        EndIf
      ;}
        
      ;-----------------------------------------------------------------------  
      ; SizeWindow Event
      ;{ 
      Case #PB_Event_SizeWindow
        ;Resize(*Me)
        *Me\redraw = #True
      ;}
    EndSelect
    
    If *Me\redraw
      NodeInfos(*Me)
    EndIf
    If *Me\tree
;        NodeInfos(*Me)
     DrawAllNodes(*Me)
    Else
      DrawEmpty(*Me)
    EndIf
    *Me\lastx = *Me\realX
    *Me\lasty = *Me\realY
    
    ; Don't push command stack
    ProcedureReturn out_value
    
  EndProcedure
  
  
  
  
  ; Switch Context
  ;---------------------------------------------------
  Procedure SwitchContext(*Me.GraphUI_t,*args.CArray::CArrayPtr)
;     Protected *mu.muval = *args\m[0]
;     Protected *mu2.muval = *args\m[1]
;     
;     Protected *e.GraphUI_t = *mu\value\vPTR
;     If Not *e : MessageRequester("SwitchContext","Graph is NULL") : ProcedureReturn :  EndIf
;     Protected ctxt.i = *mu2\value\vU32
;     Debug "Graph View Switch Context ---> "+Str(ctxt)
;     Debug "Graph View Switch Context ---> "+raa_graph_context(ctxt)
;     Select ctxt
;       Case #Graph_Context_Hierarchy
;         Protected *root.CRoot_t = *raa_current_scene\root
;         Protected *node.CGraphNode_t
;         If *root\tree = #Null
;           *root\tree = newCGraphTree(*root,"Hierarchy",#Graph_Context_Hierarchy)
;           ;*node = OGraphTree_AddNode(*root\tree,"Scene",0,0,100,20,0)
;         Else
;           Debug "Hierarchy TREE already exists"
;           FirstElement(*root\tree\root\nodes())
;           *node = *root\tree\root\nodes()
;           Debug "First Node for Hierarchy Tree : "+*node\type
;         EndIf
;         
;         OSceneNode_Setup( *node,*root )
;         
;         *e\tree = *root\tree
;         Protected *children.CArrayPtr
;         
;       Case #Graph_Context_Operator
;         ;Protected *obj.C3DObject_t = *raa_current_scene\selection\GetValue(0)
;         Protected *obj.C3DObject_t = *raa_current_scene\objects\GetValue(0)
;         *e\tree = #Null
;         *e\dirty = #True
;         
;         If *obj<>#Null
;           Debug *obj\name
;           Protected *stack.CStack_t = *obj\stack
;           If *stack
;             ForEach *stack\nodes()
;               If *stack\nodes()\class\name = "GraphTree"
;                 *e\tree = *stack\nodes()
;                 Break
;               EndIf
;             Next
;           EndIf
;         EndIf
;         
;         
;         
;       Case #Graph_Context_Shader
;         Debug "[Graph Context] Switched To Shader Mode"
;         *e\tree = #Null
;         *e\dirty = #True
;         
;     EndSelect
;     
  EndProcedure
  
  
 
  Class::DEF(GraphUI)
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 1268
; FirstLine = 1250
; Folding = --------
; EnableXP
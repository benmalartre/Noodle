XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/UIColor.pbi"
XIncludeFile "Types.pbi"

;====================================================================
; NODE MODULE IMPLEMENTATION
;====================================================================
Module Node
  
  ; ----------------------------------------------------------------------------
  ;  Constructor
  ; ----------------------------------------------------------------------------
  Procedure.i New(*tree.Node::Node_t,name.s="",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    Protected *n.Node_t

    Protected *desc.Nodes::NodeDescription_t = Nodes::*graph_nodes(name)
    If *desc
      *n = *desc\constructor(*tree,name,x,y,w,h,c)
    EndIf
    
    ProcedureReturn(*n)

  EndProcedure
    
  ; ----------------------------------------------------------------------------
  ;  Destructor
  ; ----------------------------------------------------------------------------
  Procedure Delete( *Me.Node_t )
    ; ---[ Deallocate Underlying Arrays ]---------------------------------------
    FreeList(*Me\outputs())
    FreeList(*Me\inputs())
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
  
  EndProcedure
  
  ;------------------------------------
  ; UPDATE
  ;------------------------------------
  Procedure Update(*node.Node_t)

  EndProcedure
  
  ;------------------------------------
  ; Return Node Name
  ;------------------------------------
  Procedure.s GetName(*n.Node_t)
    ProcedureReturn(*n\type)
  EndProcedure
  
  ;------------------------------------
  ; Get Node Size
  ;------------------------------------
  Procedure GetSize(*n.Node_t)
    *n\height =  Graph::#Node_TitleHeight + Graph::#Node_PortSpacing * ListSize(*n\inputs())+Graph::#Node_PortSpacing * ListSize(*n\outputs())+6
    *n\width = 120
    *n\step1 =   Graph::#Node_TitleHeight/*n\height
    *n\step2 =  ( Graph::#Node_TitleHeight +  Graph::#Node_PortSpacing * ListSize(*n\outputs()))/*n\height
  EndProcedure

  ;------------------------------------
  ; Draw Node
  ;------------------------------------
  Procedure Draw(*n.Node_t)

    Protected offset.i = Graph::#Node_ShadowY
    Protected radius.i = Graph::#Node_CornerRadius
    Protected border = Graph::#Node_BorderUnselected
    
  ; -----------------------------------------------------------------------------------------------------
  ; Vector Drawing
  ; -----------------------------------------------------------------------------------------------------
  If *n\selected
    border = Graph::#Node_BorderSelected
  EndIf 
  Protected limit = *n\height* *n\step1
  ; Draw shadow
  If Graph::#Node_DrawShadow
    Vector::RoundBoxPath(*n\posx+Graph::#Node_ShadowX,
                         *n\posy+Graph::#Node_ShadowY-24,
                         *n\width+Graph::#Node_ShadowR,
                         *n\height+Graph::#Node_ShadowR+24,
                         Graph::#Node_CornerRadius)
   VectorSourceColor(RGBA(0,0,0,32))
   FillPath()
  EndIf

  ; Draw node
  Vector::RoundBoxPath(*n\posx, *n\posy, *n\width, *n\height, Graph::#Node_CornerRadius)
    ; Draw Contour
  VectorSourceColor(border)
  StrokePath(Graph::#NODE_BORDER_WIDTH,#PB_Path_RoundCorner|#PB_Path_Preserve)
  If *n\state = Graph::#Node_StateError
    VectorSourceColor(RGBA(255,122,0,255))
    FillPath()
  Else
    VectorSourceColor(RGBA(Red(*n\color),Green(*n\color),Blue(*n\color),255))
    FillPath()
  EndIf
  

;   If Not *n\leaf And Not *n\isroot
;     Protected o.i = 3
;     AddPathBox(*n\posx-o,*n\posy-o, *n\width+2*o, *n\height+2*o)
;     StrokePath(Node::NODE_BORDER_WIDTH,#PB_Path_RoundCorner)
;   EndIf

  
  
  ; Let some place for the node name
  Protected y =  *n\posy+(Graph::#Node_TitleHeight+Graph::#Node_PortSpacing/2)
  
  ; Load Title font
  VectorFont(FontID(Globals::#FONT_DEFAULT),12)
  Protected color = *n\color
 
  
  ; Draw Outputs
  radius = Graph::#Node_PortRadius
  Protected x = *n\posx+*n\width-(Graph::#Node_PortShiftX)
  ForEach *n\outputs()
    VectorSourceColor(RGBA(Red(*n\outputs()\color),Green(*n\outputs()\color),Blue(*n\outputs()\color),255))
    AddPathCircle(x,y,radius,0,360)
    FillPath()
    
    ; DrawingMode(#PB_2DDrawing_Outlined)
    If *n\outputs()\selected 
      VectorSourceColor(RGBA(255,255,255,255))
      AddPathCircle(x,y,radius)
      StrokePath(1)
    Else
      VectorSourceColor(RGBA(66,66,66,255))
      AddPathCircle(x,y,radius)
      StrokePath(1)
    EndIf
    
    
    Protected w = VectorTextWidth(*n\outputs()\name)
    VectorSourceColor(UIColor::COLORA_LABEL)
    MovePathCursor(x-w-2*Graph::#Node_PortRadius ,y+4-(Graph::#Node_PortSpacing / 2))
    AddPathText(*n\outputs()\name)
    FillPath()
  
    y + Graph::#Node_PortSpacing
  Next
  
  ; Draw Inputs
  x = *n\posx+(Graph::#Node_PortShiftX)
  ForEach *n\inputs()
    If *n\inputs()\currenttype=Attribute::#ATTR_TYPE_NEW 
      VectorSourceColor(RGBA(Red(*n\inputs()\color),Green(*n\inputs()\color),Blue(*n\inputs()\color),120))
      AddPathCircle(x,y,radius,0,360)
      FillPath()
      VectorSourceColor(RGBA(0,0,0,255))
      StrokePath(1)
      
    Else
      VectorSourceColor(RGBA(Red(*n\inputs()\color),Green(*n\inputs()\color),Blue(*n\inputs()\color),255))
      AddPathCircle(x,y,radius,0,360)
      FillPath()
    EndIf
    
    ; DrawingMode(#PB_2DDrawing_Outlined)
    If *n\inputs()\selected 
      VectorSourceColor(RGBA(255,255,255,255))
      AddPathCircle(x,y,radius)
      StrokePath(1)
    Else
      VectorSourceColor(RGBA(66,66,66,255))
      AddPathCircle(x,y,radius)
      StrokePath(1)
    EndIf

    VectorSourceColor(UIColor::COLORA_LABEL)
    MovePathCursor(x+2*Graph::#Node_PortRadius,y+4-(Graph::#Node_PortSpacing/2))
    AddPathText(*n\inputs()\name)
    FillPath()
    
    y + Graph::#Node_PortSpacing
  Next
  
  ; Draw Node Name
  VectorFont(FontID(Globals::#FONT_BOLD),14 )
  VectorSourceColor(UIColor::COLORA_LABEL)
  MovePathCursor(*n\posx+(10 ),*n\posy-(20 ))
  AddPathText(*n\label)
  FillPath()
      
;       ;Draw Edit Button
;       If Not *n\leaf And Not *n\isroot
;         
;         DrawingMode(#PB_2DDrawing_Default)
;         Protected ex,ey
;         ex = *n\viewx+*n\viewwidth-Graph::#Node_EditButtonShiftX * *n\z * 0.01
;         ey = *n\viewy-Graph::#Node_EditButtonShiftY * *n\z * 0.01
;         Box(*n\viewx+*n\viewwidth-2*Graph::#Graph_Compound_Border,*n\viewy-Graph::#Graph_Compound_Border,Graph::#Node_EditButtonRadius  ,Graph::#Node_EditButtonRadius,Graph::#Node_EditButtonColor)
;         ;Circle(ex,ey,Graph::#Node_EditButtonRadius * *n\z * 0.01,Graph::#Node_EditButtonColor)
;         
;         DrawingMode(#PB_2DDrawing_Outlined)
;         ;Circle(ex,ey,Graph::#Node_EditButtonRadius * *n\z * 0.01,border)
;         Box(*n\viewx+*n\viewwidth-10,*n\viewy-10,6,6,border)
;         
;         DrawingMode(#PB_2DDrawing_Transparent)
;         DrawingFont(FontID(Graph::font_node))
;         
;         DrawText(ex-Graph::#Node_EditButtonShiftX* *n\z *0.01+Graph::#Node_EditButtonRadius* *n\z * 0.01,ey-Graph::#Node_EditButtonShiftY * *n\z*0.01,"e",border)
;       EndIf

    
    
    
  EndProcedure
  
  ;------------------------------------
  ; Get Node ¨Position
  ;------------------------------------
  Procedure ViewSize(*n.Node_t)
    VectorFont(FontID(Globals::#FONT_BOLD),14 )
    *n\width = VectorTextWidth(*n\label)+32
    
    VectorFont(FontID(Globals::#FONT_DEFAULT),12 )
    Define cw.i
    ForEach *n\inputs()
      cw = VectorTextWidth(*n\inputs()\name + 32)
      If cw > *n\width : *n\width = cw : EndIf
    Next
    
    ForEach *n\outputs()
      cw = VectorTextWidth(*n\outputs()\name + 32)
      If cw > *n\width : *n\width = cw : EndIf
    Next
    
  EndProcedure
  

  ;------------------------------------
  ; Get Node ¨Position
  ;------------------------------------
  Procedure ViewPosition(*n.Node_t,x.i,y.i)
    ; get position and size
;     *n\viewx = *n\posx * zoom + x
;     *n\viewy = *n\posy * zoom + y
;     
;     *n\viewwidth = *n\width * zoom
;     *n\viewheight = *n\height * zoom
     
    ;update ports view position
    y = *n\posy+ (Graph::#Node_TitleHeight + Graph::#Node_PortSpacing/2) 
    x = *n\posx +*n\width -Graph::#Node_PortShiftX
    Protected r.i = Graph::#Node_PortRadius
    
    If ListSize(*n\outputs())
      ForEach *n\outputs()
        *n\outputs()\posx = x
        *n\outputs()\posy = y
;         *n\outputs()\viewr = r
        y + Graph::#Node_PortSpacing
      Next
    EndIf
    
    If ListSize(*n\inputs())
      x = *n\posx + Graph::#Node_PortShiftX
      ForEach *n\inputs()
        *n\inputs()\posx = x
        *n\inputs()\posy = y
;         *n\inputs()\viewr = r
        y + Graph::#Node_PortSpacing
      Next  
    EndIf
    
    
  EndProcedure
  
  ;------------------------------------
  ; Is Leaf
  ;------------------------------------
  Procedure.b IsLeaf(*n.Node_t)
    ForEach *n\inputs()
      If *n\inputs()\connected 
        ProcedureReturn #False
      EndIf
    Next
    ProcedureReturn #True
  EndProcedure
  
  ;------------------------------------
  ;Set Color
  ;------------------------------------
  Procedure SetColor(*n.Node_t,r.i,g.i,b.i)
    *n\color = RGB(r,g,b)
  EndProcedure
  
  ;------------------------------------
  ; Drag Node
  ;------------------------------------
  Procedure Drag(*n.Node_t,x.i,y.i)
    *n\posx + x
    *n\posy + y
    ViewPosition(*n,x,y) 
  EndProcedure
  
  ;------------------------------------
  ; Is Under Mouse
  ;------------------------------------
  Procedure.i IsUnderMouse(*n.Node_t,x.l,y.l)
    Protected margin.i = (Graph::#Node_PortSpacing/2)
    If x>(*n\posx-margin) And x<(*n\posx+*n\width+margin) And y>(*n\posy-margin) And (y<*n\posy+*n\height+margin)
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ;------------------------------------
  ; Is Inside Node
  ;------------------------------------
  Procedure.b InsideNode(*node.Node_t,*parent.Node_t)
    ForEach *parent\nodes()
      If *parent\nodes() = *node
        ProcedureReturn #True
      EndIf
    Next
    ProcedureReturn #False
  EndProcedure

  ;------------------------------------
  ; Select Node
  ;------------------------------------
  Procedure.i Pick(*n.Node_t,x.l,y.l,connect.b=#False)
    Protected margin.i = (Graph::#Node_PortSpacing/2) 

    ;check if we are selecting the edit button
    If Not *n\leaf
      Protected b1 = Bool(x>*n\posx+*n\width-Graph::#Node_EditButtonShiftX )
      Protected b2 = Bool(x<*n\posx+*n\width-Graph::#Node_EditButtonShiftX + Graph::#Node_EditButtonRadius)
      Protected b3 = Bool(y>*n\posy-Graph::#Node_EditButtonShiftY )
      Protected b4 = Bool(y<*n\posy-Graph::#Node_EditButtonShiftY + Graph::#Node_EditButtonRadius)
      If b1 And b2 And b3 And b4
        ProcedureReturn Graph::#Graph_Selection_Dive
      EndIf
      
    EndIf
      
    ;check if we are selecting a port for connexion
    ;if we are on the right of the node check for outputs port
    If x>*n\posx+*n\width - (Graph::#Node_PortShiftX +Graph::#Node_PortRadius)
      Define i.i = 1
      ForEach *n\outputs()
        If PickPort(*n,*n\outputs(),i,x,y) = #True
          *n\port = *n\outputs() 
          ProcedureReturn Graph::#Graph_Selection_Port
        EndIf
        i+1
      Next
      
    ;if we are on the left of the node check for inputs port
  ElseIf x<*n\posx + (Graph::#Node_PortShiftX + Graph::#Node_PortRadius)
    Define i = ListSize(*n\outputs())+1
      ForEach *n\inputs()
        If PickPort(*n,*n\inputs(),i,x,y) = #True
          *n\port = *n\inputs() 
          ProcedureReturn Graph::#Graph_Selection_Port
        EndIf
        i+1
      Next
    EndIf
    
    ;check if we are in connexion mode
    If connect 
      ProcedureReturn Graph::#Graph_Selection_Connexion
    EndIf
    
    ProcedureReturn Graph::#Graph_Selection_Node
  
  EndProcedure

  ;------------------------------------
  ; Select Port
  ;------------------------------------
  Procedure.b PickPort(*n.Node_t,*p.NodePort::NodePort_t,id.i,x.i,y.i)
    Protected r.i = Graph::#Node_PortRadius * 4 
    Protected py.i = *n\posy+ (Graph::#Node_TitleHeight) + (id-1) *(Graph::#Node_PortSpacing)
    Protected px.i = 0
      
    
    ;input port
    If *p\io = #False
      px = *n\posx+Graph::#Node_PortShiftX
      
    ;outputport
    Else
      px = *n\posx +*n\width - Graph::#Node_PortShiftX
    EndIf
    
    If x>px-r And x<px+r And y>py-r And y<py+r  
      *n\port = *p
      *p\selected = #True
      ProcedureReturn #True
    Else
      *p\selected = #False
      ProcedureReturn #False
    EndIf
    
  EndProcedure

  ;------------------------------------
  ; Get Port By ID
  ;------------------------------------
  Procedure.i GetPortByID(*n.Node_t,id.i)
    Protected nbOutputs.i = ListSize(*n\outputs())
    If id<=nbOutputs
      ProcedureReturn SelectElement(*n\outputs(),id)
    Else
      ProcedureReturn SelectElement(*n\inputs(),id-(nbOutputs+1))
    EndIf
    
  EndProcedure

  ;------------------------------------
  ; Get Port By Name
  ;------------------------------------
  Procedure.i GetPortByName(*n.Node_t,name.s)
    ForEach *n\inputs()
      If *n\inputs()\name = name : ProcedureReturn *n\inputs() :EndIf  
    Next
    ForEach *n\outputs()
      If *n\outputs()\name = name : ProcedureReturn *n\outputs() :EndIf  
    Next
  EndProcedure

  ;------------------------------------
  ; Set Ports IDs
  ;------------------------------------
  Procedure.i SetInputPortID(*n.Node_t,*p.NodePort::NodePort_t,id.i = -1)
    ;if id = -1 append it at the end of the list
    Protected nb.i = ListSize(*n\outputs())+ListSize(*n\inputs())-1
  
    If id = -1
      *p\id = nb
    Else
      *p\id = id
      ;if not last we need to offset existing ports id
      
      If id < nb
        ForEach *n\inputs()
          With *n\inputs()
            If \id>= nb
              \id+1
            EndIf
          EndWith
        Next
      EndIf
    EndIf  
    ProcedureReturn *p\id
  EndProcedure

  ;------------------------------------
  ; Set Output Port ID
  ;------------------------------------
  Procedure SetOutputPortID(*n.Node_t,*p.nodePort::NodePort_t,id.i = -1)
    ;if id = -1 append it at the end of the list
    Protected nb.i = ListSize(*n\outputs())-1
    If id = -1
      *p\id = nb
   
    Else
      *p\id = id
      ;if not last we need to offset existing ports id
      
      If id < nb
        ForEach *n\outputs()
          With *n\outputs()
            If \id>= nb
              \id+1
            EndIf
          EndWith
        Next
      EndIf
      
    EndIf
    ;we need to offset existing inputs ports id
    ForEach *n\inputs()
      With *n\inputs()
        If \id>= nb
          \id+1
        EndIf
      EndWith
    Next
  
    ProcedureReturn *p\id
  EndProcedure

  ;------------------------------------
  ; Update Ports
  ;------------------------------------
  Procedure UpdatePorts(*n.Node_t,datatype.i,datacontext.i,datastructure.i)
    ForEach *n\inputs()
      If *n\inputs()\polymorph
        *n\inputs()\currenttype = datatype
        *n\inputs()\currentcontext = datacontext
        *n\inputs()\datastructure = datastructure
        NodePort::GetColor(*n\inputs())
        NodePort::Update(*n\inputs(),datatype,datacontext,datastructure)
      EndIf
      
    Next
    ForEach *n\outputs()
      If *n\outputs()\polymorph
        *n\outputs()\currenttype = datatype
        *n\outputs()\currentcontext = datacontext
        *n\outputs()\datastructure = datastructure
        NodePort::GetColor(*n\outputs())
        NodePort::Update(*n\outputs(),datatype,datacontext,datastructure)
      EndIf
      
    Next
    
  EndProcedure

  ;------------------------------------
  ;AddInput Port
  ;------------------------------------
  Procedure AddInputPort(*n.Node_t,name.s,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
    Protected *p.NodePort::NodePort_t = NodePort::New(*n,name,#False,datatype,datacontext,datastructure)
    If ListSize(*n\inputs()) : LastElement(*n\inputs()) : EndIf
    Graph::AttachListElement(*n\inputs(),*p)
    Protected id.i = SetInputPortID(*n,*n\inputs(),-1)
    GetSize(*n)
    ProcedureReturn *p
  EndProcedure

  ;------------------------------------
  ;Remove Input Port
  ;------------------------------------
  Procedure RemoveInputPort(*n.Node_t,id.i)
    If ListSize(*n\inputs())>1:
      SelectElement(*n\inputs(),id)
      ; Remove from Affects
      ForEach *n\outputs()
        ForEach *n\outputs()\affects()
          If *n\outputs()\affects() = *n\inputs()
            DeleteElement(*n\outputs()\affects())
          EndIf
        Next
      Next
      DeleteElement(*n\inputs())
    EndIf
  EndProcedure
  
  ;------------------------------------
  ;On Message
  ;------------------------------------
  Procedure OnMessage(*n.Node_t,id.i)
    
  EndProcedure

  ;------------------------------------
  ;AddOutput Port
  ;------------------------------------
  Procedure AddOutputPort(*n.Node_t,name.s,datatype.i=Attribute::#ATTR_TYPE_UNDEFINED,datacontext.i=Attribute::#ATTR_CTXT_ANY,datastructure.i=Attribute::#ATTR_STRUCT_ANY)
    Protected *p.NodePort::NodePort_t = NodePort::New(*n,name,#True,datatype,datacontext,datastructure)
    LastElement(*n\outputs())
    Graph::AttachListElement(*n\outputs(),*p)
    Protected id.i = SetOutputPortID(*n,*n\outputs(),-1)
    GetSize(*n)
    ProcedureReturn *p
  EndProcedure
  
  ;------------------------------------
  ; Is Node Dirty
  ;------------------------------------
  Procedure IsDirty(*n.Node_t)
    ForEach(*n\outputs())
      If *n\outputs()\dirty
        ProcedureReturn #True
      EndIf
    Next
  EndProcedure
  
  ;------------------------------------
  ; Update Dirty
  ;------------------------------------
  Procedure UpdateDirty(*n.Node_t)
    ForEach(*n\inputs())
      If *n\inputs()\connected
        If *n\inputs()\source\dirty
          *n\inputs()\dirty = #True
        EndIf
      EndIf
    Next
    UpdateAffects(*n)
    ForEach(*n\inputs())
      *n\inputs()\dirty = #False
    Next
    
  EndProcedure
  
  ;------------------------------------
  ; Port Affect
  ;------------------------------------
  Procedure PortAffectByName(*n.Node_t, sourceName.s, targetName.s)
    Protected *source.NodePort::NodePort_t = GetPortByName(*n, sourceName)
    Protected *target.NodePort::NodePort_t = GetPortByName(*n, targetName)
    AddElement(*target\affects())
    *target\affects() = *source
  EndProcedure
  
  ;------------------------------------
  ; Port Affect
  ;------------------------------------
  Procedure PortAffectByPort(*n.Node_t, *source.NodePort::NodePort_t, *target.NodePort::NodePort_t)
    AddElement(*target\affects())
    *target\affects() = *source
  EndProcedure
  
  ;------------------------------------
  ; Update Affects
  ;------------------------------------
  Procedure UpdateAffects(*n.Node_t)
    ForEach *n\outputs()
      ForEach *n\outputs()\affects()
        If *n\outputs()\affects()\dirty : *n\outputs()\dirty = #True : EndIf
      Next
    Next
    ForEach *n\inputs()
      *n\inputs()\dirty = #False
    Next
    
  EndProcedure
  
  ;------------------------------------
  ; Set Clean
  ;------------------------------------
  Procedure SetClean(*n.Node_t)
    ForEach *n\inputs() : *n\inputs()\dirty = #False : Next
    ForEach *n\outputs() : *n\outputs()\dirty = #False : Next
  EndProcedure
  
  ;----------------------------------------------
  ; Inspect Node
  ;----------------------------------------------
  Procedure Inspect(*n.Node_t)
    Debug "Hohoho what a funny joke"
  EndProcedure
  
  ;----------------------------------------------
  ; On Connection
  ;----------------------------------------------
  Procedure OnConnect(*n.Node_t, *port.NodePort::NodePort_t)
    MessageRequester("XXX", "Hohoho this is a dummy connection callback on port ---> "+*port\name)
    
  EndProcedure
  
  ;----------------------------------------------
  ; On Disconnection
  ;----------------------------------------------
  Procedure OnDisconnect(*n.Node_t, *port.NodePort::NodePort_t)
    Debug "Hohoho this is a dummy disconnection callback"
  EndProcedure

  Class::DEF(Node)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 28
; FirstLine = 8
; Folding = ------
; EnableThread
; EnableXP
; EnableUnicode
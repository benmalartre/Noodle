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
  ; ============================================================================
  ; ---[ Heap ]-----------------------------------------------------------------
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
    ; ---[ Deallocate Underlying Arrays ]------------------------------------
    FreeList(*Me\outputs())
    FreeList(*Me\inputs())
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
  
  EndProcedure
  
  ;------------------------------------
  ; UPDATE
  ;------------------------------------
  Procedure Update(*node.Node_t)
    Debug "Node Update Called..."
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
    
    ForEach *n\outputs()
      *n\outputs()\percx = (*n\viewx +*n\viewwidth - Graph::#Node_PortShiftX)/*n\width
      *n\outputs()\percy = ( Graph::#Node_TitleHeight + Graph::#Node_PortSpacing * *n\outputs()\id)/*n\height
    Next
    
    ForEach *n\inputs()
      *n\inputs()\percx = (*n\viewx +Graph::#Node_PortShiftX)/*n\width
      *n\inputs()\percy = (Graph::#Node_TitleHeight +*n\inputs()\id)*Graph::#Node_PortSpacing/*n\height
    Next
      
  EndProcedure

  ;------------------------------------
  ; Draw Node
  ;------------------------------------
  Procedure Draw(*n.Node_t, zoom.f)

    Protected offset.i = Graph::#Node_ShadowY* zoom
    Protected radius.i = Graph::#Node_CornerRadius * zoom
    Protected border = Graph::#Node_BorderUnselected
    
    CompilerIf Not Globals::#USE_VECTOR_DRAWING
      If *n\selected
        border = Graph::#Node_BorderSelected
      EndIf 
      
      If Graph::#Node_DrawShadow And z>0.33
        ;Shadow Box
        ;RoundBox(*n\viewx+offset, *n\viewy+offset, *n\viewwidth, *n\viewheight ,radius,radius,RGBA(0,0,0,50))
         DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
         GradientColor(0,RGBA(66,66,66,255))
      ;    GradientColor(0.5,RGBA(11,11,33,100))
      ;    GradientColor(0.75,RGBA(11,11,33,30))
         GradientColor(1,RGBA(66,66,66,0))
         Protected ltx,lty,rtx,rty,lbx,lby,rbx,rby
         Protected litx,lity,ritx,rity,libx,liby,ribx,riby
         Protected s_width.f = Graph::#Node_ShadowR/2*zoom
         
         
         ltx = *n\viewx + Graph::#Node_ShadowX * zoom - s_width 
         lty = *n\viewy -20 * zoom + Graph::#Node_ShadowY * zoom - s_width
         rtx = *n\viewx + *n\viewwidth + Graph::#Node_ShadowX * zoom + s_width 
         rty = *n\viewy -20 * zoom + Graph::#Node_ShadowY * zoom - s_width
         lbx = *n\viewx + Graph::#Node_ShadowX * zoom - s_width 
         lby = *n\viewy + *n\viewheight + Graph::#Node_ShadowY * zoom + s_width 
         rbx = *n\viewx + *n\viewwidth + Graph::#Node_ShadowX * zoom + s_width 
         rby = *n\viewy + *n\viewheight + Graph::#Node_ShadowY * zoom + s_width 
         
         litx = ltx  + Graph::#Node_ShadowR
         lity = lty  + Graph::#Node_ShadowR
         ritx = rtx  - Graph::#Node_ShadowR
         rity = rty  + Graph::#Node_ShadowR
         libx = lbx  + Graph::#Node_ShadowR
         liby = lby  - Graph::#Node_ShadowR
         ribx = rbx  - Graph::#Node_ShadowR
         riby = rby  - Graph::#Node_ShadowR
        
        ;Top Gradient
         LinearGradient(litx,lity,litx,lty)
         Box(litx,lty,ritx-litx,Graph::#Node_ShadowR)
         
         ;Bottom Gradient
         LinearGradient(libx,liby,libx,lby)
         Box(libx,liby,ribx-libx,Graph::#Node_ShadowR)
         
         ;Left Gradient
         LinearGradient(litx,lity,lbx,lity)
         Box(ltx,lity,Graph::#Node_ShadowR,liby-lity)
         
         ;Right Gradient
         LinearGradient(ritx,lity,rtx,lity)
         Box(ritx,lity,Graph::#Node_ShadowR,riby-rity)
         
         ;Left Top Corner
         CircularGradient(litx,lity,Graph::#Node_ShadowR)
         Box(ltx,lty,Graph::#Node_ShadowR,Graph::#Node_ShadowR)
         
         ;Right Top Corner
         CircularGradient(ritx,rity,Graph::#Node_ShadowR)
         Box(ritx,rty,Graph::#Node_ShadowR,Graph::#Node_ShadowR)
         
         ;Left Bottom Corner
         CircularGradient(libx,liby,Graph::#Node_ShadowR)
         Box(lbx,liby,Graph::#Node_ShadowR,Graph::#Node_ShadowR)
         
         ;Right Bottom Corner
         CircularGradient(ribx,riby,Graph::#Node_ShadowR)
         Box(ribx,riby,Graph::#Node_ShadowR,Graph::#Node_ShadowR)
         
         ; Center Rectangle
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        Box(litx,lity,ribx-litx,riby-lity,RGBA(66,66,66,255))
      EndIf
      
      ;Top Box
      DrawingMode(#PB_2DDrawing_Default)
      RoundBox(*n\viewx,*n\viewy-20 * zoom,*n\viewwidth,40 * zoom,radius,radius,RGB(200,200,200))
      
      ;Actual Box
      
      Protected limit = *n\viewheight* *n\step1
      If *n\state = Graph::#Node_StateError
        RoundBox(*n\viewx,*n\viewy, *n\viewwidth, *n\viewheight ,radius,radius,RGB(255,0,0))
      Else
        RoundBox(*n\viewx,*n\viewy, *n\viewwidth, *n\viewheight ,radius,radius,*n\color)
      EndIf

      ;Contours
      DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_Outlined|#PB_2DDrawing_AlphaBlend)
      RoundBox(*n\viewx,*n\viewy, *n\viewwidth, *n\viewheight ,radius,radius,border)
      If Not *n\leaf And Not *n\isroot
        Protected o.i = 3 * zoom
        RoundBox(*n\viewx-o,*n\viewy-o, *n\viewwidth+2*o, *n\viewheight+2*o ,radius,radius,border)
      EndIf
      
      ;Let some place for the node name
      Protected y =  *n\viewy+(Graph::#Node_TitleHeight+Graph::#Node_PortSpacing/2) * zoom
      DrawingMode(#PB_2DDrawing_Default)
      
      ;Load Title font
      DrawingFont(FontID(Graph::font_port))
      
      Protected color = *n\color

      ;Draw Outputs
      radius = Graph::#Node_PortRadius * zoom
      Protected x = *n\viewx+*n\viewwidth-(Graph::#Node_PortShiftX) * zoom
      ForEach *n\outputs()
        DrawingMode(#PB_2DDrawing_Default)
        Circle(x,y,radius,*n\outputs()\color)
        
    ;     DrawingMode(#PB_2DDrawing_Outlined)
    ;     If *n\outputs()\selected 
    ;       Circle(x,y,radius,RGB(255,255,255))
    ;     Else
    ;       Circle(x,y,radius,RGB(66,66,66))
    ;     EndIf
        
        
        If zoom>0.33
          DrawingMode(#PB_2DDrawing_Transparent)
          Protected w = TextWidth(*n\outputs()\name)
          DrawText(x-w-2*Graph::#Node_PortRadius * zoom,y-(Graph::#Node_PortSpacing/2 * zoom),*n\outputs()\name,Graph::#Node_BorderUnselected)
        EndIf
      
        y + Graph::#Node_PortSpacing * zoom
      Next
      
      ;Draw Inputs
      x = *n\viewx+(Graph::#Node_PortShiftX) * zoom
      ForEach *n\inputs()
        If *n\inputs()\currenttype=Attribute::#ATTR_TYPE_NEW 
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          Circle(x,y,radius,RGBA(Red(*n\inputs()\color),Green(*n\inputs()\color),Blue(*n\inputs()\color),66))
        Else
          DrawingMode(#PB_2DDrawing_Default)
          Circle(x,y,radius,*n\inputs()\color)
        EndIf
        
    ;     DrawingMode(#PB_2DDrawing_Outlined)
    ;     If *n\inputs()\selected 
    ;       Circle(x,y,radius,RGB(255,255,255))
    ;     Else
    ;       Circle(x,y,radius,RGB(66,66,66))
    ;     EndIf
    
        If zoom>0.33
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(x+2*Graph::#Node_PortRadius * zoom,y-(Graph::#Node_PortSpacing/2 * zoom),*n\inputs()\name,Graph::#Node_BorderUnselected)
        EndIf
        y + Graph::#Node_PortSpacing * zoom
      Next
     
      ;Draw Node Name
      If zoom>0.2
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawingFont(FontID(Graph::font_node))
        
        DrawText(*n\viewx+(10 * zoom),*n\viewy-(20 * zoom),*n\label,border)
      EndIf
      
      ;Draw Edit Button
      If Not *n\leaf And Not *n\isroot
        
        DrawingMode(#PB_2DDrawing_Default)
        Protected ex,ey
        ex = *n\viewx+*n\viewwidth-Graph::#Node_EditButtonShiftX * zoom
        ey = *n\viewy-Graph::#Node_EditButtonShiftY * zoom
        Circle(ex,ey,Graph::#Node_EditButtonRadius * zoom,Graph::#Node_EditButtonColor)
        
        DrawingMode(#PB_2DDrawing_Outlined)
        Circle(ex,ey,Graph::#Node_EditButtonRadius * zoom,border)
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawingFont(FontID(Graph::font_node))
        
        DrawText(ex-Graph::#Node_EditButtonShiftX * zoom+Graph::#Node_EditButtonRadius * zoom,ey-Graph::#Node_EditButtonShiftY * zoom,"e",border)
      EndIf
    CompilerElse
      If *n\selected
        border = Graph::#Node_BorderSelected
      EndIf 
      
      ;Actual Box
      Protected limit = *n\viewheight* *n\step1
     
      If *n\state = Graph::#Node_StateError
        VectorSourceColor(RGBA(255,122,0,255))
        ;Top Part
        MovePathCursor(*n\viewx+Graph::#Node_CornerRadius* zoom,*n\viewy)
        AddPathArc(*n\viewx+*n\viewwidth,*n\viewy,*n\viewx+*n\viewwidth,*n\viewy+*n\viewheight-Graph::#Node_CornerRadius* zoom,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        AddPathArc(*n\viewx+*n\viewwidth,*n\viewy+*n\viewheight,*n\viewx,*n\viewy+*n\viewheight-1,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        AddPathArc(*n\viewx,*n\viewy+*n\viewheight,*n\viewx,*n\viewy,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        AddPathArc(*n\viewx,*n\viewy,*n\viewx+*n\viewwidth,*n\viewy,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(RGBA(Red(*n\color),Green(*n\color),Blue(*n\color),255))
        MovePathCursor(*n\viewx+Graph::#Node_CornerRadius* zoom,*n\viewy)
        AddPathArc(*n\viewx+*n\viewwidth,*n\viewy,*n\viewx+*n\viewwidth,*n\viewy+*n\viewheight-Graph::#Node_CornerRadius* zoom,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        AddPathArc(*n\viewx+*n\viewwidth,*n\viewy+*n\viewheight,*n\viewx,*n\viewy+*n\viewheight-1,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        AddPathArc(*n\viewx,*n\viewy+*n\viewheight,*n\viewx,*n\viewy,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        AddPathArc(*n\viewx,*n\viewy,*n\viewx+*n\viewwidth,*n\viewy,Graph::#Node_CornerRadius* zoom,#PB_Path_Default)
        FillPath(#PB_Path_Preserve)
      EndIf
    
      ;Contours
      VectorSourceColor(border)
      StrokePath(Node::NODE_BORDER_WIDTH,#PB_Path_RoundCorner)
      If Not *n\leaf And Not *n\isroot
        Protected o.i = 3 * zoom
        AddPathBox(*n\viewx-o,*n\viewy-o, *n\viewwidth+2*o, *n\viewheight+2*o)
        StrokePath(Node::NODE_BORDER_WIDTH,#PB_Path_RoundCorner)
      EndIf
      
       ;Let some place for the node name
      Protected y =  *n\viewy+(Graph::#Node_TitleHeight+Graph::#Node_PortSpacing/2)* zoom
      
      ;Load Title font
      VectorFont(FontID(Graph::font_port),12 * zoom)
      Protected color = *n\color
     
      
      ;Draw Outputs
      radius = Graph::#Node_PortRadius* zoom
      Protected x = *n\viewx+*n\viewwidth-(Graph::#Node_PortShiftX) * zoom
      ForEach *n\outputs()
        VectorSourceColor(RGBA(Red(*n\outputs()\color),Green(*n\outputs()\color),Blue(*n\outputs()\color),255))
        AddPathCircle(x,y,radius,0,360)
        FillPath()
        
        ;DrawingMode(#PB_2DDrawing_Outlined)
        If *n\outputs()\selected 
          VectorSourceColor(RGBA(255,255,255,255))
          AddPathCircle(x,y,radius)
          StrokePath(1)
        Else
          VectorSourceColor(RGBA(66,66,66,255))
          AddPathCircle(x,y,radius)
          StrokePath(1)
        EndIf
        
        
        If zoom>0.33
          Protected w = VectorTextWidth(*n\outputs()\name)
          VectorSourceColor(UIColor::COLORA_LABEL)
          MovePathCursor(x-w-2*Graph::#Node_PortRadius * zoom,y+4*zoom-(Graph::#Node_PortSpacing / 2 * zoom))
          AddPathText(*n\outputs()\name)
          FillPath()
        EndIf
      
        y + Graph::#Node_PortSpacing* zoom
      Next
      
      ;Draw Inputs
      x = *n\viewx+(Graph::#Node_PortShiftX) * zoom
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
        
        ;DrawingMode(#PB_2DDrawing_Outlined)
        If *n\inputs()\selected 
          VectorSourceColor(RGBA(255,255,255,255))
          AddPathCircle(x,y,radius)
          StrokePath(1)
        Else
          VectorSourceColor(RGBA(66,66,66,255))
          AddPathCircle(x,y,radius)
          StrokePath(1)
        EndIf
    
        If zoom>0.33
          VectorSourceColor(UIColor::COLORA_LABEL)
          MovePathCursor(x+2*Graph::#Node_PortRadius * zoom,y+4* zoom-(Graph::#Node_PortSpacing/2* zoom))
          AddPathText(*n\inputs()\name)
          FillPath()
        EndIf
        y + Graph::#Node_PortSpacing* zoom
      Next
      
      ;Draw Node Name
      If zoom>0.2
        VectorFont(FontID(Graph::FONT_NODE),12 * zoom)
        VectorSourceColor(UIColor::COLORA_LABEL)
        MovePathCursor(*n\viewx+(10 * zoom),*n\viewy-(20 * zoom))
        AddPathText(*n\label)
        FillPath()
      EndIf
      
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
      
    CompilerEndIf
    
    
    
  EndProcedure
  
  ;------------------------------------
  ; Get Node ¨Position
  ;------------------------------------
  Procedure ViewSize(*n.Node_t,z.i)
    *n\width = Math::Max(TextWidth(*n\label)+50,80)
  EndProcedure
  

  ;------------------------------------
  ; Get Node ¨Position
  ;------------------------------------
  Procedure ViewPosition(*n.Node_t,zoom.f,x.i,y.i)
    ; get position and size
    *n\viewx = *n\posx * zoom + x
    *n\viewy = *n\posy * zoom + y
    
    *n\viewwidth = *n\width * zoom
    *n\viewheight = *n\height * zoom
     
    ;update ports view position
    y = *n\viewy+ (Graph::#Node_TitleHeight + Graph::#Node_PortSpacing/2) * zoom
    x = *n\viewx +*n\viewwidth -Graph::#Node_PortShiftX * zoom
    Protected r.i = Graph::#Node_PortRadius* zoom
    
    If ListSize(*n\outputs())
      ForEach *n\outputs()
        *n\outputs()\viewx = x
        *n\outputs()\viewy = y
        *n\outputs()\viewr = r
        y + Graph::#Node_PortSpacing * zoom
      Next
    EndIf
    
    If ListSize(*n\inputs())
      x = *n\viewx + Graph::#Node_PortShiftX * zoom
      ForEach *n\inputs()
        *n\inputs()\viewx = x
        *n\inputs()\viewy = y
        *n\inputs()\viewr = r
        y + Graph::#Node_PortSpacing * zoom
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
  Procedure Drag(*n.Node_t,x.i,y.i,zoom.f)
    *n\posx + (x*1.0/zoom)
    *n\posy + (y*1.0/zoom)
    ViewPosition(*n,zoom,x,y)
    
  EndProcedure
  
  ;------------------------------------
  ; Is Under Mouse
  ;------------------------------------
  Procedure.i IsUnderMouse(*n.Node_t,x.l,y.l,zoom.f)
    Protected margin.i = (Graph::#Node_PortSpacing/2) * zoom
    If x>(*n\viewx-margin) And x<(*n\viewx+*n\viewwidth+margin) And y>(*n\viewy-margin) And (y<*n\viewy+*n\viewheight+margin)
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
  Procedure.i Pick(*n.Node_t,x.l,y.l,zoom.f,connect.b=#False)
    Protected margin.i = (Graph::#Node_PortSpacing/2) * zoom

    ;check if we are selecting the edit button
    If Not *n\leaf
      Protected b1 = Bool(x>*n\viewx+*n\viewwidth-Graph::#Node_EditButtonShiftX* zoom )
      Protected b2 = Bool(x<*n\viewx+*n\viewwidth-Graph::#Node_EditButtonShiftX* zoom + Graph::#Node_EditButtonRadius * zoom)
      Protected b3 = Bool(y>*n\viewy-Graph::#Node_EditButtonShiftY* zoom )
      Protected b4 = Bool(y<*n\viewy-Graph::#Node_EditButtonShiftY* zoom + Graph::#Node_EditButtonRadius * zoom)
      If b1 And b2 And b3 And b4
        ProcedureReturn Graph::#Graph_Selection_Dive
      EndIf
      
    EndIf
      
    ;check if we are selecting a port for connexion
    ;if we are on the right of the node check for outputs port
    If x>*n\viewx+*n\viewwidth - (Graph::#Node_PortShiftX +Graph::#Node_PortRadius)* zoom
      Define i.i = 1
      ForEach *n\outputs()
        If PickPort(*n,*n\outputs(),i,x,y,zoom) = #True
          *n\port = *n\outputs() 
          ProcedureReturn Graph::#Graph_Selection_Port
        EndIf
        i+1
      Next
      
    ;if we are on the left of the node check for inputs port
  ElseIf x<*n\viewx + (Graph::#Node_PortShiftX + Graph::#Node_PortRadius)* zoom
    Define i = ListSize(*n\outputs())+1
      ForEach *n\inputs()
        If PickPort(*n,*n\inputs(),i,x,y,zoom) = #True
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
  Procedure.b PickPort(*n.Node_t,*p.NodePort::NodePort_t,id.i,x.i,y.i, zoom.f)
    Protected r.i = Graph::#Node_PortRadius * 4 * zoom
    Protected py.i = *n\viewy+ (Graph::#Node_TitleHeight* zoom) + (id-1) *(Graph::#Node_PortSpacing * zoom)
    Protected px.i = 0
      
    
    ;input port
    If *p\io = #False
      px = *n\viewx+Graph::#Node_PortShiftX
      
    ;outputport
    Else
      px = *n\viewx +*n\viewwidth - Graph::#Node_PortShiftX
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

  Class::DEF(Node)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 1
; Folding = ------
; EnableThread
; EnableXP
; EnableUnicode
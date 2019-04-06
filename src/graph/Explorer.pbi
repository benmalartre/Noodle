XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../graph/Compound.pbi"

; ============================================================================
;  NODE EXPLORER MODULE DECLARATION
; ============================================================================
DeclareModule NodeExplorer
  ; ============================================================================
  ;  Constants
  ; ============================================================================
  #NodeExplorer_CategoryH = 20
  #NodeExplorer_DescriptionH = 16
  #NodeExplorer_ItemHeight = 12
  #NodeExplorer_SpacingX = 20
  #NodeExplorer_SpacingY =10
  #NodeExplorer_Description = 1
  #NodeExplorer_Category = 2
  
  ; ============================================================================
  ;  Instance
  ; ============================================================================
  Structure NodeExplorerNode_t
    selected.b
    id.i
    type.i
    *object
  EndStructure
 
  Structure NodeExplorer_t
    name.s
    gadgetID.i
    imageID.i
    pickID.i
  ;   search.CControlEdit
  ;   refresh.CControlIcon
  ;   clear.CControlIcon
    x.i
    y.i
    width.i
    height.i
    iwidth.i
    iheight.i
    down.b
    
    scrollx.i
    scrolly.i
    scrolllastx.i
    scrolllasty.i
    scrollmaxx.i
    scrollmaxy.i
    *selected.NodeExplorerNode_t
    Map *nodes.NodeExplorerNode_t()
  EndStructure
  
  Declare New(x.i,y.i,width.i,height.i)
  Declare Delete(*explorer.NodeExplorer_t)
  Declare NewNode(type.i,*obj)
  Declare DeleteNode(*n.NodeExplorerNode_t)
  Declare GetGadgetID(*explorer.NodeExplorer_t)
  Declare GetImageSize(*explorer.NodeExplorer_t)
  Declare Clear(*explorer.NodeExplorer_t)
  Declare Draw(*explorer.NodeExplorer_t)
  Declare DrawPicture(*explorer.NodeExplorer_t)
  Declare DrawPickImage(*explorer.NodeExplorer_t)
  Declare OnEvent(*explorer.NodeExplorer_t,eventID.i,*ev_data.Control::EventTypeDatas_t)
  Declare Pick(*explorer.NodeExplorer_t)
  Declare Drag(*explorer.NodeExplorer_t)
  Declare GetScrollArea(*Me.NodeExplorer_t)

EndDeclareModule

; ============================================================================
;  NODEEXPLORER MODULE IMPLEMENTATION
; ============================================================================
Module NodeExplorer
  ; ============================================================================
;  CONSTRUCTOR
; ============================================================================
Procedure New(x.i,y.i,width.i,height.i)
  Protected *Me.NodeExplorer_t = AllocateMemory(SizeOf(NodeExplorer_t))
  InitializeStructure(*Me,NodeExplorer_t)
  
  Debug "Create Graph Node Explorer : "+Str(x)+","+Str(y)
  *Me\gadgetID = CanvasGadget(#PB_Any,x,y,width,height,#PB_Canvas_Keyboard|#PB_Canvas_DrawFocus)

  *Me\imageID = CreateImage(#PB_Any,width,height)
  *Me\pickID = CreateImage(#PB_Any,width,height)
  *Me\x = x
  *Me\y = y
  *Me\width = width
  *Me\height = height
;   *Me\search = newCControlEdit("Search","",0,5,5,100,20)
;   *Me\refresh = newCControlIcon("Refresh",#RAA_Icon_Loop,#False,0,100,5,16,16)
;   *Me\clear = newCControlIcon("Clear",#RAA_Icon_Close,#False,0,120,5,16,16)
  
  GetImageSize(*Me)
  DrawPickImage(*Me)
  DrawPicture(*Me)
  Draw(*Me)
  GetScrollArea(*Me)
  ProcedureReturn *Me
EndProcedure

; ============================================================================
;  Destructor
; ============================================================================
Procedure Delete(*explorer.NodeExplorer_t)
 FreeMemory(*explorer)
EndProcedure

  ; ----------------------------------------------------------------------------
  ;  New Node
  ; ----------------------------------------------------------------------------
  Procedure NewNode(type.i,*obj)
    Protected *n.NodeExplorerNode_t = AllocateMemory(SizeOf(NodeExplorerNode_t))
    *n\type = type
    *n\object = *obj
    ProcedureReturn *n
  EndProcedure
  
  Procedure DeleteNode(*n.NodeExplorerNode_t)
    FreeMemory(*n)
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Get Gadget ID
  ; ----------------------------------------------------------------------------
  Procedure GetGadgetID(*explorer.NodeExplorer_t)
    ProcedureReturn(*explorer\gadgetID)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Clear
  ; ----------------------------------------------------------------------------
  Procedure Clear(*explorer.NodeExplorer_t)
    Protected key.s
    ForEach *explorer\nodes()
      key = MapKey(*explorer\nodes())
      DeleteNode(*explorer\nodes())
      DeleteMapElement(*explorer\nodes(),key)
    Next
    ;ClearMap(*explorer\nodes())
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Get Image Size
  ; ----------------------------------------------------------------------------
  Procedure GetImageSize(*explorer.NodeExplorer_t)
    Protected msg.s
    Protected *category.Nodes::NodeCategory_t
    Protected *node.Nodes::NodeDescription_t
    Protected width,height,w
    width = *explorer\width
    height = 20
    StartDrawing(ImageOutput(*explorer\imageID))
    ForEach Nodes::*graph_nodes_category()
      *category = Nodes::*graph_nodes_category()
      msg + "CATEGORY : "+*category\label+Chr(10)
      w = TextWidth(*category\label)+NodeExplorer::#NodeExplorer_SpacingX
      If w>width
        width = w
      EndIf
      
      height+NodeExplorer::#NodeExplorer_CategoryH
      If *category\expended
        ForEach *category\nodes()
          *node = *category\nodes()
          
          w = TextWidth(*category\label)+NodeExplorer::#NodeExplorer_SpacingX
          If w>width
            width = w
          EndIf
          height+NodeExplorer::#NodeExplorer_DescriptionH
        Next
      EndIf
      
    Next
    StopDrawing()
    
    *explorer\iwidth = width
    *explorer\iheight = height
    
    ResizeImage(*explorer\imageID,width,height)
    ResizeImage(*explorer\pickID,width,height)
   
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  GetSCroll Area
  ; ----------------------------------------------------------------------------
  Procedure GetScrollArea(*Me.NodeExplorer_t)
      If *Me\width>*Me\iwidth : *Me\scrollmaxx = 0 : Else : *Me\scrollmaxx = *Me\iwidth-*Me\width : EndIf
      If *Me\height>*Me\iheight : *Me\scrollmaxy = 0 : Else : *Me\scrollmaxy = *Me\iheight-*Me\height : EndIf
    EndProcedure
    
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw(*explorer.NodeExplorer_t)
    StartDrawing(CanvasOutput(*explorer\gadgetID))
    Box(0,0,GadgetWidth(*explorer\gadgetID),GadgetHeight(*explorer\gadgetID),UIColor::COLOR_MAIN_BG)
    DrawImage(ImageID(*explorer\imageID),*explorer\scrollx,*explorer\scrolly)
  ;   DrawImage(ImageID(*explorer\pickID),*explorer\scrollx+100,*explorer\scrolly)
    StopDrawing()
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Draw Image
  ; ----------------------------------------------------------------------------
  Procedure DrawPicture(*explorer.NodeExplorer_t)
    Protected *category.Nodes::NodeCategory_t
    Protected *node.Nodes::NodeDescription_t
    Protected x,y
    StartDrawing(ImageOutput(*explorer\imageID))
    
    DrawingMode(#PB_2DDrawing_AllChannels)
    Box(0,0,*explorer\iwidth,*explorer\iheight,UIColor::COLOR_MAIN_BG)
  
    ForEach Nodes::*graph_nodes_category()
  
      *category = Nodes::*graph_nodes_category()
      DrawingMode(#PB_2DDrawing_Default)
      RoundBox(5,y,*explorer\iwidth-10,NodeExplorer::#NodeExplorer_CategoryH,3,3,RGBA(120,160,200,150))
      DrawingMode(#PB_2DDrawing_Outlined)
      RoundBox(5,y,*explorer\iwidth-10,NodeExplorer::#NodeExplorer_CategoryH,3,3,RGBA(66,66,66,125))
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Globals::#FONT_MENU))
      DrawText(10,y+1,*category\label,RGBA(0,0,0,255))
      y+NodeExplorer::#NodeExplorer_CategoryH
      If *category\expended
        ;DrawingFont(FontID(*explorer\font_node))
        DrawingFont(FontID(Globals::#FONT_NODE))
        ForEach *category\nodes()
          *node = *category\nodes()
          
          ;Highlight selected items
          If *node\selected
            Box(5,y,*explorer\iwidth-10,NodeExplorer::#NodeExplorer_DescriptionH,RGBA(255,255,255,120))
            *node\selected = #False
          EndIf
    
          DrawText(20,y+1,*node\label,RGBA(0,0,0,255))
          y+NodeExplorer::#NodeExplorer_DescriptionH
        Next
      EndIf
      
    Next
  
    StopDrawing()
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------------------------------------------
  Procedure DrawPickImage(*explorer.NodeExplorer_t)
    Protected *node.NodeExplorerNode_t
    Protected *category.Nodes::NodeCategory_t
    Protected *desc.Nodes::NodeDescription_t
    
    ; Clear Old Data
    ; ClearMap(*explorer\nodes())
    Clear(*explorer)
    Protected x,y
    x=0
    y=0
    StartDrawing(ImageOutput(*explorer\pickID))
    Box(0,0,*explorer\iwidth,*explorer\iheight,RGB(0,0,0))
    
    Protected id=1
    ForEach Nodes::*graph_nodes_category()
  
       *category = Nodes::*graph_nodes_category()
       DrawingMode(#PB_2DDrawing_Default)
       Box(0,y,*explorer\width,NodeExplorer::#NodeExplorer_CategoryH,RGB(id,0,0))
       *explorer\nodes(Str(id)) = NewNode(NodeExplorer::#NodeExplorer_Category,*category)
       id+1
       y+NodeExplorer::#NodeExplorer_CategoryH
      If *category\expended
  ;       Box(5,y,*explorer\iwidth-10,14,RGB(id,0,0))
  ;       id+1
        ForEach *category\nodes()
          *desc = *category\nodes()
          *desc\color_id = id
         ; *explorer\nodes(Str(id)) = *node
          *explorer\nodes(Str(id)) = NewNode(NodeExplorer::#NodeExplorer_Description,*desc)
          Box(0,y,*explorer\iwidth,NodeExplorer::#NodeExplorer_DescriptionH,RGB(id,0,0))
          y+NodeExplorer::#NodeExplorer_DescriptionH
          id+1
        Next
      EndIf
    Next
    StopDrawing()
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Pick
  ; ----------------------------------------------------------------------------
  Procedure Pick(*explorer.NodeExplorer_t)
    Debug "########################### EXPLORER PICK ##################################"
    Protected x,y, color
    x = GetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_MouseX)-*explorer\scrollx
    y = GetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_MouseY)-*explorer\scrolly
    
    ; Exit if outside drawing area
    If x<0 Or x> ImageWidth(*explorer\pickID)-1 Or y<0 Or y>ImageHeight(*explorer\pickID)-1
      ProcedureReturn
    EndIf
  
    
    ; Get Color ID under mouse position
    StartDrawing(ImageOutput(*explorer\pickID))
    color = Point(x,y)
    StopDrawing()
    
    ;ID is stored in Red Channel
    Protected id = Red(color)
    If id <= 0 Or id>MapSize(*explorer\nodes()): ProcedureReturn : EndIf
    
    ; Select Node
    If FindMapElement(*explorer\nodes(),Str(id))
      Protected *node.NodeExplorerNode_t = *explorer\nodes()
      If *node 
    
        If *explorer\selected
          *explorer\selected\selected = #False
        EndIf
        
        *node\selected = #True
        *explorer\selected = *node
      Else
        If *explorer\selected
          *explorer\selected\selected = #False
          *explorer\selected = #Null
        EndIf
      EndIf
      
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Drag
  ; ----------------------------------------------------------------------------
  Procedure Drag(*explorer.NodeExplorer_t)
    If *explorer\down
      Protected x = GetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_MouseX)
      Protected y = GetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_MouseY)
  
      *explorer\scrollx + (x-*explorer\scrolllastx)
      *explorer\scrolly + (y-*explorer\scrolllasty)
      *explorer\scrolllastx = x
      *explorer\scrolllasty = y
      If *explorer\scrollx>0 : *explorer\scrollx = 0 : EndIf
      If *explorer\scrolly>0 : *explorer\scrolly = 0 : EndIf
      If *explorer\scrollx<-*explorer\scrollmaxx : *explorer\scrollx = -*explorer\scrollmaxx : EndIf
      If *explorer\scrolly<-*explorer\scrollmaxy : *explorer\scrolly = -*explorer\scrollmaxy : EndIf
      
      ;*Me\dirty = #True
    EndIf
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  OnEvent
  ; ----------------------------------------------------------------------------
  Procedure OnEvent(*explorer.NodeExplorer_t,eventID.i,*ev_data.Control::EventTypeDatas_t)
    Select eventID 
      Case #PB_Event_SizeWindow
        If *ev_data<>#Null
          Debug "Reset Graph Node Explorer Size"
          Debug "Reset Graph Node Explorer Size"
          Debug "Graph Node Explorer Size  ("+Str(*explorer\width)+","+Str(*explorer\height)+")"
          Debug "Event Datas  ("+Str(*ev_data\width)+","+Str(*ev_data\height)+")"
  
          ResizeGadget(*explorer\gadgetID,*ev_data\x,*ev_data\y,*ev_data\width,*ev_data\height)  
        EndIf
     
    
      Case #PB_Event_Gadget
      
;             ev_data\xoff = 5
;             ev_data\yoff = 5
;             Protected ctrl.IControl = *explorer\refre
;             *explorer\refresh\Event(EventType(),@ev_data)
;             
;             ev_data\xoff = 30
;             ev_data\yoff = 5
;             ev_data\width = *explorer\width - 60
;             *explorer\refresh\Event(EventType(),@ev_data)
;             
;             ev_data\xoff = *explorer\width-30
;             *explorer\clear\Event(EventType(),@ev_data)
        
        Select EventType()
          Case #PB_EventType_LeftDoubleClick
            If *explorer\selected <>#Null
              If *explorer\selected\type = NodeExplorer::#NodeExplorer_Description
                Protected *desc.Nodes::NodeDescription_t = *explorer\selected\object
                
                MessageRequester("Description Double Clicked",*desc\name)
                
              ElseIf *explorer\selected\type = NodeExplorer::#NodeExplorer_Category
                Protected *cat.Nodes::NodeCategory_t = *explorer\selected\object
                MessageRequester("Category Double Clicked",*cat\label)
                
              EndIf
            EndIf
            
          Case #PB_EventType_MouseMove
            If *explorer\down
              Drag(*explorer)
              Draw(*explorer)
            Else
              Pick(*explorer)
            EndIf
           
              Case #PB_EventType_KeyDown
                Protected key = GetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_Key)
                If key = #PB_Shortcut_Space
                  *explorer\scrolllastx = GetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_MouseX)
                  *explorer\scrolllasty = GetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_MouseY)
                  SetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Hand)
                  *explorer\down = #True
                EndIf
              Case #PB_EventType_KeyUp
                SetGadgetAttribute(*explorer\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Default)
                *explorer\down = #False
              Case #PB_EventType_LeftButtonDown
                
                If *explorer\selected <>#Null
                  If *explorer\selected\type = NodeExplorer::#NodeExplorer_Description
                    *desc.Nodes::NodeDescription_t = *explorer\selected\object
                    If *desc : DragText(*desc\name,#PB_Drag_Copy)
                    Else : Debug "Description Empty"
                    EndIf
                    
                  ElseIf *explorer\selected\type = NodeExplorer::#NodeExplorer_Category
                    *cat.Nodes::NodeCategory_t = *explorer\selected\object
                    *cat\expended = 1- *cat\expended
                    GetImageSize(*explorer)
                    DrawPickImage(*explorer)
                    DrawPicture(*explorer)
                    GetScrollArea(*explorer)
                    Draw(*explorer)
                  EndIf
                EndIf
          EndSelect
            
            
          Case #PB_EventType_DragStart
            Debug "[OGraphNodeExplorer Event]Drag STarted!!"
    EndSelect
    
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 219
; FirstLine = 202
; Folding = ---
; EnableThread
; EnableXP
; EnableUnicode
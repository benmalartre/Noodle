
XIncludeFile "../objects/Scene.pbi"

; -----------------------------------------
; ExplorerUI Module Declaration
; -----------------------------------------
DeclareModule ControlExplorer
  
  Enumeration 
    #ICON_MODEL
    #ICON_NULL
    #ICON_POLYMESH
    #ICON_POINTCLOUD
    #ICON_CURVE
    #ICON_GROUP
    
    #ICON_MAX
  EndEnumeration
  
  Enumeration
    #TYPE_UNKNOWN
    #TYPE_MODEL
    #TYPE_GROUP
    #TYPE_LAYER
    #TYPE_3DOBJECT
    #TYPE_STACK
    #TYPE_TREE
    #TYPE_PROPERTY
    #TYPE_PARAMETER
    #TYPE_ATTRIBUTE
    #TYPE_FOLDER
    #TYPE_LEVEL
  EndEnumeration
  
  
  #LINEHEIGHT = 20
  #SHIFTX = 10
  #SHIFTY = 20
  #TOPHEIGHT = 5
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #OFFSETY_TEXT = 2
    CompilerDefault
      #OFFSETY_TEXT = 5
  CompilerEndSelect

  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  Global explorer_icon_model.i
  Global explorer_icon_polymesh.i
  Global explorer_icon_null.i
  Global explorer_icon_pointcloud.i
  Global explorer_icon_curve.i
  Global explorer_icon_group.i
  Global explorer_icon_camera.i
  Global explorer_icon_light.i
  Global explorer_icon_kinematics.i
  Global explorer_icon_property.i
  Global explorer_icon_parameter.i
  Global explorer_icon_folder.i
  Global explorer_icon_operator.i
  Global explorer_icon_tree.i
  
  ; ----------------------------------------------------------------------------
  ;  CExplorerObject Instance
  ; ----------------------------------------------------------------------------
  Structure ControlExplorerItem_t Extends Object::Object_t
    *object.Object::Object_t
    List *children.ControlExplorerItem_t()
    *parent.ControlExplorerItem_t
    type.i
    over.b
    expanded.b
    selected.b
    depth.i
    isroot.b
    isleaf.b
    havechildren.b
    havenext.b
    
  EndStructure
  
  Structure ControlExplorer_t Extends Control::Control_t
    itemcounter.i
    dirty.b
    
    iwidth.i
    iheight.i
    imageID.i
    pickID.i
    
    ioffsetx.i              ; hierarchy drawing depth X
    ioffsety.i              ; hierarchy drawing depth Y
    
    show_uniforms.b
    show_attributes.b
    show_materials.b
    
    expanded_level.i
    linebinary.l
    lastpick.i
    pick.i
    
    *root.ControlExplorerItem_t
    Map *m_items.ControlExplorerItem_t()
    List *items.ControlExplorerItem_t()
    List *visibles.ControlExplorerItem_t()
    List *selected.ControlExplorerItem_t()
    
    *scene.Scene::Scene_t
    *on_selection.Signal::Signal_t
  EndStructure
  
  Declare New(*obj.Object::Object_t,x.i,y.i,w.i,h.i)
  Declare Delete(*Me.ControlExplorer_t)
  ;   Declare Draw(*Me.ExplorerUI_t)
  Declare Init()
  Declare OnEvent(*Me.ControlExplorer_t,event.i,*ev_data.Control::EventTypeDatas_t)
  Declare Term()
  Declare Clear(*Me.ControlExplorer_t)

  
  DataSection 
    ExplorerVT: 
    ControlIconVT:
    Data.i @OnEvent()
    Data.i @Delete()
    
    VIExplorer_Model_Icon:
    IncludeBinary "../../rsc/ico/model.png"
    VIExplorer_Polymesh_Icon:  
    IncludeBinary "../../rsc/ico/polymesh.png"
    VIExplorer_Null_Icon:  
    IncludeBinary "../../rsc/ico/null.png"
    VIExplorer_PointCloud_Icon:  
    IncludeBinary "../../rsc/ico/pointcloud.png"
    VIExplorer_Curve_Icon:  
    IncludeBinary "../../rsc/ico/curve.png"
    VIExplorer_Parameter_Icon:
    IncludeBinary "../../rsc/ico/parameter.png"
    VIExplorer_Kinematics_Icon:
    IncludeBinary "../../rsc/ico/kinematics.png"
    VIExplorer_Property_Icon:
    IncludeBinary "../../rsc/ico/property.png"
    VIExplorer_Folder_Icon:
    IncludeBinary "../../rsc/ico/folder.png"
    VIExplorer_Light_Icon:
    IncludeBinary "../../rsc/ico/light.png"
    VIExplorer_Camera_Icon:
    IncludeBinary "../../rsc/ico/camera.png"
    VIExplorer_Group_Icon:
    IncludeBinary "../../rsc/ico/group.png"
    VIExplorer_Operator_Icon:
    IncludeBinary "../../rsc/ico/operator.png"
    VIExplorer_Tree_Icon:
    IncludeBinary "../../rsc/ico/tree.png"
  EndDataSection 
  

  Declare Resize(*Me.ControlExplorer_t)
  Declare Draw(*Me.ControlExplorer_t)
  Declare UnselectAll(*Me.ControlExplorer_t)
  Declare Selection(*Me.ControlExplorer_t,*item.ControlExplorerItem_t)
  Declare SelectList(*Me.ControlExplorer_t,first.i,last.i)
  Declare Pick(*Me.ControlExplorer_t, offsetX.i, offsetY.i)
  Declare Clear(*Me.ControlExplorer_t)
  Declare AddObject(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,*object.Object::Object_t,name.s,depth,type.i)
  Declare Add3DObject(*Me.ControlExplorer_t,*parent.ControlExplorerItem_t,*obj.Object3D::Object3D_t,depth.i)  
  Declare Fill(*Me.ControlExplorer_t,*scene.Scene::Scene_t)
  Declare OnEvent(*Me.ControlExplorer_t,event.i,*ev_data.Control::EventTypeDatas_t)
  Declare OnItemEvent(*Me.ControlExplorer_t, *item.ControlExplorerItem_t, event.i, *ev_data.Control::Control_t)
   DataSection 
    ControlExplorerVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    ControlExplorerItemVT: 
    Data.i @OnEvent()
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

Module ControlExplorer
 
  ; ----------------------------------------------------------------------------
  ;  New Item
  ; ----------------------------------------------------------------------------
  Procedure NewItem(*object.Object::Object_t,*parent.ControlExplorerItem_t,id,depth.i,havenext.b)
    Protected *Me.ControlExplorerItem_t = AllocateMemory(SizeOf(ControlExplorerItem_t))
    Object::INI(ControlExplorerItem)

    *Me\object = *object
    *Me\depth = depth

    *Me\isroot = Bool(*Me\object And *Me\object\class\name = "Model")
    *Me\expanded = #True
    *Me\havechildren = *Me
    *Me\parent = *parent
    *Me\havenext = havenext
   
    
    If *object <> #Null
      If *object\class
        ;*Me\type = #TYPE_3DOBJECT
        Select *object\class\name
          Case "Model"
            *Me\type = #TYPE_3DOBJECT
          Case "Polymesh"
            *Me\type = #TYPE_3DOBJECT
          Case  "PointCloud"
            *Me\type = #TYPE_3DOBJECT
          Case  "Light"
            *Me\type = #TYPE_3DOBJECT
          Case  "Camera"
            *Me\type = #TYPE_3DOBJECT
          Case  "Curve"
            *Me\type = #TYPE_3DOBJECT
          Case "Null"
            *Me\type = #TYPE_3DOBJECT
          Case "Attribute"
            *Me\type = #TYPE_ATTRIBUTE
          Case "Transform"
            *Me\type = #TYPE_PROPERTY
          Case ""
            *Me\type = #TYPE_FOLDER
            
        EndSelect
      Else 
        *Me\type = #TYPE_UNKNOWN
      EndIf
      
    Else
      *Me\type = #TYPE_FOLDER
    EndIf
  
    ProcedureReturn *Me
        
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Delete Item
  ; ----------------------------------------------------------------------------
  Procedure DeleteItem(*item.ControlExplorerItem_t)
    If *item 
  ;     If ListSize(*item\children())>0
  ;       ForEach(*item\children())
  ;         deleteCExplorerItem(*item\children())
  ;       Next
  ;     EndIf
      
      ClearStructure(*item,ControlExplorerItem_t)
      FreeMemory(*item)
    EndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Resize
  ;---------------------------------------------------------
  Procedure Resize(*Me.ControlExplorer_t)
    *Me\posX = *Me\parent\posX
    *Me\posY = *Me\parent\posY
    *Me\sizX = *Me\parent\sizX
    *Me\sizY = *Me\parent\sizY
    *Me\iwidth = *Me\sizX
    *Me\iheight = *Me\sizY
    *Me\dirty = #True
    ResizeGadget(*Me\gadgetID,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
    
  EndProcedure
  
  ;----------------------------------------
  ;  Reset Visited Flag
  ; ----------------------------------------
  Procedure ResetVisited(*Me.ControlExplorer_t,*root.Object3D::Object3D_t)
    *root\visited = #False
    Protected c
    Protected *child.Object3D::Object3D_t
    ForEach *root\children()
      *child = *root\children()
      *child\visited = #False
      If ListSize(*child\children())
        ResetVisited(*Me,*child)
      EndIf
      
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Visibles
  ;---------------------------------------------------------
  Procedure GetVisibles(*Me.ControlExplorer_t)
;     Protected depth.i,lastdepth.i
;     Protected expanded.b,lastexpanded.i
    If *Me\root
      ResetVisited(*Me,*Me\root\object)
      ClearList(*Me\visibles())
      ForEach(*Me\items())
        If (*Me\items()\parent And *Me\items()\parent\expanded) Or *Me\items()\isroot = #True
          AddElement(*Me\visibles())
          *Me\visibles() = *Me\items()
        EndIf
      Next
    EndIf
    
  ;     expanded = *Me\allitems()\expanded
  ;     depth = *Me\allitems()\depth
  ;     If lastexpanded And depth<=lastdepth
  ;       AddElement(*Me\items())
  ;       *Me\items()=*Me\allitems()
  ;      
  ;     Else
  ;      If depth<=lastdepth
  ;       AddElement(*Me\items())
  ;       *Me\items()=*Me\allitems()
  ;     EndIf
  ;   EndIf
  ;     lastexpanded = expanded
  ;     lastdepth = depth
  ;   Next
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Set Binary Lines
  ; ----------------------------------------
  Procedure SetBinaryLine(*Me.ControlExplorer_t,id.i,value.b)
    Globals::BitWrite(*Me\linebinary,id,value)
  EndProcedure
  
  
  ; ----------------------------------------
  ;  Draw
  ; ----------------------------------------
  Procedure DrawItem(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,depth.i)
    
   
    If *item\type = #TYPE_PROPERTY And Not *Me\show_uniforms : *Me\itemcounter + 1 : ProcedureReturn : EndIf
    If *item\type = #TYPE_ATTRIBUTE And Not *Me\show_attributes : *Me\itemcounter + 1 : ProcedureReturn : EndIf
  
    Protected shiftx.i = #SHIFTX
    Protected shifty.i = #SHIFTY
    Protected x = 25 + shiftx * (*item\depth)
    Protected tc = UIColor::COLOR_TEXT_DEFAULT
    VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_TEXT)
    ; Draw Background
    If Mod(*Me\itemcounter,2) = 1
      AddPathBox(0,*Me\ioffsety,*Me\iwidth,shifty)
      VectorSourceColor(UIColor::COLOR_MAIN_BG)
      FillPath()
    Else
      AddPathBox(0,*Me\ioffsety,*Me\iwidth,shifty)
      VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
      FillPath()
    EndIf
    
    ; Draw Selected
    If *item\selected = #True
      AddPathBox(0,*Me\ioffsety,*Me\iwidth,shifty)
      VectorSourceColor(UIColor::COLOR_SELECTED_BG)
      FillPath()
    EndIf
    
    ; Draw Item
    Protected *parent.ControlExplorerItem_t = *item\parent
    If *parent
      Protected yoff = 0
      Protected xoff = #SHIFTX
      Repeat
        If *parent\parent And *parent\havenext
          MovePathCursor(x-shiftx+5-xoff,*Me\ioffsety-yoff)
          AddPathLine(0,shifty, #PB_Path_Relative)
        EndIf
        xoff + #SHIFTX
        *parent = *parent\parent
      Until *parent = #Null
      VectorSourceColor(UIColor::COLOR_GROUP_FRAME)
      StrokePath(2)
    EndIf
  
    ; Draw Connexions
    If *item\havenext
      SetBinaryLine(*Me,depth,#True)
    Else
      SetBinaryLine(*Me,depth,#False)
    EndIf
    
    ; Vertical lines
    Protected i
    VectorSourceColor(UIColor::COLOR_GROUP_FRAME)
    For i=0 To depth-1
      If Globals::BitRead(*Me\linebinary,i)
        MovePathCursor(x-(i)*shiftx+5,*Me\ioffsety-shifty*0.5)
        AddPathLine(0,shifty,#PB_Path_Relative)
        StrokePath(2)
      EndIf
    Next
    
    ; Horizontal line
    MovePathCursor(x-shiftx+5,*Me\ioffsety+shifty/2)
    AddPathLine(shiftx-5,0, #PB_Path_Relative)
    StrokePath(2)
    
    ; expanded button
    If Not *item\isleaf
      VectorSourceColor(UIColor::COLOR_GROUP_FRAME)
      If *item\expanded
        MovePathCursor(x-shiftx+6, *Me\ioffsety+10)
        AddPathLine(2,4,#PB_Path_Relative)
        AddPathLine(2,-4, #PB_Path_Relative)
        ClosePath()

        StrokePath(2)
      Else
        MovePathCursor(x-shiftx+6,*Me\ioffsety+8)
        AddPathLine(4,2,#PB_Path_Relative)
        AddPathLine(-4,2, #PB_Path_Relative)
        ClosePath()
        StrokePath(2)
      EndIf
    EndIf

    ;  Draw Icon
    Select *item\type  
      Case #TYPE_3DOBJECT
        Protected *o.Object3D::Object3D_t = *item\object
        Select *o\type
          Case Object3D::#Model
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_model))
          Case Object3D::#Light
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_light))
          Case Object3D::#Camera
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_camera))
          Case Object3D::#Polymesh
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_polymesh))
          Case Object3D::#Locator
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_null))
          Case Object3D::#Curve
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_curve))
          Case Object3D::#PointCloud
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_pointcloud))
          Case Object3D::#InstanceCloud
            MovePathCursor(x,*Me\ioffsety+2)
;             DrawVectorImage(ImageID(explorer_icon_instancecloud))
            
        EndSelect
        MovePathCursor(x+20,*Me\ioffsety+#OFFSETY_TEXT+4)
        VectorSourceColor(tc)
        DrawVectorText(*o\name)
        
      Case #TYPE_GROUP
        MovePathCursor(x,*Me\ioffsety+2)
;         DrawVectorImage(ImageID(explorer_icon_group))
        MovePathCursor(x+20,*Me\ioffsety+#OFFSETY_TEXT)
        VectorSourceColor(tc)
        DrawVectorText("Fucking Group")
        
      Case #TYPE_LAYER
        Debug "Explorer Object Layer"
        
      Case #TYPE_MODEL
        
      Case #TYPE_PARAMETER
        
      Case #TYPE_FOLDER
        MovePathCursor(x,*Me\ioffsety+2)
;         DrawVectorImage(ImageID(explorer_icon_folder))
        MovePathCursor(x+20,*Me\ioffsety+#OFFSETY_TEXT+4)
        VectorSourceColor(RGBA(0,0,0,255))
        DrawVectorText("Attributes")
        
;       Case #TYPE_PROPERTY
;         DrawVectorImage(ImageID(explorer_icon_kinematics),x,*Me\ioffsety+2)
;         DrawText(x+20,*Me\ioffsety+#OFFSETY_TEXT,"Global",RGBA(0,0,0,255))
        
      Case #TYPE_ATTRIBUTE

        Protected *a.Attribute::Attribute_t = *item\object
        tc  =RGBA(255,0,0,255)
        Select *a\datatype
          Case Attribute::#ATTR_TYPE_BOOL
            VectorSourceColor(Globals::RGB2RGBA(Attribute::#ATTR_COLOR_BOOL,120))
            AddPathCircle(x+2,*Me\ioffsety+6,4)
            FillPath()
            MovePathCursor(x+15,*Me\ioffsety+#OFFSETY_TEXT)
            VectorSourceColor(tc)
            DrawVectorText(*a\name)
            
          Case Attribute::#ATTR_TYPE_FLOAT
            VectorSourceColor(Globals::RGB2RGBA(Attribute::#ATTR_COLOR_FLOAT,120))
            AddPathCircle(x+2,*Me\ioffsety+6,4)
            FillPath()
            MovePathCursor(x+15,*Me\ioffsety+#OFFSETY_TEXT)
            VectorSourceColor(tc)
            DrawVectorText(*a\name)
            
          Case Attribute::#ATTR_TYPE_VECTOR3
            VectorSourceColor(Globals::RGB2RGBA(Attribute::#ATTR_COLOR_VECTOR3,120))
            AddPathCircle(x+2,*Me\ioffsety+6,4)
            FillPath()
            MovePathCursor(x+15,*Me\ioffsety+#OFFSETY_TEXT)
            VectorSourceColor(tc)
            DrawVectorText(*a\name)
            
          Case Attribute::#ATTR_TYPE_MATRIX4
            VectorSourceColor(Globals::RGB2RGBA(Attribute::#ATTR_COLOR_MATRIX4,120))
            AddPathCircle(x+2,*Me\ioffsety+6,4)
            FillPath()
            MovePathCursor(x+15,*Me\ioffsety+#OFFSETY_TEXT)
            VectorSourceColor(tc)
            DrawVectorText(*a\name)
            
          Case Attribute::#ATTR_TYPE_COLOR
            VectorSourceColor(Globals::RGB2RGBA(Attribute::#ATTR_COLOR_COLOR,120))
            AddPathCircle(x+2,*Me\ioffsety+6,4)
            FillPath()
            MovePathCursor(x+15,*Me\ioffsety+#OFFSETY_TEXT)
            VectorSourceColor(tc)
            DrawVectorText(*a\name)
            
          Case Attribute::#ATTR_TYPE_TOPOLOGY
            VectorSourceColor(Globals::RGB2RGBA(Attribute::#ATTR_COLOR_TOPOLOGY,120))
            AddPathCircle(x+2,*Me\ioffsety+6,4)
            FillPath()
            MovePathCursor(x+15,*Me\ioffsety+#OFFSETY_TEXT)
            VectorSourceColor(tc)
            DrawVectorText(*a\name)
            
          Default 
            VectorSourceColor(RGBA(255,255,255,120))
            AddPathCircle(x+2,*Me\ioffsety+6,4)
            FillPath()
            MovePathCursor(x+15,*Me\ioffsety+#OFFSETY_TEXT)
            VectorSourceColor(tc)
            DrawVectorText(*a\name)
            
        EndSelect
    EndSelect
    
    *Me\ioffsety + #LINEHEIGHT
    *Me\itemcounter + 1
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Image 
  ; ----------------------------------------
  Procedure DrawDisplayImage(*Me.ControlExplorer_t)
    *Me\ioffsetx = 25
    *Me\ioffsety = #TOPHEIGHT
    *Me\itemcounter = 0

    StartVectorDrawing(ImageVectorOutput(*Me\imageID))
    ResetCoordinates()
    AddPathBox(0,0,*Me\iwidth,*Me\iheight)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
    *Me\linebinary = 0
    ForEach *Me\visibles()
      DrawItem(*Me,*Me\visibles(),0)
    Next
    StopVectorDrawing()
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Pick Item
  ; ----------------------------------------
  Procedure DrawPickItem(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,depth.i)
    If *item\type = #TYPE_PROPERTY And Not *Me\show_uniforms : *Me\itemcounter + 1 : ProcedureReturn : EndIf
    If *item\type = #TYPE_ATTRIBUTE And Not *Me\show_attributes : *Me\itemcounter + 1 : ProcedureReturn : EndIf
    
    Define colorid = Random(Pow(256,3));UIColor::RANDOMIZED
    AddMapElement(*Me\m_items(), Str(colorid),#PB_Map_NoElementCheck)
    *Me\m_items() = *item
    Box(0,*Me\ioffsety,*Me\iwidth,#LINEHEIGHT, colorid)

    
    *Me\ioffsety + #LINEHEIGHT
    *Me\itemcounter + 1

  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------
  Procedure DrawPickImage(*Me.ControlExplorer_t)
    
    ClearMap(*Me\m_items())
    *Me\ioffsetx = 25
    *Me\ioffsety = #TOPHEIGHT
    *Me\itemcounter = 0
    
    RandomSeed(0)
    StartDrawing(ImageOutput(*Me\pickID))
    DrawingMode(#PB_2DDrawing_AllChannels)
    
    Box(0,0,*Me\iwidth,*Me\iheight, 0)
    *Me\linebinary = 0
    ForEach *Me\visibles()
      DrawPickItem(*Me,*Me\visibles(),0)
    Next
    StopDrawing()
    Debug "PICK ITEMS MAP SIZE : "+Str(MapSize(*Me\m_items()))
    
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Canvas
  ; ----------------------------------------
  Procedure Draw(*Me.ControlExplorer_t)
  
    If *Me\dirty
      GetVisibles(*Me)
      DrawPickImage(*Me)
      DrawDisplayImage(*Me)
      *Me\dirty = #False
    EndIf
  
  EndProcedure
  
  ;--------------------------------------------------------------------
  ; Unselect All
  ;--------------------------------------------------------------------
  Procedure UnselectAll(*Me.ControlExplorer_t)
    ForEach *Me\selected()
      *Me\selected()\selected = #False  
    Next
    ClearList(*Me\selected())
  EndProcedure
  
  ;--------------------------------------------------------------------
  ; Select
  ;--------------------------------------------------------------------
  Procedure Selection(*Me.ControlExplorer_t,*item.ControlExplorerItem_t)
    AddElement(*Me\selected())
    *Me\selected() = *item
    Select *item\type
      Case #TYPE_MODEL
;         Scene::AddToSelection(*Me\scene,*item\object)
;         SelectObjectCmd::Do(*item\object)
      Case #TYPE_3DOBJECT
;         MessageRequester("Select Object","Should Increment Command Stack!!!")
;         Scene::AddToSelection(*Me\scene,*item\object)
;         SelectObjectCmdDo(*item\object)
      Default
        Debug "NOT implemented!!!"
    EndSelect
    
  EndProcedure
  
  
  ;--------------------------------------------------------------------
  ; SelectList
  ;--------------------------------------------------------------------
  Procedure SelectList(*Me.ControlExplorer_t,first.i,last.i)
    If last<first
      Protected tmp = last
      last = first
      first = tmp
    EndIf
    Protected i
    For i=first To last
  
      SelectElement(*Me\items(),i)
      *Me\items()\selected = #True
      AddElement(*Me\selected())
      *Me\selected() = *Me\items()
    Next
    
  EndProcedure
  
  ; ----------------------------------------
  ; Recurse expanded
  ; ----------------------------------------
  Procedure RecurseExpanded(*item.ControlExplorerItem_t,expanded.b = #False, depth.i = -1)
    If Not depth : ProcedureReturn : EndIf
    *item\expanded = expanded
    ForEach *item\children()
      RecurseExpanded(*item\children(),expanded, depth - 1)
    Next
    
  EndProcedure
  
  ; ----------------------------------------
  ; Pick Item
  ; ----------------------------------------
  Procedure PickItem(*Me.ControlExplorer_t, *item.ControlExplorerItem_t, mx, my, key)
    If *item <>#Null
      
      Protected l = (*item\depth+2) * #SHIFTX
      If Abs(l-mx)<20
        If Not *item\isleaf
          *item\expanded = 1-*item\expanded
           RecurseExpanded(*item, *item\expanded, 1)
          
          *Me\dirty = #True
        EndIf
        
      Else

        Select key
          
          Case #PB_Canvas_Shift
            ; Add All Items between last pick an pick
             SelectList(*Me,*Me\lastpick,*Me\pick)

          Case #PB_Canvas_Control
            *item\selected = #True
            Selection(*Me,*item)
            If *item\type = #TYPE_3DOBJECT
              Scene::SelectObject(*Me\scene,*item\object)
              Signal::Trigger(*Me\on_selection, Signal::#SIGNAL_TYPE_PING)
            Else
              ; do nothing
            EndIf
            

          Default
            ;Clear Selection before adding item
            UnselectAll(*Me)
            *item\selected = #True
            AddElement(*Me\selected())
            *Me\selected() = *item
            Debug "Selected Item : "+Str(*item)
            If *item\type = #TYPE_3DOBJECT
              Scene::SelectObject(*Me\scene,*item\object)
              Signal::Trigger(*Me\on_selection, Signal::#SIGNAL_TYPE_PING)
            EndIf
            
        EndSelect
        
        *Me\dirty = #True
      EndIf
    EndIf
  EndProcedure
  
  
  ; ----------------------------------------
  ; Pick
  ; ----------------------------------------
  Procedure Pick(*Me.ControlExplorer_t, offsetX.i, offsetY.i)
    Protected mx = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX) - offsetx
    Protected my = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY) - offsety
   
    ; Return if OUT of picking area
    If mx<0 Or mx>=*Me\iwidth Or my<0 Or my>*Me\iheight:ProcedureReturn:EndIf
    
    ; Get Point Color 
    StartDrawing(ImageOutput(*Me\pickID))
    DrawingMode(#PB_2DDrawing_AllChannels)
    Protected key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)
    Protected pick = Point(mx,my)
    StopDrawing()

    If FindMapElement(*Me\m_items(), Str(pick))  
      PickItem(*Me, *Me\m_items(), mx, my, key)
    EndIf

    Draw(*Me)

  EndProcedure
  
  ; ----------------------------------------
  ;  Clear Explorer Data
  ; ----------------------------------------
  Procedure Clear(*Me.ControlExplorer_t)
    ForEach *Me\items()
      DeleteItem(*Me\items())  
    Next
    
    ClearList(*me\items())
    ClearList(*Me\visibles())
    ClearList(*Me\selected())
  EndProcedure
  
  ; ----------------------------------------
  ;  Push Explorer Data
  ; ----------------------------------------
  Procedure AddObject(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,*object.Object::Object_t,name.s,depth,type.i)
    AddElement(*item\children())
    AddElement(*Me\items())
    *item\children() = NewItem(*object,*item,*Me\itemcounter,depth,#False)
    If *item\depth>*Me\expanded_level : *item\expanded = #False : EndIf
    
    *Me\itemcounter +1
    *Me\type = type
    *Me\iheight + #LINEHEIGHT
    Protected nw.i = TextWidth(name)+(depth+1)*#SHIFTX
    *Me\iwidth = Math::MAXIMUM(*Me\iwidth,nw)
    *Me\items() = *item\children()
    Select type
      Case #TYPE_ATTRIBUTE
        *Me\items()\expanded = #False
        *Me\items()\isleaf = #True
      Case #TYPE_PROPERTY
        *Me\items()\expanded = #False
      Case #TYPE_GROUP
        *Me\items()\isleaf = #True
        *Me\items()\expanded = #False
      Case #TYPE_3DOBJECT
        *Me\items()\expanded = #True
        *Me\items()\isleaf = #False
      Case #TYPE_STACK
        *Me\items()\expanded = #True
        *Me\items()\isleaf = #False
      Case #TYPE_TREE
        *Me\items()\expanded = #True
        *Me\items()\isleaf = #False
    EndSelect
    
    ProcedureReturn *Me\items()
  EndProcedure
  
  
  ; ----------------------------------------
  ;  Add 3DObject
  ; ----------------------------------------
  Procedure Add3DObject(*Me.ControlExplorer_t,*parent.ControlExplorerItem_t,*obj.Object3D::Object3D_t,depth.i)  
  
    If *obj\visited = #True : ProcedureReturn : EndIf
    *obj\visited = #True
    Protected *item.ControlExplorerItem_t = AddObject(*Me,*parent,*obj,*obj\name,depth+1,#TYPE_3DOBJECT)
    *item\expanded = #True
    Protected *o.ControlExplorerItem_t
    
    If *obj\stack
      Protected *stack.ControlExplorerItem_t = AddObject(*Me,*item,*obj\stack,"Stack",depth+2,#TYPE_STACK)
      ForEach *obj\stack\levels()
        Protected *tree.ControlExplorerItem_t = AddObject(*Me,*stack,*obj\stack\levels(),"Tree",depth+3,#TYPE_TREE)
      Next
    EndIf
    
    Protected *attributes.ControlExplorerItem_t = AddObject(*Me,*item,#Null,"Attributes",depth+2,#TYPE_PROPERTY)
    *attributes\expanded = #True
    *attributes\havenext = #False
    Protected nb = MapSize(*obj\geom\m_attributes())
    Protected a
    Protected *attr.Attribute::Attribute_t

    Protected cnt
    
    ForEach  *obj\geom\m_attributes()
      *attr = *obj\geom\m_attributes()
      *o = AddObject(*Me,*attributes,*attr,*attr\name,depth+3,#TYPE_ATTRIBUTE)

      If cnt < nbo-1
        *o\havenext = #True
      Else
        *o\havenext = #False
      EndIf
      
      cnt+1
    Next
    
    Protected i,nw,havenext.b
    Protected *child.Object3D::Object3D_t
    
    i=0
    ForEach *obj\children()
      *child = *obj\children()
      If Not *child\visited = #True
        
        *o = Add3DObject(*Me,*item,*child,depth+1)
        If i<ListSize(*obj\children())-1
          *o\havenext = #True
        Else
          *o\havenext = #False
        EndIf
        *child\visited = #True    
      EndIf
      i+1
    Next
    ProcedureReturn *item
    
  EndProcedure
  
  ; ----------------------------------------
  ;  Is Item in AllItems List
  ; ----------------------------------------
  Procedure IsInList(*Me.ControlExplorer_t,*item.ControlExplorerItem_t)
    ForEach *Me\items()
      If *item = *Me\items()
        ProcedureReturn  #True
      EndIf   
    Next
    ProcedureReturn #False
  EndProcedure
  
  Procedure OnSelectionChange(*scene.Scene::Scene_t)
    PostEvent(Globals::#EVENT_SELECTION_CHANGED)
  EndProcedure
  Callback::DECLARECALLBACK(OnSelectionChange, Arguments::#PTR)
  
  ; ----------------------------------------
  ;  Fill Explorer from Scene Description
  ; ----------------------------------------
  Procedure Fill(*Me.ControlExplorer_t,*scene.Scene::Scene_t)
    Clear(*Me)
    ResetVisited(*Me,*scene\root)
    Protected i
    
    ; reset image size
    *Me\iwidth = 0
    *Me\iheight = #TOPHEIGHT
    *Me\scene = *scene
  
    ;Reset counter to encoding color ID (0 is for Background)
    *Me\itemcounter = 0
    
    StartDrawing(ImageOutput(*Me\imageID))
    
    *Me\root = NewItem(*scene\root,#Null,0,0,#False)
    Protected *o.ControlExplorerItem_t
    ForEach *scene\root\children()

      Protected *obj.Object3D::Object3D_t = *scene\root\children()
      *o = Add3DObject(*Me,*Me\root,*obj,0);
      *o\isroot = #True
      If i<ListSize(*scene\root\children())-1
        *o\havenext = #True
      Else
        *o\havenext = #False
      EndIf
      *obj\visited = #True
      i+1
    Next
    
    StopDrawing()
    *Me\iwidth + 25
    *Me\iwidth = Math::Max(*Me\sizX,*Me\iwidth)
    *Me\iheight = Math::Max(*Me\sizY,*Me\iheight)
    ResizeImage(*Me\imageID,*Me\iwidth,*Me\iheight)
    ResizeImage(*Me\pickID,*Me\iwidth,*Me\iheight)
    GetVisibles(*Me)

    RecurseExpanded(*Me\root,#False)
    *Me\dirty = #True
    
    Signal::CONNECTCALLBACK(*Me\on_selection, OnSelectionChange, *scene)
    
  EndProcedure
 
  ;----------------------------------------
  ;  Event
  ;---------------------------------------------------
  Procedure OnEvent(*Me.ControlExplorer_t,event.i,*ev_data.Control::EventTypeDatas_t)
    If event = #PB_EventType_Resize Or event = #PB_Event_SizeWindow
      *Me\sizX = *ev_data\width
      *Me\sizY = *ev_data\height
      Resize(*Me)
      Draw(*Me)
      
    ElseIf event = #PB_Event_Gadget
      Protected evdt.Control::EventTypeDatas_t
      Protected mx = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
      Protected my = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)

  
        Protected key
        Select EventType()
          Case #PB_EventType_KeyDown
            key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key)
;             If key = #PB_Shortcut_Space 
;               *Me\scrolling = #True
;               *Me\scrolllastx = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
;               *Me\scrolllasty = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
;               SetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Hand)
;             EndIf
            
          Case #PB_EventType_KeyUp
            
            key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key)
            If key = #PB_Shortcut_Space ;And *Me\scrollable And *Me\scrolling
;               *Me\scrolling = #False
              SetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Default)
            EndIf
            
          Case #PB_EventType_MouseMove
            ;UI::Scroll(*Me)
            
          Case #PB_EventType_LeftButtonDown 
            Pick(*Me, *ev_data\xoff, *ev_data\yoff)
          
            
        EndSelect
      
      
    EndIf
    
    
    ;Redraw Explorer
    Draw(*Me)
    
  EndProcedure
  
  ;----------------------------------------
  ;  Item Event
  ;---------------------------------------------------
  Procedure OnItemEvent(*Me.ControlExplorer_t, *item.ControlExplorerItem_t, event.i, *ev_data.Control::Control_t)
    
  EndProcedure
  
  
  
  Procedure OnMessage( id.i, *up)
;     Protected *sig.Signal::Signal_t = *up
;     Protected *explorer.ControlExplorer_t = *sig\rcv_inst
;     Debug "Explorer Signal Recieved..."
;     Debug "Slot : "+Str(*sig\rcv_slot)
;     Debug "Sender Class : "+Str(*sig\snd_class)
  ;   *explorer\SendEvent(#PB_Event_Repaint)
  ;     Protected *sig.CSignal_t = *up
  ;   Protected *c.CControlNumber_t = *sig\snd_inst
  ;   Protected *Me.ExplorerUI_t = *c\parent
  ;   Protected v.i = *c\value_n
  ; 
  ;   Draw(*Me)
  EndProcedure
  
  
  
  ;------------------------------------------------------------------
  ; Signal / Slots Messages
  ;------------------------------------------------------------------
  Procedure ConnectSignalsSlots(*Me.ControlExplorer_t)
  ;   Protected Me.Explorer = *Me
  ;   
  ;   Me\SignalConnect(*Me\scene\SignalOnChanged(),0)
  ;   Me\SignalConnect(*Me\context\SignalOnChanged(),1)
  ;   Me\SignalConnect(*Me\search\SignalOnChanged(),2)
  ;   Me\SignalConnect(*Me\show\SignalOnChanged(),3)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.ControlExplorer_t)
    Object::TERM(ControlExplorer)
  EndProcedure
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent.UI::UI_t,x.i,y.i,w.i,h.i)
    Protected *Me.ControlExplorer_t = AllocateMemory(SizeOf(ControlExplorer_t))
    Object::INI( ControlExplorer )
    
    *Me\parent = *parent
    *Me\gadgetID = *parent\gadgetID
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = w
    *Me\sizY = h
  
    *Me\name = "Explorer"
    
    
    ; ---[ Explorer ]------------------------
    *Me\type = Globals::#VIEW_EXPLORER
    *Me\show_uniforms = #True
    *Me\show_attributes = #True
    *Me\show_materials = #True
    *Me\expanded_level = 12
;     *Me\scrollable = #True
    
    ; ---[ Set Controls ]----------------------
    Protected options.i = ControlGroup::#Autosize_V|ControlGroup::#Autosize_h
      
    ; ---[ Set Images ]----------------------
    *Me\imageID = CreateImage(#PB_Any,*Me\sizX,*Me\sizY,32)
    *Me\pickID = CreateImage(#PB_Any,*Me\sizX,*Me\sizY,32)
    
    ; ---[ Splitter ]-------------------------
    *Me\dirty = #True
    
    ; ---[ Signals ]-------------------------
    *Me\on_selection = Object::NewSignal(*Me, "OnSelectionChange")
    
    
;     If Scene::*current_scene
;       Fill(*Me,Scene::*current_scene)
; 
;       ConnectSignalsSlots(*Me)
;       RecurseExpanded(*Me\root,#False);
;     EndIf
    
    Resize(*Me)
    Draw(*Me)
    ;ConnectSignalSlot(*Me,@scn\SignalOnChanged(),0)
  
    ProcedureReturn *Me
  EndProcedure
  
  
  
  
  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure Init( )
    ; ---[ Local Variable ]-----------------------------------------------------
    Protected img.i
  
    ; ---[ Init Once ]----------------------------------------------------------
    explorer_icon_model       =     CatchImage( #PB_Any, ?VIExplorer_Model_Icon)
    explorer_icon_polymesh    =     CatchImage( #PB_Any, ?VIExplorer_Polymesh_Icon)
    explorer_icon_light       =     CatchImage( #PB_Any, ?VIExplorer_Light_Icon)
    explorer_icon_camera      =     CatchImage( #PB_Any, ?VIExplorer_Camera_Icon)
    explorer_icon_null        =     CatchImage( #PB_Any, ?VIExplorer_Null_Icon)
    explorer_icon_pointcloud  =     CatchImage( #PB_Any, ?VIExplorer_PointCloud_Icon)
    explorer_icon_curve       =     CatchImage( #PB_Any, ?VIExplorer_Curve_Icon)
    explorer_icon_parameter   =     CatchImage( #PB_Any, ?VIExplorer_Parameter_Icon)
    explorer_icon_kinematics  =     CatchImage( #PB_Any, ?VIExplorer_Kinematics_Icon)
    explorer_icon_property    =     CatchImage( #PB_Any, ?VIExplorer_Property_Icon)
    explorer_icon_folder      =     CatchImage( #PB_Any, ?VIExplorer_Folder_Icon)
    explorer_icon_group       =     CatchImage( #PB_Any, ?VIExplorer_Group_Icon)
    explorer_icon_operator    =     CatchImage( #PB_Any, ?VIExplorer_Operator_Icon)
    explorer_icon_tree        =     CatchImage( #PB_Any, ?VIExplorer_Tree_Icon)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Term
  ; ----------------------------------------------------------------------------
  Procedure Term( )
  
    ; ---[ Term Once ]----------------------------------------------------------
    FreeImage( explorer_icon_model )
    FreeImage( explorer_icon_polymesh )
    FreeImage( explorer_icon_null )
    FreeImage( explorer_icon_light )
    FreeImage( explorer_icon_camera )
    FreeImage( explorer_icon_pointcloud )
    FreeImage( explorer_icon_curve)
    FreeImage( explorer_icon_parameter )
    FreeImage( explorer_icon_kinematics )
    FreeImage( explorer_icon_property)
    FreeImage( explorer_icon_folder)
   
    
  EndProcedure
  
  Class::DEF(ControlExplorer)
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 799
; FirstLine = 757
; Folding = 4-4---
; EnableXP
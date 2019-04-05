

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
    expended.b
    selected.b
    colorid.i
    depth.i
    isroot.b
    isleaf.b
    havechildren.b
    havenext.b
    
    
    *slot.Slot::Slot_t
    
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
    
    expended_level.i
    linebinary.l
    lastpick.i
    pick.i
    
    *root.ControlExplorerItem_t
    List *items.ControlExplorerItem_t()
    List *visibles.ControlExplorerItem_t()
    List *selected.ControlExplorerItem_t()
    
    *scene.Scene::Scene_t
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
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete(); mandatory override
    
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
  
;   Declare ItemEncodeID(*item.ControlExplorerItem_t,id.i)
;   Declare ItemDecodeID(colorid.i)
;   Declare NewItem(*object.Object::Object_t,*parent.ControlExplorerItem_t,id,depth.i,havenext.b)
;   Declare DeleteItem(*item.ControlExplorerItem_t)
  Declare Resize(*Me.ControlExplorer_t)
;   Declare ResetVisited(*Me.ControlExplorer_t,*root.Object3D::Object3D_t)
;   Declare GetVisibles(*Me.ControlExplorer_t)
;   Declare SetBinaryLine(*e.ControlExplorer_t,id.i,value.b)
;   Declare DrawItem(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,depth.i)
;   Declare DrawDisplayImage(*Me.ControlExplorer_t)
;   Declare DrawPickItem(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,depth.i)
;   Declare DrawPickImage(*Me.ControlExplorer_t)
  Declare Draw(*Me.ControlExplorer_t)
  Declare UnselectAll(*Me.ControlExplorer_t)
  Declare Selection(*Me.ControlExplorer_t,*item.ControlExplorerItem_t)
  Declare SelectList(*Me.ControlExplorer_t,first.i,last.i)
;   Declare RecurseExpended(*item.ControlExplorerItem_t,expended.b = #False)
  Declare Pick(*Me.ControlExplorer_t)
  Declare Clear(*Me.ControlExplorer_t)
  Declare AddObject(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,*object.Object::Object_t,name.s,depth,type.i)
  Declare Add3DObject(*Me.ControlExplorer_t,*parent.ControlExplorerItem_t,*obj.Object3D::Object3D_t,depth.i)  
;   Declare IsInList(*Me.ControlExplorer_t,*item.ControlExplorerItem_t)
  Declare Fill(*Me.ControlExplorer_t,*scene.Scene::Scene_t)
  Declare OnEvent(*e.ControlExplorer_t,event.i,*ev_data.Control::EventTypeDatas_t)
  
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
  ;  Item Encode ID
  ; ----------------------------------------------------------------------------
  Procedure ItemEncodeID(*item.ControlExplorerItem_t,id.i)
  Protected r = id / 65536
  Math::MAXIMUM(r,0)
  Protected g = (id-r *65536)/256
  Math::MAXIMUM(g,0)
  Protected b = (id- r * 65536 - g * 256)
  Math::MAXIMUM(b,0)
  *item\colorid = RGB(r,g,b)
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Item Decode ID
  ; ----------------------------------------------------------------------------
  Procedure ItemDecodeID(colorid.i)
    Protected id = Red(colorid)*(256*256) + Green(colorid)*256 + Blue(colorid)
    ProcedureReturn id
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  New Item
  ; ----------------------------------------------------------------------------
  Procedure NewItem(*object.Object::Object_t,*parent.ControlExplorerItem_t,id,depth.i,havenext.b)
    Protected *Me.ControlExplorerItem_t = AllocateMemory(SizeOf(ControlExplorerItem_t))
    Object::INI(ControlExplorerItem)

    *Me\object = *object
    *Me\depth = depth

    *Me\isroot = Bool(*Me\object And *Me\object\class And *Me\object\class\name = "Model")
    *Me\expended = #False
    *Me\havechildren = *Me
    *Me\parent = *parent
    *Me\havenext = havenext
    
    ;Set Unique Color ID
    ItemEncodeID(*Me,id)
    
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
    *Me\iwidth = *Me\sizX
    *Me\iheight = *Me\sizY
    *Me\dirty = #True
    ResizeGadget(*Me\gadgetID,0,0,*Me\sizX,*Me\sizY)
  ;   *Me\grp\Event(#PB_EventType_Resize,@ed)
    
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
    Protected depth.i,lastdepth.i
    Protected expended.b,lastexpended.i
    ResetVisited(*Me,*Me\root\object)
    ClearList(*Me\visibles())
    ForEach(*Me\items())
      If (*Me\items()\parent And *Me\items()\parent\expended) Or *Me\items()\isroot = #True
        AddElement(*Me\visibles())
        *Me\visibles() = *Me\items()
      EndIf
    
    Next
    
  ;     expended = *Me\allitems()\expended
  ;     depth = *Me\allitems()\depth
  ;     If lastexpended And depth<=lastdepth
  ;       AddElement(*Me\items())
  ;       *Me\items()=*Me\allitems()
  ;      
  ;     Else
  ;      If depth<=lastdepth
  ;       AddElement(*Me\items())
  ;       *Me\items()=*Me\allitems()
  ;     EndIf
  ;   EndIf
    lastexpended = expended
    lastdepth = depth
  ;   Next
  
  EndProcedure
  
    ; ----------------------------------------
  ;  Set Binary Lines
  ; ----------------------------------------
  Procedure SetBinaryLine(*e.ControlExplorer_t,id.i,value.b)
    Globals::BitWrite(*e\linebinary,id,value)
  EndProcedure
  
  
  ; ----------------------------------------
  ;  Draw
  ; ----------------------------------------
  Procedure DrawItem(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,depth.i)
    
   
    If *item\type = #TYPE_PROPERTY And Not *Me\show_uniforms : ProcedureReturn : EndIf
    If *item\type = #TYPE_ATTRIBUTE And Not *Me\show_attributes : ProcedureReturn : EndIf
  
    Protected shiftx.i = #SHIFTX
    Protected shifty.i = #SHIFTY
    Protected x = 25 + shiftx * (*item\depth)
    Protected tc = RGBA(0,0,0,255)
    VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_TEXT)
    ; Draw Background
    If Mod(*Me\itemcounter,2) = 1
      AddPathBox(0,*Me\ioffsety,*Me\iwidth,shifty)
      VectorSourceColor(UIColor::COLORA_MAIN_BG)
      FillPath()
    Else
      AddPathBox(0,*Me\ioffsety,*Me\iwidth,shifty)
      VectorSourceColor(UIColor::COLORA_SECONDARY_BG)
      FillPath()
    EndIf
    
    ;   ; Draw Selected
    If *item\selected = #True
      AddPathBox(0,*Me\ioffsety,*Me\iwidth,shifty)
      VectorSourceColor(UIColor::COLORA_SELECTED_BG)
    EndIf
    
    ;Draw Item
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
      VectorSourceColor(UIColor::COLORA_GROUP_FRAME)
      StrokePath(2)
    EndIf
  
    ;Draw Connexions
    If *item\havenext
      SetBinaryLine(*Me,depth,#True)
    Else
      SetBinaryLine(*Me,depth,#False)
    EndIf
    
    ;Vertical lines
    Protected i
    VectorSourceColor(UIColor::COLORA_GROUP_FRAME)
    For i=0 To depth-1
      If Globals::BitRead(*Me\linebinary,i)
        MovePathCursor(x-(i)*shiftx+5,*Me\ioffsety-shifty*0.5)
        AddPathLine(0,shifty,#PB_Path_Relative)
        StrokePath(2)
      EndIf
    Next
    
    ;Horizontal line
    MovePathCursor(x-shiftx+5,*Me\ioffsety+shifty/2)
    AddPathLine(shiftx-5,0, #PB_Path_Relative)
    StrokePath(2)
    
    ;Expended button
    If Not *item\isleaf

      AddPathBox(x-shiftx+2,*Me\ioffsety+7,3,3)
      VectorSourceColor(UIColor::COLORA_MAIN_BG)
      FillPath()
      
      VectorSourceColor(UIColor::COLORA_GROUP_FRAME)
      If *item\expended
        MovePathCursor(x-shiftx+4,*Me\ioffsety+10)
        AddPathLine(3,0,#PB_Path_Relative)
        
        StrokePath(2)
      Else
        MovePathCursor(x-shiftx+6,*Me\ioffsety+8)
        AddPathLine(0,3, #PB_Path_Relative)
        StrokePath(2)
        
        MovePathCursor(x-shiftx+4,*Me\ioffsety+10)
        AddPathLine(3,0, #PB_Path_Relative)
        StrokePath(2)
      EndIf
    EndIf
    
    
    ;  Draw Icon
    Select *item\type  
      Case #TYPE_3DOBJECT
        Protected *o.Object3D::Object3D_t = *item\object
        Select *o\type
          Case Object3D::#Model
            ;raaBox(x,*Me\offsety,12,12,RGBA(0,120,255,255))
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_model))
          Case Object3D::#Light
            ;raaBox(x,*Me\offsety,12,12,RGBA(0,120,255,255))
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_light))
          Case Object3D::#Camera
            ;raaBox(x,*Me\offsety,12,12,RGBA(0,120,255,255))
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_camera))
          Case Object3D::#Polymesh
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_polymesh))
            ;raaBox(x,*Me\offsety,12,12,RGBA(255,0,120,255))
          Case Object3D::#Locator
            ;raaBox(x,*Me\offsety,12,12,RGBA(120,255,0,255))
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_null))
          Case Object3D::#Curve
            ;raaBox(x,*Me\offsety,12,12,RGBA(120,255,0,255))
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_curve))
          Case Object3D::#PointCloud
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_pointcloud))
            ;raaBox(x,*Me\offsety,12,12,RGBA(255,255,120,255))
          Case Object3D::#InstanceCloud
            MovePathCursor(x,*Me\ioffsety+2)
            DrawVectorImage(ImageID(explorer_icon_instancecloud))
            
        EndSelect
        MovePathCursor(x+20,*Me\ioffsety+#OFFSETY_TEXT+4)
        VectorSourceColor(tc)
        DrawVectorText(*o\name)
        
      Case #TYPE_GROUP
        MovePathCursor(x,*Me\ioffsety+2)
        DrawVectorImage(ImageID(explorer_icon_group))
        MovePathCursor(x+20,*Me\ioffsety+#OFFSETY_TEXT)
        VectorSourceColor(tc)
        DrawVectorText("Fucking Group")
        
      Case #TYPE_LAYER
        Debug "Explorer Object Layer"
        
      Case #TYPE_MODEL
        
      Case #TYPE_PARAMETER
        
      Case #TYPE_FOLDER
        MovePathCursor(x,*Me\ioffsety+2)
        DrawVectorImage(ImageID(explorer_icon_folder))
        MovePathCursor(x+20,*Me\ioffsety+#OFFSETY_TEXT+4)
        VectorSourceColor(RGBA(0,0,0,255))
        DrawVectorText("Attributes")
        
;       Case #TYPE_PROPERTY
;         DrawImage(ImageID(explorer_icon_kinematics),x,*Me\ioffsety+2)
;         DrawingMode(#PB_2DDrawing_Transparent)
;         DrawText(x+20,*Me\ioffsety+#OFFSETY_TEXT,"Global",RGBA(0,0,0,255))
;         
;       Case #TYPE_ATTRIBUTE
; 
;         Protected *a.Attribute::Attribute_t = *item\object
;         tc  =RGBA(255,0,0,255)
;         Select *a\datatype
;           Case Attribute::#ATTR_TYPE_BOOL
;   ;           Box(x+1,*Me\ioffsety+5,8,8,tc)
;             Circle(x+2,*Me\ioffsety+6,4,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_BOOL,255))
;             DrawingMode(#PB_2DDrawing_Transparent)
;             DrawText(x+15,*Me\ioffsety+#OFFSETY_TEXT,*a\name,tc)
;           Case Attribute::#ATTR_TYPE_FLOAT
;   ;           Box(x+1,*Me\ioffsety+5,8,8,tc)
;   ;           Box(x+2,*Me\ioffsety+6,7,7,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_FLOAT,255))
;             Circle(x+2,*Me\ioffsety+6,4,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_FLOAT,255))
;             DrawingMode(#PB_2DDrawing_Transparent)
;             DrawText(x+15,*Me\ioffsety+#OFFSETY_TEXT,*a\name,tc)
;           Case Attribute::#ATTR_TYPE_VECTOR3
;   ;           Box(x+1,*Me\ioffsety+5,8,8,tc)
;   ;           Box(x+2,*Me\ioffsety+6,7,7,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_VECTOR3,255))
;             Circle(x+2,*Me\ioffsety+6,4,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_VECTOR3,255))
;             DrawingMode(#PB_2DDrawing_Transparent)
;             DrawText(x+15,*Me\ioffsety+#OFFSETY_TEXT,*a\name,tc)
;           Case Attribute::#ATTR_TYPE_MATRIX4
;   ;           Box(x+1,*Me\ioffsety+5,8,8,tc)
;             Circle(x+2,*Me\ioffsety+6,4,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_MATRIX4,255))
;             DrawingMode(#PB_2DDrawing_Transparent)
;             DrawText(x+15,*Me\ioffsety+#OFFSETY_TEXT,*a\name,tc)
;           Case Attribute::#ATTR_TYPE_COLOR
;   ;           Box(x+1,*Me\ioffsety+5,8,8,tc)
;             Circle(x+2,*Me\ioffsety+6,4,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_COLOR,255))
;             DrawingMode(#PB_2DDrawing_Transparent)
;             DrawText(x+15,*Me\ioffsety+#OFFSETY_TEXT,*a\name,tc)
;           Case Attribute::#ATTR_TYPE_TOPOLOGY
;   ;           Box(x+1,*Me\ioffsety+5,8,8,tc)
;             Circle(x+2,*Me\ioffsety+6,4,Globals::RGB2RGBA(Attribute::#ATTR_COLOR_TOPOLOGY,255))
;             DrawingMode(#PB_2DDrawing_Transparent)
;             DrawText(x+15,*Me\ioffsety+#OFFSETY_TEXT,*a\name,tc)
;             
;           Default 
;   ;           Box(x+1,*Me\ioffsety+5,8,8,RGBA(0,0,0,255))
;             Circle(x+2,*Me\ioffsety+6,4,RGBA(255,255,255,255))
;             DrawingMode(#PB_2DDrawing_Default|#PB_2DDrawing_Transparent)
;             DrawText(x+15,*Me\ioffsety+#OFFSETY_TEXT,*a\name,tc)
;         EndSelect
        
      
    EndSelect
    
    *Me\ioffsety + #LINEHEIGHT
  ;   Protected nbc.i = ListSize(*item\children())
  ;   If nbc>0 And *item\expended = #True
  ;     ForEach *item\children()
  ;       Define *item2.CControlExplorerItem_t = *item\children()
  ;       If *item2\expended
  ;         DrawItem(*Me,*item2,depth+1)
  ;       EndIf
  ;     Next
  ;   EndIf
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Image 
  ; ----------------------------------------
  Procedure DrawDisplayImage(*Me.ControlExplorer_t)
    *Me\ioffsetx = 25
    *Me\ioffsety = #TOPHEIGHT
    *Me\itemcounter = 1

    StartVectorDrawing(ImageVectorOutput(*Me\imageID))
    AddPathBox(0,0,*Me\iwidth,*Me\iheight)
    VectorSourceColor(UIColor::COLORA_MAIN_BG)
    FillPath()
    *Me\linebinary = 0
    ForEach *Me\visibles()
      DrawItem(*Me,*Me\visibles(),0)
    Next
  ;   *Me\grp\Event(#PB_EventType_Draw)
    StopVectorDrawing()
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Pick Item
  ; ----------------------------------------
  Procedure DrawPickItem(*Me.ControlExplorer_t,*item.ControlExplorerItem_t,depth.i)
    If *item\type = #TYPE_PROPERTY And Not *Me\show_uniforms : ProcedureReturn : EndIf
    If *item\type = #TYPE_ATTRIBUTE And Not *Me\show_uniforms : ProcedureReturn : EndIf
    
    AddPathBox(0,*Me\ioffsety,*Me\iwidth,#LINEHEIGHT)
    VectorSourceColor(*item\colorid)
  ;   DrawText(0,*Me\ioffsety,Str(*item\colorid))
    *Me\ioffsety + #LINEHEIGHT
    Protected nbc.i = ListSize(*item\children())
  ;   If nbc>0 And *item\expended = #True Or *item\isroot
  ;     Protected i
  ;     ForEach *item\children()
  ;       Define *item2.CControlExplorerItem_t = *item\children()
  ;       If *item2\expended
  ;         DrawPickItem(*Me,*item2,depth+1)
  ;       EndIf
  ;     Next
  ;   EndIf
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------
  Procedure DrawPickImage(*Me.ControlExplorer_t)
    *Me\ioffsetx = 5
    *Me\ioffsety = #TOPHEIGHT
    *Me\itemcounter = 1
    If *Me\iwidth And *Me\iheight
      ResizeImage(*Me\pickID,*Me\iwidth,*Me\iheight)
      StartVectorDrawing(ImageVectorOutput(*Me\pickID))
      AddPathBox(0,0,*Me\iwidth,*Me\iheight)
      VectorSourceColor(RGBA(0,0,0,255))
      
       ForEach *Me\visibles()
        DrawPickItem(*Me,*Me\visibles(),0)
      Next
      StopVectorDrawing()
    EndIf
    
    
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Canvas
  ; ----------------------------------------
  Procedure Draw(*Me.ControlExplorer_t)
  
    If *Me\dirty
      DrawPickImage(*Me)
      DrawDisplayImage(*Me)
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
        ;OScene_AddToSelection(*Me\scene,*item\object)
  ;       OScene_SelectObject_Do(*item\object)
      Case #TYPE_3DOBJECT
        MessageRequester("Select Object","Should Increment Command Stack!!!")
        ;OScene_AddToSelection(*Me\scene,*item\object)
  ;       OScene_SelectObject_Do(*item\object)
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
  ; Recurse Expended
  ; ----------------------------------------
  Procedure RecurseExpended(*item.ControlExplorerItem_t,expended.b = #False)
  
    *item\expended = expended
    ForEach *item\children()
      RecurseExpended(*item\children(),expended)
    Next
    
  EndProcedure
  
  
  ; ----------------------------------------
  ; Pick
  ; ----------------------------------------
  Procedure Pick(*Me.ControlExplorer_t)
   
    Protected mx = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
    Protected my = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
   
    
    ; Return if OUT of picking area
    If mx<0 Or mx>=*Me\iwidth Or my<0 Or my>*Me\iheight:ProcedureReturn:EndIf
    
    ; Get Point Color 
    StartDrawing(ImageOutput(*Me\pickID))
    Protected key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)
    Protected pnt = Point(mx,my)
    StopDrawing()
    
    ; Convert to ID
    Protected id = ItemDecodeID(pnt)-1

    If id>=0 And id < ListSize(*Me\items())
      *Me\pick = id
      SelectElement(*Me\items(),id)
  
      Protected *item.ControlExplorerItem_t = *Me\items()
  
      If *item <>#Null
        Protected l = (*item\depth+2) * #SHIFTX
        If Abs(l-mx)<20
          If Not *item\isleaf
            *item\expended = 1-*item\expended
             RecurseExpended(*item, *item\expended)
            
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
              Else
                ; do nothing
              EndIf
              
  
            Default
              ;Clear Selection before adding item
              UnselectAll(*Me)
              *item\selected = #True
              AddElement(*Me\selected())
              *Me\selected() = *item
              ;             OScene_SelectObject_Do(*item\object)
              If *item\type = #TYPE_3DOBJECT
                Scene::SelectObject(*Me\scene,*item\object)
              EndIf
              
          EndSelect
         
          *Me\dirty = #True
        EndIf
      EndIf
    EndIf
    
    If ListSize(*Me\selected())>0
      ForEach *Me\selected()
       Scene::AddToSelection(*Me\scene,*Me\selected())
      Next
    EndIf
    
    
    If *Me\dirty
      GetVisibles(*Me)
      DrawPickImage(*Me)
      DrawDisplayImage(*Me)
      *Me\dirty = #False
    EndIf
    
    
    
   
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
    If *item\depth>*Me\expended_level : *item\expended = #False : EndIf
    
    *Me\itemcounter +1
    *Me\type = type
    *Me\iheight + #LINEHEIGHT
    Protected nw.i = TextWidth(name)+(depth+1)*#SHIFTX
    Math::MAXIMUM(*Me\iwidth,nw)
    *Me\items() = *item\children()
    Select type
      Case #TYPE_ATTRIBUTE
        *Me\items()\expended = *Me\show_attributes
        *Me\items()\isleaf = #True
      Case #TYPE_PROPERTY
        *Me\items()\expended = *Me\show_uniforms
      Case #TYPE_GROUP
        *Me\items()\isleaf = #True
        *Me\items()\expended = *Me\show_attributes
      Case #TYPE_3DOBJECT
        *Me\items()\expended = #True
        *Me\items()\isleaf = #False
      Case #TYPE_STACK
        *Me\items()\expended = #True
        *Me\items()\isleaf = #False
      Case #TYPE_TREE
        *Me\items()\expended = #True
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
    *item\expended = #True
    Protected *o.ControlExplorerItem_t
    
    If *obj\stack
      Protected *stack.ControlExplorerItem_t = AddObject(*Me,*item,*obj\stack,"Stack",depth+2,#TYPE_STACK)
      ForEach *obj\stack\levels()
        Protected *tree.ControlExplorerItem_t = AddObject(*Me,*stack,*obj\stack\levels(),"Tree",depth+3,#TYPE_TREE)
      Next
    EndIf
    
  
    Protected *attributes.ControlExplorerItem_t = AddObject(*Me,*item,#Null,"Attributes",depth+2,#TYPE_PROPERTY)
    *attributes\expended = #True
    *attributes\havenext = #False
    Protected nb = MapSize(*obj\geom\m_attributes())
    Protected a
    Protected *attr.Attribute::Attribute_t

    Protected cnt
    
    ForEach  *obj\geom\m_attributes()
      *attr = *obj\geom\m_attributes();\GetValue(a) 
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
    *Me\itemcounter = 1
    
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
    
    GetVisibles(*Me)
;     ConnectSignalsSlots(*Me)
    RecurseExpended(*Me\root,#False)
    *Me\dirty = #True
  EndProcedure
  
  
  ;----------------------------------------
  ;  Event
  ;---------------------------------------------------
  Procedure OnEvent(*e.ControlExplorer_t,event.i,*ev_data.Control::EventTypeDatas_t)
    ;   GetItems(*e)
    CompilerIf #PB_Compiler_Version < 560
        If event =  Control::#PB_EventType_Resize Or event = #PB_Event_SizeWindow
      CompilerElse
        If event = #PB_EventType_Resize Or event = #PB_Event_SizeWindow
    CompilerEndIf
      *e\sizX = *ev_data\width
      *e\sizY = *ev_data\height
      Resize(*e)
      Draw(*e)
      
    ElseIf event = #PB_Event_Gadget
      Protected evdt.Control::EventTypeDatas_t
      Protected mx = GetGadgetAttribute(*e\gadgetID,#PB_Canvas_MouseX)
      Protected my = GetGadgetAttribute(*e\gadgetID,#PB_Canvas_MouseY)

  
        Protected key
        Select EventType()
          Case #PB_EventType_KeyDown
            key = GetGadgetAttribute(*e\gadgetID,#PB_Canvas_Key)
;             If key = #PB_Shortcut_Space 
;               *e\scrolling = #True
;               *e\scrolllastx = GetGadgetAttribute(*e\gadgetID,#PB_Canvas_MouseX)
;               *e\scrolllasty = GetGadgetAttribute(*e\gadgetID,#PB_Canvas_MouseY)
;               SetGadgetAttribute(*e\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Hand)
;             EndIf
            
          Case #PB_EventType_KeyUp
            
            key = GetGadgetAttribute(*e\gadgetID,#PB_Canvas_Key)
            If key = #PB_Shortcut_Space ;And *e\scrollable And *e\scrolling
;               *e\scrolling = #False
              SetGadgetAttribute(*e\gadgetID,#PB_Canvas_Cursor,#PB_Cursor_Default)
            EndIf
            
          Case #PB_EventType_MouseMove
            ;UI::Scroll(*e)
            
            
          Case #PB_EventType_LeftButtonDown 
            ;DrawPickImage(*e)
            Pick(*e)
          
            
        EndSelect
      
      
    EndIf
    
    
    ;Redraw Explorer
    Draw(*e)
    
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
  ;   Protected *e.ExplorerUI_t = *c\parent
  ;   Protected v.i = *c\value_n
  ; 
  ;   Draw(*e)
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
  Procedure Delete(*e.ControlExplorer_t)
    FreeMemory(*e)
  EndProcedure
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*obj.Object::Object_t,x.i,y.i,w.i,h.i)
    Protected *Me.ControlExplorer_t = AllocateMemory(SizeOf(ControlExplorer_t))
    Object::INI( ControlExplorer )
    
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = w
    *Me\sizY = h
  
    *Me\name = "Explorer"
    
    ;Initialize Structures
    InitializeStructure(*Me,ControlExplorer_t)
    
    ; ---[ Explorer ]------------------------
    *Me\type = Globals::#VIEW_EXPLORER
    *Me\show_uniforms = #True
    *Me\show_attributes = #True
    *Me\show_materials = #True
    *Me\expended_level = 12
;     *Me\scrollable = #True
    

    ; ---[ Set Canvas ]----------------------
    *Me\gadgetID = CanvasGadget(#PB_Any,0,0,*Me\sizX,*Me\sizY,#PB_Canvas_Keyboard|#PB_Canvas_DrawFocus)

    ; ---[ Set Controls ]----------------------
    Protected options.i = ControlGroup::#Autosize_V|ControlGroup::#Autosize_h
      
    ; ---[ Set Images ]----------------------
    *Me\imageID = CreateImage(#PB_Any,*Me\sizX,*Me\sizY)
    *Me\pickID = CreateImage(#PB_Any,*Me\sizX,*Me\sizY)
    
    ; ---[ Splitter ]-------------------------
    *Me\dirty = #True
    
  
    
    
;     If Scene::*current_scene
;       Fill(*Me,Scene::*current_scene)
; 
;       ConnectSignalsSlots(*Me)
;       RecurseExpended(*Me\root,#False);
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
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 484
; FirstLine = 457
; Folding = f2Xef-
; EnableXP
;===============================================================================
; Vector Module Declaration
;===============================================================================
DeclareModule Vector
  Structure Item_t
    stroke.i
    stroke_width.f
    color.i
    filled.b
    closed.b
    preserve.b
    segments.s
  EndStructure
  
  Structure Icon_t Extends Item_t
    name.s
    List items.Item_t()
  EndStructure
  
  Declare Clear(*icon.Icon_t)
  Declare AddItem(*icon.Icon_t, stroke.i=#PB_Path_Default, stroke_width.f=2, color.i=0, closed.b=#False, filled.b=#False, preserve.b=#True)
  Declare WriteToFile(*icon.Icon_t, filename.s)
  Declare ReadFromFile(*icon.Icon_t, filename.s)
  Declare Draw(*icon.Icon_t)
  Declare RoundBoxPath(width.f, height.f, radius.f=6, offsetx=0, offsety=0, stroke_width=2)
EndDeclareModule


;===============================================================================
; Vector Module Implementation
;===============================================================================
Module Vector
  ;-----------------------------------------------------------------------------
  ; WRITE TO FILE
  ;-----------------------------------------------------------------------------
  Procedure WriteToFile(*icon.Icon_t, filename.s)
    ; Create xml tree
    Protected xml = CreateXML(#PB_Any) 
    Protected node = CreateXMLNode(RootXMLNode(xml), *icon\name) 
    SetXMLNodeName(node, *icon\name)
    SetXMLNodeText(node, "What tHE fUCK YOU MEAN FUCKIN DEAD?")
    Protected i = 0
    
    ; loop items
    ForEach(*icon\items())
      ; Create first xml node (in main node)
      item = CreateXMLNode(node, "Item"+Str(i)) 
      SetXMLAttribute(item, "stroke", Str(*icon\items()\stroke)) 
      SetXMLAttribute(item, "stroke_width", StrF(*icon\items()\stroke_width)) 
      SetXMLAttribute(item, "color", Str(*icon\items()\color)) 
      SetXMLAttribute(item, "filled", StrF(*icon\items()\filled)) 
      SetXMLAttribute(item, "closed", StrF(*icon\items()\closed)) 
      SetXMLAttribute(item, "preserve", StrF(*icon\items()\preserve)) 
      SetXMLNodeText(item, *icon\items()\segments)
      i + 1
    Next
    
    ; format xml
    FormatXML(xml, #PB_XML_ReFormat )
    ; Save the xml tree into a xml file
    SaveXML(xml, filename)

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; READ FROM FILE
  ;-----------------------------------------------------------------------------
  Procedure ReadFromFile(*icon.Icon_t, filename.s)
    Protected xml = LoadXML(#PB_Any, filename)
    If XMLStatus(xml) <> #PB_XML_Success
      Protected msg.s = "Error in the XML file:" + Chr(13)
      msg + "Message: " + XMLError(xml) + Chr(13)
      msg + "Line: " + Str(XMLErrorLine(xml)) + "   Character: " + Str(XMLErrorPosition(xml))
      MessageRequester("[Vector] Error", msg)
    Else
      ; clear old datas if any
      Clear(*icon)
      ; get the main xml node
      Protected *node = MainXMLNode(xml)      
      If *node
        *icon\name = GetXMLNodeName(*node)
        Protected numItems = XMLChildCount(*node)
        MessageRequester("XML", Str(numItems))
        Protected i
        Protected *child
        For i=1 To numItems
          *child = ChildXMLNode(*node , i)  
          If *child
            AddElement(*icon\items())
            *icon\items()\stroke        = Val(GetXMLAttribute(*child, "stroke"))
            *icon\items()\stroke_width  = ValF(GetXMLAttribute(*child, "stroke_width"))
            *icon\items()\color         = Val(GetXMLAttribute(*child, "color"))
            *icon\items()\filled        = Val(GetXMLAttribute(*child, "filled"))
            *icon\items()\closed        = Val(GetXMLAttribute(*child, "closed"))
            *icon\items()\preserve      = Val(GetXMLAttribute(*child, "preserve"))
            *icon\items()\segments      = GetXMLNodeText(*child)
          EndIf
        Next
      EndIf
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; CLEAR
  ;-----------------------------------------------------------------------------
  Procedure Clear(*icon.Icon_t)
    ClearList(*icon\items())
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; DRAW
  ;-----------------------------------------------------------------------------
  Procedure Draw(*icon.Icon_t)
    ForEach *icon\items()
      With *icon\items()
        AddPathSegments(\segments)
        If \filled
          VectorSourceColor(\color)
          FillPath(#PB_Path_Preserve)
        Else
          VectorSourceColor(\color)
          StrokePath(\stroke_width)
        EndIf
      EndWith
    Next
    
    If *icon\segments
      AddPathSegments(*icon\segments)
      If *icon\filled
        VectorSourceColor(*icon\color)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(*icon\color)
      StrokePath(*icon\stroke_width)
      EndIf
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; ADD ITEM
  ;-----------------------------------------------------------------------------
  Procedure AddItem(*icon.Icon_t, stroke.i=#PB_Path_Default, stroke_width.f=2, color.i=0, closed.b=#False, filled.b=#False, preserve.b=#True)
    AddElement(*icon\items())
    *icon\items()\stroke        = stroke
    *icon\items()\stroke_width  = stroke_width
    *icon\items()\color         = color
    *icon\items()\filled        = filled
    *icon\items()\closed        = closed
    *icon\items()\preserve      = preserve
    *icon\items()\segments      = PathSegments()
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; ROUND BOX PATH
  ;-----------------------------------------------------------------------------
  Procedure RoundBoxPath(width.f, height.f, radius.f=6, offsetx=0, offsety=0, stroke_width=2)
    MovePathCursor(offsetx + radius,offsety)
    AddPathArc(offsetx+width,offsety,offsetx+width,offsety+height,radius)
    AddPathArc(offsetx+width,offsety+height,offsetx,offsety+height,radius)
    AddPathArc(offsetx,offsety+height,offsetx,offsety,radius)
    AddPathArc(offsetx,offsety,offsetx+width,offsety,radius)
    ClosePath()
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; STAR PATH
  ;-----------------------------------------------------------------------------
  Procedure StarPath(center_x.f, center_y.f, inner_radius.f, outer_radius.f, num_branches.i)
    MovePathCursor(center_x ,center_y + outer_radius)
;     AddPathArc(offsetx+width,offsety,offsetx+width,offsety+height,radius)
;     AddPathArc(offsetx+width,offsety+height,offsetx,offsety+height,radius)
;     AddPathArc(offsetx,offsety+height,offsetx,offsety,radius)
;     AddPathArc(offsetx,offsety,offsetx+width,offsety,radius)
    ClosePath()
  EndProcedure
  
  
EndModule

Procedure Bulb()
  Define window = OpenWindow(#PB_Any, 0,0,800,800, "VECTOR")
  Define canvas = CanvasGadget(#PB_Any, 0,0,800,800)
  Define size = 32
  Define radius = 6
  Define offsetx = 20
  Define offsetY = 20
  Define stroke_width = 2

  Define icon.Vector::Icon_t
  icon\name = "ICON1"
  InitializeStructure(icon, Vector::Icon_t)
  Define color.i
  
  StartVectorDrawing(CanvasVectorOutput(canvas))
  ScaleCoordinates(10,10)
  BeginVectorLayer()
    Vector::RoundBoxPath(size, size, radius, offsetx, offsety, stroke_width)
    color = RGBA(128,128,128,255)
    VectorSourceColor(color)
    Vector::AddItem(icon, 0,0,color,#False, #True, #True)
    FillPath(#PB_Path_Preserve)
    
    
    color = RGBA(100,100,100,255)
    VectorSourceColor(color)
    Vector::AddItem(icon, #PB_Path_RoundCorner | #PB_Path_RoundEnd,stroke_width,color,#True, #False, #False)
    StrokePath(stroke_width, #PB_Path_RoundCorner | #PB_Path_RoundEnd)
  EndVectorLayer()
    
    
  BeginVectorLayer()
  AddPathCircle(offsetx + size*0.5, offsety + size * 0.33, size*0.25)
  color = RGBA(255,255,128,255)
  VectorSourceColor(color)
  Vector::AddItem(icon, #PB_Path_Default,0,color,#False, #True, #True)
  FillPath(#PB_Path_Preserve)
  
  color = RGBA(255,255,222,255)
  VectorSourceColor(color)
  Vector::AddItem(icon, #PB_Path_RoundCorner | #PB_Path_RoundEnd,stroke_width,color,#True, #False, #False)
  StrokePath(stroke_width, #PB_Path_RoundCorner | #PB_Path_RoundEnd)
   
  EndVectorLayer()
  
  StopVectorDrawing()
  
  Vector::WriteToFile(icon, "E:/Projects/RnD/Noodle/rsc/vector/icon1.xml")
  
  Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
EndProcedure

Procedure FromFile()
  Define window = OpenWindow(#PB_Any, 0,0,800,800, "VECTOR")
  Define canvas = CanvasGadget(#PB_Any, 0,0,800,800)
  Define size = 32
  Define radius = 6
  Define offsetx = 20
  Define offsetY = 20
  Define stroke_width = 2

  Define icon.Vector::Icon_t
  icon\name = "ICON1"
  InitializeStructure(icon, Vector::Icon_t)
  Define color.i
  
  Vector::ReadFromFile(icon, "E:/Projects/RnD/Noodle/rsc/vector/icon1.xml")
  StartVectorDrawing(CanvasVectorOutput(canvas))
  Vector::Draw(icon)
  StopVectorDrawing()
  
  Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
EndProcedure





; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 226
; FirstLine = 197
; Folding = --
; EnableXP
XIncludeFile "../core/Vector.pbi"
XIncludeFile "../core/Callback.pbi"
XIncludeFile "../core/Sheet.pbi"
XIncludeFile "../ui/UI.pbi"


; ==================================================================
;   CANVAS MODULE DECLARATION
; ==================================================================
DeclareModule CanvasUI
  UseModule Globals
  
  Structure CanvasUI_t Extends UI::UI_t    
    List *sheets.sheet::Sheet_t()
    *sheet.sheet::Sheet_t
    primary.l
    secondary.l
    color.l
    pixelratio.f
    *on_content_change.Callback::Callback_t
    *on_selection_change.Callback::Callback_t
  EndStructure
  
  Interface ICanvasUI Extends UI::IUI
  EndInterface
   
  Declare New(*parent.View::View_t,name.s="CanvasUI")
  Declare Delete(*Me.CanvasUI_t)
  Declare Resize(*Me.CanvasUI_t, x.i, y.i, width.i, height.i)
  Declare Draw(*Me.CanvasUI_t)
  Declare OnEvent(*Me.CanvasUI_t, event.i)
  

  Declare UpdateZoom(*Me.CanvasUI_t,delta.i, mx.f=0, my.f=0)
  Declare DrawGrid(*Me.CanvasUI_t)
  Declare ResetSheets(*Me.CanvasUI_t)
  Declare SetActiveTool(*Me.CanvasUI_t, tool.i)
  Declare NewSheet(*Me.CanvasUI_t)
  Declare AddSheet(*Me.CanvasUI_t, *sheet.Sheet::Sheet_t)
  Declare DeleteSheet(*Me.CanvasUI_t, *sheet.Sheet::Sheet_t)
  Declare SetActiveSheet(*Me.CanvasUI_t, index.i)
  
  DataSection
    CanvasUIVT:
      Data.i @OnEvent()
      Data.i @Delete()
      Data.i @Draw()
  EndDataSection
  
EndDeclareModule

; ==================================================================
;   CANVAS UI MODULE IMPLEMENTATION
; ==================================================================
Module CanvasUI
  UseModule Globals

  Procedure New(*view.View::View_t,name.s="CanvasUI")
    *Me.CanvasUI_t = AllocateStructure(CanvasUI_t)
    Object::INI(CanvasUI)
    *Me\posX = *view\posX
    *Me\posY = *view\posY
    *Me\sizX = *view\sizX
    *Me\sizY = *view\sizY
    *Me\pixelratio = *view\sizX / *view\sizY
    *Me\secondary = RGBA(120,12,66,255)
    *Me\gadgetID = CanvasGadget(#PB_Any,*view\posX,*view\posY,*view\sizX, *view\sizY,#PB_Canvas_Keyboard)
    *Me\zoom = 100
    *Me\on_content_change = Object::NewCallback(*Me, "OnContentChange")
    *Me\on_selection_change = Object::NewCallback(*Me, "OnSelectionChange")
    UpdateZoom(*Me,0)
    ResetSheets(*Me)
    View::SetContent(*view, *Me)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.CanvasUI_t)
    FreeGadget(*Me\gadgetID)
    FreeImage(*Me\imageID)
    Object::TERM(CanvasUI)
  EndProcedure

  Procedure SetActiveTool(*Me.CanvasUI_t, tool.i)
  EndProcedure
  
  Procedure NewSheet(*Me.CanvasUI_t)
    Define *sheet.Sheet::Sheet_t = Sheet::New(GadgetWidth(*Me\gadgetID),GadgetHeight(*Me\gadgetID))
    AddElement(*Me\sheets())
    *Me\sheets() = *sheet
    *Me\sheet = *sheet
    ProcedureReturn *Me\sheet
  EndProcedure
  
  Procedure AddSheet(*Me.CanvasUI_t, *sheet.Sheet::Sheet_t)
    AddElement(*Me\sheets())
    *Me\sheets() = *sheet
    *Me\sheet = *sheet
    ProcedureReturn *Me\sheet
  EndProcedure
  
  Procedure DeleteSheet(*Me.CanvasUI_t, *sheet.Sheet::Sheet_t)
    If *Me\sheets() = *sheet
      Sheet::Delete(*sheet)
      DeleteElement(*Me\sheets())
    Else
      ForEach *Me\sheets()
        If *Me\sheets() = *sheet
          Sheet::Delete(*sheet)
          DeleteElement(*Me\sheets())
          Break
        EndIf
      Next
    EndIf
  EndProcedure
  
  Procedure SetActiveSheet(*Me.CanvasUI_t, index.i)
    If index >-1 And index < ListSize(*Me\sheets())
      SelectElement(*Me\sheets(), index)
      *Me\sheet = *Me\sheets()
;       Tool::SetSheet(*Me\tool, *Me\sheet)
    EndIf
  EndProcedure
  
  Procedure SetCurrentColor(*Me.CanvasUI_t,*color.Math::c4f32)
    *Me\color = RGBA(*color\r,*color\g,*color\b,*color\a)
    *Me\primary = RGBA(*color\r,*color\g,*color\b,*color\a)
  EndProcedure

  Procedure SetPixelRatio(*Me.CanvasUI_t,ratio.f)
    *Me\pixelratio = ratio
  EndProcedure

  Procedure UpdateZoom(*Me.CanvasUI_t,delta.i, mx.f=0, my.f=0)
    
    Protected width = GadgetWidth(*Me\gadgetID)
    Protected height = GadgetHeight(*Me\gadgetID)
    
    Protected x = (width/mx * 2) - 1
    Protected y = (height/my * 2) - 1
;     *Me\offsetx - x
;     *Me\offsety - y
    *Me\zoom + delta
    Globals::CLAMPIZE(*Me\zoom,5,5000)
    
  EndProcedure

  Procedure DrawGrid(*Me.CanvasUI_t)
    ResetPath()
  
    Protected mx.f = *Me\sizX
    Protected my.f = *Me\sizY * *Me\pixelratio
    Protected x,y
    
    For x=0 To *Me\sizX - 1 Step 24
      MovePathCursor(x*mx* *Me\zoom, 0)
      AddPathLine(x*mx* *Me\zoom, *Me\sizY* *Me\zoom)
    Next
    
    For y=0 To *Me\sizY - 1 Step 24
      MovePathCursor(0,y*my * *Me\zoom)
      AddPathLine(*Me\sizX* *Me\zoom, y*my * *Me\zoom)
    Next
    VectorSourceColor(UIColor::COLOR_LINE_DIMMED)
    StrokePath(0.2)

  EndProcedure

  Procedure Draw(*Me.CanvasUI_t)
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    ResetCoordinates(#PB_Coordinate_User)
    AddPathBox(0,0,GadgetWidth(*Me\gadgetID), GadgetHeight(*Me\gadgetID))
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
    
    ScaleCoordinates(*Me\zoom * 0.01, *Me\zoom * 0.01)
    TranslateCoordinates(*Me\offsetx, *Me\offsety)
    DrawGrid(*Me)
    ForEach(*Me\sheets())
      Sheet::Draw(*Me\sheets())
    Next
    StopVectorDrawing()
  EndProcedure
  
  Procedure ResetSheets(*Me.CanvasUI_t)
    If ListSize(*Me\sheets())
      ForEach *Me\sheets()
        Sheet::Delete(*Me\sheets())
      Next
      ClearList(*Me\sheets())
    EndIf
    
    *Me\sheet = Sheet::New(*Me\sizX,*Me\sizY,0)
    AddElement(*Me\sheets())
    *Me\sheets() = *Me\sheet
  EndProcedure

  Procedure Resize(*Me.CanvasUI_t, x.i, y.i, width.i, height.i)
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width
    *Me\sizY = height
    ResizeGadget(*Me\gadgetID, x, y, width, height)
    Draw(*Me)
  EndProcedure
  
  Procedure OnEvent(*Me.CanvasUI_t, event.i)
    Protected mx,my,x.f,y.f,w,h,m,key
    Select event
      Case #PB_Event_Menu
        Select EventMenu()
          Case Globals::#SHORTCUT_TRANSLATE
            Debug "Canvas Translate Tool"
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSLATE)
;             *Me\tool = Globals::#TOOL_TRANSLATE                
          Case Globals::#SHORTCUT_ROTATE
            Debug "Canvas Rotate Tool"
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_ROTATE)
;             *Me\tool = Globals::#TOOL_ROTATE
          Case Globals::#SHORTCUT_SCALE
            Debug "Canvas Scale Tool"
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_SCALE)
;             *Me\tool = Globals::#TOOL_SCALE
          Case Globals::#SHORTCUT_TRANSFORM
            Debug "Canvas Transform Tool"
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSFORM)
;             *Me\tool = Globals::#TOOL_TRANSFORM
          Case Globals::#SHORTCUT_CAMERA
            Debug "Canvas Camera Tool"
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_CAMERA)
;             *Me\tool = Globals::#TOOL_CAMERA
            
          Case Globals::#SHORTCUT_DELETE
            MessageRequester("DELETE", "FUCKIN SOMETHING")
          Default 
            ;             *Me\tool = Globals::#TOOL_MAX   
            Debug "Canvas Default Menu Callback"
        EndSelect
        
      Case Globals::#EVENT_TOOL_CHANGED
        Debug "TOOL CHANGED !!!"
        
        
      Case #PB_Event_Gadget
        mx = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
        my = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
        
        Define invzoom.f = 1 / (*Me\zoom *0.01)
        x = mx * invzoom
        y = my * invzoom
        
        w = GadgetWidth(*Me\gadgetID)
        h = GadgetHeight(*Me\gadgetID)
        Select EventType()
          
          Case #PB_EventType_MouseMove
            If Not *Me\down
              StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
              ResetCoordinates(#PB_Coordinate_User)
              ScaleCoordinates(*Me\zoom*0.01, *Me\zoom * 0.01)
              TranslateCoordinates(*Me\offsetx, *Me\offsety)
              If *Me\sheet : Sheet::Pick(*Me\sheet, mx, my) : EndIf
              StopVectorDrawing()
            Else
              modifiers = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
              If modifiers & #PB_Canvas_Alt
                SetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Hand)
                *Me\offsetx - (*Me\last_x - x) 
                *Me\offsety - (*Me\last_y - y) 
              Else
                
    ;             Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety )
              EndIf
              
            EndIf
                
          Case #PB_EventType_KeyDown
            key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key)
            modifiers = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
             
            Select key
              Case #PB_Shortcut_Up
                Sheet::Shift(*Me\sheet,0,-1)
                
              Case #PB_Shortcut_Down
                Sheet::Shift(*Me\sheet,0,10)
                
              Case #PB_Shortcut_Left
                Sheet::Shift(*Me\sheet,-1,0)
                
              Case #PB_Shortcut_Right
                Sheet::Shift(*Me\sheet,1,0)
                Draw(*Me)
               
                
              Case #PB_Shortcut_Delete
                If *Me\sheet\active
                  Sheet::RemoveItem(*Me\sheet, *Me\sheet\active)
                EndIf
                
            EndSelect
            
          Case #PB_EventType_DragStart
            
          Case #PB_EventType_MouseWheel
            Protected delta =  GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_WheelDelta)*5
            UpdateZoom(*Me,delta, mx, my)
            
          Case #PB_EventType_LeftDoubleClick
    ;         Tool::Change(*Me\tool, Tool::#TOOL_EDIT)
            If *Me\sheet\over
    ;           Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety )
            EndIf
      
          Case #PB_EventType_LeftButtonDown
            *Me\down = #True
            If *Me\sheet\over
              Debug *Me\sheet\over
              Define needUpdate.b = #True
              If *Me\sheet\active And *Me\sheet\active = *Me\sheet\over
                needUpdate = #False
              EndIf
              
              *Me\sheet\active = *Me\sheet\over
              Vector::SETSTATE(*Me\sheet\active, Vector::#STATE_ACTIVE)
    ;           Selection::Clear(*Me\tool\selection)
    ;           Selection::AddAtom(*Me\tool\selection, *Me\sheet\over)
              If needUpdate :  Callback::Trigger(*Me\on_selection_change, Callback::#SIGNAL_TYPE_PING) : EndIf
            EndIf
    ;         Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety )
            
          Case #PB_EventType_LeftButtonUp
            SetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default)
            ;         Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety)
            *Me\down = #False
             
          Case #PB_EventType_RightButtonDown
            *Me\color = RGBA(0,0,0,0)
            
          Case #PB_EventType_RightButtonUp
            *Me\color = *Me\primary
            
            
        EndSelect  
        Draw(*Me)
        *Me\last_x = x
        *Me\last_y = y
      EndSelect
      
  EndProcedure
  
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 204
; FirstLine = 191
; Folding = ---
; EnableXP
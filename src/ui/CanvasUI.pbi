XIncludeFile "../core/Vector.pbi"
XIncludeFile "../core/Callback.pbi"
XIncludeFile "../core/Tool.pbi"
XIncludeFile "../core/Sheet.pbi"
XIncludeFile "../ui/UI.pbi"


; ==================================================================
;   CANVAS MODULE DECLARATION
; ==================================================================
DeclareModule CanvasUI
  UseModule Globals
  
  ; ----------------------------------------------------------------
  ;   Structure
  ; ----------------------------------------------------------------
  Structure CanvasUI_t Extends UI::UI_t
    resx.i        ; Nb Pixels X
    resy.i        ; Nb Pixels Y
    
    List *sheets.sheet::Sheet_t()
    *sheet.sheet::Sheet_t
    *tool.Tool::Tool_t
    modifier.i
    primary.l
    secondary.l
    color.l
    erase.b
    line.b
    
    pixelratio.f
    *on_content_change.Signal::Signal_t
    *on_selection_change.Signal::Signal_t
  EndStructure
  
  ; ----------------------------------------------------------------
  ;   Interface
  ; ----------------------------------------------------------------
  Interface ICanvasUI Extends UI::IUI
  EndInterface
   
  Declare New(*parent.View::View_t,name.s="CanvasUI")
  Declare Delete(*Me.CanvasUI_t)
  Declare Resize(*Me.CanvasUI_t, x.i, y.i, width.i, height.i)
  Declare Draw(*Me.CanvasUI_t)
  Declare OnEvent(*Me.CanvasUI_t)
  
  Declare ClearDatas(*Me.CanvasUI_t)
  Declare SetPixelRatio(*Me.CanvasUI_t,ratio.f)
  Declare UpdateZoom(*Me.CanvasUI_t,delta.i, mx.f=0, my.f=0)
  Declare DrawGrid(*Me.CanvasUI_t)
  
  Declare ResetSheets(*Me.CanvasUI_t)
  Declare Open(*Me.CanvasUI_t,filename.s)
  Declare ChangeResolution(*Me.CanvasUI_t,resx.i,resy.i)
  Declare Save(*Me.CanvasUI_t,filename.s)
  Declare SaveMinitel(*Me.CanvasUI_t,filename.s,head.s)
  Declare UpdateData(*Me.CanvasUI_t,mx.i,my.i,w.i,h.i,c.i)

  Declare SetActiveTool(*Me.CanvasUI_t, tool.i)
  Declare NewSheet(*Me.CanvasUI_t)
  Declare AddSheet(*Me.CanvasUI_t, *sheet.Sheet::Sheet_t)
  Declare DeleteSheet(*Me.CanvasUI_t, *sheet.Sheet::Sheet_t)
  Declare SetActiveSheet(*Me.CanvasUI_t, index.i)
  
  ; -------------------------------------------------------------------
  ;   VIRTUAL TABLE
  ; -------------------------------------------------------------------
  DataSection
    CanvasUIVT:
    Data.i @Delete()
    Data.i @Resize()
    Data.i @Draw()
    Data.i UI::@DrawPickImage()
    Data.i UI::@Pick()
    Data.i @OnEvent()
  EndDataSection
  
EndDeclareModule

; ==================================================================
;   CANVAS UI MODULE IMPLEMENTATION
; ==================================================================
Module CanvasUI
  UseModule Globals
  ; --------------------------------------------------------------------
  ;   CONSTRUCTOR
  ; --------------------------------------------------------------------
  Procedure New(*parent.View::View_t,name.s="CanvasUI")
    *Me.CanvasUI_t = AllocateMemory(SizeOf(CanvasUI_t))
    Object::INI(CanvasUI)
    Protected l.l
    *Me\resx = *parent\width
    *Me\resy = *parent\height
    *Me\pixelratio = *parent\height / *parent\width
    *Me\secondary = RGBA(120,12,66,255)
    *Me\container = ContainerGadget(#PB_Any, x, y, *parent\width, *parent\height, #PB_Container_BorderLess)
    *Me\gadgetID = CanvasGadget(#PB_Any,0,0,*parent\width, *parent\height,#PB_Canvas_Keyboard)
    *Me\zoom = 100
    *Me\imageID = CreateImage(#PB_Any,*parent\width,*parent\height,32)
    *Me\tool = Tool::New(Tool::#TOOL_SELECT, *Me\gadgetID)
    *Me\on_content_change = Object::NewSignal(*Me, "OnContentChange")
    *Me\on_selection_change = Object::NewSignal(*Me, "OnSelectionChange")
    CloseGadgetList()
    UpdateZoom(*Me,0)
    ResetSheets(*Me)
    ClearDatas(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; --------------------------------------------------------------------
  ;   DESTRUCTOR
  ; --------------------------------------------------------------------
  Procedure Delete(*Me.CanvasUI_t)
    FreeGadget(*Me\gadgetID)
    FreeImage(*Me\imageID)
    FreeGadget(*Me\container)
    Object::TERM(CanvasUI)
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   SET ACTIVE TOOL
  ; ---------------------------------------------------------
  Procedure SetActiveTool(*Me.CanvasUI_t, tool.i)
    Tool::Change(*Me\tool, tool)
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   NEW LAYER
  ; ---------------------------------------------------------
  Procedure NewSheet(*Me.CanvasUI_t)
    Define *sheet.Sheet::Sheet_t = Sheet::New(GadgetWidth(*Me\gadgetID),GadgetHeight(*Me\gadgetID))
    AddElement(*Me\sheets())
    *Me\sheets() = *sheet
    *Me\sheet = *sheet
    ProcedureReturn *Me\sheet
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   ADD LAYER
  ; ---------------------------------------------------------
  Procedure AddSheet(*Me.CanvasUI_t, *sheet.Sheet::Sheet_t)
    AddElement(*Me\sheets())
    *Me\sheets() = *sheet
    *Me\sheet = *sheet
    ProcedureReturn *Me\sheet
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   DELETE LAYER
  ; ---------------------------------------------------------
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
  
  ; ---------------------------------------------------------
  ;   SET ACTIVE LAYER
  ; ---------------------------------------------------------
  Procedure SetActiveSheet(*Me.CanvasUI_t, index.i)
    If index >-1 And index < ListSize(*Me\sheets())
      SelectElement(*Me\sheets(), index)
      *Me\sheet = *Me\sheets()
      ;Tool::SetSheet(*Me\tool, *Me\sheet)
    EndIf
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   SET CURRENT COLOR
  ; ---------------------------------------------------------
  Procedure SetCurrentColor(*Me.CanvasUI_t,*color.Math::c4f32)
    *Me\color = RGBA(*color\r,*color\g,*color\b,*color\a)
    *Me\primary = RGBA(*color\r,*color\g,*color\b,*color\a)
  EndProcedure

  ; ---------------------------------------------------------
  ;   SET PIXEL RATIO
  ; ---------------------------------------------------------
  Procedure SetPixelRatio(*Me.CanvasUI_t,ratio.f)
    *Me\pixelratio = ratio
  EndProcedure

  ; ---------------------------------------------------------
  ;   UPDATE ZOOM
  ; ---------------------------------------------------------
  Procedure UpdateZoom(*Me.CanvasUI_t,delta.i, mx.f=0, my.f=0)

    Protected tmp = GadgetWidth(*Me\gadgetID)
    Globals::MINIMIZE(tmp,GadgetHeight(*Me\gadgetID))
;     Define offsetx.f = mx + *Me\offsetx
;     Define offsety.f = my + *Me\offsety
;     *Me\offsetx - offsetx
;     *Me\offsety - offsety
    *Me\zoom + delta
    Globals::CLAMPIZE(*Me\zoom,5,5000)
    
  EndProcedure

  ; ---------------------------------------------------------
  ;   DRAW GRID
  ; ---------------------------------------------------------
  Procedure DrawGrid(*Me.CanvasUI_t)

;     Protected c = RGBA(0,0,0,20)
;   
;     Protected mx.f = *Me\cwidth/*Me\resx
;     Protected my.f = *Me\cheight/*Me\resy * *Me\pixelratio
;     Protected x,y
;     
;     For x=0 To *Me\resx
;       Line(*Me\coffsetx+x*mx,*Me\coffsety,1,*Me\cheight * *Me\pixelratio,c)
;     Next x
;     For y=0 To *Me\resy
;       Line(*Me\coffsetx,*Me\coffsety+y*my,*Me\cwidth,1,c )
;     Next y
  EndProcedure

  ; ---------------------------------------------------------
  ;   DRAW 
  ; ---------------------------------------------------------
  Procedure Draw(*Me.CanvasUI_t)
    Debug "DRAW CANVAS UI..."
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    ResetCoordinates(#PB_Coordinate_User)
    AddPathBox(0,0,GadgetWidth(*Me\gadgetID), GadgetHeight(*Me\gadgetID))
    VectorSourceColor(UIColor::BACK)
    FillPath()
    
    ScaleCoordinates(*Me\zoom * 0.01, *Me\zoom * 0.01)
    TranslateCoordinates(*Me\offsetx, *Me\offsety)

    ForEach(*Me\sheets())
      Sheet::Draw(*Me\sheets())
    Next
    StopVectorDrawing()
  EndProcedure
  
  ; ---------------------------------------------------------
  ;   RESET LAYERS
  ; ---------------------------------------------------------
  Procedure ResetSheets(*Me.CanvasUI_t)
    If ListSize(*Me\sheets())
      ForEach *Me\sheets()
        Sheet::Delete(*Me\sheets())
      Next
      ClearList(*Me\sheets())
    EndIf
    
    ;CreateDefault Sheet
    *Me\sheet = Sheet::New(*Me\resx,*Me\resy,0)
    AddElement(*Me\sheets())
    *Me\sheets() = *Me\sheet
  
  EndProcedure


  ; --------------------------------------------------------------------
  ;   OPEN
  ; --------------------------------------------------------------------
  Procedure Open(*Me.CanvasUI_t,filename.s)
    
    If FileSize(filename) < 0
      ProcedureReturn
    EndIf
    
    If *Me\imageID <> 0 : FreeImage(*Me\imageID) :EndIf
    *Me\imageID  = LoadImage(#PB_Any,filename)
    *Me\resx = ImageWidth(*Me\imageID)
    *Me\resy = ImageHeight(*Me\imageID)
    UpdateZoom(*Me,0, 0, 0)
    
  EndProcedure

  ; --------------------------------------------------------------------
  ;   CHANGE OUTPUT RESOLUTION
  ; --------------------------------------------------------------------
  Procedure ChangeResolution(*Me.CanvasUI_t,resx.i,resy.i)
    *Me\resx = resx
    *Me\resy = resy
    ClearDatas(*Me)
    UpdateZoom(*Me,0, 0, 0) 
  EndProcedure

  ; --------------------------------------------------------------------
  ;   SAVE
  ; --------------------------------------------------------------------
  Procedure Save(*Me.CanvasUI_t,filename.s)
    Protected raw,aa
    Protected x,y,d
   
    ; Get AntiAliazed File
    raw = CopyImage(*Me\imageID,#PB_Any)
    
    ; Get AntiAliazed File
    aa = CopyImage(*Me\imageID,#PB_Any)
    ResizeImage(aa,*Me\resx*4,*Me\resy*4)
    ResizeImage(aa,*Me\resx,*Me\resy,#PB_Image_Smooth)
  
    ; Save Raw File
    Protected fName.s = ReplaceString(filename,".png","_raw.png")
    SaveImage(raw, fName,  #PB_ImagePlugin_PNG)
    FreeImage(raw)
    
    ; Save Antialiazed File
    SaveImage(aa, filename,  #PB_ImagePlugin_PNG)
    FreeImage(aa)
  
    
  EndProcedure
 
  ; --------------------------------------------------------------------
  ;   SAVE MINITEL
  ; --------------------------------------------------------------------
  Procedure SaveMinitel(*Me.CanvasUI_t,filename.s,head.s)
    Protected file.i = OpenFile(#PB_Any,filename)
    WriteStringN(file, "#ifndef "+head+"_H")
    WriteStringN(file, "#define "+head+"_H")
    WriteStringN(file, "#include "+Chr(34)+"Sprite.h"+Chr(34))
    WriteStringN(file, "#define "+head+"_WIDTH 40")
    WriteStringN(file, "define "+head+"_HEIGHT 24")
    WriteStringN(file, head+"_NB 1")
    
     Protected raw,aa
    Protected x,y,d
    
    WriteStringN (file, "byte "+head+"_BITS_1[] = {")
    
    StartDrawing(ImageOutput(raw))
    DrawingMode(#PB_2DDrawing_AllChannels)
    Protected l.l
    Protected counter 
    For x=0 To *Me\resx-1
      For y=0 To *Me\resy-1
        d = Point(x,y)
        ;Plot(mx+x,my+y,d)
        If counter = 20
          WriteStringN(file,Str(d))
        Else
          WriteString(file,Str(d))
        EndIf
        
      Next y
    Next x
    StopDrawing()
  
  EndProcedure

  ; ---------------------------------------------------------
  ;   UPDATE DATAS
  ; ---------------------------------------------------------
  Procedure UpdateData(*Me.CanvasUI_t,mx.i,my.i,w.i,h.i,c.i)
    If mx<0 Or mx> w Or my<0 Or my>h
      ProcedureReturn
    EndIf
    
    Protected l.l
    
    px.f = mx/w* *Me\resx
    py.f = my/h* *Me\resy
    x = Round(px,#PB_Round_Down)
    y = Round(py,#PB_Round_Down)
    StartDrawing(ImageOutput(*Me\imageID))
    DrawingMode(#PB_2DDrawing_AllChannels)
    If x>=0 And x<OutputWidth() And y>=0 And y<OutputHeight()
      Plot(x,y,c)
    EndIf
    
    StopDrawing()
    Draw(*Me)
  EndProcedure

  ; --------------------------------------------------------------------
  ;   CLEAR DATAS
  ; --------------------------------------------------------------------
  Procedure ClearDatas(*Me.CanvasUI_t)
    If IsImage(*Me\imageID) : FreeImage(*Me\imageID) : EndIf
    *Me\imageID = CreateImage(#PB_Any,*Me\resx,*Me\resy,32)
    ResetSheets(*Me)
    
    StartDrawing(ImageOutput(*Me\imageID))
    DrawingMode(#PB_2DDrawing_AllChannels)
    Box(0,0,ImageWidth(*Me\imageID),ImageHeight(*Me\imageID),RGBA(0,0,0,0))
    StopDrawing()
    Draw(*Me)
  EndProcedure
  
  ; --------------------------------------------------------------------
  ;   RESIZE
  ; --------------------------------------------------------------------
  Procedure Resize(*Me.CanvasUI_t, x.i, y.i, width.i, height.i)
    ResizeGadget(*Me\container, x, y, width, height)
    ResizeGadget(*Me\gadgetID, 0, 0, width, height)
    Draw(*Me)
  EndProcedure
  

  ; --------------------------------------------------------------------
  ;   ON EVENT
  ; --------------------------------------------------------------------
  Procedure OnEvent(*Me.CanvasUI_t)
    Protected mx,my,x.f,y.f,w,h,m,key
    
    mx = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
    my = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
    
    Define invzoom.f = 1 / (*Me\zoom *0.01)
    x = mx * invzoom
    y = my * invzoom
    
    w = GadgetWidth(*Me\gadgetID)
    h = GadgetHeight(*Me\gadgetID)
    Select EventType()
      
      Case #PB_EventType_MouseMove
        If Not *Me\tool\down
          StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
          ResetCoordinates(#PB_Coordinate_User)
          ScaleCoordinates(*Me\zoom*0.01, *Me\zoom * 0.01)
          TranslateCoordinates(*Me\offsetx, *Me\offsety)
          Sheet::Pick(*Me\sheets(), mx, my)
          StopVectorDrawing()
        Else
          modifiers = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
          If modifiers & #PB_Canvas_Alt
            SetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Hand)
            *Me\offsetx - (*Me\last_x - x) 
            *Me\offsety - (*Me\last_y - y) 
          Else
            
            Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety )
          EndIf
          
        EndIf
            
      Case #PB_EventType_KeyDown
        key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key)
        modifiers = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
         
        Select key
          Case #PB_Shortcut_Up
            Sheet::Shift(*Me\sheet,0,-1)
            Draw(*Me)
            
          Case #PB_Shortcut_Down
            Sheet::Shift(*Me\sheet,0,1)
            Draw(*Me)
            
          Case #PB_Shortcut_Left
            Sheet::Shift(*Me\sheet,-1,0)
            Draw(*Me)
            
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
        Protected delta =  GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_WheelDelta)*24
        UpdateZoom(*Me,delta, mx, my)
        
      Case #PB_EventType_LeftDoubleClick
        Tool::Change(*Me\tool, Tool::#TOOL_EDIT)
        If *Me\sheet\over
          Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety )
        EndIf
  
      Case #PB_EventType_LeftButtonDown
        
        If *Me\sheet\over
          Define needUpdate.b = #True
          If *Me\sheet\active And *Me\sheet\active = *Me\sheet\over
            needUpdate = #False
          EndIf
          
          *Me\sheet\active = *Me\sheet\over
          Selection::Clear(*Me\tool\selection)
          ;Selection::AddAtom(*Me\tool\selection, *Me\sheet\over)
          If needUpdate :  Signal::Trigger(*Me\on_selection_change, Signal::#SIGNAL_TYPE_PING) : EndIf
        EndIf
        Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety )
        Draw(*Me)  
        
      Case #PB_EventType_LeftButtonUp
        SetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default)
        Tool::OnEvent(*Me\tool, x - *Me\offsetx , y - *Me\offsety)
        Draw(*Me)
         
      Case #PB_EventType_RightButtonDown
        *Me\erase = #True
        *Me\color = RGBA(0,0,0,0)
        UpdateData(*Me,mx,my,w,h,*Me\color)
        
      Case #PB_EventType_RightButtonUp
        *Me\erase = #False
        *Me\color = *Me\primary
        
        
    EndSelect  
    *Me\last_x = x
    *Me\last_y = y
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 410
; FirstLine = 406
; Folding = ----
; EnableXP
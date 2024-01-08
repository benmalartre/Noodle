
; ================================================================
;   TOOL MODULE DECLARATION
; ================================================================
DeclareModule Tool
  ;-------------------------------------------------------------------
  ; Globals
  ;-------------------------------------------------------------------
  Enumeration
    #TOOL_SELECT
    #TOOL_LINE
    #TOOL_BEZIER
    #TOOL_ARC
    #TOOL_BOX
    #TOOL_CIRCLE
    #TOOL_IMAGE
    #TOOL_TEXT
    #TOOL_EDIT
    #TOOL_TRANSLATE
    #TOOL_ROTATE
  EndEnumeration
    
  Global Dim ToolNames.s(11)
  ToolNames(0) = "Select"
  ToolNames(1) = "Line"
  ToolNames(2) = "Bezier"
  ToolNames(3) = "Arc"
  ToolNames(4) = "Box"
  ToolNames(5) = "Circle"
  ToolNames(6) = "Image"
  ToolNames(7) = "Text"
  ToolNames(8) = "Edit"
  ToolNames(9) = "Translate"
  ToolNames(10) = "Rotate"
  
  Global ACTIVE_TOOL.i = #TOOL_SELECT
  Global STROKE_WIDTH.f = 6.0
  Global STROKED.b = #True
  Global FILLED.b = #True
  
  ;-------------------------------------------------------------------
  ; Structure
  ;-------------------------------------------------------------------
  Structure Tool_t Extends Object::Object_t
    type.i
    last.i
    start_x.i
    start_y.i
    delta_x.f
    delta_y.f
    down.b
    gadgetID.i
    *selection.Selection::Selection_t
    *item.Vector::Item_t
    *atom.Vector::Atom_t
    *layer.Layer::Layer_t
    *on_selection.Signal::Signal_t
  EndStructure
  
  Declare New(type.i, gadgetID.i)
  Declare Delete(*Me.Tool_t)
  Declare Change(*Me.Tool_t, tool.i)
  Declare OnEvent(*Me.Tool_t,mx.f,my.f)
  Declare.s GetToolName(tool.i)
  Declare SetObject(*Me.Tool_t, *item.Vector::Item_t)
  Declare SetLayer(*Me.Tool_t, *layer.Layer::Layer_t)
  DataSection
    ToolVT:
  EndDataSection
  
EndDeclareModule

Module Tool
  ;-------------------------------------------------------------------
  ; Constructor
  ;-------------------------------------------------------------------
  Procedure New(type.i, gadgetID.i)
    Protected *Me.Tool_t = AllocateStructure(Tool_t)
    Object::INI(Tool)
    *Me\gadgetID = gadgetID
    *Me\type = type
    *Me\selection = Selection::New()
    ProcedureReturn *Me
  EndProcedure
  
  ;-------------------------------------------------------------------
  ; Destructor
  ;-------------------------------------------------------------------
  Procedure Delete(*Me.Tool_t)
    FreeGadget(*Me\gadgetID)
    Selection::Delete(*Me\selection)
    Object::TERM(Tool)
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   GET TOOL NAME
  ; -------------------------------------------------------------------
  Procedure.s GetToolName(tool.i)
    ProcedureReturn ToolNames(tool)
  EndProcedure
  
  
  ;-------------------------------------------------------------------
  ; Change
  ;-------------------------------------------------------------------
  Procedure Change(*Me.Tool_t, tool.i)
    *Me\type = tool
    Select *Me\type
      
    EndSelect
    
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   SET OBJECT
  ; -------------------------------------------------------------------
  Procedure SetObject(*Me.Tool_t, *item.Vector::Item_t)
    *Me\item = *item
    
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   SET LAYER
  ; -------------------------------------------------------------------
  Procedure SetLayer(*Me.Tool_t, *layer.Layer::Layer_t)
    *Me\layer = *layer
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   ADD IMAGE
  ; -------------------------------------------------------------------
  Procedure AddImage(*Me.Tool_t, x.f, y.f)
    Define *img.Vector::Image_t = Vector::NewItem(Vector::#ATOM_IMAGE)
    *img\T\translate\x = x
    *img\T\translate\y = y
    *img\filename = "image.jpg"
    *img\img = LoadImage(#PB_Any, *img\filename)
    If IsImage(*img\img)
      *img\width = ImageWidth(*img\img)
      *img\height = ImageHeight(*img\img)
    EndIf
    
    *img\stroked = #False
    *img\filled = #True
    
    *Me\type = #TOOL_SELECT
    *Me\item = *img
    Vector::SETSTATE(*Me\item, Vector::#STATE_ACTIVE)
    ;Layer::AddItem(*Me\layer, *img)
    ProcedureReturn *img
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   ADD TEXT
  ; -------------------------------------------------------------------
  Procedure AddText(*Me.Tool_t, x.f, y.f)
    Define *txt.Vector::Text_t = Vector::NewItem(Vector::#ATOM_TEXT)
    *txt\T\translate\x = x
    *txt\T\translate\y = y
    *txt\text = "text"
    *txt\font = 0
    *txt\font_size = 12
    *txt\fill_color = RGBA(0,0,0,255)
    *txt\stroked = #False
    *txt\filled = #True
    
    *Me\type = #TOOL_SELECT
    *Me\item = *txt
    Vector::SETSTATE(*Me\item, Vector::#STATE_ACTIVE)
    ;Layer::AddItem(*Me\layer, *txt)
    ProcedureReturn *txt
  EndProcedure
  
  Procedure AddCircle(*Me.Tool_t, x.f, y.f)
    Define *circle.Vector::Circle_t = Vector::NewItem(Vector::#ATOM_CIRCLE, Vector::#STROKE_DEFAULT, #PB_Path_Default, 2, RGBA(255,0,120,255), #True, UIColor::RANDOMIZED)
    *circle\T\translate\x = x + 1
    *circle\T\translate\y = y + 1
    *circle\radius = 1
    *circle\stroked = #True
    *circle\fill_color = UIColor::FILL
    *circle\stroke_color = UIColor::STROKE
    *circle\stroke_width = Tool::STROKE_WIDTH
    *circle\filled = #True
    *Me\type = #TOOL_EDIT
    *Me\item = *circle
    ;Selection::AddAtom(*Me\selection, *circle)
    Vector::SETSTATE(*Me\item, Vector::#STATE_ACTIVE)
    
    ;Layer::AddItem(*Me\layer, *circle)
    ProcedureReturn *circle
  EndProcedure
          
  
  ; -------------------------------------------------------------------
  ;   ON EVENT
  ; -------------------------------------------------------------------
  Procedure OnEvent(*Me.Tool_t, x.f, y.f)

    Define *active.Vector::Item_t = *Me\item
    Define *atom.Vector::Atom_t = #Null
    If *active : *atom = *active\active : EndIf
    
    Define color = RGBA(120,60,32,255)
    
    Select EventType()
      Case #PB_EventType_LeftButtonDown
        *Me\down = #True
        *Me\start_x = x
        *Me\start_y = y
        *Me\last = *Me\type

        Select *Me\type
          Case Tool::#TOOL_SELECT
            If *Me\item
              Vector::SETSTATE(*Me\item, Vector::#STATE_ACTIVE)
              *Me\type = #TOOL_TRANSLATE
            EndIf
            
          Case Tool::#TOOL_Image
            AddImage(*Me, x, y)
            
          Case Tool::#TOOL_TEXT
            AddText(*Me, x, y)
            
          Case Tool::#TOOL_CIRCLE
            AddCircle(*Me, x, y)
            
          Case Tool::#TOOL_BOX
            Define *box.Vector::Box_t = Vector::NewItem(Vector::#ATOM_BOX, Vector::#STROKE_DEFAULT, #PB_Path_Default, 2, color, #True, UIColor::RANDOMIZED)
            *box\halfsize\x = 1
            *box\halfsize\y = 1
            *box\T\translate\x = x + 1
            *box\T\translate\y = y + 1
            
            *box\fill_color = UIColor::RANDOMIZED
            *box\stroked = #True
            *box\stroke_color = color
            *box\stroke_width = 2
            *box\filled = #True
            *Me\type = #TOOL_EDIT
            *Me\item = *box
;             Selection::AddAtom(*Me\selection, *box)
;             Layer::AddItem(*Me\layer, *box)
            
          Case Tool::#TOOL_LINE
   
            Define *line.Vector::Line_t = Vector::NewItem(Vector::#ATOM_LINE, Vector::#STROKE_DEFAULT, #PB_Path_Default, 2, color, #True, UIColor::RANDOMIZED)
            *line\fill_color = UIColor::RANDOMIZED
            *line\stroked = #True
            *line\stroke_color = color
            *line\stroke_width = 2
            *line\filled = #True
            *Me\item = *line
            *Me\last = Tool::#TOOL_EDIT
            Vector::InsertPoint(*line, x, y)
;             Layer::AddItem(*Me\layer, *line)
            
            
          Case Tool::#TOOL_BEZIER
   
            Define *bezier.Vector::Bezier_t = Vector::NewItem(Vector::#ATOM_BEZIER, Vector::#STROKE_DEFAULT, #PB_Path_Default, 2, color, #True, UIColor::RANDOMIZED)
            *bezier\fill_color = UIColor::RANDOMIZED
            *bezier\stroked = #True
            *bezier\stroke_color = color
            *bezier\stroke_width = 2
            *bezier\filled = #True
            *Me\item = *bezier
            *Me\last = Tool::#TOOL_EDIT
            Vector::InsertPoint(*bezier, x, y)
;             Layer::AddItem(*Me\layer, *bezier)
            
            
          Case Tool::#TOOL_EDIT

            If *active 
              Select *active\type
                Case Vector::#ATOM_LINE
                  Define *line.Vector::Line_t = *active
                  If *line\active
;                     *line\active\x = x
;                     *line\active\y = y
                  Else
                    Vector::InsertPoint(*line, x, y)
                  EndIf
                  
                Case Vector::#ATOM_BEZIER
                  Define *bezier.Vector::Bezier_t = *active
                  If *bezier\active
                    
                  Else
                    Vector::InsertPoint(*bezier, x, y)
                  EndIf
              EndSelect    
            EndIf
  
        EndSelect
                 
      Case #PB_EventType_LeftButtonUp
        *Me\down = #False
        *Me\type = *Me\last
        
      Case #PB_EventType_LeftDoubleClick
        If *active : *atom = *active\active : EndIf
        If *atom
          Select *atom\type
            Case Vector::#ATOM_TEXT
              Define *txt.Vector::Text_t = *atom
              Define newText.S = InputRequester("CONI", "enter new text:", *txt\text)
              *txt\text = newText
              
            Case Vector::#ATOM_LINE
              *Me\type = #TOOL_EDIT
              Vector::SETSTATE(*atom, Vector::#STATE_EDIT)
          EndSelect
        EndIf
                
      Case #PB_EventType_MouseMove
        If Not MapSize(*Me\selection\items()) : ProcedureReturn : EndIf
        *active = *Me\item
        If *Me\down
          If *active : *atom = *active\active : EndIf
          
          If MapSize(*Me\selection\items())
            Select *Me\type
              Case #TOOL_EDIT
                Select *active\type
                  Case Vector::#ATOM_BOX
                    Define *box.Vector::Box_t = *active
                    Define deltax.f = (x-*Me\start_x) * 0.5
                    Define deltay.f = (y-*Me\start_y) * 0.5
                    *box\T\translate\x = *Me\start_x + deltax
                    *box\T\translate\y = *Me\start_y + deltay
                    *box\halfsize\x = deltax
                    *box\halfsize\y = deltay
                    
                  Case Vector::#ATOM_CIRCLE
                    Define *circle.Vector::Circle_t = *active
                    Define deltax.f = (x-*Me\start_x) * 0.5
                    Define deltay.f = (y-*Me\start_y) * 0.5
                    *circle\T\translate\x = *Me\start_x + deltax
                    *circle\T\translate\y = *Me\start_y + deltay
                    *circle\radius = (deltax + deltay) * 0.5
                    
                EndSelect
                
              Case #TOOL_ROTATE
                Define deltax.f = (x - *Me\start_x)
                Define deltay.f = (y - *Me\start_y)
                
                ForEach *Me\selection\items()
                  Vector::Rotate(*Me\selection\items(), 12)
                Next
            
                *Me\start_x = x
                *Me\start_y = y      
                
              Case #TOOL_TRANSLATE
                Define deltax.f = (x - *Me\start_x)
                Define deltay.f = (y - *Me\start_y)
                StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
                ;ScaleCoordinates(*Me\zoom * 0.01, *Me\zoom * 0.01)
                ;TranslateCoordinates(*Me\offsetx, *Me\offsety)
                ForEach *Me\selection\items()
                  Vector::Translate(*Me\selection\items(), deltax, deltay)
                Next
                StopVectorDrawing()
                *Me\start_x = x
                *Me\start_y = y      
            EndSelect
          EndIf
          
        EndIf  
    EndSelect
    
  EndProcedure
EndModule


  
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 236
; FirstLine = 291
; Folding = ---
; EnableXP
; EnableUnicode
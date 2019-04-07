
XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "Button.pbi"

; ==============================================================================
;  CONTROL ICON MODULE DECLARATION
; ==============================================================================
DeclareModule ControlIcon
  Macro IconType
    b
  EndMacro
  
  Enumeration
    #Icon_Custom = -1
    #Icon_Default = 0
    #Icon_Close
    #Icon_First
    #Icon_Previous
    #Icon_Back
    #Icon_Stop
    #Icon_Play
    #Icon_Next
    #Icon_Last
    #Icon_Loop
    
    #Icon_Max
  EndEnumeration
  
  Global Dim s_gui_controls_dark_icon_img.i(#Icon_Max)
  Global Dim s_gui_controls_light_icon_img.i(#Icon_Max)
  Global Dim s_gui_controls_icon_img.i(#Icon_Max)
  
  Global Dim s_gui_controls_icon_name.s(#Icon_Max)
  s_gui_controls_icon_name(0) = "default"
  s_gui_controls_icon_name(1) = "close"
  s_gui_controls_icon_name(2) = "first"
  s_gui_controls_icon_name(3) = "previous"
  s_gui_controls_icon_name(4) = "back"
  s_gui_controls_icon_name(5) = "stop"
  s_gui_controls_icon_name(6) = "play"
  s_gui_controls_icon_name(7) = "next"
  s_gui_controls_icon_name(8) = "last"
  s_gui_controls_icon_name(9) = "loop"

  
  ; ----------------------------------------------------------------------------
  ; Dark Icon Colors
  ;-----------------------------------------------------------------------------
  Global RAA_COLOR_DARK_ICON_RED             = 200
  Global RAA_COLOR_DARK_ICON_GREEN           = 210
  Global RAA_COLOR_DARK_ICON_BLUE            = 200
  
  ; ----------------------------------------------------------------------------
  ; Light Icon Colors
  ;-----------------------------------------------------------------------------
  Global RAA_COLOR_LIGHT_ICON_RED             = 40
  Global RAA_COLOR_LIGHT_ICON_GREEN           = 50
  Global RAA_COLOR_LIGHT_ICON_BLUE            = 60

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlIcon_t )
  ; ----------------------------------------------------------------------------
  ;{
  Structure ControlIcon_t Extends Control::Control_t
    icon.i
    label.s
    value.i
    over.i
    down.i
    *on_click.Signal::Signal_t
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlicon Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares
  ; ----------------------------------------------------------------------------
  Declare New( gadgetID.i ,name.s,icon.IconType = #Icon_Default, options.i = #False, value.i=#False , x.i = 0, y.i = 0, width.i = 32, height.i = 32 )
  Declare Delete(*Me.ControlIcon_t)
  Declare OnEvent( *Me.ControlIcon_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  Declare.b Init()
  Declare.b Term()
  Declare SetTheme(theme.i)

  ; ============================================================================
  ;  VTABLE ( CObject + CControl + ControlIcon )
  ; ============================================================================
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Macro ICON_IMG_FOLDER
        "..\..\rsc\skins\grey\control_icon4\"
      EndMacro
    CompilerDefault
      Macro ICON_IMG_FOLDER
        "../../rsc/skins/grey/control_icon4/"
      EndMacro
  CompilerEndSelect
  
  DataSection
    ControlIconVT:
    Data.i @OnEvent()            ; mandatory override
    Data.i @Delete()             ; mandatory override
   
    ; Images
    VIControlIcon_Default:  
    IncludeBinary ICON_IMG_FOLDER+"default.png"
    VIControlIcon_Close:    
    IncludeBinary ICON_IMG_FOLDER+"close.png"
    VIControlIcon_Play:     
    IncludeBinary ICON_IMG_FOLDER+"play.png"
    VIControlIcon_Stop:     
    IncludeBinary ICON_IMG_FOLDER+"stop.png"
    VIControlIcon_Back:     
    IncludeBinary ICON_IMG_FOLDER+"back.png"
    VIControlIcon_First:    
    IncludeBinary ICON_IMG_FOLDER+"first.png"
    VIControlIcon_Last:     
    IncludeBinary ICON_IMG_FOLDER+"last.png"
    VIControlIcon_Previous: 
    IncludeBinary ICON_IMG_FOLDER+"previous.png"
    VIControlIcon_Next:     
    IncludeBinary ICON_IMG_FOLDER+"next.png"
    VIControlIcon_Loop:     
    IncludeBinary ICON_IMG_FOLDER+"loop.png"
    
    
  EndDataSection

  
  Global CLASS.Class::Class_t
EndDeclareModule


; ==============================================================================
;  CONTROL ICON MODULE IMPLEMENTATION 
; ==============================================================================
Module ControlIcon
  
  ;{
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ToDo : implement Disable Mode
  ; ----------------------------------------------------------------------------
  ;{
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure hlpDraw( *Me.ControlIcon_t, xoff.i = 0, yoff.i = 0 )
  
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Reset Clipping ]-----------------------------------------------------

    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable 
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\value < 0
        Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, 2)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, 2)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
      EndIf
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\down Or ( *Me\value < 0 )
        Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, 2)
        VectorSourceColor(UIColor::COLOR_MAIN_BG)
        FillPath()
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, 2)
        VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
        FillPath()
      EndIf
    ; ---[ Normal State ]-------------------------------------------------------
    Else
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\value < 0 Or *Me\down
        Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, 2)
        VectorSourceColor(UIColor::COLOR_MAIN_BG)
        FillPath()
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, 2)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
      EndIf
    EndIf
      
    ; ---[ Draw Icon ]----------------------------------------------------------
    ;DrawingMode(#PB_2DDrawing_AllChannels)
    
    Protected offx,offy
    offx = (*Me\sizX-ImageWidth(s_gui_controls_icon_img(*Me\icon)))/2
    offy = (*Me\sizY-ImageHeight(s_gui_controls_icon_img(*Me\icon)))/2
    MovePathCursor(xoff+offx, yoff+offy)
    DrawVectorImage(ImageID(s_gui_controls_icon_img(*Me\icon)))
    ;DrawImage(ImageID(s_gui_controls_icon_img(*Me\icon)),xoff,yoff,*Me\sizX,*Me\sizY)
 
  EndProcedure
  ;}

  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlIcon_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
  
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Draw
      ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        ; ...[ Draw Control ]...................................................
        hlpDraw( *Me, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      CompilerIf #PB_Compiler_Version < 560
        Case Control::#PB_EventType_Resize
      CompilerElse
        Case #PB_EventType_Resize
      CompilerEndIf
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        ; ...[ Update Topology ]................................................
        If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
        If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
        If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
        If #PB_Ignore <> *ev_data\height : *Me\sizY = *ev_data\height : EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  MouseEnter
      ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseEnter
        If *Me\visible And *Me\enable
          *Me\over = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseLeave
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseMove
      ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseMove
        If *Me\visible And *Me\enable
          If *Me\down
            If ( *ev_data\x < 0 ) Or ( *ev_data\x >= *Me\sizX ) Or ( *ev_data\y < 0 ) Or ( *ev_data\y >= *Me\sizY )
              If *Me\over : *Me\over = #False : Control::Invalidate(*Me) : EndIf
            Else
              If Not *Me\over : *Me\over = #True : Control::Invalidate(*Me) : EndIf
            EndIf
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonDown
        If *Me\visible And *Me\enable
          *Me\down = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonUp
      ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      If *Me\visible And *Me\enable
          *Me\down = #False
          If *Me\over And ( *Me\options & #PB_Button_Toggle )
            *Me\value*-1
          EndIf
          Control::Invalidate(*Me)
          Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OVER : "+Str(*Me\over)
          If *Me\over
            Signal::Trigger(*Me\on_click,Signal::#SIGNAL_TYPE_PING)
            ; TODO : >>> TRIGGER ACTION <<<
;             Debug ">> Trigger ["+ *Me\label +"]/["+ Str(*Me\value) +"]"
;             Protected *slot.CSlot = *Me\sig_onchanged
;             *slot\Trigger(#RAA_SIGNAL_TYPE_PING, #Null)
  
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  Enable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Enable
        If *Me\visible And Not *Me\enable
          *Me\enable = #True
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
  
      ; ------------------------------------------------------------------------
      ;  Disable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Disable
        If *Me\visible And *Me\enable
          *Me\enable = #False
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
  
    EndSelect
    
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn( #False )
    
  EndProcedure
  ;}
  
 
  
  ; ============================================================================
  ;  IMPLEMENTATION ( ControlIcon )
  ; ============================================================================
  ;{
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlIcon_t )
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    ClearStructure(*Me,ControlIcon_t)
    FreeMemory( *Me )
    
  EndProcedure

  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New( gadgetID.i ,name.s,icon.IconType = #Icon_Default, options.i = #False, value.i=#False , x.i = 0, y.i = 0, width.i = 32, height.i = 32 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlIcon_t = AllocateMemory( SizeOf(ControlIcon_t) )
    
;     *Me\VT = ?ControlIconVT
;     *Me\classname = "CONTROLICON"
    Object::INI(ControlIcon)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type       = #PB_GadgetType_Button
    *Me\name       = name
    *Me\gadgetID   = gadgetID
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\options    = options
    *Me\visible    = #True
    *Me\enable     = #True
    *Me\value      = 1
    *Me\label      = name
    *Me\icon       = icon 
    If value          : *Me\value = -1    : Else : *Me\value = 1    : EndIf
    
    ; ---[ Signals ]------------------------------------------------------------
    *Me\on_click = Object::NewSignal(*Me, "OnClick")
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

  
  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  ; ----------------------------------------------------------------------------
  ;  hlpSetTheme
  ; ----------------------------------------------------------------------------
  Procedure SetTheme( theme.i )
    ControlButton::SetTheme( theme )
    Protected i
    For i=0 To #Icon_Max - 1
      Select theme
        ;---[ Dark ]-------------------------------------------------------
        Case Globals::#GUI_THEME_DARK
          s_gui_controls_icon_img(i) = s_gui_controls_dark_icon_img(i)
        ;---[ Light ]-------------------------------------------------------
        Case Globals::#GUI_THEME_LIGHT
          s_gui_controls_icon_img(i) = s_gui_controls_light_icon_img(i)
          
      EndSelect
    Next i
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; We extract alpha channel from input image
  ; We store it in a new image
  ;----------------------------------------------------------------------------
  Procedure GetImage( label.i ,icon.i, resx.i=-1,resy.i=-1)
    ; Catch Image in Memory
    Protected src.i = CatchImage(#PB_Any,label)
    
    ; Create IconData Structure
  
  ;   Protected x, y, pt
  ;   
  ;   If resx>0 And resy>0
  ;     ResizeImage(src,resx,resy,#PB_Image_Raw)
  ;   Else
  ;     Protected rx = ImageWidth(src)
  ;     Protected ry = ImageHeight(src)
  ;     resx = rx
  ;     resy = ry
  ;   EndIf
  ;   
  ;   ; Create new images
  ;   Protected light = CreateImage(#PB_Any,resx,resy,32)
  ;   Protected dark = CreateImage(#PB_Any,resx,resy,32)
  ;   
  ;   Protected size_p.i
  ;   Protected *dat = AllocateMemory(resx*resy*SizeOf(size_p)*4)
  ;   
  ;   ;Get Source Alpha in Memory
  ;   StartDrawing(ImageOutput(src))
  ;   DrawingMode(#PB_2DDrawDrawing_AllChannels)
  ;   For x = 0 To resx -1
  ;     For y = 0 To resy - 1
  ;       PokeI(*dat + (x + resx * y),Red(Point(x,y)))
  ;       PokeI(*dat + (x + resx * y+size_p),Green(Point(x,y)))
  ;       PokeI(*dat + (x + resx * y+2*size_p),Blue(Point(x,y)))
  ;       PokeI(*dat + (x + resx * y+3*size_p),Alpha(Point(x,y)))
  ;     Next y
  ;   Next x
  ;   StopDrawing()
  ;   
  ;   ;Draw Dark Icon
  ;   StartDrawing(ImageOutput(dark))
  ;   DrawingMode(#PB_2DDrawing_AllChannels)
  ;   For x=0 To resx-1
  ;     For y = 0 To resy-1
  ;       Plot(x,y,RGBA(RAA_COLOR_DARK_ICON_RED,RAA_COLOR_DARK_ICON_GREEN,RAA_COLOR_DARK_ICON_BLUE,PeekI(*dat + (x + resx * y))))
  ;    Next y
  ;   Next x
  ;   StopDrawing()
  ;   
  ;   ;Draw Light Icon
  ;   StartDrawing(ImageOutput(light))
  ;   DrawingMode(#PB_2DDrawing_AllChannels)
  ;   For x=0 To resx-1
  ;    For y = 0 To resy-1
  ;        Plot(x,y,RGBA(RAA_COLOR_LIGHT_ICON_RED,RAA_COLOR_LIGHT_ICON_GREEN,RAA_COLOR_LIGHT_ICON_BLUE,PeekI(*dat + (x + resx * y))))
  ;    Next y
  ;   Next x
  ;   StopDrawing()
  ;   
  ;   ; Free Memory
  ;   FreeMemory(*dat)
  
    ; Add Images to Global Array
    s_gui_controls_dark_icon_img(icon) = src
    s_gui_controls_light_icon_img(icon) = src
    
  EndProcedure
  

  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure.b Init( )

    ; ---[ Init Once ]----------------------------------------------------------
    ; ---[ Create Icons Images ]------------------------------------------------
    GetImage(?VIControlIcon_Default  ,#Icon_Default  , 32,32)
    GetImage(?VIControlIcon_Close    ,#Icon_Close    , 32,32)
    GetImage(?VIControlIcon_First    ,#Icon_First    , 32,32)
    GetImage(?VIControlIcon_Previous ,#Icon_Previous , 32,32)
    GetImage(?VIControlIcon_Back     ,#Icon_Back     , 32,32)
    GetImage(?VIControlIcon_Stop     ,#Icon_Stop     , 32,32)
    GetImage(?VIControlIcon_Play     ,#Icon_Play     , 32,32)
    GetImage(?VIControlIcon_Next     ,#Icon_Next     , 32,32)
    GetImage(?VIControlIcon_Last     ,#Icon_Last     , 32,32)
    GetImage(?VIControlIcon_Loop     ,#Icon_Loop     , 32,32)

    
    ; ---[ Set Initial Theme ]--------------------------------------------------
    SetTheme( Globals::#GUI_THEME_LIGHT )
    

    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  Term
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )
  ;CHECK_INIT  

    
    ; ---[ Term Once ]----------------------------------------------------------
    ; ...[ Delete Icons Images ]................................................
    ;{
    Protected i
    For i=0 To #Icon_Max -1
      FreeImage(s_gui_controls_dark_icon_img(i))
      FreeImage(s_gui_controls_light_icon_img(i))
    Next i
    ;}
    
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlIcon )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 180
; FirstLine = 176
; Folding = ----
; EnableXP
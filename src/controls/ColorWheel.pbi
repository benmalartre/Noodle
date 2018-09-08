; ============================================================================
;  raafal.gui.controls.colorwheel.pbi
; ............................................................................
;  GUI Color WHeel Control
; ============================================================================
;  2012/09/05 | Guy Rabiller
;  - creation
;  2014/02/08 | Ben Malartre
;  - implementation of the original test file
; ============================================================================


; ============================================================================
;  GLOBALS
; ============================================================================
;{

Enumeration
  #RAA_COLORWHEEL_MODE_DISK = 0
  #RAA_COLORWHEEL_MODE_CUBE
  #RAA_COLORWHEEL_MODE_EYE
  
  #RAA_COLORWHEEL_MODE_MAX
EndEnumeration

; ----------------------------------------------------------------------------
;  Light
; ----------------------------------------------------------------------------
;{
Global s_gui_controls_light_colorwheel_dot .i
Global s_gui_controls_light_colorwheel_arrow.i
;}
; ----------------------------------------------------------------------------
;  Dark
; ----------------------------------------------------------------------------
;{
Global s_gui_controls_dark_colorwheel_dot .i
Global s_gui_controls_dark_colorwheel_arrow.i
;}
; ----------------------------------------------------------------------------
;  Current
; ----------------------------------------------------------------------------
;{
Global s_gui_controls_colorwheel_dot .i
Global s_gui_controls_colorwheel_arrow.i
;}
Global wheel_xhsiz.d
Global wheel_yhsiz.d
Global wheel_cx_offset.d
Global wheel_cy_offset.d
Global wheel_wradius.d
;}

; ============================================================================
;  CLASS ( CControlColorWheel )
; ============================================================================
;{
; ----------------------------------------------------------------------------
;  Class ( CObject + CControl + CControlColorWheel )
; ----------------------------------------------------------------------------
;{
Interface CControlColorWheel Extends CControl
  SetValue   ( r.f,g.f,b.f,a.f )
  GetValue.i ( *color.c4f32    )
EndInterface
;}
; ----------------------------------------------------------------------------
;  Object ( CControlColorWheel_t )
; ----------------------------------------------------------------------------
;{
Structure CControlColorWheel_t Extends CControl_t
  imageID.i
  hue.d
  val.d
  sat.d
  
  cx_offset.d
  cy_offset.d
  
  jxoff.i
  jyoff.i
  jaoff.d
  
  xhsiz.d
  yhsiz.d
  
  wradius.d
  
  
  key_down.b
  mode.i
  hue_only.b
  val_only.b
  sat_only.b
  
  color.c4f32
EndStructure
;}
;}


; ============================================================================
;  IMPLEMENTATION ( Helpers )
; ============================================================================
;{
; ------------------------------------------------------------------------
;  HSV2RGB
; ------------------------------------------------------------------------
Procedure.i HSV2RGB( c_hue.d, c_sat.d, c_val.d )
  
  Protected c_rgb = 0
  
  If c_sat < 0.00000001
    ; it's a gray-tone
    c_rgb = RGB( c_val*$FF, c_val*$FF, c_val*$FF )
  Else
    
    Protected h.d = 6.0*c_hue
    Protected i   = Round( h, #PB_Round_Down )
    Protected f.d = h - i
    Protected p.d = c_val*(1.0-c_sat)
    Protected q.d = c_val*(1.0-c_sat*f)
    Protected t.d = c_val*(1.0-c_sat*(1.0-f))
   
    Select i
      Case 0 : c_rgb = RGB( c_val*$FF, t*$FF, p*$FF )
      Case 1 : c_rgb = RGB( q*$FF, c_val*$FF, p*$FF )
      Case 2 : c_rgb = RGB( p*$FF, c_val*$FF, t*$FF )
      Case 3 : c_rgb = RGB( p*$FF, q*$FF, c_val*$FF )
      Case 4 : c_rgb = RGB( t*$FF, p*$FF, c_val*$FF )
      Case 5 : c_rgb = RGB( c_val*$FF, p*$FF, q*$FF )
    EndSelect
  EndIf
  
  ProcedureReturn c_rgb
    
EndProcedure
; ------------------------------------------------------------------------
;  Wheel Cube Callback
; ------------------------------------------------------------------------
Procedure WheelCubeCallback( x, y, cs, ct )
  
  Protected xo.d = x - wheel_xhsiz - wheel_cx_offset
  Protected yo.d = y - wheel_yhsiz - wheel_cy_offset
  
  Protected ra.d  = Sqr( xo*xo + yo*yo )/(wheel_xhsiz*wheel_wradius)
  
  Protected va.d = Alpha(cs)/255.0
  
  If ra > 1.0 : ra = 1.0 : EndIf
  If ra < 0.0 : ra = 0.0 : EndIf
  
  Protected rn.d  = $FF*( 1.0 - ra )
  
  If ra > 0.99
    
    Protected df.d = ( ra - 0.99 )/( 1.0 - 0.99 )
    Protected dn.d = 1.0 - df
    
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75*dn + $48*df, (Green(cs)*ra + rn)*0.75*dn + $48*df, (Blue(cs)*ra + rn)*0.75*dn + $48*df )
    
  ElseIf ra > 0.8 And ra < 0.81
    
    df = ( ra - 0.8 )/( 0.81 - 0.8 )
    dn = 1.0 - df
    
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75*df + $48*dn, (Green(cs)*ra + rn)*0.75*df + $48*dn, (Blue(cs)*ra + rn)*0.75*df + $48*dn )
    
  ElseIf ra > 0.8
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75, (Green(cs)*ra + rn)*0.75, (Blue(cs)*ra + rn)*0.75 )
  Else
    ProcedureReturn RGB( $48, $48, $48 )
  EndIf
  
EndProcedure

; ------------------------------------------------------------------------
;  Wheel Eye Callback
; ------------------------------------------------------------------------
Procedure WheelEyeCallback( x, y, cs, ct )
  
  Protected xo.d = x - wheel_xhsiz - wheel_cx_offset
  Protected yo.d = y - wheel_yhsiz - wheel_cy_offset
  
  Protected ra.d  = Sqr( xo*xo + yo*yo )/(wheel_xhsiz*wheel_wradius)
  
  Protected va.d = Alpha(cs)/255.0
  
  If ra > 1.0 : ra = 1.0 : EndIf
  If ra < 0.0 : ra = 0.0 : EndIf
  
  Protected rn.d  = $FF*( 1.0 - ra )
  
  If ra > 0.99
    
    Protected df.d = ( ra - 0.99 )/( 1.0 - 0.99 )
    Protected dn.d = 1.0 - df
    
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75*dn + $48*df, (Green(cs)*ra + rn)*0.75*dn + $48*df, (Blue(cs)*ra + rn)*0.75*dn + $48*df )
    
  ElseIf ra > 0.9 And ra < 0.91
    
    df = ( ra - 0.9 )/( 0.91 - 0.9 )
    dn = 1.0 - df
    
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75*df + $48*dn, (Green(cs)*ra + rn)*0.75*df + $48*dn, (Blue(cs)*ra + rn)*0.75*df + $48*dn )
    
  ElseIf ra > 0.9
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75, (Green(cs)*ra + rn)*0.75, (Blue(cs)*ra + rn)*0.75 )
  Else
    ProcedureReturn RGB( $48, $48, $48 )
  EndIf
  
EndProcedure

; ------------------------------------------------------------------------
;  Wheel Disk Callback
; ------------------------------------------------------------------------
Procedure WheelDiskCallback( x, y, cs, ct )
    
  Protected xo.d = x - wheel_xhsiz - wheel_cx_offset
  Protected yo.d = y - wheel_yhsiz - wheel_cy_offset
  
  Protected ra.d  = Sqr( xo*xo + yo*yo )/(wheel_xhsiz*wheel_wradius)
  
  Protected va.d = Alpha(cs)/255.0
  
  If ra > 1.0 : ra = 1.0 : EndIf
  If ra < 0.0 : ra = 0.0 : EndIf
  
  Protected rn.d  = $FF*( 1.0 - ra )
  
  If ra > 0.99
    
    Protected df.d = ( ra - 0.99 )/( 1.0 - 0.99 )
    Protected dn.d = 1.0 - df
    
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75*dn + $48*df, (Green(cs)*ra + rn)*0.75*dn + $48*df, (Blue(cs)*ra + rn)*0.75*dn + $48*df )
    
  ElseIf ra > 0.9 And ra < 0.91
    
    df = ( ra - 0.9 )/( 0.91 - 0.9 )
    dn = 1.0 - df
    
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75*df + (Red(cs)*ra + rn)*va*dn, (Green(cs)*ra + rn)*0.75*df + (Green(cs)*ra + rn)*va*dn, (Blue(cs)*ra + rn)*0.75*df + (Blue(cs)*ra + rn)*va*dn )
    
  ElseIf ra > 0.9
    ProcedureReturn RGB( (Red(cs)*ra + rn)*0.75, (Green(cs)*ra + rn)*0.75, (Blue(cs)*ra + rn)*0.75 )
  Else
    ProcedureReturn RGB( (Red(cs)*ra + rn)*va, (Green(cs)*ra + rn)*va, (Blue(cs)*ra + rn)*va )
  EndIf
  
EndProcedure

; ------------------------------------------------------------------------
;  Wheel Cube Gradient
; ------------------------------------------------------------------------
Procedure OControlColorWheel_CubeGradient(*Me.CControlColorWheel_t, x, y, cs, ct )
  
;   Protected xf.f =       1.0*( x - cxpos )/csiz
;   Protected yf.f = 1.0 - 1.0*( y - cypos )/csiz
;   
;   If xf < 0.0 : xf = 0.0 : ElseIf xf > 1.0 : xf = 0.0 : EndIf
;   If yf < 0.0 : yf = 0.0 : ElseIf yf > 1.0 : yf = 0.0 : EndIf
;   
;   ProcedureReturn HSV2RGB( chue, xf, yf )
  
EndProcedure

; ------------------------------------------------------------------------
;  Draw
; ------------------------------------------------------------------------
Procedure OControlColorWheel_DrawCircle( *Me.CControlColorWheel_t,redraw_wheel = #True )  
  *Me\sizX = GadgetWidth (*Me\gadgetID) : *Me\xhsiz = *Me\sizX/2.0
  *Me\sizY = GadgetHeight(*Me\gadgetID) : *Me\yhsiz = *Me\sizY/2.0
  
  wheel_xhsiz = 128;*Me\xhsiz
  wheel_yhsiz = 128;*Me\yhsiz
  wheel_wradius = 1;*Me\wradius
  wheel_cx_offset = 0;*Me\cx_offset
  wheel_cy_offset = 0;*Me\cy_offset
  
  Protected xoff = wheel_xhsiz + wheel_cx_offset
  Protected yoff = wheel_yhsiz + wheel_cy_offset
  
  *Me\val = 0.5
  Protected calpha = *Me\val*$FF
  
  If redraw_wheel
    StartDrawing( ImageOutput(*Me\imageID) )

    Box( 0,0, 256, 256, RGB($48,$48,$48) )
    
    DrawingMode( #PB_2DDrawing_Gradient|#PB_2DDrawing_CustomFilter )
    
      Select *Me\mode
        Case #RAA_COLORWHEEL_MODE_DISK
          CustomFilterCallback( @WheelDiskCallback() )
        Case #RAA_COLORWHEEL_MODE_CUBE
          CustomFilterCallback( @WheelCubeCallback() )
        Case #RAA_COLORWHEEL_MODE_EYE
          CustomFilterCallback( @WheelEyeCallback())
      EndSelect
      
      BackColor( RGBA($FF,$00,$00,calpha) )            ; Red
      GradientColor( 0.083, RGBA($FF,$00,$7F,calpha) )
      GradientColor( 0.166, RGBA($FF,$00,$FF,calpha) ) ; Fuschia
      GradientColor( 0.250, RGBA($7F,$00,$FF,calpha) )
      GradientColor( 0.333, RGBA($00,$00,$FF,calpha) ) ; Blue
      GradientColor( 0.416, RGBA($00,$70,$FF,calpha) )
      GradientColor( 0.500, RGBA($00,$FF,$FF,calpha) ) ; Aqua
      GradientColor( 0.583, RGBA($00,$FF,$7F,calpha) )
      GradientColor( 0.666, RGBA($00,$FF,$00,calpha) ) ; Lime
      GradientColor( 0.750, RGBA($7F,$FF,$00,calpha) )
      GradientColor( 0.833, RGBA($FF,$FF,$00,calpha) ) ; Yellow
      GradientColor( 0.916, RGBA($FF,$7F,$00,calpha) )
      FrontColor( RGBA($FF,$00,$00,calpha) )           ; Red
      
      ConicalGradient( xoff, yoff, 0.0           )
      Circle         ( xoff, yoff, 128 )
;       
;       Select *Me\mode
;         Case #RAA_COLORWHEEL_MODE_CUBE
;           DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_CustomFilter )
;           CustomFilterCallback( @OControlColorWheel_CubeGradient() )
;           csiz  = 0.56*xsiz*wradius
;           cxpos = xoff - 0.5*csiz
;           cypos = yoff - 0.5*csiz
;           Box( cxpos, cypos, csiz, csiz )
;       EndSelect
        
        Protected cb_dark  = RGB($38,$38,$38)
        Protected cb_light = RGB($58,$58,$58)
        Protected xsiz = *Me\sizX
        Protected ysiz = *Me\sizY
        Line( 0,      0,      xsiz,   1,      cb_dark  )
        Line( 0,      ysiz-1, xsiz,   1,      cb_light )
        Line( 0,      0,      1,      ysiz,   cb_dark  )
        Line( xsiz-1, 0,      1,      ysiz,   cb_light )
        Line( 1,      1,      xsiz-2, 1,      cb_light )
        Line( 1,      ysiz-2, xsiz-2, 1,      cb_dark  )
        Line( 1,      1,      1,      ysiz-2, cb_light )
        Line( xsiz-2, 1,      1,      ysiz-2, cb_dark  )
      
    StopDrawing()
  EndIf
  
  StartDrawing( CanvasOutput(*Me\gadgetID) )
  
  ;     gSetUnit( #UnitPixel )
  ;     gSetAntialiasMode( #AntialiasMode_AntiAlias )
  Protected size.i = *Me\sizX
  If *Me\sizY<*Me\sizX : size = *Me\sizY : EndIf

  Box(0,0,*Me\sizX,*Me\sizY,RAA_COLOR_MAIN_BG)
  DrawImage( ImageID(*Me\imageID),0,0, size, size )
    
;     Protected col = RGBA($00,$00,$00,$AF)
;     If *Me\val < 0.6
;       col = RGBA($D0,$D0,$D0,$AF)
;     EndIf
;     
;     DrawingMode( #PB_2DDrawing_Default )
;     ;gClipBox( 2, 2, xsiz-4, ysiz-4 )
;     
;     ; Draw Center Cross
;     ;gSetPen($FF000000,1.5)
;     If *Me\mode = #RAA_COLORWHEEL_MODE_DISK
;       Line( xoff-3, yoff,   6, 0, col )
;       Line( xoff,   yoff-3, 0, 6, col )
;     EndIf
;     
;     Protected r.d = *Me\sat*( *Me\wradius**Me\xhsiz*0.9 )
;     Protected t.d = *Me\hue*2.0*#PI
;     Protected x.d = Cos( t )
;     Protected y.d = Sin( t )
;     
;     If *Me\key_down
; ;       gSetPen($FF000000,1)
; ;       gSetPenStyle(#PenStyleCustom,@myStyle(),2)
;       If Not *Me\hue_only
;         LineXY( xoff, yoff,  xoff + 0.9* *Me\xhsiz*x* *Me\wradius, yoff - 0.9* *Me\yhsiz*y* *Me\wradius, col )
;       EndIf
;       If Not *Me\sat_only
;         DrawingMode( #PB_2DDrawing_Outlined )
;         Circle( xoff, yoff, r, col )
;       EndIf
;     EndIf
;     
;     ; Draw Dot
;     Select *Me\mode
;       Case #RAA_COLORWHEEL_MODE_DISK
;         DrawingMode( #PB_2DDrawing_AlphaBlend )
;         ;DrawImage( ImageID(*Me\imageID),   xoff + x*r - 4.5, yoff - y*r - 4.5 )
;       Case #RAA_COLORWHEEL_MODE_CUBE
; ;         Protected dx = *Me\sat*csiz + cxpos
; ;         Protected dy = ( 1.0 - cval )*csiz + cypos
; ;         DrawingMode( #PB_2DDrawing_AlphaBlend )
; ;         DrawImage( ImageID(1), dx - 4.5, dy - 4.5 )
;       Case #RAA_COLORWHEEL_MODE_EYE
;     EndSelect
        
    ; Draw Hue Arrow    
;     gRotateAt ( xoff + 0.95*x*xhsiz*wradius, yoff - 0.95*y*yhsiz*wradius, 360-Degree(t)-90 )
    ;DrawImage( s_gui_controls_colorwheel_arrow, xoff + 0.95*x* *Me\xhsiz* *Me\wradius - 6, yoff - 0.95*y* *Me\yhsiz* *Me\wradius - 6 )
  
  StopDrawing()

EndProcedure
Procedure RedrawCube()
;   
;   StartDrawing( CanvasOutput(1) )
;     Box( 0,0, xsiz, 80, HSV2RGB( chue, csat, cval ) )
;   StopDrawing()
;   
;   xsiz = GadgetWidth (0) : xhsiz = xsiz/2.0
;   ysiz = GadgetHeight(0) : yhsiz = ysiz/2.0
;   
;   Protected xoff = xhsiz + wheel_cx_offset
;   Protected yoff = yhsiz + wheel_cy_offset
;   
;   StartDrawing( ImageOutput(0) )
;     DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_CustomFilter )
;     CustomFilterCallback( @WheelCubeGradient() )
;     csiz  = 0.56*xsiz*wradius
;     cxpos = xoff - 0.5*csiz
;     cypos = yoff - 0.5*csiz
;     Box( cxpos, cypos, csiz, csiz )
;   StopDrawing()
;   
;   gStartDrawing( CanvasOutput(0) )
;   
;     gSetUnit( #UnitPixel )
;     gSetAntialiasMode( #AntialiasMode_AntiAlias )
;   
;     DrawImage( ImageID(0), 0, 0 )
;     
;     gDrawingMode( #PB_2DDrawing_Default )
;     
;     Protected r.d = csat*( wradius*xhsiz*0.9 )
;     Protected t.d = chue*2.0*#PI
;     Protected x.d = Cos( t )
;     Protected y.d = Sin( t )
;     
;     Protected dx = csat*csiz + cxpos
;     Protected dy = ( 1.0 - cval )*csiz + cypos
;     
;     Protected col = RGBA($00,$00,$00,$AF)
;     If cval < 0.5
;       col = RGBA($D0,$D0,$D0,$AF)
;     EndIf
;     
;     If lm_down Or key_down
;       gSetPen($FF000000,1)
;       gSetPenStyle(#PenStyleCustom,@myStyle(),2)
;       If sat_only
;         gLine( cxpos, dy-1,  csiz, 1, col )
;       EndIf
;       If val_only
;         gLine( dx-1, cypos, 1, csiz, col )
;       EndIf
;     EndIf
;     
;     ; Draw Sat/Val Dot
;     DrawingMode( #PB_2DDrawing_AlphaBlend )
;     DrawImage( ImageID(1), dx - 4.5, dy - 4.5 )
;         
;     ; Draw Hue Arrow    
;     gRotateAt ( xoff + 0.95*x*xhsiz*wradius, yoff - 0.95*y*yhsiz*wradius, 360-Degree(t)-90 )
;     gDrawImage( iarrow, xoff + 0.95*x*xhsiz*wradius - 6, yoff - 0.95*y*yhsiz*wradius - 6 )
;   
;   gStopDrawing()

EndProcedure

Procedure OControlColorWheel_UpdateHueAndSat(*Me.CControlColorWheel_t, x, y, flag = #False )
  
  
  Protected xoff = *Me\xhsiz + *Me\cx_offset
  Protected yoff = *Me\yhsiz + *Me\cy_offset
  Protected x0.d = x - xoff
  Protected y0.d = y - yoff
  Protected hue.d
  
  If flag And *Me\sat_only
    Protected tr.d = *Me\sat*( *Me\wradius* *Me\xhsiz*0.9 )
    Protected tt.d = *Me\hue*2.0*#PI
    Protected tx.d = Cos( tt )
    Protected ty.d = Sin( tt )
    *Me\jxoff =   tx*tr - ( x - xoff )
    *Me\jyoff = - ty*tr - ( y - yoff )
  EndIf
  
  If *Me\sat_only
    x0 + *Me\jxoff
    y0 + *Me\jyoff
  EndIf
  
  Protected l0.d = Sqr( x0*x0 + y0*y0 )
  
  Protected wx.d = x0 / l0
  
  If Not *Me\sat_only
    Protected thue.d
    If flag And *Me\hue_only
      *Me\jaoff = *Me\hue*2.0*#PI
      If y0 > 0.0
        *Me\jaoff = *Me\hue - ( 1.0 - ACos(wx)/(2.0*#PI) )
      Else
        *Me\jaoff = *Me\hue - ACos(wx)/(2.0*#PI)
      EndIf
    EndIf
    If *Me\hue_only
      If y0 > 0.0
        hue = 1.0 - ( ACos(wx)/(2.0*#PI) ) + *Me\jaoff
      Else
        hue = ACos(wx)/(2.0*#PI) + *Me\jaoff
      EndIf
      If hue > 1.0 : hue = hue - 1.0 : EndIf
      If hue < 0.0 : hue = 1.0 + hue : EndIf
    Else
      If y0 > 0.0
        hue = 1.0 - ACos(wx)/(2.0*#PI)
      Else
        hue = ACos(wx)/(2.0*#PI)
      EndIf
    EndIf
    If Abs( hue - *Me\hue ) < 0.01 And flag And Not *Me\hue_only
      *Me\sat_only = #True
    Else
      *Me\hue = hue
    EndIf
    Debug "HUE:["+StrD(*Me\hue)+"]"
  EndIf
  
  If Not *Me\hue_only
    Protected sat.d
    If *Me\sat_only
      Protected r.d  = *Me\wradius* *Me\xhsiz*0.9
      Protected t.d  = *Me\hue*2.0*#PI
      Protected x1.d = Cos( t )*r
      Protected y1.d = Sin( t )*r
      sat = ( x0*x1 - y0*y1 )/( x1*x1 + y1*y1 ) ; distance to plane with normal Hue from mouse coordinates.
      If sat < 0.0 : sat = 0.0 : EndIf
    Else
      sat = 2.0*l0/( *Me\wradius*420*0.9 )
    EndIf
    If sat > 1.0 And flag
      *Me\hue_only = #True
      If *Me\sat_only
        *Me\hue = hue
        *Me\sat_only = #False
      EndIf
      ProcedureReturn
    EndIf
    *Me\sat = sat
    If *Me\sat > 1.0 : *Me\sat = 1.0 : EndIf
    If *Me\sat < 0.0 : *Me\sat = 0.0 : EndIf
  EndIf
                
EndProcedure

Procedure OControlColorWheel_UpdateCubeSatAndVal(*Me.CControlColorWheel_t, x, y, flag = #False )
  
;   ; wheel_cx_offset
;   ; wheel_cy_offset
;   ; xhsiz
;   ; yhsiz
;   
;   Protected xoff = *Me\xhsiz + *Me\cx_offset
;   Protected yoff = *Me\yhsiz + *Me\cy_offset
;   Protected x0.d = x - xoff
;   Protected y0.d = y - yoff
; 
;   Protected l0.d = Sqr( x0*x0 + y0*y0 )
;   
;   Protected wx.d = x0 / l0
;   
;   If 2.0*l0/( *Me\wradius*420*0.9 ) > 0.9 And flag
;     *Me\hue_only = #True
;   EndIf
;   
;   If *Me\hue_only
;     If y0 > 0.0
;       *Me\hue = 1.0 - ACos(wx)/(2.0*#PI)
;     Else
;       *Me\hue = ACos(wx)/(2.0*#PI)
;     EndIf
;     ProcedureReturn
;   EndIf
;   
;   If flag And ( *Me\sat_only Or *Me\val_only )
;     Protected tr.d = *Me\sat*( *Me\wradius* *Me\xhsiz*0.9 )
;     Protected tt.d = *Me\hue*2.0*#PI
;     Protected tx.d = Cos( tt )
;     Protected ty.d = Sin( tt )
;     If *Me\sat_only
;       *Me\jxoff = (*Me\sat*csiz + cxpos) - x
;     ElseIf val_only
;       *Me\jyoff = ((1.0 - cval)*csiz + cxpos) - y
;     EndIf
;   EndIf
;   
;   If *Me\sat_only
;     x + jxoff
;   ElseIf  val_only
;     y + jyoff
;   EndIf
;   
;   If Not *Me\val_only
;     *Me\sat = 1.0*( x - cxpos )/csiz
;     If csat < 0.0 : csat = 0.0 : ElseIf csat > 1.0 : csat = 1.0 : EndIf
;   EndIf
;   
;   If Not sat_only
;     cval = 1.0 - 1.0*( y - cypos )/csiz
;     If cval < 0.0 : cval = 0.0 : ElseIf cval > 1.0 : cval = 1.0 : EndIf
;   EndIf
  
EndProcedure
Procedure OControlColorWheel_UpdateRadius( *Me.CControlColorWheel_t,delta, x, y )
  
  
  Protected oradius.d = *Me\wradius : *Me\wradius + delta/4.0
  If *Me\wradius > 5.0
    *Me\wradius = 5.0
  ElseIf *Me\wradius < 1 
    *Me\wradius = 1
    *Me\cx_offset = 0
    *Me\cy_offset = 0
  Else
    Protected wx.d = ( *Me\xhsiz + *Me\cx_offset ) - x
    Protected wy.d = ( *Me\yhsiz + *Me\cy_offset ) - y
    Protected wf.d = *Me\wradius/oradius
    *Me\cx_offset + ( wx*wf - wx )
    *Me\cy_offset + ( wy*wf - wy )
  EndIf
              
EndProcedure

Procedure OControlColorWheel_ResetRadius(*Me.CControlColorWheel_t) 
  *Me\wradius         = 1.0
  *Me\cx_offset = 0
  *Me\cy_offset = 0 
EndProcedure


; ----------------------------------------------------------------------------
;  hlpDraw
; ----------------------------------------------------------------------------
Procedure OControlColorWheel_hlpDraw( *Me.CControlColorWheel_t, xoff.i = 0, yoff.i = 0 )

  
  
EndProcedure
;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ OnEvent ]--------------------------------------------------------------
Procedure.i OControlColorWheel_OnEvent( *Me.CControlColorWheel_t, ev_code.i, *ev_data.EventTypeDatas_t = #Null )
  Debug "Color Wheel On Event!!!"
  ; ---[ Retrieve Interface ]-------------------------------------------------
  Protected Me.CControl = *Me
  
  ; ---[ Dispatch Event ]-----------------------------------------------------
  Select ev_code

    ; ------------------------------------------------------------------------
    ;  Draw
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Draw
      ; ...[ Draw Control ]...................................................
      OControlColorWheel_hlpDraw( *Me.CControlColorWheel_t, *ev_data\xoff, *ev_data\yoff )
      ; ...[ Processed ]......................................................
      ret( #True )
      
    ; ------------------------------------------------------------------------
    ;  Resize
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Resize
      ; ...[ Sanity Check ]...................................................
      CHECK_PTR1_NULL( *ev_data )
      ; ...[ Cancel Height Resize ]...........................................
      *Me\sizY = 18
      ; ...[ Update Status ]..................................................
      If #PB_Ignore <> *ev_data\width : *Me\sizX = *ev_data\width : EndIf
      If #PB_Ignore <> *ev_data\x     : *Me\posX = *ev_data\x     : EndIf
      If #PB_Ignore <> *ev_data\y     : *Me\posY = *ev_data\y     : EndIf
      ; ...[ Processed ]......................................................
      ret( #True )
      
    ; ------------------------------------------------------------------------
    ;  MouseEnter
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseEnter


    ; ------------------------------------------------------------------------
    ;  MouseLeave
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseLeave

      
    ; ------------------------------------------------------------------------
    ;  MouseMove
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseMove
      
    ; ------------------------------------------------------------------------
    ;  MouseWheel
    ; ------------------------------------------------------------------------
  Case #PB_EventType_MouseWheel
    Protected mx = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX )
    Protected my = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY )
    OControlColorWheel_UpdateRadius( *Me,GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_WheelDelta ), mx, my )
    Debug *me\wradius
      OControlColorWheel_DrawCircle( *Me,#True )


    ; ------------------------------------------------------------------------
    ;  LeftButtonDown
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonDown
      
      
    ; ------------------------------------------------------------------------
    ;  LeftButtonUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      
      
    ; ------------------------------------------------------------------------
    ;  Enable
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Enable
     
    ; ------------------------------------------------------------------------
    ;  Key Down
    ; ------------------------------------------------------------------------
    Case #PB_EventType_KeyDown
      Protected ckey = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Key )
      If GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Modifiers ) & #PB_Canvas_Alt
      Else
        If Not *Me\key_down = #True
          *Me\key_down = #True
          Select *Me\mode
            Case #RAA_COLORWHEEL_MODE_DISK
              If ckey = 17 ; CTRL
                *Me\hue_only = #True
              ElseIf ckey = 16 ; SHIFT
                *Me\sat_only = #True
              EndIf
              OControlColorWheel_DrawCircle(*Me,#False)
            Case #RAA_COLORWHEEL_MODE_CUBE
              If ckey = 17 ; CTRL
                *Me\val_only = #True
              ElseIf ckey = 16 ; SHIFT
                *Me\sat_only = #True
              EndIf
              OControlColorWheel_DrawCircle(*Me,#False)
          EndSelect
        EndIf
      EndIf
    
      
  EndSelect
  
  ; ---[ Process Default ]----------------------------------------------------
  ret( #False )
  
EndProcedure
;}


; ============================================================================
;  IMPLEMENTATION ( CControlColorWheel )
; ============================================================================
;{
; ---[ SetValue ]-------------------------------------------------------------
Procedure OControlColorWheel_SetValue( *Me.CControlColorWheel_t, r.f,g.f,b.f,a.f )
  
EndProcedure

; ---[ GetValue ]-------------------------------------------------------------
Procedure.i OControlColorWheel_GetValue( *Me.CControlColorWheel_t,*color.c4f32 )
  Color4_Set(*color,*Me\color\r,*Me\color\g,*Me\color\b,*Me\color\a)
EndProcedure

; ---[ Free ]-----------------------------------------------------------------
Procedure OControlColorWheel_Free( *Me.CControlColorWheel_t )
  FreeMemory( *Me )
EndProcedure
;}


; ============================================================================
;  VTABLE & DATAS ( CObject + CControl + CControlColorWheel )
; ============================================================================
;{
DataSection
  ; CObject
  CObject_DAT( ControlColorWheel )
  ; CControl
  CControl_DAT
  Data.i @OControlColorWheel_OnEvent() ; mandatory override
  
  ; CControlColorWheel
  Data.i @OControlColorWheel_SetValue()
  Data.i @OControlColorWheel_GetValue()
  

  VIControlColorWheel_Dot:
  IncludeBinary "../../rsc/skins/grey/control_colorwheel/white_dot.png"
  
  VIControlColorWheel_Arrow:
  IncludeBinary "../../rsc/skins/grey/control_colorwheel/white_arrow.png"
  
EndDataSection
;}


; ============================================================================
;  REFLECTION
; ============================================================================
;{
; ----------------------------------------------------------------------------
;  CControlColorWheelClass Object
; ----------------------------------------------------------------------------
Class_DEF( ControlColorWheel )
;}


; ============================================================================
;  CONSTRUCTORS
; ============================================================================
;{
; ---[ Stack ]----------------------------------------------------------------
Procedure.i nesCControlColorWheel( *Me.CControlColorWheel_t, x.i=0,y.i=0,width.i=200,height.i=200 )
  
  ; ---[ Sanity Check ]-------------------------------------------------------
  CHECK_PTR1_NULL( *Me )
  
  ; ---[ Init CObject Base Class ]--------------------------------------------
  CObject_INI( ControlColorWheel )
  
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\type     = #PB_GadgetType_ColorWheel
  *Me\name     = "Color Wheel"
  *Me\posX     = x
  *Me\posY     = y
  *Me\sizX     = width
  *Me\sizY     = height
  *Me\gadgetID = CanvasGadget(#PB_Any,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY,#PB_Canvas_Keyboard|#PB_Canvas_DrawFocus)
  *Me\imageID  = CreateImage(#PB_Any,256,256)
  *Me\visible  = #True
  *Me\enable   = #True
  *Me\mode     = #RAA_COLORWHEEL_MODE_DISK
  *Me\wradius  = 0.5
  
  OControlColorWheel_DrawCircle(*Me)
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ret( *Me )
  
EndProcedure
; ---[ Heap ]-----------------------------------------------------------------
Procedure.i newCControlColorWheel( x.i=0, y.i=0,width.i=100,height.i=100 )
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *p.CControlColorWheel_t = AllocateMemory( SizeOf(CControlColorWheel_t) )
  
  ; ---[ Init Object ]--------------------------------------------------------
  ret( nesCControlColorWheel( *p, x,y,width,height ) )
  
EndProcedure
;}


; ============================================================================
;  PROCEDURES
; ============================================================================
;{
Procedure raaGUIControlsColorWheelSetTheme( theme.RAA_GUI_THEME )
  
  Select theme
      
    ; ---[ Light ]------------------------------------------------------------
    Case #RAA_GUI_THEME_LIGHT
      s_gui_controls_colorwheel_dot  = s_gui_controls_light_colorwheel_dot
      s_gui_controls_colorwheel_arrow  = s_gui_controls_light_colorwheel_arrow
      
    ; ---[ Dark ]-------------------------------------------------------------
    Case #RAA_GUI_THEME_DARK
      s_gui_controls_colorwheel_dot  = s_gui_controls_dark_colorwheel_dot
      s_gui_controls_colorwheel_arrow  = s_gui_controls_dark_colorwheel_arrow
      
  EndSelect
  
EndProcedure
;}


; ============================================================================
;  ADMINISTRATION
; ============================================================================
;{
; ----------------------------------------------------------------------------
;  GLOBALS
; ----------------------------------------------------------------------------
ADMIN_GLOBALS( gui_controls_colorwheel )
; ----------------------------------------------------------------------------
;  raaGuiControlsControlWheelInitOnce
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsControlWheelInitOnce( void )
;CHECK_INIT

  ; ---[ Init Start ]---------------------------------------------------------
  ADMIN_INIT_START( gui_controls_colorwheel )
  
  ; ---[ Init Once ]----------------------------------------------------------
  ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
  ;  LIGHT
  ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
  ;{
  s_gui_controls_light_colorwheel_dot  = CatchImage( #PB_Any, ?VIControlColorWheel_Dot  )
  s_gui_controls_light_colorwheel_arrow = CatchImage( #PB_Any, ?VIControlColorWheel_Arrow )
  ;}
  ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
  ;  DARK
  ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
  ;{
  s_gui_controls_dark_colorwheel_dot  = CatchImage( #PB_Any, ?VIControlColorWheel_Dot  )
  s_gui_controls_dark_colorwheel_arrow = CatchImage( #PB_Any, ?VIControlColorWheel_Arrow )
  ;}
  
  ; ---[ Init End ]-----------------------------------------------------------
  ADMIN_INIT_END( gui_controls_colorwheel )
  
  ; ---[ OK ]-----------------------------------------------------------------
  ret( #RAA_OK )
  
EndProcedure
; ----------------------------------------------------------------------------
;  raaGuiControlsControlWheelTermOnce
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsControlWheelTermOnce( void )
;CHECK_INIT  

  ; ---[ Term Start ]---------------------------------------------------------
  ADMIN_TERM_START( gui_controls_colorwheel )
  
  ; ---[ Term Once ]----------------------------------------------------------
  ; 같�[ Free Images ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같
  ;{
  ; ...[ Dark ]...............................................................
  ;{
  FreeImage( s_gui_controls_dark_colorwheel_dot     )
  FreeImage( s_gui_controls_dark_colorwheel_arrow      )
  ;}
  ; ...[ Light ]..............................................................
  ;{
  FreeImage( s_gui_controls_light_colorwheel_dot     )
  FreeImage( s_gui_controls_light_colorwheel_arrow      )
  ;}
  ;}

  ; ---[ Term End ]-----------------------------------------------------------
  ADMIN_TERM_END( gui_controls_colorwheel )
  
  ; ---[ OK ]-----------------------------------------------------------------
  ret( #RAA_OK )
  
EndProcedure
; ----------------------------------------------------------------------------
;  raaGuiControlsControlWheelIsInitialized
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsControlWheelIsInitialized( void )
  
  ; ---[ Return Status ]------------------------------------------------------
  ret( ADMIN_STATUS( gui_controls_colorwheel ) )
  
EndProcedure
; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 705
; FirstLine = 389
; Folding = --------
; EnableXP
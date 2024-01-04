XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/UIColor.pbi"

; ==============================================================================
;  CONTROL COLORWHEEL MODULE DECLARATION
; ==============================================================================
DeclareModule ControlColorWheel
  UseModule Math
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  
  Enumeration
    #MODE_DISK = 0
    #MODE_CUBE
    #MODE_EYE
    
    #MODE_MAX
  EndEnumeration
  
  
  Global wheel_xhsiz.d
  Global wheel_yhsiz.d
  Global wheel_cx_offset.d
  Global wheel_cy_offset.d
  Global wheel_wradius.d
  
  
  ; ============================================================================
  ;  CLASS ( ControlColorWheel )
  ; ============================================================================
  ; ----------------------------------------------------------------------------
  ;  Class ( Object + Control + ControlColorWheel )
  ; ----------------------------------------------------------------------------
  Interface ControlColorWheel Extends Control::IControl
    SetValue   ( r.f,g.f,b.f,a.f )
    GetValue.i ( *color.c4f32    )
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Object ( CControlColorWheel_t )
  ; ----------------------------------------------------------------------------
  Structure ControlColorWheel_t Extends Control::Control_t
    imageID.i
    hue.d
    val.d
    sat.d
    
    cx_offset.d
    cy_offset.d
    
    jxoff.i
    jyoff.i
    jaoff.d
    
    wradius.d
    
    
    key_down.b
    mode.i
    hue_only.b
    val_only.b
    sat_only.b
    
    color.c4f32
  EndStructure
  
  ; ============================================================================
  ;  Functions Declaration
  ; ============================================================================
  Declare New(*parent.Control::Control_t,x.i=0,y.i=0,width.i=200,height.i=200 )
  Declare Delete(*Me.ControlColorWheel_t)
  Declare OnEvent( *Me.ControlColorWheel_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetValue( *Me.ControlColorWheel_t, r.f,g.f,b.f,a.f )
  Declare GetValue( *Me.ControlColorWheel_t,*color.c4f32 )
  
  ; ============================================================================
  ;  VTABLE & DATAS ( Object + Control + ControlColorWheel )
  ; ============================================================================
  DataSection
    ControlColorWheelVT:

    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()
    
    ; ControlColorWheel
    Data.i @SetValue()
    Data.i @GetValue()
    
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule



; ============================================================================
;  CONTROL COLORWHEEL MODULE IMPLEMENTATION
; ============================================================================
Module ControlColorWheel
  
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
  Procedure CubeGradient(*Me.ControlColorWheel_t, x, y, cs, ct )
    
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
  Procedure DrawCircle( *Me.ControlColorWheel_t,redraw_wheel = #True )  

    wheel_xhsiz = 128
    wheel_yhsiz = 128
    wheel_wradius = 1
    wheel_cx_offset = 0
    wheel_cy_offset = 0
    
    Protected xoff = wheel_xhsiz + wheel_cx_offset
    Protected yoff = wheel_yhsiz + wheel_cy_offset
    
    *Me\val = 0.5
    Protected calpha = *Me\val*$FF
    
    If redraw_wheel
      StartDrawing( ImageOutput(*Me\imageID) )
  
      Box( 0,0, 256, 256, RGB($48,$48,$48) )
      
      DrawingMode( #PB_2DDrawing_Gradient|#PB_2DDrawing_CustomFilter )
      
        Select *Me\mode
          Case #MODE_DISK
            CustomFilterCallback( @WheelDiskCallback() )
          Case #MODE_CUBE
            CustomFilterCallback( @WheelCubeCallback() )
          Case #MODE_EYE
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
  ;         Case #COLORWHEEL_MODE_CUBE
  ;           DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_CustomFilter )
  ;           CustomFilterCallback( @OControlColorWheel_CubeGradient() )
  ;           csiz  = 0.56*xsiz*wradius
  ;           cxpos = xoff - 0.5*csiz
  ;           cypos = yoff - 0.5*csiz
  ;           Box( cxpos, cypos, csiz, csiz )
  ;       EndSelect
;           
;           Protected cb_dark  = RGB($38,$38,$38)
;           Protected cb_light = RGB($58,$58,$58)
;           Protected xsiz = *Me\sizX
;           Protected ysiz = *Me\sizY
;           Line( 0,      0,      xsiz,   1,      cb_dark  )
;           Line( 0,      ysiz-1, xsiz,   1,      cb_light )
;           Line( 0,      0,      1,      ysiz,   cb_dark  )
;           Line( xsiz-1, 0,      1,      ysiz,   cb_light )
;           Line( 1,      1,      xsiz-2, 1,      cb_light )
;           Line( 1,      ysiz-2, xsiz-2, 1,      cb_dark  )
;           Line( 1,      1,      1,      ysiz-2, cb_light )
;           Line( xsiz-2, 1,      1,      ysiz-2, cb_dark  )
        
      StopDrawing()
    EndIf
   
    
  
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
  
  Procedure UpdateHueAndSat(*Me.ControlColorWheel_t, x, y, flag = #False )
    
    
    Protected xoff = *Me\sizX * 0.5 + *Me\cx_offset
    Protected yoff = *Me\sizY * 0.5 + *Me\cy_offset
    Protected x0.d = x - xoff
    Protected y0.d = y - yoff
    Protected hue.d
    
    If flag And *Me\sat_only
      Protected tr.d = *Me\sat*( *Me\wradius* *Me\sizX * 0.5 *0.9 )
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
        Protected r.d  = *Me\wradius* *Me\sizX*0.5*0.9
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
  
  Procedure UpdateCubeSatAndVal(*Me.ControlColorWheel_t, x, y, flag = #False )
    
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
  Procedure UpdateRadius( *Me.ControlColorWheel_t,delta, x, y )
    
    
    Protected oradius.d = *Me\wradius : *Me\wradius + delta/4.0
    If *Me\wradius > 5.0
      *Me\wradius = 5.0
    ElseIf *Me\wradius < 1 
      *Me\wradius = 1
      *Me\cx_offset = 0
      *Me\cy_offset = 0
    Else
      Protected wx.d = ( *Me\sizX*0.5 + *Me\cx_offset ) - x
      Protected wy.d = ( *Me\sizY*0.5 + *Me\cy_offset ) - y
      Protected wf.d = *Me\wradius/oradius
      *Me\cx_offset + ( wx*wf - wx )
      *Me\cy_offset + ( wy*wf - wy )
    EndIf
                
  EndProcedure
  
  Procedure ResetRadius(*Me.ControlColorWheel_t) 
    *Me\wradius   = *Me\sizX * 0.5
    *Me\cx_offset = 0
    *Me\cy_offset = 0 
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure hlpDraw( *Me.ControlColorWheel_t, xoff.i = 0, yoff.i = 0 )
  
    Protected size.i = *Me\sizX
    If *Me\sizY<*Me\sizX : size = *Me\sizY : EndIf
  
    AddPathBox(xoff,yoff,*Me\sizX,*Me\sizY)
    VectorSourceColor(RGBA(255,0,0,255));UIColor::COLOR_MAIN_BG)
    FillPath()
    
    ResetCoordinates()
    MovePathCursor(xoff,yoff)
    DrawVectorImage( ImageID(*Me\imageID), 255,size, size )
    

      Protected col = RGBA($00,$00,$00,$AF)
      If *Me\val < 0.6
        col = RGBA($D0,$D0,$D0,$AF)
      EndIf
      
      
      ; Draw Center Cross
      If *Me\mode = #MODE_DISK
        MovePathCursor( xoff-3, yoff)
        AddPathLine(6, 0)
        
        MovePathCursor( xoff,   yoff-3)
        AddPathLine(0, 6 )
        
        VectorSourceColor(col)
        StrokePath(2)
      EndIf
      
      Protected r.d = *Me\sat*( *Me\wradius**Me\sizX*0.5*0.9 )
      Protected t.d = *Me\hue*2.0*#PI
      Protected x.d = Cos( t )
      Protected y.d = Sin( t )
      
      If *Me\key_down
  ;       gSetPen($FF000000,1)
  ;       gSetPenStyle(#PenStyleCustom,@myStyle(),2)
        If Not *Me\hue_only
          MovePathCursor( xoff, yoff)
          AddPathLine(xoff + 0.9* *Me\sizX*0.5*x* *Me\wradius, yoff - 0.9* *Me\sizY*0.5*y* *Me\wradius)
          StrokePath(2)
        EndIf
        If Not *Me\sat_only
          AddPathCircle(xoff, yoff, r)
          VectorSourceColor(col)
          StrokePath(2)
        EndIf
      EndIf
      
      ; Draw Dot
      Select *Me\mode
        Case #MODE_DISK
;           DrawingMode( #PB_2DDrawing_AlphaBlend )
          ;DrawImage( ImageID(*Me\imageID),   xoff + x*r - 4.5, yoff - y*r - 4.5 )
        Case #MODE_CUBE
  ;         Protected dx = *Me\sat*csiz + cxpos
  ;         Protected dy = ( 1.0 - cval )*csiz + cypos
  ;         DrawingMode( #PB_2DDrawing_AlphaBlend )
  ;         DrawImage( ImageID(1), dx - 4.5, dy - 4.5 )
        Case #MODE_EYE
      EndSelect
          
;       Draw Hue Arrow    
;       gRotateAt ( xoff + 0.95*x*xhsiz*wradius, yoff - 0.95*y*yhsiz*wradius, 360-Degree(t)-90 )
;       DrawImage( s_gui_controls_colorwheel_arrow, xoff + 0.95*x* *Me\xhsiz* *Me\wradius - 6, yoff - 0.95*y* *Me\yhsiz* *Me\wradius - 6 )
    
  EndProcedure

  
  ; ============================================================================
  ;  OVERRIDE ( Control )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlColorWheel_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
    
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
  
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        hlpDraw( *Me.ControlColorWheel_t, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn #True 
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Resize
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        
        ; ...[ Update Status ]..................................................
        If #PB_Ignore <> *ev_data\width : *Me\sizX = *ev_data\width : EndIf
        If #PB_Ignore <> *ev_data\height : *Me\sizY = *ev_data\height : EndIf
        If #PB_Ignore <> *ev_data\x     : *Me\posX = *ev_data\x     : EndIf
        If #PB_Ignore <> *ev_data\y     : *Me\posY = *ev_data\y     : EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn #True 
        
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
      UpdateRadius( *Me,GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_WheelDelta ), mx, my )
      Control::Invalidate(*Me)
  
  
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
      Case Control::#PB_EventType_Enable
       
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
              Case #MODE_DISK
                If ckey = 17 ; CTRL
                  *Me\hue_only = #True
                ElseIf ckey = 16 ; SHIFT
                  *Me\sat_only = #True
                EndIf
                DrawCircle(*Me)
              Case #MODE_CUBE
                If ckey = 17 ; CTRL
                  *Me\val_only = #True
                ElseIf ckey = 16 ; SHIFT
                  *Me\sat_only = #True
                EndIf
                DrawCircle(*Me)
            EndSelect
          EndIf
        EndIf
      
        
    EndSelect
    
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn( #False )
    
  EndProcedure
 
  ; ============================================================================
  ;  IMPLEMENTATION ( ControlColorWheel )
  ; ============================================================================
  ; ---[ SetValue ]-------------------------------------------------------------
  Procedure SetValue( *Me.ControlColorWheel_t, r.f,g.f,b.f,a.f )
    
  EndProcedure
  
  ; ---[ GetValue ]-------------------------------------------------------------
  Procedure.i GetValue( *Me.ControlColorWheel_t,*color.c4f32 )
    Color::Set(*color,*Me\color\r,*Me\color\g,*Me\color\b,*Me\color\a)
  EndProcedure
  
  ; ---[ Delete ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlColorWheel_t )
    Object::TERM(ControlColorWheel)
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New( *parent.Control::Control_t, x.i=0,y.i=0,width.i=200,height.i=200 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlColorWheel_t = AllocateStructure(ControlColorWheel_t)
    
    ; ---[ Init CObject Base Class ]--------------------------------------------
    Object::INI( ControlColorWheel )
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#COLORWHEEL
    *Me\name     = "ColorWheel"
    *Me\posX     = x
    *Me\posY     = y
    *Me\sizX     = width
    *Me\sizY     = height
    *Me\parent   = *parent
    *Me\gadgetID = *parent\gadgetID
    *Me\imageID  = CreateImage(#PB_Any,256,256)
    *Me\visible  = #True
    *Me\enable   = #True
    *Me\mode     = #MODE_DISK
    *Me\wradius  = 0.5
    
    DrawCircle(*Me)
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
 
  ; ============================================================================
  ;  REFLECTION
  ; ============================================================================
  Class::DEF( ControlColorWheel )
  
EndModule

; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 791
; FirstLine = 789
; Folding = ----
; EnableXP
; based on https://www.shadertoy.com/view/Mdy3Dw

Procedure Mandelbrot(t.f, width.i, height.i)
  Protected scale.f = 1 + Cos( t )
  Protected x.i, y.i, z.i
  Protected x_off.f, y_off.f, dx.f, px.f, py.f
  Protected ox.f, oy.f
  Protected r.l, g.l
  t + 0.01
  For y = 0 To height - 1
    y_off = (y / height -0.5) * scale
    x_off = -0.5 * scale
    dx = scale / width
    For x=0 To width - 1
      ox = 0
      oy = 0
      For z=0 To 7
        px = ox
        py = oy
        oy = -(py * py - px * px - 0.55 + x_off)
        ox = -(px * px + py * px - 0.55 + y_off)
      Next
      r = ox * 255
      g = oy * 255
      Plot(x, y, RGB(r,g,255))
      x_off + dx
    Next
  Next
EndProcedure

Define WIDTH = 256
Define HEIGHT = 256
Define window.i = OpenWindow(#PB_Any, 0,0,WIDTH, HEIGHT, "MANDELBROOT")
Define canvas.i = CanvasGadget(#PB_Any, 0,0,WIDTH, HEIGHT)


StartDrawing(CanvasOutput(canvas))
Mandelbrot(6.666, WIDTH, HEIGHT)
StopDrawing()

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow

    
; For( int y = 0; y < SCRHEIGHT; y++ )
; {
;  float yoffs = ((float)y / SCRHEIGHT - 0.5f) * scale;
;  float xoffs = -0.5f * scale, dx = scale / SCRWIDTH;
;  For( int x = 0; x < SCRWIDTH; x++, xoffs += dx )
;  {
;  float ox = 0, oy = 0, py;
;  For( int i = 0; i < 99; i++ ) px = ox, py = oy,
;  oy = -(py * py - px * px - 0.55f + xoffs),
;  ox = -(px * py + py * px - 0.55f + yoffs);
;  int r = min( 255, max( 0, (int)(ox * 255) ) );
;  int g = min( 255, max( 0, (int)(oy * 255) ) );
;  screen->Plot( x, y, (r << 16) + (g << 8) );
;  }
; }

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 31
; Folding = -
; EnableXP
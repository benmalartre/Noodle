


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"

UseModule Math
width = 800
height = 800
window = OpenWindow(#PB_Any, 0, 0, width, height, "MATH", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
canvas = CanvasGadget(#PB_Any, 0,0,width, height)


Procedure BuildDisc(x.i, y.i, r.i, method.b=#False)
  p.v2f32
  c1.c4f32
  c2.c4f32
  c.c4f32
  Color::Set(@c1,1.0,1.0,0.0)
  Color::Set(@c2,0.0,0.5,0.75)
  
  For i=0 To 2000
    Math::UniformPointOnCircle(@p)
    Circle(x + p\x * r, y + p\y * r,1, RGB(255,0,0))
    If method
      Math::UniformPointOnDisc2(@p)
    Else
      Math::UniformPointOnDisc(@p)
    EndIf
      
    Color::LinearInterpolate(@c, @c1, @c2, Vector2::Length(@p))
    Circle(x + p\x * (r-2), y + p\y * (r-2),1, RGB(c\r*255, c\g*255, c\b*255))
  Next
EndProcedure

Time::Init()
r.i=250
StartDrawing(CanvasOutput(canvas))
  Box(0,0,width, height, RGB(128,128,128))
StopDrawing()

Repeat
  
  StartDrawing(CanvasOutput(canvas))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  Box(0,0,width, height, RGBA(128,128,128,32))
  DrawingMode(#PB_2DDrawing_Default)
  Define t.d = Time::Get()
  BuildDisc(100+Random(10)-5, 100+Random(10)-5, 50)
  BuildDisc(300+Random(10)-5, 100+Random(10)-5, 50)
  BuildDisc(500+Random(10)-5, 100+Random(10)-5, 50)
  BuildDisc(700+Random(10)-5, 100+Random(10)-5, 50)
  
  BuildDisc(100+Random(10)-5, 300+Random(10)-5, 50)
  BuildDisc(300+Random(10)-5, 300+Random(10)-5, 50)
  BuildDisc(500+Random(10)-5, 300+Random(10)-5, 50)
  BuildDisc(700+Random(10)-5, 300+Random(10)-5, 50)
  Define d1.f = Time::Get() - t
  t.d = Time::Get()
  BuildDisc(100+Random(10)-5, 500+Random(10)-5, 50,#True)
  BuildDisc(300+Random(10)-5, 500+Random(10)-5, 50,#True)
  BuildDisc(500+Random(10)-5, 500+Random(10)-5, 50,#True)
  BuildDisc(700+Random(10)-5, 500+Random(10)-5, 50,#True)
  
  BuildDisc(100+Random(10)-5, 700+Random(10)-5, 50,#True)
  BuildDisc(300+Random(10)-5, 700+Random(10)-5, 50,#True)
  BuildDisc(500+Random(10)-5, 700+Random(10)-5, 50,#True)
  BuildDisc(700+Random(10)-5, 700+Random(10)-5, 50,#True)
  Define d2.f = Time::Get() - t
  
  Box(0,0,width, 64, RGB(128,128,128))
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawText(10,10,"Rejection Method : "+StrD(d1), RGB(0,0,0))
  DrawText(10,30,"Polar Method : "+StrD(d2), RGB(0,0,0))
  StopDrawing()
Until WaitWindowEvent(0) = #PB_Event_CloseWindow


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 35
; Folding = -
; EnableXP
; EnableUnicode
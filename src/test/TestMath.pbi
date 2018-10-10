


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"

UseModule Math
Define width = 800
Define height = 800
Define window = OpenWindow(#PB_Any, 0, 0, width, height, "MATH", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
Define canvas = CanvasGadget(#PB_Any, 0,0,width, height)

Macro Normalize(_v,_o)
  Define _mag.f = Sqr(_o\x * _o\x + _o\y * _o\y + _o\z * _o\z)
  ;Avoid error dividing by zero
  If _mag = 0 : _mag =1.0 :EndIf
  
  Define _div.f = 1.0/_mag
  _v\x = _o\x * _div
  _v\y = _o\y * _div
  _v\z = _o\z * _div
EndMacro

Macro CrossProduct(_v,_a,_b)
  _v\x = (_a\y * _b\z) - (_a\z * _b\y)
  _v\y = (_a\z * _b\x) - (_a\x * _b\z)
  _v\z = (_a\x * _b\y) - (_a\y * _b\x)
EndMacro

Procedure.s ArrayString(*A, nb)
  Protected *v.v3f32
  Protected s.s
  Define i
  If nb > 12
    For i=0 To 5
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
    For i=nb-7 To nb-1
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
  Else
    For i=0 To nb-1
      *v = *A + i * SizeOf(v3f32)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
  EndIf
    
  ProcedureReturn s
EndProcedure

Procedure Compare(*A1, *A2, nb)
  Protected *v1.v3f32, *v2.v3f32
  Define i
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(v3f32)
    *v2 = *A2 + i * SizeOf(v3f32)
    If Abs(*v1\x - *v2\x) > 0.001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\y - *v2\y) > 0.001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\z - *v2\z) > 0.001
      ProcedureReturn #False
    EndIf
  Next
  
  ProcedureReturn #True
EndProcedure

Procedure TestCrossProduct(nb.i)
  Define i, offset
  Define.v3f32 *v1, *v2, *v3
  
  Define *A = AllocateMemory(nb * SizeOf(v3f32))
  Define *B = AllocateMemory(nb * SizeOf(v3f32))
  Define *C = AllocateMemory(nb * SizeOf(v3f32))
  Define *D = AllocateMemory(nb * SizeOf(v3f32))
  
  Define *v.v3f32
  For i=0 To nb -1
    *v = *A + i * SizeOf(v3f32)
    *v\x = (Random(2000) - 1000) * 0.001
    *v\y = (Random(2000) - 1000) * 0.001
    *v\z = (Random(2000) - 1000) * 0.001
    
    *v = *B + i * SizeOf(v3f32)
    *v\x = (Random(2000) - 1000) * 0.001
    *v\y = (Random(2000) - 1000) * 0.001
    *v\z = (Random(2000) - 1000) * 0.001
  Next
  
  Define T.d = Time::Get()
  For i=0 To nb-1
    offset = i * SizeOf(v3f32)
    *v1 = *A + offset
    *v2 = *B + offset
    *v3 = *C + offset
    
    Vector3::Cross(*v3, *v1, *v2)
  Next

  Define T1.d = Time::Get() - T
  
  T.d = Time::Get()
  For i=0 To nb-1
    offset = i * SizeOf(v3f32)
    *v1 = *A + offset
    *v2 = *B + offset
    *v3 = *D + offset
    CrossProduct(*v3, *v1, *v2)
  Next

  Define T2.d = Time::Get() - T
  
  MessageRequester("CROSS PRODUCT",
                   "With SSE:"+ Str(nb)+" cross product took : "+ StrD(T1)+Chr(10)+
                   "WITHout SSE:"+ Str(nb)+" cross product took : "+ StrD(T2)+Chr(10)+
                   "COMPARE RESULTS : "+Str(Compare(*C, *D, nb))+Chr(10)+
                   ArrayString(*C, nb)+Chr(10)+"-------------------"+Chr(10)+
                   ArrayString(*D, nb)+Chr(10))
  
EndProcedure


Procedure TestNormalize(nb.i)
  Define i, offset
  Define.v3f32 *v1, *v2, *v3
  
  Define *A = AllocateMemory(nb * SizeOf(v3f32))
  Define *B = AllocateMemory(nb * SizeOf(v3f32))
  Define *C = AllocateMemory(nb * SizeOf(v3f32))
  
  Define *v.v3f32
  For i=0 To nb -1
    *v = *A + i * SizeOf(v3f32)
    *v\x = (Random(1000)) * 0.001 + 0.5
    *v\y = (Random(1000)) * 0.001 + 0.5 
    *v\z = (Random(1000)) * 0.001 + 0.5
  Next
  
   Define T.d = Time::Get()
  For i=0 To nb-1
    offset = i * SizeOf(v3f32)
    *v1 = *A + offset
    *v2 = *C + offset
    Normalize(*v2, *v1)
  Next

  Define T2.d = Time::Get() - T
  
  Define T.d = Time::Get()
  For i=0 To nb-1
    offset = i * SizeOf(v3f32)
    *v1 = *A + offset
    *v2 = *B + offset
    
    Vector3::Normalize(*v2, *v1)
  Next

  Define T1.d = Time::Get() - T
  
 
  
  MessageRequester("NORMALIZE",
                   "With SSE:"+ Str(nb)+" normalization took : "+ StrD(T1)+Chr(10)+
                   "WITHout SSE:"+ Str(nb)+" normalization took : "+ StrD(T2)+Chr(10)+
                   "COMPARE RESULTS : "+Str(Compare(*B, *C, nb))+Chr(10)+
                   ArrayString(*A, nb)+Chr(10)+"-------------------"+Chr(10)+
                   ArrayString(*B, nb)+Chr(10)+"-------------------"+Chr(10)+
                   ArrayString(*C, nb)+Chr(10))
  
EndProcedure

Procedure BuildDisc(x.i, y.i, r.i, method.b=#False)
  Define p.v2f32
  Define c1.c4f32
  Define c2.c4f32
  Define c.c4f32
  Color::Set(c1,1.0,1.0,0.0,1)
  Color::Set(c2,0.0,0.5,0.75,1)
  Define i
  For i=0 To 2000
    Math::UniformPointOnCircle(@p)
    Circle(x + p\x * r, y + p\y * r,1, RGB(255,0,0))
    If method
      Math::UniformPointOnDisc2(@p)
    Else
      Math::UniformPointOnDisc(@p)
    EndIf
      
    Color::LinearInterpolate(c, c1, c2, Vector2::Length(p))
    Circle(x + p\x * (r-2), y + p\y * (r-2),1, RGB(c\r*255, c\g*255, c\b*255))
  Next
EndProcedure


Time::Init()

TestNormalize(1200000*16)
  
Define r.i=250
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
; CursorPosition = 53
; FirstLine = 42
; Folding = --
; EnableXP
; EnableUnicode
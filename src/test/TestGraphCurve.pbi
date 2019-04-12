
Prototype.f FNGRAPHCURVE(*crv, x.f)

Structure GraphCurve_t
  *callback.FNGRAPHCURVE
  color.i
EndStructure

Procedure.f LinearCallback(*crv.GraphCurve_t, x.f)
  ProcedureReturn x
EndProcedure

Procedure.f Pow2Callback(*crv.GraphCurve_t, x.f)
  ProcedureReturn Pow(x, 2)
EndProcedure

Procedure.f Pow3Callback(*crv.GraphCurve_t, x.f)
  ProcedureReturn Pow(x, 3)
EndProcedure

Procedure.f LogCallback(*crv.GraphCurve_t, x.f)
  ProcedureReturn Log(x)
EndProcedure

Procedure.f ExpCallback(*crv.GraphCurve_t, x.f)
  ProcedureReturn Exp(x)
EndProcedure

Procedure.f SinCallback(*crv.GraphCurve_t, x.f)
  ProcedureReturn Sin(x)
EndProcedure

Procedure.f CosCallback(*crv.GraphCurve_t, x.f)
  ProcedureReturn Cos(x)
EndProcedure

Procedure.f TanCallback(*crv.GraphCurve_t, x.f)
  ProcedureReturn Cos(x)
EndProcedure

Procedure NewCurve(*callback.FNGRAPHCURVE, r.f=255, g.f=0, b.f=0)
  Define *Me.GraphCurve_t = AllocateMemory(SizeOf(GraphCurve_t))
  *Me\callback = *callback 
  *Me\color = RGBA(r,g,b,255)
  ProcedureReturn *Me
EndProcedure

Structure GraphView_t
  posX.f
  posY.f
  zoom.f
  window.i
  gadget.i
  down.b
  startX.f
  startY.f
  width.i
  height.i
  samples.i
  List *curves.GraphCurve_t()
EndStructure

Procedure NewView(width.i, height.i, name.s="Test Graph")
  Define *Me.GraphView_t = AllocateMemory(SizeOf(GraphView_t))
  InitializeStructure(*Me, GraphView_t)
  *Me\window = OpenWindow(#PB_Any, 0,0, width, height, name)
  *Me\gadget = CanvasGadget(#PB_Any, 0, 0, width, height,#PB_Canvas_Keyboard)
  *Me\width = width 
  *Me\height = height
  *Me\posX = width * 0.5
  *Me\posY = height * 0.5
  *Me\zoom = 10
  ProcedureReturn *Me
EndProcedure

Procedure DeleteView(*Me.GraphView_t)
  FreeGadget(*Me\gadget)
  ClearStructure(*Me, GraphView_t)
  FreeMemory(*Me)
EndProcedure


Procedure CanvasEvent(*Me.GraphView_t)
  Select EventType()
    Case #PB_EventType_MouseWheel
      Define wheel.i = GetGadgetAttribute(*Me\gadget, #PB_Canvas_WheelDelta)
      *Me\zoom + wheel * (*Me\zoom * 250 / 1000)

      
    Case #PB_EventType_LeftButtonDown
      *Me\down = #True
      *Me\startX = GetGadgetAttribute(*Me\gadget, #PB_Canvas_MouseX)
      *Me\startY = GetGadgetAttribute(*Me\gadget, #PB_Canvas_MouseY)
      
    Case #PB_EventType_LeftButtonUp
      *Me\down = #False
      
    Case #PB_EventType_MouseMove
      If *Me\down
        Define mx.d = GetGadgetAttribute(*Me\gadget, #PB_Canvas_MouseX)
        Define my.d = GetGadgetAttribute(*Me\gadget, #PB_Canvas_MouseY)
        
        *Me\posX + (mx - *Me\startX) ;* *Me\zoom
        *Me\posY + (my - *Me\startY); * *Me\zoom
        *Me\startX = mx
        *Me\startY = my
      EndIf 
      
  EndSelect
  
EndProcedure

Procedure DrawBG(*Me.GraphView_t)
  
  AddPathBox(0,0, *Me\width,*Me\height)
  VectorSourceColor(RGBA(128,128,128,255))
  FillPath()
  
  MovePathCursor(*Me\posX, 0)
  AddPathLine(0, *Me\height , #PB_Path_Relative)
  MovePathCursor(0, *Me\posY)
  AddPathLine(*Me\width , 0, #PB_Path_Relative)
  VectorSourceColor(RGBA(0,0,0,64))
  StrokePath(2)
    
  ;DrawVectorText("WIDTH : "+Str(*Me\width)
EndProcedure

Procedure DrawCurve(*Me.GraphView_t, *crv.GraphCurve_t, startT.f, endT.f, N.i)
  Define px.d, py.d, T.d
  Define nxt.f = (endT-startT)/N
  Debug "NEXT : "+StrF(nxt)
  px = startT
  py = *crv\callback(*crv, px)
  Define nbp = 0
  VectorSourceColor(*crv\color)
  If IsNAN(py)
    MovePathCursor(ConvertCoordinateX(px, 0,#PB_Coordinate_Device, #PB_Coordinate_Output),
                   ConvertCoordinateY(px, 0,#PB_Coordinate_Device, #PB_Coordinate_Output))
    nbp+1
  ElseIf IsInfinity(py)
    MovePathCursor(ConvertCoordinateX(px, 0,#PB_Coordinate_Device, #PB_Coordinate_Output),
                   0)
    nbp+1
  Else
    MovePathCursor(ConvertCoordinateX(px, py,#PB_Coordinate_Device, #PB_Coordinate_Output),
                   ConvertCoordinateY(px, py,#PB_Coordinate_Device, #PB_Coordinate_Output))
    nbp+1
  EndIf
  For i=0 To N-1
    px = startT + i * nxt
    py =  *crv\callback(*crv, px)
    If IsNAN(py) 
      continue
    ElseIf IsInfinity(py)
      AddPathLine(ConvertCoordinateX(px, 0,#PB_Coordinate_Device, #PB_Coordinate_Output),
                  0)
      nbp+1
    Else
      AddPathLine(ConvertCoordinateX(px, py,#PB_Coordinate_Device, #PB_Coordinate_Output),
                  ConvertCoordinateY(px, py,#PB_Coordinate_Device, #PB_Coordinate_Output))
      nbp+1
    EndIf
    
  Next
  If nbp > 2
    StrokePath(2/*Me\zoom)
  Else
    ResetPath()
  EndIf
  
  
EndProcedure

Procedure CanvasDraw(*Me.GraphView_t)
  StartVectorDrawing(CanvasVectorOutput(*Me\gadget))
  DrawBG(*Me)
  TranslateCoordinates(*Me\posX, *Me\posY)
  ScaleCoordinates(*Me\zoom, *Me\zoom)
  
  Define startT.f, endT.f
  Define invZoom.f = 1 / *Me\zoom
  startT = -*Me\posX * invZoom
  endT = (-*Me\posX + *Me\width) * invZoom
  ForEach *Me\curves()
    DrawCurve( *Me, *Me\curves(),startT, endT, *Me\width)
  Next
  
  StopVectorDrawing()
EndProcedure



Define *view.GraphView_t = NewView(800,600)


AddElement(*view\curves())
*view\curves() = NewCurve(@LinearCallback(), 255, 0, 0)
AddElement(*view\curves())
*view\curves() = NewCurve(@Pow2Callback(), 0, 255, 0)
AddElement(*view\curves())
*view\curves() = NewCurve(@SinCallback(), 0, 0, 255)
AddElement(*view\curves())
*view\curves() = NewCurve(@LogCallback(), 255, 255, 0)
AddElement(*view\curves())
*view\curves() = NewCurve(@ExpCallback(), 0, 255, 255)


Define e
Repeat
  e = WaitWindowEvent()
  Select e
    Case #PB_Event_Gadget
      Select EventGadget()
        Case *view\gadget
          CanvasEvent(*view)
          CanvasDraw(*view)
      EndSelect
      
  EndSelect
  
Until e = #PB_Event_CloseWindow


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 153
; FirstLine = 107
; Folding = ---
; EnableXP
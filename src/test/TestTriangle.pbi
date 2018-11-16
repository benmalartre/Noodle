XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Triangle.pbi"


Global window
Global canvas
Global elapsed.d
Global numTris.i
Global numHits.i
Global numRequests.i = 0

Procedure PolygonSoup(numTris.i)
  Define f.f
  Define sf.i = SizeOf(f)
	Define *positions = AllocateMemory(numTris * 9 * sf);
	Define offset = 0
	Define i, j
	For  i = 0 To numTris - 1
	  For j = 0 To 2
	    PokeF(*positions + offset * sf, Random(5000) /100 - 25)
	    PokeF(*positions + (offset+1) * sf, Random(5000) /100 - 25)
	    PokeF(*positions + (offset+2) * sf, Random(5000) /100 - 25)

			offset + 3
		Next
	Next
	
	ProcedureReturn *positions
EndProcedure

Procedure Draw()
  Define w = GadgetWidth(canvas)
  Define h = GadgetHeight(canvas)
  StartDrawing(CanvasOutput(canvas) )
  DrawingMode(#PB_2DDrawing_Default)
  Box(0,0,w, h, RGB(Random(255), Random(255), Random(255)))
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawText(20,20, "NUM TRIANGLES : "+Str(numTris))
  DrawText(20,40, "NUM REQUESTS : "+Str(numRequests))
  DrawText(20,60, "NUM HITS : "+Str(numHits))
  DrawText(20,80, "TOOK : "+StrD(elapsed))
  StopDrawing()
EndProcedure  


Procedure Compute()

  numTris = 1000000
  numHits = 0
	Define *soup = PolygonSoup(numTris)
	
	Define f.f
	Define sf.i = SizeOf(f)
	Define sp.i = 3 * sf
	Define center.Math::v3f32
	Define halfsize.Math::v3f32
	Vector3::Set(center, 0, 7, 0)
	Vector3::Set(halfsize,0.5, 0.5, 0.5)
	Protected *boxhalfsize.Math::v3f32 = halfsize

	
	Define.Math::v3f32 *a, *b, *c
	Define tri.Geometry::Triangle_t
	Define *tri.Geometry::Triangle_t = tri
	Define.f min,max,p0,p1,p2,rad,fex,fey,fez
	Define.Math::v3f32 v0, v1, v2
	Define.Math::v3f32 e0, e1, e2
	Define normal.Math::v3f32
	Define.Math::v3f32 vmin,vmax
	Define.f v
	Define box.Geometry::Box_t
	Vector3::SetFromOther(box\origin, center)
	Vector3::SetFromOther(box\extend, halfsize)
  
  Define offset = 0
  Define i, j
  
  Define startT.d = Time::Get()
  
  For i = 0 To numTris - 1
    tri\id = i
    tri\vertices[0] = offset
    tri\vertices[1] = offset + 1
    tri\vertices[2] = offset + 2
    
    *a = *soup + i * 12
    *b = *soup + i * 12 + 4
    *c = *soup + i * 12 + 8
    offset + 3
    
    If Triangle::Touch(box, *a, *b, *c)
		  numHits+1
		EndIf
	Next
	
	elapsed = Time::Get() - startT
	Draw()
	
	FreeMemory(*soup)
EndProcedure


Time::Init()
window = OpenWindow(#PB_Any, 0,0,800,600, "Test Triangle")
canvas = CanvasGadget(#PB_Any, 0,0,800,600, #PB_Canvas_Keyboard)
Compute()
Repeat
  e = WaitWindowEvent()
  If e = #PB_Event_Gadget 
    If EventType() = #PB_EventType_KeyDown
      Compute()
    EndIf
  EndIf
Until e = #PB_Event_CloseWindow

  

	



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 92
; FirstLine = 57
; Folding = -
; EnableXP
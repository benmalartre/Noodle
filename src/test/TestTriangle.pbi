XIncludeFile "../core/Application.pbi"
UseModule Math

Global window
Global canvas
Global elapsed.d
Global numTris.i
Global numHits.i
Global numRequests.i = 0

Procedure PolygonSoup(numTris.i)

  Define *positions.CArray::CArrayV3F32 = CArray::New(Types::#Type_V3F32)
  CARray::SetCount(*positions, numTris * 3)
	Define offset = 0
	Define i, j
	Define *p.Math::v3f32
	For  i = 0 To numTris - 1
	  
	  For j = 0 To 2
	    *p = CArray::GetValue(*positions, i *3 + j)
	    Vector3::RandomizeInPlace(*p,1)
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

  numTris = 10000000
  numHits = 0
	Define *soup.CArray::CArrayV3F32 = PolygonSoup(numTris)
	
	Define f.f
	Define sf.i = SizeOf(f)
	Define sp.i = 3 * sf
	Define center.Math::v3f32
	Define halfsize.Math::v3f32
	Vector3::Set(center, 0, 7, 0)
	Vector3::Set(halfsize,0.5, 0.5, 0.5)
	
	Define.Math::v3f32 *a, *b, *c
	Define box.Geometry::Box_t
	Vector3::SetFromOther(box\origin, center)
	Vector3::SetFromOther(box\extend, halfsize)
  
  Define offset = 0
  Define i, j
  
  Define startT.d = Time::Get()
  
  For i = 0 To numTris - 1

    *a = CArray::GetValue(*soup, i*3)
    *b = CArray::GetValue(*soup, i*3+1)
    *c = CArray::GetValue(*soup, i*3+2)
    
    If Triangle::Touch(box, *a, *b, *c)
		  numHits+1
		EndIf
	Next
	
	elapsed = Time::Get() - startT
	Draw()
	
	CArray::Delete(*soup)
EndProcedure


Time::Init()
window = OpenWindow(#PB_Any, 0,0,800,600, "Test Triangle")
canvas = CanvasGadget(#PB_Any, 0,0,800,600, #PB_Canvas_Keyboard)
Compute()
Define e
Repeat
  e = WaitWindowEvent()
  If e = #PB_Event_Gadget 
    If EventType() = #PB_EventType_KeyDown
      Compute()
    EndIf
  EndIf
Until e = #PB_Event_CloseWindow

  

	


; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 36
; FirstLine = 8
; Folding = -
; EnableXP
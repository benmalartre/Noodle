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
	Protected *boxhalfsize.Math::v3f32 = @halfsize

	
	Define.Math::v3f32 *a, *b, *c
	Define tri.Geometry::Triangle_t
	Define *tri.Geometry::Triangle_t = @tri
	Define.f min,max,p0,p1,p2,rad,fex,fey,fez
	Define.Math::v3f32 v0, v1, v2
	Define.Math::v3f32 e0, e1, e2
	Define normal.Math::v3f32
	Define.Math::v3f32 vmin,vmax
  Define.f v
  
  Define offset = 0
  Define i, j
  
  Define startT.d = Time::Get()
  
  For i = 0 To numTris - 1
    tri\id = i
    tri\vertices[0] = offset
    tri\vertices[1] = offset + 1
    tri\vertices[2] = offset + 2

    offset + 3
    
    If Triangle::Touch(@tri, *soup, @center, @halfsize)
		  numHits+1
		EndIf

    
;     ; This is the fastest branch on Sun 
;     ; move everything so that the boxcenter is in (0,0,0)
;    
;     v0\x = PeekF(*soup + tri\vertices[0] * 12) - center\x
;     v0\y = PeekF(*soup + tri\vertices[0] * 12 + 4) - center\y
;     v0\z = PeekF(*soup + tri\vertices[0] * 12 + 8)- center\z
;     
;     v1\x = PeekF(*soup + tri\vertices[1] * 12)- center\x
;     v1\y = PeekF(*soup + tri\vertices[1] * 12 + 4) - center\y
;     v1\z = PeekF(*soup + tri\vertices[1] * 12 + 8) - center\z
;     
;     v2\x = PeekF(*soup + tri\vertices[2] * 12) - center\x
;     v2\y = PeekF(*soup + tri\vertices[2] * 12 + 4) - center\y
;     v2\z = PeekF(*soup + tri\vertices[2] * 12 + 8) - center\z
;  
;     ; compute triangle edges
;     e0\x = v1\x - v0\x
;     e0\y = v1\y - v0\y
;     e0\z = v1\z - v0\z
;     
;     e1\x = v2\x - v1\x
;     e1\y = v2\y - v1\y
;     e1\z = v2\z - v1\z
;     
;     e2\x = v0\x - v2\x
;     e2\y = v0\y - v2\y
;     e2\z = v0\z - v2\z
;   
;     ;  test the 9 tests first (this was faster) 
;     fex = Abs(e0\x)
;     fey = Abs(e0\y)
;     fez = Abs(e0\z)
;     
;     Triangle::AXISTEST_X01(e0\z, e0\y, fez, fey)
;     Triangle::AXISTEST_Y02(e0\z, e0\x, fez, fex)
;     Triangle::AXISTEST_Z12(e0\y, e0\x, fey, fex)
;     
;     fex = Abs(e1\x)
;     fey = Abs(e1\y)
;     fez = Abs(e1\z)
;     
;     Triangle::AXISTEST_X01(e1\z, e1\y, fez, fey)
;     Triangle::AXISTEST_Y02(e1\z, e1\x, fez, fex)
;     Triangle::AXISTEST_Z0(e1\y, e1\x, fey, fex)
;     
;     fex = Abs(e2\x)
;     fey = Abs(e2\y)
;     fez = Abs(e2\z)
;     
;     Triangle::AXISTEST_X2(e2\z, e2\y, fez, fey)
;     Triangle::AXISTEST_Y1(e2\z, e2\x, fez, fex)
;     Triangle::AXISTEST_Z12(e2\y, e2\x, fey, fex)
;     
;     ; first test overlap in the {x,y,z}-directions
;     ; find min, max of the triangle each direction, And test For overlap in
;     ; that direction -- this is equivalent To testing a minimal AABB around
;     ; the triangle against the AABB    
;     ; test in X-direction
;     Triangle::FINDMINMAX(v0\x,v1\x,v2\x,min,max)
;     If(min>*boxhalfsize\x Or max<-*boxhalfsize\x) : Continue: EndIf
;     
;    ; test in Y-direction
;     Triangle::FINDMINMAX(v0\y,v1\y,v2\y,min,max)
;     If(min>*boxhalfsize\y Or max<-*boxhalfsize\y) : Continue : EndIf
;     
;     ; test in Z-direction
;     Triangle::FINDMINMAX(v0\z,v1\z,v2\z,min,max)
;     If(min>*boxhalfsize\z Or max<-*boxhalfsize\z) : Continue : EndIf
;     
;     ; test If the box intersects the plane of the triangle
;     ; compute plane equation of triangle: normal*x+d=0
;     normal\x = (e0\y * e1\z) - (e0\z * e1\y)
;     normal\y = (e0\z * e1\x) - (e0\x * e1\z)
;     normal\z = (e0\x * e1\y) - (e0\y * e1\x)
;     
;     v = v0\x
;     If normal\x > 0.0 :  vmin\x = -*boxhalfsize\x - v : vmax\x = *boxhalfsize\x - v : Else : vmin\x = *boxhalfsize\x -v : vmax\x = -*boxhalfsize\x - v : EndIf
;     v = v0\y
;     If normal\y > 0.0 :  vmin\y = -*boxhalfsize\y - v : vmax\y = *boxhalfsize\y - v : Else : vmin\y = *boxhalfsize\y -v : vmax\y = -*boxhalfsize\y - v : EndIf
;     v = v0\z
;     If normal\z > 0.0 :  vmin\z = -*boxhalfsize\z - v : vmax\z = *boxhalfsize\z - v : Else : vmin\z = *boxhalfsize\z -v : vmax\z = -*boxhalfsize\z - v : EndIf
;     
;     If normal\x * vmin\x + normal\y * vmin\y + normal\z * vmin\z > 0.0 : Continue : EndIf
;     If normal\x * vmax\x + normal\y * vmax\y + normal\z * vmax\z >= 0.0 :numHits+1 : EndIf
;     If Vector3::Dot(*normal, @vmin) > 0.0 : ProcedureReturn #False : EndIf
;     If Vector3::Dot(*normal, @vmax) >= 0.0 : ProcedureReturn #True : EndIf
;     ProcedureReturn #False

		
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
; CursorPosition = 60
; FirstLine = 54
; Folding = -
; EnableXP
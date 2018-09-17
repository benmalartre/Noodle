XIncludeFile "../core/Math.pbi"
XIncludeFile "Geometry.pbi"

; ======================================================
; TRIANGLE DECLARATION
; ======================================================
DeclareModule Triangle
  UseModule Math
  UseModule Geometry
  Macro FINDMINMAX(x0, x1, x2, min, max)
    min = 0
    max = 0
    If x1<min : min = x1 : EndIf
    If x1>max : max = x1 : EndIf
    If x2<min : min = x2 : EndIf
    If x2>max : max = x2 : EndIf
  EndMacro
  
  ; ======================== X-tests ========================
  Macro AXISTEST_X01(a, b, fa, fb)
    p0 = a*v0\y - b*v0\z
    p2 = a*v2\y - b*v2\z
    If p0 < p2 : min = p0 : max = p2 : 
    Else : min = p2 : max = p0 : EndIf
    rad = fa * *boxhalfsize\y + fb * *boxhalfsize\z
    If min > rad Or max <-rad  : ProcedureReturn #False : EndIf
  EndMacro
  
  Macro AXISTEST_X2(a, b, fa, fb)
    p0 = a*v0\y - b*v0\z
    p1 = a*v1\y - b*v1\z
    If p0 < p1 : min = p0 : max = p1 : 
    Else : min = p1 : max = p0 : EndIf
    rad = fa * *boxhalfsize\y + fb * *boxhalfsize\z
    If min > rad Or max <-rad  : ProcedureReturn #False : EndIf
  EndMacro
  
  ; ======================== Y-tests ========================
  Macro AXISTEST_Y02(a, b, fa, fb)
    p0 = -a*v0\x - b*v0\z
    p2 = -a*v2\x - b*v2\z
    If p0 < p2 : min = p0 : max = p2 : 
    Else : min = p2 : max = p0 : EndIf
    rad = fa * *boxhalfsize\x + fb * *boxhalfsize\z
    If min > rad Or max <-rad  : ProcedureReturn #False : EndIf
  EndMacro
  
  Macro AXISTEST_Y1(a, b, fa, fb)
    p0 = -a*v0\x - b*v0\z
    p1 = -a*v1\x - b*v1\z
    If p0 < p1 : min = p0 : max = p1 : 
    Else : min = p1 : max = p0 : EndIf
    rad = fa * *boxhalfsize\x + fb * *boxhalfsize\z
    If min > rad Or max <-rad  : ProcedureReturn #False : EndIf
  EndMacro
  
  ; ======================== Z-tests ========================
  Macro AXISTEST_Z12(a, b, fa, fb)
    p0 = a*v1\x - b*v1\y
    p2 = a*v2\x - b*v2\y
    If p0 < p2 : min = p0 : max = p2 : 
    Else : min = p2 : max = p0 : EndIf
    rad = fa * *boxhalfsize\x + fb * *boxhalfsize\y
    If min > rad Or max <-rad  : ProcedureReturn #False : EndIf
  EndMacro
  
  Macro AXISTEST_Z0(a, b, fa, fb)
    p0 = a*v0\x - b*v0\y
    p1 = a*v1\x - b*v1\y
    If p0 < p1 : min = p0 : max = p1 : 
    Else : min = p1 : max = p0 : EndIf
    rad = fa * *boxhalfsize\x + fb * *boxhalfsize\y
    If min > rad Or max <-rad  : ProcedureReturn #False : EndIf
  EndMacro
  
  Declare GetCenter(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *center.v3f32)
  Declare GetNormal(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *normal.v3f32)
  Declare ClosestPoint(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
  Declare.b Touch(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *center.v3f32, *boxhalfsize.v3f32)
  Declare.b PlaneBoxTest(*Me.Triangle_t, *normal.v3f32, *vert.v3f32, *maxbox.v3f32)
  Declare.b IsBoundary(*Me.Triangle_t)
EndDeclareModule


; ======================================================
; TRIANGLE IMPLEMENTATION
; ======================================================
Module Triangle
  UseModule Math
  UseModule Geometry
  
  ;------------------------------------------------------------------
  ; Get Center
  ;------------------------------------------------------------------
  Procedure GetCenter(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *center.v3f32)
    Vector3::Add(*center, CArray::GetValue(*positions, *Me\vertices[0]), CArray::GetValue(*positions, *Me\vertices[1]))
    Vector3::AddInPlace(*center, CArray::GetValue(*positions, *Me\vertices[2]))
    Vector3::ScaleInPlace(*center,1.0/3.0)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Get Normal
  ;------------------------------------------------------------------
  Procedure GetNormal(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *normal.v3f32)
    ; get triangle edges
    Protected AB.v3f32, AC.v3f32
    Vector3::Sub(@AB, CArray::GetValue(*positions, *Me\vertices[1]), CArray::GetValue(*positions, *Me\vertices[0]))
    Vector3::Sub(@AC, CArray::GetValue(*positions, *Me\vertices[2]), CArray::GetValue(*positions, *Me\vertices[0]))
    ; cross product
    Vector3::Cross(*normal, @AB, @AC)
    ; normalize
    Vector3::NormalizeInPlace(*normal)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Closest Point
  ;------------------------------------------------------------------
  Procedure ClosestPoint(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
    Define.v3f32 *A, *B, *C
    *A = CArray::GetValue(*positions, *Me\vertices[0])
    *B = CArray::GetValue(*positions, *Me\vertices[1])
    *C = CArray::GetValue(*positions, *Me\vertices[2])
    Protected edge0.v3f32
    Protected edge1.v3f32
    
    Vector3::Sub(@edge0, *B, *A)
    Vector3::Sub(@edge1, *C, *A)
    
    Protected v0.v3f32
    Vector3::Sub(@v0, *A, *P)
    
    Define.f a,b,c,d,e
    a = Vector3::Dot(@edge0, @edge0)
    b = Vector3::Dot(@edge0, @edge1)
    c = Vector3::Dot(@edge1, @edge1)
    d = Vector3::Dot(@edge0, @v0)
    e = Vector3::Dot(@edge1, @v0)
    
    Define.f det, s, t
    det = a*c - b*b
    s = b*e - c*d
    t = b*d - a*e
    
    If ( s + t < det )
      If ( s < 0.0)
        If ( t < 0.0 )
          If ( d < 0.0 )
            s = -d/a
            CLAMP( s, 0.0, 1.0 )
            t = 0.0
          Else
            s = 0.0
            t = -e/c
            CLAMP( t, 0.0, 1.0 )
          EndIf
        Else
          s = 0.0
          t = -e/c
          CLAMP( t, 0.0, 1.0 )
        EndIf 
      ElseIf ( t < 0.0 )
        s = -d/a
        CLAMP( s, 0.0, 1.0 )
        t = 0.0
      Else
        Define invDet.f = 1.0 / det
        s * invDet
        t * invDet
      EndIf
   Else
    If ( s < 0.0 )
      Define tmp0.f = b+d
      Define tmp1.f = c+e
      If ( tmp1 > tmp0 )
        Define numer.f = tmp1 - tmp0
        Define denom.f = a-2*b+c
        s = numer/denom
        CLAMP( s, 0.0, 1.0 )
        t = 1-s
      Else
        t = -e/c
        CLAMP( t, 0.0, 1.0 )
        s = 0.0
      EndIf
    ElseIf ( t < 0.0 )
      If ( a+d > b+e )
        Define numer.f = c+e-b-d
        Define denom.f = a-2*b+c
        s = numer/denom
        CLAMP( s, 0.0, 1.0)
        t = 1-s
      Else
        s = -e/c
        CLAMP( s, 0.0, 1.0 )
        t = 0.0
      EndIf
    Else
      Define numer.f = c+e-b-d
      Define denom.f = a-2*b+c
      s = numer/denom
      CLAMP( s, 0.0, 1.0 )
      t = 1.0 - s
    EndIf
  EndIf
  
  Vector3::SetFromOther(*closest, *A)
  Vector3::ScaleInPlace(@edge0, s)
  Vector3::ScaleInPlace(@edge1, t)
  Vector3::AddInPlace(*closest, @edge0)
  Vector3::AddInPlace(*closest, @edge1)
  
  *uvw\y = s
  *uvw\z = t
  *uvw\x = 1.0-v-w

EndProcedure

  ;------------------------------------------------------------------
  ; Touch Box
  ;------------------------------------------------------------------
  Procedure.b Touch(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *center.v3f32, *boxhalfsize.v3f32)
     
;      use separating axis theorem To test overlap between triangle And box
;      need To test For overlap in these directions:
;      
;      1) the {x,y,z}-directions (actually, since we use the AABB of the triangle
;      we do Not even need To test these)
;      2) normal of the triangle
;      3) crossproduct(edge from triangle, {x,y,z}-direction)
;      
;      this gives 3x3=9 more tests
     
    
    Define.f min,max,p0,p1,p2,rad,fex,fey,fez
    
    ; This is the fastest branch on Sun 
    ; move everything so that the boxcenter is in (0,0,0)
    Define.v3f32 v0, v1, v2
    Vector3::Sub(@v0, CArray::GetValue(*positions, *Me\vertices[0]), *center)
    Vector3::Sub(@v1, CArray::GetValue(*positions, *Me\vertices[1]), *center)
    Vector3::Sub(@v2, CArray::GetValue(*positions, *Me\vertices[2]), *center)
 
    ; compute triangle edges
    Define.v3f32 e0, e1, e2
    Vector3::Sub(@e0, @v0, @v1)
    Vector3::Sub(@e1, @v1, @v2)
    Vector3::Sub(@e2, @v2, @v0)
    
    ;  test the 9 tests first (this was faster) 
    fex = Abs(e0\x)
    fey = Abs(e0\y)
    fez = Abs(e0\z)
    
    AXISTEST_X01(e0\z, e0\y, fez, fey)
    AXISTEST_Y02(e0\z, e0\x, fez, fex)
    AXISTEST_Z12(e0\y, e0\x, fey, fex)
    
    fex = Abs(e1\x)
    fey = Abs(e1\y)
    fez = Abs(e1\z)
    
    AXISTEST_X01(e1\z, e1\y, fez, fey)
    AXISTEST_Y02(e1\z, e1\x, fez, fex)
    AXISTEST_Z0(e1\y, e1\x, fey, fex)
    
    fex = Abs(e2\x)
    fey = Abs(e2\y)
    fez = Abs(e2\z)
    
    AXISTEST_X2(e2\z, e2\y, fez, fey)
    AXISTEST_Y1(e2\z, e2\x, fez, fex)
    AXISTEST_Z12(e2\y, e2\x, fey, fex)
    
;      first test overlap in the {x,y,z}-directions
;      find min, max of the triangle each direction, And test For overlap in
;      that direction -- this is equivalent To testing a minimal AABB around
;      the triangle against the AABB
    
    ; test in X-direction
    FINDMINMAX(v0\x,v1\x,v2\x,min,max)
    If min>*boxhalfsize\x Or max<-*boxhalfsize\x : ProcedureReturn #False : EndIf
    
    ; test in Y-direction
    FINDMINMAX(v0\y,v1\y,v2\y,min,max);
    If min>*boxhalfsize\y Or max<-*boxhalfsize\y :  ProcedureReturn #False : EndIf
    
    ; test in Z-direction
    FINDMINMAX(v0\z,v1\z,v2\z,min,max)
    If min>*boxhalfsize\z Or max<-*boxhalfsize\z :  ProcedureReturn #False : EndIf
    
    ; test If the box intersects the plane of the triangle
    ; compute plane equation of triangle: normal*x+d=0
    Protected normal.v3f32
    Vector3::Cross(@normal, @e0, @e1)
    
    ; -NJMP- (line removed here)
    If Not PlaneBoxTest(*Me, @normal, @v0, *boxhalfsize) : ProcedureReturn #False : EndIf;	// -NJMP-
    
    ; box And triangle overlaps
    ProcedureReturn #True
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Plane Box Test
  ;------------------------------------------------------------------
  Procedure.b PlaneBoxTest(*Me.Triangle_t,*normal.v3f32, *vert.v3f32, *maxbox.v3f32)
    Protected q.i
    
    Protected vmin.v3f32,vmax.v3f32
    Protected v.f
    
    v = *vert\x
    If *normal\x>0.0 : vmin\x=-*maxbox\x - v : vmax\x=*maxbox\x - v : Else : vmin\x=*maxbox\x - v : vmax\x=-*maxbox\x - v : EndIf
    v = *vert\y
    If *normal\y>0.0 : vmin\y=-*maxbox\y - v : vmax\y=*maxbox\y - v : Else : vmin\y=*maxbox\y - v : vmax\y=-*maxbox\y - v : EndIf
    v = *vert\z
    If *normal\z>0.0 : vmin\z=-*maxbox\z - v : vmax\z=*maxbox\z - v : Else : vmin\z=*maxbox\z - v : vmax\z=-*maxbox\z - v : EndIf
    
    If Vector3::Dot(*normal, @vmin) > 0.0 : ProcedureReturn #False : EndIf
    If Vector3::Dot(*normal, @vmax) >= 0.0 : ProcedureReturn #True : EndIf
    ProcedureReturn #False

  EndProcedure
  
  ;------------------------------------------------------------------
  ; Is Boundary
  ;------------------------------------------------------------------
  Procedure.b IsBoundary(*Me.Triangle_t) 
    ProcedureReturn *Me\boundary
  EndProcedure
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 77
; FirstLine = 51
; Folding = ---
; EnableXP
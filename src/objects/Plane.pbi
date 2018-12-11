XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"


; ============================================================================
;  PLANE MODULE DECLARATION
; ============================================================================
DeclareModule Plane
  UseModule Math
  UseModule Geometry
  
  Declare Set(*plane.Plane_t, *normal.v3f32, *point.v3f32)
  Declare SetOrig(*plane.Plane_t,*point.v3f32)
  Declare SetNormal(*plane.Plane_t,*normal.v3f32)
  Declare SetOrigFromValues(*plane.Plane_t,x.f, y.f, z.f)
  Declare SetNormalFromValues(*plane.Plane_t,x.f,y.f,z.f)
  Declare SetFromThreePoints(*plane.Plane_t, *a.v3f32, *b.v3f32, *c.v3f32)
  Declare Transform(*plane.Plane_t, *m.m4f32)
  Declare.b IntersectPositiveHalfSpace(*plane.Plane_t, *box.Box_t)
EndDeclareModule

; ============================================================================
;  PLANE MODULE IMPLEMENTATION
; ============================================================================
Module Plane
  UseModule Math
  UseModule Geometry
  
  Procedure Set(*plane.Plane_t, *normal.v3f32, *point.v3f32)
    Vector3::Normalize(*plane\normal, *normal)
    *plane\distance = Vector3::Dot(*plane\normal, *point)
  EndProcedure
  
  Procedure SetOrig(*plane.Plane_t,*point.v3f32)
    *plane\distance = Vector3::Dot(*plane\normal, *point)
  EndProcedure
  
  Procedure SetNormal(*plane.Plane_t, *normal.v3f32)
    Vector3::Normalize(*plane\normal, *normal)
  EndProcedure
  
  Procedure SetOrigFromValues(*plane.Plane_t, x.f, y.f, z.f)
    Define p.v3f32
    Vector3::Set(p, x, y, z)
    *plane\distance = Vector3::Dot(*plane\normal, p)
  EndProcedure
  
  Procedure SetNormalFromValues(*plane.Plane_t, x.f, y.f, z.f)
    Vector3::Set(*plane\normal, x, y, z)
    Vector3::NormalizeInPlace(*plane\normal)
  EndProcedure
  
  Procedure SetFromThreePoints(*plane.Plane_t, *a.v3f32, *b.v3f32, *c.v3f32)
    Define.v3f32 ab, ac
    Vector3::Sub(ab, *a, *b)
    Vector3::Sub(ac, *a, *c)
    Vector3::Cross(*plane\normal, ab, ac)
    Vector3::NormalizeInPlace(*plane\normal)
    *plane\distance = Vector3::Dot(*plane\normal, *a)
  EndProcedure
  
  Procedure Transform(*plane.Plane_t, *m.m4f32)
    Define pointOnPlane.v3f32
    Vector3::Multiply(pointOnPlane, *plane\normal, *plane\normal)
    
    Define adjoint.m4f32
    Matrix4::Inverse(adjoint, *m)
    Matrix4::TransposeInPlace(adjoint)
    
;     // Compute the point on the plane along the normal from the origin.
;     Vector3 pointOnPlane = _normal * _normal;
; 
;     // Transform the plane normal by the adjoint of the matrix To get
;     // the new normal.  The adjoint (inverse transpose) is used To
;     // multiply normals so they are Not scaled incorrectly.
;     Matrix4 adjoint = matrix.inverse();
;     adjoint.transposeInPlace();
;     //_normal = adjoint.TransformDir(_normal).GetNormalized();
;     _normal = _normal.transformDir(adjoint);
;     _normal.normalizeInPlace();
; 
;     // Transform the point on the plane by the matrix.
;     //pointOnPlane = matrix.Transform(pointOnPlane);
;     pointOnPlane = pointOnPlane.transform(matrix);
; 
;     // The new distance is the projected distance of the vector To the
;     // transformed point onto the (unit) transformed normal. This is
;     // just a dot product.
;     _distance = pointOnPlane.dot(_normal);
; 
;     Return *this;
  EndProcedure
  
  Procedure.b IntersectPositiveHalfSpace(*plane.Plane_t, *box.Box_t)
  EndProcedure
  
EndModule
  

; bool Plane::intersectsPositiveHalfSpace(const Range3 &box) const
; {
;     If (box.isEmpty())
; 	Return false;
;     
;     // Test each vertex of the box against the positive half
;     // space. Since the box is aligned With the coordinate axes, we
;     // can test For a quick accept/reject at each stage.
; 
; // This Macro tests one corner using the given inequality operators.
; #define CORNER_TEST(X, Y, Z, XOP, YOP, ZOP)                               \
;     If (X + Y + Z >= _distance)                                               \
;         Return true;                                                          \
;     Else If (_normal[0] XOP 0.0 && _normal[1] YOP 0.0 && _normal[2] ZOP 0.0)  \
;         Return false
; 
;     // The sum of these values is GfDot(box.GetMin(), _normal)
;     float xmin = _normal[0] * box.getMin()[0];
;     float ymin = _normal[1] * box.getMin()[1];
;     float zmin = _normal[2] * box.getMin()[2];
; 
;     // We can do the all-min corner test right now.
;     CORNER_TEST(xmin, ymin, zmin, <=, <=, <=);
; 
;     // The sum of these values is GfDot(box.GetMax(), _normal)
;     float xmax = _normal[0] * box.getMax()[0];
;     float ymax = _normal[1] * box.getMax()[1];
;     float zmax = _normal[2] * box.getMax()[2];
; 
;     // Do the other 7 corner tests.
;     CORNER_TEST(xmax, ymax, zmax, >=, >=, >=);
;     CORNER_TEST(xmin, ymin, zmax, <=, <=, >=);
;     CORNER_TEST(xmin, ymax, zmin, <=, >=, <=);
;     CORNER_TEST(xmin, ymax, zmax, <=, >=, >=);
;     CORNER_TEST(xmax, ymin, zmin, >=, <=, <=);
;     CORNER_TEST(xmax, ymin, zmax, >=, <=, >=);
;     CORNER_TEST(xmax, ymax, zmin, >=, >=, <=);
; 
;     Return false;
; 
; #undef CORNER_TEST
; }
; 
; } // End namespace BOB
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 55
; FirstLine = 50
; Folding = --
; EnableXP
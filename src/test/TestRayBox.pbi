XIncludeFile "../core/math.pbi"
XIncludeFile "../objects/Ray.pbi"
XIncludeFile "../objects/Geometry.pbi"


UseModule Math
Define ray.Geometry::Ray_t
Define box.Geometry::Box_t

Vector3::Set(ray\origin, 3,5,2)
Vector3::Set(ray\direction, 0,-1,0)

Vector3::Set(box\extend,1,1,1)

Debug Ray::BoxIntersection(ray, box)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 12
; EnableXP
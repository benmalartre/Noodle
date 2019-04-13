XIncludeFile "../core/Math.pbi"
XIncludeFile "Polymesh.pbi"

DeclareModule Sampler
  Enumeration
    #Sample_Points
    #Sample_Edges
    #Sample_Polygons
    #Sample_Triangles
    #Sample_Barycentric
    #Sample_Poisson
  EndEnumeration
  
  Declare SamplePolymesh(*mesh.Geometry::PolymeshGeometry_t,*locations.CArray::CArrayLocation, nb.i,seed)
EndDeclareModule

Module Sampler
  UseModule Math
  ;-----------------------------------------------------
  ; Sample Geometry
  ;-----------------------------------------------------
  Procedure SamplePolymesh( *mesh.Geometry::PolymeshGeometry_t,*locations.CArray::CArrayLocation, nb.i,seed.i)
    Define *object3D.Object3D::Object3D_t = *mesh\parent
    *locations\geometry = *mesh
    *locations\transform = *object3D\globalT
    
    CArray::SetCount(*locations, nb)
    
    Protected i
    Protected tid
    Define.v3f32 *a,*b,*c
    Define.f u,v
    Define.v3f32 p,sum,scl
    Define color.c4f32
    Define s.f
    Define a,b,c
    Define.c4f32 *ca,*cb,*cc
    Define uvw.v3f32
    
    Protected *parent.Object3D::Object3D_t = *mesh\parent
    Protected *loc.Geometry::Location_t 
    CArray::SetCount(*locations, nb)
    
    RandomSeed(seed)
    For i=0 To nb-1
      tid = Random(*mesh\nbtriangles-1)
      a = CArray::GetValueL(*mesh\a_triangleindices,tid*3)
      b = CArray::GetValueL(*mesh\a_triangleindices,tid*3+1)
      c = CArray::GetValueL(*mesh\a_triangleindices,tid*3+2)
      
      *a = CArray::GetValue(*mesh\a_positions,a)
      *b = CArray::GetValue(*mesh\a_positions,b)
      *c = CArray::GetValue(*mesh\a_positions,c)
      
      
      u = Random(1000)*0.001
      v = Random(1000)*0.001
      If u+v>1
        u = 1-u
        v = 1-v
      EndIf
      
      Vector3::Set(sum,0,0,0)
      Vector3::Scale(p,*a,u)
      Vector3::AddInPlace(sum,p)
      Vector3::Scale(p, *b,v)
      Vector3::AddInPlace(sum,p)
      Vector3::Scale(p, *c,1-(u+v))
      Vector3::AddInPlace(sum,p)
      
      s = 1;Random(10)*0.1
      Vector3::Set(scl,s,s,s)
      
      *loc = CArray::GetValue(*locations, i)
      Location::Init(*loc, *mesh, *parent\globalT, tid, u, v, 1-(u+v))
      
      Vector3::Set(*loc\uvw, u, v, 1-(u+v))
      *loc\tid = tid
      Vector3::SetFromOther(*loc\p,sum)      
;       Vector3::MulByMatrix4InPlace(*loc\p, *loc\t\m)
      
      *a = CArray::GetValue(*mesh\a_pointnormals,a)
      *b = CArray::GetValue(*mesh\a_pointnormals,b)
      *c = CArray::GetValue(*mesh\a_pointnormals,c)
      Vector3::Set(sum,0,0,0)
      Vector3::Scale(p,*a,u)
      Vector3::AddInPlace(sum,p)
      Vector3::Scale(p, *b,v)
      Vector3::AddInPlace(sum,p)
      Vector3::Scale(p, *c,1-(u+v))
      Vector3::AddInPlace(sum,p)
      
      Vector3::SetFromOther(*loc\n,sum)
;       Vector3::MulByMatrix4InPlace(*loc\n, *loc\t\m)
      
      *ca = CArray::GetValue(*mesh\a_colors,tid*3)
      *cb = CArray::GetValue(*mesh\a_colors,tid*3+1)
      *cb = CArray::GetValue(*mesh\a_colors,tid*3+1)
      ;     Vector4_Set(@color,*ca\r,*ca\g,*ca\b,*ca\a)
      Color::Set(color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1.0)
      ;*pc\a_color\SetValue(i,@color)
      Color::SetFromOther(*loc\c,color)
    Next
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 101
; FirstLine = 45
; Folding = -
; EnableXP
; EnableUnicode
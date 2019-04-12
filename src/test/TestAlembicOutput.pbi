XIncludeFile "../libs/Booze.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../objects/PointCloud.pbi"
EnableExplicit

; NewList objects.Alembic::OObject()
; Define *model.Object3D::Object3D_t = Model::New("Toto")
; Define *parent.Object3D::Object3D_t = *model
; For i = 0 To 32
;   Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Mesh"+Str(i), Shape::#SHAPE_BUNNY)
;   Object3D::AddChild(*parent, *bunny)
;   *parent=*bunny
; Next

Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_SPHERE)
Define *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
Define *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)

Define *cloud.PointCloud::PointCloud_t = PointCloud::New("Cloud", 32)

Procedure AddObjectsRecursively(archive.Alembic::OArchive, object.Alembic::OObject)
  Define c
  Define *obj.Object3D::Object3D_t = object\GetCustomData()
  Define child.Alembic::OObject
  ForEach *obj\children()
    Define *child.Object3D::Object3D_t = *obj\children()
    Select *child\type
      Case Object3D::#Polymesh
        child = archive\AddObject(object, *child\name, Alembic::#ABC_OBJECT_POLYMESH, *child)
        AddObjectsRecursively(archive, child)
        
      Case Object3D::#PointCloud
        child = archive\AddObject(object, *child\name, Alembic::#ABC_OBJECT_POINTS, *child)
        AddObjectsRecursively(archive, child)
        
      Case Object3D::#Curve
        child = archive\AddObject(object, *child\name, Alembic::#ABC_OBJECT_CURVE, *child)
        AddObjectsRecursively(archive, child)
        
      Case Object3D::#Camera
        child = archive\AddObject(object, *child\name, Alembic::#ABC_OBJECT_CAMERA, *child)
        AddObjectsRecursively(archive, child)
        
      Case Object3D::#Light
        child = archive\AddObject(object, *child\name, Alembic::#ABC_OBJECT_LIGHT, *child)
        AddObjectsRecursively(archive, child)
        
      Case Object3D::#Model
        child = archive\AddObject(object, *child\name, Alembic::#ABC_OBJECT_XFORM, *child)
        AddObjectsRecursively(archive, child)
        
      Case Object3D::#Locator
        child = archive\AddObject(object, *child\name, Alembic::#ABC_OBJECT_XFORM, *child)
        AddObjectsRecursively(archive, child)
    EndSelect   
  Next
EndProcedure

Define numFrames = 12, i
Dim frames.f(numFrames)
For i=0 To numFrames-1 :  frames(i)=i : Next

Define job.Alembic::OWriteJob = Alembic::newWriteJob("E:\Projects\RnD\Noodle\abc\Output.abc",@frames(0), numFrames)
job\SetFrameRate(24)

Define archive.Alembic::OArchive = job\GetArchive()
Debug archive\GetRoot()
Define xfo0.Alembic::OXform = archive\AddObject(archive\GetRoot(), *bunny\name, Alembic::#ABC_OBJECT_XFORM, *bunny)
Define obj0.Alembic::OPolymesh = archive\AddObject( xfo0, *bunny\name+"Shape", Alembic::#ABC_OBJECT_POLYMESH, *bunny)
Debug xfo0
Define xfo1.Alembic::OXform = archive\AddObject(xfo0, *torus\name, Alembic::#ABC_OBJECT_XFORM, *torus)
Define obj1.Alembic::OPolymesh = archive\AddObject( xfo1, *torus\name+"Shape", Alembic::#ABC_OBJECT_POLYMESH, *torus)
Debug xfo1
Define xfo2.Alembic::OXform = archive\AddObject(archive\GetRoot(), *cloud\name, Alembic::#ABC_OBJECT_XFORM, *cloud)
; Define obj2.Alembic::OPolymesh = archive\AddObject( xfo2, *teapot\name+Str(2)+"Shape", Alembic::#ABC_OBJECT_POLYMESH, *teapot)
Define obj2.Alembic::OPoints = archive\AddObject( xfo2, *cloud\name+"Shape", Alembic::#ABC_OBJECT_POINTS, *cloud)
Debug xfo2

Define *geom0.Geometry::PolymeshGeometry_t = *bunny\geom
Define *geom1.Geometry::PolymeshGeometry_t = *torus\geom
Define *geom2.Geometry::PolymeshGeometry_t = *teapot\geom
Define *geom3.Geometry::PointCloudGeometry_t = *cloud\geom

Define m.Math::m4f32
Matrix4::SetIdentity(m)
Define t.Math::v3f32
Vector3::Set(t,1,2,3)
Matrix4::SetTranslation(m, t)


Procedure Transform(xfo.Alembic::OXform, s.f=0.25)
  Define m.Math::m4f32
  Matrix4::SetIdentity(m)
  Define v.Math::v3f32
  Vector3::RandomizeInPlace(v,s)
  Matrix4::SetTranslation(m, v)
  xfo\SetTransform(m)
EndProcedure

Procedure Deform(*geom.Geometry::PolymeshGeometry_t, s.f)
  Define i
  Define *p.Math::v3f32
  For i=0 To CArray::GetCount(*geom\a_positions)-1  
    *p = CArray::GetValue(*geom\a_positions, i)
    *p\x + Math::Random_0_1() * s
    *p\y + Math::Random_0_1() * s
    *p\z + Math::Random_0_1() * s
  Next
  
EndProcedure

Macro MACRO_DEFORM(INDEX)
  Deform(*geom#INDEX, 0.2)
  Memory::UnshiftAlign(*geom#INDEX\a_positions\data, *geom#INDEX\nbpoints, 16, 12)
  obj#INDEX\SetPositions(*geom#INDEX\a_positions\data, *geom#INDEX\nbpoints)
  Memory::ShiftAlign(*geom#INDEX\a_positions\data, *geom#INDEX\nbpoints, 12, 16)
EndMacro
   

CompilerIf #USE_SSE
  Memory::UnshiftAlign(*geom0\a_positions\data, *geom0\nbpoints, 16, 12)
  Memory::UnshiftAlign(*geom1\a_positions\data, *geom1\nbpoints, 16, 12)
  Memory::UnshiftAlign(*geom3\a_positions\data, *geom3\nbpoints, 16, 12)
   obj0\Set(*geom0\a_positions\data, *geom0\nbpoints, *geom0\a_faceindices\data, *geom0\a_facecount\data, *geom0\nbpolygons)
   obj1\Set(*geom1\a_positions\data, *geom1\nbpoints, *geom1\a_faceindices\data, *geom1\a_facecount\data, *geom1\nbpolygons)
   obj2\Set(*geom3\a_positions\data, *geom3\a_indices, *geom3\nbpoints)
   Memory::ShiftAlign(*geom0\a_positions\data, *geom0\nbpoints, 12, 16)
   Memory::ShiftAlign(*geom1\a_positions\data, *geom1\nbpoints, 12, 16)
   Memory::ShiftAlign(*geom3\a_positions\data, *geom3\nbpoints, 12, 16)

     Transform(xfo0)
     Transform(xfo1)
     Transform(xfo2)
     
     MACRO_DEFORM(0)
     MACRO_DEFORM(1)
     MACRO_DEFORM(2)
     

   job\Save(0)
;    For i = 1 To numFrames - 1
;      Transform(xfo0)
;      Transform(xfo1)
;      Transform(xfo2)
;      
;      job\Save(i)
;    Next
;    
;      
CompilerElse
;   obj0\Set2(*geom0\a_positions\data, *geom0\nbpoints, *geom0\a_faceindices\data, *geom0\a_facecount\data, *geom0\nbpolygons)
;    obj1\Set2(*geom1\a_positions\data, *geom1\nbpoints, *geom1\a_faceindices\data, *geom1\a_facecount\data, *geom1\nbpolygons)
;    obj2\Set2(*geom2\a_positions\data, *geom2\nbpoints, *geom2\a_faceindices\data, *geom2\a_facecount\data, *geom2\nbpolygons)
 CompilerEndIf
;  
;  
;    
; 
; 
; ; Alembic::deleteOArchive(archive)
; 
; ; ; AddObjectsRecursively(archive, obj)
; ; ; 
; ; ; Debug archive\GetNumObjects()
Alembic::deleteWriteJob(job)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 140
; FirstLine = 99
; Folding = -
; EnableXP
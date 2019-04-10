XIncludeFile "../libs/Booze.pbi"
XIncludeFile "../objects/Object3D.pbi"
EnableExplicit

; NewList objects.Alembic::OObject()
; Define *model.Object3D::Object3D_t = Model::New("Toto")
; Define *parent.Object3D::Object3D_t = *model
; For i = 0 To 32
;   Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Mesh"+Str(i), Shape::#SHAPE_BUNNY)
;   Object3D::AddChild(*parent, *mesh)
;   *parent=*mesh
; Next

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Mesh",Shape::#SHAPE_BUNNY)

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

Define job.Alembic::OWriteJob = Alembic::newWriteJob("E:\Projects\RnD\Noodle\abc\Output.abc",#Null, 0)
job\SetFrameRate(24)

Define archive.Alembic::OArchive = job\GetArchive()

Define xfo0.Alembic::OXform = archive\AddObject(archive\GetRoot(), *mesh\name+Str(0), Alembic::#ABC_OBJECT_XFORM, *mesh)
Define obj0.Alembic::OPolymesh = archive\AddObject( xfo0, *mesh\name+Str(0)+"Shape", Alembic::#ABC_OBJECT_POLYMESH, *mesh)
Define xfo1.Alembic::OXform = archive\AddObject(xfo0, *mesh\name+Str(1), Alembic::#ABC_OBJECT_XFORM, *mesh)
Define obj1.Alembic::OPolymesh = archive\AddObject( xfo1, *mesh\name+Str(1)+"Shape", Alembic::#ABC_OBJECT_POLYMESH, *mesh)
Define xfo2.Alembic::OXform = archive\AddObject(xfo1, *mesh\name+Str(2), Alembic::#ABC_OBJECT_XFORM, *mesh)
Define obj2.Alembic::OPolymesh = archive\AddObject( xfo2, *mesh\name+Str(2)+"Shape", Alembic::#ABC_OBJECT_POLYMESH, *mesh)


Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
Define m.Math::m4f32
Matrix4::SetIdentity(m)
Define t.Math::v3f32
Vector3::Set(t,1,2,3)
Matrix4::SetTranslation(m, t)

CompilerIf #USE_SSE
   Memory::UnshiftAlign(*geom\a_positions\data, *geom\nbpoints, 16, 12)
   obj0\Set2(*geom\a_positions\data, *geom\nbpoints, *geom\a_faceindices\data, *geom\a_facecount\data, *geom\nbpolygons)
   obj1\Set2(*geom\a_positions\data, *geom\nbpoints, *geom\a_faceindices\data, *geom\a_facecount\data, *geom\nbpolygons)
   obj2\Set2(*geom\a_positions\data, *geom\nbpoints, *geom\a_faceindices\data, *geom\a_facecount\data, *geom\nbpolygons)
  Memory::ShiftAlign(*geom\a_positions\data, *geom\nbpoints, 12, 16)
CompilerElse
  obj0\Set2(*geom\a_positions\data, *geom\nbpoints, *geom\a_faceindices\data, *geom\a_facecount\data, *geom\nbpolygons)
  obj1\Set2(*geom\a_positions\data, *geom\nbpoints, *geom\a_faceindices\data, *geom\a_facecount\data, *geom\nbpolygons)
  obj2\Set2(*geom\a_positions\data, *geom\nbpoints, *geom\a_faceindices\data, *geom\a_facecount\data, *geom\nbpolygons)
CompilerEndIf

job\Save(0)
; Alembic::deleteOArchive(archive)

; ; AddObjectsRecursively(archive, obj)
; ; 
; ; Debug archive\GetNumObjects()
Alembic::deleteWriteJob(job)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 82
; FirstLine = 33
; Folding = -
; EnableXP
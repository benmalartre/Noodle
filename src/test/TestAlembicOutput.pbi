XIncludeFile "../libs/Booze.pbi"
XIncludeFile "../objects/Object3D.pbi"

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

Define job.Alembic::IWriteJob = Alembic::newWriteJob("E:\Projects\RnD\Noodle\abc\Output.abc",#Null, 0)
Debug PeekS(job\GetFileName(), -1, #PB_UTF8)
job\SetFrameRate(24)
Define archive.Alembic::OArchive = job\GetArchive()

Define obj.Alembic::OPolymesh = archive\AddObject(archive\GetTop(), *mesh\name, Alembic::#ABC_OBJECT_POLYMESH, *mesh)
Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
Debug *geom\a_positions\data
Debug *geom\nbpoints
obj\SetPositions(*geom\a_positions\data, *geom\nbpoints)
obj\SetDescription(*geom\a_faceindices\data, *geom\a_facecount\data, *geom\nbpolygons)
obj\Save(0)

; AddObjectsRecursively(archive, obj)

Debug archive\GetNumObjects()


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 64
; Folding = +
; EnableXP
XIncludeFile "../libs/Booze.pbi"

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Mesh", Shape::#SHAPE_BUNNY)


Define job.Alembic::IWriteJob = Alembic::newWriteJob("E:\Projects\RnD\Noodle\abc\Output.abc",#Null, 0)
Debug PeekS(job\GetFileName(), -1, #PB_UTF8)
Define archive.Alembic::OArchive = job\GetArchive()
Debug "ARCHIVE : "+Str(archive)
Debug "VALID   : "+Str(archive\IsValid())

; archive\GetIdentifier(i)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 5
; EnableXP
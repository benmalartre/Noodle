XIncludeFile "../core/Application.pbi"

Define *obj.Polymesh::Polymesh_t = Polymesh::New("TOTO", Shape::#SHPAE_SPHERE)

Debug *obj

Polymesh::Delete(*obj)
; IDE Options = PureBasic 5.62 (Windows - x64)
; EnableXP
; Constant = #USE_SSE=1
; Constant = #USE_GLFW=0
; Constant = #USE_BULLET=0
; Constant = #USE_ALEMBIC=0
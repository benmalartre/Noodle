XIncludeFile "../core/Application.pbi"

Time::Init()
Globals::Init()
Controls::Init()

Global *obj.Object3D::Object3D_t = Polymesh::New("Test",Shape::#Shape_Cube)

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 7
; EnableXP
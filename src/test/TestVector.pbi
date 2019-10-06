XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "../ui/CanvasUI.pbi"

Global width = 1024
Global height = 720

UseModule Math

Global *app.Application::Application_t
Global *canvas.CanvasUI::CanvasUI_t


Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  CanvasUI::OnEvent(*canvas)
EndProcedure

Procedure AddCircleGroup(*sheet.Sheet::Sheet_t)
  Define *grp.Vector::Item_t = Vector::NewCompound()
  For i=0 To 2
   Define *circle.Vector::Circle_t = Vector::NewCircle(*grp)
   *circle\radius = 12
   *circle\stroke_color = RGBA(Random(255),Random(255),Random(255),255)
   *circle\stroked = #True
   *circle\filled = #False
   *circle\stroke_width = 4
   *circle\T\translate\x = 100 + i*20
   *circle\T\translate\y = 100 + Mod(i, 2)*20
  Next
 
   Sheet::AddItem(*sheet, *grp)
EndProcedure

Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("TestMesh",width,height)

   *canvas = CanvasUI::New(*app\window\main)
   Define *sheet1.Sheet::Sheet_t = Sheet::New(*canvas\sizX,*canvas\sizY,0, "Sheet")
   Define *sheet2.Sheet::Sheet_t = Sheet::New(*canvas\sizX,*canvas\sizY,1, "Sheet")
   
   Define *circle.Vector::Circle_t = Vector::NewCircle()
   *circle\radius = 12
   *circle\stroke_color = RGBA(0,255,0,255)
   *circle\stroked = #True
   *circle\filled = #False
   *circle\stroke_width = 4
   Sheet::AddItem(*sheet1, *circle)
   
   AddCircleGroup(*sheet2)
   
   CanvasUI::AddSheet(*canvas, *sheet1)
   CanvasUI::AddSheet(*canvas, *sheet2)
   
   Application::Loop(*app, @Draw())
EndIf


; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 39
; FirstLine = 22
; Folding = -
; EnableXP
XIncludeFile "../core/Demo.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "../ui/CanvasUI.pbi"

Global width = 1024
Global height = 720

UseModule Math

Global *demo.DemoApplication::DemoApplication_t
Global *canvas.CanvasUI::CanvasUI_t


Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32

; Draw
;--------------------------------------------
Procedure Draw(*demo.DemoApplication::DemoApplication_t)
  CanvasUI::OnEvent(*canvas, Event())
  
  StartVectorDrawing(CanvasVectorOutput(*canvas\gadgetID))
  AddPathText("current tool : "+Str(*demo\tool))
  StrokePath(1)
  If *demo\tool = Globals::#TOOL_TRANSLATE
    CanvasUI::SetActiveTool(*canvas, 0)
  EndIf
  
  StopVectorDrawing()
EndProcedure

Procedure AddCircleGroup(*sheet.Sheet::Sheet_t)  
  Define *master.Vector::Compound_t = Vector::NewCompound()
  *master\T\translate\x = 200
  *master\T\translate\y = 200
  *master\T\rotate = 0
  *master\T\scale\x = 1
  
  
  Vector::SETSTATE(*master, Vector::#STATE_ACTIVE)
  
  For i=0 To 2
   Define *circle.Vector::Circle_t = Vector::NewCircle(*master)
   *circle\radius = 12
   *circle\stroke_color = RGBA(Random(255),Random(255),Random(255),255)
   *circle\stroked = #True
   *circle\filled = #False
   *circle\stroke_width = 4
   *circle\T\translate\x = i*20
   *circle\T\translate\y = Mod(i, 2)*20
 Next
 
 Sheet::AddItem(*sheet, *master)
EndProcedure

Procedure AddSomeText(*sheet.Sheet::Sheet_t)  
  Define *master.Vector::Compound_t = Vector::NewCompound()

  *master\T\translate\x = 200
  *master\T\translate\y = 400
  *master\T\rotate = 30
  *master\T\scale\x = 1
  
  
  Vector::SETSTATE(*master, Vector::#STATE_ACTIVE)
  
  For i=0 To 12
    Define *text.Vector::Text_t = Vector::NewText(0, "zobiniktou", *master)
    *text\text ="zobiniktou"
    *text\font_size = 32
    *text\stroke_color = RGBA(Random(255),Random(255),Random(255),255)
    *text\fill_color = RGBA(Random(255),Random(255),Random(255),255)
   *text\stroked = #True
   *text\filled = #False
   *text\stroke_width = 1
   *text\T\translate\x = 0
   *text\T\translate\y = i * 24
   
 Next
 
 Sheet::AddItem(*sheet, *master)
EndProcedure

Procedure AddSomeMoreSTuff(*sheet.Sheet::Sheet_t)  
  Define *master.Vector::Compound_t = Vector::NewCompound()

  *master\T\translate\x = 400
  *master\T\translate\y = 400
  
  
  Vector::SETSTATE(*master, Vector::#STATE_ACTIVE)
  
  Define *box.Vector::Box_t = Vector::NewBox(*master)
  *box\halfsize\x = 64
  *box\halfsize\y = 32
  *box\stroke_color = UICOlor::RANDOMIZED
  *box\fill_color = UIColor::RANDOMIZED
  *box\stroked = #True
  *box\filled = #True
  
  Define *line.Vector::Line_t = Vector::NewLine(*master)
  For i = 0 To 12
    AddElement(*line\points())
    *line\points()\x = (Random_0_1() * 2 - 1) * 50
    *line\points()\y = (Random_0_1() * 2 - 1) * 50
  Next
  

 
 Sheet::AddItem(*sheet, *master)
EndProcedure

 *demo = DemoApplication::New("Test Vector Library",width,height)
  
 *canvas = CanvasUI::New(DemoApplication::GetView(*demo))
 Define *sheet1.Sheet::Sheet_t = Sheet::New(*canvas\sizX,*canvas\sizY,0, "Sheet")
 Define *sheet2.Sheet::Sheet_t = Sheet::New(*canvas\sizX,*canvas\sizY,1, "Sheet")
 
 
 Define *circle.Vector::Circle_t = Vector::NewCircle()
 *circle\radius = 12
 *circle\stroke_color = RGBA(0,255,0,255)
 *circle\stroked = #True
 *circle\filled = #False
 *circle\stroke_width = 4
 *circle\T\translate\x = 200
 *circle\T\translate\y = 100
 Sheet::AddItem(*sheet1, *circle)
 
 AddCircleGroup(*sheet2)
 
 AddSomeText(*sheet1)  
 AddSomeMoreSTuff(*sheet2)
 
 CanvasUI::AddSheet(*canvas, *sheet1)
 CanvasUI::AddSheet(*canvas, *sheet2)
 CanvasUI::SetActiveTool(*canvas, 0)

 Application::Loop(*demo, DemoApplication::@Draw())


; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 119
; FirstLine = 86
; Folding = -
; EnableXP
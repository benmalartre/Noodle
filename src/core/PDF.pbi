XIncludeFile "PDFium.pbi"
XIncludeFile "Vector.pbi"
UseJPEGImageEncoder()
; =====================================================================
;   PDF MODULE DECLARATION
; =====================================================================
DeclareModule PDF
  Structure PDFFile_t
    in_file.s
    out_file.s
    img.i
    hdc.i
    width.i
    height.i
    offsetx.f
    offsety.f
    document.i
    page.i
  EndStructure
  
  Declare Init()
  Declare New(file_in.s, file_out.s, width.i=720, height.i=1024)
  Declare Delete(*pdf.PDFFile_t)
  Declare AddItem(*pdf.PDFFile_t, *item.Vector::Item_t)
  Declare AddAtom(*pdf.PDFFile_t, *atom.Vector::Atom_t, stroked.b, stroke_width.f, stroke_color.i, filled.b, fill_color.i)
  Declare Draw(*pdf.PDFFile_t)
  Declare Save(*pdf.PDFFile_t)
  
  #CIRCLE_BEZIER_K = 0.552284749831 ;4*(sqrt(2)-1)/3
  
EndDeclareModule

; =====================================================================
;   PDF MODULE IMPLEMENTATION
; =====================================================================
Module PDF
  ; -------------------------------------------------------------------
  ;   INIT
  ; -------------------------------------------------------------------
  Procedure Init()
    PDFium::Init()
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   CONSTRUCTOR
  ; -------------------------------------------------------------------
  Procedure New(in_file.s, out_file.s, width.i=720, height.i=1024)
    Protected *pdf.PDFFile_t = AllocateMemory(SizeOf(PDFFile_t))
    InitializeStructure(*pdf, PDFFile_t)
    If in_file And FileSize(in_file) > 0
      *pdf\in_file = in_file
      *pdf\out_file = out_file
      *pdf\document = PDFium::LoadDocument(*pdf\in_file, "")
      *pdf\page = PDFium::LoadPage(*pdf\document, 0)
      *pdf\height = PDFium::GetPageHeight(*pdf\page)
      *pdf\width = PDFium::GetPageWidth(*pdf\page)
      Define cl.f, cb.f, cr.f, ct.f
      PDFium::GetCropBox(*pdf\page, @cl, @cb, @cr,@ct)
      *pdf\offsetx = -cl
      *pdf\offsety = -(*pdf\height-ct)
    Else
      *pdf\in_file = ""
      *pdf\out_file = out_file
      *pdf\document = PDFium::CreateNewDocument()
      *pdf\page = PDFium::NewPage(*pdf\document, 0, width, height)
      *pdf\width = width
      *pdf\height = height
    EndIf
    ProcedureReturn *pdf
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   DESTRUCTOR
  ; -------------------------------------------------------------------
  Procedure Delete(*pdf.PDFFIle_t)
    PDFium::ClosePage(*pdf\page)
    PDFium::CloseDocument(*pdf\document)
    ClearStructure(*pdf, PDFFile_t)
    FreeMemory(*pdf)
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   DRAW
  ; -------------------------------------------------------------------
  Procedure Draw(*pdf.PDFFile_t)
    *pdf\img = CreateImage(#PB_Any, *pdf\width, *pdf\height, 24, RGBA(255,255,255,0))
    *pdf\hdc = StartDrawing(ImageOutput(*pdf\img))
    PDFium::RenderPage(*pdf\hdc, *pdf\page, 0, 0, *pdf\width, *pdf\height, 0, 0)
    StopDrawing()
    
    SaveImage(*pdf\img,"pdf2image.jpg", #PB_ImagePlugin_JPEG)
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   SAVE
  ; -------------------------------------------------------------------
  Procedure Save(*pdf.PDFFile_t)
    PDFium::GeneratePageContent(*pdf\page)
    Define writer = PDFium::NewWriter(*pdf\out_file)
    PDFium::SaveAsCopy(*pdf\document, writer,0)
    PDFium::DeleteWriter(writer)
  EndProcedure
  
  Procedure SetPathStyle(path_handle.i, stroked.b, stroke_width.f, stroke_color.i, filled.b, fill_color.i)
    PDFium::PathSetStrokeWidth(path_handle, stroke_width)
    PDFium::PathSetStrokeColor(path_handle, Red(stroke_color), Green(stroke_color), Blue(stroke_color), Alpha(stroke_color))
    PDFium::PathSetFillColor(path_handle, Red(fill_color), Green(fill_color), Blue(fill_color), Alpha(fill_color))
    If stroked
      If filled
        PDFium::PathSetDrawMode(path_handle, PDFium::#FPDF_FILLMODE_ALTERNATE, #True)
      Else
        PDFium::PathSetDrawMode(path_handle, PDFium::#FPDF_FILLMODE_NONE, #True)
      EndIf
    Else
      If filled
        PDFium::PathSetDrawMode(path_handle, PDFium::#FPDF_FILLMODE_ALTERNATE, #False)
      Else
        PDFium::PathSetDrawMode(path_handle, PDFium::#FPDF_FILLMODE_WINDING, #False)
      EndIf
    EndIf
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   ADD VECTOR ATOM
  ; -------------------------------------------------------------------
  Procedure AddAtom(*pdf.PDFFile_t, *atom.Vector::Atom_t, stroked.b, stroke_width.f, stroke_color.i, filled.b, fill_color.i)
    Select *atom\type
      Case Vector::#ATOM_POINT
        
      Case Vector::#ATOM_LINE 
        Define *line.Vector::Line_t = *atom
        If ListSize(*line\points())
          FirstElement(*line\points())
          Define path_handle = PDFium::NewPathObject(*line\points()\x - *pdf\offsetx, *pdf\height - *line\points()\y + *pdf\offsety)
          While NextElement(*line\points())
            PDFium::PathLineTo(path_handle, *line\points()\x - *pdf\offsetx, *pdf\height - *line\points()\y + *pdf\offsety)
          Wend
          SetPathStyle(path_handle, stroked, stroke_width, stroke_color, filled, fill_color)
          ;PDFium::PathClose(path_handle)
          PDFium::InsertPageObject(*pdf\page, path_handle)
          
        EndIf
        
      Case Vector::#ATOM_POINT
        
      Case Vector::#ATOM_BOX
        Define *box.Vector::Box_t = *atom
        Define box_handle = PDFium::NewRectangleObject((*box\T\translate\x - *box\halfsize\x) - *pdf\offsetx,
                                                       *pdf\height - (*box\T\translate\y + *box\halfsize\y) + *pdf\offsety,
                                                       *box\halfsize\x * 2,
                                                       *box\halfsize\y * 2)
        SetPathStyle(box_handle, stroked, stroke_width, stroke_color, filled, fill_color)
        PDFium::InsertPageObject(*pdf\page, box_handle)
        
      Case Vector::#ATOM_CIRCLE
        Define *circle.Vector::Circle_t = *atom
        Define circle_handle = PDFium::NewPathObject(*circle\T\translate\x- *pdf\offsetx, *pdf\height - *circle\T\translate\y + *circle\radius + *pdf\offsety)
       
        PDFium::PathBezierTo(circle_handle,
                             *circle\T\translate\x + *circle\radius * #CIRCLE_BEZIER_K - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y + *circle\radius + *pdf\offsety,
                             *circle\T\translate\x + *circle\radius - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y + *circle\radius * #CIRCLE_BEZIER_K + *pdf\offsety,
                             *circle\T\translate\x + *circle\radius - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y + *pdf\offsety)
        
        PDFium::PathBezierTo(circle_handle,
                             *circle\T\translate\x + *circle\radius - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y - *circle\radius * #CIRCLE_BEZIER_K + *pdf\offsety,
                             *circle\T\translate\x + *circle\radius * #CIRCLE_BEZIER_K - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y - *circle\radius + *pdf\offsety,
                             *circle\T\translate\x- *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y - *circle\radius + *pdf\offsety)
        
        PDFium::PathBezierTo(circle_handle,
                             *circle\T\translate\x - *circle\radius * #CIRCLE_BEZIER_K - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y - *circle\radius + *pdf\offsety,
                             *circle\T\translate\x - *circle\radius - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y - *circle\radius * #CIRCLE_BEZIER_K + *pdf\offsety,
                             *circle\T\translate\x - *circle\radius - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y + *pdf\offsety)
        
        PDFium::PathBezierTo(circle_handle,
                             *circle\T\translate\x - *circle\radius - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y + *circle\radius * #CIRCLE_BEZIER_K + *pdf\offsety,
                             *circle\T\translate\x - *circle\radius * #CIRCLE_BEZIER_K - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y + *circle\radius + *pdf\offsety,
                             *circle\T\translate\x - *pdf\offsetx,
                             *pdf\height - *circle\T\translate\y + *circle\radius + *pdf\offsety)
        
        SetPathStyle(circle_handle, stroked, stroke_width, stroke_color, filled, fill_color)
        PDFium::InsertPageObject(*pdf\page, circle_handle)
                             
;   EXPECT_TRUE(FPDFPath_BezierTo(path, 180, 166, 180, 233, 250, 300));
;   EXPECT_TRUE(FPDFPath_LineTo(path, 255, 305));
;   EXPECT_TRUE(FPDFPath_BezierTo(path, 325, 233, 325, 166, 255, 105));
;   EXPECT_TRUE(FPDFPath_Close(path));
;   EXPECT_TRUE(FPDFPath_SetFillColor(path, 200, 128, 128, 100));
;   EXPECT_TRUE(FPDFPath_SetStrokeColor(path, 128, 200, 128, 150));
;   EXPECT_TRUE(FPDFPath_SetStrokeWidth(path, 10.5f));
;   EXPECT_TRUE(FPDFPath_SetDrawMode(path, FPDF_FILLMODE_ALTERNATE, 1));
;   FPDFPage_InsertObject(page, path);
                                                       
        
      Case Vector::#ATOM_TEXT
        Define *txt.Vector::Text_t = *atom
        Define text_handle = PDFium::NewTextObject(*pdf\document, "Arial", *txt\font_size)
        If text_handle
          PDFium::SetText(text_handle, PDFium::TranslateText(*txt\text))
          PDFium::Transform(text_handle,1,0,0,1,*txt\T\translate\x - *pdf\offsetx,*pdf\height - *txt\T\translate\y)
          PDFium::InsertPageObject(*pdf\page, text_handle)
        EndIf
      Default
        Debug "VECTOR TYPE TO PDF NOT IMPLEMENTED !!!"
    EndSelect
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   ADD VECTOR ITEM
  ; -------------------------------------------------------------------
  Procedure AddItem(*pdf.PDFFile_t, *item.Vector::Item_t)
    ForEach *item\childrens()
      AddAtom(*pdf, *item\childrens(), *item\stroked, *item\stroke_width, *item\stroke_color, *item\filled, *item\fill_color)
    Next
  EndProcedure
  

EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 30
; Folding = --
; EnableXP
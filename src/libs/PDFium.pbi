DeclareModule PDFium
  
  ; Structure for custom file write
  Structure FileWrite_t Align #PB_Structure_AlignC
  EndStructure
  
  Prototype PFNNEWWRITER(filename.p-utf8)
  Prototype PFNDELETEWRITER(*writer.FileWrite_t)
  
  Global writer_dll = OpenLibrary(#PB_Any, "libs/writer.dll")
  If writer_dll = 0
    Debug "Error loading writer DLL"
    End
  EndIf
  
  ; library
  Global NewWriter.PFNNEWWRITER         = GetFunction(writer_dll, "NewWriter")
  Global DeleteWriter.PFNDELETEWRITER   = GetFunction(writer_dll, "DeleteWriter")

  Macro ARGB(_a, _r, _g,_b)    
    (((_b)&$FF) | (((_g)&$FF) << 8) | (((_r)&$FF) << 16) | (((_a)&$FF) << 24))
  EndMacro
  
  Macro GetBValue(_argb) : (PeekA(_argb)) : EndMacro
  Macro GetGValue(_argb) : (PeekA(_argb) >> 8) : EndMacro
  Macro GetRValue(_argb) : (PeekA(_argb) >> 16) : EndMacro
  Macro GetAValue(_argb) : (PeekA(_argb) >> 24) : EndMacro


  ; Refer To PDF Reference version 1.7 table 4.12 For all color space families.
  #FPDF_COLORSPACE_UNKNOWN = 0
  #FPDF_COLORSPACE_DEVICEGRAY = 1
  #FPDF_COLORSPACE_DEVICERGB = 2
  #FPDF_COLORSPACE_DEVICECMYK = 3
  #FPDF_COLORSPACE_CALGRAY = 4
  #FPDF_COLORSPACE_CALRGB = 5
  #FPDF_COLORSPACE_LAB = 6
  #FPDF_COLORSPACE_ICCBASED = 7
  #PDF_COLORSPACE_SEPARATION = 8
  #PDF_COLORSPACE_DEVICEN = 9
  #FPDF_COLORSPACE_INDEXED = 10
  #FPDF_COLORSPACE_PATTERN = 11
  
  ; The page object constants.
  #FPDF_PAGEOBJ_UNKNOWN = 0
  #FPDF_PAGEOBJ_TEXT = 1
  #FPDF_PAGEOBJ_PATH = 2
  #FPDF_PAGEOBJ_IMAGE = 3
  #FPDF_PAGEOBJ_SHADING = 4
  #FPDF_PAGEOBJ_FORM = 5
  
  ; The path segment constants.
  #FPDF_SEGMENT_UNKNOWN = -1
  #FPDF_SEGMENT_LINETO = 0
  #FPDF_SEGMENT_BEZIERTO = 1
  #FPDF_SEGMENT_MOVETO = 2
  #FPDF_FILLMODE_NONE = 0
  #FPDF_FILLMODE_ALTERNATE = 1
  #FPDF_FILLMODE_WINDING = 2
  #FPDF_FONT_TYPE1 = 1
  #FPDF_FONT_TRUETYPE = 2
  #FPDF_LINECAP_BUTT = 0
  #FPDF_LINECAP_ROUND = 1
  #FPDF_LINECAP_PROJECTING_SQUARE = 2
  #FPDF_LINEJOIN_MITER = 0
  #FPDF_LINEJOIN_ROUND = 1
  #FPDF_LINEJOIN_BEVEL = 2
  #FPDF_PRINTMODE_EMF = 0
  #FPDF_PRINTMODE_TEXTONLY = 1
  #FPDF_PRINTMODE_POSTSCRIPT2 = 2
  #FPDF_PRINTMODE_POSTSCRIPT3 = 3
  #FPDF_PRINTMODE_POSTSCRIPT2_PASSTHROUGH = 4
  #FPDF_PRINTMODE_POSTSCRIPT3_PASSTHROUGH = 5
  #FPDF_TEXTRENDERMODE_FILL = 0
  #FPDF_TEXTRENDERMODE_STROKE = 1
  #FPDF_TEXTRENDERMODE_FILL_STROKE = 2
  #FPDF_TEXTRENDERMODE_INVISIBLE = 3
  #FPDF_TEXTRENDERMODE_FILL_CLIP = 4
  #FPDF_TEXTRENDERMODE_STROKE_CLIP = 5
  #FPDF_TEXTRENDERMODE_FILL_STROKE_CLIP = 6
  #FPDF_TEXTRENDERMODE_CLIP = 7
  
  Structure ImageMetada_t
    width.l
    height.l
  
    horizontal_dpi.f
    vertical_dpi.f
    bits_per_pixel.l
    colorspace.l
  
    marked_content_id.l
  EndStructure

  Prototype PFNINITLIBRARY()
  
  ; document
  Prototype PFNCREATENEWDOCUMENT()
  Prototype PFNLOADDOCUMENT(documentpath.p-ascii,password.p-utf8)
  Prototype PFNCLOSEDOCUMENT(document)
  Prototype PFNSAVEASCOPY(document.i, *writer.FileWrite_t, flag.i)
  Prototype PFNSAVEWITHVERSION(document.i, *writer.FileWrite_t, flag.i, version.i)

  Prototype PFNGETMETATEXT(document, tag.p-utf8, buffer, buflen)
  Prototype PFNGETFILEVERSION(document, *version)
  Prototype PFNGETPAGECOUNT(document)
  Prototype PFNFONT(document.i, name.p-ascii)
  Prototype PFNSTANDARDFONT(document.i, name.p-ascii)
  
  ; page
  Prototype PFNNEWPAGE(document.i, index.i, width.d, height.d)
  Prototype PFNDELETEPAGE(document.i, index.i)
  Prototype PFNLOADPAGE(document, pageindex.l)
  Prototype PFNCLOSEPAGE(page.i)
  Prototype.d PFNGETPAGEHEIGHT(page.i)
  Prototype.d PFNGETPAGEWIDTH(page.i)
  Prototype PFNGETCROPBOX(page.i, *left, *bottom, *right, *top)
  Prototype PFNSETCROPBOX(page.i, left.f, bottom.f, right.f, top.f)
  Prototype PFNGETPAGEROTATION(page.i)
  Prototype PFNSETPAGEROTATION(page.i, rotation.i)
  Prototype PFNINSERTPAGEOBJECT(page.i, obj.i)
  Prototype PFNREMOVEPAGEOBJECT(page.i, obj.i)
  Prototype PFNCOUNTPAGEOBJECTS(page.i)
  Prototype PFNGETPAGEOBJECT(page.i, index.i)
  Prototype PFNHASPAGETRANSPARENCY(page.i)
  Prototype PFNGENERATEPAGECONTENT(page.i)
  
  ; object
  Prototype PFNDESTROYOBJECT(obj.i)
  Prototype PFNHASOBJECTTRANSPARENCY(obj.i)
  Prototype PGNGETOBJECTTYPE(obj.i)
  Prototype PFNGETFILLCOLOR(obj.i)
  Prototype PFNGETSTROKECOLOR(obj.i)
  Prototype PFNGETSTROKEWIDTH(obj.i)
  Prototype PFNSETFILLCOLOR(obj.i, color.i)
  Prototype PFNSETSTROKECOLOR(obj.i, color.i)
  Prototype PFNSETSTROKEWIDTH(obj.i, width.d)
  
  Prototype PFNNEWRECTANGLEOBJECT(x.f,y.f, w.f, h.f)
  
  Prototype PFNNEWTEXTOBJECT(document.i, text.p-utf8, font_size.f)
  Prototype PFNSETTEXT(obj.i, *text)
  
  Prototype PFNNEWPATHOBJECT(x.f, y.f)
  Prototype PFNPATHMOVETO(path.i,x.f,y.f)
  Prototype PFNPATHLINETO(path.i,x.f,f.f)
  Prototype PFNPATHBEZIERTO(path.i,x1.f,y1.f, x2.f, y2.f, x3.f, y3.f)
  Prototype PFNPATHCLOSE(path.i)
  Prototype PFNPATHSETFILLCOLOR(path.i, r.l, g.l, b.l, a.l)
  Prototype PFNPATHSETDRAWMODE(path.i, mode.i=#FPDF_FILLMODE_NONE, stroke.b=#False)
  Prototype PFNPATHSETSTROKECOLOR(path.i, r.l, g.l, b.l, a.l)
  Prototype PFNPATHSETSTROKEWIDTH(path.i, width.f)
  

  Prototype PFNNEWIMAGEOBJECT(document.i)
  
  Prototype PFNCOUNTMARKS(obj.i)
  Prototype PFNGETMARK(obj.i, index.i)
  Prototype PFNADDMARK(obj.i, name.p-ascii)
  Prototype PFNREMOVEMARK(obj.i, mark.i)
  Prototype PFNGETMARKNAME(mark.i, *buffer, len.i)
  
  Prototype PFNTRANSFORMANNOTS(page.i, a.d, b.d, c.d, d.d, e.d, f.d)

  Prototype PFNGETMATRIX(obj.i)
  Prototype PFNSETMATRIX(obj.i)
  Prototype PFNTRANSFORM(obj.i, a.d, b.d, c.d, d.d, e.d, f.d)
  
  Prototype PFNRENDERPAGE(hdc, page, start_x.l, start_y.l, size_x.l, size_y.l, rotate.l, flags.l)
  
  
  Global pdf_dll = OpenLibrary(#PB_Any, "libs/pdfium.dll")
  #BUFFER_LEN = 1024
  Global *buffer

  If pdf_dll = 0
    Debug "Error loading DLL"
    End
  EndIf
  
  ; library
  Global InitLibrary.PFNINITLIBRARY                 = GetFunction(pdf_dll, "FPDF_InitLibrary")
  
  ; document
  Global CreateNewDocument.PFNCREATENEWDOCUMENT     = GetFunction(pdf_dll, "FPDF_CreateNewDocument")
  Global LoadDocument.PFNLOADDOCUMENT               = GetFunction(pdf_dll, "FPDF_LoadDocument")
  Global CloseDocument.PFNCLOSEDOCUMENT             = GetFunction(pdf_dll, "FPDF_CloseDocument")
  Global SaveAsCopy.PFNSAVEASCOPY                   = GetFunction(pdf_dll, "FPDF_SaveAsCopy")
  Global SaveWithVersion.PFNSAVEWITHVERSION         = GetFunction(pdf_dll, "FPDF_SaveWithVersion")
  Global GetPageCount.PFNGETPAGECOUNT               = GetFunction(pdf_dll, "FPDF_GetPageCount")
  Global GetMetaText.PFNGETMETATEXT                 = GetFunction(pdf_dll, "FPDF_GetMetaText")
  Global GetFileVersion.PFNGETFILEVERSION           = GetFunction(pdf_dll, "FPDF_GetFileVersion")
  Global Font.PFNFONT                               = GetFunction(pdf_dll, "FPDFText_LoadFont")
  Global StandardFont.PFNSTANDARDFONT               = GetFunction(pdf_dll, "FPDFText_LoadStandardFont")
  
  ; page
  Global NewPage.PFNNEWPAGE                         = GetFunction(pdf_dll, "FPDFPage_New")
  Global DeletePage.PFNDELETEPAGE                   = GetFunction(pdf_dll, "FPDFPage_Delete")
  Global LoadPage.PFNLOADPAGE                       = GetFunction(pdf_dll, "FPDF_LoadPage")
  Global ClosePage.PFNCLOSEPAGE                     = GetFunction(pdf_dll, "FPDF_ClosePage")
  Global GetPageHeight.PFNGETPAGEHEIGHT             = GetFunction(pdf_dll, "FPDF_GetPageHeight")
  Global GetPageWidth.PFNGETPAGEWIDTH               = GetFunction(pdf_dll, "FPDF_GetPageWidth")
  Global GetCropBox.PFNGETCROPBOX                   = GetFunction(pdf_dll, "FPDFPage_GetCropBox")
  Global SetCropBox.PFNSETCROPBOX                   = GetFunction(pdf_dll, "FPDFPage_SetCropBox")
  Global GetPageRotation.PFNGETPAGEROTATION         = GetFunction(pdf_dll, "FPDFPage_GetRotation")
  Global SetPageRotation.PFNSETPAGEROTATION         = GetFunction(pdf_dll, "FPDFPage_SetRotation")
  Global InsertPageObject.PFNINSERTPageOBJECT       = GetFunction(pdf_dll, "FPDFPage_InsertObject")
  Global RemovePageObject.PFNREMOVEPAGEOBJECT       = GetFunction(pdf_dll, "FPDFPage_RemoveObject")
  Global CountPageObjects.PFNCOUNTPAGEOBJECTS       = GetFunction(pdf_dll, "FPDFPage_CountObjects")
  Global GetPageObject.PFNGETPAGEOBJECT             = GetFunction(pdf_dll, "FPDFPage_GetObject")
  Global HasPageTransparency.PFNHASPAGETRANSPARENCY = GetFunction(pdf_dll, "FPDFPage_HasTransparency")
  Global GeneratePageContent.PFNGENERATEPAGECONTENT = GetFunction(pdf_dll, "FPDFPage_GenerateContent")
  
  ; object
  Global DestroyObject.PFNDESTROYOBJECT             = GetFunction(pdf_dll, "FPDFPageObj_Destroy")
  Global HasObjectTransparency.PFNHASOBJECTTRANSPARENCY= GetFunction(pdf_dll, "FPDFPageObj_HasTransparency")
  Global GetObjectType.PGNGETOBJECTTYPE             = GetFunction(pdf_dll, "FPDFPageObj_GetType")
  
  Global GetFillColor.PFNGETFILLCOLOR               = GetFunction(pdf_dll, "FPDFPageObj_GetFillColor")
  Global GetStrokeColor.PFNGETSTROKECOLOR           = GetFunction(pdf_dll, "FPDFPageObj_GetStrokeColor")
  Global SetFillColor.PFNSETFILLCOLOR               = GetFunction(pdf_dll, "FPDFPageObj_SetFillColor")
  Global SetStrokeColor.PFNGETSTROKECOLOR           = GetFunction(pdf_dll, "FPDFPageObj_SetStrokeColor")
  
  Global NewRectangleObject.PFNNEWRECTANGLEOBJECT   = GetFunction(pdf_dll, "FPDFPageObj_CreateNewRect")
  
  Global NewTextObject.PFNNEWTEXTOBJECT             = GetFunction(pdf_dll, "FPDFPageObj_NewTextObj")
  Global SetText.PFNSETTEXT                         = GetFunction(pdf_dll, "FPDFText_SetText")
  
  Global NewPathObject.PFNNEWPATHOBJECT             = GetFunction(pdf_dll, "FPDFPageObj_CreateNewPath")
  Global PathMoveTo.PFNPATHMOVETO                   = GetFunction(pdf_dll, "FPDFPath_MoveTo")
  Global PathLineTo.PFNPATHLINETO                   = GetFunction(pdf_dll, "FPDFPath_LineTo")
  Global PathBezierTo.PFNPATHBEZIERTO               = GetFunction(pdf_dll, "FPDFPath_BezierTo")
  Global PathClose.PFNPATHCLOSE                     = GetFunction(pdf_dll, "FPDFPath_Close")
  Global PathSetFillColor.PFNPATHSETFILLCOLOR       = GetFunction(pdf_dll, "FPDFPath_SetFillColor")
  Global PathSetDrawMode.PFNPATHSETDRAWMODE         = GetFunction(pdf_dll, "FPDFPath_SetDrawMode")
  Global PathSetStrokeWidth.PFNPATHSETSTROKEWIDTH   = GetFunction(pdf_dll, "FPDFPath_SetStrokeWidth")
  Global PathSetStrokeColor.PFNPATHSETSTROKECOLOR   = GetFunction(pdf_dll, "FPDFPath_SetStrokeColor")
    
  
  Global NewImageObject.PFNNEWIMAGEOBJECT           = GetFunction(pdf_dll, "FPDFPageObj_NewImageObj")
  Global CountMarks.PFNCOUNTMARKS                   = GetFunction(pdf_dll, "FPDFPageObj_CountMarks")
  Global GetMark.PFNGETMARK                         = GetFunction(pdf_dll, "FPDFPageObj_GetMark")
  Global AddMark.PFNADDMARK                         = GetFunction(pdf_dll, "FPDFPageObj_AddMark")
  Global RemoveMark.PFNREMOVEMARK                   = GetFunction(pdf_dll, "FPDFPageObj_RemoveMark")
  Global GetMarkName.PFNGETMARKNAME                 = GetFunction(pdf_dll, "FPDFPageObjMark_GetName")
  
  Global TransformAnnots.PFNTRANSFORMANNOTS         = GetFunction(pdf_dll, "FPDFPage_TransformAnnots")
  
  Global GetMatrix.PFNGETMATRIX                     = GetFunction(pdf_dll, "FPDFPath_GetMatrix")
  Global SetMatrix.PFNSETMATRIX                     = GetFunction(pdf_dll, "FPDFPath_SetMatrix")
  Global Transform.PFNTRANSFORM                     = GetFunction(pdf_dll, "FPDFPageObj_Transform")
  Global RenderPage.PFNRENDERPAGE                   = GetFunction(pdf_dll, "FPDF_RenderPage")  
  
  Declare Init()
  Declare Term()
  Declare.s GetAuthor(pdf_doc)
  Declare.s GetCreator(pdf_doc)
  Declare.s GetTitle(pdf_doc)
  Declare TranslateText(text.s)
  
EndDeclareModule

Module PDFium
  Procedure Init()
    InitLibrary()
    *buffer = AllocateMemory(#BUFFER_LEN)
  EndProcedure
  
  Procedure Term()
    If pdf_dll : CloseLibrary(pdf_dll) : EndIf
    If *buffer : FreeMemory(*buffer) : EndIf
  EndProcedure
  
  ; PDF-Author
  Procedure.s GetAuthor(pdf_doc)
    Define ret = PDFium::GetMetaText(pdf_doc,"Author",*buffer, #BUFFER_LEN)
    If ret : ProcedureReturn PeekS(*buffer, ret) : EndIf
  EndProcedure
  
  ; PDF-Titel
  Procedure.s GetTitle(pdf_doc)
    Define ret = PDFium::GetMetaText(pdf_doc,"Title",*buffer, #BUFFER_LEN)
    If ret : ProcedureReturn PeekS(*buffer, ret) : EndIf
  EndProcedure

  ; PDF-Creator
  Procedure.S GetCreator(pdf_doc)
    Define ret = PDFium::GetMetaText(pdf_doc,"Creator",*buffer, #BUFFER_LEN)
    If ret : ProcedureReturn PeekS(*buffer, ret) : EndIf
  EndProcedure
  
  Procedure TranslateText(text.s)
    Debug "TRANSLATE TEXT : "+text
    Define translated.s = PeekS(@text, -1, #PB_UTF16)
    FillMemory(*buffer, #BUFFER_LEN, 0)
    CopyMemory(@translated, *buffer, StringByteLength(translated, #PB_UTF16))
    ProcedureReturn *buffer
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 22
; FirstLine = 241
; Folding = ---
; EnableXP
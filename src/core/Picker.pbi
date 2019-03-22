; ====================================================================================================
;   PICKER MODULE DECLARATION
; ====================================================================================================
DeclareModule Picker
  ; --------------------------------------------------------------------------------------------------
  ; STRUCTRURE
  ; --------------------------------------------------------------------------------------------------
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Structure Picker_t
        hDC.i
        color.i
        
    CompilerCase #PB_OS_MacOS
      Structure Picker_t
        image.i
        csRGB.i
        ctx.i
        color.l
        
    CompilerCase #PB_OS_Linux
      Structure Picker_t
        color.l
        
  CompilerEndSelect
        r.i
        g.i
        b.i
        repr.s
    EndStructure

  ; --------------------------------------------------------------------------------------------------
  ;   IMPORTS
  ; --------------------------------------------------------------------------------------------------
   CompilerSelect #PB_Compiler_OS
     CompilerCase #PB_OS_Windows
       
     CompilerCase #PB_OS_MacOS
     
      ImportC ""
        CGBitmapContextCreate(*bdata, width, height, bitsPerComponent, bytesPerRow, cs, bitmapInfo)
        CGColorSpaceCreateDeviceRGB()
        CGColorSpaceRelease(cs)
        CGContextRelease(c)
        CGImageRelease(image)  
      EndImport
      
      Declare CGContextDrawImage_addr()
      Declare CGWindowListCreateImage_addr()

      Prototype CGContextDrawImage_proto(c, x.d, y.d, w.d, h.d, image)
      Prototype CGWindowListCreateImage_proto(x.d, y.d, w.d, h.d, listOption, windowID, imageOption)
      Global CGWindowListCreateImage.CGWindowListCreateImage_proto = CGWindowListCreateImage_addr()
      Global CGContextDrawImage.CGContextDrawImage_proto = CGContextDrawImage_addr()
      
    CompilerCase #PB_OS_Linux
      
      ImportC ""
        gdk_pixbuf_get_from_window(window, x, y, width, height)
        gdk_pixbuf_get_pixels(pixbuf)
      EndImport

  CompilerEndSelect
  
  Declare New()
  Declare Delete(*picker.Picker_t)
  Declare Pick(*picker.Picker_t, mx.i, my.i)
  
EndDeclareModule

; ====================================================================================================
;   PICKER MODULE IMPLEMENTATION
; ====================================================================================================
Module Picker
  ; --------------------------------------------------------------------------------------------------
  ;   CONSTRUCTOR
  ; --------------------------------------------------------------------------------------------------
  Procedure New()
    Protected *picker.Picker_t = AllocateMemory(SizeOf(Picker_t))
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        *picker\hDC = GetDC_(0)
      CompilerCase #PB_OS_MacOS
        
      CompilerCase #PB_OS_Linux
        
    CompilerEndSelect
    ProcedureReturn *picker
  EndProcedure
  
  ; --------------------------------------------------------------------------------------------------
  ;   DESTRUCTOR
  ; --------------------------------------------------------------------------------------------------
  Procedure Delete(*picker.Picker_t )
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ReleaseDC_(0,*picker\hDC)
        
      CompilerCase #PB_OS_MacOS
        
      CompilerCase #PB_OS_Linux
        
    CompilerEndSelect
    FreeMemory(*picker)
  EndProcedure
  
  ; --------------------------------------------------------------------------------------------------
  ;   PICK
  ; --------------------------------------------------------------------------------------------------
  Procedure Pick(*picker.Picker_t, mx.i, my.i)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        *picker\color = GetPixel_(*picker\hDC,mx,my)
        Debug Str(mx)+", "+Str(my)
        Debug "PICK : " +Str(*picker\color)
        
      CompilerCase #PB_OS_MacOS
        *picker\image = CGWindowListCreateImage(mx, my, 1, 1, 1, 0, 0)
        *picker\csRGB = CGColorSpaceCreateDeviceRGB()
        *picker\ctx = CGBitmapContextCreate(@*picker\color, 1, 1, 8, 4, *picker\csRGB, 1)
        CGContextDrawImage(*picker\ctx, 0, 0, 1, 1, *picker\image)
        CGColorSpaceRelease(*picker\csRGB)
        CGImageRelease(*picker\image)
        CGContextRelease(*picker\ctx)  
        
      CompilerCase #PB_OS_Linux
         Protected.i pixbuf, *buf.Ascii
        pixbuf = gdk_pixbuf_get_from_window(gdk_get_default_root_window_(), mx, my, 1, 1)
        *buf = gdk_pixbuf_get_pixels(pixbuf)
        *picker\color = *buf\a : *buf + 1
        *picker\color | *buf\a << 8 : *buf + 1
        *picker\color | *buf\a << 16
        g_object_unref_(pixbuf)
        
      CompilerDefault
        ProcedureReturn

    CompilerEndSelect
    
    *picker\r = Red(*picker\color)
    *picker\g = Green(*picker\color)
    *picker\b = Blue(*picker\color)
    *picker\repr = "#" + RSet(Hex(*picker\r), 2, "0") + RSet(Hex(*picker\g), 2, "0") + RSet(Hex(*picker\b), 2, "0") 
    
  EndProcedure
  
  ; --------------------------------------------------------------------------------------------------
  ;   UTILS MACOS
  ; --------------------------------------------------------------------------------------------------
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    Procedure CGContextDrawImage_addr()
      ProcedureReturn ?cgcdi_start
      cgcdi_start:
      !extern _CGContextDrawImage
      !sub rsp, 40
      !movq [rsp     ], xmm0
      !movq [rsp +  8], xmm1
      !movq [rsp + 16], xmm2
      !movq [rsp + 24], xmm3
      !call _CGContextDrawImage
      !add rsp, 40
      !ret
    EndProcedure
    
    Procedure CGWindowListCreateImage_addr()
      ProcedureReturn ?cgwlci_start
      cgwlci_start:
      !extern _CGWindowListCreateImage
      !sub rsp, 40
      !movq [rsp     ], xmm0
      !movq [rsp +  8], xmm1
      !movq [rsp + 16], xmm2
      !movq [rsp + 24], xmm3
      !call _CGWindowListCreateImage
      !add rsp, 40
      !ret
    EndProcedure
  CompilerEndIf

  
EndModule

Procedure TestPicker()
  OpenWindow(0, 0, 0, 200, 20, "", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
  TextGadget(0, 0, 3, 200, 20, "", #PB_Text_Center)
  
  Define *picker.Picker::Picker_t = Picker::New()
  
  Repeat
   Event = WaitWindowEvent(100)
    
   mx = DesktopMouseX()
   my = DesktopMouseY()
   Picker::Pick(*picker, mx, my)
  
   If WindowHeight(0) > 10
    SetWindowTitle(0, "GetPixelColour")
    pixel.s = *picker\repr + " (" + Str(*picker\r) + ", " + Str(*picker\g) + ", " + Str(*picker\b) + ")"
    SetGadgetText(0, Str(mx) + ","+ Str(my) +" : " + pixel)
   Else
    SetWindowTitle(0, *picker\repr)
   EndIf
   
  Until Event = #PB_Event_CloseWindow
  
  Picker::Delete(*picker)
EndProcedure

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 106
; FirstLine = 93
; Folding = --
; EnableXP
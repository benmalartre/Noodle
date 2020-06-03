;------------------------------------------------------------------------------------------------
; SCREEN CAPTURE MODULE DECLARATION
;------------------------------------------------------------------------------------------------
DeclareModule ScreenCapture
  Structure RectangleData_t
    left.i
    top.i
    width.i
    height.i
  EndStructure
 
  Structure ScreenCapture_t
    rect.RectangleData_t
    img.i
    *buffer
  EndStructure
  
  DataSection
    swap_red_blue_mask:
    Data.a 2,1,0,3,6,5,4,7,10,9,8,11,14,13,12,15
  EndDataSection
  
  Declare Init(*data.ScreenCapture_t, *rect.RectangleData_t)
  Declare Capture(*data.ScreenCapture_t, flipBuffer.b)
  Declare Term(*data.ScreenCapture_t)
EndDeclareModule

;------------------------------------------------------------------------------------------------
; SCREEN CAPTURE MODULE IMPLEMENTATION
;------------------------------------------------------------------------------------------------
Module ScreenCapture
  Procedure FlipBuffer(*data.ScreenCapture_t)
    StartDrawing(ImageOutput(*data\img))
    Define *input = DrawingBuffer()
    Define *output = *data\buffer
    Define num_pixels_in_row.i = *data\rect\width
    Define num_rows.i = *data\rect\height
    Define *mask = ScreenCapture::?swap_red_blue_mask
    
    ! mov rsi, [p.p_input]                ; input buffer to rsi register
    ! mov rdi, [p.p_output]               ; output buffer to rdi register
    ! mov eax, [p.v_num_pixels_in_row]    ; image width in rax register
    ! mov ecx, [p.v_num_rows]             ; image height in rcx register
    ! mov r10, [p.p_mask]                 ; load mask in r10 register
    ! mov r15, rax                        ; num pixels in a row
    ! imul r15, 4                         ; size of a row of pixels
    ! movups xmm1, [r10]                  ; load mask in xmm1 register
    
    ! loop_over_rows:
    !   mov r11, rax                      ; reset pixels counter
    !   mov r13, rcx                      ; as we reverse iterate
    !   sub r13, 1                        ; we need the previous row
    !   imul r13, r15                     ; address of current pixel
    !   mov r14, rsi                      ; load input buffer in r14 register
    !   add r14, r13                      ; offset to current pixel
    
    ! loop_over_pixels:
    !   movups xmm0, [r14]                ; load pixel to xmm0
    !   pshufb xmm0, xmm1                 ; shuffle bytes with mask
    !   movups [rdi], xmm0                ; set fixed color to output ptr
    !   add r14, 16                       ; advance input ptr
    !   add rdi, 16                       ; advance output ptr
    !   sub r11, 4                        ; decrement pixel counter
    !   jg loop_over_pixels               ; loop next pixel
    
    ! next_row:
    !   dec rcx                           ; decrement row counter
    !   jg loop_over_rows                 ; loop next row
    StopDrawing()
  EndProcedure

  Procedure Init(*data.ScreenCapture_t, *rect.RectangleData_t)
    *data\rect\top = *rect\top
    *data\rect\left = *rect\left
    If *rect\width % 4 
      *data\rect\width = *rect\width + ( 4 - *rect\width  % 4 )
    Else
      *data\rect\width = *rect\width
    EndIf
    
    If *rect\height % 4 
      *data\rect\height = *rect\height + ( 4 - *rect\height  % 4 )
    Else
      *data\rect\height = *rect\height
    EndIf

    If *data\rect\width > 0 And *data\rect\height > 0
      *data\img = CreateImage(#PB_Any, *data\rect\width, *data\rect\height, 32)
      *data\buffer = AllocateMemory(*data\rect\width * *data\rect\height * 4)
    EndIf
  EndProcedure
  
  Procedure Capture(*data.ScreenCapture_t, flipBuffer.b)
    Define hDC = StartDrawing(ImageOutput(*data\img))
     If hDC
       Define deskDC = GetDC_(GetDesktopWindow_())
       If deskDC
         BitBlt_(hDC,0,0,*data\rect\width,*data\rect\height,deskDC,*data\rect\left,*data\rect\top,#SRCCOPY)
       EndIf
       ReleaseDC_(GetDesktopWindow_(),deskDC)
     EndIf
    StopDrawing()
    
    If flipBuffer      
      FlipBuffer(*data)
    EndIf
    
    ProcedureReturn
  EndProcedure
  
  Procedure Term(*data.ScreenCapture_t)
    If IsImage(*data\img) : FreeImage(*data\img) : EndIf
    FreeMemory(*data\buffer)
  EndProcedure 
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 114
; FirstLine = 49
; Folding = --
; EnableXP
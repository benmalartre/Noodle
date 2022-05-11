XIncludeFile "../core/Icons.pbi"

UsePNGImageEncoder()

DataSection
  swap_red_blue_mask:
  Data.a 2,1,0,3,6,5,4,7,10,9,8,11,14,13,12,15
EndDataSection

CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
Procedure FlipBuffer(image.i, *memory, resolution.i)
    StartDrawing(ImageOutput(image))
    Define *input = DrawingBuffer()
    Define *output = *memory
    Define num_pixels_in_row.i = resolution
    Define num_rows.i = resolution
    Define *mask = ?swap_red_blue_mask
    
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
CompilerElse
  Procedure FlipBuffer(image.i, *memory, resolution.i)
    StartDrawing(ImageOutput(image))
    Define *input = DrawingBuffer()
  EndProcedure
CompilerEndIf


ProcedureDLL BuildIconInMemory(*memory, resolution, icon.i, fill.i=Icon::#FILL_COLOR_DEFAULT, 
                               stroke.i=Icon::#STROKE_COLOR_DEFAULT, thickness=Icon::#STROKE_WIDTH)
  Define image.i = CreateImage(#PB_Any, resolution, resolution, 32)
  
  StartDrawing(ImageOutput(image))
  DrawingMode(#PB_2DDrawing_AlphaChannel)
  Box(0, 0, resolution, resolution, RGBA(0,0,0,0))
  StopDrawing()

  StartVectorDrawing(ImageVectorOutput(image))
  Select icon
    Case Icon::#ICON_VISIBLE
      Icon::VisibleIcon(fill, stroke, thickness)  
    Case Icon::#ICON_INVISIBLE
      Icon::InvisibleIcon(fill, stroke, thickness) 
    Case Icon::#ICON_PLAYFORWARD
      Icon::PlayForwardIcon(fill, stroke, thickness) 
    Case Icon::#ICON_PLAYBACKWARD
      Icon::PlayBackwardIcon(fill, stroke, thickness) 
    Case Icon::#ICON_STOP
      Icon::StopIcon(fill, stroke, thickness) 
    Case Icon::#ICON_PREVIOUSFRAME
      Icon::PreviousFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_NEXTFRAME
      Icon::NextFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_FIRSTFRAME
      Icon::FirstFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_LASTFRAME
      Icon::LastFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_LOOP
      Icon::LoopIcon(fill, stroke, thickness) 
    Case Icon::#ICON_TRANSLATE
      Icon::TranslateIcon(fill, stroke, thickness) 
    Case Icon::#ICON_ROTATE
      Icon::RotateIcon(fill, stroke, thickness) 
    Case Icon::#ICON_SCALE
      Icon::ScaleIcon(fill, stroke, thickness) 
     Case Icon::#ICON_BRUSH
       Icon::BrushIcon(fill, stroke, thickness) 
     Case Icon::#ICON_PEN
       Icon::PenIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SELECT
       Icon::SelectIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SPLITH
       Icon::SplitHIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SPLITV
       Icon::SplitVIcon(fill, stroke, thickness) 
     Case Icon::#ICON_LOCKED
       Icon::LockedIcon(fill, stroke, thickness) 
     Case Icon::#ICON_UNLOCKED
       Icon::LockedIcon(fill, stroke, thickness) 
     Case Icon::#ICON_OP
       Icon::OpIcon(fill, stroke, thickness) 
     Case Icon::#ICON_TRASH
       Icon::TrashIcon(fill, stroke, thickness) 
     Case Icon::#ICON_STAGE
       Icon::StageIcon(fill, stroke, thickness)
     Case Icon::#ICON_LAYER
       Icon::LayerIcon(fill, stroke, thickness) 
     Case Icon::#ICON_FOLDER
       Icon::FolderIcon(fill, stroke, thickness) 
     Case Icon::#ICON_FILE
       Icon::FileIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SAVE
       Icon::SaveIcon(fill, stroke, thickness) 
     Case Icon::#ICON_OPEN
       Icon::OpenIcon(fill, stroke, thickness) 
     Case Icon::#ICON_HOME
       Icon::HomeIcon(fill, stroke, thickness) 
     Case Icon::#ICON_BACK
       Icon::BackIcon(fill, stroke, thickness) 
     Case Icon::#ICON_WARNING
       Icon::WarningIcon(fill, stroke, thickness) 
     Case Icon::#ICON_ERROR
       Icon::ErrorIcon(fill, stroke, thickness) 
  EndSelect
  StopVectorDrawing()
  
  FlipBuffer(image, *memory, resolution)
  
  FreeImage(image)
EndProcedure
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 55
; FirstLine = 29
; Folding = -
; EnableXP
XIncludeFile "../controls/Icon.pbi"

UsePNGImageEncoder()

DataSection
  swap_red_blue_mask:
  Data.a 2,1,0,3,6,5,4,7,10,9,8,11,14,13,12,15
EndDataSection

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

ProcedureDLL BuildIconInMemory(*memory, resolution, icon.i, fill.i=ControlIcon::#FILL_COLOR_DEFAULT, 
                               stroke.i=ControlIcon::#STROKE_COLOR_DEFAULT, thickness=ControlIcon::#STROKE_WIDTH)
  Define image.i = CreateImage(#PB_Any, resolution, resolution, 32)
  
  StartDrawing(ImageOutput(image))
  DrawingMode(#PB_2DDrawing_AlphaChannel)
  Box(0, 0, resolution, resolution, RGBA(0,0,0,0))
  StopDrawing()

  StartVectorDrawing(ImageVectorOutput(image))
  Select icon
    Case ControlIcon::#ICON_VISIBLE
      ControlIcon::VisibleIcon(fill, stroke, thickness)  
    Case ControlIcon::#ICON_INVISIBLE
      ControlIcon::InvisibleIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_PLAYFORWARD
      ControlIcon::PlayForwardIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_PLAYBACKWARD
      ControlIcon::PlayBackwardIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_STOP
      ControlIcon::StopIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_PREVIOUSFRAME
      ControlIcon::PreviousFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_NEXTFRAME
      ControlIcon::NextFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_FIRSTFRAME
      ControlIcon::FirstFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_LASTFRAME
      ControlIcon::LastFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_LOOP
      ControlIcon::LoopIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_TRANSLATE
      ControlIcon::TranslateIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_ROTATE
      ControlIcon::RotateIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_SCALE
      ControlIcon::ScaleIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_BRUSH
       ControlIcon::BrushIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_PEN
       ControlIcon::PenIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SELECT
       ControlIcon::SelectIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SPLITH
       ControlIcon::SplitHIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SPLITV
       ControlIcon::SplitVIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_LOCKED
       ControlIcon::LockedIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_UNLOCKED
       ControlIcon::LockedIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_OP
       ControlIcon::OpIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_TRASH
       ControlIcon::TrashIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_STAGE
       ControlIcon::StageIcon(fill, stroke, thickness)
     Case ControlIcon::#ICON_LAYER
       ControlIcon::LayerIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_FOLDER
       ControlIcon::FolderIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_FILE
       ControlIcon::FileIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SAVE
       ControlIcon::SaveIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_OPEN
       ControlIcon::OpenIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_HOME
       ControlIcon::HomeIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_BACK
       ControlIcon::BackIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_WARNING
       ControlIcon::WarningIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_ERROR
       ControlIcon::ErrorIcon(fill, stroke, thickness) 
  EndSelect
  StopVectorDrawing()
  
  FlipBuffer(image, *memory, resolution)
  
  FreeImage(image)
EndProcedure


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 127
; FirstLine = 70
; Folding = -
; EnableXP
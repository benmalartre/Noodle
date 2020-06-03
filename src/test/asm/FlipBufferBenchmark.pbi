XIncludeFile "../../core/Time.pbi"
Structure Data_t
  *input
  *output
  width.i
  height.i
EndStructure

DataSection
  swap_red_blue_mask:
  Data.a 2,1,0,3,6,5,4,7,10,9,8,11,14,13,12,15
EndDataSection

Procedure InitData(*data.Data_t, width.i, height.i)
  Define size = width * height * 4
  
  *data\width = width
  *data\height = height
  
  *data\input = AllocateMemory(size)
  *data\output = AllocateMemory(size)
  For i = 0 To size -1
    PokeA(*data\input + i, Random(255))
  Next
  
EndProcedure

Procedure CopyData(*src.Data_t, *dst.Data_t)
  Define size = *src\width * *src\height * 4
  
  *dst\width = *src\width
  *dst\height = *src\height
  
  *dst\input = AllocateMemory(size)
  *dst\output = AllocateMemory(size)
  CopyMemory(*src\input, *dst\input, size)
EndProcedure

  
Procedure FlipBufferRowsSSE(*data.Data_t)
  Define *input = *data\input + *data\width * *data\height * 4
  Define *output = *data\output
  Define num_pixels_in_row.i = *data\width 
  Define num_rows.i = *data\height 
  Define *mask = ?swap_red_blue_mask
  
  ! mov rsi, [p.p_input]                ; input buffer to rsi register
  ! mov rdi, [p.p_output]               ; output buffer to rdi register
  ! mov eax, [p.v_num_pixels_in_row]    ; image width in rax register
  ! mov ecx, [p.v_num_rows]             ; image height in rcx register
  ! mov r10, [p.p_mask]                 ; swap red and blue mask in r10 register
  ! movups xmm1, [r10]
  
  ! loop_over_rows:
  !   mov r11, rax                      ; reset pixels counter
  
  ! loop_over_pixels:
  !   sub rsi, 16                        ; reverse advance output ptr
  !   movups xmm0, [rsi]                ; load pixel to xmm0
  !   pshufb xmm0, xmm1                 ; shuffle bytes with mask
  !   movups [rdi], xmm0                ; set fixed color to output ptr
  !   add rdi, 16                        ; forward advance input ptr
  !   sub r11, 4                           ; decrement pixels counter
  !   jg loop_over_pixels               ; loop next pixel
  
  ! next_row:
  !   dec rcx                           ; decrement row counter
  !   jg loop_over_rows                 ; loop next row
EndProcedure

Structure Pixel_t
  r.a
  g.a
  b.a
  a.a
EndStructure

Procedure FlipBufferRows(*data.Data_t)
  Define num_pixels = *data\width * *data\height
  Define forward_p = 0
  Define reverse_p = (num_pixels - 1) * 4
  Define *input_pixel.Pixel_t
  Define *output_pixel.Pixel_t
  
  For i=0 To num_pixels - 1
    *input_pixel.Pixel_t = *data\input + reverse_p
    *output_pixel.Pixel_t = *data\output + forward_p
    
    *output_pixel\r = *input_pixel\b
    *output_pixel\g = *input_pixel\g
    *output_pixel\b = *input_pixel\r
    *output_pixel\a = *input_pixel\a
    reverse_p - 4
    forward_p + 4
  Next
EndProcedure

Procedure CompareDatas(*A.Data_t, *B.Data_t)
  ProcedureReturn CompareMemory(*A\output, *B\output, *A\width * *A\height * 4)  
EndProcedure

Procedure EchoData(*data.Data_t)
  Define s.s
  Define *p.Pixel_t
  For i=0 To *data\width * *data\height * 4 -1 Step 4
    *p = *data\output + i
    s + "("+Str(*p\r)+","+*p\g+","+*p\b+","+*p\a+"),"
  Next
  Debug s
EndProcedure

Time::Init()
Define A.Data_t
Define B.Data_t
Define N = 100
InitData(A, 1000, 1000)
CopyData(A, B)

Define PBT.d = 0
Define SSET.d = 0

Define T.d = Time::Get()
For i=0 To N
  FlipBufferRows(A)
  PBT + (Time::Get() - T)
  T = Time::Get()
Next

T.d = Time::Get()
For i=0 To N
  FlipBufferRowsSSE(B)
  SSET + (Time::Get() - T)
  T = Time::Get()
Next

; EchoData(A)
; EchoData(B)

MessageRequester("FlipBuffer Benchmark", "PB : "+StrD(PBT)+Chr(10)+"SSE : "+StrD(SSET)+Chr(10)+"Compare Results : "+Str(CompareDatas(A, B)))

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 103
; FirstLine = 83
; Folding = --
; EnableXP
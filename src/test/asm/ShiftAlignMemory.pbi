;----------------------------------------
; SHIFT ALIGN
;----------------------------------------
Structure Vector3
  x.f
  y.f
  z.f
EndStructure

Structure Vector4
  x.f
  y.f
  z.f
  w.f
EndStructure


Procedure.s Vector3ArrayString(*A, nb)
  Protected *v.Vector3
  Protected s.s
  If nb > 10
    For i=0 To 4
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+Chr(10)
    Next
    s+ "  ~     ~    ~   "+Chr(10)
    For i=nb-6 To nb-1
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+Chr(10)
    Next
  Else
    For i=0 To nb-1
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+Chr(10)
    Next
  EndIf
    
  ProcedureReturn s
EndProcedure

Procedure.s Vector4ArrayString(*A, nb)
  Protected *v.Vector4
  Protected s.s
  If nb > 10
    For i=0 To 4
      *v = *A + i * SizeOf(Vector4)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","+StrF(*v\w,3)+Chr(10)
    Next
    s+ "  ~     ~    ~    ~   "+Chr(10)
    For i=nb-6 To nb-1
      *v = *A + i * SizeOf(Vector4)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","+StrF(*v\w,3)+Chr(10)
    Next
  Else
    For i=0 To nb-1
      *v = *A + i * SizeOf(Vector4)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","+StrF(*v\w,3)+Chr(10)
    Next
  EndIf
  ProcedureReturn s
EndProcedure

; Procedure ShiftAlignPB(*av, nb.i)
;   Define iv4 = (nb-1) * SizeOf(Vector4)
;   Define iv3 = (nb-1) * SizeOf(Vector3)
;   Define *v3.Vector3
;   Define *v4.Vector4
;   While nb >= 0
;     *v3 = *av + iv3
;     *v4 = *av + iv4
;     *v4\x = *v3\x
;     *v4\y = *v3\y
;     *v4\z = *v3\z
;     *v4\w = 0
;     iv4 - SizeOf(Vector4)
;     iv3 - SizeOf(Vector3)
;     nb - 1  
;   Wend
; EndProcedure
; 
; Procedure UnshiftAlignPB(*av, nb.i)
;   Define *v3.Vector3
;   Define *v4.Vector4
;   Define i
;   For i=1 To nb-1
;     *v3 = *av + i * SizeOf(Vector3)
;     *v4 = *av + i * SizeOf(Vector4)
;     *v3\x = *v4\x
;     *v3\y = *v4\y
;     *v3\z = *v4\z
;   Next
; EndProcedure

;----------------------------------------------------------------
; Shift Align
;----------------------------------------------------------------
Procedure ShiftAlign(*data, nb.i, src_size, dst_size.i)
  If dst_size > src_size
    Define offset_dst = (nb-1) * dst_size
    Define offset_src = (nb-1) * src_size
    
    Define *src, *dst
    While nb >= 0
      *src = *data + offset_src
      *dst = *data + offset_dst
      MoveMemory(*src, *dst, src_size)
      FillMemory(*dst + src_size, dst_size-src_size, 0)
      iv4 - dst_size
      iv3 - src_size
      nb - 1  
    Wend
  EndIf
EndProcedure

;----------------------------------------------------------------
; Unshift Align
;----------------------------------------------------------------
Procedure UnshiftAlign(*data, nb.i, src_size, dst_size.i)
  If dst_size < src_size
    Define *src, *dst
    Define i
    For i=1 To nb-1
      *src = *data + i * src_size
      *dst = *data + i * dst_size
      MoveMemory(*src, *dst, src_size)
    Next
    FillMemory(*data + nb * dst_size, nb * src_size - nb * dst_size, 0)
  EndIf
EndProcedure

Procedure ShiftAlignSSE(*av3, *av4, nb.i)
  
EndProcedure

Define nb.i = 1280000
Define *av = AllocateMemory(SizeOf(Vector4)*nb)


Define *v3.Vector3
Define *v4.Vector4
For i=0 To nb-1
  *v3 = *av + i * SizeOf(Vector3)
  *v3\x = i
  *v3\y = i
  *v3\z = i
Next

Define arrayStr1.s = Vector3ArrayString(*av, nb)
Define T.q = ElapsedMilliseconds()
ShiftAlign(*av, nb, SizeOf(Vector3), SizeOf(Vector4))
Define TSHIFT.q = ElapsedMilliseconds() - T
Define arrayStr2.s = Vector4ArrayString(*av, nb)

Define T.q = ElapsedMilliseconds()
UnshiftAlign(*av, nb, SizeOf(Vector4), SizeOf(Vector3))
Define TUNSHIFT.q = ElapsedMilliseconds() - T
Define arrayStr3.s = Vector3ArrayString(*av, nb)

MessageRequester("SHIFT ALIGN MEMORY", "SHIFT : "+Str(TSHIFT)+" vs UNSHIFT : "+Str(TUNSHIFT)+Chr(10)+
                                       "----------------------------------------------"+Chr(10)+
                                       arrayStr1+Chr(10)+
                                       "----------------------------------------------"+Chr(10)+
                                       arrayStr2+Chr(10)+
                                       "----------------------------------------------"+Chr(10)+
                                       arrayStr3+Chr(10))

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 134
; FirstLine = 107
; Folding = -
; EnableXP
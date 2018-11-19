Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure



; Conversely, getting the minimum:
; 
; movhlps xmm1,xmm0
; minps   xmm0,xmm1
; pshufd  xmm1,xmm0,$55
; minps   xmm0,xmm1

Procedure HorizontalMaximum(*v.v3f32)
  ! mov rdx, [p.p_v]
  ! movups xmm0, [rdx]  
  ! movhlps xmm1,xmm0         ; Move top two floats to lower part of xmm1
  ! maxps   xmm0,xmm1         ; Get maximum of the two sets of floats
  ! pshufd  xmm1,xmm0,$55     ; Move second float to lower part of xmm1
  ! maxps   xmm0,xmm1         ; Get maximum of the two remaining floats
 
  ! movups [rdx], xmm0
  
  Debug *v\x
  Debug *v\y
  Debug *v\z
  Debug *v\w
EndProcedure

Procedure HorizontalMinimum(*v.v3f32)
  ! mov rdx, [p.p_v]
  ! movups xmm0, [rdx]  
  ! movhlps xmm1,xmm0         ; Move top two floats to lower part of xmm1
  ! minps   xmm0,xmm1         ; Get minimum of the two sets of floats
  ! pshufd  xmm1,xmm0,$55     ; Move second float to lower part of xmm1
  ! minps   xmm0,xmm1         ; Get minimum of the two remaining floats
 
  ! movups [rdx], xmm0
  
  Debug *v\x
  Debug *v\y
  Debug *v\z
  Debug *v\w
EndProcedure

Define v.v3f32
v\x = 7
v\y = 4
v\z = 1
v\w = 9
  
HorizontalMaximum(v)

Define v.v3f32
v\x = 8
v\y = 5
v\z = 2
v\w = 11
  
HorizontalMinimum(v)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 24
; FirstLine = 5
; Folding = -
; EnableXP
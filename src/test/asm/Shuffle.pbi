

Structure Vector3
  x.f
  y.f
  z.f
  w.f
EndStructure



Macro MakeShuffleMask(_x,_y,_z,_w)
  (_x | (_y<<2) | (_z<<4) | (_w<<6))
EndMacro

Macro BroadcastSSEFloat1(SourceRegister, DestinationRegister)
  !shufps #DestinationRegister, #SourceRegister, 00000000b
EndMacro

Macro BroadcastSSEFloat2(SourceRegister, DestinationRegister)
  !shufps #DestinationRegister, #SourceRegister, 01010101b
EndMacro

Macro BroadcastSSEFloat3(SourceRegister, DestinationRegister)
  !shufps #DestinationRegister, #SourceRegister, 10101010b
EndMacro

Macro BroadcastSSEFloat4(SourceRegister, DestinationRegister)
  !shufps #DestinationRegister, #SourceRegister, 11111111b
EndMacro



Macro VecSwizzle(_v,_x,_y,_z,_w)
  Define _m.c = MakeShuffleMask(_x,_y,_z,_w)
  EnableASM 
  MOV rdi, _v
  DisableASM
  !movups xmm0, [rdi]
  !shufps xmm0, xmm0, 00000000b
  !movups [rdi], xmm0
EndMacro

Macro Vector3_Dot(_a, _b)
  EnableASM
  MOV rdi, _a
  MOV rsi, _b
  DisableASM
  
  ! movups xmm6, [rdi]           ;le U signifie qu'on ne suppose pas que les données sont alignées à 128 bits
  ! shufps xmm6, xmm6, 9         ;= 1 + 8, c'est-à-dire une rotation des 3 composantes
  ! movups xmm7, [rsi]
  ! shufps xmm7, xmm7, 18        ;= 2 + 16, c'est-à-dire une rotation dans l'autre sens
  ! movaps xmm0,xmm6             ;premier produit pour chaque composante
  ! mulps xmm0,xmm7
  ! movups xmm6, vS1
  ! shufps xmm6, xmm6, 18
  ! movups xmm7, vS2
  ! shufps xmm7, xmm7, 9
  ! mulps xmm7,xmm6              ;deuxième produit retranché pour chaque composante
  ! subps xmm0,xmm7
  
EndMacro

Define v.Vector3
v\x = 6.666
v\y = 5.432
v\z = 3.213
v\w = 65439

Define a.Vector3
a\x = 1
a\y = 2
a\z = 3
a\w = 4

Define b.Vector3
b\x = 0.128
b\y = 0.256
b\z = 0.512
b\w = 0.1024



Debug StrF(a\x,3)+", "+StrF(a\y,3)+", "+StrF(a\z,3)+", "+StrF(a\w,3)
Debug StrF(b\x,3)+", "+StrF(b\y,3)+", "+StrF(b\z,3)+", "+StrF(b\w,3)

!mov rdi, v_a
!mov rsi, v_b
!movups xmm0, [rdi]
!movups xmm1, [rsi]
! shufps xmm0, xmm1, 10011001b
!movups [rdi], xmm0


Debug StrF(a\x,3)+", "+StrF(a\y,3)+", "+StrF(a\z,3)+", "+StrF(a\w,3)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 49
; FirstLine = 36
; Folding = --
; EnableXP
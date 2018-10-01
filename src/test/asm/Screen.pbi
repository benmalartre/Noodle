   !JMP     finproginit
   ;---------------------------  resolution ecran ------------------------
!initecran:
   !LEA     eax,[adecran]
   !MOV     [ecranlog],eax 
   !LEA     eax,[adzbuffer]
   !MOV     [madzbuffer],eax 
   !CALL    initport
   !CMP     dword[resolu],640
   !JE      ecr640 
   !CMP     dword[resolu],800
   !JE      ecr800 
   !CMP     dword[resolu],1024
   !JE      ecr1024 
   !CMP     dword[resolu],1280
   !JE      ecr1280 
   !RET
!ecr640:
   OpenScreen(640,480, 32, "") 
   !CALL    starrdd
   !MOV     dword[largecr],2560
   !MOV     dword[nbpixel],76800     
   !RET
!ecr800:
   OpenScreen(800,600, 32, "") 
   !CALL    starrdd
   !MOV     dword[largecr],3584
   !MOV     dword[nbpixel],120000     
   !RET
!ecr1024:
   OpenScreen(1024,768, 32, "") 
   !CALL    starrdd
   !MOV     dword[largecr],4096
   !MOV     dword[nbpixel],196608     
   !RET
!ecr1280:
   OpenScreen(1280,1024, 32, "") 
   !CALL    starrdd
   !MOV     dword[largecr],5120
   !MOV     dword[nbpixel],327680     
   !RET
   ;--------------------------------------------------------------------------
   ;--------------------- clavier ,souris ------------------------------------     
!initport:
   InitSprite() 
   InitKeyboard() 
   InitMouse() 
   !RET  
!starrdd: 
   StartDrawing(ScreenOutput()) 
   addecr1 = DrawingBuffer() 
   StopDrawing()
   FlipBuffers()
   StartDrawing(ScreenOutput()) 
   !MOV     eax,[v_addecr1]
   !MOV     [ecranphy],eax
   !ret
!finprog:
   StopDrawing()
   ExamineKeyboard() 
   If KeyboardPushed(#PB_Key_Escape) 
   End 
   EndIf 
   StartDrawing(ScreenOutput())
   !RET
!souris:  
   ExamineMouse()
   moux=MouseX()
   mouy=MouseY()
   !PUSH    eax  
   !MOV     eax,[v_moux]
   !MOV     [xsouris],eax
   !MOV     eax,[v_mouy]
   !MOV     [ysouris],eax
   !POP     eax
   !RET
!clavier:
   ExamineKeyboard()  
   clav$=KeyboardInkey()
   clav=Asc(clav$)
   !PUSH    eax
   !MOV     al,byte[v_clav]
   !MOV     byte[codeclav],al
   !POP     eax 
   !RET
   ;-------------------------------------------------------------------------------------
   ;--transfere le buffer ecran sur l ecran physique et efface le buffer ecran et z buffer------------------  
!flipclsz: 
   !MOV     ecx,[nbpixel]
   !MOV     edi,[ecranphy]
   !MOV     esi,[ecranlog]
   !MOV     ebp,[madzbuffer]
   !MOVaps  xmm1,[noir];gris
   !MOVaps  xmm2,[noir]
!fgh:
   !MOVaps  xmm0,[esi] 
   !MOVaps  [esi],xmm1
   !MOVaps  [edi],xmm0
   !MOVaps  [ebp],xmm2
   !ADD     esi,16
   !ADD     edi,16
   !ADD     ebp,16
   !LOOP    fgh  
   !RET   ;-----------------------------------------------------------------
   ;--transfere le buffer ecran sur l ecran physique et efface le buffer ecran ------------------  
!flipcls: 
   !MOV     ecx,[nbpixel]
   !MOV     edi,[ecranphy]
   !MOV     esi,[ecranlog]
   !MOVaps  xmm1,[noir];gris
!fgh2:
   !MOVaps  xmm0,[esi] 
   !MOVaps  [esi],xmm1
   !MOVaps  [edi],xmm0
   !ADD     esi,16
   !ADD     edi,16
   !LOOP    fgh2  
   !RET   ;-----------------------------------------------------------------   
    ;----------------transfere le buffer ecran sur l ecran physique ------------------  
!flip: 
   !MOV     ecx,[nbpixel]
   !MOV     edi,[ecranphy]
   !MOV     esi,[ecranlog]
!fgh3:
   !MOVaps  xmm0,[esi] 
   !MOVaps  [esi],xmm1
   !ADD     esi,16
   !LOOP    fgh3  
   !RET   ;-----------------------------------------------------------------  
!efface_ecr: ;----------------  efface le buffer ecran --------------------------  
   !MOV     ecx,[nbpixel]
   !MOV     esi,[ecranlog]
   !MOVaps  xmm0,[gris]
!fgh0:
   !MOVaps  [esi],xmm0
   !ADD     esi,16
   !LOOP    fgh0   
   !RET  ;------------------------------------------------------------------------
!efface_zbuf: ;----------------  efface le zbuffer  --------------------------  
   !MOV     ecx,[nbpixel]
   !MOV     esi,[madzbuffer]
   !MOVaps  xmm0,[noir]
!fgh01:
   !ADD     esi,16
   !LOOP    fgh01   
   !RET  ;------------------------------------------------------------------------
;---------------- converti une image bmp 24 bits en bmp 32 bits--------------------- 
!transimage:  
   !LEA     edi,[image]
   !MOV     ecx,1024
   !MOV     [imagex],ecx
   !MOV     edx,863
   !MOV     [imagey],edx
   !MOV     ebp,1024
   !SUB     ebp,ecx
   !SAL     ebp,2
   !MOV     ebx,ecx
   !ADD     edi,036h
   !LEA     esi,[mimage]
   !MOV     [adimage],esi
!ima01:
   !MOV     eax,[edi]
   !And     eax,00ffffffh 
   !MOV     [esi],eax
   !ADD     edi,3
   !ADD     esi,4
   !LOOP    ima01  
   !MOV     ecx,ebx
   !DEC     edx
   !JA      ima01 
   !RET
   ;------------------------------------------------------------------------------

   ;------------------------------------------------------------------------------
!section '.data' align 16
!resolu:
   !dd      0 
!largecr:
   !dd      0
!nbpixel:
   !dd      0
!xsouris:
   !dd      0
!ysouris:
   !dd      0
!codeclav:
   !dd      0

!section '.data' align 16
!adecran:
   !rd      1310720
!mimage:
   !rd      1310720 
!finproginit:
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 193
; EnableXP
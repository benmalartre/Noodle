;Note that either you have to change the Compiler/Compiler Options to allow
;Inline ASM Support for this code to compile correctly.

;Note that statements in ASM (Assembler) that refer to line lables have a "l_"
;(small L with underscore) added in front when referenced by an ASM instruction,
;and the characters must be in lower case.  The actual line labels can be in
;mixed case, as illustrated in this code.

Procedure.s x_propercase(s.s)  ;convert all groups of letters to Ucase form
  Protected *sptr = @s
  !  MOV eax, [p.p_sptr]         ;string pointer on stack (pointed to by esp) into EAX reg      
  !  XOr dl, dl                  ;clear garbage for DL
  !cycle:                        ;return point to repeat for each character in string   
  !  MOV dh,dl                   ;save the last processed char in DH 
  !  MOV dl,[eax]                ;get the next character to process in DL
  !  TEST dl,dl                  ;set flags against same register to check value           
  !  JZ endstring              ;character is zero (Null), so exit process
  !  And dx,$DFDF                ;get rid of lower case flag in DH and DL registers
  !  CMP dl, 'Z'                 ;compare the value in DL with 90 (ascii code for 'Z')  
  !  JA not_alpha              ;if above 'Z', it is not an Alpha character
  !  CMP dl, 'A'                 ;compare the value in DL with 65 (ascii code for 'A')
  !  JB not_alpha              ;if below 'A', it is not an Alpha character
  !  CMP dh, 'A'                 ;compare last character with 65 (ascii code for 'A')
  !  JB high                   ;if below 'A', we keep the current letter in UPPER case  
  !  CMP dh, 'Z'                 ;compare last character with 90 (ascii code for 'Z')
  !  JA high                   ;if above 'Z', we keep the current letter in UPPER case  
  !low:                          ;otherwise, we have two or more alpha characters in a row
  !  OR dl, $20                  ;and we force the current letter to lower case  
  !high:                         ;and this is where the UPPER case letters merge in again  
  !  MOV [eax], dl               ;so that we can store the correct case letter back
  !not_alpha:                   ;or we skipped if current character not an Alpha character
  !  INC eax                     ;we increment the string pointer for s.s to next character 
  !  JMP cycle                 ;and jump back to repeat for the next character  
  !endstring: 
   ProcedureReturn s           ;we make sure the changes are returned. 
EndProcedure 

OpenConsole()
ConsoleColor(15,1)
PrintN(x_propercase("thiS iS a tESt of pROper *C*a(se)s."))
While Inkey()=""
Wend
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 20
; Folding = -
; EnableXP
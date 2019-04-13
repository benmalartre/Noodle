InitScintilla()

; -----------------------------------------
; UI Module Declaration
; -----------------------------------------
DeclareModule UI
  Enumeration
    #UI_DUMMY
    #UI_GRAPH
    #UI_3D
    #UI_SHADER
    #UI_COLOR
    #UI_LOG
    #UI_TIMELINE
    #UI_ANIMATION_EDITOR
  EndEnumeration
  
  Structure UI_t Extends Control::Control_t
    lastX.i
    lastY.i
    offsetX.i
    offsetY.i

    container.i
    dirty.b
    down.b
    zoom.f
    
    imageID.i
    iSizX.i
    iSizY.i
    
    scrollable.b
    scrolling.b
    scrollX.i
    scrollY.i
    scrollMaxX.i
    scrollMaxY.i
    scrollLastX.i
    scrollLastY.i
    
    active.b
  EndStructure
  
  Interface IUI
    Init()
    Event(event.i)
    Term()
  EndInterface
  
  
;   Global img_local_only.i
;   Global img_server_only.i
;   Global img_local_new.i
;   Global img_server_new.i
;   Global img_sync.i
;   Global img_folder_sync.i
;   Global img_folder_server_only.i
;   Global img_folder_local_only.i
;   
;   Declare Init()
;   Declare Term()
  
  Declare GetScrollArea(*Me.UI_t)
  Declare Scroll(*Me.UI_t,mode.b =#False)
   
  
EndDeclareModule

; -----------------------------------------
; UI Module Implementation
; -----------------------------------------
Module UI
  Procedure GetName(*ui.UI_t)
    MessageRequester(*ui\name,*ui\name)
  EndProcedure
  
  Procedure GetScrollArea(*Me.UI_t)
  If *Me\scrollable
    *Me\scrolling = #False
    If *Me\sizX>*Me\iSizX : *Me\scrollMaxX = 0 : Else : *Me\scrollMaxX = *Me\iSizX-*Me\sizX : EndIf
    If *Me\sizY>*Me\iSizY : *Me\scrollMaxY = 0 : Else : *Me\scrollMaxY = *Me\iSizY-*Me\sizY : EndIf
  EndIf
  
EndProcedure

Procedure Scroll(*Me.UI_t,mode.b =#False)

  If *Me\scrollable And (*Me\scrolling Or mode = #True)
    If mode = #True
      Protected d = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_WheelDelta)
      *Me\scrollY + d*22
    Else
      
      Protected x = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
      Protected y = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
      *Me\scrollX + (x-*Me\scrollLastX)
      *Me\scrollY + (y-*Me\scrollLastY)
      *Me\scrollLastX = x
      *Me\scrollLastY = y
    EndIf
    
    If *Me\scrollX>0 : *Me\scrollX = 0 : EndIf
    If *Me\scrollY>0 : *Me\scrollY = 0 : EndIf
    If *Me\scrollX<-*Me\scrollMaxX : *Me\scrollX = -*Me\scrollMaxX : EndIf
    If *Me\scrollY<-*Me\scrollMaxY : *Me\scrollY = -*Me\scrollMaxY : EndIf
    
  EndIf
EndProcedure
  
    
;   UsePNGImageDecoder()
;    ; Init
;   ;-------------------------------
;   Procedure Init()
;     img_local_only = LoadImage(#PB_Any,GetCurrentDirectory()+"ico/FileLocalOnly_raw.png")
;     img_server_only = LoadImage(#PB_Any,GetCurrentDirectory()+"ico/FileServerOnly_raw.png")
;     img_local_new = LoadImage(#PB_Any,GetCurrentDirectory()+"ico/FileLocalNew_raw.png")
;     img_server_new = LoadImage(#PB_Any,GetCurrentDirectory()+"ico/FileServerNew_raw.png")
;     img_sync = LoadImage(#PB_Any,GetCurrentDirectory()+"ico/FileSync_raw.png")
;     img_folder_sync = LoadImage(#PB_Any,GetCurrentDirectory()+"ico/FolderSync_raw.png")
;     img_folder_server_only = LoadImage(#PB_Any,GetCurrentDirectory()+"ico/FolderServerOnly_raw.png")
;   EndProcedure
;   
;   ; Term
;   ;-------------------------------
;   Procedure Term()
;     If IsImage(img_local_only):FreeImage(img_local_only):EndIf
;     If IsImage(img_server_only):FreeImage(img_server_only):EndIf
;     If IsImage(img_local_new):FreeImage(img_local_new):EndIf
;     If IsImage(img_server_new):FreeImage(img_server_new):EndIf
;     If IsImage(img_sync):FreeImage(img_sync):EndIf
;   EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 30
; Folding = -
; EnableXP
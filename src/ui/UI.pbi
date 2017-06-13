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
  EndEnumeration
  
  Structure UI_t Extends Object::Object_t
    name.s
    x.i
    y.i
    lastx.i
    lasty.i
    offsetx.i
    offsety.i
    width.i
    height.i
    container.i
    type.i
    dirty.b
    down.b
    zoom.i
    gadgetID.i
    
    imageID.i
    iwidth.i
    iheight.i
    
    scrollable.b
    scrolling.b
    scrollx.i
    scrolly.i
    scrollmaxx.i
    scrollmaxy.i
    scrolllastx.i
    scrolllasty.i
    
    active.b
    *top
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
    If *Me\width>*Me\iwidth : *Me\scrollmaxx = 0 : Else : *Me\scrollmaxx = *Me\iwidth-*Me\width : EndIf
    If *Me\height>*Me\iheight : *Me\scrollmaxy = 0 : Else : *Me\scrollmaxy = *Me\iheight-*Me\height : EndIf
  EndIf
  
EndProcedure

Procedure Scroll(*Me.UI_t,mode.b =#False)

  If *Me\scrollable And (*Me\scrolling Or mode = #True)
    If mode = #True
      Protected d = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_WheelDelta)
      *Me\scrolly + d*22
    Else
      
      Protected x = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseX)
      Protected y = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_MouseY)
      *Me\scrollx + (x-*Me\scrolllastx)
      *Me\scrolly + (y-*Me\scrolllasty)
      *Me\scrolllastx = x
      *Me\scrolllasty = y
    EndIf
    
    If *Me\scrollx>0 : *Me\scrollx = 0 : EndIf
    If *Me\scrolly>0 : *Me\scrolly = 0 : EndIf
    If *Me\scrollx<-*Me\scrollmaxx : *Me\scrollx = -*Me\scrollmaxx : EndIf
    If *Me\scrolly<-*Me\scrollmaxy : *Me\scrolly = -*Me\scrollmaxy : EndIf
    
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
; IDE Options = PureBasic 5.41 LTS (Linux - x64)
; CursorPosition = 46
; FirstLine = 30
; Folding = -
; EnableXP
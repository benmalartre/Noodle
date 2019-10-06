InitScintilla()
XIncludeFile "../core/Control.pbi"
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
    last_x.i
    last_y.i
    
    active.b
  EndStructure
  
  Interface IUI
    Delete()
    Resize(x.i, y.i, width.i, height.i)
    Draw()
    DrawPickImage()
    Pick(mx.f, my.f)
    OnEvent(event.i)
  EndInterface
  
  
  ; ------------------------------------------------------------------
  ;   DECLARE
  ; ------------------------------------------------------------------
  Declare Resize(*ui.UI_t, x.i, y.i, width.i, height.i)
  Declare Draw(*ui.UI_t)
  Declare DrawPickImage(*ui.UI_t)
  Declare Pick(*ui.UI_t, mx.f, my.f)
  Declare OnEvent(*ui.UI_t)
  Declare GetScrollArea(*Me.UI_t)
  Declare Scroll(*Me.UI_t,mode.b =#False)
  
EndDeclareModule

; -----------------------------------------
; UI Module Implementation
; -----------------------------------------
Module UI
  ; -------------------------------------------------------------------
  ;   RESIZE (DUMMY)
  ; -------------------------------------------------------------------
  Procedure Resize(*ui.UI_t, x.i, y.i, width.i, height.i)
    
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   DRAW
  ; -------------------------------------------------------------------
  Procedure Draw(*ui.UI_t)
    StartVectorDrawing(CanvasVectorOutput(*ui\gadgetID))
    AddPathBox(0,0,GadgetWidth(*ui\gadgetID), GadgetHeight(*ui\gadgetID))
    VectorSourceColor(UICOLOR::BACK)
    FillPath()
    
;     Define ctrl.Control::IControl
;     For i=0 To ArraySize(*ui\())-1
;       ctrl = *ui\items(i)
;       ctrl\Draw()
;     Next
    StopVectorDrawing()
    
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   DRAW PICK IMAGE
  ; -------------------------------------------------------------------
  Procedure DrawPickImage(*ui.UI_t)
    StartVectorDrawing(ImageVectorOutput(*ui\imageID))
    AddPathBox(0,0,ImageWidth(*ui\imageID), ImageHeight(*ui\imageID))
    VectorSourceColor(RGBA(0,0,0,255))
    FillPath()
    
;     Define ctrl.Control::IControl
;     For i=0 To ArraySize(*ui\childrens())-1
;       ctrl = *ui\childrens(i)
;       ctrl\DrawPickImage(i+1)
;     Next
    StopVectorDrawing()
    
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   PICK
  ; -------------------------------------------------------------------
  Procedure Pick(*ui.UI_t, mx.f, my.f)
    Define pick = 0
    StartDrawing(ImageOutput(*ui\imageID))
    If mx >-1 And mx < ImageWidth(*ui\imageID) And my> -1 And my < ImageHeight(*ui\imageID)
      pick = Point(mx, my)
    EndIf
    StopDrawing()
    ProcedureReturn pick-1
  EndProcedure
  
  ; -------------------------------------------------------------------
  ;   ON EVENT
  ; -------------------------------------------------------------------
  Procedure OnEvent(*ui.UI_t)
  EndProcedure
  
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
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 132
; FirstLine = 102
; Folding = --
; EnableXP
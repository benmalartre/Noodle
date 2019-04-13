XIncludeFile "Layer.pbi"

; ============================================================================
;   Layer Manager Module Declaration
; ============================================================================
DeclareModule LayerManager
  ; STRUCTURE
  ; ------------------------------------------------------
  Structure LayerManager_t
    List *layers.Layer::Layer_t() 
    *active.Layer::Layer_t
  EndStructure
  
  ; DECLARATIONS
  ; ------------------------------------------------------
  Declare Init(*Me.LayerManager_t)
  Declare Term(*Me.LayerManager_t)
  Declare AddLayer(*Me.LayerManager_t, *layer.Layer::Layer_t)
  Declare RemoveLayer(*Me.LayerManager_t, *layer.Layer::Layer_t)
EndDeclareModule

; ============================================================================
;   Layer Manager Module Implementation
; ============================================================================
Module LayerManager
  ; INIT
  ; ------------------------------------------------------
  Procedure Init(*Me.LayerManager_t)
    InitializeStructure(*Me, LayerManager_t)
  EndProcedure
  
  ; TERM
  ; ------------------------------------------------------
  Procedure Term(*Me.LayerManager_t)
    ClearStructure(*Me, LayerManager_t)
  EndProcedure
  
  ; ADD LAYER
  ; ------------------------------------------------------
  Procedure AddLayer(*Me.LayerManager_t, *layer.Layer::Layer_t)
    LastElement(*Me\layers())
    AddElement(*Me\layers())
    *Me\layers()= *layer
  EndProcedure
  
  ; REMOVE LAYER
  ; ------------------------------------------------------
  Procedure.b RemoveLayer(*Me.LayerManager_t, *layer.Layer::Layer_t)
    ForEach *Me\layers()
      If *Me\layers() = *layer
        DeleteElement(*Me\layers())
        ProcedureReturn #True
      EndIf
    Next
    Procedure #False
  EndProcedure
  
EndModule
; ============================================================================
;   EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 21
; Folding = --
; EnableXP
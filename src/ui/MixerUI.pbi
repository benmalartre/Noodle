
XIncludeFile "../core/Log.pbi"
XIncludeFile "UI.pbi"

; -----------------------------------------
; MixerUI Module Declaration
; -----------------------------------------
DeclareModule MixerUI
  Structure MixerUI_t Extends UI::UI_t
    area.i
    frame.i
    canvas.i
  EndStructure
  
  Declare New(name.s,x.i,y.i,w.i,h.i)
  Declare Delete(*Me.MixerUI_t)
;   Declare Draw(*Me.MixerUI_t)
  Declare Init(*Me.MixerUI_t)
  Declare Event(*Me.MixerUI_t,event.i)
  Declare Term(*Me.MixerUI_t)
  
  DataSection 
    MixerUIVT: 
    Data.i @Init()
    Data.i @Event()
    Data.i @Term()
  EndDataSection 
EndDeclareModule

; -----------------------------------------
; MixerUI Module Implementation
; -----------------------------------------
Module MixerUI
  ; Constructor
  ;-------------------------------
  Procedure New(name.s,x.i,y.i,w.i,h.i)
    Protected *ui.MixerUI_t = AllocateStructure(MixerUI_t)
    Object::INI(MixerUI)
    *ui\name = name
    *ui\x = x
    *ui\y = y
    *ui\width = w
    *ui\height = h
    *ui\container = ContainerGadget(#PB_Any,x,y,w,h)
    *ui\frame = FrameGadget(#PB_Any,0,0,w,h,"Log")
    
    
    *ui\canvas = CanvasGadget(#PB_Any,5,20,w-10,h-25,s)
   

    ;SetGadgetColor(*ui\area,#PB_Gadget_BackColor,RGB(222,222,222))
    CloseGadgetList()
    ProcedureReturn *ui
  EndProcedure
  
  ; Destructor
  ;-------------------------------
  Procedure Delete(*Me.MixerUI_t)
    If IsGadget(*Me\container): FreeGadget(*Me\container): EndIf
    If IsGadget(*Me\frame): FreeGadget(*Me\frame): EndIf
    If IsGadget(*Me\canvas): FreeGadget(*Me\canvas): EndIf
    Object::TERM(MixerUI)
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*Me.MixerUI_t)
    
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure Event(*Me.MixerUI_t,event.i)
    Select event
      Case #PB_Event_SizeWindow
        ResizeGadget(*Me\frame,0,0,GadgetWidth(*Me\container),GadgetHeight(*Me\container))
        ResizeGadget(*Me\area,5,20,GadgetWidth(*Me\container)-10,GadgetHeight(*Me\container)-25)
      Case #PB_Event_Gadget
        Select EventGadget()
          Case *Me\area
            Select EventType()
              Case #PB_EventType_Change
                ClearGadgetItems(*Me\area)
                ForEach Log::*LOGMACHINE\msgs()
                  AddGadgetItem(*Me\area,-1,Log::*LOGMACHINE\msgs()\msg)
                Next
                SetGadgetState(*Me\area,CountGadgetItems(*Me\area)-1)
            EndSelect
        EndSelect
        
        
    EndSelect
    
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*Me.MixerUI_t)
    
  EndProcedure
  
  
;   Procedure Draw(*Me.MixerUI_t)
;     ClearGadgetItems(*Me\area)
;     ForEach Log::*LOGMACHINE\msgs()
;       AddGadgetItem(*Me\area,-1,Log::*LOGMACHINE\msgs()\msg)
;     Next
;     SetGadgetState(*Me\area,CountGadgetItems(*Me\area)-1)
;     
;   EndProcedure
  
  
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 61
; FirstLine = 32
; Folding = --
; EnableXP
; EnableUnicode

XIncludeFile "../core/Log.pbi"
XIncludeFile "UI.pbi"

; -----------------------------------------
; LogUI Module Declaration
; -----------------------------------------
DeclareModule LogUI
  Structure LogUI_t Extends UI::UI_t
    area.i
    frame.i
  EndStructure
  
  Declare New(*parent.View::View_t,name.s)
  Declare Delete(*Me.LogUI_t)
;   Declare Draw(*Me.LogUI_t)
  Declare Init(*Me.LogUI_t)
  Declare Event(*Me.LogUI_t,event.i)
  Declare Term(*Me.LogUI_t)
  
  DataSection 
    LogUIVT: 
    Data.i @Init()
    Data.i @Event()
    Data.i @Term()
  EndDataSection 
EndDeclareModule

; -----------------------------------------
; LogUI Module Implementation
; -----------------------------------------
Module LogUI
  ; Constructor
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s)
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
    
    
    Protected *Me.LogUI_t = AllocateMemory(SizeOf(LogUI_t))
    
    Object::INI(LogUI)
    *Me\name = name
    *Me\x = x
    *Me\y = y
    *Me\width = w
    *Me\height = h
    *Me\container = ContainerGadget(#PB_Any,x,y,w,h)
    *Me\frame = FrameGadget(#PB_Any,0,0,w,h,"Log")
    
    
    *Me\area = EditorGadget(#PB_Any,5,20,w-10,h-25,s)
    SetGadgetAttribute(*Me\area,#PB_Editor_ReadOnly,#True)
;     SetGadgetColor(*Me\area,#PB_Gadget_BackColor,RGB(20,20,20))
;     SetGadgetColor(*Me\area,#PB_Gadget_FrontColor,RGB(100,255,160))

    ;SetGadgetColor(*Me\area,#PB_Gadget_BackColor,RGB(222,222,222))
    CloseGadgetList()
    
    View::SetContent(*parent,*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;-------------------------------
  Procedure Delete(*Me.LogUI_t)
    If IsGadget(*Me\container): FreeGadget(*Me\container): EndIf
    FreeMemory(*Me)
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*Me.LogUI_t)
    
  EndProcedure
  
   ; Scroll To End
  ;-------------------------------
  Procedure ScrollToEnd(*Me.LogUI_t)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux
        Protected *Adjustment.GtkAdjustment
  
        *Adjustment.GtkAdjustment = gtk_scrolled_window_get_vadjustment_(gtk_widget_get_parent_(GadgetID(*Me\area)))
        *Adjustment\value = *Adjustment\upper
        gtk_adjustment_value_changed_(*Adjustment)     
      CompilerCase #PB_OS_MacOS
        Protected Range.NSRange
  
        Range.NSRange\location = Len(GetGadgetText(*Me\area))
        CocoaMessage(0, GadgetID(*Me\area), "scrollRangeToVisible:@", @Range)
      CompilerCase #PB_OS_Windows
        SendMessage_(GadgetID(*Me\area), #EM_SETSEL, -1, -1) 
  CompilerEndSelect
EndProcedure
  
  ; Write
  ;-------------------------------
  Procedure Write(*Me.LogUI_t)
    ForEach Log::*LOGMACHINE\msgs()
      AddGadgetItem(*Me\area,-1,Log::*LOGMACHINE\msgs()\msg)
      DeleteElement(Log::*LOGMACHINE\msgs())
    Next
    ;SetGadgetState(*Me\area,CountGadgetItems(*Me\area)-1)
    ScrollToEnd(*Me)
    
  EndProcedure
      
  
  ; Event
  ;-------------------------------
  Procedure Event(*Me.LogUI_t,event.i)

    Select event
      Case Globals::#EVENT_COMMAND_CALLED

        Write(*Me)
      Case Globals::#EVENT_PARAMETER_CHANGED

        Write(*Me)
      Case Globals::#EVENT_GRAPH_CHANGED

        Write(*Me)
        
;           
      Case #PB_Event_SizeWindow
        ResizeGadget(*Me\frame,0,0,GadgetWidth(*Me\container),GadgetHeight(*Me\container))
        ResizeGadget(*Me\area,5,20,GadgetWidth(*Me\container)-10,GadgetHeight(*Me\container)-25)
      Case #PB_Event_Menu
        Select EventMenu()
          
        EndSelect
            
            
      Case #PB_Event_Gadget
        Select EventGadget()
          Case *Me\area
            Select EventType()
              Case #PB_EventType_Change
                Write(*Me)
            EndSelect
        EndSelect
        
        
    EndSelect
    
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*Me.LogUI_t)
    
  EndProcedure
  
  
;   Procedure Draw(*Me.LogUI_t)
;     ClearGadgetItems(*Me\area)
;     ForEach Log::*LOGMACHINE\msgs()
;       AddGadgetItem(*Me\area,-1,Log::*LOGMACHINE\msgs()\msg)
;     Next
;     SetGadgetState(*Me\area,CountGadgetItems(*Me\area)-1)
;     
;   EndProcedure
  
  
EndModule
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 10
; Folding = --
; EnableUnicode
; EnableXP
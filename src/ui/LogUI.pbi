
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
  
  Declare New(*parent.View::View_t,name.s="LogUI")
  Declare Delete(*Me.LogUI_t)
  Declare Resize(*Me.LogUI_t)
  Declare Draw(*Me.LogUI_t)
  Declare DrawPickImage(*Me.LogUI_t)
  Declare Pick(*Me.LogUI_t)
  Declare OnEvent(*Me.LogUI_t,event.i)
  
  DataSection 
    LogUIVT: 
    Data.i @Delete()
    Data.i @Resize()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i @Pick()
    Data.i @OnEvent()
  EndDataSection 
EndDeclareModule

; -----------------------------------------
; LogUI Module Implementation
; -----------------------------------------
Module LogUI
  ; Constructor
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s="LogUI")
    Protected x = *parent\posX
    Protected y = *parent\posY
    Protected w = *parent\sizX
    Protected h = *parent\sizY
    
    
    Protected *Me.LogUI_t = AllocateMemory(SizeOf(LogUI_t))
    
    Object::INI(LogUI)
    *Me\name = name
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = w
    *Me\sizY = h
    *Me\frame = ContainerGadget(#PB_Any,x,y,w,h)
    
    
    *Me\area = EditorGadget(#PB_Any,5,20,w-10,h-25,s)
    SetGadgetAttribute(*Me\area,#PB_Editor_ReadOnly,#True)

    CloseGadgetList()
    
    View::SetContent(*parent,*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;-------------------------------
  Procedure Delete(*Me.LogUI_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; Resize
  ;-------------------------------
  Procedure Resize(*Me.LogUI_t)
    
  EndProcedure
  
  ; Draw
  ;-------------------------------
  Procedure Draw(*Me.LogUI_t)
    
  EndProcedure
  
  ; Draw Pick Image
  ;-------------------------------
  Procedure DrawPickImage(*Me.LogUI_t)
    
  EndProcedure
  
  ; Pick
  ;-------------------------------
  Procedure Pick(*Me.LogUI_t)
    
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
  Procedure OnEvent(*Me.LogUI_t,event.i)

    Select event
      Case Globals::#EVENT_COMMAND_CALLED

        Write(*Me)
      Case Globals::#EVENT_PARAMETER_CHANGED

        Write(*Me)
      Case Globals::#EVENT_GRAPH_CHANGED

        Write(*Me)
        
;           
      Case #PB_Event_SizeWindow
        ResizeGadget(*Me\area,*Me\parent\posX,*Me\parent\posY,*Me\parent\sizX,*Me\parent\sizY)
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
        
        
      Case #PB_Event_Repaint
        Write(*Me)
    EndSelect
    
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
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 53
; FirstLine = 49
; Folding = --
; EnableXP
; EnableUnicode
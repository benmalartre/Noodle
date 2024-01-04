; ================================================================
;   Sheet
; ================================================================
XIncludeFile "../core/UIColor.pbi"
XIncludeFile "../core/Vector.pbi"

DeclareModule Sheet
  ;-----------------------------------------------------------------
  ; Structure
  ;-----------------------------------------------------------------
  Structure Sheet_t Extends Object::Object_t
    List *items.Vector::Item_t()
    *over.Vector::Item_t
    *active.Vector::Item_t
    px.f
    py.f
    r.f
    width.i
    height.i
    name.s
    *on_selection_change.Signal::Signal_t
    *on_content_change.Signal::Signal_t
  EndStructure
  
  Declare New(width.i,height.i,zindex=0, name.s="Sheet")
  Declare Delete(*Me.Sheet_t)
  Declare Draw(*Me.Sheet_t)
  Declare.b Pick(*Me.Sheet_t, mx.f, my.f)
  Declare AddItem(*Me.Sheet_t, *item.Vector::Item_t)
  Declare RemoveItem(*Me.Sheet_t, *item.Vector::Item_t)
  Declare FlipX(*Me.Sheet_t, pivot.i)
  Declare FlipY(*Me.Sheet_t, pivot.i)
  Declare Shift(*Me.Sheet_t,shiftx.i,shifty.i)
  
  DataSection
    SheetVT:
  EndDataSection
  
EndDeclareModule

Module Sheet
  UseModule Globals
  ; -----------------------------------------------------------------
  ;   CONSTRUCTOR
  ; -----------------------------------------------------------------
  Procedure New(width.i,height.i,zindex=0, name.s="Sheet")
    Protected *Me.Sheet_t = AllocateStructure(Sheet_t)
    Object::INI(Sheet)
    *Me\width = width
    *Me\height = height
    *Me\name = name
    *Me\on_selection_change = Object::NewSignal(*Me, "OnSelectionChange")
    *Me\on_content_change = Object::NewSignal(*Me, "OnContentChange")
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;   DESTRUCTOR
  ; -----------------------------------------------------------------
  Procedure Delete(*Me.Sheet_t)
    Object::TERM(Sheet)
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;   CALLBACKS
  ; -----------------------------------------------------------------
  Procedure OnContentChange(*Me.Sheet_t)
    Sheet::Draw(*Me)
  EndProcedure
  Callback::DECLARECALLBACK(OnContentChange, #PB_Structure)
  
  ; -----------------------------------------------------------------
  ;   ADD ITEM
  ; -----------------------------------------------------------------
  Procedure AddItem(*Me.Sheet_t, *item.Vector::Item_t)
    If *Me And *item
      AddElement(*Me\items())
      *Me\items() = *item
    EndIf
  EndProcedure
  
  ;--------------------------------------------------------
  ; Remove Item
  ;--------------------------------------------------------
  Procedure RemoveItem(*Me.Sheet_t, *item.Vector::Item_t)
    If *Me And *item
      ForEach *Me\items()
        If *Me\items() = *item
          Vector::DeleteItem(*item)
          DeleteElement(*Me\items())
          ProcedureReturn
        EndIf
      Next
    EndIf
  EndProcedure
  
  ; --------------------------------------------------------
  ;   DRAW
  ; --------------------------------------------------------
  Procedure Draw(*Me.Sheet_t)
    ForEach *Me\items()
      Vector::DrawItem(*Me\items())
    Next
  EndProcedure
  
  ; --------------------------------------------------------
  ;   PICK 
  ; --------------------------------------------------------
  Procedure.b Pick(*Me.Sheet_t, mx.f, my.f)
    Define *pick.Vector::Item_t = #Null
    
    If LastElement(*Me\items())
      Repeat
        Vector::ResetPick(*Me\items())
        *pick = Vector::PickItem(*Me\items(), mx, my)
        If *pick
          *Me\over = *pick
          ProcedureReturn #True
        EndIf
      Until PreviousElement(*Me\items()) = #False
    EndIf
    *Me\over = #Null
    ProcedureReturn #False
    
  EndProcedure
  

  ;--------------------------------------------------------------------
  ; Flip X
  ;--------------------------------------------------------------------
  Procedure FlipX(*Me.Sheet_t, pivot.i)
    FlipCoordinatesX(pivot)
  EndProcedure
  
  ;--------------------------------------------------------------------
  ; Flip Y
  ;--------------------------------------------------------------------
  Procedure FlipY(*Me.Sheet_t, pivot.i)
    FlipCoordinatesY(pivot)
  EndProcedure

  ;--------------------------------------------------------------------
  ; Shift
  ;--------------------------------------------------------------------
  Procedure Shift(*Me.Sheet_t,shiftx.i,shifty.i)
    If *Me\active
      Vector::Translate(*Me\active, shiftx, shifty)
    EndIf
    
;     TranslateCoordinates(*Me, shiftx, shifty)
  EndProcedure
  
 
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 46
; FirstLine = 42
; Folding = ---
; EnableXP
; EnableUnicode
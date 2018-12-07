XIncludeFile "../core/Object.pbi"
XIncludeFile "../core/Array.pbi"

DeclareModule Selection
  
  Enumeration
    #ITEM_OBJECT
    #ITEM_VERTEX
    #ITEM_EDGE
    #ITEM_FACE
  EndEnumeration
  
  Structure SelectionItem_t
    *obj.Object3D::Object3D_t
    type.i
  EndStructure
  
  Structure SelectionComponentItem_t Extends SelectionItem_t
    *components.CArray::CArrayLong
  EndStructure
  
  Structure Selection_t
    Map *selected.SelectionItem_t()
  EndStructure
  
  Declare New()
  Declare Delete(*Me.Selection_t)
  Declare AddObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
  Declare RemoveObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
  Declare AddComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
  Declare RemoveComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
  Declare Get(*Me.Selection_t)
  
  Declare NewSelectionItem(*obj.Object3D::Object3D_t)
  Declare NewSelectionComponentItem(*obj.Object3D::Object3D_t, type.i)
  
  Declare DeleteSelectionItem(*item.SelectionItem_t)
  Declare DeleteSelectionComponentItem(*item.SelectionComponentItem_t)
  
EndDeclareModule

Module Selection
  Procedure New()
    Protected *Me.Selection_t = AllocateMemory(SizeOf(Selection_t))
    InitializeStructure(*Me, Selection_t)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Selection_t)
    ClearStructure(*Me, Selection_t)
    FreeMemory(*Me)
  EndProcedure
  
  Procedure NewSelectionItem(*obj.Object3D::Object3D_t)
    Protected *item.SelectionItem_t = AllocateMemory(SizeOf(SelectionItem_t))
    *item\obj = *obj
    *item\type = #ITEM_OBJECT
    ProcedureReturn *item
  EndProcedure
  
  Procedure DeleteSelectionItem(*item.SelectionItem_t)
    FreeMemory(*item)
  EndProcedure
  
  Procedure NewSelectionComponentItem(*obj.Object3D::Object3D_t, type.i)
    Protected *item.SelectionComponentItem_t = AllocateMemory(SizeOf(SelectionComponentItem_t))
    *item\obj = *obj
    *item\type = type
    *item\components = CArray::newCArrayLong()
    ProcedureReturn *item
  EndProcedure
  
  Procedure DeleteSelectionComponentItem(*item.SelectionComponentItem_t)
    CArray::Delete(*item\components)
    FreeMemory(*item)
  EndProcedure
  
  
  Procedure AddObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
    If Not FindMapElement(*Me\selected(), Str(*obj))
      Define *selectable.SelectionItem_t = NewSelectionItem(*obj)
      AddMapElement(*Me\selected(), Str(*obj))
      *Me\selected() = *selectable
    EndIf  
  EndProcedure
  
  Procedure RemoveObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
    If FindMapElement(*Me\selected(), Str(*obj))
      If *Me\selected()\type = #ITEM_OBJECT
        DeleteSelectionItem(*Me\selected())
      Else
        DeleteSelectionComponentItem(*Me\selected())
      EndIf
      DeleteMapElement(*Me\selected())
    EndIf
  EndProcedure
  
  Procedure AddComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
    Define hash.s = Str(*obj)
    Select type
      Case #ITEM_VERTEX
        hash+".Vertex"
      Case #ITEM_EDGE
        hash+".Edge"
      Case #ITEM_FACE
        hash+".Face"
    EndSelect
    
    If Not FindMapElement(*Me\selected(), hash)
      *Me\selected(hash) = *obj
    EndIf  
  EndProcedure
  
  Procedure RemoveComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
    Define hash.s = Str(*obj)
    Select type
      Case #ITEM_VERTEX
        hash+".Vertex"
      Case #ITEM_EDGE
        hash+".Edge"
      Case #ITEM_FACE
        hash+".Face"
    EndSelect
    If FindMapElement(*Me\selected(), hash)
      DeleteMapElement(*Me\selected())
    EndIf
  EndProcedure
  
  Procedure Get(*Me.Selection_t)
    If MapSize(*Me\selected())
      ProcedureReturn *Me\selected()
    EndIf
    
  EndProcedure
  
EndModule

DeclareModule ComponentSelection
  Enumeration 
    #TYPE_POINT
    #TYPE_SEGMENT
    #TYPE_FACE
  EndEnumeration
  
  Structure ComponentSelectable_t
    *indices.CArray::CArrayLong
    *geom.Geometry::Geometry_t
    type.i
    ID.i
  EndStructure
  
  Structure ComponentSelection_t
    Map selectables.ComponentSelectable_t()
    List *selected.ComponentSelectable_t()
  EndStructure
EndDeclareModule

Module ComponentSelection
EndModule


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 23
; FirstLine = 3
; Folding = ---
; EnableXP
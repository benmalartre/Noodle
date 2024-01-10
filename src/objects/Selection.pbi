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
    key.s
  EndStructure
  
  Structure SelectionComponentItem_t Extends SelectionItem_t
    *components.CArray::CArrayLong
  EndStructure
  
  Structure Selection_t
    Map *items.SelectionItem_t()
  EndStructure
  
  Declare New()
  Declare Delete(*Me.Selection_t)
  Declare Clear(*Me.Selection_t)
  Declare AddObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
  Declare RemoveObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
  Declare AddComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
  Declare RemoveComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
  Declare Get(*Me.Selection_t)
  
EndDeclareModule


Module Selection
  Procedure New()
    Protected *Me.Selection_t = AllocateStructure(Selection_t)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Selection_t)
    FreeStructure(*Me)
  EndProcedure
  
   Procedure Clear(*Me.Selection_t)
     ForEach *Me\items()
       RemoveObject(*Me, *Me\items())
     Next
     ClearMap(*Me\items())
  EndProcedure
  
  Procedure AddObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
    If Not *obj : ProcedureReturn : EndIf
    
    Debug "ADD OBJECT : "+Str(*obj);\name
    If Not FindMapElement(*Me\items(), Str(*obj))
      Protected *item.SelectionItem_t = AllocateStructure(SelectionItem_t)
      *item\obj = *obj
      *item\type = #ITEM_OBJECT
      Define key.s = Str(*obj)
      Debug "KEY : "+key
      AddMapElement(*Me\items(), key)
      *Me\items() = *item
      *item\key = key
;       Debug *Me\items()
;       Debug *Me\items()\obj
;       Debug *Me\items()\obj\fullname
;       Debug "ADD OBJECT TO SELECTION : "+*Me\items()\obj\fullname
    EndIf  
  EndProcedure
  
  Procedure RemoveObject(*Me.Selection_t, *item.SelectionItem_t)
    If *Me\items(*item\key)
      If *item\type <> #ITEM_OBJECT
        Define *subItem.SelectionComponentItem_t = *item
        CArray::Delete(*subItem\components)
      EndIf
     DeleteMapElement(*Me\items(), *item\key)
     FreeStructure(*item)
   EndIf
  EndProcedure
 
  
  Procedure AddComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
    Protected *item.SelectionComponentItem_t = AllocateStructure(SelectionComponentItem_t)
    *item\obj = *obj
    *item\type = type
    *item\components = CArray::New(Types::#TYPE_LONG)
    
    Define hash.s = Str(*obj)
    Select type
      Case #ITEM_VERTEX
        hash+".Vertex"
      Case #ITEM_EDGE
        hash+".Edge"
      Case #ITEM_FACE
        hash+".Face"
    EndSelect
    
    If Not FindMapElement(*Me\items(), hash)
      *Me\items(hash) = *obj
    EndIf  
    ProcedureReturn *item
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
    If FindMapElement(*Me\items(), hash)
      DeleteMapElement(*Me\items())
    EndIf
  EndProcedure
  
  Procedure Get(*Me.Selection_t)
    If MapSize(*Me\items())
      ProcedureReturn *Me\items()
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
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 91
; FirstLine = 87
; Folding = ---
; EnableXP
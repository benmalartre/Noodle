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
    Map *selected.SelectionItem_t()
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
    Protected *Me.Selection_t = AllocateMemory(SizeOf(Selection_t))
    InitializeStructure(*Me, Selection_t)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Selection_t)
    ClearStructure(*Me, Selection_t)
    FreeMemory(*Me)
  EndProcedure
  
   Procedure Clear(*Me.Selection_t)
     ForEach *Me\selected()
       RemoveObject(*Me, *Me\selected())
     Next
     ClearMap(*Me\selected())
  EndProcedure
  
  Procedure AddObject(*Me.Selection_t, *obj.Object3D::Object3D_t)
    If Not *obj : ProcedureReturn : EndIf
    
    Debug "ADD OBJECT : "+Str(*obj);\name
    If Not FindMapElement(*Me\selected(), Str(*obj))
      Protected *item.SelectionItem_t = AllocateMemory(SizeOf(SelectionItem_t))
      *item\obj = *obj
      *item\type = #ITEM_OBJECT
      Define key.s = Str(*obj)
      Debug "KEY : "+key
      AddMapElement(*Me\selected(), key)
      *Me\selected(key) = *item
      *item\key = key
      
      Debug "ADD OBJECT TO SELECTION : "+*Me\selected()\obj\fullname
    EndIf  
  EndProcedure
  
  Procedure RemoveObject(*Me.Selection_t, *item.SelectionItem_t)
    If *Me\selected(*item\key)
      Define *item.SelectionItem_t = *Me\selected(*item\key)
      If *item\type <> #ITEM_OBJECT
        Define *subItem.SelectionComponentItem_t = *item
        CArray::Delete(*subItem\components)
      EndIf
     DeleteMapElement(*Me\selected(), *item\key)
     FreeMemory(*item)
   EndIf
  EndProcedure
 
  
  Procedure AddComponent(*Me.Selection_t, *obj.Object3D::Object3D_t, type.i)
    Protected *item.SelectionComponentItem_t = AllocateMemory(SizeOf(SelectionComponentItem_t))
    *item\obj = *obj
    *item\type = type
    *item\components = CArray::newCArrayLong()
    
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
; CursorPosition = 60
; FirstLine = 53
; Folding = ---
; EnableXP
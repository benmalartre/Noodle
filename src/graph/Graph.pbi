XIncludeFile "../core/Array.pbi"
XIncludeFile "Types.pbi"
XIncludeFile "../objects/Object3D.pbi"

;====================================================================================
; GRAPH MODULE IMPLEMENTATION
;====================================================================================
Module Graph
  Procedure ResolveGetReference(*port.NodePort::NodePort_t)
    Protected refname.s
    Protected *node.Node::Node_t = *port\node
    Protected *obj.Object3D::Object3D_t = Node::GetParent3DObject(*node)

    refname.s = NodePort::AcquireReferenceData(*port)

    Protected fields.i = CountString(refname, ".")+1
    Protected base.s = StringField(refname, 1,".")
    ;*node\label = refname
    Protected *output.NodePort::NodePort_t = Node::GetPortByName(*node,"Data")
    If base ="Self" Or base ="This"
      Protected *attribute.Attribute::Attribute_t = *obj\geom\m_attributes(StringField(refname, 2,"."))
      If *attribute
        *output\currenttype = *attribute\datatype
        *output\currentcontext = *attribute\datacontext
        *output\currentstructure = *attribute\datastructure
        NodePort::Init(*output, *obj\geom)
        *output\attribute = *attribute
      EndIf
    EndIf
  EndProcedure  
  
  Procedure ResolveSetReference(*port.NodePort::NodePort_t)
    Protected *node.Node::Node_t = *port\node
    Protected refname.s = NodePort::AcquireReferenceData(*ref)
    
    If refname
      Protected fields.i = CountString(refname, ".")+1
      Protected base.s = StringField(refname, 1,".")
      
      If base ="Self" Or base ="This"
        Protected *obj.Object3D::Object3D_t = Node::GetParent3DObject(*node)
        Protected *input.NodePort::NodePort_t
        Protected name.s = StringField(refname, 2,".")
        If FindMapElement(*obj\geom\m_attributes(),name)
          
          Protected *attribute.Attribute::Attribute_t = *obj\geom\m_attributes(name)
          *input = Node::GetPortByName(*node,"Data")
  
          NodePort::InitFromReference(*input,*attribute)
          *node\state = Graph::#Node_StateOK
          *node\errorstr = ""
        EndIf
        
      EndIf
    Else
      *node\state = Graph::#Node_StateError
      *node\errorstr = "[ERROR] Input Empty"
    EndIf
    
  EndProcedure
  
  ;------------------------------
  ; Switch Context
  ;------------------------------
  Procedure SwitchContext(ID)
    Select ID
      Case Graph::#Graph_Context_Compositing
        MessageRequester("GRAPH SWITCH CONTEXT","COMPOSITING")
       
     Case Graph::#Graph_Context_Hierarchy
       MessageRequester("GRAPH SWITCH CONTEXT","HIERARCHY")
       
     Case Graph::#Graph_Context_Modeling
       MessageRequester("GRAPH SWITCH CONTEXT","MODELING")
       
     Case Graph::#Graph_Context_Operator
       MessageRequester("GRAPH SWITCH CONTEXT","OPERATOR")
       
     Case Graph::#Graph_Context_Shader
       MessageRequester("GRAPH SWITCH CONTEXT","SHADER")
       
     Case Graph::#Graph_Context_Simulation
       MessageRequester("GRAPH SWITCH CONTEXT","SIMULATION")
       
    EndSelect
    
    
  EndProcedure

EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 57
; FirstLine = 25
; Folding = -
; EnableXP
; EnableUnicode
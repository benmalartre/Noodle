XIncludeFile "../core/Array.pbi"
XIncludeFile "Types.pbi"

;====================================================================================
; COMPOUND NODE MODULE IMPLEMENTATION
;====================================================================================
Module CompoundNode
  ;-------------------------------------------------------------------------------
  ; Constructor
  ;-------------------------------------------------------------------------------
  Procedure  New(*nodes.CArray::CArrayPtr,*parent.Node::Node_t,x.i,y.i,w.i,h.i,c.i)
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.CompoundNode_t = AllocateMemory(SizeOf(CompoundNode_t))
    Object::INI(CompoundNode)
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\parent = *parent
    *Me\label = "CompoundNode"
    *Me\name = "CompoundNode"
    *Me\type = "CompoundNode"
    *Me\posx = x
    *Me\posy = y
    *Me\width = w
    *Me\height = h
    *Me\color = c
    *Me\state = Graph::#Node_StateUndefined
    
    *Me\iexpanded = #True
    *Me\iexpand = 200
    
    *Me\input_exposer = CompoundNodePort::New(*Me,"expose input",#False)
    *Me\output_exposer = CompoundNodePort::New(*Me,"expose input",#True)
    
    Protected i
    For i=0 To CArray::GetCount(*nodes)-1
      Graph::AttachListElement(*Me\nodes(),CArray::GetValuePtr(*nodes,i))
      *Me\nodes()\parent = *Me
    Next i
      
    Protected msg.s

    ForEach *Me\nodes()
     
      msg + *Me\nodes()\class\name+Chr(10)
    Next
    
    MessageRequester("Tree Passed Nodes",msg)
  
    ProcedureReturn (*Me)
    
  EndProcedure
  
  ;-------------------------------------------------------------------------------
  ; Destructor
  ;-------------------------------------------------------------------------------
  Procedure Delete(*Me.CompoundNode_t)
    ClearStructure(*Me,CompoundNode_t)
    FreeMemory(*Me)
  EndProcedure
  
  
  ;-------------------------------------------------------------------------------
  ; Draw
  ;-------------------------------------------------------------------------------
  Procedure Draw(*Me.CompoundNode_t,gadgetID.i)
    Protected w = GadgetWidth(gadgetID)
    Protected h = GadgetHeight(gadgetID)
    Protected x = 10
    Protected y = 20
    ForEach *Me\exposed_inputs()
      Circle(x,y,Graph::#Node_PortRadius,*Me\exposed_inputs()\color)
      y + Graph::#Node_PortSpacing
    Next
    
    y=20
    x= w-20
    ForEach *Me\exposed_outputs()
      Circle(x,y,Graph::#Node_PortRadius,*Me\exposed_outputs()\color)
      y + Graph::#Node_PortSpacing
    Next
    
  EndProcedure
  
  
  ;-------------------------------------------------------------------------------
  ; Is Node Inside
  ;-------------------------------------------------------------------------------
  Procedure IsNodeInside(*Me.CompoundNode_t,*node.Node::Node_t)
    Protected id = ListIndex(*Me\nodes())
    ForEach *Me\nodes()
      If *Me\nodes() = *node
        SelectElement(*Me\nodes(),id)
        ProcedureReturn #True
      EndIf
    Next
    SelectElement(*Me\nodes(),id)
    ProcedureReturn #False
  EndProcedure
  
  
  ;-------------------------------------------------------------------------------
  ; CollectExposedOutput
  ;-------------------------------------------------------------------------------
  Procedure CollectExposedOutputPorts(*Me.CompoundNode_t)
    Protected msg.s
    ClearList(*Me\exposed_outputs())
    ForEach *Me\nodes()
      ForEach *Me\nodes()\outputs()
        If *Me\nodes()\outputs()\connected
          Protected *output.NodePort::NodePort_t = *Me\nodes()\outputs()
          ForEach *output\targets()
            Protected *target.NodePort::NodePort_t = *output\targets()
            Protected name.s = *target\name
            If Not IsNodeInside(*Me,*target\node)
              AddElement(*Me\exposed_outputs())
              *Me\exposed_outputs() = CompoundNodePort::NewFromPort(*output)
              Graph::AttachListElement(*Me\outputs(),*Me\exposed_outputs())
              Protected *connexion.Connexion::Connexion_t = *target\connexion
              *connexion\start = *Me\exposed_outputs()
              *Me\exposed_outputs()\connected = #True
              *Me\exposed_outputs()\connexion = *connexion
            EndIf
          Next
          
          
        EndIf
      Next
    Next
    
    
    
  EndProcedure
  
  ;-------------------------------------------------------------------------------
  ; Collect Exposed Inputs
  ;-------------------------------------------------------------------------------
   Procedure CollectExposedInputPorts(*Me.CompoundNode_t)
    Protected msg.s
    ClearList(*Me\exposed_inputs())
    
    Protected *node.Node::Node_t
    ForEach *Me\nodes()
      *node = *Me\nodes()

      ForEach *node\inputs()

        If *node\inputs()\connected
          Protected *input.NodePort::NodePort_t = *Me\nodes()\inputs()
          Protected *src.NodePort::NodePort_t = *input\source
          If Not IsNodeInside(*Me,*src\node)
            AddElement(*Me\exposed_inputs())
            *Me\exposed_inputs() = CompoundNodePort::NewFromPort(*input)
            Graph::AttachListElement(*Me\inputs(),*Me\exposed_inputs())
            Protected *connexion.Connexion::Connexion_t = *input\connexion
            *connexion\end = *Me\exposed_inputs()
            *Me\exposed_inputs()\connected = #True
            *Me\exposed_inputs()\connexion = *connexion
          EndIf         
        EndIf
      Next
    Next
    
    
  EndProcedure
  
  ;-------------------------------------------------------------------------------
  ; Pick
  ;-------------------------------------------------------------------------------
  Procedure Pick(*node.CompoundNode_t,gadgetID,mousex,mousey)
    If mousex >GadgetWidth(gadgetID)-Graph::#Graph_Compound_Border And mousey>0 And mousey < Graph::#Graph_Compound_Border 
      ProcedureReturn Graph::#Graph_Selection_ExposeOutput
    ElseIf mousex < Graph::#Graph_Compound_Border ;And mousey>0 And mousey < Graph::#Graph_Compound_Border 
      ProcedureReturn Graph::#Graph_Selection_ExposeInput
    EndIf
    ProcedureReturn Graph::#Graph_Selection_None
      
  EndProcedure
  
  ;-------------------------------------------------------------------------------
  ; ExposePort
  ;-------------------------------------------------------------------------------
  Procedure ExposePort(*node.CompoundNode_t,*port.NodePort::NodePort_t)
    MessageRequester("CompoundNode","ExposePort : Called")
    Protected *exposed.CompoundNodePort::CompoundNodePort_t
    ; Output Port
    If *port\io
      *exposed = CompoundNodePort::NewFromPort(*port)
      Graph::AttachListElement(*node\exposed_outputs(),*exposed)
      Graph::AttachListElement(*node\outputs(),*port)
       MessageRequester("CompoundNode","Expose Output Port : "+*exposed\name)
    ; Input Port
    Else
      *exposed = CompoundNodePort::NewFromPort(*port)
      Graph::AttachListElement(*node\exposed_inputs(),*exposed)
      Graph::AttachListElement(*node\inputs(),*port)
      MessageRequester("CompoundNode","Expose Input Port : "+*exposed\name)
    EndIf
    
  EndProcedure
  
  ;-------------------------------------------------------------------------------
  ; Remove Exposed Port
  ;-------------------------------------------------------------------------------
  Procedure RemoveExposedPort(*node.CompoundNode_t,*port.NodePort::NodePort_t)
    
    If *port\io
      ForEach *node\exposed_outputs()
        
        If *node\exposed_outputs()\port = *port
          If *node\exposed_outputs()\connected
            Protected *connexion.Connexion::Connexion_t = *node\exposed_outputs()\connexion
            ForEach *node\parent\connexions()
              If *node\parent\connexions() = *connexion
                DeleteElement(*node\parent\connexions())
                Break
              EndIf
            Next
            
            *connexion\end\connected = #False
            Connexion::Delete(*connexion)
           EndIf
           
          
          ForEach *node\outputs()
            If *node\outputs() = *node\exposed_outputs()
              MessageRequester("RemoveexposedPort","Delete Associated Port")
              DeleteElement(*node\outputs())
              Break
            EndIf
          Next
          
          CompoundNodePort::Delete(*node\exposed_outputs())
          DeleteElement(*node\exposed_outputs())
          
          Break
        EndIf
  
      Next
    Else
       ForEach *node\exposed_inputs()
        
         If *node\exposed_inputs()\port = *port
           If *node\exposed_inputs()\connected
             
           EndIf
           
          CompoundNodePort::Delete(*node\exposed_inputs())
          ForEach *node\inputs()
            If *node\inputs() = *port
              DeleteElement(*node\inputs())
              Break
            EndIf
          Next
          DeleteElement(*node\exposed_inputs())
  
          Break
        EndIf
  
      Next
    EndIf
    
    
  EndProcedure
  
  
  Class::DEF(CompoundNode)
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 13
; FirstLine = 10
; Folding = --
; EnableXP
; EnableUnicode
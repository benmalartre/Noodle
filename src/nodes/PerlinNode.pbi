XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Perlin.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; BUILD ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule PerlinNode
  Structure PerlinNode_t Extends Node::Node_t
    mode.i
    seed.i
    *noise.PerlinNoise::PerlinNoise_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IPerlinNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="PerlinNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.PerlinNode_t)
  Declare Init(*node.PerlinNode_t)
  Declare Evaluate(*node.PerlinNode_t)
  Declare Terminate(*node.PerlinNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("PerlinNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(PerlinNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY NODE MODULE DECLARATION
; ==================================================================================================
Module PerlinNode
  UseModule Math
  
  Procedure Init(*node.PerlinNode_t)
    Node::AddInputPort(*node,"Seed",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"Time Varying",Attribute::#ATTR_TYPE_BOOL)
    Node::AddInputPort(*node,"Position",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddInputPort(*node,"Time Fraquency",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"Space Fraquency",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddInputPort(*node,"Complexity",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_VECTOR3)
    
    ForEach *node\inputs()
      Node::PortAffectByName(*node, *node\inputs()\name, "Output")
    Next

    *node\label = "Perlin"
  EndProcedure
  
  Procedure Evaluate(*node.PerlinNode_t)
    FirstElement(*node\inputs())
    Protected *seedArray.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *timeVaryingArray.CArray::CArrayBool = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *position.NodePort::NodePort_t = *node\inputs()
    Protected *positionArray.CArray::CArrayV3F32 = NodePort::AcquireInputData(*position)
    NextElement(*node\inputs())
    Protected *timeFrequencyArray.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *spaceFrequencyArray.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *complexityArray.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    Protected complexity.i = CArray::GetValueI(*complexityArray,0)
    
    Protected variancei.f
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    
    Protected i.i
    Protected time.f = Time::currentframe
    Protected seed.i = CArray::GetValueI(*seedArray,0)
    If CArray::GetValueB(*timeVaryingArray,0)
      *node\noise\seed = seed+time*CArray::GetValueF(*timeFrequencyArray,0)
    Else
      *node\noise\seed = seed
    EndIf
          
     
    Protected *outputArray.CArray::CArrayV3F32
    *outputArray = NodePort::AcquireOutputData(*output)
    
    CArray::Copy(*outputArray,*positionArray)
    Protected v.v3f32, *a.v3f32, *b.v3f32
    For i=0 To CArray::GetCount(*positionArray)-1
      *a = CArray::GetValue(*positionArray,i)
      *b = CArray::GetValue(*spaceFrequencyArray,0)
      Vector3::Multiply(v, *a, *b)
      PerlinNoise::Eval(*node\noise,v , CArray::GetValue(*outputArray,i))
    Next i
  EndProcedure
  
  Procedure Terminate(*node.PerlinNode_t)
  
  EndProcedure
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete(*node.PerlinNode_t)
    PerlinNoise::Delete(*node\noise)
    Node::DEL(PerlinNode)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New(*tree.Tree::Tree_t,type.s="PerlinNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    Protected *Me.PerlinNode_t = AllocateStructure(PerlinNode_t)
    Node::INI(PerlinNode,*tree,type,x,y,w,h,c)
    *Me\noise = PerlinNoise::New()
    PerlinNoise::Init(*Me\noise)
    ProcedureReturn( *Me)
    
  EndProcedure

  
  Class::DEF(PerlinNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 120
; FirstLine = 99
; Folding = --
; EnableXP
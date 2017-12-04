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
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_VECTOR3)
    
    ForEach *node\inputs()
      Node::PortAffect(*node, *node\inputs()\name, "Output")
    Next
    
    
    *node\label = "Perlin"
  EndProcedure
  
  Procedure Evaluate(*node.PerlinNode_t)
    FirstElement(*node\inputs())
    Protected *seedArray.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *timeVaryingArray.CArray::CArrayBool = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *positionPort.NodePort::NodePort_t = *node\inputs()
    Protected *positionArray.CArray::CArrayV3F32 = NodePort::AcquireInputData(*positionPort)
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
    If *output\value = #Null
      NodePort::Init(*output)
    EndIf
    
    Protected i.i
    Protected time.f = Time::currentframe
    If CArray::GetValueB(*timeVaryingArray,0)
      RandomSeed(CArray::GetValueI(*seedArray,0)+time+i)
    Else
      RandomSeed(CArray::GetValueI(*seedArray,0)+i)
    EndIf
          
     
    Protected *v.v3f32
    Protected v2.v3f32
    Protected *vIn.CArray::CArrayV3F32,*vOut.CArray::CArrayV3F32
    Define.d rx,ry,rz
    *vOut = *output\value
    *vIn = NodePort::AcquireInputData(*positionPort)
    CArray::Copy(*vOut,*vIn)
    
    Protected msg.s
    Protected *p.v3f32
    For i=0 To CArray::GetCount(*vIn)-1
      *p = CArray::GetValue(*vIn,i)
      rx = PerlinNoise::Unsigned(PerlinNoise::PerlinNoise1D(*p\x, 3, 12, 6))
      ry = PerlinNoise::Unsigned(PerlinNoise::PerlinNoise1D(*p\y, 3, 12, 6))
      rz = PerlinNoise::Unsigned(PerlinNoise::PerlinNoise1D(*p\z, 3, 12, 6))
      msg + StrF(rx)+","+StrF(ry)+","+StrF(rz)+Chr(10)
      
      *v = CArray::GetValue(*vOut,i);-variance+r
      Vector3::Set(*v,rx,ry,rz)

    Next i
   MessageRequester("Perlin Node" , msg)
  
  EndProcedure
  
  Procedure Terminate(*node.PerlinNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.PerlinNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="PerlinNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.PerlinNode_t = AllocateMemory(SizeOf(PerlinNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(PerlinNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(PerlinNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 62
; FirstLine = 35
; Folding = --
; EnableXP
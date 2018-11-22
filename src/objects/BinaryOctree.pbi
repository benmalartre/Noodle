;=======================================================================
; DECLARATION
;=======================================================================
DeclareModule BinaryOctree
  #MAX_EXPONANT = 31
  #BinaryOctree_MASK = (1<<#MAX_EXPONANT)-1

  Macro Min(a,b)
    (Bool((a)>(b))*(b))|(Bool((b)>(a))*(a))
  EndMacro

  Macro Max(a,b)
     (Bool((a)<(b))*(b))|(Bool((b)<(a))*(a))
  EndMacro
  
  Structure i2f_t
    StructureUnion
      i.l
      f.f
    EndStructureUnion
  EndStructure
  
  Structure Node_t
    *children.Node_t[8]
  EndStructure
  
  Structure BinaryOctree_t Extends Node_t
    *root.Node_t
    posxyz.i[3]                     ; les coordonnées cartésiennes (avant passage à l'echelle)
    e.i                             ; l'exposant courant
    *tab.Node_t[#MAX_EXPONANT+1]    ; un pointeur sur la racine, un pointeur de pointeur sur la racine et les autres niveau
    translation.f[3]                ; coordonnées d'offset (translation=(0,0,0) correspond à une origine au coin du cube racine)
    scale.f                         ; facteur d'échelle (la taille du cube racine est égale à scale*2^EMAX)
    invscale.f            
  EndStructure
  
  Declare NewNode()
  Declare DeleteNode(*n.Node_t)
  Declare SplitNode(*o.Node_t)
  Declare RecursiveSplitNode(*o.Node_t, n.i)
  Declare Cut(*o.Node_t)
  Declare GetExponant(value.f)
  Declare NumLeaves(*o.Node_t)
  
  Declare New(*root.Node_t, *box.Geometry::Box_t, n.i)
  Declare Delete(*o.BinaryOctree_t)
  Declare.b GetNode( *o.BinaryOctree_t, x.i, y.i , z.i, e0.i)
  Declare.b GetNodeFromPos(*o.BinaryOctree_t, x.f, y.f, z.f, e0.i)
  Declare.b Increment(*o.BinaryOctree_t)
  Declare LastNode(*o.BinaryOctree_t, x.i, y.i, z.i)
  Declare FirstLastNode(*o.BinaryOctree_t)
  Declare.b NextLastNode(*o.BinaryOctree_t)
EndDeclareModule

;=======================================================================
; IMPLEMENTATION
;=======================================================================
Module BinaryOctree
  ;---------------------------------------------------------------------
  ; CONSTRUCTOR (BinaryOctree)
  ;---------------------------------------------------------------------
  Procedure New(*root.Node_t, *box.Geometry::Box_t, n.i)
    Protected *o.BinaryOctree_t = AllocateMemory(SizeOf(BinaryOctree_t))
    InitializeStructure(*o, BinaryOctree_t)
    *o\root = *root
    *o\scale
    RecursiveSplitNode(*o\root, n)
    ProcedureReturn *o
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; DESTUCTOR (BinaryOctree)
  ;---------------------------------------------------------------------
  Procedure Delete(*o.BinaryOctree_t)
    Protected *child.Node_t
    If *o\children
      For i=0 To 7
        *child = *o\children[i]
        If *child
          DeleteNode(*child)
        EndIf
      Next
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET NODE
  ;---------------------------------------------------------------------
  Procedure.b GetNode(*o.BinaryOctree_t, x.i, y.i, z.i, e0.i)
    x = x & #BinaryOctree_MASK
    y = y & #BinaryOctree_MASK
    z = z & #BinaryOctree_MASK
    
    Protected difference.i = Int(Pow(*o\posxyz[0], x)) | Int(Pow(*o\posxyz[1], y)) | Int(Pow(*o\posxyz[2], z))
    e0 = min(#MAX_EXPONANT, e0)
    *o\e = max(*o\e, e0)
    
    difference>>e
    While difference : *o\e + 1 : difference>>1 : Wend
    
    While *o\e > e0 And *o\tab[e] <> #Null
      *o\e - 1
      Protected index.i = ((x>>*o\e)&1) | (((y>>*o\e)&1)<<1) | (((z>>*o\e)&1)<<2)
      *o\tab[*o\e] = *o\tab[*o\e+1]\children + index * SizeOf(Node_t)
    Wend
    
    *o\posxyz[0] = x
    *o\posxyz[1] = y
    *o\posxyz[2] = z
    ProcedureReturn Bool(e0 = *o\e)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET NODE FROM 3D POSITION
  ;---------------------------------------------------------------------
  Procedure.b GetNodeFromPos(*o.BinaryOctree_t, x.f, y.f, z.f, e0.i)
    x=*o\invscale*(x+*o\translation[0])
    y=*o\invscale*(y+*o\translation[1])
    z=*o\invscale*(z+*o\translation[2])
    ProcedureReturn GetNode(*o, x, y, z, e0)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; INCREMENT SEARCH
  ;---------------------------------------------------------------------
  Procedure.b Increment(*o.BinaryOctree_t)
    Protected f1=*o\posxyz[0] & *o\posxyz[1] & *o\posxyz[2]
    f1>>*o\e  
    f1=Int(Pow((f1+1), f1))>>1
    While f1 : *o\e + 1 : f1 >> 1 : Wend  
    
    *o\posxyz[0]>>*o\e
    *o\posxyz[1]>>*o\e-1
    *o\posxyz[2]>>*o\e-2
    
    Protected i.i = (*o\posxyz[0] & 1)|(*o\posxyz[1] & 2)|(*o\posxyz[2] & 4)
    i + 1
    *o\posxyz[0]=((*o\posxyz[0] & -2)|(i&1))<<*o\e
    *o\posxyz[1]=((*o\posxyz[1] & -4)|(i&2))<<(*o\e-1)
    *o\posxyz[2]=((*o\posxyz[2] & -8)|(i&4))<<(*o\e-2)

    If *o\e >= #MAX_EXPONANT
      *o\posxyz[0]=0
      *o\posxyz[1]=0
      *o\posxyz[2]=0
      *o\e=#MAX_EXPONANT
      ProcedureReturn #False
    EndIf
    
    *o\tab[e]+SizeOf(Node_t)
    ProcedureReturn #True
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; LAST NODE
  ;---------------------------------------------------------------------
  Procedure LastNode(*o.BinaryOctree_t, x.i, y.i, z.i)
    x & #BinaryOctree_MASK
    y & #BinaryOctree_MASK
    z & #BinaryOctree_MASK
    Protected difference.i = Int(Pow(*o\posxyz[0], x)) | Int(Pow(*o\posxyz[1], y)) | Int(Pow(*o\posxyz[2], z))
    difference >> *o\e
    While difference : *o\e+1 : difference >> 1 : Wend
    Protected index.i
    While *o\tab[e]\children <> #Null
        *o\e-1
        index=((x>>*o\e)&1)|(((y>>*o\e)&1)<<1)|(((z>>*o\e)&1)<<2)
        *o\tab[e] = *o\tab[e+1]\children + index * SizeOf(Node_t)
    Wend  
    *o\posxyz[0]=x
    *o\posxyz[1]=y
    *o\posxyz[2]=z
    
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; FIRST LAST NODE
  ;---------------------------------------------------------------------
  Procedure FirstLastNode(*o.BinaryOctree_t)
    *o\e=#MAX_EXPONANT
    *o\posxyz[0]=0
    *o\posxyz[1]=0
    *o\posxyz[2]=0
    
    While *o\tab[e]\children<>#Null
;       *o\e-1
;       *o\tab[*o\e] = *o\tab[*o\e+1]\children
    Wend
  EndProcedure

  ;---------------------------------------------------------------------
  ; NEXT LAST NODE
  ;---------------------------------------------------------------------
  Procedure.b NextLastNode(*o.BinaryOctree_t)
    If Not Increment(*o) : ProcedureReturn #False : EndIf
    
    While *o\tab[*o\e]\children<>#Null
        *o\e-1
        *o\tab[*o\e] = *o\tab[*o\e+1]\children
    Wend
    ProcedureReturn #True
  EndProcedure

  
  ;---------------------------------------------------------------------
  ; CONSTRUCTOR (NODE)
  ;---------------------------------------------------------------------
  Procedure NewNode()
    Protected *n.Node_t = AllocateMemory(SizeOf(Node_t))
    InitializeStructure(*n, Node_t)
    ProcedureReturn *n
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; DESTUCTOR (NODE)
  ;---------------------------------------------------------------------
  Procedure DeleteNode(*n.Node_t)
    Protected *child.Node_t
    If *n\children
      For i=0 To 7
        *child = *n\children[i]
        If *child
          DeleteNode(*child)
        EndIf
      Next
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; COPY
  ;---------------------------------------------------------------------
  Procedure Copy(*n.Node_t, *o.Node_t)
    SplitNode(*n)
    For i=0 To 7
      If *o\children[i]
        *n\children[i] = *o\children[i]
      EndIf
    Next
  EndProcedure

  ;---------------------------------------------------------------------
  ; GET EXPONANT
  ;---------------------------------------------------------------------
  Procedure GetExponant(value.f)
    Protected u.i2f_t
    u\f = value
    ProcedureReturn (u\i >> 23) - 126
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; RECURSIVE SPLIT NODE
  ;---------------------------------------------------------------------
  Procedure RecursiveSplitNode(*n.Node_t, n.i)
    If n > 0
       SplitNode(*n)
       RecursiveSplitNode(*n\children[0], n-1)
       RecursiveSplitNode(*n\children[1], n-1)
       RecursiveSplitNode(*n\children[2], n-1)
       RecursiveSplitNode(*n\children[3], n-1)
       RecursiveSplitNode(*n\children[4], n-1)
       RecursiveSplitNode(*n\children[5], n-1)
       RecursiveSplitNode(*n\children[6], n-1)
       RecursiveSplitNode(*n\children[7], n-1)
     EndIf
   EndProcedure
  
  ;---------------------------------------------------------------------
  ; SPLIT NODE
  ;---------------------------------------------------------------------
  Procedure SplitNode(*n.Node_t)
    For i=0 To 7
      If *n\children[i] : DeleteNode(*n\children[i]) : EndIf
      *n\children[i] = NewNode()
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; CUT NODE
  ;---------------------------------------------------------------------
  Procedure Cut(*n.Node_t)
    For i=0 To 7
      If *n\children[i] : DeleteNode(*n\children[i]) : EndIf
      *n\children[i] = #Null
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; NUM LEAVES
  ;---------------------------------------------------------------------
  Procedure NumLeaves(*o.BinaryOctree_t)
    Protected index.i=0
    FirstLastNode(*o)
;     While NextLastNode(*o)
;       index + 1
;     Wend  
    ProcedureReturn index
  EndProcedure
  
EndModule

Define box.Feometry::Box_t 
Vector3::Set(box\origin, 2,1.5,1.666)
Vector3::Set(box\extend, 4,1,0.5)
Define *o.BinaryOctree::BinaryOctree_t = BinaryOctree::New(*root,box,12)
MessageRequester("MORTON", "NUM LEAVES : "+Str(BinaryOctree::NumLeaves(*o)))
BinaryOctree::Delete(*o)
MessageRequester("FUCKIN MORTON", "ALL IS FINE")
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 93
; FirstLine = 99
; Folding = ----
; EnableXP
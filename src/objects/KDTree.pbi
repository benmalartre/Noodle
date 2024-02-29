;=======================================================================
; DECLARATION
;=======================================================================
DeclareModule KDTree
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    #KDTREE_POINT_SIZE = 4
  CompilerElse
    #KDTREE_POINT_SIZE = 3
  CompilerEndIf
  
  #KDTREE_DIM = 3
  #KD_F32_MAX = 3.402823466e+38
  #KD_F32_MIN = 1.175494351e-38
  
  Structure KDPoint_t
    v.f[#KDTREE_POINT_SIZE]
  EndStructure
  
  Structure KDSort_t
    v.f
    ID.i
  EndStructure
  
  Structure KDSearch_t
    ID.i
    distance.f
  EndStructure
  
  Structure KDNode_t
    ID.i
    level.i
    split_value.f
    *left.KDNode_t
    *right.KDNode_t
    *parent.KDNode_t
    leftID.i
    rightID.i
    parentID.i
    r.f
    g.f
    b.f
    hit.b
    List indices.i()
  EndStructure
  
  Structure KDTree_t Extends Object::Object_t
    m_nbp.i                       ; nb points
    *root.KDNode_t                ; root node
    m_currentaxis.i               ; current axis
    m_levels.i                    ; maximum level depth
    m_cmps.i                      ; count how many comparisons were made in the tree for a query
    m_id.i                        ; current node ID
    *points.CArray::CArrayV3F32   ; array of point pointers
    List closests.KDSort_t()
  EndStructure
  
  Declare New()
  Declare Delete(*tree.KDTree_t)
  Declare NewNode(*parent.KDNode_t,ID.i,level.i)
  Declare DeleteNode(*node.KDNode_t)

  Declare Split(*tree.KDTree_t,*node.KDNode_t,*left.KDNode_t,*right.KDNode_t)
  Declare Build(*tree.KDTree_t,*pnts,nbp.i, max_levels=99,min_pnts=10)
  Declare.f SquaredDistance(*a.KDPoint_t,*b.KDPoint_t)
  Declare GetBoundingBox(*tree.KDTree_t,*node.KDNode_t,*min.KDPoint_t,*max.KDPoint_t)
  Declare SearchAtNode(*tree.KDTree_t,*node.KDNode_t, *query.KDPoint_t, *search.KDSearch_t)
  Declare SearchAtNodeRange(*tree.KDTree_t,*node.KDNode_t, *query.KDPoint_t, range.f,*search.KDSearch_t)
  Declare Search(*tree.KDTree_t,*query.KDPoint_t,*search.KDSearch_t)
  Declare SearchN(*tree.KDTree_t, *query.KDPoint_t,max_distance,max_points)
  Declare ResetHit(*tree.KDTree_t)
EndDeclareModule

;=======================================================================
; IMPLEMENTATION
;=======================================================================
Module KDTree
  ; Distance Between Two Points
  ;-------------------------------------------------------------------
  Procedure.f SquaredDistance(*a.KDPoint_t,*b.KDPoint_t)
    
    Protected dist.f = 0.0
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      ! mov rsi, [p.p_a]
      ! movups xmm0, [rsi]
      ! mov rsi, [p.p_b]
      ! movups xmm1, [rsi]
      
      ! subps xmm0, xmm1
      ! mulps xmm0, xmm0
      ! haddps xmm0, xmm0
      ! haddps xmm0, xmm0
      ! movss [p.v_dist], xmm0
    CompilerElse
      
      Protected i
      For i=0 To #KDTREE_DIM - 1
        dist + Pow(*a\v[i] - *b\v[i], 2)
      Next
    CompilerEndIf
    
    ProcedureReturn dist
  EndProcedure
  
  ; New Node
  ;--------------------------------------------------------------------
  Procedure NewNode(*parent.KDNode_t,ID.i,level.i)
    Protected *node.KDNode_t = AllocateStructure(KDNode_t)
    *node\parent = *parent
    *node\ID = ID
    *node\level = level
    *node\r = Random(100)*0.01
    *node\g = Random(100)*0.01
    *node\b = Random(100)*0.01
    ProcedureReturn *node
  EndProcedure
  
  ; Delete Node
  ;--------------------------------------------------------------------
  Procedure DeleteNode(*node.KDNode_t)
    If *node\left:DeleteNode(*node\left):EndIf
    If *node\right:DeleteNode(*node\right):EndIf
    FreeStructure(*node)
  EndProcedure
  
  ; Constructor
  ;--------------------------------------------------------------------
  Procedure New()
    Protected *tree.KDTree_t = AllocateStructure(KDTree_t)
    *tree\points = CArray::New(Types::#Type_V3F32)
    *tree\root = #Null
    *tree\m_id = 0
    ProcedureReturn *tree
  EndProcedure
  
  ; Destructor
  ;--------------------------------------------------------------------
  Procedure Delete(*tree.KDTree_t)
    CArray::Delete(*tree\points)
    DeleteNode(*tree\root)
    FreeStructure(*tree)
  EndProcedure
  
  ; Sort Points
  ;--------------------------------------------------------------------
  Procedure SortPoints(*tree.KDTree_t,a.i,b.i)
    Protected *a.KDPoint_t = CArray::GetValue(*tree\points, a)
    Protected *b.KDPoint_t = CARray::GetValue(*tree\points, b)
    
    ProcedureReturn Bool(*a\v[*tree\m_currentaxis]<*b\v[*tree\m_currentaxis])
  EndProcedure
  
  ; Get Bounding Box
  ;--------------------------------------------------------------------
  Procedure GetBoundingBox(*tree.KDTree_t,*node.KDNode_t,*min.KDPoint_t,*max.KDPoint_t)
    Protected *v.KDPoint_t
    *min\v[0] = #KD_F32_MAX
    *min\v[1] = #KD_F32_MAX
    *min\v[2] = #KD_F32_MAX
    
    *max\v[0] = #KD_F32_MIN
    *max\v[1] = #KD_F32_MIN
    *max\v[2] = #KD_F32_MIN
  
    ForEach *node\indices()
      *v = CArray::GetValue(*tree\points, *node\indices())
      ;Vector3_MulByMatrix4InPlace(*v,*srt)
      If *v\v[0] < *min\v[0] : *min\v[0] = *v\v[0] : EndIf
      If *v\v[1] < *min\v[1] : *min\v[1] = *v\v[1] : EndIf
      If *v\v[2] < *min\v[2] : *min\v[2] = *v\v[2] : EndIf
     
      If *v\v[0] > *max\v[0] : *max\v[0] = *v\v[0] : EndIf
      If *v\v[1] > *max\v[1] : *max\v[1] = *v\v[1] : EndIf
      If *v\v[2] > *max\v[2] : *max\v[2] = *v\v[2] : EndIf
    Next
  EndProcedure
  
  ; ResetHit
  ;--------------------------------------------------------------------
  Procedure ResetHitAtNode(*tree.KDTree_t,*node.KDNode_t)
    If *node\left
      ResetHitAtNode(*tree,*node\left)
      ResetHitAtNode(*tree,*node\right)
    Else
      *node\hit = #False  
    EndIf
  EndProcedure
  
  ; ResetHit
  ;--------------------------------------------------------------------
  Procedure ResetHit(*tree.KDTree_t)
    ResetHitAtNode(*tree,*tree\root)
  EndProcedure
  
  ; Split
  ;--------------------------------------------------------------------
  Procedure Split(*tree.KDTree_t,*node.KDNode_t,*left.KDNode_t,*right.KDNode_t)
    *tree\m_currentaxis = *node\level % #KDTREE_DIM
    Protected i,j,k
    
    ; Sort Indices
    Dim v.KDSort_t(ListSize(*node\indices())-1)
    Protected *pnt.KDPoint_t
    ForEach *node\indices()
      *pnt = CArray::GetValue(*tree\points, *node\indices())
      v(i)\v = *pnt\v[*tree\m_currentaxis]
      v(i)\ID = *node\indices() 
      i+1
    Next
    
    SortStructuredArray(v(),#PB_Sort_Ascending,OffsetOf(KDSort_t\v),#PB_Float)
    
    i=0
    ForEach *node\indices()
      *node\indices() = v(i)\ID
      i+1
    Next
    
    SelectElement( *node\indices(),ListSize(*node\indices())/2)
    *pnt = CArray::GetValue(*tree\points, *node\indices())
    *node\split_value = *pnt\v[*tree\m_currentaxis]
    Define lnb.i, rnb.i
    ForEach *node\indices()
        
      j = *node\indices()
      *pnt = CArray::GetValue(*tree\points, j)
      If *pnt\v[*tree\m_currentaxis]<*node\split_value
        AddElement(*left\indices())
        *left\indices() = j
        lnb +1
      Else
        AddElement(*right\indices())
        *right\indices() = j
        rnb + 1
      EndIf
    Next 
  EndProcedure
  
  ; Search At Node
  ;--------------------------------------------------------------------
  Procedure SearchAtNode(*tree.KDTree_t,*node.KDNode_t, *query.KDPoint_t, *search.KDSearch_t)
    *search\ID=0
    *search\distance = #KD_F32_MAX
    Protected idx.i
    Protected dist.f
    Protected *retNode.KDNode_t = #Null
    While #True
      Protected split_axis.i = *node\level % #KDTREE_DIM
      *tree\m_cmps +1
      If *node\left = #Null
        *retNode = *node
        ForEach *node\indices()
          *tree\m_cmps +1
          idx = *node\indices()
          dist = SquaredDistance(*query,CArray::GetValue(*tree\points, idx))
          If(dist<*search\distance)
            *search\distance = dist
            *search\ID = idx
          EndIf
        Next
        Break 
      ElseIf(*query\v[split_axis]<*node\split_value)
        *node = *node\left
      Else
        *node = *node\right
      EndIf
    Wend
    ProcedureReturn *retNode
  EndProcedure
  
  ; Search At Node Range
  ;--------------------------------------------------------------------
  Procedure SearchAtNodeRange(*tree.KDTree_t,*node.KDNode_t, *query.KDPoint_t, range.f, *search.KDSearch_t)

    Protected split_axis.i
    Protected idx.i
    Protected dist.f
    
    Protected NewList *to_visit.KDNode_t()
    AddElement(*to_visit())
    *to_visit() = *node
    
    While ListSize(*to_visit())
      Protected NewList *next_search.KDNode_t()
      While ListSize(*to_visit())
        LastElement(*to_visit())
        *node = *to_visit()
        *node\hit = #True
        DeleteElement(*to_visit())
        split_axis = *node\level % #KDTREE_DIM
        
        ; leaf case
        If *node\left = #Null And *node\right = #Null
          ForEach *node\indices()
            *tree\m_cmps +1
           
            idx = *node\indices()
            dist = SquaredDistance(*query,CArray::GetValue(*tree\points, idx))
            If dist<*search\distance
              *search\distance = dist
              *search\ID = idx
            EndIf
          Next
          
        ; recurse case
        Else
          dist = *query\v[split_axis] - *node\split_value
          ; there are 3 possible scenarios
          ; the hypercircle only intersect the left region
          ; the hypercricle only intersect the right region
          ; the hypercircle intersects both

          *tree\m_cmps + 1
          If(Abs(dist)>range)
            If dist<0
              AddElement(*next_search())
              *next_search() = *node\left
            Else
              AddElement(*next_search())
              *next_search() = *node\right
            EndIf
            
          Else
            AddElement(*next_search())
            *next_search() = *node\left
            AddElement(*next_search())
            *next_search() = *node\right
          EndIf
        EndIf
      Wend
      CopyList(*next_search(),*to_visit())
    Wend  
   
  EndProcedure
  
  ; SearchN At Node Range
  ;--------------------------------------------------------------------
  Procedure SearchNAtNodeRange(*tree.KDTree_t,*node.KDNode_t, *query.KDPoint_t, range.f)
    Protected best_idx.i
    Protected best_dist.f = #KD_F32_MAX
    
    Protected split_axis.i
    Protected idx.i
    Protected dist.f
    
    Protected NewList *to_visit.KDNode_t()
    AddElement(*to_visit())
    *to_visit() = *node
    
    While ListSize(*to_visit())
      Protected NewList *next_search.KDNode_t()
      While ListSize(*to_visit())
        LastElement(*to_visit())
        *node = *to_visit()
        DeleteElement(*to_visit())
        split_axis = *node\level % #KDTREE_DIM
        
        ; search leaf node
        If *node\left = #Null
          ForEach *node\indices()
            *tree\m_cmps +1
            idx = *node\indices()
            dist = SquaredDistance(*query, CARray::GetValue(*tree\points, idx))
            If dist<range
              AddElement(*tree\closests())
              *tree\closests()\ID = idx
              *tree\closests()\v = dist
            EndIf
          Next
        ; recurse parent node 
        Else
          dist = *query\v[split_axis]- *node\split_value
          ; there are 3 possible scenarios
          ; the hypercircle only intersect the left region
          ; the hypercricle only intersect the right region
          ; the hypercircle intersects both
          
          *tree\m_cmps +1
          If(Abs(dist)>range)
            If dist<0
              AddElement(*next_search())
              *next_search() = *node\left
            Else
              AddElement(*next_search())
              *next_search() = *node\right
            EndIf
            
          Else
            AddElement(*next_search())
            *next_search() = *node\left
            AddElement(*next_search())
            *next_search() = *node\right
          EndIf
        EndIf
      Wend
      CopyList(*next_search(),*to_visit())
    Wend  
  EndProcedure
  
  ; Search
  ;--------------------------------------------------------------------
  Procedure Search(*tree.KDTree_t, *query.KDPoint_t,*search.KDSearch_t)
    ; Find the closest Node, this will be the upper bound for the next searches
    *tree\m_cmps = 0
    
    *search\distance = #KD_F32_MAX
    Protected *best_node.KDNode_t = SearchAtNode(*tree,*tree\root,*query,*search)
    *best_node\hit = #True
    
    ; now find possible other candidates
    Protected *node.KDNode_t = *best_node
    Protected *parent.KDNode_t
    Protected split_axis.i
    
    While *node\parent
      ; go up
      *parent = *node\parent
      split_axis = *parent\level % #KDTREE_DIM

      ; search the other node      
      Protected *tmp_node.KDNode_t
      Protected *search_node.KDNode_t
      
      If Abs(*parent\split_value - *query\v[split_axis]) <= *search\distance
        ; search opposite node
        If Not *parent\left = *node
          SearchAtNodeRange(*tree,*parent\left,*query,*search\distance,*search)
        Else
          SearchAtNodeRange(*tree,*parent\right,*query,*search\distance,*search)
        EndIf
      EndIf
      
      *node = *parent
    Wend  

  EndProcedure
  
  ; Search
  ;--------------------------------------------------------------------
  Procedure SearchN(*tree.KDTree_t, *query.KDPoint_t,max_distance,max_points)
    ; Find the closest Node, this will be the upper bound for the next searches
    
    Protected best_idx = 0
    Protected best_dist.f = #KD_F32_MAX
    Protected radius.f = 0
    *tree\m_cmps = 0
    Protected founds.i = 0
    ResetHit(*tree)
    ClearList(*tree\closests())
    
    Protected result.KDSearch_t
    Protected *best_node.KDNode_t = SearchAtNode(*tree,*tree\root,*query,result)
    radius = result\distance
    If radius > max_distance
      ProcedureReturn
    EndIf
    
    
    AddElement(*tree\closests())
    *tree\closests()\ID = result\ID
    *tree\closests()\v = radius
    
    SearchNAtNodeRange(*tree,*best_node,*query,max_distance)
    
    ; now find possible other candidates
    Protected *node.KDNode_t = *best_node
    Protected *parent.KDNode_t
    Protected split_axis.i
   
    
    While *node\parent
      ; go up
      *parent = *node\parent
      split_axis = *parent\level % #KDTREE_DIM
      
      ; search the other node
      Protected tmp_idx
      Protected tmp_dist.f = #KD_F32_MAX
      Protected *tmp_node.KDNode_t
      Protected *search_node.KDNode_t
      
      If Abs(*parent\split_value - *query\v[split_axis]) <= max_distance
        ; search opposite node
        If Not *parent\left = *node
          SearchNAtNodeRange(*tree,*parent\left,*query,max_distance)
        Else
          SearchNAtNodeRange(*tree,*parent\right,*query,max_distance)
        EndIf
      EndIf
      *node = *parent
    Wend  
    
    SortStructuredList(*tree\closests(),#PB_Sort_Ascending,OffsetOf(KDSort_t\v),TypeOf(KDSort_t\v))
    
    If max_points >0
      While ListSize(*tree\closests())>max_points
        LastElement(*tree\closests())
        DeleteElement(*tree\closests())
      Wend
    EndIf
  EndProcedure
  
  
  ; Build
  ;--------------------------------------------------------------------
  Procedure Build(*tree.KDTree_t,*pnts.CArray::CArrayV3F32 ,nbp.i, max_levels=99,min_pnts=10)
    *tree\m_nbp = nbp
    *tree\m_levels = max_levels
    *tree\root = NewNode(#Null,0,0)
    *tree\root\ID = *tree\m_id
    *tree\m_id+1
   
    Protected pnt.KDPoint_t
    CArray::Copy(*tree\points, *pnts)
    Protected i

    For i=0 To nbp-1
      AddElement(*tree\root\indices())
      *tree\root\indices() = i
    Next
    
    Protected *node.KDNode_t
    NewList *to_visit.KDNode_t()
    
    AddElement(*to_visit())
    *to_visit() = *tree\root
    While ListSize(*to_visit())
      NewList *next_search.KDNode_t()
      While(ListSize(*to_visit()))
        LastElement(*to_visit())
        *node = *to_visit()
        DeleteElement(*to_visit())
        If *node\level <*tree\m_levels
          If ListSize(*node\indices())>min_pnts
            Protected *left.KDNode_t = NewNode(*node,*tree\m_id,*node\level+1)
            Protected *right.KDNode_t = NewNode(*node,*tree\m_id+1,*node\level+1)
            *tree\m_id+2

            Split(*tree,*node,*left,*right)
            
            *node\left = *left
            *node\right = *right
            *node\leftID = *left\ID
            *node\rightID = *right\ID
            
            ; clear current indices
            ClearList( *node\indices())

            If ListSize(*left\indices())
              AddElement(*next_search())
              *next_search() = *left
            EndIf
            
            If ListSize(*right\indices())
              AddElement(*next_search())
              *next_search() = *right
            EndIf
            
          EndIf
          
        EndIf
        
      Wend
      CopyList(*next_search(),*to_visit())
      FreeList(*next_search())
    Wend
    
    FreeList(*to_visit())
    
    
  EndProcedure
EndModule
  
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 499
; FirstLine = 490
; Folding = ----
; EnableXP
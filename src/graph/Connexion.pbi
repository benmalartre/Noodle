XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"

; ============================================================================
; GRAPH CONNEXION MODULE IMPLEMENTATION
; ============================================================================
Module Connexion
  UseModule Graph
  ;---------------------------------------------------
  ; Constructor
  ;---------------------------------------------------
  Procedure.i New(*p.NodePort::NodePort_t)
    Protected *c.Connexion_t = AllocateStructure(Connexion_t)
    Init(*c,*p\color)
    *c\start = *p
    Set(*c,*p\posx,*p\posy,*p\posx+4,*p\posy)
   
    *c\connected = #False
    ProcedureReturn *c
  EndProcedure
  
  ;---------------------------------------------------
  ; Destructor
  ;---------------------------------------------------
  Procedure Delete(*c.Connexion_t)
    FreeStructure(*c)  
  EndProcedure
  
  ;---------------------------------------------------
  ; Color Blending
  ;---------------------------------------------------
  Procedure.l ColorBlending(Color1.l, Color2.l, Blend.f)
    Protected Red, Green, Blue, Red2, Green2, Blue2
   
    Red = Color1 & $FF
    Green = Color1 >> 8 & $FF
    Blue = Color1 >> 16
    Red2 = Color2 & $FF
    Green2 = Color2 >> 8 & $FF
    Blue2 = Color2 >> 16
   
    Red = Red * Blend + Red2 * (1-Blend)
    Green = Green * Blend + Green2 * (1-Blend)
    Blue = Blue * Blend + Blue2 * (1-Blend)
   
    ProcedureReturn (Red | Green <<8 | Blue << 16)
  EndProcedure
  
  ;---------------------------------------------------
  ; NormalL
  ;---------------------------------------------------
  Procedure NormalL(X,Y, x3, y3, Color, Thickness = 1)
    Protected Width = x3-X
    Protected Hight = y3-Y
    Protected SignX, SignY, n, nn, Thick.f, x2.f, y2.f, Color_Found.l, Application.f, Hypo.f
   
    If Width >= 0
      SignX = 1
    Else
      SignX = -1
      Width = - Width
    EndIf
    If Hight >= 0
      SignY = 1
    Else
      SignY = -1
      Hight = - Hight
    EndIf 
   
   
    Thick.f = Thickness / 2
   
    Hypo.f = Sqr(Width * Width + Hight * Hight)
    Protected CosPhi.f = Width / Hypo
    Protected SinPhi.f = -Sin(ACos(CosPhi))
   
   
    For n = -Thickness To Width + Thickness
      For nn = -Thickness To Hight + Thickness
       
  
        x2 = n * CosPhi - nn * SinPhi
        y2 = Abs(n * SinPhi + nn * CosPhi)
       
        If y2 <= Thick + 0.5
          Application =  0.5 + Thick - y2
          If Application > 1
            Application = 1
          EndIf
          If x2 > -1 And x2 < Hypo + 1
            If x2 < 0
              Application * (1 + x2)
            ElseIf x2 > Hypo
              Application * (1 - x2 + Hypo)
            EndIf
          Else
            Application = 0
          EndIf
          If Application > 0
            If Application < 1
              Color_Found = Point(X + n * SignX, Y + nn * SignY)
              Plot(X + n * SignX, Y + nn * SignY, ColorBlending(Color, Color_Found, Application))
            Else
              Plot(X + n * SignX, Y + nn * SignY, Color)
            EndIf
          EndIf
        EndIf     
      Next
    Next
   
  EndProcedure

  ;---------------------------------------------------
  ; ArrowL
  ;---------------------------------------------------
  Procedure ArrowL(x1.l, y1.l, x2.l, y2.l, Color.l,Thick.f, Llength.f, Angle.f)
    If Llength = 0
      Llength = 0.05*(Sqr((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)))
    EndIf
    Llength = Abs(Llength) : Angle = Abs(Angle*#PI/180.0)
    NormalL(x1, y1,x2, y2,Color,Thick)
    If (Llength > 0.0) And (Abs(x2 - x1) + Abs(y2 - y1) > Llength)
      Protected x33.f = -1*Cos(Angle) * Llength
      Protected y33.f =    Sin(Angle) * Llength
      Protected x44.f = -1*Cos(Angle) * Llength
      Protected y44.f = -1*Sin(Angle) * Llength
     
      Protected SAngle.f = ATan((y1 - y2)/(x2 - x1))
      If (x2 < x1)
        SAngle = SAngle + #PI
      EndIf
     
      Protected x3 = Cos(SAngle)*x33 + Sin(SAngle)*y33
      Protected y3 = Cos(SAngle)*y33 - Sin(SAngle)*x33
      Protected x4 = Cos(SAngle)*x44 + Sin(SAngle)*y44
      Protected y4 = Cos(SAngle)*y44 - Sin(SAngle)*x44   
     
      NormalL(x2, y2,x2+x3,y2+y3, Color,Thick)
      NormalL(x2, y2,x2+x4,y2+y4, Color,Thick)
      If Thick > 4
        Circle(x2,y2,Thick/2,Color)
        Circle(x1,y1,Thick/2,Color)
      EndIf
    EndIf
  EndProcedure
  
  ;---------------------------------------------------
  ; DashL
  ;---------------------------------------------------
  Procedure DashL(x1.i, y1.i, x2.i, y2.i, Color.i,Thick.f, Lstep.f)
    Protected scale.f = (y2-y1)/(x2-x1)
    Protected i
   For i = 0 To 10
      NormalL(x1,y1,x1+Lstep,y1+Lstep*scale,Color,Thick)
      x1 = x1+Lstep + Lstep
      y1 = y1+2*Lstep*scale
   Next
  EndProcedure
  
  ;---------------------------------------------------
  ; DashDotL
  ;---------------------------------------------------
  Procedure DashDotL(x1.i, y1.i, x2.i, y2.i, Color.i,Thick.f,Lstep.f)
    Protected scale.f = (y2-y1)/(x2-x1)
    Protected i
   For i = 0 To 10
     NormalL(x1,y1,x1+Lstep,y1+Lstep*scale,Color, Thick)
     If Thick = 1
        Circle(x1+Lstep + Lstep/2,y1+1.5*Lstep*scale,Thick,Color)
     Else
       Circle(x1+Lstep + Lstep/2,y1+1.5*Lstep*scale,Thick/2,Color)
     EndIf
      x1 = x1+Lstep + Lstep
      y1 = y1+2*Lstep*scale
   Next
  EndProcedure
  

  ;---------------------------------------------------
  ; Init
  ;---------------------------------------------------
  Procedure Init(*c.Connexion_t,color.i)
;     *c\accuracy = 0.04
;     *c\linear = #False
;     *c\antialiased = #False
;     *c\method = 0
    
    *c\color = color
    ProcedureReturn *c
  EndProcedure
  
  ;---------------------------------------------------
  ; Reuse
  ;---------------------------------------------------
  Procedure.i Reuse(*c.Connexion_t)
    
    Protected *s.NodePort::NodePort_t = *c\start
    Protected *e.NodePort::NodePort_t = *c\end
    Set(*c,*s\posx,*s\posy,*e\posx-4,*e\posy)
    *e\connexion = #Null
    *e\connected = #False
    *e\source = #Null
    
    ForEach *s\targets()
      If *s\targets() = *e
        DeleteElement(*s\targets())
      EndIf
    Next
    
    *c\connected = #False
    *c\end = #Null

    ProcedureReturn *c
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw
  ;---------------------------------------------------
  Procedure Draw(*c.Connexion_t,dotted.b)
    Protected beziercount.w=2 ;+Start & End Points
    Define.f u,x,y,xlast,ylast
    Define endpoint.b = 0
    u = 0
    
    Define shadowcolor = RGB(100,100,100)
    Define a.i = *c\d\x - *c\a\x
    Define b.i = *c\d\y - *c\a\y
    Define l.f = Sqr(a*a+b*b)
    Define dot.f =*c\d\y/l - *c\a\y/l
    Define m.f = Sin(dot)
    
    Define shadowoffsetx.i = 4 * -m
    Define shadowoffsety.i = 4 * (1-Abs(m))
    
    ;-------------------------------------------------------------------------------------
    ; USE DEFAULT DRAWING
    ;-------------------------------------------------------------------------------------
    CompilerIf Not Globals::#USE_VECTOR_DRAWING
      If GRAPH_CONNEXION_LINEAR
        ;Draw linear connexion
        FrontColor(*c\color)
        LineXY(*c\a\x,*c\a\y,*c\b\x,*c\b\y,*c\color)
        LineXY(*c\b\x,*c\b\y,*c\c\x,*c\c\y,*c\color)
        LineXY(*c\c\x,*c\c\y,*c\d\x,*c\d\y,*c\color)
    
    ;     OGraphBezier_DrawLine(*b\a\x,*b\a\y+1,*b\b\x-*b\a\x,#Graph_Bezier_Thickness,*b\color,*b\antialiased)
    ;     OGraphBezier_DrawLine(*b\b\x-#Graph_Bezier_Thickness,*b\b\y+#Graph_Bezier_Thickness,#Graph_Bezier_Thickness,*b\c\y-*b\b\y,*b\color,*b\antialiased)
    ;     OGraphBezier_DrawLine(*b\c\x,*b\c\y,*b\d\x-*b\c\x,#Graph_Bezier_Thickness,*b\color,*b\antialiased)
    
      Else
        ;Draw bezier connexion
    ;     CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;       Protected color.q = RGBA(Red(*b\color),Green(*b\color),Blue(*b\color),0.5)
    ;       gSetPen(RGBA(Red(*b\color),Green(*b\color),Blue(*b\color),$FF),1)
    ;       gBezier(*b\a\x,*b\a\y,*b\b\x,*b\b\y,*b\c\x,*b\c\y,*b\d\x,*b\d\y)
    ;     CompilerElse
        Protected i
          Repeat
            xlast = x
            ylast = y
            x = Pow((1-u),3) * *c\a\x + 3*Pow((1-u),2)*u* *c\b\x + 3*(1-u)*Pow(u,2)* *c\c\x + Pow(u,3)* *c\d\x
            y = Pow((1-u),3) * *c\a\y + 3*Pow((1-u),2)*u* *c\b\y + 3*(1-u)*Pow(u,2)* *c\c\y + Pow(u,3)* *c\d\y
      
            If u.f>0
              If dotted
                If i%2=0
                  DrawLine(x,y,xlast,ylast,*c\color,GRAPH_CONNEXION_ANTIALIASED)
                EndIf
                
              Else
                
                DrawLine(x,y,xlast,ylast,*c\color,GRAPH_CONNEXION_ANTIALIASED)
              EndIf
              
            EndIf
            
            u+GRAPH_CONNEXION_ACCURACY
            
            If u>1.0 And endpoint=0
              endpoint=1
              u=1.0
            EndIf
            
            If u>0.0 And u<1.0
              beziercount+1
            EndIf
            i+1
          Until (u>1.0)
    ;     CompilerEndIf
          
      EndIf
        
      ;Draw Arrow Head
      If Not *c\connected

      EndIf
     ;-------------------------------------------------------------------------------------
     ; USE VECTOR DRAWING
     ;-------------------------------------------------------------------------------------
    CompilerElse
      If GRAPH_CONNEXION_LINEAR
       MovePathCursor(*c\a\x,*c\a\y)
       AddPathLine(*c\b\x,*c\b\y)
       AddPathLine(*c\c\x,*c\c\y)
       AddPathLine(*c\d\x,*c\d\y)
       VectorSourceColor(RGBA(Red(*c\color),Green(*c\color),Blue(*c\color),255))
       StrokePath(Connexion::#Graph_Bezier_Thickness)
     Else
       MovePathCursor(*c\a\x,*c\a\y)
       AddPathCurve(*c\b\x,*c\b\y,*c\c\x,*c\c\y,*c\d\x,*c\d\y)
       VectorSourceColor(RGBA(Red(*c\color),Green(*c\color),Blue(*c\color),255))
       StrokePath(Connexion::#Graph_Bezier_Thickness)
     EndIf
     
     CompilerEndIf
       
   EndProcedure
   
  ;---------------------------------------------------
  ; Set
  ;---------------------------------------------------
  Procedure Set(*c.Connexion_t,x1.i,y1.i,x2.i,y2.i)
    *c\a\x = x1
    *c\a\y = y1
    *c\b\x = (x1 + x2)/2
    *c\b\y = y1
    *c\c\x = (x1 + x2)/2
    *c\c\y = y2
    *c\d\x = x2
    *c\d\y = y2
    Protected a.i = *c\d\x - *c\a\x
    Protected b.i = *c\d\y - *c\a\y
    Protected l.f = Sqr(a*a+b*b)
    l = MAXIMUM(l,0.01)
    *c\samples = 1/l * 5
    
  EndProcedure
   
  ;---------------------------------------------------
  ; Set Linear
  ;---------------------------------------------------
  Procedure SetLinear(v.b)
    GRAPH_CONNEXION_LINEAR = v
  EndProcedure
   
  ;---------------------------------------------------
  ; Set Antialiazed
  ;---------------------------------------------------
  Procedure SetAntialiased(v.b)
    GRAPH_CONNEXION_ANTIALIASED = v  
  EndProcedure

  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure Create(*c.Connexion_t,*s.NodePort::NodePort_t,*e.NodePort::NodePort_t)
  
    *e\source = *s
    *e\connected = #True
    *s\connected = #True
    
    *s\connexion = *c
    *e\connexion = *c
    *c\connected = #True
  EndProcedure
  
  ;---------------------------------------------------
  ; Update Connexion position relative to view
  ;---------------------------------------------------
  Procedure ViewPosition(*c.Connexion_t)
    If Not *c\start = #Null And Not *c\end = #Null
      Set(*c,*c\start\posx,*c\start\posy,*c\end\posx,*c\end\posy)
    EndIf
  EndProcedure

  ;---------------------------------------------------
  ; Drag
  ;---------------------------------------------------
  Procedure Drag(*c.Connexion_t,x.i,y.i)
  
    *c\a\x = *c\start\posx
    *c\a\y = *c\start\posy
    *c\b\x = (*c\start\posx + x)/2
    *c\b\y = *c\start\posy
    *c\c\x = (*c\start\posx + x)/2
    *c\c\y = y
    *c\d\x = x
    *c\d\y = y
  
    Protected a.i = *c\a\x - *c\d\x
    Protected b.i = *c\a\y - *c\d\y
    Protected l.f = Sqr(a*a+b*b)
    
    l = MAXIMUM(l,0.01)
    *c\samples = 1/l*10
  EndProcedure

  ;---------------------------------------------------
  ; Recurse Possible
  ;---------------------------------------------------
  Procedure RecursePossible(*connexion.Connexion_t,datatype.i,datacontext.i,datastructure.i,way.b)
    If Not *connexion : ProcedureReturn : EndIf
    
    ;Recurse Backward
    If Not way
      Protected *port.NodePort::NodePort_t = *connexion\start
      
      Protected *node.Node::Node_t = *port\node
      Protected *other.Connexion::Connexion_t
  
      ForEach *node\inputs()
        If *node\inputs()\polymorph
          If *node\inputs()\connected
            *other = *node\inputs()\connexion
            If RecursePossible(*other,datatype,datacontext,datastructure,way) = -1
              ProcedureReturn -1
            EndIf
  ;         Else
  ;           ; Check Data Type
  ;           If Not Bool(*other\datatype & *c\start\currenttype) :  ProcedureReturn #fo0 : EndIf
  ;           
  ;           ; Check Data Context
  ;           If Not Bool(*p\currentcontext = *c\start\currentcontext): ProcedureReturn #foO : EndIf
          EndIf
        EndIf
      Next
      
      ProcedureReturn 1
    Else
      
    EndIf
        
  EndProcedure

  ;---------------------------------------------------
  ; Is Connexion Possible
  ;---------------------------------------------------
  Procedure.b Possible(*c.Connexion_t,*p.NodePort::NodePort_t)
    
    If *p\currenttype = Attribute::#ATTR_TYPE_NEW : ProcedureReturn(#True) : EndIf
    
    ; Check ItSelf
    If  *p\node = *c\start\node : ProcedureReturn(#False) : EndIf
    
    ; Check Data Type
    If Not Bool(*p\datatype & *c\start\currenttype) And Not Bool(*c\start\datatype & *p\currenttype)  :  ProcedureReturn #False : EndIf
    
    ; Check Data Context
    ;If Not Bool(*p\currentcontext = *c\start\currentcontext): ProcedureReturn #False : EndIf
    
    ; Recurse Branch
    Protected *node.Node::Node_t = *p\node
    Protected *connexion.Connexion::Connexion_t
    Protected possible.b
    ForEach *node\inputs()
      If *node\inputs()\connected = #True
        *connexion = *node\inputs()\connexion
        possible = RecursePossible(*connexion,*c\start\currenttype,*c\start\currentcontext,*c\start\currentstructure,#False)
        If Not possible : ProcedureReturn #False : EndIf
      EndIf
    Next
  
    ProcedureReturn #True
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Connect
  ;---------------------------------------------------
  Procedure.b Connect(*c.Connexion_t,*p.NodePort::NodePort_t,interactive.b)
    
    If Not Possible(*c,*p)
      *c\start\selected = #False
      *p\selected = #False
      ProcedureReturn #False
    EndIf
    
    If interactive And *p\datatype = Attribute::#ATTR_TYPE_NEW
      ;Get Previous Last Port
      Protected *node.Node::Node_t = *p\node
      SelectElement(*node\inputs(),ListSize(*node\inputs())-2)
      Protected *last.NodePort::NodePort_t = *node\inputs()
      
      ;Update Last Port
      Protected name.s = *last\name
      Protected newname.s
      Protected last.s
      last = Right(name,1)
      If Asc(last)>47 And Asc(last)<58
        Protected id.i = Val(last)
        newname = Left(name,Len(name)-1)+Str(id+1)
      Else
        newname = name+"1"
      EndIf
      
      *p\name = newname
      *p\datatype = *last\datatype
      *p\currenttype = *last\currenttype
      ForEach *node\outputs()
        Node::PortAffectByPort(*node, *p, *node\outputs())
      Next
      
      NodePort::Update(*p,*last\currenttype,*last\currentcontext,*last\currentstructure)
  
      ;Create New Last Port
      Node::AddInputPort(*p\node,"New("+newname+")...",Attribute::#ATTR_TYPE_NEW)
      
    ElseIf Not *p\currenttype = *c\start\currenttype
      If *c\start\currenttype = Attribute::#ATTR_TYPE_UNDEFINED
        NodePort::Update(*c\start,*p\currenttype,*p\currentcontext,*p\currentstructure)
      Else
        Node::UpdatePorts(*p\node,*c\start\currenttype,*c\start\currentcontext,*c\start\currentstructure)
      EndIf
      
    EndIf
   
    
    *p\selected = #False
    *c\start\selected = #False
    *c\end = *p
    
    ; Inputs ports only accept ONE connexion
    If Not *p\io
      If *p\connected
        ; Reuse Existing connexion
        Protected *connexion.Connexion_t = *p\connexion
;         Define *oldsrc.NodePort::NodePort_t = *connexion\end\source
;         
;         ; Remove target from old source
;         ForEach *oldsrc\targets()
;           If *oldsrc\targets() = *connexion\start
;             DeleteElement(*oldsrc\targets())
;             Break
;           EndIf
;         Next
;             
;         *connexion\start\connected = #False
;         *connexion\start = *c\start
;         *connexion\color = *c\start\color
;         *connexion\end\source = *connexion\start
        
        AddElement(*connexion\start\targets())
        *connexion\start\targets() = *connexion\end
        
        ProcedureReturn #False
      Else
        AddElement(*c\start\targets())
        *c\start\targets() = *p
      EndIf 
      
    Else
      AddElement(*p\targets())
      *p\targets() = *c\start
    EndIf
    
    ; connection callback
    Define inode.Node::INode = *p\node
    inode\OnConnect(*p)
    inode = *c\start\node
    inode\OnConnect(*c\start)

    ProcedureReturn #True
  
  EndProcedure

  ;---------------------------------------------------
  ; Set Head
  ;---------------------------------------------------
  Procedure SetHead(*c.Connexion_t,*p.NodePort::NodePort_t)
    If Possible(*c.Connexion_t,*p.NodePort::NodePort_t)
      Set(*c,*c\a\x,*c\a\y,*p\posx,*p\posy)
    EndIf
      
  EndProcedure

  ;---------------------------------------------------
  ; Share Parent Node
  ;---------------------------------------------------
  Procedure ShareParentNode(*connexion.Connexion_t)
    Protected *start.Node::Node_t= *connexion\start\node
    Protected *end.Node::Node_t = *connexion\end\node
    
    If *start\parent = *end\parent : ProcedureReturn #True : EndIf
    ProcedureReturn #False
   
  EndProcedure

EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 29
; FirstLine = 1
; Folding = ----
; EnableXP
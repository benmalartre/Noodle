XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "Divot.pbi"
XIncludeFile "Label.pbi"
XIncludeFile "Check.pbi"
XIncludeFile "Edit.pbi"
XIncludeFile "Number.pbi"
XIncludeFile "Button.pbi"
XIncludeFile "Group.pbi"
XIncludeFile "Head.pbi"
XIncludeFile "Knob.pbi"

;========================================================================================
; Property Module Declaration
;========================================================================================
DeclareModule ControlProperty
  UseModule Math
  #HEAD_HEIGHT = 24
  
  Enumeration 
    #PROPERTY_FLAT
    #PROPERTY_LABELED
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Structure ControlProperty_t Extends Control::Control_t
    expanded  .b
    pickID    .i
    imageID   .i
    label     .s
    append    .i
    row       .i
    down      .i
    *head.ControlHead::ControlHead_t
    overchild .Control::IControl
    focuschild.Control::IControl
    Array *children .Control::Control_t(10)
    Array rowflags .i(10)
    List *groups.ControlGroup::ControlGroup_t()
    chilcount .i
    current   .i
    closed    .b
    decoration.i
    lock.Control::IControl
    refresh.Control::IControl
    
    ; drawing position
    dx.i
    dy.i
    
    slotID.i
  
  EndStructure
  
  Interface IControlProperty Extends Control::IControl
  EndInterface
  
  Declare New( *object.Object::Object_t, name.s, label.s,x.i=0,y.i=0,width.i=320,height.i=120 ,decoration = #PROPERTY_LABELED)
  Declare Delete(*ctrl.ControlProperty_t)
  Declare OnEvent( *Me.ControlProperty_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )  
  Declare AppendStart( *Me.ControlProperty_t )
  Declare Append( *Me.ControlProperty_t, ctl.Control::IControl )
  Declare AppendStop( *Me.ControlProperty_t )
  Declare RowStart( *Me.ControlProperty_t )
  Declare RowEnd( *Me.ControlProperty_t )
  Declare AddHead( *Me.ControlProperty_t)
  Declare AddBoolControl( *Me.ControlProperty_t, name.s,label.s,value.b,*obj.Object::Object_t)
  Declare AddIntegerControl( *Me.ControlProperty_t,name.s,label.s,value.i,*obj.Object::Object_t)
  Declare AddFloatControl( *Me.ControlProperty_t,name.s,label.s,value.f,*obj.Object::Object_t)
  Declare AddVector2Control(*Me.ControlProperty_t,name.s,label.s,*value.v2f32,*obj.Object::Object_t)
  Declare AddVector3Control(*Me.ControlProperty_t,name.s,label.s,*value.v3f32,*obj.Object::Object_t)
  Declare AddQuaternionControl(*Me.ControlProperty_t,name.s,label.s,*value.q4f32,*obj.Object::Object_t)
  Declare AddMatrix4Control(*Me.ControlProperty_t,name.s,label.s,*value.m4f32,*obj.Object::Object_t)
  Declare AddReferenceControl( *Me.ControlProperty_t,name.s,value.s,*obj.Object::Object_t)
  Declare AddStringControl( *Me.ControlProperty_t,name.s,value.s,*obj.Object::Object_t)
  Declare AddColorControl(*Me.ControlProperty_t,name.s,label.s,*value.c4f32,*obj.Object::Object_t)
  Declare AddButtonControl(*Me.ControlProperty_t, name.s,label.s, color.i, width=18, height=18)
  Declare AddKnobControl(*Me.ControlProperty_t, name.s,color.i, width.i=64, height.i=64)
  Declare AddGroup( *Me.ControlProperty_t,name.s)
  Declare EndGroup( *Me.ControlProperty_t)
  Declare Init( *Me.ControlProperty_t)
  Declare Refresh( *Me.ControlProperty_t)
  Declare EventWithFilter(*Me.ControlProperty_t,filter.i,ev_type.i)
  Declare Clear( *Me.ControlProperty_t )
  Declare.i GetWidth(*Me.ControlProperty_t)
  Declare.i GetHeight(*Me.ControlProperty_t)
  
  Declare Test(*prop.ControlProperty_t,*mesh.Polymesh::Polymesh_t)
  
  DataSection 
    ControlPropertyVT: 
    Data.i @OnEvent()
    Data.i @Delete()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  CONTROL PROPERTY MODULE IMPLEMENTATION 
; ============================================================================
Module ControlProperty
  UseModule Math


  ; ----------------------------------------------------------------------------
  ;  hlpNextItem
  ; ----------------------------------------------------------------------------
  Procedure hlpNextItem( *Me.ControlGroup::ControlGroup_t )
    ; ---[ Unfocus Current Item ]-----------------------------------------------
    *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected iBound.i = *Me\chilcount - 1
    Protected n.i = (*me\current+1)%iBound
    
    Protected ev_data.Control::EventTypeDatas_t 
    *Me\focuschild = *Me\children(n)
    *Me\focuschild\OnEvent(#PB_EventType_Focus,@ev_data)
    ;*Me\focuschild\Event( #PB_EventType_Focus, #Null);*ev_data )
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Clear
  ; ----------------------------------------------------------------------------
  Procedure Clear( *Me.ControlProperty_t )
    Protected i
    Protected *ctl.Control::IControl
    Protected *c.Control::Control_t
    
    If ArraySize(*Me\children())>0
      
      For i=0 To *Me\chilcount-1
        *ctl = *Me\children(i)
        *c = *ctl
        If *ctl<>#Null : *ctl\Delete() : EndIf
      Next
      ReDim *Me\children(0)
      ReDim *Me\rowflags(0)
      *Me\chilcount = 0
    EndIf
    
    *Me\dx = 0
    *Me\dy = 0
    
    *Me\focuschild = #Null
    *Me\current = #Null
    *Me\overchild = #Null
    
    
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  Get Image ID
  ; ----------------------------------------------------------------------------
  Procedure.i GetImageID( *Me.ControlProperty_t)
    ProcedureReturn *Me\imageID
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ; Select Gadget Under Mouse 
  ; ----------------------------------------------------------------------------
  Procedure Pick(*Me.ControlProperty_t)
    Protected xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX )
    Protected ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY )
    
    Protected iw = ImageWidth(*Me\imageID)
    Protected ih = ImageHeight(*Me\imageID)

    If xm<0 Or ym<0 Or xm>= iw Or im>=ih : ProcedureReturn : EndIf
    
    xm = Math::Min( Math::Max( xm, 0 ), iw - 1 )
    ym = Math::Min( Math::Max( ym, 0 ), ih - 1 )
    
     ; First get gadget under mouse
    StartDrawing( ImageOutput(*Me\imageID) )
    *Me\pickID = Point(xm,ym)-1
    StopDrawing()
    If *Me\pickID >-1 And *Me\pickID<*Me\chilcount
      Protected *overchild.Control::Control_t = *Me\children(*Me\pickID)
      If *overchild\type = Control::#CONTROL_GROUP
        ControlGroup::Pick(*overchild)
      EndIf
    EndIf
  
    ProcedureReturn *Me\pickID
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------------------------------------------
  Procedure.i DrawPickImage( *Me.ControlProperty_t)
    ResizeImage(*Me\imageID, *Me\sizX, *Me\sizY)
    ; ---[ Local Variables ]----------------------------------------------------
    Protected i     .i = 0
    Protected iBound.i = *Me\chilcount - 1
  
    Protected  son  .Control::IControl
    Protected *son  .Control::Control_t
    
    If *Me\chilcount
      If *Me\expanded
        ; ---[ Draw ]---------------------------------------------------------------
        StartVectorDrawing( ImageVectorOutput(*Me\imageID) )
        AddPathBox( 0, 0, *Me\sizX, *Me\sizY)
        VectorSourceColor(RGBA(0,0,0,255))
        FillPath()
        
        For i=0 To iBound
          *son = *Me\children(i)
          If *son\type = Control::#CONTROL_GROUP
            AddPathBox( *son\posX, *son\posY, *son\sizX, *son\sizY)
            VectorSourceColor(RGBA(i+1,0,0,255))
            FillPath()
          Else
            AddPathBox( *son\posX, *son\posY, *son\sizX, *son\sizY)
            VectorSourceColor(RGBA(i+1,0,0,255))
            FillPath()
          EndIf
          
        Next
        StopVectorDrawing()
        
      Else
        ; ---[ Draw ]---------------------------------------------------------------
        StartVectorDrawing( ImageVectorOutput(*Me\imageID) )        
        AddPathBox( 0, 0, *Me\sizX, *Me\sizY )
        VectorSourceColor(RGBA(0,0,0,255))
        FillPath()
        *son = *Me\children(0)
        AddPathBox(*son\posX,*son\posY,*son\sizX,*son\sizY)
        VectorSourceColor(RGBA(1,0,0,255))
        FillPath()
        StopVectorDrawing()

      EndIf
    EndIf
   
  EndProcedure
  
  Procedure.i DrawTitle( *Me.ControlProperty_t)
    
  EndProcedure
  
    
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure.i Draw( *Me.ControlProperty_t)
    Protected label.s = *Me\label
    Protected lalen.i = Len(label)
    Protected maxW .i = *Me\sizX - 21
    Protected curW .i
   
    ; ---[ Tag Picking Surface ]------------------------------------------------
    DrawPickImage( *Me)    
    
    If *Me\chilcount
      ; ---[ Local Variables ]----------------------------------------------------
      Protected i     .i = 0
      Protected iBound.i = *Me\chilcount - 1
      Protected  son  .Control::IControl
      Protected *son  .Control::Control_t
      Protected ev_data.Control::EventTypeDatas_t
        
      If *Me\expanded
        ; ---[ Drawing Start ]------------------------------------------------------
        StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
        ResetCoordinates()
        AddPathBox( *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::COLORA_MAIN_BG)
        FillPath()

        ; ---[ Redraw Children ]----------------------------------------------------
        For i=0 To iBound
           son = *Me\children(i)
          *son = son
          ev_data\xoff = *son\posX
          ev_data\yoff = *son\posY      
          son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
        Next
        
        ; ---[ Drawing End ]--------------------------------------------------------
        StopVectorDrawing()
      Else
        ; ---[ Drawing Start ]------------------------------------------------------
        StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
        ResetCoordinates()
        AddPathBox( *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
        VectorSourceColor( UIColor::COLORA_MAIN_BG )
        FillPath()
        
;         ; ---[ Redraw Head ]----------------------------------------------------
;         son = *Me\children(0)
;         *son = son
;         ev_data\xoff = *son\posX
;         ev_data\yoff = *son\posY     
;         son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
    
        ; ---[ Drawing End ]--------------------------------------------------------
        StopVectorDrawing()
      EndIf
    EndIf

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Draw Empty
  ; ----------------------------------------------------------------------------
  Procedure.i DrawEmpty( *Me.ControlProperty_t)
    Protected w = GadgetWidth(*Me\gadgetID)
    Protected h = GadgetHeight(*Me\gadgetID)
    
    StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
    AddPathBox( 0, 0, w,h);
    VectorSourceColor( UIColor::COLORA_MAIN_BG )
    FillPath()
    StopVectorDrawing()
  EndProcedure
  
  ; ---[ AppendStart ]----------------------------------------------------------
  Procedure AppendStart( *Me.ControlProperty_t )
    
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If *Me\append : ProcedureReturn : EndIf
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\append = #True
  EndProcedure

  ; ---[ Append ]---------------------------------------------------------------
  Procedure.i Append( *Me.ControlProperty_t, *ctl.Control::Control_t )
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *ctl
      ProcedureReturn
    EndIf
  
    
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If #False = *Me\append
      ; ...[ FAILED ]...........................................................
     ProcedureReturn #False
    EndIf
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected Me.Control::IControl     = *Me
  
    ; ---[ Check Array Space ]--------------------------------------------------
    If *Me\chilcount > ArraySize( *Me\children() )
      ReDim *Me\children( *Me\chilcount + 10 )
      ReDim *Me\rowflags( *Me\chilcount + 10 )
    EndIf
    
    ; ---[ Set Me As Control Parent ]-------------------------------------------
    *ctl\parent = Me
  
    ; ---[ Append Control ]-----------------------------------------------------
    *Me\children( *Me\chilcount ) = *ctl
  
    ; ---[ Set Row Flag ]-------------------------------------------------------
    *Me\rowflags( *Me\chilcount ) = *Me\row
  
    ; ---[ One More Control ]---------------------------------------------------
    *Me\chilcount + 1
    
    ; ---[ Expand height ]------------------------------------------------------
    If *Me\chilcount > 1 And *Me\rowflags(*Me\chilcount) <> *Me\rowflags(*Me\chilcount-1)
      *Me\dy + *ctl\sizY
    ElseIf *Me\chilcount <= 1
      *Me\dy + *ctl\sizY
    EndIf
  
    ; ---[ Return The Added Control ]-------------------------------------------
    ProcedureReturn( ctl )
  
  EndProcedure
  ; ---[ AppendStop ]-----------------------------------------------------------
  Procedure AppendStop( *Me.ControlProperty_t )
    
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If Not *Me\append : ProcedureReturn( void ) : EndIf
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\append = #False
    
    ; ---[ Recompute Size ]-----------------------------------------------------
    *Me\sizY = *Me\dy
    ResizeGadget(*Me\gadgetID,#PB_Ignore,#PB_Ignore,#PB_Ignore,*Me\sizY)
    
    ; ---[ Update Control And Children ]----------------------------------------
    Draw( *Me )

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; RowStart
  ;-----------------------------------------------------------------------------
  Procedure RowStart( *Me.ControlProperty_t )
    
    ; Check Row Status
    If *Me\row : ProcedureReturn( void ) : EndIf
    
    ; Update Status
    *Me\row = #True
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; RowEnd
  ;-----------------------------------------------------------------------------
  Procedure RowEnd( *Me.ControlProperty_t )
    
    ; Check Row Status
    If Not *Me\row : ProcedureReturn( void ) : EndIf
    
    ; Update Current Child
    If *Me\chilcount>0 : *Me\rowflags( *Me\chilcount - 1 ) = #False : EndIf
    
    ; Update Status
    *Me\row = #False
    
  EndProcedure
;   ; ---[ Draw Title Bar ]-------------------------------------------------------
;   ;------------------------------------------------------------
;   Procedure DrawHead(*Me.ControlProperty_t)
;   
;     StartDrawing( CanvasOutput(*Me\head) )
;     
;     Box( 0, 0, *Me\sizX, #HEAD_HEIGHT, Globals::COLOR_MAIN_BG )
;     ;raaBox(50,10,*Me\sizX,1,Globals::COLOR_GROUP_LABEL)
;     Line(0,5,*Me\sizX,1,Globals::COLOR_GROUP_FRAME)
;   
;   ;   raaDrawingMode( #PB_2DDrawing_Outlined )
;   ;   raaClipBoxMask( 12, 0, curW+6, 12 )
;   ;   raaRoundBox   ( 3.0, 7.0, *Me\sizX-7, *Me\sizY-10.0, 5.0, 5.0, Globals::COLOR_GROUP_FRAME )
;   ;   raaResetClip  ()
;   
;       DrawingMode( #PB_2DDrawing_Default )
;       Box( 12, 0, TextWidth(*Me\label)+6, 12, Globals::COLOR_MAIN_BG )
;       DrawingMode( #PB_2DDrawing_Transparent )
;       DrawingFont(FontID(Globals::#FONT_HEADHEADER))
;       DrawText( 15,  0, *Me\label, Globals::COLOR_GROUP_LABEL )
;     
;     StopDrawing()
;   EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Button Control
  ;-----------------------------------------------------------------------------
  Procedure AddButtonControl( *Me.ControlProperty_t, name.s,label.s, color.i,width=18, height=18)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *btn.ControlButton::ControlButton_t
    *Me\dx =0
    Protected *Ctl.Control::Control_t
    
    OpenGadgetList(*Me\gadgetID)
    ; Add Parameter
    If  ListSize(*Me\groups()) And *Me\groups()
      *btn = ControlButton::New(*obj,name,name,#False, 0,*Me\dx,*Me\dy+2,width,height, color )
      ControlGroup::Append(*Me\groups(),*btn)
      If Not *Me\groups()\row Or Not *Me\groups()\chilcount > 1 : *Me\dy + 22 : EndIf
    Else
      *btn = ControlButton::New(*obj,name,name,#False, 0,*Me\dx,*Me\dy+2,width,height, color )
      Append( *Me, *btn)
      If Not *Me\row : *Me\dy + 22 : EndIf
    EndIf
    CloseGadgetList()
    ProcedureReturn(*btn)
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Knob Control
  ;-----------------------------------------------------------------------------
  Procedure AddKnobControl( *Me.ControlProperty_t, name.s, color.i,width=64, height=64)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *knob.ControlKnob::ControlKnob_t
    Protected *ctl.Control::Control_t
    
    ; Add Parameter
    If  ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*knob)
      If Not *Me\groups()\row Or Not *Me\groups()\chilcount > 1 : *Me\dy + height : EndIf
    Else
      *knob = ControlKnob::New(*Me\gadgetID,name,0, 0,*Me\dx,*Me\dy,width,height, color )
      Append( *Me, *knob)
      If *Me\row  : *Me\dx + width : Else : *Me\dy + height : EndIf
    EndIf

    ProcedureReturn(*knob)
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Bool Control
  ;-----------------------------------------------------------------------------
  Procedure AddBoolControl( *Me.ControlProperty_t, name.s,label.s,value.b,*obj.Object::Object_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    
    *Me\dx =0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    Protected *Ctl.Control::Control_t
    
    ; Add Parameter
    If  ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::RowStart(*Me\groups())
      ControlGroup::Append(*Me\groups(),ControlDivot::New(*obj,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append(*Me\groups(),ControlLabel::New(*obj,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *Ctl = ControlCheck::New(*obj,name+"Check",name, value,0,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      ControlGroup::Append(*Me\groups(),*Ctl)
      ControlGroup::RowEnd(*Me\groups())
    Else
      
      RowStart(*Me)
      Append( *Me,ControlDivot::New(*obj,name+"Divot" ,ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append( *Me,ControlLabel::New(*obj,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *Ctl = ControlCheck::New(*obj, name+"Check",name, value,0,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      Append( *Me,*Ctl)
    
      RowEnd(*Me)
    EndIf
    
    ; Connect Signal
    If *obj
      Protected *class.Class::Class_t = *obj\class
      Object::SignalConnect(*obj,*Ctl\slot,0)
    EndIf
    
    
    *Me\dy + 22
    ProcedureReturn(#True)
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Long Control
  ;-----------------------------------------------------------------------------
  Procedure AddIntegerControl( *Me.ControlProperty_t,name.s,label.s,value.i,*obj.Object::Object_t)
    ; Sanity Check
    If Not*Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    *Me\dx = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    ; Add Parameter
    If ListSize(*Me\groups()) And *Me\groups()
     ControlGroup::RowStart( *Me\groups())
      ControlGroup::Append( *Me\groups(), ControlDivot::New(*obj,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append( *Me\groups(), ControlLabel::New(*obj,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *Ctl = ControlNumber::New(*obj,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      ControlGroup::Append( *Me\groups(), *Ctl  )
      ControlGroup::RowEnd( *Me\groups())
    Else
      RowStart(*Me)
      Append(*Me,ControlDivot::New(*obj,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append(*Me,ControlLabel::New(*obj,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *Ctl = ControlNumber::New(*obj,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      Append(*Me, *Ctl)
      RowEnd(*Me)
    EndIf

    ; Connect Signal
    If *obj
      Object::SignalConnect(*obj,*Ctl\slot,0)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + 22
    ProcedureReturn(#True)

    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Float Control 
  ;-----------------------------------------------------------------------------
  Procedure AddFloatControl( *Me.ControlProperty_t,name.s,label.s,value.f,*obj.Object::Object_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    *Me\dx = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
        
    ; Add Parameter
    If ListSize(*Me\groups()) And *Me\groups()
     ControlGroup::RowStart( *Me\groups())
      ControlGroup::Append( *Me\groups(), ControlDivot::New(*obj,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append( *Me\groups(), ControlLabel::New(*obj,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *Ctl = ControlNumber::New(*obj,name+"Number",value,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      ControlGroup::Append( *Me\groups(), *Ctl )
      ControlGroup::RowEnd( *Me\groups())
    Else
      RowStart(*Me)
      Append(*Me,ControlDivot::New(*obj,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append(*Me,ControlLabel::New(*obj,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *Ctl = ControlNumber::New(*obj,name+"Number",value,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      Append(*Me,*Ctl )
      RowEnd(*Me)
    EndIf
    
    
    ; Connect Signal
    If *obj
       Object::SignalConnect(*obj,*Ctl\slot,0)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + 22
    
    ProcedureReturn(#True)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Vector2 Control
  ;-----------------------------------------------------------------------------
  Procedure AddVector2Control(*Me.ControlProperty_t,name.s,label.s,*value.v2f32,*obj.Object::Object_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    *Me\dx = 0
    *Me\dy + 10
    Protected w= *Me\sizX/3
    ; Create Group
    Protected options.i = 0;ControlGroup::#Autostack|ControlGroup::#Autosize_V;
    Protected width = GadgetWidth(*Me\gadgetID)/2
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*obj, name, name,*Me\gadgetID, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    ; Add X Parameter
    ControlGroup::Append(*group,ControlDivot::New(*obj,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*obj,"XLabel","X",#False,0,*Me\dx+20,14,(width-20)*0.25,21 ))
    *xCtl = ControlNumber::New(*obj,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18)
    ControlGroup::Append(*group, *xCtl )
    
    ; Add Y Parameter
    ControlGroup::Append(*group, ControlDivot::New(*obj,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*obj,"YLabel","Y",#False,0,*Me\dx+width+20,14,(width-20)*0.25,21 ))
    *yCtl = ControlNumber::New(*obj,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *yCtl )
    
    ; Terminate Group
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf
    
    ; Connect Signals
    If *obj
      Object::SignalConnect(*obj,*xCtl\slot,0)
      Object::SignalConnect(*obj,*yCtl\slot,1)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + *group\sizY
    ProcedureReturn(#True)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Vector3 Control
  ;-----------------------------------------------------------------------------
  Procedure AddVector3Control(*Me.ControlProperty_t,name.s,label.s,*value.v3f32,*obj.Object::Object_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    *Me\dx = 0
    Protected w = *Me\sizX/4
    
    ; Create Group
    Protected options.i = 0;ControlGroup::#Autostack|ControlGroup::#Autosize_V;
    Protected width = GadgetWidth(*Me\gadgetID)/3
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*obj, name, name,*Me\gadgetID, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    ; Add X Parameter
;     ControlGroup::Append(*group,ControlDivot::New(*obj,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*obj,"XLabel","X",#False,0,*Me\dx+20,14,(width-20)*0.25,21 ))
    *xCtl = ControlNumber::New(*obj,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18)
    ControlGroup::Append(*group, *xCtl )
    
    ; Add Y Parameter
;     ControlGroup::Append(*group, ControlDivot::New(*obj,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*obj,"YLabel","Y",#False,0,*Me\dx+width+20,14,(width-20)*0.25,21 ))
    *yCtl = ControlNumber::New(*obj,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *yCtl )
    
    ; Add Z Parameter
;     ControlGroup::Append(*group, ControlDivot::New(*obj,"ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*obj,"ZLabel","Z",#False,0,*Me\dx+2*width+20,14,(width-20)*0.25,21 ))
    *zCtl = ControlNumber::New(*obj,"ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *zCtl)
    
    ; Terminate Group
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf

    ; Connect Signals
    If *obj
      Object::SignalConnect(*obj,*xCtl\slot,0)
      Object::SignalConnect(*obj,*yCtl\slot,1)
      Object::SignalConnect(*obj,*zCtl\slot,2)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + *group\sizY
    ProcedureReturn(#True)
  EndProcedure

; ;--------------------------------------------------------------------
; ;  Add Vector4 Control
; ;--------------------------------------------------------------------
; Procedure AddVector4Control(*Me.ControlProperty_t,name.s,label.s,*value.v4f32,*obj.Object::Object_t)
;   ; Sanity Check
;   ;------------------------------
;   CHECK_PTR1_BOO(*Me)
;   
;   Protected Me.ControlProperty::IControlProperty = *Me
;   Protected Ctl.Control::IControl
;   *Me\dx = 5
;   ; Create Group
;   ;------------------------------
;   Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V;
;   Protected width = GadgetWidth(*Me\gadgetID)/3
;   Define group.Control::IControlGroup = newControl::IControlGroup( name, name,*Me\gadgetID, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
;   
;   ; Add X,Y,Z,W parameters
;   ;------------------------------
;   ControlGroup::AppendStart(*Me)
;   ControlGroup::RowStart(*Me)
;   
;   ;X
;   ControlGroup::Append(*group, newControl::IControlDivot("XDivot",#RAA_DIVOT_ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
;   ;ControlGroup::Append(*group, newControl::IControlLabel("XLabel","X",#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
;   Ctl = ControlGroup::Append(*group, newControl::IControlNumber("XNumber",*value\x,#RAA_CTL_NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
;   If *obj : *obj\SignalConnect(Ctl\SignalOnChanged(),0) : EndIf
;   
;   ;Y
;   ControlGroup::Append(*group, newControl::IControlDivot("YDivot",#RAA_DIVOT_ANIM_NONE,0,*Me\dx+width,*Me\dy+2,18,18 ))
;   ;ControlGroup::Append(*group, newControl::IControlLabel("YLabel","Y",#False,0,*Me\dx+width+20,*Me\dy,(width-20)*0.25,21 ))
;   Ctl = ControlGroup::Append(*group, newControl::IControlNumber("YNumber",*value\y,#RAA_CTL_NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
;   If *obj : *obj\SignalConnect(Ctl\SignalOnChanged(),1) : EndIf
;   
;   ;Z
;   ControlGroup::Append(*group, newControl::IControlDivot("ZDivot",#RAA_DIVOT_ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
;   ;ControlGroup::Append(*group, newControl::IControlLabel("ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,(width-20)*0.25,21 ))
;   Ctl = ControlGroup::Append(*group, newControl::IControlNumber("ZNumber",*value\z,#RAA_CTL_NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
;   If *obj : *obj\SignalConnect(Ctl\SignalOnChanged(),2) : EndIf
;   
;   ;W
;   ControlGroup::Append(*group, newControl::IControlDivot("WDivot",#RAA_DIVOT_ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
;   ;ControlGroup::Append(*group, newControl::IControlLabel("ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,(width-20)*0.25,21 ))
;   Ctl = ControlGroup::Append(*group, newControl::IControlNumber(">Number",*value\w,#RAA_CTL_NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
;   If *obj : *obj\SignalConnect(Ctl\SignalOnChanged(),3) : EndIf
;   
;   ControlGroup::RowEnd(*group)
;   ControlGroup::AppendStop(*group)
;   
;   ; Add Group to PPG
;   ;---------------------------------
;   ; ---[ Add Parameter ]--------------------------------------------
;   If ListSize(*Me\groups()) And *Me\groups()
;    *Me\groups()\Append(group)
;   Else
;     Append(*Me,group)
;   EndIf
;   
;   
;   ; Offset for Next Control
;   ;---------------------------------
;   *Me\dy + group\GetHeight()
; 
;   ProcedureReturn(#True)
; EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Quaternion Control
  ;-----------------------------------------------------------------------------
  Procedure AddQuaternionControl(*Me.ControlProperty_t,name.s,label.s,*value.q4f32,*obj.Object::Object_t)
    ; Sanity Check
    ;------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    
    ; Create Group
    ;------------------------------
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *obj,name, name,*Me\gadgetID, *Me\dx, *Me\dy, width*4, 50 ,options)
    
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    Protected *aCtl.Control::Control_t

    ; Add X,Y,Z parameters
    ;------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    Protected w= *Me\sizX/4
    ;X
    ControlGroup::Append(*group,ControlDivot::New(*obj,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*obj,"XLabel","X",#False,0,*Me\dx+20,14,(width-20)*0.25,21 ))
    *xCtl = ControlGroup::Append(*group, ControlNumber::New(*obj,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
    
    ;Y
    ControlGroup::Append(*group, ControlDivot::New(*obj,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*obj,"YLabel","Y",#False,0,*Me\dx+width+20,14,(width-20)*0.25,21 ))
    *yCtl = ControlGroup::Append(*group,ControlNumber::New(*obj,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )
    
    ;Z
    ControlGroup::Append(*group, ControlDivot::New(*obj,"ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*obj,"ZLabel","Z",#False,0,*Me\dx+2*width+20,14,(width-20)*0.25,21 ))
    *zCtl = ControlGroup::Append(*group, ControlNumber::New(*obj,"ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )
    
    ;Angle
    ControlGroup::Append(*group, ControlDivot::New(*obj,"AngleDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*obj,"AngleLabel","Angle",#False,0,*Me\dx+2*width+20,14,(width-20)*0.25,21 ))
    *aCtl = ControlGroup::Append(*group, ControlNumber::New(*obj,"AngleNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
  
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    ;---------------------------------
    ; ---[ Add Parameter ]--------------------------------------------
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
  
    Else
      Append(*Me,*group)
    EndIf
    
    ; Connect Signals
    ;---------------------------------
    ; ---[ Connect Signal ]-------------------------------------------
    If *obj
      Object::SignalConnect(*obj,*xCtl\slot,0)
      Object::SignalConnect(*obj,*yCtl\slot,1)
      Object::SignalConnect(*obj,*zCtl\slot,2)
      Object::SignalConnect(*obj,*aCtl\slot,3)
    EndIf
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + *group\sizY
    
    ProcedureReturn(#True)
  
  EndProcedure

  ; ---[ Add Matrix4 Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddMatrix4Control(*Me.ControlProperty_t,name.s,label.s,*value.m4f32,*obj.Object::Object_t)
    ; Sanity Check
    ;------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
        
    ; Create Group
    ;------------------------------
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *obj,name, name,*Me\gadgetID, *Me\dx, *Me\dy, width*4, 200 ,options)
    
    ; Add Row Parameters
    ;------------------------------
    ControlGroup::AppendStart(*group)
    Protected i
    For i=0 To 3
    
      ControlGroup::RowStart(*group)
    
      Protected w= *Me\sizX/4
      ;Mi0
      ControlGroup::Append(*group,ControlDivot::New(*obj,"M"+Str(i)+"0Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*obj,"M"+Str(i)+"0Label","M"+Str(i)+"0",#False,0,*Me\dx+20,14,(width-20)*0.25,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*obj,"M"+Str(i)+"0Number",*value\v[i*4],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
      
      ;Mi1
      ControlGroup::Append(*group, ControlDivot::New(*obj,"M"+Str(i)+"1Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
      ControlGroup::Append(*group,ControlLabel::New(*obj,"M"+Str(i)+"1Label","M"+Str(i)+"1",#False,0,*Me\dx+width+20,14,(width-20)*0.25,21 ))
      ControlGroup::Append(*group,ControlNumber::New(*obj,"M"+Str(i)+"1Number",*value\v[i*4+1],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )
      
      ;Mi2
      ControlGroup::Append(*group, ControlDivot::New(*obj,"M"+Str(i)+"2Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*obj,"M"+Str(i)+"2Label","M"+Str(i)+"2",#False,0,*Me\dx+2*width+20,14,(width-20)*0.25,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*obj,"M"+Str(i)+"2Number",*value\v[i*4+2],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )
      
      ;Mi3
      ControlGroup::Append(*group, ControlDivot::New(*obj,"M"+Str(i)+"3Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*obj,"M"+Str(i)+"3Label","M"+Str(i)+"3",#False,0,*Me\dx+2*width+20,14,(width-20)*0.25,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*obj,"M"+Str(i)+"3Number",*value\v[i*4+3],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
    
      ControlGroup::RowEnd(*group)
      *Me\posY +50
    Next
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    ;---------------------------------
    ; ---[ Add Parameter ]--------------------------------------------
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
  
    Else
      Append(*Me,*group)
    EndIf
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + *group\sizY
    ProcedureReturn(#True)
  EndProcedure

  ; ---[ Add Reference Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddReferenceControl( *Me.ControlProperty_t,name.s,value.s,*obj.Object::Object_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*obj, name, name,*Me\gadgetID, *Me\dx, *Me\dy, width, 50 ,options)

    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    ;Append(*Me, newControl::IControlLabel(name+"Label",label,#False,0,*Me\dx,*Me\dy,(width-20)*0.25,21 ))
    *Ctl = ControlEdit::New(*obj,name+"_Edit",value,5,*Me\dx,*Me\dy+2,(width-110),18) 
    ControlGroup::Append( *group,*Ctl)
    ;*obj\SignalConnect(Ctl\SignalOnChanged(),0)
  ;   Ctl = ControlGroup::Append(*group, newControl::IControlButton(name+"Pick_Btn","Pick",#False,0,(width-60),*Me\dy,50,21))
  ;   *obj\SignalConnect(Ctl\SignalOnChanged(),1)
  ;   Ctl = ControlGroup::Append(*group, newControl::IControlButton(name+"Explore_Btn","...",#False,0,(width-30),*Me\dy,50,21))
  ;   *obj\SignalConnect(Ctl\SignalOnChanged(),2)
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; Connect Signal
    ;---------------------------------
    If *obj
      Object::SignalConnect(*obj,*Ctl\slot,0)
      If *obj\class\name = "NodePort"
        Protected *port.NodePort::NodePort_t = *obj
        Protected *node.Node::Node_t = *port\node
        Object::SignalConnect(*node,*Ctl\slot,0)
      EndIf
      
    EndIf
    
    ; Add Group to PPG
    ;---------------------------------
    Append(*Me,*group)
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure
  
  ; ---[ Add Reference Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddStringControl( *Me.ControlProperty_t,name.s,value.s,*obj.Object::Object_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*obj, name, name,*Me\gadgetID, *Me\dx, *Me\dy, width, 50 ,options)
   
    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *Ctl = ControlEdit::New(*obj,name+"_Edit",value,5,*Me\dx,*Me\dy+2,(width-110),18) 
    ControlGroup::Append( *group,*Ctl)

    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; Add Group to PPG
    ;---------------------------------
    Append(*Me,*group)
    
    ; Connect Signal
    ;---------------------------------
    If *obj
       Object::SignalConnect(*obj,*Ctl\slot,0)
    EndIf
    
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure

  ; ---[ Add Matrix4 Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddColorControl(*Me.ControlProperty_t,name.s,label.s,*value.c4f32,*obj.Object::Object_t)
  
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*obj, name, name,*Me\gadgetID, *Me\dx, *Me\dy, width, 50 ,options)
    Define *color.ControlColor::ControlColor_t = ControlColor::New(name+"_Color",name+"_Color",*value,*Me\dx,*Me\dy+2,(width-110),18)
    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    ;Append(*Me, newControl::IControlLabel(name+"Label",label,#False,0,*Me\dx,*Me\dy,(width-20)*0.25,21 ))
    ;ControlGroup::Append(*group, ControlEdit::New(*obj,name+"_Edit","",5,*Me\dx,*Me\dy+2,(width-110),18) )
    ControlGroup::Append(*group, *color)
  ;   *obj\SignalConnect(Ctl\SignalOnChanged(),0)
  ;   Ctl = ControlGroup::Append(*group, newControl::IControlButton(name+"Pick_Btn","Pick",#False,0,(width-60),*Me\dy,50,21))
  ;   *obj\SignalConnect(Ctl\SignalOnChanged(),1)
  ;   Ctl = ControlGroup::Append(*group, newControl::IControlButton(name+"Explore_Btn","...",#False,0,(width-30),*Me\dy,50,21))
  ;   *obj\SignalConnect(Ctl\SignalOnChanged(),2)
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; Add Group to PPG
    ;---------------------------------
;      AddElement(*Me\groups())
;     *Me\groups() = *group
    Append(*Me,*group)
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + *group\sizY 
    ProcedureReturn(*color)
  EndProcedure

  
  ; ---[ Add Group Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddGroup( *Me.ControlProperty_t,name.s)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*obj, name, name,*Me\gadgetID, *Me\dx, *Me\dy, width, 50 ,options)
    
    AddElement(*Me\groups())
    *Me\groups() = *group
    Append(*Me,*group)
   
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
  
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + 20
    ProcedureReturn(*group)
  EndProcedure

  Procedure EndGroup( *Me.ControlProperty_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ; Retrieve currently open group
    Protected *group.ControlGroup::ControlGroup_t = *Me\groups()
    If Not *group : ProcedureReturn : EndIf
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + *group\sizY-20
   
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStop(*group)
    DeleteElement(*Me\groups())
   
    ProcedureReturn(#Null)
  EndProcedure
  
  ; ---[ Add Head Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddHead( *Me.ControlProperty_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *head.ControlHead::ControlHead_t
    *Me\dy = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    *head = ControlHead::New(*Me,*Me\name+"_Head",options,*Me\dx,*Me\dy+2,width,18) 
    Append(*Me,*head)
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\head = *head
    ProcedureReturn(*head)
  EndProcedure
  
  ; ---[ Get Width ]-----------------------------------------------
  ;---------------------------------------
  Procedure GetWidth( *Me.ControlProperty_t)
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ProcedureReturn(*Me\sizX)
  EndProcedure
  
  ; ---[ Get Height ]-----------------------------------------------
  ;---------------------------------------
  Procedure GetHeight( *Me.ControlProperty_t)
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected *son.Control::Control_t
    *Me\sizY = 0
    If *Me\expanded
      For i=0 To *Me\chilcount-1
      
        *son = *Me\children(i)
        If (*son\posY+*son\sizY) > *Me\sizY
          *Me\sizY = *son\posY+*son\sizY
        EndIf
      Next
    Else
      *Me\sizY = ControlHead::#HEAD_HEIGHT
    EndIf
    
    ProcedureReturn *Me\sizY
  EndProcedure

  
  ; ---[ On Init ]-----------------------------------------------
  ;---------------------------------------
  Procedure Init( *Me.ControlProperty_t)
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
  
    ; ---[ Add Parameter ]--------------------------------------------
    
    ; ---[ Draw Pick Image ]------------------------------------------
    DrawPickImage(*Me)
    Draw(*Me)
    
    ProcedureReturn(#True)
  EndProcedure

  ; ---[ Refresh ]-----------------------------------------------
  ;---------------------------------------
  Procedure Refresh( *Me.ControlProperty_t)
    
    ; ---[ Sanity Check ]--------------
    If Not *Me : ProcedureReturn : EndIf
    
    
    ProcedureReturn(#True)
  EndProcedure
  
  ; ---[ Send Event To Filtered Child ]-----------------------------------------------
  ;---------------------------------------
  Procedure EventWithFilter(*Me.ControlProperty_t,filter.i,ev_type.i)
    Protected *son.Control::IControl
    Protected i
    For i=0 To *Me\chilcount-1
      *son = *Me\children(i)
      *son\OnEvent(ev_type,#Null)
    Next i
    
  ;   ForEach *Me\groups()
  ;   
  ;     If filter = *Me\groups()\GetGadgetID() : *Me\groups()\Event( ev_type ) : EndIf
  ;   Next
  EndProcedure
  

  ; ----------------------------------------------------------------------------
  ;  ON MESSAGE
  ; ----------------------------------------------------------------------------
  Procedure OnMessage( id.i, *up)
    Protected *sig.Signal::Signal_t = *up
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  DESTRUCTOR
  ; ----------------------------------------------------------------------------
  Procedure Delete( *Me.ControlProperty_t )
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    Protected c
    Protected ictl.Control::IControl
    For c=0 To *Me\chilcount-1
      ictl = *Me\children(c)
      ictl\Delete()
    Next
    FreeGadget(*Me\gadgetID)
    If IsImage(*Me\imageID) 
      FreeImage(*Me\imageID)
    EndIf
    If IsImage(*Me\pickID)
      FreeImage(*Me\pickID)
    EndIf
    
    ClearStructure(*Me, ControlProperty_t)
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get Num Control In Row
  ; ----------------------------------------------------------------------------
  Procedure GetNumControlInRow(*Me.ControlProperty_t, base.i)
    Protected index = base
    Protected search.b = #True
    While search
      If  Not *Me\rowflags(index) : search = #False : EndIf
      index+1
    Wend
    ProcedureReturn index - base
  EndProcedure
  

  ; ============================================================================
  ;  OVERRIDE ( Control::IControl )
  ; ============================================================================
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlProperty_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )  
    
    Protected *c.Control::IControl = *Me\children(*Me\current)
    ; ---[ Local Variables ]----------------------------------------------------
    Protected  ev_data.Control::EventTypeDatas_t
    Protected *son.Control::Control_t
    Protected  son.Control::IControl
    Protected idx,xm,ym
    Protected *overchild.Control::Control_t
    Protected overchild.Control::IControl
    
    *Me\pickID = Pick(*Me)
    If *Me\pickID > -1 And *Me\pickID < *Me\chilcount 
      *overchild = *Me\children(*Me\pickID)
      overchild = *overchild
    EndIf

    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      CompilerIf #PB_Compiler_Version < 560
        Case Control::#PB_EventType_Resize
      CompilerElse
        Case #PB_EventType_Resize
      CompilerEndIf
        *Me\posX = *ev_data\x
        *Me\posY = *ev_data\y
        *Me\sizX = *ev_data\width

        ResizeGadget(*Me\gadgetID,*ev_data\x,*ev_data\y,*Me\sizX,*Me\sizY)
 
        ev_data\x = 0
        ev_data\y = 0
        ev_data\width = *ev_data\width
        ev_data\height = #PB_Ignore

        Protected nbc_row.i
        Protected idr.i = 0
        Protected wi.i
        
        ; Resize Controls
        For c=0 To *Me\chilcount - 1
          If *Me\rowflags(c) 
            nbc_row = GetNumControlInRow(*Me, c)
            walk = #True
            wi = *Me\sizX / nbc_row
            For d=0 To nbc_row -1
              son = *Me\children(c+d)
              *son = son
              ev_data\width = wi
              ev_data\x     = *Me\posX + wi * d
              ev_data\y     = *son\posY
              CompilerIf #PB_Compiler_Version <560
                son\OnEvent(Control::#PB_EventType_Resize, @ev_data)
              CompilerElse
                son\OnEvent(#PB_EventType_Resize, @ev_data)
              CompilerEndIf
              If Not *Me\rowflags(c) : walk = #False : EndIf
            Next
            c + nbc_row - 1
          Else
            son = *Me\children(c)
            *son = son
            ev_data\width = *ev_data\width
            ev_data\x     = *son\posX
            ev_data\y     = *son\posY
            CompilerIf #PB_Compiler_Version <560
              son\OnEvent(Control::#PB_EventType_Resize, @ev_data)
            CompilerElse
              son\OnEvent(#PB_EventType_Resize, @ev_data)
            CompilerEndIf
          EndIf
        Next
        
        ; Resize Groups
        For c=0 To *Me\chilcount-1
          son = *Me\children(c)
          *son = son
          If *son\type = Control::#CONTROL_GROUP
            ev_data\x    = *son\posX
            ev_data\y    = *son\posY
            CompilerIf #PB_Compiler_Version <560
              son\OnEvent(Control::#PB_EventType_Resize, @ev_data)
            CompilerElse
              son\OnEvent(#PB_EventType_Resize, @ev_data)
            CompilerEndIf
          EndIf
        Next
        
        Draw( *Me )
        DrawPickImage(*Me)
        

        ProcedureReturn( #True )
          
      ; ------------------------------------------------------------------------
      ;  DrawChild
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_DrawChild
        *son.Control::Control_t = *ev_data
        son.Control::IControl    = *son
        ev_data\xoff    = *son\posX
        ev_data\yoff    = *son\posY
        StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
        AddPathBox( *son\posX, *son\posY, *son\sizX, *son\sizY)
        VectorSourceColor(UIColor::COLORA_MAIN_BG )
        FillPath()
        son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
        StopVectorDrawing()
  
      ; ------------------------------------------------------------------------
      ;  Focus
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Focus
        If *Me\overchild
          If *Me\overchild <> *overchild
            *Me\overchild\OnEvent(#PB_EventType_LostFocus)
            *Me\overchild = *overchild
            If *Me\overchild
              *Me\overchild\OnEvent(#PB_EventType_Focus)
            EndIf
          EndIf
        Else
          If *overchild
            *Me\overchild = *overchild
            *Me\overchild\OnEvent(#PB_EventType_Focus)
          EndIf
        EndIf

      ; ------------------------------------------------------------------------
      ;  ChildFocused
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_ChildFocused
        *Me\focuschild = *ev_data
        
      ; ------------------------------------------------------------------------
      ;  ChildDeFocused
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_ChildDeFocused
        *Me\focuschild = #Null
        
      ; ------------------------------------------------------------------------
      ;  ChildCursor
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_ChildCursor
        SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, *ev_data )
        
      ; ------------------------------------------------------------------------
      ;  LostFocus
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LostFocus
        If *Me\focuschild
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          *Me\focuschild = #Null
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseMove
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseMove
        xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX )
        ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY )
        
        xm = Min( Max( xm, 0 ), *Me\sizX - 1 )
        ym = Min( Max( ym, 0 ), *Me\sizY - 1 )
        
        If *Me\overchild
          If *Me\overchild <> *overchild
            *Me\overchild\OnEvent(#PB_EventType_MouseLeave)
            *Me\overchild = *overchild
            If *Me\overchild
              *Me\overchild\OnEvent(#PB_EventType_MouseEnter)
            EndIf
          Else
            *Me\overchild\OnEvent(#PB_EventType_MouseMove)
          EndIf
        ElseIf *overchild
          *Me\overchild = *overchild
          *Me\overchild\OnEvent(#PB_EventType_MouseEnter)
        EndIf
        
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonDown
      ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonDown
      *Me\down = #True
      If *overchild
        If *Me\focuschild 
          If *overchild <> *Me\focuschild
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          EndIf
          *Me\focuschild = *overchild
          *Me\focuschild\OnEvent( #PB_EventType_Focus, #Null )
        EndIf
        
        ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX )
        ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY )
        ev_data\xoff = *overchild\posX
        ev_data\yoff = *overchild\posY
        *Me\overchild\OnEvent(#PB_EventType_LeftButtonDown,@ev_data)

      ElseIf *Me\focuschild
        *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
      EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonUp
      ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
        *overchild.Control::Control_t = *Me\overchild
        If *overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_LeftButtonUp,@ev_data)
        EndIf
      
        *Me\down = #False
        
      ; ------------------------------------------------------------------------
      ;  LeftDoubleClick
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftDoubleClick
        *overchild.Control::Control_t = *Me\overchild
        If *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_LeftDoubleClick,@ev_data)
          *Me\focuschild = *Me\overchild
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  RightButtonDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_RightButtonDown
        *Me\down = #True
        *overchild.Control::Control_t = *Me\overchild
        If *Me\overchild
          If *Me\focuschild And ( *Me\overchild <> *Me\focuschild )
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          EndIf
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonDown,@ev_data)
        ElseIf *Me\focuschild
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  RightButtonUp
      ; ------------------------------------------------------------------------
      Case #PB_EventType_RightButtonUp
        
        If *Me\overchild
          *overchild.Control::Control_t = *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
        EndIf
        *Me\down = #False
      
      ; ------------------------------------------------------------------------
      ;  RightButtonUp
      ; ------------------------------------------------------------------------
      Case #PB_EventType_RightButtonUp
        If *Me\overchild
          *overchild.Control::Control_t = *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  Input
      ; ------------------------------------------------------------------------
    Case #PB_EventType_Input
        ; Do We Have A Focused Child
        If *Me\focuschild
          ; Retrieve Character
          ev_data\input = Chr(GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Input))
          ; Send Character To Focused Child
          *Me\focuschild\OnEvent(#PB_EventType_Input,@ev_data)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  KeyDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_KeyDown
        ; Do We Have A Focused Child
        If *Me\focuschild
          ; Retrieve Key 
          ev_data\key   = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key      )
          ev_data\modif = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)
          
          ; Send Key To Focused Child
          *Me\focuschild\OnEvent(#PB_EventType_KeyDown,@ev_data)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_COPY
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_COPY
        ; Do We Have A Focused Child
        If *Me\focuschild
          MessageRequester("COPY", "Copy")
          ; Send Key To Focused Child
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_COPY,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_CUT
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_CUT
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_CUT,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_PASTE
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_PASTE
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_PASTE,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_UNDO
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_UNDO
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_UNDO,#Null)
        EndIf
        
  ;       ; ------------------------------------------------------------------------
  ;       ;  SHORTCUT_NEXT
  ;       ; ------------------------------------------------------------------------
  ;       Case Globals::#SHORTCUT_NEXT
  ;         ; ---[ Do We Have A Focused Child ? ]-------------------------------------
  ;         If *Me\focuschild
  ;           ; ---[ Go To Next Item ]------------------------------------------------
  ;           OControlGroup_hlpNextItem( *Me ) 
  ;         EndIf
  ;         
  ;       ;------------------------------------------------------------------------
  ;       ; SHORTCUT_PREVIOUS
  ;       ;------------------------------------------------------------------------
  ;       Case Globals::#SHORTCUT_PREVIOUS
  ;           Debug "Previous Item called"
  ;           ; ---[ Do We Have A Focused Child ? ]-----------------------------------
  ;           If *Me\focuschild
  ;             ; go to previous child
  ;             Debug "previous child per favor..."
  ;           EndIf
                 
               
        
      ;Case #PB_EventType_KeyUp
      ;Case #PB_EventType_MiddleButtonDown
      ;Case #PB_EventType_MiddleButtonUp
      ;Case #PB_EventType_MouseWheel
      ;Case #PB_EventType_PopupMenu
      ;Debug ">> PopupMenu"
      ;Case #PB_EventType_PopupWindow
      ;Debug ">> PopupWindow"
        
    EndSelect
  
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn( #False )
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Test
  ; ----------------------------------------------------------------------------
  Procedure Test(*prop.ControlProperty_t,*mesh.Polymesh::Polymesh_t)
   
    AppendStart(*prop)
    AddBoolControl(*prop,"boolean","boolean",#False,*mesh)
    AddFloatControl(*prop,"float","float",#False,*mesh)
    AddIntegerControl(*prop,"integer","integer",#False,*mesh)
    AddReferenceControl(*prop,"reference1","ref1",*mesh)
    AddReferenceControl(*prop,"reference2","ref2",*mesh)
    AddReferenceControl(*prop,"reference3","ref3",*mesh)
    *group = AddGroup(*prop,"BUTTON")
    
    ControlGroup::Append(*group,ControlButton::New(*mesh,"button","button",#True,#PB_Button_Toggle))
    EndGroup(*prop)
    
    
    
    Define q.Math::q4f32
    Quaternion::SetIdentity(q)
    AddQuaternionControl(*prop,"quaternion","quat",@q,*mesh)
    
    *group = AddGroup(*prop,"ICONS")
    ControlGroup::RowStart(*group)
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Back",ControlIcon::#Icon_Back,0))
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Stop",ControlIcon::#Icon_Stop,0))
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Play",ControlIcon::#Icon_Play,#PB_Button_Toggle))
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Loop",ControlIcon::#Icon_Loop,0))
    ControlGroup::RowEnd(*group)
    EndGroup(*prop)
        
    AppendStop(*prop)
  EndProcedure


  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New( *object.Object::Object_t, name.s, label.s,x.i=0,y.i=0,width.i=320,height.i=120 ,decoration = #PROPERTY_LABELED)
    
    ; Allocate Object Memory
    Protected *Me.ControlProperty_t = AllocateMemory( SizeOf(ControlProperty_t) )
    
    Object::INI(ControlProperty)
    *Me\object = *object
    
    ; Init Members
    *Me\type       = #PB_GadgetType_Container
    *Me\decoration = decoration
    *Me\name       = name
    *Me\gadgetID   = CanvasGadget(#PB_Any,x,y,width,height,#PB_Canvas_Keyboard)
    *Me\imageID    = CreateImage(#PB_Any,width,height)
    *Me\pickID     = CreateImage(#PB_Any,width,height)
    SetGadgetColor(*Me\gadgetID,#PB_Gadget_BackColor,UIColor::COLOR_MAIN_BG )
  
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\label      = label
    *Me\visible    = #True
    *Me\enable     = #True
    *Me\head       = #Null
    *Me\expanded   = #True
  
    ; Init Structure
    InitializeStructure( *Me, ControlProperty_t ) ; List
    DrawEmpty(*Me)
   
    ; Return Initialized Object
    ProcedureReturn( *Me )
    
  EndProcedure
  
  Class::DEF(ControlProperty)
EndModule


; ============================================================================
;  EOF
; ============================================================================

      
      
    
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 1149
; FirstLine = 1137
; Folding = --------
; EnableXP
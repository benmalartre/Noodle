XIncludeFile "Object.pbi"
XIncludeFile "UIColor.pbi"

;===============================================================================
; TRANSFORM 2D MODULE DECLARATION
;===============================================================================
DeclareModule Transform2D
  ; ------------------------------------------------------------------
  ;   DIRTY STATES
  ; ------------------------------------------------------------------
  Enumeration
    #DIRTY_CLEAN
    #DIRTY_SRT
    #DIRTY_MATRIX
  EndEnumeration
  
  ; ------------------------------------------------------------------
  ;   STRUCTURES
  ; ------------------------------------------------------------------
  Structure Vector_t
    x.f
    y.f
    z.f
  EndStructure
  
  Structure Matrix_t
    m00.f
    m01.f
    m02.f
    m10.f
    m11.f
    m12.f
    m20.f
    m21.f
    m22.f
  EndStructure
  
  Structure Transform_t
    localT.Matrix_t
    globalT.Matrix_t
    scale.Vector_t
    rotate.f
    translate.Vector_t
    skew.Vector_t
    dirty.b
  EndStructure
  
  ; ------------------------------------------------------------------
  ;   DECLARE
  ; ------------------------------------------------------------------
  Declare.b Inverse(*m.Matrix_t, *o.Matrix_t)
  Declare.b InverseInPlace(*m.Matrix_t)
  Declare Transform(*p.Vector_t, *o.Vector_t, *m.Matrix_t)
  Declare TransformInPlace(*p.Vector_t, *m.Matrix_t)
  Declare Initialize(*t.Transform_t)
  Declare Compute(*t.Transform_t, *p.Transform_t=#Null)
  Declare MatrixToSRT(*m.Matrix_t, *t.Transform_t)
  Declare SRTToMatrix(*t.Transform_t, *m.Matrix_t)
  
  ; ------------------------------------------------------------------
  ;   INDENTITY MATRIX
  ; ------------------------------------------------------------------
  Macro IDENTITIZE(_M)
    _M\m00 = 1 : _M\m01 = 0 : _M\m02 = 0
    _M\m10 = 0 : _M\m11 = 1 : _M\m12 = 0
    _M\m20 = 0 : _M\m21 = 0 : _M\m22 = 1
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   SCALING MATRIX
  ; ------------------------------------------------------------------
  Macro SCALING(_M, _x, _y)
    Transform2D::IDENTITIZE(_M)
    _M\m00 = _x
    _M\m11 = _y
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   ROTATION MATRIX
  ; ------------------------------------------------------------------
  Macro ROTATION(_M, _angle)
    Transform2D::IDENTITIZE(_M)
    _M\m00 = Cos(Radian(_angle))
    _M\m01 = -Sin(Radian(_angle))
    _M\m10 = Sin(Radian(_angle))
    _M\m11 = Cos(Radian(_angle))
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   TRANSLATION MATRIX
  ; ------------------------------------------------------------------
  Macro TRANSLATION(_M, _x, _y)
    Transform2D::IDENTITIZE(_M)
    _M\m02 = _x
    _M\m12 = _y
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   SCALE
  ; ------------------------------------------------------------------
  Macro SCALE(_T, _x, _y)
    _T\scale\x + _x
    _T\scale\y + _y
    _T\dirty = Transform2D::#DIRTY_SRT
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   ROTATE
  ; ------------------------------------------------------------------
  Macro ROTATE(_T, _a)
    _T\rotate + _a
    _T\dirty = Transform2D::#DIRTY_SRT
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   TRANSLATE
  ; ------------------------------------------------------------------
  Macro TRANSLATE(_T, _x, _y)
    _T\translate\x + _x
    _T\translate\y + _y
    _T\dirty = Transform2D::#DIRTY_SRT
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   USEFUL MATRICES
  ; ------------------------------------------------------------------
  Global IDENTITY.Matrix_t
  IDENTITIZE(IDENTITY)
  
  Global FLIPX.Matrix_t
  IDENTITIZE(FLIPX)
  FLIPX\m00 = -1
  
  Global FLIPY.Matrix_t
  IDENTITIZE(FLIPY)
  FLIPY\m11 = -1
  
  Global FLIPXY.Matrix_t
  IDENTITIZE(FLIPXY)
  FLIPXY\m00 = -1
  FLIPXY\m11 = -1
  
  ; ------------------------------------------------------------------
  ;   MULTIPLY MATRIX IN PLACE
  ; ------------------------------------------------------------------
  Macro MultiplyInPlace(_m,_o)
    Define _tmp_m3.Transform2D::Matrix_t
    _tmp_m3\m00 = _m\m00 * _o\m00 + _m\m01 * _o\m10 + _m\m02 * _o\m20
    _tmp_m3\m01 = _m\m00 * _o\m01 + _m\m01 * _o\m11 + _m\m02 * _o\m21
    _tmp_m3\m02 = _m\m00 * _o\m02 + _m\m01 * _o\m12 + _m\m02 * _o\m22
    
    _tmp_m3\m10 = _m\m10 * _o\m00 + _m\m11 * _o\m10 + _m\m12 * _o\m20
    _tmp_m3\m11 = _m\m10 * _o\m01 + _m\m11 * _o\m11 + _m\m12 * _o\m21
    _tmp_m3\m12 = _m\m10 * _o\m02 + _m\m11 * _o\m12 + _m\m12 * _o\m22
    
    _tmp_m3\m20 = _m\m20 * _o\m00 + _m\m21 * _o\m10 + _m\m22 * _o\m20
    _tmp_m3\m21 = _m\m20 * _o\m01 + _m\m21 * _o\m11 + _m\m22 * _o\m21
    _tmp_m3\m22 = _m\m20 * _o\m02 + _m\m21 * _o\m12 + _m\m22 * _o\m22
    
    CopyMemory(_m, _tmp_m3, SizeOf(Transform2D::Matrix_t))

  EndMacro
  
  ; ------------------------------------------------------------------
  ;   MULTIPLY MATRIX
  ; ------------------------------------------------------------------
  Macro Multiply(_m,_f,_s)
    _m\m00 = _f\m00 * _s\m00 + _f\m01 * _s\m10 + _f\m02 * _s\m20
    _m\m01 = _f\m00 * _s\m01 + _f\m01 * _s\m11 + _f\m02 * _s\m21
    _m\m02 = _f\m00 * _s\m02 + _f\m01 * _s\m12 + _f\m02 * _s\m22
    
    _m\m10 = _f\m10 * _s\m00 + _f\m11 * _s\m10 + _f\m12 * _s\m20
    _m\m11 = _f\m10 * _s\m01 + _f\m11 * _s\m11 + _f\m12 * _s\m21
    _m\m12 = _f\m10 * _s\m02 + _f\m11 * _s\m12 + _f\m12 * _s\m22
    
    _m\m20 = _f\m20 * _s\m00 + _f\m21 * _s\m10 + _f\m22 * _s\m20
    _m\m21 = _f\m20 * _s\m01 + _f\m21 * _s\m11 + _f\m22 * _s\m21
    _m\m22 = _f\m20 * _s\m02 + _f\m21 * _s\m12 + _f\m22 * _s\m22
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   TRANSFORM POINT X
  ; ------------------------------------------------------------------
  Macro TransformPointX(_p, _M)
    (_p\x * _M\m00 + _p\y * _M\m01 + _p\z * _M\m02)
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   TRANSFORM POINT Y
  ; ------------------------------------------------------------------
  Macro TransformPointY(_p, _M) 
    (_p\x * _M\m10 + _p\y * _M\m11 + _p\z * _M\m12)
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   ECHO MATRIX ( DEBUG ONLY )
  ; ------------------------------------------------------------------
  Macro ECHO(_M)
    Debug "["+StrF(_M\m00, 3)+", "+StrF(_M\m01, 3)+", "+StrF(_M\m02, 3)+"]"
    Debug "["+StrF(_M\m10, 3)+", "+StrF(_M\m11, 3)+", "+StrF(_M\m12, 3)+"]"
    Debug "["+StrF(_M\m20, 3)+", "+StrF(_M\m21, 3)+", "+StrF(_M\m22, 3)+"]"
  EndMacro
  
  
EndDeclareModule


; ===============================================================================
;   TRANSFORM 2D MODULE IMPLEMENTATION
; ===============================================================================
Module Transform2D
  ; -----------------------------------------------------------------------------
  ;   INVERSE MATRIX
  ; -----------------------------------------------------------------------------
  Procedure.b Inverse(*m.Matrix_t, *o.Matrix_t)

    Define det.f = 0
    det + *o\m00 * (*o\m11 * *o\m22 - *o\m12 * *o\m21)
    det + *o\m01 * (*o\m12 * *o\m20 - *o\m10 * *o\m22)
    det + *o\m02 * (*o\m10 * *o\m21 - *o\m11 * *o\m20)
    
    If det <> 0
      Define invdet.f = 1 / det
      *m\m00 = (*o\m11 * *o\m22 - *o\m12 * *o\m21) * invdet
      *m\m01 = (*o\m21 * *o\m02 - *o\m22 * *o\m01) * invdet
      *m\m02 = (*o\m01 * *o\m12 - *o\m02 * *o\m11) * invdet
      *m\m10 = (*o\m12 * *o\m20 - *o\m10 * *o\m22) * invdet
      *m\m11 = (*o\m22 * *o\m00 - *o\m20 * *o\m02) * invdet
      *m\m12 = (*o\m02 * *o\m10 - *o\m00 * *o\m12) * invdet
      *m\m20 = (*o\m10 * *o\m21 - *o\m11 * *o\m20) * invdet
      *m\m21 = (*o\m20 * *o\m01 - *o\m21 * *o\m00) * invdet
      *m\m22 = (*o\m00 * *o\m11 - *o\m01 * *o\m10) * invdet
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
   
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   INVERSE MATRIX IN PLACE
  ; -----------------------------------------------------------------------------
  Procedure.b InverseInPlace(*m.Matrix_t)
    Define tmp.Matrix_t
    If Inverse(tmp, *m)
      CopyMemory(tmp, *m, SizeOf(Matrix_t))
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   TRANSFORM POINT
  ; -----------------------------------------------------------------------------
  Procedure Transform(*p.Vector_t, *o.Vector_t, *m.Matrix_t)
    *p\x = *o\x * *m\m00 + *o\y * *m\m01 + *o\z * *m\m02
    *p\y = *o\x * *m\m10 + *o\y * *m\m11 + *o\z * *m\m12
    *p\z = *o\x * *m\m20 + *o\y * *m\m21 + *o\z * *m\m22
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   TRANSFORM POINT IN PLACE
  ; -----------------------------------------------------------------------------
  Procedure TransformInPlace(*p.Vector_t, *m.Matrix_t)
    Define x.f, y.f, z.f
    x = *p\x * *m\m00 + *p\y * *m\m01 + *p\z * *m\m02
    y = *p\x * *m\m10 + *p\y * *m\m11 + *p\z * *m\m12
    z = *p\x * *m\m20 + *p\y * *m\m21 + *p\z * *m\m22
    *p\x = x
    *p\y = y
    *p\z = z
  EndProcedure

  ; -----------------------------------------------------------------------------
  ;   INITIALIZE TRANSFORM
  ; -----------------------------------------------------------------------------
  Procedure Initialize(*t.Transform_t)
    IDENTITIZE(*t\localT)
    IDENTITIZE(*t\globalT)
    *t\scale\x = 1
    *t\scale\y = 1
    *t\rotate = 0
    *t\translate\x = 0
    *t\translate\y = 0
    *t\skew\x = 0
    *t\skew\y = 0
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   COMPUTE
  ; -----------------------------------------------------------------------------
  Procedure Compute(*t.Transform_t, *p.Transform_t=#Null)
    If *t\dirty = #DIRTY_SRT
      Define.Matrix_t S, R, T
      SCALING(S, *t\scale\x, *t\scale\y)
      ROTATION(R, *t\rotate)
      TRANSLATION(T, *t\translate\x, *t\translate\y)
      Multiply(*t\localT, S, R)
      MultiplyInPlace(*t\localT, T)
    ElseIf *t\dirty = #DIRTY_MATRIX
      *t\scale\x = Sqr(Pow(*t\localT\m00, 2) + Pow(*t\localT\m01, 2));(M11 * M11 + M12 * M12)
      *t\scale\y = Sqr(Pow(*t\localT\m10, 2) + Pow(*t\localT\m11, 2))
      
      *t\translate\x = *t\localT\m02
      *t\translate\y = *t\localT\m12
    EndIf
    
    If *p
      Multiply(*t\globalT, *t\localT, *p\globalT)
    Else
      CopyMemory(*t\localT, *t\globalT, SizeOf(Matrix_t))  
    EndIf
      
    *t\dirty = #DIRTY_CLEAN
  EndProcedure

EndModule

; ===============================================================================
;   Vector Module Declaration
; ===============================================================================
DeclareModule Vector
  Enumeration
    #ATOM_COMPOUND
    #ATOM_POINT
    #ATOM_LINE
    #ATOM_BEZIER
    #ATOM_BOX
    #ATOM_CIRCLE
    #ATOM_ELLIPSE
    #ATOM_TEXT
    #ATOM_IMAGE
    #ATOM_PDF
    #ATOM_ITEM
    
  EndEnumeration
  
  Enumeration
    #STROKE_DEFAULT
    #STROKE_DOT
    #STROKE_DASH
    #STROKE_CUSTOM
  EndEnumeration
  
  #STATE_NONE      = 0
  #STATE_OVER      = 1
  #STATE_ACTIVE    = 2
  #STATE_EDIT      = 3
  #STATE_LOCKED    = 4
  #STATE_CONNECTED = 5
  
  Global Dim stroke_types.Globals::KeyValue_t(4)
  stroke_types(0)\key = "Default"
  stroke_types(0)\value = #STROKE_DEFAULT
  stroke_types(1)\key = "Dot"
  stroke_types(1)\value = #STROKE_DOT
  stroke_types(2)\key = "Dash"
  stroke_types(2)\value = #STROKE_DASH
  stroke_types(3)\key = "Custom"
  stroke_types(3)\value = #STROKE_CUSTOM
     
  Global Dim stroke_corners.Globals::KeyValue_t(2)
  stroke_corners(0)\key = "Default"
  stroke_corners(0)\value = #PB_Path_Default
  stroke_corners(1)\key = "RoundCorner"
  stroke_corners(1)\value = #PB_Path_RoundCorner
  
  Global Dim stroke_ends.Globals::KeyValue_t(2)
  stroke_ends(0)\key = "RoundEnd"
  stroke_ends(0)\value = #PB_Path_RoundEnd
  stroke_ends(1)\key = "SquareEnd"
  stroke_ends(1)\value = #PB_Path_SquareEnd
  
  Structure Atom_t Extends Object::Object_t
    id.i
    type.a
    state.a
    *parent.Atom_t
  EndStructure
  
  Structure Point_t Extends Atom_t
    x.f
    y.f
  EndStructure
  
  Structure BezierPoint_t Extends Atom_t
    position.Point_t
    in_tangent.Point_t
    out_tangent.Point_t
  EndStructure
  
  Structure Item_t Extends Atom_t
    stroked.b
    stroke_type.i
    stroke_style.i
    stroke_width.f
    stroke_color.i
    fill_color.i
    filled.b
    segments.s
    edit.b
    name.s
    bbox.Geometry::Box_t
    T.Transform2D::Transform_t
    *over.Atom_t
    *active.Atom_t
    List *childrens.Item_t()
  EndStructure
  
  Structure Compound_t Extends Item_t
    
  EndStructure
  
  
  Structure Line_t Extends Item_t
    List points.Point_t()
    List closed.i()
  EndStructure
  
  Structure Bezier_t Extends Item_t
    List points.BezierPoint_t()
    List closed.i()
  EndStructure
  
  Structure Box_t Extends Item_t
    halfsize.Point_t
  EndStructure
  
  Structure Circle_t Extends Item_t
    radius.f
    closed.b
    start_angle.f
    end_angle.f
  EndStructure 
  
  Structure Ellipse_t Extends Item_t
    halfsize.Point_t
    closed.b
    start_angle.f
    end_angle.f
  EndStructure 
  
  Structure Text_t Extends Item_t
    font_size.f
    font.i
    text.s
  EndStructure
  
  Structure Image_t Extends Item_t
    filename.s
    img.i
    width.f
    height.f
    alpha.a
  EndStructure
  
  DataSection
    CompoundVT:
    PointVT:
    LineVT:
    BezierVT:
    BoxVT:
    CircleVT:
    EllipseVT:
    TextVT:
    ImageVT:
  EndDataSection
  
  Declare NewCompound(*parent.Item_t=#Null)
  Declare NewPoint(*parent.Item_t=#Null)
  Declare NewLine(*parent.Item_t=#Null)
  Declare NewBezier(*parent.Item_t=#Null)
  Declare NewBox(*parent.Item_t=#Null)
  Declare NewCircle(*parent.Item_t=#Null)
  Declare NewEllipse(*parent.Item_t=#Null)
  Declare NewText(font.i, *parent.Item_t=#Null)
  Declare NewImage(img.i, x.f=0, y.f=0, *parent.Item_t=#Null)
  
  Declare NewItem(type.i=#ATOM_LINE, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_width.f=2, color.i=0, filled.b=#False, fill_color.i=0, *parent.Item_t=#Null)
  Declare DeleteItem(*item.Item_t)
  Declare AddAtom(*item.Item_t, *atom.Atom_t)
  Declare RemoveAtom(*item.Item_t, *atom.Atom_t)
  Declare DeleteAtom(*atom.Atom_t)
  Declare WriteToFile(*item.Item_t, filename.s)
  Declare ReadFromFile(*item.Item_t, filename.s)
  
  Declare RoundBoxPath(x.f, y.f, width.f, height.f, radius.f=6)
  Declare MoveCursorPathOnCircle(cx.f, cy.f, radius.f, angle.f)
  
  Declare AddPoint(*item.Item_t)
  Declare AddLine(*item.Item_t)
  Declare AddBezier(*item.Item_t)
  Declare AddBox(*item.Item_t)
  Declare AddCircle(*item.Item_t)
  Declare AddEllipse(*item.Item_t)
  Declare AddText(*item.Item_t, font.i)
  Declare AddImage(*item.Item_t, img.i, x.f=0, y.f=0)
  Declare SetFont(*text.Text_t, font.i, font_size.f)
  
  Declare ComputeBoundingBox(*item.Item_t, init.b=#True)
  Declare DrawBoundingBox(*item.Item_t, color.i, stroked.b=#True, stroke_width=4)
  Declare DrawItem(*item.Item_t)
  Declare DrawLine(*line.Line_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216, expand.i=0)
  Declare DrawPoint(*pnt.Point_t, radius.f, stroke_color.i)
  Declare DrawBox(*box.Box_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216, expand.i=0)
  Declare DrawCircle(*circle.Circle_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216, expand.i=0)
  Declare DrawTextAtom(*text.Text_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216)
  Declare DrawImageAtom(*im.Image_t)
  
  Declare PickItem(*item.Item_t, mx.f, my.f)
  Declare ResetPick(*item.Item_t)
  Declare PickPoint(*pnt.Point_t, mx.f, my.f, radius.f)
  Declare PickLine(*line.Line_t, filled.b, mx.f, my.f, width.f)
  Declare PickBezier(*arc.Bezier_t, filled.b, mx.f, my.f, width.f)
  Declare PickBox(*box.Box_t, filled.b, mx.f, my.f, width.f)
  Declare PickCircle(*circle.Circle_t, filled.b, mx.f, my.f, width.f)
  Declare PickText(*text.Text_t, mx.f, my.f)
  
  Declare SetStyle(*item.Item_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216)
  Declare Lock(*atom.Atom_t)
  Declare Unlock(*atom.Atom_t)
  Declare.b IsLocked(*atom.Atom_t)
  Declare Connect(*atom.Atom_t, *other.Atom_t)
  Declare Disconnect(*atom.Atom_t, *other.Atom_t)
  Declare.b IsConnected(*atom.Atom_t)
  Declare BeginEdit(*atom.Atom_t, x.f, y.f)
  Declare InsertPoint(*atom.Atom_t, x.f, y.f, index.i=-1)
  Declare EndEdit(*atom.Atom_t)
  Declare CloseLine(*line.Line_t)
  Declare CloseBezier(*bezier.Bezier_t)
  
  Declare Translate(*atom.Atom_t, x.f, y.f)
  Declare Rotate(*atom.Atom_t, angle.f)
  Declare Transform(*item.Item_t)
  Declare.b Parent(*item.Item_t, *parent.Item_t)
  Declare AccumulatedTransform(*item.Item_t, *m.Transform2D::Matrix_t)
  Declare InverseTransform(*T.Transform2D::Matrix_t)
  Declare AccumulatedInverseTransform(*item.Item_t, *T.Transform2D::Matrix_t)
  
  Macro SETSTATE(_atom, _bit)
    _atom\state | 1 << _bit  
  EndMacro
  
  Macro CLEARSTATE(_atom, _bit)
    _atom\state & ~ ( 1 << _bit)
  EndMacro
  
  Macro CLEARALLSTATE(_atom)
    _atom\state ! _atom\state
  EndMacro
  
  Macro GETSTATE(_atom, _bit)
    ((_atom\state & ( 1 <<_bit) ) >> _bit)
  EndMacro
  
EndDeclareModule


;===============================================================================
; Vector Module Implementation
;===============================================================================
Module Vector
  
  ; -----------------------------------------------------------------------------
  ;   CONSTRUCTORS
  ; -----------------------------------------------------------------------------
  Procedure NewCompound(*parent.Item_t=#Null)
    Define *Me.Compound_t = AllocateMemory(SizeOf(Compound_t))
    Object::INI(Compound)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_COMPOUND
    Parent(*Me, *parent)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewPoint(*parent.Item_t=#Null)
    Define *Me.Point_t = AllocateMemory(SizeOf(Point_t))
    Object::INI(Point)
    *Me\type = #ATOM_POINT
    Parent(*Me, *parent)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewLine(*parent.Item_t=#Null)
    Define *Me.Line_t  = AllocateMemory(SizeOf(Line_t))
    Object::INI(Line)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_LINE
    Parent(*Me, *parent)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewBezier(*parent.Item_t=#Null)
    Define *Me.Bezier_t  = AllocateMemory(SizeOf(Bezier_t))
    Object::INI(Bezier)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_BEZIER
    Parent(*Me, *parent)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewBox(*parent.Item_t=#Null)
    Define *Me.Box_t = AllocateMemory(SizeOf(Box_t))
    Object::INI(Box)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_BOX
    Parent(*Me, *parent)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewCircle(*parent.Item_t=#Null)
    Define *Me.Circle_t  = AllocateMemory(SizeOf(Circle_t))
    Object::INI(Circle)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_CIRCLE
    Parent(*Me, *parent)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewEllipse(*parent.Item_t=#Null)
    Define *Me.Ellipse_t  = AllocateMemory(SizeOf(Ellipse_t))
    Object::INI(Ellipse)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_ELLIPSE
    Parent(*Me, *parent)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewText(font.i, *parent.Item_t=#Null)
    Define *Me.Text_t  = AllocateMemory(SizeOf(Text_t))
    Object::INI(Text)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_TEXT
    Parent(*Me, *parent)
    *Me\font = font
    *Me\font_size = 6
    *Me\text = "hello"
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewImage(img.i, x.f=0, y.f=0, *parent.Item_t=#Null)
    Define *Me.Image_t  = AllocateMemory(SizeOf(Image_t))
    Object::INI(Image)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_IMAGE
    Parent(*Me, *parent)
    *Me\T\translate\x = x
    *Me\T\translate\y = y
    If IsImage(img)
      *Me\img = img
      *Me\width = ImageWidth(img)
      *Me\height = ImageHeight(img)
    EndIf
    ProcedureReturn *Me
  EndProcedure
  
    
  Procedure NewItem(type.i=#ATOM_LINE, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_width.f=2, stroke_color.i=0, filled.b=#False, fill_color.i=0, *parent.Item_t=#Null)

    Define *item.Item_t = #Null
    Select type
;       Case #ATOM_POINT
;         
;         *item = NewPoint(stroke_type, stroke_style, stroke_width, stroke_color, filled, fill_color, *parent)
;         *item\name = "POINT"
        
      Case #ATOM_LINE
        *item = NewLine(*parent)
        *item\name = "LINE"
        
      Case #ATOM_BEZIER
        *item = NewBezier(*parent)
        *item\name = "BEZIER"
        
      Case #ATOM_BOX
        *item = NewBox(*parent)
        *item\name = "BOX"
        
      Case #ATOM_CIRCLE
        *item = NewCircle(*parent)
        *item\name = "CIRCLE"
        
      Case #ATOM_ELLIPSE
        *item = NewEllipse(*parent)
        *item\name = "ELLIPSE"
        
      Case #ATOM_TEXT
        *item = NewText(0, *parent)
        *item\name = "TEXT"
        
      Case #ATOM_IMAGE
        *item = NewImage(0, 0, 0, *parent)
        *item\name = "IMAGE"
        
      Case #ATOM_COMPOUND
        *item = NewCompound(*parent)
        *item\name = "COMPOUND"
        
      Default
        ProcedureReturn #Null
    
    EndSelect
    
    If *item <> #Null
      
      Transform2D::IDENTITIZE(*item\T\localT)
      Transform2D::IDENTITIZE(*item\T\globalT)
      *item\stroke_type = stroke_type
      *item\stroke_style = stroke_style
      *item\stroked = stroke_style
      *item\stroke_color = stroke_color
      *item\stroke_width = stroke_width
      *item\stroked = #True
      *item\filled = filled
      *item\fill_color = UIColor::FILL  
  
  
      Object::ATTR(*item, stroked, Slot::#SLOT_BOOL)
      Object::ENUM(*item, stroke_type, Vector::stroke_types)
  ;     Object::RADIO(*item, stroke_style, Vector::stroke_styles)
      Object::ATTR(*item, stroke_width, Slot::#SLOT_FLOAT)
      Object::ATTR(*item, stroke_color, Slot::#SLOT_INT)
      Object::ATTR(*item, filled, Slot::#SLOT_BOOL)
      Object::ATTR(*item, fill_color, Slot::#SLOT_INT)
      Object::ATTR(*item, name, Slot::#SLOT_STRING)
      
      Select *item\type
        Case Vector::#ATOM_IMAGE
          Define *img.Image_t = *item
          Define *filename = @*img\filename
          Object::PROXY(*item, "filename", *filename, Slot::#SLOT_STRING)
          Object::PROXY(*item, "width", *img\width, Slot::#SLOT_STRING)
          Object::PROXY(*item, "height", *img\height, Slot::#SLOT_STRING)
          
        Case Vector::#ATOM_TEXT
          Define *txt.Text_t = *item
          Define *content = @*txt\text
          Object::PROXY(*item, "text", *content, Slot::#SLOT_STRING)
          Object::PROXY(*item, "font", *txt\font, Slot::#SLOT_INT)
          Object::PROXY(*item, "font_size", *txt\font_size, Slot::#SLOT_FLOAT)
          Object::PROXY(*item, "font_size", *txt\font_size, Slot::#SLOT_FLOAT)
      
      EndSelect
      
    EndIf
    
    ProcedureReturn *item
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   PARENT ITEM
  ; -----------------------------------------------------------------------------
  Procedure.b Parent(*item.Item_t, *parent.Item_t)
    If *parent <> #Null
      *item\parent = *parent
      AddElement(*parent\childrens())
      *parent\childrens() = *item
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   SET STYLE
  ; -----------------------------------------------------------------------------
  Procedure SetStyle(*item.Item_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216)
    *item\filled = filled
    *item\stroked = stroked
    *item\fill_color = fill_color
    *item\stroke_width = stroke_width
    *item\stroke_type = stroke_type
    *item\stroke_style = stroke_style
    *item\stroke_color = stroke_color
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ITEM DESTRUCTOR
  ; -----------------------------------------------------------------------------
  Procedure DeleteItem(*item.Item_t)
    If *item <> #Null
      ForEach *item\childrens()
        DeleteItem(*item\childrens())
      Next
      
      ClearStructure(*item, Item_t)
      FreeMemory(*item)
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD POINT
  ; -----------------------------------------------------------------------------
  Procedure AddPoint(*item.Item_t)
    AddElement(*item\childrens())
    Define *Me.Point_t = AllocateMemory(SizeOf(Point_t))
    Object::INI(Point)
    *Me\type = #ATOM_POINT
    *Me\parent = *item
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD LINE
  ; -----------------------------------------------------------------------------
  Procedure Addline(*item.Item_t)
    AddElement(*item\childrens() )
    Define *Me.Line_t  = AllocateMemory(SizeOf(Line_t))
    Object::INI(Line)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_LINE
    *Me\parent = *item
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD BEZIER
  ; -----------------------------------------------------------------------------
  Procedure AddBezier(*item.Item_t)
    AddElement(*item\childrens()) 
    Define *Me.Bezier_t  = AllocateMemory(SizeOf(Bezier_t))
    Object::INI(Bezier)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_BEZIER
    *Me\parent = *item
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD BOX
  ; -----------------------------------------------------------------------------
  Procedure AddBox(*item.Item_t)
    AddElement(*item\childrens() )
    Define *Me.Box_t = AllocateMemory(SizeOf(Box_t))
    Object::INI(Box)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_BOX
    *Me\parent = *item
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD CIRCLE
  ; -----------------------------------------------------------------------------
  Procedure AddCircle(*item.Item_t)
    AddElement(*item\childrens() )
    Define *Me.Circle_t  = AllocateMemory(SizeOf(Circle_t))
    Object::INI(Circle)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_CIRCLE
    *Me\parent = *item
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD ELLIPSE
  ; -----------------------------------------------------------------------------
  Procedure AddEllipse(*item.Item_t)
    AddElement(*item\childrens() )
    Define *Me.Ellipse_t  = AllocateMemory(SizeOf(Ellipse_t))
    Object::INI(Ellipse)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_ELLIPSE
    *Me\parent = *item
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD TEXT
  ; -----------------------------------------------------------------------------
  Procedure AddText(*item.Item_t, font.i)
    AddElement(*item\childrens() )
    Define *Me.Text_t  = AllocateMemory(SizeOf(Text_t))
    Object::INI(Text)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_TEXT
    *Me\parent = *item
    *Me\font = font
    *Me\font_size = 6
    *Me\text = "hello"
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  Procedure SetFont(*text.Text_t, font.i, font_size.f)
    *text\font = font
    *text\font_size = font_size
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD IMAGE
  ; -----------------------------------------------------------------------------
  Procedure AddImage(*item.Item_t, img.i, x.f=0, y.f=0)
    AddElement(*item\childrens() )
    Define *Me.Image_t  = AllocateMemory(SizeOf(Image_t))
    Object::INI(Image)
    Transform2D::Initialize(*Me\T)
    *Me\type = #ATOM_IMAGE
    *Me\parent = *item
    *Me\T\translate\x = x
    *Me\T\translate\y = y
    If IsImage(img)
      *Me\img = img
      *Me\width = ImageWidth(img)
      *Me\height = ImageHeight(img)
    EndIf
    *item\childrens() = *Me
    *item\active = *Me
    ProcedureReturn *Me
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   SET SIZE
  ; -----------------------------------------------------------------------------
  Procedure SetSize(*Me.Image_t, width.i, height.i)
    *Me\width = width
    *Me\height = height
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DELETE ATOM
  ; -----------------------------------------------------------------------------
  Procedure DeleteAtom(*Me.Atom_t)
    Select *Me\type
      Case #ATOM_POINT
        Object::TERM(Point)
      Case #ATOM_LINE
        Object::TERM(Line)
      Case #ATOM_BEZIER
        Object::TERM(Bezier)
      Case #ATOM_BOX
        Object::TERM(Box)
      Case #ATOM_CIRCLE
        Object::TERM(Circle)
      Case #ATOM_TEXT
        Object::TERM(Text)
      Case #ATOM_IMAGE
        Object::TERM(Image)
    EndSelect
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ADD  ATOM
  ; -----------------------------------------------------------------------------
  Procedure AddAtom(*item.Item_t, *atom.Atom_t)
    If ListSize(*item\childrens())
      ForEach *item\childrens()
        If *item\childrens() = *atom : ProcedureReturn *atom : EndIf
      Next
    EndIf
    
    AddElement(*item\childrens())
    *item\childrens() = *atom
    *item\childrens()\parent = *item
    ProcedureReturn *item\childrens()
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   REMOVE ATOM
  ; -----------------------------------------------------------------------------
  Procedure RemoveAtom(*item.Item_t, *atom.Atom_t)
    ForEach *item\childrens()
      If *item\childrens() = *atom 
        Define *atom.Atom_t = *item\childrens()
        DeleteAtom(*atom)
        DeleteElement(*item\childrens())
      EndIf
    Next
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ;   WRITE TO FILE
  ;-----------------------------------------------------------------------------
  Procedure WriteToFile(*item.Item_t, filename.s)
;     ; Create xml tree
;     Protected xml = CreateXML(#PB_Any) 
;     Protected node = CreateXMLNode(RootXMLNode(xml), *item\name) 
;     SetXMLNodeName(node, *item\name)
;     SetXMLNodeText(node, "What tHE fUCK YOU MEAN FUCKIN DEAD?")
;     Protected i = 0
;     
;     ; loop items
;     ForEach(*item\childrens())
;       ; Create first xml node (in main node)
;       item = CreateXMLNode(node, "Item"+Str(i)) 
;       SetXMLAttribute(item, "stroked", Str(*item\childrens()\stroked)) 
;       SetXMLAttribute(item, "stroke_type", Str(*item\childrens()\stroke_type)) 
;       SetXMLAttribute(item, "stroke_style", Str(*item\childrens()\stroke_style)) 
;       SetXMLAttribute(item, "stroke_width", StrF(*item\childrens()\stroke_width)) 
;       SetXMLAttribute(item, "stroke_color", Str(*item\childrens()\stroke_color)) 
;       SetXMLAttribute(item, "fill_color", Str(*item\childrens()\fill_color)) 
;       SetXMLAttribute(item, "filled", StrF(*item\childrens()\filled)) 
;       SetXMLNodeText(item, *item\childrens()\segments)
;       i + 1
;     Next
;     
;     ; format xml
;     FormatXML(xml, #PB_XML_ReFormat )
;     ; Save the xml tree into a xml file
;     SaveXML(xml, filename)

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; READ FROM FILE
  ;-----------------------------------------------------------------------------
  Procedure ReadFromFile(*item.Item_t, filename.s)
;     Protected xml = LoadXML(#PB_Any, filename)
;     If XMLStatus(xml) <> #PB_XML_Success
;       Protected msg.s = "Error in the XML file:" + Chr(13)
;       msg + "Message: " + XMLError(xml) + Chr(13)
;       msg + "Line: " + Str(XMLErrorLine(xml)) + "   Character: " + Str(XMLErrorPosition(xml))
;       MessageRequester("[Vector] Error", msg)
;     Else
;       ; clear old datas if any
;       Clear(*compound)
;       ; get the main xml node
;       Protected *node = MainXMLNode(xml)      
;       If *node
;         *compound\name = GetXMLNodeName(*node)
;         Protected numItems = XMLChildCount(*node)
;         MessageRequester("XML", Str(numItems))
;         Protected i
;         Protected *child
;         For i=1 To numItems
;           *child = ChildXMLNode(*node , i)  
;           If *child
;             AddElement(*item\childrens())
;             *item\childrens()\stroked       = Val(GetXMLAttribute(*child, "stroked"))
;             *item\childrens()\stroke_type   = Val(GetXMLAttribute(*child, "stroke_type"))
;             *item\childrens()\stroke_style  = Val(GetXMLAttribute(*child, "stroke_style"))
;             *item\childrens()\stroke_width  = ValF(GetXMLAttribute(*child, "stroke_width"))
;             *item\childrens()\stroke_color  = Val(GetXMLAttribute(*child, "stroke_color"))
;             *item\childrens()\fill_color    = Val(GetXMLAttribute(*child, "fill_color"))
;             *item\childrens()\filled        = Val(GetXMLAttribute(*child, "filled"))
;             *item\childrens()\segments      = GetXMLNodeText(*child)
;           EndIf
;         Next
;       EndIf
;     EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   COMPUTE BOUNDING BOX
  ; -----------------------------------------------------------------------------
  Procedure ComputeBoundingBox(*item.Item_t, init.b=#True)
    If init
      SaveVectorState()
      ResetPath()
    Else
      Transform(*item)
    EndIf
    

    Select *item\type
      Case #ATOM_BOX
        Define *box.Box_t = *item
        AddPathBox(-*box\halfsize\x, -*box\halfsize\y, 2 * *box\halfsize\x, 2 * *box\halfsize\y)
        
      Case #ATOM_CIRCLE
        Define *circle.Circle_t = *item
        AddPathCircle(0, 0, *circle\radius)
        
      Case #ATOM_LINE
        Define *line.Line_t = *item
        FirstElement(*line\points())
        MovePathCursor(*line\points()\x, *line\points()\y)
        While NextElement(*line\points())
          AddPathLine(*line\points()\x, *line\points()\y)
        Wend  
        
      Case #ATOM_BEZIER
        Define *bezier.Bezier_t = *item
        Define *a.BezierPoint_t, *b.BezierPoint_t
        FirstElement(*bezier\points())
        *a = *bezier\points()
        MovePathCursor(*a\position\x, *a\position\y)
        While NextElement(*bezier\points())
          *b = *bezier\points()
          AddPathCurve(*a\position\x + *a\out_tangent\x,
                       *a\position\y + *a\out_tangent\y,
                       *b\position\x + *b\in_tangent\x,
                       *b\position\y + *b\in_tangent\y,
                       *b\position\x,
                       *b\position\y)
        Wend  
        
      Case #ATOM_TEXT
        Define *txt.Text_t = *item
        MovePathCursor(0, 0)
        If *txt\font_size > 0
          VectorFont(FontID(*txt\font), *txt\font_size)
          AddPathText(*txt\text)
        EndIf
        
      Case #ATOM_IMAGE
        Define *img.Image_t = *item
        MovePathCursor(0, 0)
        AddPathBox(0,0,*img\width, *img\height)
    EndSelect
    
    ForEach *item\childrens()
      SaveVectorState()
      ComputeBoundingBox(*item\childrens(), #False)
      RestoreVectorState()
    Next

    If Not init
      Define x.f = PathBoundsX()
      Define y.f = PathBoundsY()
      Define w.f = PathBoundsWidth()
      Define h.f = PathBoundsHeight()
      If stroked
        x - stroke_width
        y - stroke_width
        w + 2 * stroke_width
        h + 2 * stroke_width
      EndIf
      
;       Vector::AccumulatedTransform(

      RestoreVectorState()
      Vector3::Set(*item\bbox\origin, x + w*0.5, y+h*0.5, 0)
      Vector3::Set(*item\bbox\extend, w*0.5, h*0.5, 0)
      VectorSourceColor(RGBA(255,222,111,255))
      ResetPath()
    EndIf

  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW BOUNDING BOX
  ; -----------------------------------------------------------------------------
  Procedure DrawBoundingBox(*item.Item_t, color.i, stroked.b=#True, stroke_width=4)
    ComputeBoundingBox(*item, #True)
    
    SaveVectorState()
    AddPathBox(*item\bbox\origin\x-*item\bbox\extend\x, *item\bbox\origin\y-*item\bbox\extend\y, *item\bbox\extend\x*2, *item\bbox\extend\y*2)
    VectorSourceColor(color)
    DashPath(1,3)
    
    Define x.f = ConvertCoordinateX(*item\bbox\origin\x-*item\bbox\extend\x, *item\bbox\origin\y-*item\bbox\extend\y, #PB_Coordinate_User, #PB_Coordinate_Device)
    Define y.f = ConvertCoordinateY(*item\bbox\origin\x-*item\bbox\extend\x, *item\bbox\origin\y-*item\bbox\extend\y, #PB_Coordinate_User, #PB_Coordinate_Device)
    Define w.f = ConvertCoordinateX(*item\bbox\extend\x*2, *item\bbox\extend\y*2, #PB_Coordinate_User, #PB_Coordinate_Device)
    Define h.f = ConvertCoordinateY(*item\bbox\extend\x*2, *item\bbox\extend\y*2, #PB_Coordinate_User, #PB_Coordinate_Device)
    
    ResetCoordinates()
    AddPathBox(x, y, w, h)
    VectorSourceColor(color)
    DashPath(1,3)
    RestoreVectorState()

  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW POINT
  ; -----------------------------------------------------------------------------
  Procedure DrawPoint(*pnt.Point_t, radius.f, stroke_color.i)
    VectorSourceColor(stroke_color)
    AddPathCircle(*pnt\x, *pnt\y, radius)
    FillPath()
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW POINTS
  ; -----------------------------------------------------------------------------
  Procedure DrawPoints(*line.Line_t, width.f)
    If ListSize(*line\points())
      ResetList(*line\points())
      
      While NextElement(*line\points())
        AddPathCircle(*line\points()\x, *line\points()\y, width *0.5)
        If *line\points() = *line\active
          VectorSourceColor(UIColor::HANDLE_H)
          FillPath()
        Else
          VectorSourceColor(UIColor::HANDLE)
          FillPath()
        EndIf
      Wend  
      
    EndIf
    
  EndProcedure
  
  
  ; -----------------------------------------------------------------------------
  ;   DRAW LINE INTERNAL
  ; -----------------------------------------------------------------------------
  Procedure DrawLineInternal(*line.Line_t)
    FirstElement(*line\points())
    MovePathCursor(*line\points()\x, *line\points()\y)
    
    If ListSize(*line\closed())
      Define index.i = 0
      Define last.i
      ForEach *line\closed()
        last = *line\closed()   
        While index < last
          NextElement(*line\points())
          AddPathLine(*line\points()\x, *line\points()\y)
          index + 1
        Wend
        ClosePath()
        NextElement(*line\points())
        If *line\points()
          MovePathCursor(*line\points()\x, *line\points()\y)
          index + 1
        EndIf
      Next
    Else
      While NextElement(*line\points())
        AddPathLine(*line\points()\x, *line\points()\y)
      Wend  
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW LINE
  ; -----------------------------------------------------------------------------
  Procedure DrawLine(*line.Line_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216, expand.i=0)
    ; draw line
    If ListSize(*line\points())

      DrawLineInternal(*line)

      If filled
        VectorSourceColor(fill_color)
        If stroked
          FillPath(#PB_Path_Preserve)
        Else
          FillPath()
        EndIf
      EndIf
      
      If stroked
        VectorSourceColor(stroke_color)
        Globals::MAXIMIZE(stroke_width, 0.0000001)
        Select stroke_type
          Case #STROKE_DEFAULT
            StrokePath( stroke_width, stroke_style)
          Case #STROKE_DOT
            DotPath( stroke_width, stroke_width * 2, stroke_style)
          Case #STROKE_DASH
            DashPath( stroke_width, stroke_width * 4, stroke_style)
          Case #STROKE_CUSTOM
            StrokePath(stroke_width, stroke_style)
        EndSelect
      EndIf
      
    EndIf
    
    ; draw edit handle
    If Vector::GETSTATE(*line, #STATE_EDIT)
      If ListSize(*line\points())
        
        DrawLineInternal(*line)
        VectorSourceColor(UIColor::BLACK)
        StrokePath( 1)
        
        DrawPoints(*line, stroke_width)
      EndIf
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW BEZIER
  ; -----------------------------------------------------------------------------
  Procedure DrawBezier(*bezier.Bezier_t, width.f, stroke_color.i, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default)

    Define numPoints.i = ListSize(*bezier\points())
    Define *A.BezierPoint_t, *B.BezierPoint_t
    If numPoints > 0
      If numPoints > 2
        FirstElement(*bezier\points())
        *A = *bezier\points()
        MovePathCursor(*bezier\points()\position\x, *bezier\points()\position\y)
        While NextElement(*bezier\points())
          *B = *bezier\points()
          AddPathCurve(*A\position\x + *A\out_tangent\x,
                       *A\position\y + *A\out_tangent\y,
                       *B\position\x + *B\in_tangent\x,
                       *B\position\y + *B\in_tangent\y,
                       *B\position\x,
                       *B\position\y)
          
          *A = *B
        Wend
      Else
        FirstElement(*bezier\points())
        MovePathCursor(*bezier\points()\position\x, *bezier\points()\position\y)
        NextElement(*bezier\points())
        AddPathLine(*bezier\points()\position\x, *bezier\points()\position\y)
      EndIf

      VectorSourceColor(stroke_color)
      Select stroke_type
        Case #STROKE_DEFAULT
          StrokePath( width, stroke_style)
        Case #STROKE_DOT
          DotPath( width, width * 2, stroke_style)
        Case #STROKE_DASH
          DashPath( width, width * 4, stroke_style)
        Case #STROKE_CUSTOM
          StrokePath(width, stroke_style)
      EndSelect
    EndIf

  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW ATOM
  ; -----------------------------------------------------------------------------
  Procedure DrawAtom(filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216, expand.i=0)
    If filled
      VectorSourceColor(fill_color)
      If stroked 
        FillPath(#PB_Path_Preserve)
      Else
        FillPath()
      EndIf
    EndIf
    
    If stroked
      VectorSourceColor(stroke_color)
      Select stroke_type
        Case #STROKE_DEFAULT
          StrokePath(stroke_width, stroke_style)
        Case #STROKE_DOT
          DotPath(stroke_width, stroke_width * 2, stroke_style)
        Case #STROKE_DASH
          DashPath(stroke_width, stroke_width * 4, stroke_style)
        Case #STROKE_CUSTOM
          StrokePath(stroke_width, stroke_style)
        Default
          StrokePath(stroke_width, stroke_style)
      EndSelect
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW BOX
  ; -----------------------------------------------------------------------------
  Procedure DrawBox(*box.Box_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216, expand.i=0)
    AddPathBox(-*box\halfsize\x-expand, -*box\halfsize\y-expand, *box\halfsize\x * 2 + 2 * expand, *box\halfsize\y * 2 + 2 * expand)
    DrawAtom(filled, stroked, fill_color, stroke_width, stroke_type, stroke_style, stroke_color, expand)
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW CIRCLE
  ; -----------------------------------------------------------------------------
  Procedure DrawCircle(*circle.Circle_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216, expand.i=0)
    AddPathCircle(0, 0, *circle\radius + expand)
    DrawAtom(filled, stroked, fill_color, stroke_width, stroke_type, stroke_style, stroke_color, expand)
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW TEXT
  ; -----------------------------------------------------------------------------
  Procedure DrawTextAtom(*text.Text_t, filled.b, stroked.b, fill_color.i, stroke_width.f=1, stroke_type.i=#STROKE_DEFAULT, stroke_style.i=#PB_Path_Default, stroke_color=-16777216)
    MovePathCursor(0, 0)
    VectorFont(FontID(*text\font), *text\font_size)
    AddPathText(*text\text)
    DrawAtom(filled, stroked, fill_color, stroke_width, stroke_type, stroke_style, stroke_color, expand)
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW IMAGE
  ; -----------------------------------------------------------------------------
  Procedure DrawImageAtom(*img.Image_t)
    If IsImage(*img\img)
      MovePathCursor(0, 0)
      DrawVectorImage(ImageID(*img\img), 255, *img\width, *img\height)
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   DRAW ITEM
  ; -----------------------------------------------------------------------------
  Procedure DrawItem(*item.Item_t)
    SaveVectorState()
    Transform(*item)
   
    Select *item\type
        
      Case #ATOM_LINE
      
        If Vector::GETSTATE(*item, #STATE_ACTIVE)
          DrawBoundingBox(*item, UIColor::ACTIVE)
          DrawLine(*item, *item\filled, *item\stroked, *item\fill_color, *item\stroke_width, *item\stroke_type, *item\stroke_style, *item\stroke_color)
        ElseIf Vector::GETSTATE(*item, #STATE_OVER)
          DrawBoundingBox(*item, UIColor::OVER)
          DrawLine(*item, *item\filled, *item\stroked, *item\fill_color, *item\stroke_width, *item\stroke_type, *item\stroke_style, UIColor::EDIT)
        Else
          DrawLine(*item, *item\filled, *item\stroked, *item\fill_color, *item\stroke_width, *item\stroke_type, *item\stroke_style, *item\stroke_color)
        EndIf

        If Vector::GETSTATE(*item, #STATE_EDIT)
          DrawPoints(*item, *item\stroke_width)
        EndIf
        
      Case #ATOM_BEZIER
        If Vector::GETSTATE(*item, #STATE_ACTIVE)
          DrawBoundingBox(*item, UIColor::ACTIVE)
          DrawBezier(*item, *item\stroke_width+Globals::#SELECTION_BORDER, UIColor::SELECTED, *item\stroke_type, *item\stroke_style)
        ElseIf Vector::GETSTATE(*item, #STATE_OVER)
          DrawBoundingBox(*item, UIColor::OVER)
          DrawBezier(*item, *item\stroke_width+Globals::#SELECTION_BORDER, UIColor::SELECTED, *item\stroke_type, *item\stroke_style)
        EndIf
        DrawBezier(*item, *item\stroke_width, *item\stroke_color, *item\stroke_type, *item\stroke_style)

        If Vector::GETSTATE(*item, #STATE_EDIT)
          DrawPoints(*item, *item\stroke_width)
        EndIf
        
      Case #ATOM_BOX
        If Vector::GETSTATE(*item, #STATE_ACTIVE)
          DrawBoundingBox(*item, UIColor::ACTIVE)
          DrawBox(*item, *item\filled, #False, UIColor::SELECTED, 2, #STROKE_DEFAULT, #PB_Path_Default, UIColor::SELECTED,Globals::#SELECTION_BORDER)
        ElseIf Vector::GETSTATE(*item, #STATE_OVER)
          DrawBoundingBox(*item, UIColor::OVER)
          DrawBox(*item, *item\filled, #False, UIColor::SELECTED, 2, #STROKE_DEFAULT, #PB_Path_Default, UIColor::SELECTED,Globals::#SELECTION_BORDER)
        Else
          DrawBox(*item, *item\filled, *item\stroked, *item\fill_color, *item\stroke_width, *item\stroke_type, *item\stroke_style, *item\stroke_color)
        EndIf

      Case #ATOM_CIRCLE
        If Vector::GETSTATE(*item, #STATE_ACTIVE)
          DrawBoundingBox(*item, UIColor::ACTIVE)
          DrawCircle(*item, *item\filled, #False, UIColor::SELECTED, 1, #STROKE_DEFAULT, #PB_Path_Default, UIColor::SELECTED,Globals::#SELECTION_BORDER)
        ElseIf Vector::GETSTATE(*item, #STATE_OVER)
          DrawBoundingBox(*item, UIColor::OVER)
          DrawCircle(*item, *item\filled, *item\stroked, UIColor::SELECTED, 1, *item\stroke_width, *item\stroke_type, UIColor::SELECTED,Globals::#SELECTION_BORDER)
        Else
          DrawCircle(*item, *item\filled, *item\stroked, *item\fill_color, *item\stroke_width, *item\stroke_type, *item\stroke_style, *item\stroke_color)
        EndIf
        
      Case #ATOM_TEXT
        If Vector::GETSTATE(*item, #STATE_ACTIVE)
          DrawBoundingBox(*item, UIColor::ACTIVE)
          DrawTextAtom(*item, #True, #True, UIColor::SELECTED, Globals::#SELECTION_BORDER, #STROKE_DEFAULT, #PB_Path_Default, UIColor::SELECTED)
        ElseIf Vector::GETSTATE(*item, #STATE_OVER)
          DrawBoundingBox(*item, UIColor::OVER)
          DrawTextAtom(*item, #True, #True, UIColor::SELECTED, Globals::#SELECTION_BORDER, #STROKE_DEFAULT, #PB_Path_Default, UIColor::SELECTED)
        Else
          DrawTextAtom(*item, *item\filled, *item\stroked, *item\fill_color, *item\stroke_width, *item\stroke_type, *item\stroke_style, *item\stroke_color)
        EndIf
        
       Case #ATOM_IMAGE
         If Vector::GETSTATE(*item, #STATE_ACTIVE)
            DrawBoundingBox(*item, UIColor::ACTIVE)
            DrawImageAtom(*item)
          ElseIf Vector::GETSTATE(*item, #STATE_OVER)
            DrawBoundingBox(*item, UIColor::OVER)
            DrawImageAtom(*item)
          Else 
            DrawImageAtom(*item)
          EndIf
          
        Case #ATOM_COMPOUND
          AddPathCircle(0,0,12)
          VectorSourceColor(RGBA(255,0,0,255))
          FillPath()
          If Vector::GETSTATE(*item, #STATE_ACTIVE)
            DrawBoundingBox(*item, UIColor::ACTIVE)
          ElseIf Vector::GETSTATE(*item, #STATE_OVER)
            DrawBoundingBox(*item, UIColor::OVER)
          EndIf
    
    EndSelect
    
    ; rescursive draw
    ForEach *item\childrens()
      DrawItem(*item\childrens())
    Next
    
    RestoreVectorState()
;     ForEach *item\childrens()
;       If *item\childrens()\type = #ATOM_LINE
;         DrawLine(*item\childrens())
;       EndIf
;       
;       With *item\childrens()
;         AddPathSegments(\segments)
;         If \filled
;           VectorSourceColor(\fill_color)
;           FillPath(#PB_Path_Preserve)
;         EndIf
;         If \stroked
;           VectorSourceColor(\stroke_color)
;           StrokePath(\stroke_width)
;         EndIf
;       EndWith
;     Next
;     
;     If *compound\segments
;       AddPathSegments(*compound\segments)
;       If *compound\filled
;         VectorSourceColor(*compound\fill_color)
;         FillPath(#PB_Path_Preserve)
;       EndIf
;       If *compound\stroked
;         VectorSourceColor(*compound\stroke_color)
;         StrokePath(*compound\stroke_width)
;       EndIf
;     EndIf
  EndProcedure 
  
  ; ----------------------------------------------------------------------------
  ;   PICK POINT
  ;-----------------------------------------------------------------------------
  Procedure PickPoint(*pnt.Point_t, mx.f, my.f, radius.f)
    ResetPath()
    AddPathCircle(*pnt\x, *pnt\y, radius)
    If IsInsidePath(mx, my, #PB_Coordinate_Device)
      ProcedureReturn *pnt
    Else
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   PICK POINTS ( FROM LINE )
  ;-----------------------------------------------------------------------------
  Procedure PickPoints(*line.Line_t, filled.b, mx.f, my.f, width.f)
    ResetList(*line\points())
    Define current = 0
    Define index = -1
    While NextElement(*line\points())
      If PickPoint(*line\points(), mx, my, width)
        index = current
        SETSTATE(*line\points(), #STATE_OVER)
      Else
        CLEARSTATE(*line\points(), #STATE_OVER)
      EndIf
      current + 1
    Wend
    If index > -1
      SelectElement(*line\points(), index)
      ProcedureReturn *line\points()
    Else
      ProcedureReturn #Null
    EndIf
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   PICK LINE
  ;-----------------------------------------------------------------------------
  Procedure PickLine(*line.Line_t, filled.b, mx.f, my.f, width.f)
    DrawLineInternal(*line)
    Define index.i = -2
    Define current.i
    If filled
      If IsInsidePath(mx, my, #PB_Coordinate_Device)
        index = -1
;         If Vector::GETSTATE(*line, Vector::#STATE_EDIT)
;           current = PickPoints(*line, filled, mx, my, width)
;           If current > -1 
;             SelectElement(*line\points(), current) 
;             *line\active = *line\points()  
;             index = current
;           EndIf
;         Else
;           *line\active = #Null
;         EndIf
      EndIf
    Else
      If IsInsideStroke(mx, my,  width, #PB_Path_Default, #PB_Coordinate_Device)
        index = -1
;         If Vector::GETSTATE(*line, Vector::#STATE_EDIT)
;           current = PickPoints(*line, filled, mx, my, width)
;           If current > -1 
;             SelectElement(*line\points(), current) 
;             *line\active = *line\points() 
;             index = current
;           Else
;             *line\active = #Null
;           EndIf
;         Else
;           *line\active = #Null
;         EndIf
      EndIf
    EndIf
    
    ResetPath()
    
;     If index >=0
;       SelectElement(*line\childrens(), index)
;       Debug "RETURN : "+Str(*line\childrens())
;       ProcedureReturn *line\childrens()
;     Else
    If index = -1
      ProcedureReturn *line
    Else
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   PICK BEZIER
  ;-----------------------------------------------------------------------------
  Procedure PickBezier(*bezier.Bezier_t, filled.b, mx.f, my.f, width.f)

    ResetPath()
    FirstElement(*bezier\points())
    MovePathCursor(*bezier\points()\position\x, *bezier\points()\position\y)
    While NextElement(*bezier\points())
      AddPathLine(*bezier\points()\position\x, *bezier\points()\position\y)
    Wend

    Define index.i = -2
    Define current.i
    If filled
      
      If IsInsidePath(mx, my, #PB_Coordinate_Device)
        index = -1
        If Vector::GETSTATE(*bezier, Vector::#STATE_EDIT)
          current = PickPoints(*bezier, filled, mx, my, width)
          If current > -1 
            SelectElement(*bezier\points(), current) 
            *bezier\active = *bezier\points()  
          EndIf
        Else
          *bezier\active = #Null
        EndIf
      EndIf
    Else
      If Vector::GETSTATE(*bezier, Vector::#STATE_EDIT)
        index = -1
        current = PickPoints(*bezier, filled, mx, my, width)
        If current > -1 
          SelectElement(*bezier\points(), current) 
          *bezier\active = *bezier\points()  
          ResetPath()
          RestoreVectorState()
          ProcedureReturn #True
        EndIf
      Else
        If IsInsideStroke(mx, my,  width, #PB_Path_Default, #PB_Coordinate_Device)
          index = -1
          *bezier\active = #Null
        EndIf
      EndIf
    EndIf
    ResetPath()
    
    If index >=0
      SelectElement(*bezier\childrens(), index)
      ProcedureReturn *bezier\childrens()
    ElseIf index = -1
      ProcedureReturn *bezier
    Else
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   PICK BOX
  ; ----------------------------------------------------------------------------
  Procedure PickBox(*box.Box_t, filled.b, mx.f, my.f, width.f)
    ResetPath()
    AddPathBox(-*box\halfsize\x, -*box\halfsize\y, *box\halfsize\x * 2, *box\halfsize\y * 2)

    If filled
      If IsInsidePath(mx, my, #PB_Coordinate_Device)
        ProcedureReturn *box
      EndIf
      
    Else
      If IsInsideStroke(mx, my, width, #PB_Coordinate_Device)
        ProcedureReturn *box
      EndIf
   
    EndIf
    ProcedureReturn #Null

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   PICK IMAGE
  ; ----------------------------------------------------------------------------
  Procedure PickImage(*img.Image_t,  mx.f, my.f)
    ResetPath()
    AddPathBox(0, 0, *img\width, *img\height)
    If IsInsidePath(mx, my, #PB_Coordinate_Device)
      ProcedureReturn *img
    Else
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   PICK CIRCLE
  ; ----------------------------------------------------------------------------
  Procedure PickCircle(*circle.Circle_t, filled.b, mx.f, my.f, width.f)
    ResetPath()
    AddPathCircle(0, 0, *circle\radius)

    If filled
      If IsInsidePath(mx, my, #PB_Coordinate_Device)
        ProcedureReturn *circle
      EndIf
      
    Else
      If IsInsideStroke(mx, my, width, #PB_Coordinate_Device)
        ProcedureReturn *circle
      EndIf
      
    EndIf
    ProcedureReturn #Null
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   PICK TEXT
  ; ----------------------------------------------------------------------------
  Procedure PickText(*text.Text_t, mx.f, my.f)
    ResetPath()
    MovePathCursor(0, 0)
    VectorFont(FontID(*text\font), *text\font_size)
    AddPathText(*text\text)
    Define x.f = PathBoundsX()
    Define y.f = PathBoundsY()
    Define w.f = PathBoundsWidth()
    Define h.f = PathBoundsHeight()
    ResetPath()
    AddPathBox(x, y, w, h)
    If IsInsidePath(mx, my, #PB_Coordinate_Device)
      ProcedureReturn *text
    Else
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   RESET PICK 
  ; ----------------------------------------------------------------------------
  Procedure ResetPick(*item.Item_t)
    ForEach *item\childrens()
      CLEARSTATE(*item\childrens(), #STATE_OVER)
    Next
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   UPDATE OVER STATE
  ; ----------------------------------------------------------------------------
  Macro UpdateOverState(_item, _over)
    If _over <> #Null
      *picked = _over
      SETSTATE(_item, #STATE_OVER)
    Else
      If _item
        CLEARSTATE(_item, #STATE_OVER)
      EndIf
    EndIf
  EndMacro
    
  ; ----------------------------------------------------------------------------
  ;   PICK
  ; ----------------------------------------------------------------------------
  Procedure PickItem(*item.Item_t, mx.f, my.f)
    ResetPath()
    Define *picked.Item_t = #Null
    Define *current.Item_t
    If IsLocked(*item) : ProcedureReturn #Null : EndIf
    SaveVectorState()
    Transform(*item)
    
    Select *item\type
;       Case #ATOM_POINT  
;         *current = PickPoint(*item, mx, my, *item\stroke_width)
;         If *current : UpdateOverState(*item, *current) : EndIf
       
      Case  #ATOM_LINE
        *current = PickLine(*item, *item\filled, mx, my, *item\stroke_width)
        UpdateOverState(*item, *current)
        
      Case  #ATOM_BEZIER
        *current = PickBezier(*item, *item\filled, mx, my, *item\stroke_width)
        UpdateOverState(*item, *current)
        
;       Case  #ATOM_ELLIPSE
;         *current = PickEllipse(*item, *item\filled, mx, my, *item\stroke_width)
;         If *current : UpdateOverState(*item, *current) : EndIf
        
      Case #ATOM_BOX
        *current = PickBox(*item, *item\filled, mx, my, *item\stroke_width)
        UpdateOverState(*item, *current)
        
      Case #ATOM_IMAGE
        *current = PickImage(*item, mx, my)
        UpdateOverState(*item, *current)
        
      Case #ATOM_CIRCLE
        *current = PickCircle(*item, #True, mx, my, *item\stroke_width)
        UpdateOverState(*item, *current)
        
      Case #ATOM_TEXT
        *current = PickText(*item, mx, my)
        UpdateOverState(*item, *current)
        
    EndSelect
    
    ForEach *item\childrens()       
      If IsLocked(*item\childrens()) : Continue : EndIf
      *current = PickItem(*item\childrens(), mx, my)
      UpdateOverState(*item\childrens(), *current)
    Next
    RestoreVectorState()
    ProcedureReturn *picked
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   UPDATE HIERARCHY
  ; ----------------------------------------------------------------------------
  Procedure UpdateHierarchy(*item.Item_t)
    Define *parentT.Transform2D::Transform_t = #Null
    If *item\parent
      Define *parentItem.Item_t = *item\parent
      *parentT = *parentItem\T
    EndIf
    
    Transform2D::Compute(*item\T, *parentT)
    ForEach *item\childrens()
      UpdateHierarchy(*item\childrens())
    Next
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   TRANSLATE
  ; ----------------------------------------------------------------------------
  Procedure Translate(*atom.Atom_t, x.f, y.f)
    Select *atom\type
      Case Vector::#ATOM_POINT
        Define *pnt.Point_t = *atom
        *pnt\x + x
        *pnt\y + y
        
      Default
        Define *item.Item_t = *atom
        If *item\parent
          Define *parent.Vector::Item_t = *item\parent

          Define m.Transform2D::Matrix_t
          Define p.Transform2D::Vector_t
          p\x = x
          p\y = y
          p\z = 1
          Transform2D::Inverse(m, *parent\T\globalT)
          Transform2D::TRANSLATE(*item\T, Transform2D::TransformPointX(p, m), Transform2D::TransformPointY(p, m))
          UpdateHierarchy(*item)
        Else
          Transform2D::Translate(*item\T, x, y)
          UpdateHierarchy(*item)
        EndIf
    
    EndSelect

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   ROTATE
  ; ----------------------------------------------------------------------------
  Procedure Rotate(*atom.Atom_t, angle.f)
    If *atom\type <> Vector::#ATOM_POINT
      Define *item.Item_t = *atom
      Transform2D::ROTATE(*item\T, angle)
      UpdateHierarchy(*item)
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   TRANSFORM
  ; ----------------------------------------------------------------------------
  Procedure Transform(*item.Item_t)
    TranslateCoordinates(*item\T\translate\x, *item\T\translate\y)  
    RotateCoordinates(0,0,*item\T\rotate)
    ScaleCoordinates(*item\T\scale\x, *item\T\scale\y)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   ACCUMULATED TRANSFORM
  ; ----------------------------------------------------------------------------
  Procedure AccumulatedTransform(*item.Item_t, *m.Transform2D::Matrix_t)
    If *item\parent
      Define NewList *parents.Item_t()
      Define *parent.Item_t = *item
      While *parent\parent
        AddElement(*parents())
        *parents() = *parent\parent
        *parent = *parent\parent
      Wend
      ResetCoordinates()
      Define recurse.i = 0
      Repeat
        recurse + 1
        Transform2D::Compute(*parents()\T)
        Transform(*parents())
      Until PreviousElement(*parents()) = #False
      FreeList(*parents())
    EndIf
    Transform(*item)

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   INVERSE TRANSFORM
  ; ----------------------------------------------------------------------------
  Procedure InverseTransform(*T.Transform2D::Matrix_t)
    ScaleCoordinates(1-(1-*T\scale\x), 1-(1-*T\scale\y))
    RotateCoordinates(0,0,-*T\rotate)
    TranslateCoordinates(-*T\translate\x, -*T\translate\y)  
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   ACCUMULATED TRANSFORM
  ; ----------------------------------------------------------------------------
  Procedure AccumulatedInverseTransform(*item.Item_t)
    If *item\parent
      Define NewList *parents.Item_t()
      Define *parent.Item_t = *item
      While *parent\parent
        AddElement(*parents())
        *parents() = *parent\parent
        *parent = *parent\parent
      Wend
      ResetCoordinates()
      Define recurse.i = 0
      Repeat
        recurse + 1
        InverseTransform(*parents()\T)
      Until PreviousElement(*parents()) = #False
      FreeList(*parents())
    EndIf
    Transform(*item)

  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   ROUND BOX PATH
  ; -----------------------------------------------------------------------------
  Procedure RoundBoxPath(x.f, y.f, width.f, height.f, radius.f=6)
    MovePathCursor(x + radius,y)
    AddPathArc(x+width,y,x+width,y+height,radius)
    AddPathArc(x+width,y+height,x,y+height,radius)
    AddPathArc(x,y+height,x,y,radius)
    AddPathArc(x,y,x+width,y,radius)
    ClosePath()
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   STAR PATH
  ; -----------------------------------------------------------------------------
  Procedure StarPath(center_x.f, center_y.f, inner_radius.f, outer_radius.f, num_branches.i)
    MovePathCursor(center_x ,center_y + outer_radius)
;     AddPathArc(offsetx+width,offsety,offsetx+width,offsety+height,radius)
;     AddPathArc(offsetx+width,offsety+height,offsetx,offsety+height,radius)
;     AddPathArc(offsetx,offsety+height,offsetx,offsety,radius)
;     AddPathArc(offsetx,offsety,offsetx+width,offsety,radius)
    ClosePath()
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   MOVE CURSOR PATH ON CIRCLE
  ; -----------------------------------------------------------------------------
  Procedure MoveCursorPathOnCircle(cx.f, cy.f, radius.f, angle.f)
    Define pcx.f = Cos(angle) * radius
    Define pcy.f = Sin(angle) * radius
    MovePathCursor(cx + pcx, cy + pcy)
  EndProcedure
  
  Procedure FromFile()
;     Define window = OpenWindow(#PB_Any, 0,0,800,800, "VECTOR")
;     Define canvas = CanvasGadget(#PB_Any, 0,0,800,800)
;     Define size = 32
;     Define radius = 6
;     Define offsetx = 20
;     Define offsetY = 20
;     Define stroke_width = 2
;   
;     Define icon.Vector::Compound_t
;     icon\name = "ICON1"
;     InitializeStructure(icon, Vector::Compound_t)
;     Define color.i
;     
;     Vector::ReadFromFile(icon, "E:/Projects/RnD/Noodle/rsc/vector/icon1.xml")
;     StartVectorDrawing(CanvasVectorOutput(canvas))
;     Vector::DrawCompound(icon)
;     StopVectorDrawing()
;     
;     Repeat
;     Until WaitWindowEvent() = #PB_Event_CloseWindow
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   LOCK
  ; -----------------------------------------------------------------------------
  Procedure Lock(*atom.Atom_t)
    Vector::SETSTATE(*atom, Vector::#STATE_LOCKED)
  EndProcedure
  
  Procedure Unlock(*atom.Atom_t)
    Vector::CLEARSTATE(*atom, Vector::#STATE_LOCKED)
  EndProcedure
  
  Procedure.b IsLocked(*atom.Atom_t)
    ProcedureReturn Vector::GETSTATE(*atom, Vector::#STATE_LOCKED)
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   CONNEXION
  ; -----------------------------------------------------------------------------
  Procedure Connect(*pnt.Point_t, *other.Point_t)
;     Define exist.b = #False
;     ForEach *pnt\connexions()
;       If *pnt\connexions() = *other : exist = #True : Break : EndIf
;     Next
;     If Not exist : AddElement(*pnt\connexions()) : *pnt\connexions() = *other : EndIf
;     
;     exist = #False
;      ForEach *other\connexions()
;       If *other\connexions() = *pnt : exist = #True : Break : EndIf
;     Next
;     If Not exist : AddElement(*other\connexions()) : *other\connexions() = *pnt : EndIf
  EndProcedure
  
  Procedure Disconnect(*pnt.Point_t, *other.Point_t)
    
  EndProcedure
  
  Procedure.b IsConnected(*pnt.Point_t)
;     ProcedureReturn Bool(ListSize(*pnt\connexions())>0)
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   EDITION
  ; -----------------------------------------------------------------------------
  Procedure BeginEdit(*atom.Atom_t, x.f, y.f)
    ;     *atom\edit = #True
    Select *atom\type
      Case #ATOM_LINE
        Define *line.Line_t = *atom
        If AddElement(*line\points())
          *line\points()\x = x
          *line\points()\y = y
          *line\points()\id = ListSize(*line\points())-1
        EndIf
        
    EndSelect
  EndProcedure
  
  ; -----------------------------------------------------------------------------
  ;   INSERTION
  ; -----------------------------------------------------------------------------
  Procedure InsertPoint(*atom.Atom_t, x.f, y.f, index.i=-1)
    Select *atom\type
      Case #ATOM_LINE
        Define *line.Line_t = *atom
        AddElement(*line\points())
        *line\points()\x = x
        *line\points()\y = y
        *line\points()\id = ListSize(*line\points())-1
        Object::PROXY(*line, "point"+Str(ListSize(*line\points()))+"_x", *line\points()\x, Slot::#SLOT_FLOAT)
        Object::PROXY(*line, "point"+Str(ListSize(*line\points()))+"_y", *line\points()\y, Slot::#SLOT_FLOAT)
      Case #ATOM_Bezier
        Define *bezier.Bezier_t = *atom
        AddElement(*bezier\points())
        *bezier\points()\position\x = x
        *bezier\points()\position\y = y
        *bezier\points()\in_tangent\x = -64
        *bezier\points()\in_tangent\y = 0
        *bezier\points()\out_tangent\x = 64
        *bezier\points()\out_tangent\y = 0
        *bezier\points()\id = ListSize(*bezier\points())-1
        Define sindex.s
        If index = -1
          sindex = Str(ListSize(*bezier\points()))
        Else
          sindex = Str(index)
        EndIf
        
        Object::PROXY(*bezier, "point"+sindex+"_pos_x", *bezier\points()\position\x, Slot::#SLOT_FLOAT)
        Object::PROXY(*bezier, "point"+sindex+"_pos_y", *bezier\points()\position\y, Slot::#SLOT_FLOAT)
        Object::PROXY(*bezier, "point"+sindex+"_in_tan_x", *bezier\points()\in_tangent\x, Slot::#SLOT_FLOAT)
        Object::PROXY(*bezier, "point"+sindex+"_in_tan_y", *bezier\points()\in_tangent\y, Slot::#SLOT_FLOAT)
        Object::PROXY(*bezier, "point"+sindex+"_out_tan_x", *bezier\points()\out_tangent\x, Slot::#SLOT_FLOAT)
        Object::PROXY(*bezier, "point"+sindex+"_out_tan_y", *bezier\points()\out_tangent\y, Slot::#SLOT_FLOAT)
    EndSelect
  EndProcedure
  
  Procedure EndEdit(*atom.Atom_t)
;     *atom\edit = #False
  EndProcedure
  
  Procedure CloseLine(*line.Line_t)
    AddElement(*line\closed())
    *line\closed() = ListSize(*line\points()) - 1
  EndProcedure
  
  Procedure CloseBezier(*bezier.Bezier_t)
    AddElement(*bezier\closed())
    *bezier\closed() = ListSize(*bezier\points()) - 1
  EndProcedure

EndModule




; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 570
; FirstLine = 567
; Folding = -----------------
; EnableXP
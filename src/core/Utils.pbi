XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../objects/Location.pbi"

UseModule OpenGL
UseModule OpenGLExt

UsePNGImageDecoder()
UseTGAImageDecoder()
UseJPEGImageDecoder()
UseTIFFImageDecoder()
UseJPEG2000ImageDecoder()

DeclareModule Utils
  UseModule Math
  Declare GLDecodeID(x,y,z)
  Declare GLLoadImage(imageID,flipY.b=#True,wrap_s=#GL_CLAMP,wrap_t=#GL_CLAMP,min_f=#GL_NEAREST,mag_f=#GL_NEAREST)
  Declare GLWriteImage(path.s,width.i,height.i)
  Declare TransformPositionArray(*io.CArray::CArrayV3F32,*points.CArray::CArrayV3F32,*m.m4f32)
  Declare TransformPositionArrayInPlace(*points.CArray::CArrayV3F32,*m.m4f32)
  Declare BuildCircleSection(*io.CArray::CArrayV3F32, nbp.i = 12, radius.f = 1.0,start_angle.f = 0.0,end_angle.f = 360.0)
  Declare BuildMatrixArray(*io.CArray::CArrayM4F32,*a.v3f32,*b.v3f32,*c.v3f32,*d.v3f32,*up.v3f32)
  Declare RotateVector(*v.v3f32,*q.q4f32,*io.v3f32)
  Declare DirectionToRotation(*io.m3f32,*dir.v3f32,*up.v3f32=#Null)
  Declare ClosestPointOnTriangle(*io.v3f32,*a.v3f32,*b.v3f32,*c.v3f32,*p.v3f32)
EndDeclareModule

Module Utils
  UseModule OpenGL
  UseModule Math
  ;-------------------------------------------
  ; Encode a unique ID into a color with components in range 0.0 to 1.0
  ;-------------------------------------------
  Procedure GLDecodeID(x,y,z)
    ProcedureReturn RGB(x,y,z)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Draw Arrow
  ;---------------------------------------------------------
  ; Procedure GL_DrawAxis(axis.i=0)
  ;   glPushMatrix()
  ;   glDisable(#GL_LIGHTING)
  ;   Protected *quad
  ;   Select axis
  ;     Case 0 ; X axis
  ;       glColor3f(1,0,0)
  ;       glBegin(#GL_LINES)
  ;       glVertex3f(0,0,0)
  ;       glVertex3f(1,0,0)
  ;       glEnd()
  ;       glTranslatef(1,0,0)
  ;       glRotatef(90,0,1,0)
  ; ;       *quad = gluNewQuadric()
  ; ;       gluCylinder(*quad,0.1,0,0.25,12,6)
  ;       
  ;     Case 1 ; Y Axis
  ;       glColor3f(0,1,0)
  ;       glBegin(#GL_LINES)
  ;       glVertex3f(0,0,0)
  ;       glVertex3f(0,1,0)
  ;       glEnd()
  ;       glTranslatef(0,1,0)
  ;       glRotatef(-90,1,0,0)
  ; ;       *quad = gluNewQuadric()
  ; ;       gluCylinder(*quad,0.1,0,0.25,12,6)
  ;       
  ;     Case 2 ; Z Axis
  ;       glColor3f(0,0,1)
  ;       glBegin(#GL_LINES)
  ;       glVertex3f(0,0,0)
  ;       glVertex3f(0,0,1)
  ;       glEnd()
  ;       glTranslatef(0,0,1)
  ; ;       *quad = gluNewQuadric()
  ; ;       gluCylinder(*quad,0.1,0,0.25,12,6)
  ;       
  ;   EndSelect
  ;   glPopMatrix()
  ; EndProcedure
  
  ; ;---------------------------------------------------------
  ; ; Build OpenGL Font from image
  ; ;---------------------------------------------------------
  ; Procedure GL_BuildFont(GLTextureID)
  ;   Protected base = glGenLists(95)
  ;   Protected loop
  ;   glBindTexture(#GL_TEXTURE_2D, GLTextureID)
  ;   For loop=0 To 94
  ;     
  ;     Protected cx.f = Mod(loop,16)/16.0
  ;     Protected cy.f = Mod((loop/16),8.0)
  ;     
  ; ;     glNewList(base+loop,#GL_COMPILE)
  ; ;     glBegin(#GL_QUADS)
  ; ;     ;Bottom Left
  ; ;     glTexCoord2f(cx         ,1.0-cy-0.120)
  ; ;     glVertex2i(0,0)
  ; ;     ;Bottom Right
  ; ;     glTexCoord2f(cx+0.0625 ,1.0-cy-0.120)
  ; ;     glVertex2i(16,0)
  ; ;     ;Top Right
  ; ;     glTexCoord2f(cx+0.0625 ,1.0-cy)
  ; ;     glVertex2i(16,16)
  ; ;     ;Top Left
  ; ;     glTexCoord2f(cx        ,1.0-cy)
  ; ;     glVertex2i(0,16)
  ; ;     glEnd()
  ; ;     
  ; ;     glTranslated(10,0,0)
  ; ;     glEndList()
  ;   Next loop
  ;      
  ; EndProcedure
  
  ;------------------------------------------------------------
  ; Load Image
  ;------------------------------------------------------------
  Procedure GLLoadImage(imageID,flipY.b=#True,wrap_s=#GL_CLAMP,wrap_t=#GL_CLAMP,min_f=#GL_NEAREST,mag_f=#GL_NEAREST)
    If imageID <> #Null
      Protected out.GLint
      glGenTextures(1,@out)
          
      glBindTexture(#GL_TEXTURE_2D,out)
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, wrap_s );
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, wrap_t );
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, min_f ); // No pixel averaging
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, mag_f ); // No pixel averaging
      
      Protected w.i = ImageWidth(imageID) 
      Protected h.i = ImageHeight(imageID)
  
      Protected d.i = ImageDepth(imageID)

     
      ;Read pixels
      StartDrawing(ImageOutput(imageID))
      Select DrawingBufferPixelFormat()!#PB_PixelFormat_ReversedY

        Case #PB_PixelFormat_8Bits
          MessageRequester("8BITS","8BITS")
          ;glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_SHORT, DrawingBuffer() )
        Case #PB_PixelFormat_15Bits
          MessageRequester("15BITS","15BITS")
          ;glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_SHORT, DrawingBuffer() )
        Case #PB_PixelFormat_16Bits
          MessageRequester("16BITS","16BITS")
          ;glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_SHORT, DrawingBuffer() )
        Case #PB_PixelFormat_24Bits_RGB
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_BYTE, DrawingBuffer() )
        Case #PB_PixelFormat_24Bits_BGR
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_BGR, #GL_UNSIGNED_BYTE, DrawingBuffer() )
        Case #PB_PixelFormat_32Bits_RGB
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, DrawingBuffer() )
        Case #PB_PixelFormat_32Bits_BGR
          
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_BGRA, #GL_UNSIGNED_BYTE, DrawingBuffer() )
      EndSelect
      
      StopDrawing()
      
      
      ProcedureReturn out
    EndIf
    
  EndProcedure
  
  ;------------------------------------------------------------
  ; Write Image
  ;------------------------------------------------------------
  Procedure GLWriteImage(path.s,width.i,height.i)
     ;Read Frame Buffer
    Protected GLubyte_s.GLubyte
    Define *datas = AllocateMemory(width * height * SizeOf(GLubyte_s)*4)
    glReadPixels(0,0,width,height,#GL_RGBA,#GL_UNSIGNED_BYTE,*datas)
    Protected img = CreateImage(#PB_Any,width,height)
    StartDrawing(ImageOutput(img))
    Protected x,y,offset
    Define.a r,g,b
    For y=0 To height-1
      For x=0 To width-1
        r = PeekA(*datas+offset)
        g = PeekA(*datas+SizeOf(GLubyte_s)+offset)
        b = PeekA(*datas+2*SizeOf(GLubyte_s)+offset)
        Plot(x,height-y-1,RGB(r,g,b))
        offset + 4*SizeOf(GLubyte_s)
      Next x
    Next y
    StopDrawing()
    
    UsePNGImageEncoder()
    Protected result = SaveImage(img,path,#PB_ImagePlugin_PNG)
    If result = 0
      Debug "[GL_WriteImage] Fail to write image to disk!!"
    EndIf
    
    FreeImage(img)
    FreeMemory(*datas)
  EndProcedure
  

  ;  Transform Position Array
  ; ----------------------------------------------------------------------------
  Procedure TransformPositionArray(*io.CArray::CArrayV3F32,*points.CArray::CArrayV3F32,*m.m4f32)
    Protected i
    Protected nb = CArray::GetCount(*points)
    Protected v.v3f32
    CArray::SetCount(*io,nb)
    Protected *v.v3f32
    
    For i=0 To nb-1
      *v = CArray::GetValue(*points,i)
      Vector3::MulByMatrix4(v,*v,*m)
      CArray::SetValue(*io,i,@v)
    Next
  EndProcedure
  
  ;  Transform Position Array In Place
  ; ----------------------------------------------------------------------------
  Procedure TransformPositionArrayInPlace(*points.CArray::CArrayV3F32,*m.m4f32)
    Protected i
    Protected nb = CArray::GetCount(*points)
    Protected *v.v3f32
    For i=0 To nb-1
      *v = CArray::GetValue(*points,i)
      Vector3::MulByMatrix4InPlace(*v,*m)
    Next
  EndProcedure

  ;  Build Circle Section
  ; ----------------------------------------------------------------------------
  Procedure BuildCircleSection(*io.CArray::CArrayV3F32, nbp.i = 12, radius.f = 1.0,start_angle.f = 0.0,end_angle.f = 360.0)
  
    Protected q.q4f32
    Protected axis.v3f32
    Protected r.v3f32
    Vector3::Set(axis,0,1,0)
    Vector3::Set(r,radius,0,0)
    Protected *p.v3f32
    Protected angle.f
    Protected i=0
    Protected st.f
  
    CArray::SetCount(*io,nbp)
    st = (end_angle-start_angle)/(nbp-1)
    For i=0 To nbp-1
      angle = start_angle + i* st
      *p = CArray::GetValue(*io,i)
      Quaternion::SetFromAxisAngle(q,axis,Radian(angle))
      Vector3::MulByQuaternion(*p,r,q)
      CArray::SetValue(*io,i,*p)
    Next
  
  EndProcedure
  ;}
  
  ; ----------------------------------------------------------------------------
  ;  Build Matrix Array
  ; ----------------------------------------------------------------------------
  ;{
  Procedure BuildMatrixArray(*io.CArray::CArrayM4F32,*a.v3f32,*b.v3f32,*c.v3f32,*d.v3f32,*up.v3f32)
    Protected i
    Protected p.v3f32
    Protected o.v3f32
    Protected nb = CArray::GetCount(*io)
    
    Protected st.f = 1.0/ (nb-1)
    Protected u.f
    Protected previous.v3f32
    Protected delta.v3f32
    Protected up.v3f32,side.v3f32
    Protected q.q4f32
    Protected t.Transform::Transform_t
    
    
    Vector3::SetFromOther(previous,*a)
    Vector3::SetFromOther(up,*up)
    
    For i=0 To nb-1
      u = i* st
      Vector3::BezierInterpolate(p,*a,*b,*c,*d,u)
  
      ;Orientation
      If i>0
        Vector3::Sub(delta,p,previous)
        Vector3::NormalizeInPlace(delta)
        Vector3::Cross(side,*up,delta)
        Vector3::Cross(up,delta,side)
        Vector3::NormalizeInPlace(up)
        Quaternion::LookAt(t\t\rot,delta,up, #False)
        Vector3::SetFromOther(*up,up)
      EndIf
      
      ; Scale
      ;     Define r.f = 1 - i*st
      Define r.f = 1+Random(10)*0.01
      Vector3::Set(t\t\scl,r,r,r)
     
      ;Position
      Vector3::SetFromOther(t\t\pos,p)
      Transform::UpdateMatrixFromSRT(@t)
      CArray::SetValue(*io,i,t\m)
      
      If i=1
        Matrix4::SetTranslation(t\m,@previous)
        CArray::SetValue(*io,0,t\m)
      EndIf
      Vector3::SetFromOther(previous,p)
      
    Next
   
  
  EndProcedure
  ;}
  
  ;-------------------------------------------------------------------
  ; Rotate Vector
  ;-------------------------------------------------------------------
  ;{
  Procedure RotateVector(*v.v3f32,*q.q4f32,*io.v3f32)
    Protected len.f = Vector3::Length(*v)
    Protected vn.v3f32
    Protected q2.q4f32
    
    Vector3::Normalize(vn,*v)
    Quaternion::Conjugate(q2,*q)
    
    Protected vecQuat.q4f32, resQuat.q4f32
    
    Quaternion::Set(vecQuat,vn\x,vn\y,vn\z,1.0)
    Quaternion::Multiply(resQuat,vecQuat,q2)
    Quaternion::Multiply(resQuat,*q,resQuat)
    
    Vector3::Set(*io,resQuat\x,resQuat\y,resQuat\z)
    Vector3::SetLength(*io,len)
  EndProcedure
  ;}
  
  ;-------------------------------------------------------------------
  ; Direction To Rotation
  ;-------------------------------------------------------------------
  ;{
  Procedure DirectionToRotation(*io.m3f32,*dir.v3f32,*up.v3f32=#Null)
    If *up=#Null
      Define up.v3f32
      Vector3::Set(up,0,1,0)
      *up = @up
    EndIf
    
    Define.v3f32 xaxis, yaxis, zaxis
    Vector3::Normalize(zaxis,*dir)
    Vector3::Cross(xaxis,*up,zaxis)
    Vector3::NormalizeInPlace(xaxis)
    
    Vector3::Cross(yaxis,zaxis,xaxis)
    Vector3::NormalizeInPlace(yaxis)
    
    *io\v[0] = xaxis\x
    *io\v[3] = yaxis\x
    *io\v[6] = zaxis\x
    
    *io\v[1] = xaxis\y
    *io\v[4] = yaxis\y
    *io\v[7] = zaxis\y
    
    *io\v[2] = -xaxis\z
    *io\v[5] = -yaxis\z
    *io\v[8] = -zaxis\z
    
  EndProcedure
  ;}
  
  ; Closest Point On Triangle
  ;-------------------------------------------------------------------
  Procedure ClosestPointOnTriangle(*io.v3f32,*a.v3f32,*b.v3f32,*c.v3f32,*p.v3f32)
    Define.v3f32 e0,e1,v
    Vector3::Sub(e0,*b,*a)
    Vector3::Sub(e1,*c,*a)
    Vector3::Sub(v,*a,*p)
    
    Define.d a,b,c,d,e
    a = Vector3::Dot(e0,e0)
    b = Vector3::Dot(e0,e1)
    c = Vector3::Dot(e1,e1)
    d = Vector3::Dot(e0,v)
    e = Vector3::Dot(e1,v)
    
    Define det.d = a*c - b*b
    Define s.d = b*e - c*d
    Define t.d = b*d - a*e
    
    If (s+t)<det
      If s<0
        If t<0
          If d<0
            s = -d/a
            CLAMP(s,0,1)
            t = 0
          Else
            s = 0
            t = -e/c
            CLAMP(t,0,1)
          EndIf
        Else
          s = 0
          t = -e/c
          CLAMP(t,0,1)
        EndIf
      ElseIf t<0
        s = -d/a
        CLAMP(s,0,1)
        t = 0
      Else
        Define invDet.d = 1/det
        s * invDet
        t * invDet
      EndIf
    Else
      Define.d numer,denom
      If(s<0)
        Define tmp0.f = b+d
        Define tmp1.f = c+e
        If tmp1>tmp0
          numer = tmp1-tmp0
          denom = a-2*b+c
          s = numer/denom
          CLAMP(s,0,1)
          t=1-s
        Else
          t = -e/c
          CLAMP(t,0,1)
          s=0
        EndIf
      ElseIf t<0
        If (a+d)>(b+e)
          numer = c+e-b-d
          denom = a-2*b+c
          s = numer/denom
          CLAMP(s,0,1)
          t = 1-s
        Else
          s = -e/c
          CLAMP(s,0,1)
          t=0
        EndIf
      Else
        numer = c+e-b-d
        denom = a-2*b+c
        s = numer/denom
        CLAMP(s,0,1)
        t = 1-s
      EndIf
    EndIf
    Define.v3f32 se0, te1
    Vector3::Scale(se0,e0,s)
    Vector3::Scale(te1,e1,t)
    Vector3::Add(*io,*a,se0)
    Vector3::AddInPlace(*io,te1)
      
  EndProcedure
  ;}

;   ;-----------------------------------------------------
;   ; Sample Geometry
;   ;-----------------------------------------------------
;   ;{
;   Procedure SampleGeometry( *geom.Geometry::Geometry_t,*attr.CArray::CArrayPtr, nb.i,seed)
; 
;     Protected *m.Geometry::PolymeshGeometry_t = *geom
;     
;     If Not nb = CArray::GetCount(*attr)
;       CArray::SetCount(*attr,nb)
;     EndIf
;    
;     Protected i
;     Protected tid
;     Define.v3f32 *a,*b,*c
;     Define.f u,v
;     Define.v3f32 p,sum,scl
;     Define color.c4f32
;     Define s.f
;     Define a,b,c
;     Define.c4f32 *ca,*cb,*cc
;     Define uvw.v3f32
;     
;     RandomSeed(seed)
;     For i=0 To nb-1
;       tid = Random(*m\nbtriangles-1)
;       a = CArray::GetValueL(*m\a_triangleindices,tid*3)
;       b = CArray::GetValueL(*m\a_triangleindices,tid*3+1)
;       c = CArray::GetValueL(*m\a_triangleindices,tid*3+2)
;       
;       *a = CArray::GetValue(*m\a_positions,a)
;       *b = CArray::GetValue(*m\a_positions,b)
;       *c = CArray::GetValue(*m\a_positions,c)
;       
;       
;       u = Random(1000)*0.001
;       v = Random(1000)*0.001
;       If u+v>1
;         u = 1-u
;         v = 1-v
;       EndIf
;       Vector3::Set(sum,0,0,0)
;       Vector3::Scale(@p,*a,u)
;       Vector3::AddInPlace(@sum,@p)
;       Vector3::Scale(@p, *b,v)
;       Vector3::AddInPlace(@sum,@p)
;       Vector3::Scale(@p, *c,1-(u+v))
;       Vector3::AddInPlace(@sum,@p)
;       
;       s = 1;Random(10)*0.1
;       Vector3::Set(scl,s,s,s)
;       
;       Protected *loc.Geometry::Location_t = Location::New()
;       *loc\u = u
;       *loc\v = v
;       *loc\tid = tid
;       Vector3::SetFromOther(*loc\p,@sum)
;       
;       
;       *a = CArray::GetValue(*m\a_pointnormals,a)
;       *b = CArray::GetValue(*m\a_pointnormals,b)
;       *c = CArray::GetValue(*m\a_pointnormals,c)
;        Vector3::Set(sum,0,0,0)
;       Vector3::Scale(@p,*a,u)
;       Vector3::AddInPlace(@sum,@p)
;       Vector3::Scale(@p, *b,v)
;       Vector3::AddInPlace(@sum,@p)
;       Vector3::Scale(@p, *c,1-(u+v))
;       Vector3::AddInPlace(@sum,@p)
;       
;       Vector3::SetFromOther(*loc\n,@sum)
;       
;       *ca = CArray::GetValue(*m\a_colors,tid*3)
;       *cb = CArray::GetValue(*m\a_colors,tid*3+1)
;       *cb = CArray::GetValue(*m\a_colors,tid*3+1)
;       ;     Vector4_Set(@color,*ca\r,*ca\g,*ca\b,*ca\a)
;       Vector4::Set(@color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1.0)
;       ;*pc\a_color\SetValue(i,@color)
;       Color::SetFromOther(*loc\c,@color)
;       
;       ; flipper tmp datas
;       Vector3::Set(uvw,u,v,tid)
;       
;       
;     Next
;     
;   EndProcedure


EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 333
; FirstLine = 323
; Folding = ---
; EnableXP
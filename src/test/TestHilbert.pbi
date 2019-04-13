; -----------------------------------------------------------------------------------
; Test Hilbert Curve
; -----------------------------------------------------------------------------------
XIncludeFile "../core/Application.pbi"
XIncludeFile "../core/Morton.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../objects/Polygonizer.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit


Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t
Global *curve.Curve::Curve_t

Global width.i, height.i
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
; Global *polygonizer.Polygonizer::Grid_t
; Global *grid.Geometry::Grid3D_t

DeclareModule Hilbert
  UseModule Math
  #EMAX = 31  ;EXPOSANT maximal en 32 bit (à 31 on touche le bit de signe, à 32 on sort)
  #OCT_MASQ  = ((1<<#EMAX)-1)

  Structure I2F_t
    StructureUnion
      i.i
      f.f
    EndStructureUnion
  EndStructure
  
  Structure Cell_t
    isleaf.b
    morton.i
    extand.v3f32
    pos.v3f32
    *children
  EndStructure
  
  Structure Grid_t Extends Cell_t
    box.Geometry::Box_t
    Map *cells.Cell_t(0)  
  EndStructure
  
  Declare New(*box.Geometry::Box_t, n.i)
  Declare Split(*grid.Grid_t, *cell.Cell_t, n)
  Declare GetCellFromPoint(*grid.Grid_t, posx.l, posy.l, posz.l, e.i)
  Declare GetCellFromKey(*grid.Grid_t, key.i, e.i)
  Declare MapWorldSpaceToHilbertSpace(*grid.Hilbert::Grid_t, *v.v3f32, *p.Morton::Point3D_t)
  Declare MapHilbertSpaceToWorldSpace(*grid.Hilbert::Grid_t,  *p.Morton::Point3D_t, *v.v3f32)
  Declare.f MapHilbertSpaceTo1DSpace(*grid.Hilbert::Grid_t,  *p.Morton::Point3D_t)
EndDeclareModule

Module Hilbert
  UseModule Math
  Procedure New(*box.Geometry::Box_t, n.i)
    Protected  *grid.Grid_t = AllocateMemory(SizeOf(Grid_t))
    InitializeStructure(*grid, Grid_t)
    
    Vector3::SetFromOther(*grid\extand, *box\extend)
    Vector3::SetFromOther(*grid\pos, *box\origin)
    Vector3::Echo(*grid\pos, "ORIGIN")
    Vector3::Echo(*grid\extand, "EXTAND")
    Split(*grid, *grid, n)
    
    ProcedureReturn *grid
  EndProcedure
  
  
;   Procedure DeleteCell(*cell.Cell_t)
;     Protected i
;     For i=0 To 7
;       If *cell\children[i]
;         DeleteCell(*cell\children[i])
;       EndIf
;     Next
;     
;     ClearStructure(*cell, Cell_t)
;     FreeMemory(*cell)
;   EndProcedure
  
  Procedure OffsetCell(*cell.Cell_t, *pos.v3f32, *extand.v3f32, index.i)
    *cell\extand\x = *extand\x * 0.5
    *cell\extand\y = *extand\y * 0.5
    *cell\extand\z = *extand\z * 0.5
    
    Select index
      Case 0:
        *cell\pos\x = *pos\x - *cell\extand\x
        *cell\pos\y = *pos\y - *cell\extand\y
        *cell\pos\z = *pos\z - *cell\extand\z
      Case 1:
        *cell\pos\x = *pos\x + *cell\extand\x
        *cell\pos\y = *pos\y - *cell\extand\y
        *cell\pos\z = *pos\z - *cell\extand\z
      Case 2:
        *cell\pos\x = *pos\x + *cell\extand\x
        *cell\pos\y = *pos\y - *cell\extand\y
        *cell\pos\z = *pos\z + *cell\extand\z
      Case 3:
        *cell\pos\x = *pos\x - *cell\extand\x
        *cell\pos\y = *pos\y - *cell\extand\y
        *cell\pos\z = *pos\z + *cell\extand\z
      Case 4:
        *cell\pos\x = *pos\x - *cell\extand\x
        *cell\pos\y = *pos\y + *cell\extand\y
        *cell\pos\z = *pos\z - *cell\extand\z
      Case 5:
        *cell\pos\x = *pos\x + *cell\extand\x
        *cell\pos\y = *pos\y + *cell\extand\y
        *cell\pos\z = *pos\z - *cell\extand\z
      Case 6:
        *cell\pos\x = *pos\x + *cell\extand\x
        *cell\pos\y = *pos\y + *cell\extand\y
        *cell\pos\z = *pos\z + *cell\extand\z
      Case 7:
        *cell\pos\x = *pos\x - *cell\extand\x
        *cell\pos\y = *pos\y + *cell\extand\y
        *cell\pos\z = *pos\z + *cell\extand\z
    EndSelect

  EndProcedure
  
  ; Map world space to hilbert space
  Procedure MapWorldSpaceToHilbertSpace(*grid.Hilbert::Grid_t, *v.v3f32, *p.Morton::Point3D_t)

    Protected x.f = (*v\x - (*grid\pos\x - *grid\extand\x)) / (*grid\extand\x * 2.0)    
    Protected y.f = (*v\y - (*grid\pos\y - *grid\extand\y)) / (*grid\extand\y * 2.0) 
    Protected z.f = (*v\z - (*grid\pos\z - *grid\extand\z)) / (*grid\extand\z * 2.0) 
    Protected ml = 65535
    *p\x = x * ml
    *p\y = y * ml
    *p\z = z * ml
  EndProcedure
    
  ; Map hilbert space To world space
  Procedure MapHilbertSpaceToWorldSpace(*grid.Hilbert::Grid_t,  *p.Morton::Point3D_t, *v.v3f32)
    Protected ml.f = 1.0 / 65535.0
    *v\x = *p\x * ml * 2 * *grid\extand\x + (*grid\pos\x - *grid\extand\x)
    *v\y = *p\y * ml * 2 * *grid\extand\y + (*grid\pos\y - *grid\extand\y)
    *v\z = *p\z * ml * 2 * *grid\extand\z + (*grid\pos\z - *grid\extand\z)
  EndProcedure
  
  ; Map hilbert space To 1D space
  Procedure.f MapHilbertSpaceTo1DSpace(*grid.Hilbert::Grid_t,  *p.Morton::Point3D_t)
    ProcedureReturn *grid\morton / 2147483647.0 
  EndProcedure
  
  ; Recursive Split 
  Procedure Split(*grid.Grid_t, *cell.Cell_t, n.i)
    If n>0
      Protected i
      Protected p.Morton::Point3D_t
      *cell\isleaf = #False
      *cell\children = AllocateMemory(8 * SizeOf(Cell_t))
      Protected *child.Cell_t
      Protected morton.s = Str(*cell\morton)
      If FindMapElement(*grid\cells(), morton)
        DeleteMapElement(*grid\cells(), morton)
      EndIf
      
      For i=0 To 7
        *child = *cell\children + i * SizeOf(Cell_t)
        InitializeStructure(*child, Cell_t)
        OffsetCell(*child, *cell\pos, *cell\extand, i)
        MapWorldSpaceToHilbertSpace(*grid, *child\pos, @p)
        *child\morton = Morton::Encode3D(@p)
        AddMapElement(*grid\cells(), Str(*child\morton))
        *grid\cells() = *child
        Split(*grid, *child, n-1)
      Next 
    Else
      *cell\isleaf = #True
    EndIf
  EndProcedure
  
  Procedure AddCell(*cell, x.i, y.i, z.i, morton.i)
    
  EndProcedure
  
  Procedure GetCellFromPoint(*grid.Grid_t, pox.l, posy.l, posz.l, e.i)
;     Protected e0.i=30
;     Protected childIndex.i
;     Protected search.b = #True
;     Protected *cell.Cell_t = *grid
;     
;     ; tant qu'il y a des enfants et que la profondeur n'est pas atteinte
;     While(search And e0 > e)
;       e0-1;// on descend d'un niveau dans la profondeur de l'arbre
;       childIndex = ((posx >> e0) & 1) + (((posy >> e0) & 1) << 1) +  (((posz >> e0) & 1) << 2) 
;       If *cell\children[childIndex]
;         *cell = *cell\children[childIndex]
;       Else 
;         search = #False
;       EndIf
;     Wend
;     ProcedureReturn *child
  EndProcedure
  
  Procedure GetCellFromKey(*grid.Grid_t, key.i, e.i)
;     Protected e0=30 ; Conventionnellement, dans ce code, la largeur du cube racine est de 2^30
;     Protected *cell.Cell_t = *grid
;     Protected *child.Cell_t
;     Protected search.b = #True
;     While search And e0 > e
;       e0 - 1
;       *child = *cell\children[(key >> 3*e0) & 7]
;       If *child
;         *cell = *child
;       Else
;         search = #False
;       EndIf
;     Wend
;     
;     ProcedureReturn *cell
    
  EndProcedure
  
EndModule

; //---------------------------------------------------------------------------
; #ifndef _Hilbert_vector_h
; #define _Hilbert_vector_h
; //---------------------------------------------------------------------------
; #include "list.h"
; //---------------------------------------------------------------------------
; void Hilbert2D(List<double> &pnt,double x,double y,double z,double a,int n)
;     {
;     int i,j,m;
;     double x0,y0,x1,y1,q;
;     For (m=4*3,i=1,j=2;j<=n;j++,i+=i+1) m*=4; a/=i; // m = needed size of pnt[]
;     pnt.num=0;
;     // init generator
;           pnt.add(x); pnt.add(y); pnt.add(z);
;     y+=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     x+=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     y-=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     x0=x-0.5*a; // center of generator
;     y0=y+0.5*a;
;     // iterative subdivision
;     For (j=2;j<=n;j++)
;         {
;         // mirror/rotate 2 qudrants
;         x1=x0; y1=y0; m=pnt.num;
;         For (i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]   ;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             q=x; x=+y; y=-q;    // z+
;             pnt.dat[i+0]=(x1+x);
;             pnt.dat[i+1]=(y1-y);
;             pnt.dat[i+2]=(   z);
;             }
;         For (y1+=2.0*a,i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]   ;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             q=x; x=-y; y=+q;    // z-
;             pnt.add(x1+x);
;             pnt.add(y1+y);
;             pnt.add(   z);
;             }
;         // mirror the rest
;         x0+=a; y0+=a; m=pnt.num;
;         For (i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]   ;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             pnt.add(x0-x);
;             pnt.add(y0+y);
;             pnt.add(   z);
;             }
;         a*=2.0;
;         }
; /*
;         // rotations
;         q=x; x=+y; y=-q;    // z+
;         q=x; x=-y; y=+q;    // z-
; */
;     }
; //---------------------------------------------------------------------------
; void Hilbert3D(List<double> &pnt,double x,double y,double z,double a,int n)
;     {
;     int i,j,m;
;     double x0,y0,z0,x1,y1,z1,q;
;     For (m=8*3,i=1,j=2;j<=n;j++,i+=i+1) m*=8; a/=i; // m = needed size of pnt[]
;     pnt.num=0;
;     // init generator
;           pnt.add(x); pnt.add(y); pnt.add(z);
;     z-=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     x+=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     z+=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     y+=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     z-=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     x-=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     z+=a; pnt.add(x); pnt.add(y); pnt.add(z);
;     x0=x+0.5*a; // center of generator
;     y0=y-0.5*a;
;     z0=z-0.5*a;
;     // iterative subdivision
;     For (j=2;j<=n;j++)
;         {
;         // mirror/rotate qudrants
;         x1=x0; y1=y0; z1=z0; m=pnt.num;
;         For (i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]-z0;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             q=y; y=-z; z=+q;    // x-
;             pnt.dat[i+0]=(x1+x);
;             pnt.dat[i+1]=(y1+y);
;             pnt.dat[i+2]=(z1-z);
;             }
;         For (z1-=2.0*a,i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]-z0;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             q=z; z=+x; x=-q;    // y+
;             q=y; y=+z; z=-q;    // x+
;             pnt.add(x1-x);
;             pnt.add(y1+y);
;             pnt.add(z1+z);
;             }
;         For (x1+=2.0*a,i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]-z0;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             q=y; y=+z; z=-q;    // x+
;             pnt.add(x1+x);
;             pnt.add(y1+y);
;             pnt.add(z1+z);
;             }
;         For (z1+=2.0*a,i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]-z0;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             q=z; z=+x; x=-q;    // y+
;             pnt.add(x1-x);
;             pnt.add(y1-y);
;             pnt.add(z1+z);
;             }
;         // mirror octants
;         x0+=a; y0+=a; z0-=a; m=pnt.num;
;         For (i=m;i>=3;)
;             {
;             i--; z=pnt.dat[i]-z0;
;             i--; y=pnt.dat[i]-y0;
;             i--; x=pnt.dat[i]-x0;
;             pnt.add(x0+x);
;             pnt.add(y0-y);
;             pnt.add(z0+z);
;             }
;         a*=2.0;
;         }
; /*
;         // rotations
;         q=z; z=+x; x=-q;    // y+
;         q=z; z=-x; x=+q;    // y-
;         q=y; y=+z; z=-q;    // x+
;         q=y; y=-z; z=+q;    // x-
;         q=x; x=+y; y=-q;    // z+
;         q=x; x=-y; y=+q;    // z-
; */
;     }
; //---------------------------------------------------------------------------
; void pnt_draw2(List<double> &pnt)   // piecewise linear
;     {
;     int i;
;     glBegin(GL_LINE_STRIP);
;     For (i=0;i<pnt.num;i+=3) glVertex3dv(pnt.dat+i);
;     glEnd();
;     }
; //---------------------------------------------------------------------------
; void pnt_draw4(List<double> &pnt)   // piecewise cubic
;     {
;     int i,j;
;     double  d1,d2,t,tt,ttt,*p0,*p1,*p2,*p3,a0[3],a1[3],a2[3],a3[3],p[3];
;     glBegin(GL_LINE_STRIP);
;     For (i=-3;i<pnt.num;i+=3)
;         {
;         j=i-3; if (j>pnt.num-3) j=pnt.num-3; if (j<0) j=0; p0=pnt.dat+j;
;         j=i  ; if (j>pnt.num-3) j=pnt.num-3; if (j<0) j=0; p1=pnt.dat+j;
;         j=i+3; if (j>pnt.num-3) j=pnt.num-3; if (j<0) j=0; p2=pnt.dat+j;
;         j=i+6; if (j>pnt.num-3) j=pnt.num-3; if (j<0) j=0; p3=pnt.dat+j;
;         For (j=0;j<3;j++)
;             {
;             d1=0.5*(p2[j]-p0[j]);
;             d2=0.5*(p3[j]-p1[j]);
;             a0[j]=p1[j];
;             a1[j]=d1;
;             a2[j]=(3.0*(p2[j]-p1[j]))-(2.0*d1)-d2;
;             a3[j]=d1+d2+(2.0*(-p2[j]+p1[j]));
;             }
;         For (t=0.0;t<=1.0;t+=0.1)   // single curve patch/segment
;             {
;             tt=t*t;
;             ttt=tt*t;
;             For (j=0;j<3;j++) p[j]=a0[j]+(a1[j]*t)+(a2[j]*tt)+(a3[j]*ttt);
;             glVertex3dv(p);
;             }
;         }
;     glEnd();
;     }
; //---------------------------------------------------------------------------
; #endif
; //---------------------------------------------------------------------------
Procedure MapWorldPositionToScreenSpace(*view.m4f32, *proj.m4f32, width.i, height.i, *w.v3f32, *s.v2f32)
  Protected w2s.v3f32
  Vector3::MulByMatrix4 (@w2s, *w, *view)
  Vector3::MulByMatrix4InPlace(@w2s, *proj)
  *s\x = width * (w2s\x + 1.0)/2.0
  *s\y = height * (1.0 - ((w2s\y + 1.0) / 2.0))
EndProcedure

Procedure DrawPolygonizer(*polygonizer.Polygonizer::Grid_t, ss.f, ratio.f)
  Protected numPoints = ArraySize(*polygonizer\points())
  
  Protected world.v3f32
  Protected screen.v2f32
  
  Protected *view.m4f32 = Layer::GetViewMatrix(*layer)
  Protected *proj.m4f32 = Layer::GetProjectionMatrix(*layer)
  Protected i
  
  For i=0 To numPoints -1
    Vector3::Set(@world, *polygonizer\points(i)\p[0], *polygonizer\points(i)\p[1], *polygonizer\points(i)\p[2])
    MapWorldPositionToScreenSpace(*view, *proj, *viewport\width, *viewport\height, @world, @screen)
    FTGL::Draw(*app\context\writer,"z",(screen\x * 2)/width - 1,1 - (screen\y * 2) /height,ss,ss*ratio)
  Next
  
EndProcedure


; -----------------------------------------------------------------------------------------
; Draw
; -----------------------------------------------------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  ViewportUI::SetContext(*viewport)

  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer, *app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Testing Hilbert Curve",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  glDisable(#GL_BLEND)
  
  ViewportUI::FlipBuffer(*viewport)

EndProcedure

Procedure DrawCells(*grid.Hilbert::Grid_t)
  Protected p1.Morton::Point3D_t, p2.Morton::Point3D_t
  Protected *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  Protected *colors.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
  CArray::SetCount(*positions, MapSize(*grid\cells())*2)
  CArray::SetCount(*colors, MapSize(*grid\cells())*2)
  Protected index = 0
  Protected u.f
  Protected c.c4f32
  Protected numCells.i = MapSize(*grid\cells())
  Protected inc_c.f = 1.0 / numCells
  ForEach *grid\cells()
    Morton::Decode3D(*grid\cells()\morton, @p2)
    ;     u = Hilbert::MapHilbertSpaceTo1DSpace(*grid\cells(), @p2)  
    u = index * inc_c
    Color::Set(@c, u , 1-u, 0, 1.0)
    
    If index > 0
      CArray::SetValue(*colors, index*2, c)
      CArray::SetValue(*colors, index*2+1, c)
      Hilbert::MapHilbertSpaceToWorldSpace(*grid, @p1, CArray::GetValue(*positions, index*2))
      Hilbert::MapHilbertSpaceToWorldSpace(*grid, @p2, CArray::GetValue(*positions, index*2+1))
    EndIf
    p1\x = p2\x
    p1\y = p2\y
    p1\z = p2\z
    index + 1
  Next
  
  Protected *line.Drawer::Item_t = Drawer::AddColoredLines(*drawer, *positions, *colors)
  Drawer::SetSize(*line, 2)

  CArray::Delete(*positions)
  CArray::Delete(*colors)
EndProcedure

Procedure DrawCell(*cell.Hilbert::Cell_t)
  If *cell
    If *cell\isleaf
      Define m.Math::m4f32
      Define s.Math::v3f32
      Vector3::Scale(@s, *cell\extand, 1.9)
      Matrix4::SetIdentity(@m)
      Define c.Math::c4f32
      Matrix4::SetScale(@m, @s)
      Matrix4::SetTranslation(@m, *cell\pos)
      Color::Randomize(@c)
      Protected *box.Drawer::Item_t = Drawer::AddBox(*drawer, @m)
      Drawer::SetSize(*box, 3)
      Drawer::SetColor(*box, @c)
    EndIf
    
    If *cell\children
      Protected i
      Protected *child.Hilbert::Cell_t
      For i = 0 To 7
        *child = *cell\children + i * SizeOf(Hilbert::Cell_t)
        If *child
          DrawCell(*child)
        EndIf
      Next
    EndIf
  EndIf

EndProcedure

; Main
Globals::Init()
FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   width = 800
   height = 600
   *app = Application::New("Test Hilbert Curve",width, height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
 
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
    
  *s_wireframe = *app\context\shaders("wireframe")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm
  
  *drawer.Drawer::Drawer_t = Drawer::New("Hilbert")
  
  Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_BUNNY)
  Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  Object3D::SetShader(*mesh,*s_polymesh)
  Object3D::SetShader(*drawer,*s_wireframe)
  Object3D::AddChild(*root, *mesh)
  Object3D::AddChild(*root, *drawer)
  
  Geometry::ComputeBoundingBox(*geom)
  Define box.Geometry::Box_t
  Vector3::Set(box\extend, 4, 4, 4)
  Define m.Math::m4f32
  Matrix4::SetIdentity(@m)
  Define s.v3f32
  Vector3::Scale(@s, @box\extend, 2)
  Matrix4::SetScale(@m, @s)
  Matrix4::SetTranslation(@m, @box\origin)
  
  Drawer::AddBox(*drawer, @m)
  Define *grid.Hilbert::Grid_t = Hilbert::New(@box,3)
  DrawCells(*grid)
  
  Scene::AddModel(Scene::*current_scene, *root)
  Scene::Setup(Scene::*current_scene, *app\context)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 17
; FirstLine = 2
; Folding = ---
; EnableXP
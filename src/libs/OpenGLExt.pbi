XIncludeFile "OpenGL.pbi"
XIncludeFile "GLFW.pbi"
DeclareModule OpenGLExt
  UseModule OpenGL
  UseModule GLFW
  ; ; ============================================================================
  ; ;  OpenGL Extensions Prototypes
  ; ; ============================================================================
  ; ;{
  ;   Extension Loading is done via GLFW library
  
  ; Use these for enable/disable loading of extensions
  #ENABLEGL1_0 = #True
  #ENABLEGL1_1 = #True
  #ENABLEGL1_2 = #True
  #ENABLEGL1_3 = #True
  #ENABLEGL1_4 = #True
  #ENABLEGL1_5 = #True
  #ENABLEGL2_0 = #True
  #ENABLEGL2_1 = #True
  #ENABLEGL3_0 = #True
  #ENABLEGL3_1 = #True
  #ENABLEGL3_2 = #True
  #ENABLEGL3_3 = #True
  #ENABLEGLMISC = #True
  
  ; ; Load GL Extensions
  ; CompilerIf Not Defined(RAA_USE_GLFW,#PB_Constant)
  ;   #RAA_USE_GLFW = #False
  ; CompilerEndIf
 
  CompilerIf #USE_GLFW
    CompilerIf #GLFW_GETPROCADDRESS_DEBUG
      Macro  setGLEXT(var, extname)
      var = glfwGetProcAddress(extname)
        If Not var
          Debug(extname+": Not found !!!")
        Else
          Debug(extname+": 0x"+Hex(var))
        EndIf
    EndMacro
    CompilerElse
      Macro  setGLEXT(var, extname)
        var = glfwGetProcAddress(extname)
      EndMacro
    CompilerEndIf
  CompilerElse
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux
        ImportC "-lGL"
          glXGetProcAddress(s.p-ascii) As "glXGetProcAddress"
        EndImport 
        
        Macro setGLEXT(var, extname)
          var = glXGetProcAddress(extname)
        EndMacro
        
      CompilerCase #PB_OS_Windows
        ImportC "opengl32.lib"
          wglGetProcAddress(s.p-ascii) As "wglGetProcAddress"

        EndImport 
        
        Macro setGLEXT(var, extname)
          var = wglGetProcAddress(extname)
        EndMacro
        
      CompilerCase #PB_OS_MacOS
        Macro setGLEXT(var, extname)
          var = dlsym_(#RTLD_DEFAULT,extname)
          If Not var
            Debug(extname+": Not found !!!")
          Else
            Debug(extname+": 0x"+Hex(var))
          EndIf
        EndMacro
        
    CompilerEndSelect
  CompilerEndIf
  
    
    
    
  ;- OpenGL 1.2
  CompilerIf #ENABLEGL1_2
    Prototype PFNGLBLENDCOLORPROC ( red.f, green.f, blue.f, alpha.f)
    Prototype PFNGLBLENDEQUATIONPROC ( mode.l )
    Prototype PFNGLDRAWRANGEELEMENTSPROC ( mode.l, start.i, End_.i, count.i, type.l, indices.l)
    Prototype PFNGLTEXIMAGE3DPROC ( target.l, level.i, internalformat.i, width.i, height.i, depth.i, border.i, format.l, type.l, pixels.l)
    Prototype PFNGLTEXSUBIMAGE3DPROC ( target.l, level.i, xoffset.i, yoffset.i, zoffset.i, width.i, height.i, depth.i, format.l, type.l, pixels.l)
    Prototype PFNGLCOPYTEXSUBIMAGE3DPROC ( target.l, level.i, xoffset.i, yoffset.i, zoffset.i, x.i, y.i, width.i, height.i )
  CompilerEndIf
    
  ;- OpenGL 1.3
  CompilerIf #ENABLEGL1_3
    Prototype PFNGLACTIVETEXTUREPROC ( texture.l )
    Prototype PFNGLSAMPLECOVERAGEPROC ( value.f, invert.b )
    Prototype PFNGLCOMPRESSEDTEXIMAGE3DPROC ( target.l, level.i, internalformat.l, width.i, height.i, depth.i, border.i, imageSize.i, Data_.l )
    Prototype PFNGLCOMPRESSEDTEXIMAGE2DPROC ( target.l, level.i, internalformat.l, width.i, height.i, border.i, imageSize.i, Data_.l )
    Prototype PFNGLCOMPRESSEDTEXIMAGE1DPROC ( target.l, level.i, internalformat.l, width.i, border.i, imageSize.i, Data_.l )
    Prototype PFNGLCOMPRESSEDTEXSUBIMAGE3DPROC ( target.l, level.i, xoffset.i, yoffset.i, zoffset.i, width.i, height.i, depth.i, format.l, imageSize.i, Data_.l )
    Prototype PFNGLCOMPRESSEDTEXSUBIMAGE2DPROC ( target.l, level.i, xoffset.i, yoffset.i, width.i, height.i, format.l, imageSize.i, Data_.l )
    Prototype PFNGLCOMPRESSEDTEXSUBIMAGE1DPROC ( target.l, level.i, xoffset.i, width.i, format.l, imageSize.i, Data_.l )
    Prototype PFNGLGETCOMPRESSEDTEXIMAGEPROC ( target.l, level.i, img.l)
   
  CompilerEndIf
    
  ;- OpenGL 1.4
  CompilerIf #ENABLEGL1_4
    Prototype PFNGLBLENDFUNCSEPARATEPROC ( sfactorRGB.l, dfactorRGB.l, sfactorAlpha.l, dfactorAlpha.l)
    Prototype PFNGLMULTIDRAWARRAYSPROC ( mode.l, *first, *count, primcount.i)
    Prototype PFNGLMULTIDRAWELEMENTSPROC ( mode.l, *count, type.l, *indices, primcount )
    Prototype PFNGLPOINTPARAMETERFPROC ( pname.l, param.f )
    Prototype PFNGLPOINTPARAMETERFVPROC ( pname.l, *param )
    Prototype PFNGLPOINTPARAMETERIPROC ( pname.l, param.i )
    Prototype PFNGLPOINTPARAMETERIVPROC ( pname.l, *param )
  CompilerEndIf
  
  ;- OpenGL 1.5
  CompilerIf #ENABLEGL1_5
    Prototype PFNGLGENQUERIESPROC (n.i, *ids)
    Prototype PFNGLDELETEQUERIESPROC (n.i,*ids)
    Prototype.b PFNGLISQUERYPROC (id.i)
    Prototype PFNGLBEGINQUERYPROC (target.l, id.i)
    Prototype PFNGLENDQUERYPROC (target.l)
    Prototype PFNGLGETQUERYIVPROC (target.l, pname.l, *params)
    Prototype PFNGLGETQUERYOBJECTIVPROC (id.i, pname.l, *params)
    Prototype PFNGLGETQUERYOBJECTUIVPROC (id.i, pname.l, *params)
    Prototype PFNGLBINDBUFFERPROC (target.l, buffer.i)
    Prototype PFNGLDELETEBUFFERSPROC (n.i, *buffers)
    Prototype PFNGLGENBUFFERSPROC (n.i, *buffers)
    Prototype.b PFNGLISBUFFERPROC (buffer.i)
    Prototype PFNGLBUFFERDATAPROC (target.l, size.i, *Data_, usage.l)
    Prototype PFNGLBUFFERSUBDATAPROC (target.l, offset.i, size.i, *Data_)
    Prototype PFNGLGETBUFFERSUBDATAPROC (target.l, offset.i, size.i, *Data_)
    Prototype PFNGLMAPBUFFERPROC (target.l, access.l)
    Prototype.b PFNGLUNMAPBUFFERPROC (target.l)
    Prototype PFNGLGETBUFFERPARAMETERIVPROC (target.l, pname.l, *params)
    Prototype PFNGLGETBUFFERPOINTERVPROC (target.l, pname.l, *params)
  CompilerEndIf
    
  ;- OpenGL 2.0
    CompilerIf #ENABLEGL2_0
    Prototype PFNGLBLENDEQUATIONSEPARATEPROC ( modeRGB.l, modeAlpha.l )
    Prototype PFNGLDRAWBUFFERSPROC ( n.i, *bufs )
    Prototype PFNGLSTENCILOPSEPARATEPROC ( face.l, sfail.l, dpfail.l, dppass.l )
    Prototype PFNGLSTENCILFUNCSEPARATEPROC ( face.l, func.l, ref.i, mask.i )
    Prototype PFNGLSTENCILMASKSEPARATEPROC ( face.l, mask.i )
    Prototype PFNGLATTACHSHADERPROC ( program.i, shader.i )
    Prototype PFNGLBINDATTRIBLOCATIONPROC ( program.i, index.i, name.p-utf8 )
    Prototype PFNGLCOMPILESHADERPROC ( shader.i )
    Prototype.i PFNGLCREATEPROGRAMPROC ( )
    Prototype.i PFNGLCREATESHADERPROC ( type.l )
    Prototype PFNGLDELETEPROGRAMPROC ( program.i )
    Prototype PFNGLDELETESHADERPROC ( shader.i )
    Prototype PFNGLDETACHSHADERPROC ( program.i, shader.i )
    Prototype PFNGLDISABLEVERTEXATTRIBARRAYPROC ( index.i )
    Prototype PFNGLENABLEVERTEXATTRIBARRAYPROC ( index.i )
    Prototype PFNGLGETACTIVEATTRIBPROC ( program.i, index.i, bufSize.i, *length, *size, *type, *name )
    Prototype PFNGLGETACTIVEUNIFORMPROC ( program.i, index.i, bufSize.i, *length, *size, *type, *name )
    Prototype PFNGLGETATTACHEDSHADERSPROC ( program.i, maxCount.i, *count, *obj )
    Prototype PFNGLGETATTRIBLOCATIONPROC ( program.i, name.p-utf8 )
    Prototype PFNGLGETPROGRAMIVPROC ( program.i, pname.l, *params )
    Prototype PFNGLGETPROGRAMINFOLOGPROC ( program.i, bufSize.i, *length, *infoLog )
    Prototype PFNGLGETSHADERIVPROC ( shader.i, pname.l, *params )
    Prototype PFNGLGETSHADERINFOLOGPROC ( shader.i, bufSize.i, *length, *infoLog )
    Prototype PFNGLGETSHADERSOURCEPROC ( shader.i, bufSize.i, *length, *source )
    Prototype PFNGLGETUNIFORMLOCATIONPROC ( program.i, name.p-utf8 )
    Prototype PFNGLGETUNIFORMFVPROC ( program.i, location.i, *params )
    Prototype PFNGLGETUNIFORMIVPROC ( program.i, location.i, *params )
    Prototype PFNGLGETVERTEXATTRIBDVPROC ( index.i, pname.l, *params )
    Prototype PFNGLGETVERTEXATTRIBFVPROC ( index.i, pname.l, *params )
    Prototype PFNGLGETVERTEXATTRIBIVPROC ( index.i, pname.l, *params )
    Prototype PFNGLGETVERTEXATTRIBPOINTERVPROC ( index.i, pname.l, *pointer )
    Prototype.b PFNGLISPROGRAMPROC ( program.i )
    Prototype.b PFNGLISSHADERPROC ( shader.i )
    Prototype PFNGLLINKPROGRAMPROC ( program.i )
    Prototype PFNGLSHADERSOURCEPROC ( shader.i, count.i, *string, *length )
    Prototype PFNGLUSEPROGRAMPROC ( program.i )
    Prototype PFNGLUNIFORM1FPROC ( location.i, v0.f )
    Prototype PFNGLUNIFORM2FPROC ( location.i, v0.f, v1.f )
    Prototype PFNGLUNIFORM3FPROC ( location.i, v0.f, v1.f, v2.f )
    Prototype PFNGLUNIFORM4FPROC ( location.i, v0.f, v1.f, v2.f, v3.f )
    Prototype PFNGLUNIFORM1IPROC ( location.i, v0.i )
    Prototype PFNGLUNIFORM2IPROC ( location.i, v0.i, v1.i )
    Prototype PFNGLUNIFORM3IPROC ( location.i, v0.i, v1.i, v2.i )
    Prototype PFNGLUNIFORM4IPROC ( location.i, v0.i, v1.i, v2.i, v3.i )
    Prototype PFNGLUNIFORM1FVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM2FVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM3FVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM4FVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM1IVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM2IVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM3IVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM4IVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORMMATRIX2FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLUNIFORMMATRIX3FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLUNIFORMMATRIX4FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLVALIDATEPROGRAMPROC ( program.i )
    Prototype PFNGLVERTEXATTRIB1DPROC ( index.i, x.d )
    Prototype PFNGLVERTEXATTRIB1DVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB1FPROC ( index.i, x.f )
    Prototype PFNGLVERTEXATTRIB1FVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB1SPROC ( index.i, x.w )
    Prototype PFNGLVERTEXATTRIB1SVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB2DPROC ( index.i, x.d, y.d )
    Prototype PFNGLVERTEXATTRIB2DVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB2FPROC ( index.i, x.f, y.f )
    Prototype PFNGLVERTEXATTRIB2FVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB2SPROC ( index.i, x.w, y.w )
    Prototype PFNGLVERTEXATTRIB2SVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB3DPROC ( index.i, x.d, y.d, z.d )
    Prototype PFNGLVERTEXATTRIB3DVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB3FPROC ( index.i, x.f, y.f, z.f )
    Prototype PFNGLVERTEXATTRIB3FVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB3SPROC ( index.i, x.w, y.w, z.w )
    Prototype PFNGLVERTEXATTRIB3SVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4NBVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4NIVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4NSVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4NUBPROC ( index.i, x.b, y.b, z.b, w.b )
    Prototype PFNGLVERTEXATTRIB4NUBVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4NUIVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4NUSVPROC ( index.i, *v)
    Prototype PFNGLVERTEXATTRIB4BVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4DPROC ( index.i, x.d, y.d, z.d, w.d )
    Prototype PFNGLVERTEXATTRIB4DVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4FPROC ( index.i, x.f, y.f, z.f, w.f )
    Prototype PFNGLVERTEXATTRIB4FVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4IVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4SPROC ( index.i, x.w, y.w, z.w, w.w )
    Prototype PFNGLVERTEXATTRIB4SVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4UBVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4UIVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIB4USVPROC ( index.i, *v)
    Prototype PFNGLVERTEXATTRIBPOINTERPROC ( index.i, size.i, type.l, normalized.b, stride.i, *pointer )
    Prototype PFNGLBINDVERTEXARRAYSPROC(array_.i)
    Prototype PFNGLDELETEVERTEXARRAYSPROC( n.i, *arrays )
    Prototype PFNGLGENVERTEXARRAYSPROC( n.i,array_.i)             
    Prototype PFNGLISVERTEXARRAYPROC( array_.i )
    Prototype PFNGLDRAWARRAYSPROC(mode.i,firts.i,count.i)
      
    
  CompilerEndIf
  
  ;- OpenGL 2.1
  CompilerIf #ENABLEGL2_1
    Prototype PFNGLUNIFORMMATRIX2X3FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLUNIFORMMATRIX3X2FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLUNIFORMMATRIX2X4FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLUNIFORMMATRIX4X2FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLUNIFORMMATRIX3X4FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLUNIFORMMATRIX4X3FVPROC ( location.i, count.i, transpose.b, *value )
    Prototype PFNGLDISABLECLIENTSTATEPROC ( enum.i )
  CompilerEndIf
    
  ;- OpenGL 3.0
  CompilerIf #ENABLEGL3_0
    Prototype PFNGLCOLORMASKIPROC ( index.i, r.b, g.b, b.b, a.b )
    Prototype PFNGLGETBOOLEANI_VPROC ( target.i, index.i, *data_ )
    Prototype PFNGLGETINTEGERI_VPROC ( target.i, index.i, *data_ )
    Prototype PFNGLENABLEIPROC ( target.i, index.i )
    Prototype PFNGLDISABLEIPROC ( target.i, index.i )
    Prototype.b PFNGLISENABLEDIPROC ( target.i, index.i )
    Prototype PFNGLBEGINTRANSFORMFEEDBACKPROC ( primitiveMode.l )
    Prototype PFNGLENDTRANSFORMFEEDBACKPROC (  )
    Prototype PFNGLBINDBUFFERRANGEPROC ( target.i, index.i, buffer.i, offset.i, size.i )
    Prototype PFNGLBINDBUFFERBASEPROC ( target.i, index.i, buffer.i )
    Prototype PFNGLTRANSFORMFEEDBACKVARYINGSPROC ( program.i, count.i, *varyings, bufferMode.l )
    Prototype PFNGLGETTRANSFORMFEEDBACKVARYINGPROC ( program.i, index.i, bufSize.i, *length, *size, *type, *name )
    Prototype PFNGLCLAMPCOLORPROC ( target.i, clamp.l )
    Prototype PFNGLBEGINCONDITIONALRENDERPROC ( id.i, mode.l )
    Prototype PFNGLENDCONDITIONALRENDERPROC (  )
    Prototype PFNGLVERTEXATTRIBIPOINTERPROC ( index.i, size.i, type.i, stride.i, *pointer )
    Prototype PFNGLGETVERTEXATTRIBIIVPROC ( index.i, pname.l, *params )
    Prototype PFNGLGETVERTEXATTRIBIUIVPROC ( index.i, pname.l, *params )
    Prototype PFNGLVERTEXATTRIBI1IPROC ( index.i, x.i )
    Prototype PFNGLVERTEXATTRIBI2IPROC ( index.i, x.i, y.i )
    Prototype PFNGLVERTEXATTRIBI3IPROC ( index.i, x.i, y.i, z.i )
    Prototype PFNGLVERTEXATTRIBI4IPROC ( index.i, x.i, y.i, z.i, w.i )
    Prototype PFNGLVERTEXATTRIBI1UIPROC ( index.i, x.i )
    Prototype PFNGLVERTEXATTRIBI2UIPROC ( index.i, x.i, y.i )
    Prototype PFNGLVERTEXATTRIBI3UIPROC ( index.i, x.i, y.i, z.i )
    Prototype PFNGLVERTEXATTRIBI4UIPROC ( index.i, x.i, y.i, z.i, w.i )
    Prototype PFNGLVERTEXATTRIBI1IVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI2IVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI3IVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI4IVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI1UIVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI2UIVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI3UIVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI4UIVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI4BVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI4SVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI4UBVPROC ( index.i, *v )
    Prototype PFNGLVERTEXATTRIBI4USVPROC ( index.i, *v )
    Prototype PFNGLGETUNIFORMUIVPROC ( program.i, location.i, *params )
    Prototype PFNGLBINDFRAGDATALOCATIONPROC ( program.i, color.i, name.p-utf8 )
    Prototype.i PFNGLGETFRAGDATALOCATIONPROC ( program.i, *name )
  ;     Prototype PFNGLUNIFORM1FPROC(location.GLint,v0.GLfloat)
  ;     Prototype PFNGLUNIFORM2FPROC(location.GLint,v0.GLfloat,v1.GLfloat)
  ;     Prototype PFNGLUNIFORM3FPROC(location.GLint,v0.GLfloat,v1.GLfloat,v2.GLfloat)
    Prototype PFNGLUNIFORM1UIPROC ( location.i, v0.i )
    Prototype PFNGLUNIFORM2UIPROC ( location.i, v0.i, v1.i )
    Prototype PFNGLUNIFORM3UIPROC ( location.i, v0.i, v1.i, v2.i )
    Prototype PFNGLUNIFORM4UIPROC ( location.i, v0.i, v1.i, v2.i, v3.i )
    Prototype PFNGLUNIFORM1UIVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM2UIVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM3UIVPROC ( location.i, count.i, *value )
    Prototype PFNGLUNIFORM4UIVPROC ( location.i, count.i, *value )
    Prototype PFNGLTEXPARAMETERIIVPROC ( target.i, pname.l, *params )
    Prototype PFNGLTEXPARAMETERIUIVPROC ( target.i, pname.l, *params )
    Prototype PFNGLGETTEXPARAMETERIIVPROC ( target.i, pname.l, *params )
    Prototype PFNGLGETTEXPARAMETERIUIVPROC ( target.i, pname.l, *params )
    Prototype PFNGLCLEARBUFFERIVPROC ( buffer.l, drawbuffer.i, *value )
    Prototype PFNGLCLEARBUFFERUIVPROC ( buffer.l, drawbuffer.i, *value )
    Prototype PFNGLCLEARBUFFERFVPROC ( buffer.l, drawbuffer.i, *value )
    Prototype PFNGLCLEARBUFFERFIPROC ( buffer.l, drawbuffer.i, depth.f, stencil.i )
    Prototype.l PFNGLGETSTRINGIPROC ( name.l, index.i )
  CompilerEndIf
    
  ;- OpenGL 3.1
  CompilerIf #ENABLEGL3_1
    Prototype PFNGLDRAWARRAYSINSTANCEDPROC ( mode.l, first.i, count.i, primcount.i )
    Prototype PFNGLDRAWELEMENTSINSTANCEDPROC ( mode.l, count.i, type.l, *indices, primcount.i )
    Prototype PFNGLTEXBUFFERPROC ( target.l, internalformat.l, buffer.i )
    Prototype PFNGLPRIMITIVERESTARTINDEXPROC ( index.i )
  CompilerEndIf
    
  ;- OpenGL 3.2
  CompilerIf #ENABLEGL3_2
    Prototype PFNGLTEXIMAGE2DMULTISAMPLE(  target.i,samples.i ,internalformat.i,width.i,height.i,fixedsamplelocations.b)
    Prototype PFNGLGETINTEGER64I_VPROC ( target.l, index.i, *data_ )
    Prototype PFNGLGETBUFFERPARAMETERI64VPROC ( target.l, pname.l, *params )
    Prototype PFNGLFRAMEBUFFERTEXTUREPROC ( target.l, attachment.l, texture.i, level.i )
  CompilerEndIf
    
  ;- OpenGL 3.3
  CompilerIf #ENABLEGL3_2
    Prototype PFNGLVERTEXATTRIBDIVISORPROC (index.i, divisor.i)
    Prototype PFNGLPOLYGONOFFSET(factor.GLfloat, units.GLfloat)
  CompilerEndIf
  
  ;- OpenGL Misc
  CompilerIf #ENABLEGLMISC
    Prototype.b PFNGLISRENDERBUFFERPROC ( renderbuffer.i )
    Prototype PFNGLBINDRENDERBUFFERPROC ( target.l, renderbuffer.i )
    Prototype PFNGLDELETERENDERBUFFERSPROC ( n.i, *renderbuffers )
    Prototype PFNGLGENRENDERBUFFERSPROC ( n.i, *renderbuffers )
    Prototype PFNGLRENDERBUFFERSTORAGEPROC ( target.l, internalformat.l, width.i, height.i )
    Prototype PFNGLGETRENDERBUFFERPARAMETERIVPROC ( target.l, pname.l, *params )
    Prototype.b PFNGLISFRAMEBUFFERPROC ( framebuffer.i )
    Prototype PFNGLBINDFRAMEBUFFERPROC ( target.l, framebuffer.i )
    Prototype PFNGLDELETEFRAMEBUFFERSPROC ( n.i, *framebuffers )
    Prototype PFNGLGENFRAMEBUFFERSPROC ( n.i, *framebuffers )
    Prototype.l PFNGLCHECKFRAMEBUFFERSTATUSPROC ( target.l )
    Prototype PFNGLFRAMEBUFFERTEXTURE1DPROC ( target.l, attachment.l, textarget.l, texture.i, level.i )
    Prototype PFNGLFRAMEBUFFERTEXTURE2DPROC ( target.l, attachment.l, textarget.l, texture.i, level.i )
    Prototype PFNGLFRAMEBUFFERTEXTURE3DPROC ( target.l, attachment.l, textarget.l, texture.i, level.i, zoffset.i )
    Prototype PFNGLFRAMEBUFFERRENDERBUFFERPROC ( target.l, attachment.l, renderbuffertarget.l, renderbuffer.i )
    Prototype PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC ( target.l, attachment.l, pname.l, *params )
    Prototype PFNGLGENERATEMIPMAPPROC ( target.l )
    Prototype PFNGLBLITFRAMEBUFFERPROC ( srcX0.i, srcY0.i, srcX1.i, srcY1.i, dstX0.i, dstY0.i, dstX1.i, dstY1.i, mask.i, filter.l )
    Prototype PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC ( target.l, samples.i, internalformat.l, width.i, height.i )
    Prototype PFNGLFRAMEBUFFERTEXTURELAYERPROC ( target.l, attachment.l, texture.i, level.i, layer.i )
  CompilerEndIf
  
  ;- OpenGL 1.2
  Global glBlendColor.PFNGLBLENDCOLORPROC 
  Global glBlendEquation.PFNGLBLENDEQUATIONPROC
  Global glDrawRangeElements.PFNGLDRAWRANGEELEMENTSPROC
  Global glTexImage3D.PFNGLTEXIMAGE3DPROC
  Global glTexSubImage3D.PFNGLTEXSUBIMAGE3DPROC
  Global glCopyTexSubImage3D.PFNGLCOPYTEXSUBIMAGE3DPROC
  
  
  ;- OpenGL 1.3
  Global glActiveTexture.PFNGLACTIVETEXTUREPROC
  Global glSampleCoverage.PFNGLSAMPLECOVERAGEPROC
  Global glCompressedTexImage3D.PFNGLCOMPRESSEDTEXIMAGE3DPROC
  Global glCompressedTexImage2D.PFNGLCOMPRESSEDTEXIMAGE2DPROC
  Global glCompressedTexImage1D.PFNGLCOMPRESSEDTEXIMAGE1DPROC
  Global glCompressedTexSubImage3D.PFNGLCOMPRESSEDTEXSUBIMAGE3DPROC
  Global glCompressedTexSubImage2D.PFNGLCOMPRESSEDTEXSUBIMAGE2DPROC
  Global glCompressedTexSubImage1D.PFNGLCOMPRESSEDTEXSUBIMAGE1DPROC
  Global glGetCompressedTexImage.PFNGLGETCOMPRESSEDTEXIMAGEPROC
  
  ;- OpenGL 1.4 
  Global glBlendFuncSeparate.PFNGLBLENDFUNCSEPARATEPROC
  Global glMultiDrawArrays.PFNGLMULTIDRAWARRAYSPROC
  Global glMultiDrawElements.PFNGLMULTIDRAWELEMENTSPROC
  Global glPointParameterf.PFNGLPOINTPARAMETERFPROC
  Global glPointParameterfv.PFNGLPOINTPARAMETERFVPROC
  Global glPointParameteri.PFNGLPOINTPARAMETERIPROC
  Global glPointParameteriv.PFNGLPOINTPARAMETERIVPROC
    
  ;- OpenGL 1.5 
  Global glGenQueries.PFNGLGENQUERIESPROC
  Global glDeleteQueries.PFNGLDELETEQUERIESPROC
  Global glIsQuery.PFNGLISQUERYPROC
  Global glBeginQuery.PFNGLBEGINQUERYPROC
  Global glEndQuery.PFNGLENDQUERYPROC
  Global glGetQueryiv.PFNGLGETQUERYIVPROC
  Global glGetQueryObjectiv.PFNGLGETQUERYOBJECTIVPROC
  Global glGetQueryObjectuiv.PFNGLGETQUERYOBJECTUIVPROC
  Global glBindBuffer.PFNGLBINDBUFFERPROC
  Global glDeleteBuffers.PFNGLDELETEBUFFERSPROC
  Global glGenBuffers.PFNGLGENBUFFERSPROC
  Global glIsBuffer.PFNGLISBUFFERPROC
  Global glBufferData.PFNGLBUFFERDATAPROC
  Global glBufferSubData.PFNGLBUFFERSUBDATAPROC
  Global glGetBufferSubData.PFNGLGETBUFFERSUBDATAPROC
  Global glMapBuffer.PFNGLMAPBUFFERPROC
  Global glUnmapBuffer.PFNGLUNMAPBUFFERPROC
  Global glGetBufferParameteriv.PFNGLGETBUFFERPARAMETERIVPROC
  Global glGetBufferPointerv.PFNGLGETBUFFERPOINTERVPROC
  
  ;- OpenGL 2.0
  Global glBlendEquationSeparate.PFNGLBLENDEQUATIONSEPARATEPROC
  Global glDrawBuffers.PFNGLDRAWBUFFERSPROC
  Global glStencilOpSeparate.PFNGLSTENCILOPSEPARATEPROC
  Global glStencilFuncSeparate.PFNGLSTENCILFUNCSEPARATEPROC
  Global glStencilMaskSeparate.PFNGLSTENCILMASKSEPARATEPROC
  Global glAttachShader.PFNGLATTACHSHADERPROC
  Global glBindAttribLocation.PFNGLBINDATTRIBLOCATIONPROC
  Global glCompileShader.PFNGLCOMPILESHADERPROC
  Global glCreateProgram.PFNGLCREATEPROGRAMPROC
  Global glCreateShader.PFNGLCREATESHADERPROC
  Global glDeleteProgram.PFNGLDELETEPROGRAMPROC
  Global glDeleteShader.PFNGLDELETESHADERPROC
  Global glDetachShader.PFNGLDETACHSHADERPROC
  Global glDisableVertexAttribArray.PFNGLDISABLEVERTEXATTRIBARRAYPROC
  Global glEnableVertexAttribArray.PFNGLENABLEVERTEXATTRIBARRAYPROC
  Global glGetActiveAttrib.PFNGLGETACTIVEATTRIBPROC
  Global glGetActiveUniform.PFNGLGETACTIVEUNIFORMPROC
  Global glGetAttachedShaders.PFNGLGETATTACHEDSHADERSPROC
  Global glGetAttribLocation.PFNGLGETATTRIBLOCATIONPROC
  Global glGetProgramiv.PFNGLGETPROGRAMIVPROC
  Global glGetProgramInfoLog.PFNGLGETPROGRAMINFOLOGPROC
  Global glGetShaderiv.PFNGLGETSHADERIVPROC
  Global glGetShaderInfoLog.PFNGLGETSHADERINFOLOGPROC
  Global glGetShaderSource.PFNGLGETSHADERSOURCEPROC
  Global glGetUniformLocation.PFNGLGETUNIFORMLOCATIONPROC
  Global glGetUniformfv.PFNGLGETUNIFORMFVPROC
  Global glGetUniformiv.PFNGLGETUNIFORMIVPROC
  Global glGetVertexAttribdv.PFNGLGETVERTEXATTRIBDVPROC
  Global glGetVertexAttribfv.PFNGLGETVERTEXATTRIBFVPROC
  Global glGetVertexAttribiv.PFNGLGETVERTEXATTRIBIVPROC
  Global glGetVertexAttribPointerv.PFNGLGETVERTEXATTRIBPOINTERVPROC
  Global glIsProgram.PFNGLISPROGRAMPROC
  Global glIsShader.PFNGLISSHADERPROC
  Global glLinkProgram.PFNGLLINKPROGRAMPROC
  Global glShaderSource.PFNGLSHADERSOURCEPROC
  Global glUseProgram.PFNGLUSEPROGRAMPROC
  Global glUniform1f.PFNGLUNIFORM1FPROC
  Global glUniform2f.PFNGLUNIFORM2FPROC
  Global glUniform3f.PFNGLUNIFORM3FPROC
  Global glUniform4f.PFNGLUNIFORM4FPROC
  Global glUniform1i.PFNGLUNIFORM1IPROC
  Global glUniform2i.PFNGLUNIFORM2IPROC
  Global glUniform3i.PFNGLUNIFORM3IPROC
  Global glUniform4i.PFNGLUNIFORM4IPROC
  Global glUniform1fv.PFNGLUNIFORM1FVPROC
  Global glUniform2fv.PFNGLUNIFORM2FVPROC
  Global glUniform3fv.PFNGLUNIFORM3FVPROC
  Global glUniform4fv.PFNGLUNIFORM4FVPROC
  Global glUniform1iv.PFNGLUNIFORM1IVPROC
  Global glUniform2iv.PFNGLUNIFORM2IVPROC
  Global glUniform3iv.PFNGLUNIFORM3IVPROC
  Global glUniform4iv.PFNGLUNIFORM4IVPROC
  Global glUniformMatrix2fv.PFNGLUNIFORMMATRIX2FVPROC
  Global glUniformMatrix3fv.PFNGLUNIFORMMATRIX3FVPROC
  Global glUniformMatrix4fv.PFNGLUNIFORMMATRIX4FVPROC
  Global glValidateProgram.PFNGLVALIDATEPROGRAMPROC
  Global glVertexAttrib1d.PFNGLVERTEXATTRIB1DPROC
  Global glVertexAttrib1dv.PFNGLVERTEXATTRIB1DVPROC
  Global glVertexAttrib1f.PFNGLVERTEXATTRIB1FPROC
  Global glVertexAttrib1fv.PFNGLVERTEXATTRIB1FVPROC
  Global glVertexAttrib1s.PFNGLVERTEXATTRIB1SPROC
  Global glVertexAttrib1sv.PFNGLVERTEXATTRIB1SVPROC
  Global glVertexAttrib2d.PFNGLVERTEXATTRIB2DPROC
  Global glVertexAttrib2dv.PFNGLVERTEXATTRIB2DVPROC
  Global glVertexAttrib2f.PFNGLVERTEXATTRIB2FPROC
  Global glVertexAttrib2fv.PFNGLVERTEXATTRIB2FVPROC
  Global glVertexAttrib2s.PFNGLVERTEXATTRIB2SPROC
  Global glVertexAttrib2sv.PFNGLVERTEXATTRIB2SVPROC
  Global glVertexAttrib3d.PFNGLVERTEXATTRIB3DPROC
  Global glVertexAttrib3dv.PFNGLVERTEXATTRIB3DVPROC
  Global glVertexAttrib3f.PFNGLVERTEXATTRIB3FPROC
  Global glVertexAttrib3fv.PFNGLVERTEXATTRIB3FVPROC
  Global glVertexAttrib3s.PFNGLVERTEXATTRIB3SPROC
  Global glVertexAttrib3sv.PFNGLVERTEXATTRIB3SVPROC
  Global glVertexAttrib4Nbv.PFNGLVERTEXATTRIB4NBVPROC
  Global glVertexAttrib4Niv.PFNGLVERTEXATTRIB4NIVPROC
  Global glVertexAttrib4Nsv.PFNGLVERTEXATTRIB4NSVPROC
  Global glVertexAttrib4Nub.PFNGLVERTEXATTRIB4NUBPROC
  Global glVertexAttrib4Nubv.PFNGLVERTEXATTRIB4NUBVPROC
  Global glVertexAttrib4Nuiv.PFNGLVERTEXATTRIB4NUIVPROC
  Global glVertexAttrib4Nusv.PFNGLVERTEXATTRIB4NUSVPROC
  Global glVertexAttrib4bv.PFNGLVERTEXATTRIB4BVPROC
  Global glVertexAttrib4d.PFNGLVERTEXATTRIB4DPROC
  Global glVertexAttrib4dv.PFNGLVERTEXATTRIB4DVPROC
  Global glVertexAttrib4f.PFNGLVERTEXATTRIB4FPROC
  Global glVertexAttrib4fv.PFNGLVERTEXATTRIB4FVPROC
  Global glVertexAttrib4iv.PFNGLVERTEXATTRIB4IVPROC
  Global glVertexAttrib4s.PFNGLVERTEXATTRIB4SPROC
  Global glVertexAttrib4sv.PFNGLVERTEXATTRIB4SVPROC
  Global glVertexAttrib4ubv.PFNGLVERTEXATTRIB4UBVPROC
  Global glVertexAttrib4uiv.PFNGLVERTEXATTRIB4UIVPROC
  Global glVertexAttrib4usv.PFNGLVERTEXATTRIB4USVPROC
  Global glVertexAttribPointer.PFNGLVERTEXATTRIBPOINTERPROC
  Global glBindVertexArray.PFNGLBINDVERTEXARRAYSPROC
  Global glDeleteVertexArrays.PFNGLDELETEVERTEXARRAYSPROC
  Global glGenVertexArrays.PFNGLGENVERTEXARRAYSPROC
  Global glIsVertexArray.PFNGLISVERTEXARRAYPROC
  Global glDrawArrays.PFNGLDRAWARRAYSPROC
  
  ;- OpenGL 2.1
  Global glUniformMatrix2x3fv.PFNGLUNIFORMMATRIX2X3FVPROC
  Global glUniformMatrix3x2fv.PFNGLUNIFORMMATRIX3X2FVPROC
  Global glUniformMatrix2x4fv.PFNGLUNIFORMMATRIX2X4FVPROC
  Global glUniformMatrix4x2fv.PFNGLUNIFORMMATRIX4X2FVPROC
  Global glUniformMatrix3x4fv.PFNGLUNIFORMMATRIX3X4FVPROC
  Global glUniformMatrix4x3fv.PFNGLUNIFORMMATRIX4X3FVPROC
  Global glDisableClientState.PFNGLDISABLECLIENTSTATEPROC
  
  ;- OpenGL 3.0
  Global glColorMaski.PFNGLCOLORMASKIPROC
  Global glGetBooleani_v.PFNGLGETBOOLEANI_VPROC
  Global glGetIntegeri_v.PFNGLGETINTEGERI_VPROC
  Global glEnablei.PFNGLENABLEIPROC
  Global glDisablei.PFNGLDISABLEIPROC
  Global glIsEnabledi.PFNGLISENABLEDIPROC
  Global glBeginTransformFeedback.PFNGLBEGINTRANSFORMFEEDBACKPROC
  Global glEndTransformFeedback.PFNGLENDTRANSFORMFEEDBACKPROC
  Global glBindBufferRange.PFNGLBINDBUFFERRANGEPROC
  Global glBindBufferBase.PFNGLBINDBUFFERBASEPROC
  Global glTransformFeedbackVaryings.PFNGLTRANSFORMFEEDBACKVARYINGSPROC
  Global glGetTransformFeedbackVarying.PFNGLGETTRANSFORMFEEDBACKVARYINGPROC
  Global glClampColor.PFNGLCLAMPCOLORPROC
  Global glBeginConditionalRender.PFNGLBEGINCONDITIONALRENDERPROC
  Global glEndConditionalRender.PFNGLENDCONDITIONALRENDERPROC
  Global glVertexAttribIPointer.PFNGLVERTEXATTRIBIPOINTERPROC
  Global glGetVertexAttribIiv.PFNGLGETVERTEXATTRIBIIVPROC
  Global glGetVertexAttribIuiv.PFNGLGETVERTEXATTRIBIUIVPROC
  Global glVertexAttribI1i.PFNGLVERTEXATTRIBI1IPROC
  Global glVertexAttribI2i.PFNGLVERTEXATTRIBI2IPROC
  Global glVertexAttribI3i.PFNGLVERTEXATTRIBI3IPROC
  Global glVertexAttribI4i.PFNGLVERTEXATTRIBI4IPROC
  Global glVertexAttribI1ui.PFNGLVERTEXATTRIBI1UIPROC
  Global glVertexAttribI2ui.PFNGLVERTEXATTRIBI2UIPROC
  Global glVertexAttribI3ui.PFNGLVERTEXATTRIBI3UIPROC
  Global glVertexAttribI4ui.PFNGLVERTEXATTRIBI4UIPROC
  Global glVertexAttribI1iv.PFNGLVERTEXATTRIBI1IVPROC
  Global glVertexAttribI2iv.PFNGLVERTEXATTRIBI2IVPROC
  Global glVertexAttribI3iv.PFNGLVERTEXATTRIBI3IVPROC
  Global glVertexAttribI4iv.PFNGLVERTEXATTRIBI4IVPROC
  Global glVertexAttribI1uiv.PFNGLVERTEXATTRIBI1UIVPROC
  Global glVertexAttribI2uiv.PFNGLVERTEXATTRIBI2UIVPROC
  Global glVertexAttribI3uiv.PFNGLVERTEXATTRIBI3UIVPROC
  Global glVertexAttribI4uiv.PFNGLVERTEXATTRIBI4UIVPROC
  Global glVertexAttribI4bv.PFNGLVERTEXATTRIBI4BVPROC
  Global glVertexAttribI4sv.PFNGLVERTEXATTRIBI4SVPROC
  Global glVertexAttribI4ubv.PFNGLVERTEXATTRIBI4UBVPROC
  Global glVertexAttribI4usv.PFNGLVERTEXATTRIBI4USVPROC
  Global glGetUniformuiv.PFNGLGETUNIFORMUIVPROC
  Global glBindFragDataLocation.PFNGLBINDFRAGDATALOCATIONPROC
  Global glGetFragDataLocation.PFNGLGETFRAGDATALOCATIONPROC
  Global glUniform1ui.PFNGLUNIFORM1UIPROC
  Global glUniform2ui.PFNGLUNIFORM2UIPROC
  Global glUniform3ui.PFNGLUNIFORM3UIPROC
  Global glUniform4ui.PFNGLUNIFORM4UIPROC
  Global glUniform1uiv.PFNGLUNIFORM1UIVPROC
  Global glUniform2uiv.PFNGLUNIFORM2UIVPROC
  Global glUniform3uiv.PFNGLUNIFORM3UIVPROC
  Global glUniform4uiv.PFNGLUNIFORM4UIVPROC
  ;     Global glUniform1f.PFNGLUNIFORM1FPROC
  ;     Global glUniform2f.PFNGLUNIFORM2FPROC
  ;     Global glUniform3f.PFNGLUNIFORM3FPROC
  Global glTexParameterIiv.PFNGLTEXPARAMETERIIVPROC
  Global glTexParameterIuiv.PFNGLTEXPARAMETERIUIVPROC
  Global glGetTexParameterIiv.PFNGLGETTEXPARAMETERIIVPROC
  Global glGetTexParameterIuiv.PFNGLGETTEXPARAMETERIUIVPROC
  Global glClearBufferiv.PFNGLCLEARBUFFERIVPROC
  Global glClearBufferuiv.PFNGLCLEARBUFFERUIVPROC
  Global glClearBufferfv.PFNGLCLEARBUFFERFVPROC
  Global glClearBufferfi.PFNGLCLEARBUFFERFIPROC
  Global glGetStringi_.PFNGLGETSTRINGIPROC
  
  ;- OpenGL 3.1
  Global glDrawArraysInstanced.PFNGLDRAWARRAYSINSTANCEDPROC
  Global glDrawElementsInstanced.PFNGLDRAWELEMENTSINSTANCEDPROC
  Global glTexBuffer.PFNGLTEXBUFFERPROC
  Global glPrimitiveRestartIndex.PFNGLPRIMITIVERESTARTINDEXPROC
        
  ;- OpenGL 3.2
  Global glTexImage2DMultisample.PFNGLTEXIMAGE2DMULTISAMPLE
  Global glGetInteger64i_v.PFNGLGETINTEGER64I_VPROC
  Global glGetBufferParameteri64v.PFNGLGETBUFFERPARAMETERI64VPROC
  Global glFramebufferTexture.PFNGLFRAMEBUFFERTEXTUREPROC    
  
  ;- OpenGL 3.3
  Global glVertexAttribDivisor.PFNGLVERTEXATTRIBDIVISORPROC
  Global glPolygonOffset.PFNGLPOLYGONOFFSET
  
  ;- OpenGL Misc
  Global glIsRenderbuffer.PFNGLISRENDERBUFFERPROC
  Global glBindRenderbuffer.PFNGLBINDRENDERBUFFERPROC
  Global glDeleteRenderbuffers.PFNGLDELETERENDERBUFFERSPROC
  Global glGenRenderbuffers.PFNGLGENRENDERBUFFERSPROC
  Global glRenderbufferStorage.PFNGLRENDERBUFFERSTORAGEPROC
  Global glGetRenderbufferParameteriv.PFNGLGETRENDERBUFFERPARAMETERIVPROC
  Global glIsFramebuffer.PFNGLISFRAMEBUFFERPROC
  Global glBindFramebuffer.PFNGLBINDFRAMEBUFFERPROC
  Global glDeleteFramebuffers.PFNGLDELETEFRAMEBUFFERSPROC
  Global glGenFramebuffers.PFNGLGENFRAMEBUFFERSPROC
  Global glCheckFramebufferStatus.PFNGLCHECKFRAMEBUFFERSTATUSPROC
  Global glFramebufferTexture1D.PFNGLFRAMEBUFFERTEXTURE1DPROC
  Global glFramebufferTexture2D.PFNGLFRAMEBUFFERTEXTURE2DPROC
  Global glFramebufferTexture3D.PFNGLFRAMEBUFFERTEXTURE3DPROC
  Global glFramebufferRenderbuffer.PFNGLFRAMEBUFFERRENDERBUFFERPROC
  Global glGetFramebufferAttachmentParameteriv.PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC
  Global glGenerateMipmap.PFNGLGENERATEMIPMAPPROC
  Global glBlitFramebuffer.PFNGLBLITFRAMEBUFFERPROC
  Global glRenderbufferStorageMultisample.PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC
  Global glFramebufferTextureLayer.PFNGLFRAMEBUFFERTEXTURELAYERPROC
  
  Declare GLLoadExtensions()
  Declare GLCheckError(message.s)
  Declare GLDebugHardware()
  
EndDeclareModule

; ============================================================================
;  OpenGLExt Module Implementation
; ============================================================================
Module OpenGLExt
  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  
  ; ============================================================================
  ;  Load OpenGL Extensions
  ; ============================================================================
  Procedure GLLoadExtensions()
    
    If Not GL_EXTENSIONS_LOADED
        
        ;- OpenGL 1.2
        CompilerIf #ENABLEGL1_2
          
          setGLEXT( glBlendColor,           "glBlendColor" )
          setGLEXT( glBlendEquation,        "glBlendEquation" )
          setGLEXT( glDrawRangeElements,    "glDrawRangeElements" )
          setGLEXT( glTexImage3D,           "glTexImage3D" )
          setGLEXT( glTexSubImage3D,        "glTexSubImage3D" )
          setGLEXT( glCopyTexSubImage3D,    "glCopyTexSubImage3D" )
        CompilerEndIf
        
        ;- OpenGL 1.3
        CompilerIf #ENABLEGL1_3
          
          setGLEXT( glActiveTexture,            "glActiveTexture" )
          setGLEXT( glSampleCoverage,           "glSampleCoverage" )
          setGLEXT( glCompressedTexImage3D,     "glCompressedTexImage3D" )
          setGLEXT( glCompressedTexImage2D,     "glCompressedTexImage2D" )
          setGLEXT( glCompressedTexImage1D,     "glCompressedTexImage1D" )
          setGLEXT( glCompressedTexSubImage3D,  "glCompressedTexSubImage3D" )
          setGLEXT( glCompressedTexSubImage2D,  "glCompressedTexSubImage2D" )
          setGLEXT( glCompressedTexSubImage1D,  "glCompressedTexSubImage1D" )
          setGLEXT( glGetCompressedTexImage,    "glGetCompressedTexImage" )
        CompilerEndIf
        
        ;- OpenGL 1.4
        CompilerIf #ENABLEGL1_4  
          
          setGLEXT( glBlendFuncSeparate,  "glBlendFuncSeparate" )
          setGLEXT( glMultiDrawArrays,    "glMultiDrawArrays" )
          setGLEXT( glMultiDrawElements,  "glMultiDrawElements" )
          setGLEXT( glPointParameterf,    "glPointParameterf" )
          setGLEXT( glPointParameterfv,   "glPointParameterfv" )
          setGLEXT( glPointParameteri,    "glPointParameteri" )
          setGLEXT( glPointParameteriv,   "glPointParameteriv" )
        CompilerEndIf
        
        ;- OpenGL 1.5
        CompilerIf #ENABLEGL1_5    
          
          setGLEXT( glGenQueries,           "glGenQueries" )
          setGLEXT( glDeleteQueries,        "glDeleteQueries" )
          setGLEXT( glIsQuery,              "glIsQuery" )
          setGLEXT( glBeginQuery,           "glBeginQuery" )
          setGLEXT( glEndQuery,             "glEndQuery" )
          setGLEXT( glGetQueryiv,           "glGetQueryiv" )
          setGLEXT( glGetQueryObjectiv,     "glGetQueryObjectiv" )
          setGLEXT( glGetQueryObjectuiv,    "glGetQueryObjectuiv" )
          setGLEXT( glBindBuffer,           "glBindBuffer" )
          setGLEXT( glDeleteBuffers,        "glDeleteBuffers" )
          setGLEXT( glGenBuffers,           "glGenBuffers" )
          setGLEXT( glIsBuffer,             "glIsBuffer" )
          setGLEXT( glBufferData,           "glBufferData" )
          setGLEXT( glBufferSubData,        "glBufferSubData" )
          setGLEXT( glMapBuffer,            "glMapBuffer" )
          setGLEXT( glUnmapBuffer,          "glUnmapBuffer" )
          setGLEXT( glGetBufferParameteriv, "glGetBufferParameteriv" )
          setGLEXT( glGetBufferPointerv,    "glGetBufferPointerv" )
        CompilerEndIf
        
        ;- OpenGL 2.0
          CompilerIf #ENABLEGL2_0
          
          setGLEXT( glBlendEquationSeparate,    "glBlendEquationSeparate" )
          setGLEXT( glDrawBuffers,              "glDrawBuffers" )
          setGLEXT( glStencilOpSeparate,        "glStencilOpSeparate" )
          setGLEXT( glStencilFuncSeparate,      "glStencilFuncSeparate" )
          setGLEXT( glStencilMaskSeparate,      "glStencilMaskSeparate" )
          setGLEXT( glAttachShader,             "glAttachShader" )
          setGLEXT( glBindAttribLocation,       "glBindAttribLocation" )
          setGLEXT( glCompileShader,            "glCompileShader" )
          setGLEXT( glCreateProgram,            "glCreateProgram" )
          setGLEXT( glCreateShader,             "glCreateShader" )
          setGLEXT( glDeleteProgram,            "glDeleteProgram" )
          setGLEXT( glDeleteShader,             "glDeleteShader" )
          setGLEXT( glDetachShader,             "glDetachShader" )
          setGLEXT( glDisableVertexAttribArray, "glDisableVertexAttribArray" )
          setGLEXT( glEnableVertexAttribArray,  "glEnableVertexAttribArray" )
          setGLEXT( glGetActiveAttrib,          "glGetActiveAttrib" )
          setGLEXT( glGetActiveUniform,         "glGetActiveUniform" )
          setGLEXT( glGetAttachedShaders,       "glGetAttachedShaders" )
          setGLEXT( glGetAttribLocation,        "glGetAttribLocation" )
          setGLEXT( glGetProgramiv,             "glGetProgramiv" )
          setGLEXT( glGetProgramInfoLog,        "glGetProgramInfoLog" )
          setGLEXT( glGetShaderiv,              "glGetShaderiv" )
          setGLEXT( glGetShaderInfoLog,         "glGetShaderInfoLog" )
          setGLEXT( glGetShaderSource,          "glGetShaderSource" )
          setGLEXT( glGetUniformLocation,       "glGetUniformLocation" )
          setGLEXT( glGetUniformfv,             "glGetUniformfv" )
          setGLEXT( glGetUniformiv,             "glGetUniformiv" )
          setGLEXT( glGetVertexAttribdv,        "glGetVertexAttribdv" )
          setGLEXT( glGetVertexAttribfv,        "glGetVertexAttribfv" )
          setGLEXT( glGetVertexAttribiv,        "glGetVertexAttribiv" )
          setGLEXT( glGetVertexAttribPointerv,  "glGetVertexAttribPointerv" )
          setGLEXT( glIsProgram,                "glIsProgram" )
          setGLEXT( glIsShader,                 "glIsShader" )
          setGLEXT( glLinkProgram,              "glLinkProgram" )
          setGLEXT( glShaderSource,             "glShaderSource" )
          setGLEXT( glUseProgram,               "glUseProgram" )
          setGLEXT( glUniform1f,                "glUniform1f" )
          setGLEXT( glUniform2f,                "glUniform2f" )
          setGLEXT( glUniform3f,                "glUniform3f" )
          setGLEXT( glUniform4f,                "glUniform4f" )
          setGLEXT( glUniform1i,                "glUniform1i" )
          setGLEXT( glUniform2i,                "glUniform2i" )
          setGLEXT( glUniform3i,                "glUniform3i" )
          setGLEXT( glUniform4i,                "glUniform4i" )
          setGLEXT( glUniform1fv,               "glUniform1fv" )
          setGLEXT( glUniform2fv,               "glUniform2fv" )
          setGLEXT( glUniform3fv,               "glUniform3fv" )
          setGLEXT( glUniform4fv,               "glUniform4fv" )
          setGLEXT( glUniform1iv,               "glUniform1iv" )
          setGLEXT( glUniform2iv,               "glUniform2iv" )
          setGLEXT( glUniform3iv,               "glUniform3iv" )
          setGLEXT( glUniform4iv,               "glUniform4iv" )
          setGLEXT( glUniformMatrix2fv,         "glUniformMatrix2fv" )
          setGLEXT( glUniformMatrix3fv,         "glUniformMatrix3fv" )
          setGLEXT( glUniformMatrix4fv,         "glUniformMatrix4fv" )
          setGLEXT( glValidateProgram,          "glValidateProgram" )
          setGLEXT( glVertexAttrib1d,           "glVertexAttrib1d" )
          setGLEXT( glVertexAttrib1dv,          "glVertexAttrib1dv" )
          setGLEXT( glVertexAttrib1f,           "glVertexAttrib1f" )
          setGLEXT( glVertexAttrib1fv,          "glVertexAttrib1fv" )
          setGLEXT( glVertexAttrib1s,           "glVertexAttrib1s" )
          setGLEXT( glVertexAttrib1sv,          "glVertexAttrib1sv" )
          setGLEXT( glVertexAttrib2d,           "glVertexAttrib2d" )
          setGLEXT( glVertexAttrib2dv,          "glVertexAttrib2dv" )
          setGLEXT( glVertexAttrib2f,           "glVertexAttrib2f" )
          setGLEXT( glVertexAttrib2fv,          "glVertexAttrib2fv" )
          setGLEXT( glVertexAttrib2s,           "glVertexAttrib2s" )
          setGLEXT( glVertexAttrib2sv,          "glVertexAttrib2sv" )
          setGLEXT( glVertexAttrib3d,           "glVertexAttrib3d" )
          setGLEXT( glVertexAttrib3dv,          "glVertexAttrib3dv" )
          setGLEXT( glVertexAttrib3f,           "glVertexAttrib3f" )
          setGLEXT( glVertexAttrib3fv,          "glVertexAttrib3fv" )
          setGLEXT( glVertexAttrib3s,           "glVertexAttrib3s" )
          setGLEXT( glVertexAttrib3sv,          "glVertexAttrib3sv" )
          setGLEXT( glVertexAttrib4Nbv,         "glVertexAttrib4Nbv" )
          setGLEXT( glVertexAttrib4Niv,         "glVertexAttrib4Niv" )
          setGLEXT( glVertexAttrib4Nsv,         "glVertexAttrib4Nsv" )
          setGLEXT( glVertexAttrib4Nub,         "glVertexAttrib4Nub" )
          setGLEXT( glVertexAttrib4Nubv,        "glVertexAttrib4Nubv" )
          setGLEXT( glVertexAttrib4Nuiv,        "glVertexAttrib4Nuiv" )
          setGLEXT( glVertexAttrib4Nusv,        "glVertexAttrib4Nusv" )
          setGLEXT( glVertexAttrib4bv,          "glVertexAttrib4bv" )
          setGLEXT( glVertexAttrib4d,           "glVertexAttrib4d" )
          setGLEXT( glVertexAttrib4dv,          "glVertexAttrib4dv" )
          setGLEXT( glVertexAttrib4f,           "glVertexAttrib4f" )
          setGLEXT( glVertexAttrib4fv,          "glVertexAttrib4fv" )
          setGLEXT( glVertexAttrib4iv,          "glVertexAttrib4iv" )
          setGLEXT( glVertexAttrib4s,           "glVertexAttrib4s" )
          setGLEXT( glVertexAttrib4sv,          "glVertexAttrib4sv" )
          setGLEXT( glVertexAttrib4ubv,         "glVertexAttrib4ubv" )
          setGLEXT( glVertexAttrib4uiv,         "glVertexAttrib4Nusv" )
          setGLEXT( glVertexAttrib4usv,         "glVertexAttrib4usv" )
          setGLEXT( glVertexAttribPointer,      "glVertexAttribPointer" )
          
          CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And OpenGL::#USE_LEGACY_OPENGL
            setGLEXT( glBindVertexArray,          "glBindVertexArrayAPPLE")
            setGLEXT( glDeleteVertexArrays,       "glDeleteVertexArraysAPPLE")
            setGLEXT( glGenVertexArrays,          "glGenVertexArraysAPPLE")
            setGLEXT( glIsVertexArrays,          "glIsVertexArraysAPPLE")
          CompilerElse
            setGLEXT( glBindVertexArray,          "glBindVertexArray")
            setGLEXT( glDeleteVertexArrays,       "glDeleteVertexArrays")
            setGLEXT( glGenVertexArrays,          "glGenVertexArrays")
            setGLEXT( glIsVertexArray,            "glIsVertexArray")
          CompilerEndIf
;           
          setGLEXT( glDrawArrays,               "glDrawArrays")
        CompilerEndIf
;         
        ;- OpenGL 2.1
        CompilerIf #ENABLEGL2_1
          
          setGLEXT( glUniformMatrix2x3fv,      "glUniformMatrix2x3fv" )
          setGLEXT( glUniformMatrix3x2fv,      "glUniformMatrix3x2fv" )
          setGLEXT( glUniformMatrix2x4fv,      "glUniformMatrix2x4fv" )
          setGLEXT( glUniformMatrix4x2fv,      "glUniformMatrix4x2fv" )
          setGLEXT( glUniformMatrix3x4fv,      "glUniformMatrix3x4fv" )
          setGLEXT( glUniformMatrix4x3fv,      "glUniformMatrix4x3fv" )
          setGLEXT( glDisableClientState,      "glDisableClientState" )
        CompilerEndIf
        
        ;- OpenGL 3.0
        CompilerIf #ENABLEGL3_0
          
          setGLEXT( glColorMaski,                     "glColorMaski" )
          setGLEXT( glGetBooleani_v,                  "glGetBooleani_v" )
          setGLEXT( glGetIntegeri_v,                  "glGetIntegeri_v" )
          setGLEXT( glEnablei,                        "glEnablei" )
          setGLEXT( glDisablei,                       "glDisablei" )
          setGLEXT( glIsEnabledi,                     "glIsEnabledi" )
          setGLEXT( glBeginTransformFeedback,         "glBeginTransformFeedback" )
          setGLEXT( glEndTransformFeedback,           "glEndTransformFeedback" )
          setGLEXT( glBindBufferRange,                "glBindBufferRange" )
          setGLEXT( glBindBufferBase,                 "glBindBufferBase" )
          setGLEXT( glTransformFeedbackVaryings,      "glTransformFeedbackVaryings" )
          setGLEXT( glGetTransformFeedbackVarying,    "glGetTransformFeedbackVarying" )
          setGLEXT( glClampColor,                     "glClampColor" )
          setGLEXT( glBeginConditionalRender,         "glBeginConditionalRender" )
          setGLEXT( glEndConditionalRender,           "glEndConditionalRender" )
          setGLEXT( glVertexAttribIPointer,           "glVertexAttribIPointer" )
          setGLEXT( glGetVertexAttribIiv,             "glGetVertexAttribIiv" )
          setGLEXT( glGetVertexAttribIuiv,            "glGetVertexAttribIuiv" )
          setGLEXT( glVertexAttribI1i,                "glVertexAttribI1i" )
          setGLEXT( glVertexAttribI2i,                "glVertexAttribI2i" )
          setGLEXT( glVertexAttribI3i,                "glVertexAttribI3i" )
          setGLEXT( glVertexAttribI4i,                "glVertexAttribI4i" )
          setGLEXT( glVertexAttribI1ui,               "glVertexAttribI1ui" )
          setGLEXT( glVertexAttribI2ui,               "glVertexAttribI2ui" )
          setGLEXT( glVertexAttribI3ui,               "glVertexAttribI3ui" )
          setGLEXT( glVertexAttribI4ui,               "glVertexAttribI4ui" )
          setGLEXT( glVertexAttribI1iv,               "glVertexAttribI1iv" )
          setGLEXT( glVertexAttribI2iv,               "glVertexAttribI2iv" )
          setGLEXT( glVertexAttribI3iv,               "glVertexAttribI3iv" )
          setGLEXT( glVertexAttribI4iv,               "glVertexAttribI4iv" )
          setGLEXT( glVertexAttribI1uiv,              "glVertexAttribI1uiv" )
          setGLEXT( glVertexAttribI2uiv,              "glVertexAttribI2uiv" )
          setGLEXT( glVertexAttribI3uiv,              "glVertexAttribI3uiv" )
          setGLEXT( glVertexAttribI4uiv,              "glVertexAttribI4uiv" )
          setGLEXT( glVertexAttribI4bv,               "glVertexAttribI4bv" )
          setGLEXT( glVertexAttribI4sv,               "glVertexAttribI4sv" )
          setGLEXT( glVertexAttribI4ubv,              "glVertexAttribI4ubv" )
          setGLEXT( glVertexAttribI4usv,              "glVertexAttribI4usv" )
          setGLEXT( glGetUniformuiv,                  "glGetUniformuiv" )
          setGLEXT( glBindFragDataLocation,           "glBindFragDataLocation" )
          setGLEXT( glGetFragDataLocation,            "glGetFragDataLocation" )
          setGLEXT( glUniform1ui,                     "glUniform1ui" )
          setGLEXT( glUniform2ui,                     "glUniform2ui" )
          setGLEXT( glUniform3ui,                     "glUniform3ui" )
          setGLEXT( glUniform4ui,                     "glUniform4ui" )
          setGLEXT( glUniform1uiv,                    "glUniform1uiv" )
          setGLEXT( glUniform2uiv,                    "glUniform2uiv" )
          setGLEXT( glUniform3uiv,                    "glUniform3uiv" )
          setGLEXT( glUniform4uiv,                    "glUniform4uiv" )
      ;     setGLEXT( glUniform1f,                      "glUniform1f")
      ;     setGLEXT( glUniform2f,                      "glUniform2f")
      ;     setGLEXT( glUniform3f,                      "glUniform3f")
          setGLEXT( glTexParameterIiv,                "glTexParameterIiv" )
          setGLEXT( glTexParameterIuiv,               "glTexParameterIuiv" )
          setGLEXT( glGetTexParameterIiv,             "glGetTexParameterIiv" )
          setGLEXT( glGetTexParameterIuiv,            "glGetTexParameterIuiv" )
          setGLEXT( glClearBufferiv,                  "glClearBufferiv" )
          setGLEXT( glClearBufferuiv,                 "glClearBufferuiv" )
          setGLEXT( glClearBufferfv,                  "glClearBufferfv" )
          setGLEXT( glClearBufferfi,                  "glClearBufferfi" )
          setGLEXT( glGetStringi_,                     "glGetStringi" )
        CompilerEndIf
        
        ;- OpenGL 3.1
        CompilerIf #ENABLEGL3_1
          
          setGLEXT( glDrawArraysInstanced,    "glDrawArraysInstanced" )
          setGLEXT( glDrawElementsInstanced,  "glDrawElementsInstanced" )
          setGLEXT( glTexBuffer,              "glTexBuffer" )
          setGLEXT( glPrimitiveRestartIndex,  "glPrimitiveRestartIndex" )
        CompilerEndIf
        
        ;- OpenGL 3.2
        CompilerIf #ENABLEGL3_2
          setGLEXT( glTexImage2DMultisample,  "glTexImage2DMultisample")
          setGLEXT( glGetInteger64i_v,        "glGetInteger64i_v" )
          setGLEXT( glGetBufferParameteri64v, "glGetBufferParameteri64v" )
          setGLEXT( glFramebufferTexture,     "glFramebufferTexture" )
        CompilerEndIf
        
        ;- OpenGL 3.3
        CompilerIf #ENABLEGL3_2
          setGLEXT( glVertexAttribDivisor,    "glVertexAttribDivisor" )
          setGLEXT( glPolygonOffset,          "glPolygonOffset" )
        CompilerEndIf
        
        ;- OpenGL Misc
        CompilerIf #ENABLEGLMISC
          setGLEXT( glIsRenderbuffer,                       "glIsRenderbuffer" )
          setGLEXT( glBindRenderbuffer,                     "glBindRenderbuffer" )
          setGLEXT( glDeleteRenderbuffers,                  "glDeleteRenderbuffers" )
          setGLEXT( glGenRenderbuffers,                     "glGenRenderbuffers" )
          setGLEXT( glDeleteRenderbuffers,                  "glDeleteRenderbuffers" )
          setGLEXT( glRenderbufferStorage,                  "glRenderbufferStorage" )
          setGLEXT( glGetRenderbufferParameteriv,           "glGetRenderbufferParameteriv" )
          setGLEXT( glIsFramebuffer,                        "glIsFramebuffer" )
          setGLEXT( glBindFramebuffer,                      "glBindFramebuffer" )
          setGLEXT( glDeleteFramebuffers,                   "glDeleteFramebuffers" )
          setGLEXT( glGenFramebuffers,                      "glGenFramebuffers" )
          setGLEXT( glCheckFramebufferStatus,               "glCheckFramebufferStatus" )
          setGLEXT( glFramebufferTexture1D,                 "glFramebufferTexture1D" )
          setGLEXT( glFramebufferTexture2D,                 "glFramebufferTexture2D" )
          setGLEXT( glFramebufferTexture3D,                 "glFramebufferTexture3D" )
          setGLEXT( glFramebufferRenderbuffer,              "glFramebufferRenderbuffer" )
          setGLEXT( glGetFramebufferAttachmentParameteriv,  "glGetFramebufferAttachmentParameteriv" )
          setGLEXT( glGenerateMipmap,                       "glGenerateMipmap" )
          setGLEXT( glBlitFramebuffer,                      "glBlitFramebuffer" )
          setGLEXT( glRenderbufferStorageMultisample,       "glRenderbufferStorageMultisample" )
          setGLEXT( glFramebufferTextureLayer,              "glFramebufferTextureLayer" )
        CompilerEndIf
        
        GL_EXTENSIONS_LOADED = #True

    EndIf
    
  EndProcedure

  ; PrototypeC           glDrawArrays                         ( mode.GLenum, first.GLint, count.GLsizei )
  ; PrototypeC           glDrawElements                       ( mode.GLenum, count.GLsizei, type.GLenum, *indices )
  ; PrototypeC           glGetPointerv                        ( pname.GLenum, *params )
  ; PrototypeC           glPolygonOffset                      ( factor.GLfloat, units.GLfloat )
  ; PrototypeC           glCopyTexImage1D                     ( target.GLenum, level.GLint, internalformat.GLenum, x.GLint, y.GLint, width.GLsizei, border.GLint )
  ; PrototypeC           glCopyTexImage2D                     ( target.GLenum, level.GLint, internalformat.GLenum, x.GLint, y.GLint, width.GLsizei, height.GLsizei, border.GLint )
  ; PrototypeC           glCopyTexSubImage1D                  ( target.GLenum, level.GLint, xoffset.GLint, x.GLint, y.GLint, width.GLsizei )
  ; PrototypeC           glCopyTexSubImage2D                  ( target.GLenum, level.GLint, xoffset.GLint, yoffset.GLint, x.GLint, y.GLint, width.GLsizei, height.GLsizei )
  ; PrototypeC           glTexSubImage1D                      ( target.GLenum, level.GLint, xoffset.GLint, width.GLsizei, format.GLenum, type.GLenum, *pixels )
  ; PrototypeC           glTexSubImage2D                      ( target.GLenum, level.GLint, xoffset.GLint, yoffset.GLint, width.GLsizei, height.GLsizei, format.GLenum, type.GLenum, *pixels )
  ; PrototypeC           glBindTexture                        ( target.GLenum, texture.GLuint )
  ; PrototypeC           glDeleteTextures                     ( n.GLsizei, *textures )
  ; PrototypeC           glGenTextures                        ( n.GLsizei, *textures )
  ; PrototypeC.GLboolean glIsTexture                          ( texture.GLuint )
  ; PrototypeC           glBlendColor                         ( red.GLclampf, green.GLclampf, blue.GLclampf, alpha.GLclampf )
  ; PrototypeC           glBlendEquation                      ( mode.GLenum )
  ; PrototypeC           glDrawRangeElements                  ( mode.GLenum, start.GLuint, end_.GLuint, count.GLsizei, type.GLenum, *indices )
  ; PrototypeC           glTexImage3D                         ( target.GLenum, level.GLint, internalformat.GLint, width.GLsizei, height.GLsizei, depth.GLsizei, border.GLint, format.GLenum, type.GLenum, *pixels )
  ; PrototypeC           glTexSubImage3D                      ( target.GLenum, level.GLint, xoffset.GLint, yoffset.GLint, zoffset.GLint, width.GLsizei, height.GLsizei, depth.GLsizei, format.GLenum, type.GLenum, *pixels )
  ; PrototypeC           glCopyTexSubImage3D                  ( target.GLenum, level.GLint, xoffset.GLint, yoffset.GLint, zoffset.GLint, x.GLint, y.GLint, width.GLsizei, height.GLsizei )
  ; PrototypeC           glActiveTexture                      ( texture.GLenum )
  ; PrototypeC           glSampleCoverage                     ( value.GLclampf, invert.GLboolean )
  ; PrototypeC           glCompressedTexImage3D               ( target.GLenum, level.GLint, internalformat.GLenum, width.GLsizei, height.GLsizei, depth.GLsizei, border.GLint, imageSize.GLsizei, *data_ )
  ; PrototypeC           glCompressedTexImage2D               ( target.GLenum, level.GLint, internalformat.GLenum, width.GLsizei, height.GLsizei, border.GLint, imageSize.GLsizei, *data_ )
  ; PrototypeC           glCompressedTexImage1D               ( target.GLenum, level.GLint, internalformat.GLenum, width.GLsizei, border.GLint, imageSize.GLsizei, *data_ )
  ; PrototypeC           glCompressedTexSubImage3D            ( target.GLenum, level.GLint, xoffset.GLint, yoffset.GLint, zoffset.GLint, width.GLsizei, height.GLsizei, depth.GLsizei, format.GLenum, imageSize.GLsizei, *data_ )
  ; PrototypeC           glCompressedTexSubImage2D            ( target.GLenum, level.GLint, xoffset.GLint, yoffset.GLint, width.GLsizei, height.GLsizei, format.GLenum, imageSize.GLsizei, *data_ )
  ; PrototypeC           glCompressedTexSubImage1D            ( target.GLenum, level.GLint, xoffset.GLint, width.GLsizei, format.GLenum, imageSize.GLsizei, *data_ )
  ; PrototypeC           glGetCompressedTexImage              ( target.GLenum, level.GLint, *img )
  ; PrototypeC           glBlendFuncSeparate                  ( sfactorRGB.GLenum, dfactorRGB.GLenum, sfactorAlpha.GLenum, dfactorAlpha.GLenum )
  ; PrototypeC           glMultiDrawArrays                    ( mode.GLenum, first.GLint, count.GLsizei,  primcount.GLsizei )
  ; PrototypeC           glMultiDrawElements                  ( mode.GLenum, count.GLsizei, type.GLenum, *indices, primcount.GLsizei )
  ; PrototypeC           glPointParameterf                    ( pname.GLenum, param.GLfloat )                                                                                                                                                 
  ; PrototypeC           glPointParameterfv                   ( pname.GLenum, *params )
  ; PrototypeC           glPointParameteri                    ( pname.GLenum, param.GLint )
  ; PrototypeC           glPointParameteriv                   ( pname.GLenum, params.GLint )
  ; PrototypeC           glGenQueries                         ( n.GLsizei, *ids )
  ; PrototypeC           glDeleteQueries                      ( n.GLsizei, *ids )
  ; PrototypeC.GLboolean glIsQuery                            ( id.GLuint )
  ; PrototypeC           glBeginQuery                         ( target.GLenum, id.GLuint )
  ; PrototypeC           glEndQuery                           ( target.GLenum )
  ; PrototypeC           glGetQueryiv                         ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC           glGetQueryObjectiv                   ( id.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetQueryObjectuiv                  ( id.GLuint, pname.GLenum, *params )
  ; PrototypeC           glBindBuffer                         ( target.GLenum, buffer.GLuint )
  ; PrototypeC           glDeleteBuffers                      ( n.GLsizei, *buffers )
  ; PrototypeC           PGLGENBUFFERS                         ( n.GLsizei, *buffers )
  ; PrototypeC.GLboolean glIsBuffer                           ( buffer.GLuint )
  ; PrototypeC           glBufferData                         ( target.GLenum, size.GLsizeiptr, *data_, usage.GLenum )
  ; PrototypeC           glBufferSubData                      ( target.GLenum, offset.GLintptr, size.GLsizeiptr, *data_ )
  ; PrototypeC           glGetBufferSubData                   ( target.GLenum, offset.GLintptr, size.GLsizeiptr, *data_ )
  ; PrototypeC.i         glMapBuffer                          ( target.GLenum, access.GLenum )
  ; PrototypeC.GLboolean glUnmapBuffer                        ( target.GLenum )
  ; PrototypeC           glGetBufferParameteriv               ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC           glGetBufferPointerv                  ( target.GLenum, pname.GLenum, *params ) ; GLvoid** params
  ; PrototypeC           glBlendEquationSeparate              ( modeRGB.GLenum, modeAlpha.GLenum )
  ; PrototypeC           glDrawBuffers                        ( n.GLsizei, *bufs )
  ; PrototypeC           glStencilOpSeparate                  ( face.GLenum, sfail.GLenum, dpfail.GLenum, dppassv.GLenum  )
  ; PrototypeC           glStencilFuncSeparate                ( face.GLenum, func.GLenum, ref.GLint, mask.GLuint )
  ; PrototypeC           glStencilMaskSeparate                ( face.GLenum, mask.GLuint )
  ; PrototypeC           glAttachShader                       ( program.GLuint, shader.GLuint )
  ; PrototypeC           glBindAttribLocation                 ( program.GLuint, index.GLuint, name.p-ascii )
  ; PrototypeC           glCompileShader                      ( shader.GLuint )
  ; PrototypeC.GLuint    glCreateProgram                      ( void )
  ; PrototypeC.GLuint    glCreateShader                       ( type.GLenum )
  ; PrototypeC           glDeleteProgram                      ( program.GLuint )
  ; PrototypeC           glDeleteShader                       ( shader.GLuint )
  ; PrototypeC           glDetachShader                       ( program.GLuint, shader.GLuint )
  ; PrototypeC           glDisableVertexAttribArray           ( index.GLuint )
  ; PrototypeC           glEnableVertexAttribArray            ( index.GLuint )
  ; PrototypeC           glGetActiveAttrib                    ( program.GLuint, index.GLuint, bufSize.GLsizei, length.GLsizei, size.GLint, type.GLenum, name.p-ascii )
  ; PrototypeC           glGetActiveUniform                   ( program.GLuint, index.GLuint, bufSize.GLsizei, length.GLsizei, size.GLint, type.GLenum, name.p-ascii )
  ; PrototypeC           glGetAttachedShaders                 ( program.GLuint, maxCount.GLsizei, count.GLsizei, obj.GLuint )
  ; PrototypeC.GLint     glGetAttribLocation                  ( program.GLuint, name.p-ascii )
  ; PrototypeC           glGetProgramiv                       ( program.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetProgramInfoLog                  ( program.GLuint, bufSize.GLsizei, length.GLsizei, *infoLog )
  ; PrototypeC           glGetShaderiv                        ( shader.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetShaderInfoLog                   ( shader.GLuint, bufSize.GLsizei, length.GLsizei, *infoLog )
  ; PrototypeC           glGetShaderSource                    ( shader.GLuint, bufSize.GLsizei, length.GLsizei, *source )
  ; PrototypeC.GLint     glGetUniformLocation                 ( program.GLuint, name.p-ascii )
  ; PrototypeC           glGetUniformfv                       ( program.GLuint, location.GLint, *params )
  ; PrototypeC           glGetUniformiv                       ( program.GLuint, location.GLint, *params )
  ; PrototypeC           glGetVertexAttribdv                  ( index.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetVertexAttribfv                  ( index.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetVertexAttribiv                  ( index.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetVertexAttribPointerv            ( index.GLuint, pname.GLenum, *pointer )
  ; PrototypeC.GLboolean glIsProgram                          ( program.GLuint )
  ; PrototypeC.GLboolean glIsShader                           ( shader.GLuint )
  ; PrototypeC           glLinkProgram                        ( program.GLuint )
  ; PrototypeC           glShaderSource                       ( shader.GLuint, count.GLsizei, *string, *length ) ; const GLchar** string
  ; PrototypeC           glUseProgram                         ( program.GLuint )
  ; PrototypeC           glUniform1f                          ( location.GLint, v0.GLfloat )
  ; PrototypeC           glUniform2f                          ( location.GLint, v0.GLfloat, v1.GLfloat )
  ; PrototypeC           glUniform3f                          ( location.GLint, v0.GLfloat, v1.GLfloat, v2.GLfloat )
  ; PrototypeC           glUniform4f                          ( location.GLint, v0.GLfloat, v1.GLfloat, v2.GLfloat, v3.GLfloat )
  ; PrototypeC           glUniform1i                          ( location.GLint, v0.GLint )
  ; PrototypeC           glUniform2i                          ( location.GLint, v0.GLint, v1.GLint )
  ; PrototypeC           glUniform3i                          ( location.GLint, v0.GLint, v1.GLint, v2.GLint )
  ; PrototypeC           glUniform4i                          ( location.GLint, v0.GLint, v1.GLint, v2.GLint, v3.GLint )
  ; PrototypeC           glUniform1fv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform2fv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform3fv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform4fv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform1iv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform2iv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform3iv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform4iv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniformMatrix2fv                   ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix3fv                   ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix4fv                   ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glValidateProgram                    ( program.GLuint )
  ; PrototypeC           glVertexAttrib1d                     ( index.GLuint, x.GLdouble )
  ; PrototypeC           glVertexAttrib1dv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib1f                     ( index.GLuint, x.GLfloat )
  ; PrototypeC           glVertexAttrib1fv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib1s                     ( index.GLuint, x.GLshort )
  ; PrototypeC           glVertexAttrib1sv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib2d                     ( index.GLuint, x.GLdouble, y.GLdouble )
  ; PrototypeC           glVertexAttrib2dv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib2f                     ( index.GLuint, x.GLfloat, y.GLfloat )
  ; PrototypeC           glVertexAttrib2fv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib2s                     ( index.GLuint, x.GLshort, y.GLshort )
  ; PrototypeC           glVertexAttrib2sv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib3d                     ( index.GLuint, x.GLdouble, y.GLdouble, z.GLdouble )
  ; PrototypeC           glVertexAttrib3dv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib3f                     ( index.GLuint, x.GLfloat, y.GLfloat, z.GLfloat )
  ; PrototypeC           glVertexAttrib3fv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib3s                     ( index.GLuint, x.GLshort, y.GLshort, z.GLshort )
  ; PrototypeC           glVertexAttrib3sv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4Nbv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4Niv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4Nsv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4Nub                   ( index.GLuint, x.GLubyte, y.GLubyte, z.GLubyte, w.GLubyte )
  ; PrototypeC           glVertexAttrib4Nubv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4Nuiv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4Nusv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4bv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4d                     ( index.GLuint, x.GLdouble, y.GLdouble, z.GLdouble, w.GLdouble )
  ; PrototypeC           glVertexAttrib4dv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4f                     ( index.GLuint, x.GLfloat, y.GLfloat, z.GLfloat, w.GLfloat )
  ; PrototypeC           glVertexAttrib4fv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4iv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4s                     ( index.GLuint, x.GLshort, y.GLshort, z.GLshort, w.GLshort )
  ; PrototypeC           glVertexAttrib4sv                    ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4ubv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4uiv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttrib4usv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribPointer                ( index.GLuint, size.GLint, type.GLenum, normalized.GLboolean, stride.GLsizei, *pointer )
  ; PrototypeC           glUniformMatrix2x3fv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix3x2fv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix2x4fv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix4x2fv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix3x4fv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix4x3fv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glColorMaski                         ( index.GLuint, r.GLboolean, g.GLboolean, b.GLboolean, a.GLboolean )
  ; PrototypeC           glGetBooleani_v                      ( target.GLenum, index.GLuint, *data_ )
  ; PrototypeC           glGetIntegeri_v                      ( target.GLenum, index.GLuint, *data_ )
  ; PrototypeC           glEnablei                            ( target.GLenum, index.GLuint )
  ; PrototypeC           glDisablei                           ( target.GLenum, index.GLuint )
  ; PrototypeC.GLboolean glIsEnabledi                         ( target.GLenum, index.GLuint )
  ; PrototypeC           glBeginTransformFeedback             ( primitiveMode.GLenum )
  ; PrototypeC           glEndTransformFeedback               ( void )
  ; PrototypeC           glBindBufferRange                    ( target.GLenum, index.GLuint, buffer.GLuint, offset.GLintptr, size.GLsizeiptr )
  ; PrototypeC           glBindBufferBase                     ( target.GLenum, index.GLuint, buffer.GLuint )
  ; PrototypeC           glTransformFeedbackVaryings          ( program.GLuint, count.GLsizei, *varyings, bufferMode.GLenum ) ; **varyings.GLchar
  ; PrototypeC           glGetTransformFeedbackVarying        ( program.GLuint, index.GLuint, bufSize.GLsizei, *length, *size, *type, name.p-ascii )
  ; PrototypeC           glClampColor                         ( target.GLenum, clamp.GLenum )
  ; PrototypeC           glBeginConditionalRender             ( id.GLuint, mode.GLenum )
  ; PrototypeC           glEndConditionalRender               ( void )
  ; PrototypeC           glVertexAttribIPointer               ( index.GLuint, size.GLint, type.GLenum, stride.GLsizei, *pointer )
  ; PrototypeC           glGetVertexAttribIiv                 ( index.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetVertexAttribIuiv                ( index.GLuint, pname.GLenum, *params )
  ; PrototypeC           glVertexAttribI1i                    ( index.GLuint, x.GLint )
  ; PrototypeC           glVertexAttribI2i                    ( index.GLuint, x.GLint, y.GLint )
  ; PrototypeC           glVertexAttribI3i                    ( index.GLuint, x.GLint, y.GLint, z.GLint )
  ; PrototypeC           glVertexAttribI4i                    ( index.GLuint, x.GLint, y.GLint, z.GLint, w.GLint )
  ; PrototypeC           glVertexAttribI1ui                   ( index.GLuint, x.GLuint )
  ; PrototypeC           glVertexAttribI2ui                   ( index.GLuint, x.GLuint, y.GLuint )
  ; PrototypeC           glVertexAttribI3ui                   ( index.GLuint, x.GLuint, y.GLuint, z.GLuint )
  ; PrototypeC           glVertexAttribI4ui                   ( index.GLuint, x.GLuint, y.GLuint, z.GLuint, w.GLuint )
  ; PrototypeC           glVertexAttribI1iv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI2iv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI3iv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI4iv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI1uiv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI2uiv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI3uiv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI4uiv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI4bv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI4sv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI4ubv                  ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribI4usv                  ( index.GLuint, *v )
  ; PrototypeC           glGetUniformuiv                      ( program.GLuint, location.GLint, *params )
  ; PrototypeC           glBindFragDataLocation               ( program.GLuint, color.GLuint, name.p-ascii )
  ; PrototypeC.GLint     glGetFragDataLocation                ( program.GLuint, name.p-ascii )
  ; PrototypeC           glUniform1ui                         ( location.GLint, v0.GLuint )
  ; PrototypeC           glUniform2ui                         ( location.GLint, v0.GLuint, v1.GLuint )
  ; PrototypeC           glUniform3ui                         ( location.GLint, v0.GLuint, v1.GLuint, v2.GLuint )
  ; PrototypeC           glUniform4ui                         ( location.GLint, v0.GLuint, v1.GLuint, v2.GLuint, v3.GLuint )
  ; PrototypeC           glUniform1uiv                        ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform2uiv                        ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform3uiv                        ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform4uiv                        ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glTexParameterIiv                    ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC           glTexParameterIuiv                   ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC           glGetTexParameterIiv                 ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC           glGetTexParameterIuiv                ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC           glClearBufferiv                      ( buffer.GLenum, drawbuffer.GLint, *value )
  ; PrototypeC           glClearBufferuiv                     ( buffer.GLenum, drawbuffer.GLint, *value )
  ; PrototypeC           glClearBufferfv                      ( buffer.GLenum, drawbuffer.GLint, *value )
  ; PrototypeC           glClearBufferfi                      ( buffer.GLenum, drawbuffer.GLint, depth.GLfloat, stencil.GLint )
  ; PrototypeC.i         glGetStringi                         ( name.GLenum, index.GLuint )
  ; PrototypeC           glDrawArraysInstanced                ( mode.GLenum, first.GLint, count.GLsizei, primcount.GLsizei )
  ; PrototypeC           glDrawElementsInstanced              ( mode.GLenum, count.GLsizei, type.GLenum, *indices, primcount.GLsizei )
  ; PrototypeC           glTexBuffer                          ( target.GLenum, internalformat.GLenum, buffer.GLuint )
  ; PrototypeC           glPrimitiveRestartIndex              ( index.GLuint )
  ; PrototypeC           glGetInteger64i_v                    ( target.GLenum, index.GLuint, *data_ )
  ; PrototypeC           glGetBufferParameteri64v             ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC           glFramebufferTexture                 ( target.GLenum, attachment.GLenum, texture.GLuint, level.GLint )
  ; PrototypeC           glVertexAttribDivisor                ( index.GLuint, divisor.GLuint )
  ; PrototypeC           glMinSampleShading                   ( value.GLclampf )
  ; PrototypeC           glBlendEquationi                     ( buf.GLuint, mode.GLenum )
  ; PrototypeC           glBlendEquationSeparatei             ( buf.GLuint, modeRGB.GLenum, modeAlpha.GLenum )
  ; PrototypeC           glBlendFunci                         ( buf.GLuint, src.GLenum, dst.GLenum )
  ; PrototypeC           glBlendFuncSeparatei                 ( buf.GLuint, srcRGB.GLenum, dstRGB.GLenum, srcAlpha.GLenum, dstAlpha.GLenum )
  ; PrototypeC.GLboolean glIsRenderbuffer                     ( renderbuffer.GLuint )
  ; PrototypeC           glBindRenderbuffer                   ( target.GLenum, renderbuffer.GLuint )
  ; PrototypeC           glDeleteRenderbuffers                ( n.GLsizei, *renderbuffers )
  ; PrototypeC           glGenRenderbuffers                   ( n.GLsizei, *renderbuffers )
  ; PrototypeC           glRenderbufferStorage                ( target.GLenum, internalformat.GLenum, width.GLsizei, height.GLsizei )
  ; PrototypeC           glGetRenderbufferParameteriv         ( target.GLenum, pname.GLenum, *params )
  ; PrototypeC.GLboolean glIsFramebuffer                      ( framebuffer.GLuint )
  ; PrototypeC           glBindFramebuffer                    ( target.GLenum, framebuffer.GLuint )
  ; PrototypeC           glDeleteFramebuffers                 ( n.GLsizei, *framebuffers )
  ; PrototypeC           glGenFramebuffers                    ( n.GLsizei, *framebuffers )
  ; PrototypeC.GLenum    glCheckFramebufferStatus             ( target.GLenum )
  ; PrototypeC           glFramebufferTexture1D               ( target.GLenum, attachment.GLenum, textarget.GLenum, texture.GLuint, level.GLint )
  ; PrototypeC           glFramebufferTexture2D               ( target.GLenum, attachment.GLenum, textarget.GLenum, texture.GLuint, level.GLint )
  ; PrototypeC           glFramebufferTexture3D               ( target.GLenum, attachment.GLenum, textarget.GLenum, texture.GLuint, level.GLint, zoffset.GLint )
  ; PrototypeC           glFramebufferRenderbuffer            ( target.GLenum, attachment.GLenum, renderbuffertarget.GLenum, renderbuffer.GLuint )
  ; PrototypeC           glGetFramebufferAttachmentParameteriv( target.GLenum, attachment.GLenum, pname.GLenum, *params )
  ; PrototypeC           glGenerateMipmap                     ( target.GLenum )
  ; PrototypeC           glBlitFramebuffer                    ( srcX0.GLint, srcY0.GLint, srcX1.GLint, srcY1.GLint, dstX0.GLint, dstY0.GLint, dstX1.GLint, dstY1.GLint, mask.GLbitfield, filter.GLenum )
  ; PrototypeC           glRenderbufferStorageMultisample     ( target.GLenum, samples.GLsizei, internalformat.GLenum, width.GLsizei, height.GLsizei )
  ; PrototypeC           glFramebufferTextureLayer            ( target.GLenum, attachment.GLenum, texture.GLuint, level.GLint, layer.GLint )
  ; PrototypeC.i         glMapBufferRange                     ( target.GLenum, offset.GLintptr, length.GLsizeiptr, access.GLbitfield )
  ; PrototypeC           glFlushMappedBufferRange             ( target.GLenum, offset.GLintptr, length.GLsizeiptr )
  ; PrototypeC           glBindVertexArray                    ( array_.GLuint )
  ; PrototypeC           glDeleteVertexArrays                 ( n.GLsizei, *arrays )
  ; PrototypeC           glGenVertexArrays                    ( n.GLsizei, *arrays )
  ; PrototypeC.GLboolean glIsVertexArray                      ( array_.GLuint )
  ; PrototypeC           glGetUniformIndices                  ( program.GLuint, uniformCount.GLsizei, *uniformNames, *uniformIndices )
  ; PrototypeC           glGetActiveUniformsiv                ( program.GLuint, uniformCount.GLsizei, *uniformIndices, pname.GLenum, *params )
  ; PrototypeC           glGetActiveUniformName               ( program.GLuint, uniformIndex.GLuint, bufSize.GLsizei, *length, uniformName.p-ascii )
  ; PrototypeC.GLuint    glGetUniformBlockIndex               ( program.GLuint, uniformBlockName.p-ascii )
  ; PrototypeC           glGetActiveUniformBlockiv            ( program.GLuint, uniformBlockIndex.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetActiveUniformBlockName          ( program.GLuint, uniformBlockIndex.GLuint, bufSize.GLsizei, *length, uniformBlockName.p-ascii )
  ; PrototypeC           glUniformBlockBinding                ( program.GLuint, uniformBlockIndex.GLuint, uniformBlockBinding.GLuint )
  ; PrototypeC           glCopyBufferSubData                  ( readTarget.GLenum, writeTarget.GLenum, readOffset.GLintptr, writeOffset.GLintptr, size.GLsizeiptr )
  ; PrototypeC           glDrawElementsBaseVertex             ( mode.GLenum, count.GLsizei, type.GLenum, *indices, basevertex.GLint )
  ; PrototypeC           glDrawRangeElementsBaseVertex        ( mode.GLenum, start.GLuint, end_.GLuint, count.GLsizei, type.GLenum, *indices, basevertex.GLint )
  ; PrototypeC           glDrawElementsInstancedBaseVertex    ( mode.GLenum, count.GLsizei, type.GLenum, *indices, primcount.GLsizei, basevertex.GLint )
  ; PrototypeC           glMultiDrawElementsBaseVertex        ( mode.GLenum, *count, type.GLenum, *indices, primcount.GLsizei, *basevertex )
  ; PrototypeC           glProvokingVertex                    ( mode.GLenum )
  ; PrototypeC.GLsync    glFenceSync                          ( condition.GLenum, flags.GLbitfield )
  ; PrototypeC.GLboolean glIsSync                             ( sync.GLsync )
  ; PrototypeC           glDeleteSync                         ( sync.GLsync )
  ; PrototypeC.GLenum    glClientWaitSync                     ( sync.GLsync, flags.GLbitfield, timeout.GLuint64 )
  ; PrototypeC           glWaitSync                           ( sync.GLsync, flags.GLbitfield, timeout.GLuint64 )
  ; PrototypeC           glGetInteger64v                      ( pname.GLenum, *params )
  ; PrototypeC           glGetSynciv                          ( sync.GLsync, pname.GLenum, bufSize.GLsizei, *length, *values )
  ; PrototypeC           glTexImage2DMultisample              ( target.GLenum, samples.GLsizei, internalformat.GLint, width.GLsizei, height.GLsizei, fixedsamplelocations.GLboolean )
  ; PrototypeC           glTexImage3DMultisample              ( target.GLenum, samples.GLsizei, internalformat.GLint, width.GLsizei, height.GLsizei, depth.GLsizei, fixedsamplelocations.GLboolean )
  ; PrototypeC           glGetMultisamplefv                   ( pname.GLenum, index.GLuint, *val )
  ; PrototypeC           glSampleMaski                        ( index.GLuint, mask.GLbitfield )
  ; PrototypeC           glNamedStringARB                     ( type.GLenum, namelen.GLint, name.p-ascii, stringlen.GLint, string.p-ascii )
  ; PrototypeC           glDeleteNamedStringARB               ( namelen.GLint, name.p-ascii )
  ; PrototypeC           glCompileShaderIncludeARB            ( shader.GLuint, count.GLsizei, *path, *length ) ; const GLchar** path
  ; PrototypeC.GLboolean glIsNamedStringARB                   ( namelen.GLint, name.p-ascii )
  ; PrototypeC           glGetNamedStringARB                  ( namelen.GLint, name.p-ascii, bufSize.GLsizei, *stringlen, *string )
  ; PrototypeC           glGetNamedStringivARB                ( namelen.GLint, name.p-ascii, pname.GLenum, *params )
  ; PrototypeC           glBindFragDataLocationIndexed        ( program.GLuint, colorNumber.GLuint, index.GLuint, name.p-ascii )
  ; PrototypeC.GLint     glGetFragDataIndex                   ( program.GLuint, name.p-ascii )
  ; PrototypeC           glGenSamplers                        ( count.GLsizei, *samplers )
  ; PrototypeC           glDeleteSamplers                     ( count.GLsizei, *samplers )
  ; PrototypeC.GLboolean glIsSampler                          ( sampler.GLuint )
  ; PrototypeC           glBindSampler                        ( unit.GLuint, sampler.GLuint )
  ; PrototypeC           glSamplerParameteri                  ( sampler.GLuint, pname.GLenum, param.GLint )
  ; PrototypeC           glSamplerParameteriv                 ( sampler.GLuint, pname.GLenum, *param )
  ; PrototypeC           glSamplerParameterf                  ( sampler.GLuint, pname.GLenum, param.GLfloat )
  ; PrototypeC           glSamplerParameterfv                 ( sampler.GLuint, pname.GLenum, *param )
  ; PrototypeC           glSamplerParameterIiv                ( sampler.GLuint, pname.GLenum, *param )
  ; PrototypeC           glSamplerParameterIuiv               ( sampler.GLuint, pname.GLenum, *param )
  ; PrototypeC           glGetSamplerParameteriv              ( sampler.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetSamplerParameterIiv             ( sampler.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetSamplerParameterfv              ( sampler.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetSamplerParameterIuiv            ( sampler.GLuint, pname.GLenum, *params )
  ; PrototypeC           glQueryCounter                       ( id.GLuint, target.GLenum )
  ; PrototypeC           glGetQueryObjecti64v                 ( id.GLuint, pname.GLenum, *params )
  ; PrototypeC           glGetQueryObjectui64v                ( id.GLuint, pname.GLenum, *params )
  ; PrototypeC           glVertexP2ui                         ( type.GLenum, value.GLuint )
  ; PrototypeC           glVertexP2uiv                        ( type.GLenum, *value )
  ; PrototypeC           glVertexP3ui                         ( type.GLenum, value.GLuint )
  ; PrototypeC           glVertexP3uiv                        ( type.GLenum, *value )
  ; PrototypeC           glVertexP4ui                         ( type.GLenum, value.GLuint )
  ; PrototypeC           glVertexP4uiv                        ( type.GLenum, *value )
  ; PrototypeC           glTexCoordP1ui                       ( type.GLenum, coords.GLuint )
  ; PrototypeC           glTexCoordP1uiv                      ( type.GLenum, *coords )
  ; PrototypeC           glTexCoordP2ui                       ( type.GLenum, coords.GLuint )
  ; PrototypeC           glTexCoordP2uiv                      ( type.GLenum, *coords )
  ; PrototypeC           glTexCoordP3ui                       ( type.GLenum, coords.GLuint )
  ; PrototypeC           glTexCoordP3uiv                      ( type.GLenum, *coords )
  ; PrototypeC           glTexCoordP4ui                       ( type.GLenum, coords.GLuint )
  ; PrototypeC           glTexCoordP4uiv                      ( type.GLenum, *coords )
  ; PrototypeC           glMultiTexCoordP1ui                  ( texture.GLenum, type.GLenum, coords.GLuint )
  ; PrototypeC           glMultiTexCoordP1uiv                 ( texture.GLenum, type.GLenum, *coords )
  ; PrototypeC           glMultiTexCoordP2ui                  ( texture.GLenum, type.GLenum, coords.GLuint )
  ; PrototypeC           glMultiTexCoordP2uiv                 ( texture.GLenum, type.GLenum, *coords )
  ; PrototypeC           glMultiTexCoordP3ui                  ( texture.GLenum, type.GLenum, coords.GLuint )
  ; PrototypeC           glMultiTexCoordP3uiv                 ( texture.GLenum, type.GLenum, *coords )
  ; PrototypeC           glMultiTexCoordP4ui                  ( texture.GLenum, type.GLenum, coords.GLuint )
  ; PrototypeC           glMultiTexCoordP4uiv                 ( texture.GLenum, type.GLenum, *coords )
  ; PrototypeC           glNormalP3ui                         ( type.GLenum, coords.GLuint )
  ; PrototypeC           glNormalP3uiv                        ( type.GLenum, *coords )
  ; PrototypeC           glColorP3ui                          ( type.GLenum, color.GLuint )
  ; PrototypeC           glColorP3uiv                         ( type.GLenum, *color )
  ; PrototypeC           glColorP4ui                          ( type.GLenum, color.GLuint )
  ; PrototypeC           glColorP4uiv                         ( type.GLenum, *color )
  ; PrototypeC           glSecondaryColorP3ui                 ( type.GLenum, color.GLuint )
  ; PrototypeC           glSecondaryColorP3uiv                ( type.GLenum, *color )
  ; PrototypeC           glVertexAttribP1ui                   ( index.GLuint, type.GLenum, normalized.GLboolean, value.GLuint )
  ; PrototypeC           glVertexAttribP1uiv                  ( index.GLuint, type.GLenum, normalized.GLboolean, *value )
  ; PrototypeC           glVertexAttribP2ui                   ( index.GLuint, type.GLenum, normalized.GLboolean, value.GLuint )
  ; PrototypeC           glVertexAttribP2uiv                  ( index.GLuint, type.GLenum, normalized.GLboolean, *value )
  ; PrototypeC           glVertexAttribP3ui                   ( index.GLuint, type.GLenum, normalized.GLboolean, value.GLuint )
  ; PrototypeC           glVertexAttribP3uiv                  ( index.GLuint, type.GLenum, normalized.GLboolean, *value )
  ; PrototypeC           glVertexAttribP4ui                   ( index.GLuint, type.GLenum, normalized.GLboolean, value.GLuint )
  ; PrototypeC           glVertexAttribP4uiv                  ( index.GLuint, type.GLenum, normalized.GLboolean, *value )
  ; PrototypeC           glDrawArraysIndirect                 ( mode.GLenum, *indirect )
  ; PrototypeC           glDrawElementsIndirect               ( mode.GLenum, type.GLenum, *indirect )
  ; PrototypeC           glUniform1d                          ( location.GLint, x.GLdouble )
  ; PrototypeC           glUniform2d                          ( location.GLint, x.GLdouble, y.GLdouble )
  ; PrototypeC           glUniform3d                          ( location.GLint, x.GLdouble, y.GLdouble, z.GLdouble )
  ; PrototypeC           glUniform4d                          ( location.GLint, x.GLdouble, y.GLdouble, z.GLdouble, w.GLdouble )
  ; PrototypeC           glUniform1dv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform2dv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform3dv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniform4dv                         ( location.GLint, count.GLsizei, *value )
  ; PrototypeC           glUniformMatrix2dv                   ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix3dv                   ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix4dv                   ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix2x3dv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix2x4dv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix3x2dv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix3x4dv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix4x2dv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glUniformMatrix4x3dv                 ( location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glGetUniformdv                       ( program.GLuint, location.GLint, *params )
  ; PrototypeC.GLint     glGetSubroutineUniformLocation       ( program.GLuint, shadertype.GLenum, name.p-ascii )
  ; PrototypeC.GLuint    glGetSubroutineIndex                 ( program.GLuint, shadertype.GLenum, name.p-ascii )
  ; PrototypeC           glGetActiveSubroutineUniformiv       ( program.GLuint, shadertype.GLenum, index.GLuint, pname.GLenum, *values )
  ; PrototypeC           glGetActiveSubroutineUniformName     ( program.GLuint, shadertype.GLenum, index.GLuint, bufsize.GLsizei, *length, *name )
  ; PrototypeC           glGetActiveSubroutineName            ( program.GLuint, shadertype.GLenum, index.GLuint, bufsize.GLsizei, *length, *name )
  ; PrototypeC           glUniformSubroutinesuiv              ( shadertype.GLenum, count.GLsizei, *indices )
  ; PrototypeC           glGetUniformSubroutineuiv            ( shadertype.GLenum, location.GLint, *params )
  ; PrototypeC           glGetProgramStageiv                  ( program.GLuint, shadertype.GLenum, pname.GLenum, *values )
  ; PrototypeC           glPatchParameteri                    ( pname.GLenum, value.GLint )
  ; PrototypeC           glPatchParameterfv                   ( pname.GLenum, *values )
  ; PrototypeC           glBindTransformFeedback              ( target.GLenum, id.GLuint )
  ; PrototypeC           glDeleteTransformFeedbacks           ( n.GLsizei, *ids )
  ; PrototypeC           glGenTransformFeedbacks              ( n.GLsizei, *ids )
  ; PrototypeC.GLboolean glIsTransformFeedback                ( id.GLuint )
  ; PrototypeC           glPauseTransformFeedback             ( void )
  ; PrototypeC           glResumeTransformFeedback            ( void )
  ; PrototypeC           glDrawTransformFeedback              ( mode.GLenum, id.GLuint )
  ; PrototypeC           glDrawTransformFeedbackStream        ( mode.GLenum, id.GLuint, stream.GLuint )
  ; PrototypeC           glBeginQueryIndexed                  ( target.GLenum, index.GLuint, id.GLuint )
  ; PrototypeC           glEndQueryIndexed                    ( target.GLenum, index.GLuint )
  ; PrototypeC           glGetQueryIndexediv                  ( target.GLenum, index.GLuint, pname.GLenum, *params )
  ; PrototypeC           glReleaseShaderCompiler              ( void )
  ; PrototypeC           glShaderBinary                       ( count.GLsizei, *shaders, binaryformat.GLenum, *binary, length.GLsizei )
  ; PrototypeC           glGetShaderPrecisionFormat           ( shadertype.GLenum, precisiontype.GLenum, *range, *precision )
  ; PrototypeC           glDepthRangef                        ( n.GLclampf, f.GLclampf )
  ; PrototypeC           glClearDepthf                        ( d.GLclampf )
  ; PrototypeC           glGetProgramBinary                   ( program.GLuint, bufSize.GLsizei, *length, *binaryFormat, *binary )
  ; PrototypeC           glProgramBinary                      ( program.GLuint, binaryFormat.GLenum, *binary, length.GLsizei )
  ; PrototypeC           glProgramParameteri                  ( program.GLuint, pname.GLenum, value.GLint )
  ; PrototypeC           glUseProgramStages                   ( pipeline.GLuint, stages.GLbitfield, program.GLuint )
  ; PrototypeC           glActiveShaderProgram                ( pipeline.GLuint, program.GLuint )
  ; PrototypeC.GLuint    glCreateShaderProgramv               ( type.GLenum, count.GLsizei, *strings ) ; const GLchar** strings
  ; PrototypeC           glBindProgramPipeline                ( pipeline.GLuint )
  ; PrototypeC           glDeleteProgramPipelines             ( n.GLsizei, *pipelines )
  ; PrototypeC           glGenProgramPipelines                ( n.GLsizei, *pipelines )
  ; PrototypeC.GLboolean glIsProgramPipeline                  ( pipeline.GLuint )
  ; PrototypeC           glGetProgramPipelineiv               ( pipeline.GLuint, pname.GLenum, *params )
  ; PrototypeC           glProgramUniform1i                   ( program.GLuint, location.GLint, v0.GLint )
  ; PrototypeC           glProgramUniform1iv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform1f                   ( program.GLuint, location.GLint, v0.GLfloat )
  ; PrototypeC           glProgramUniform1fv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform1d                   ( program.GLuint, location.GLint, v0.GLdouble )
  ; PrototypeC           glProgramUniform1dv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform1ui                  ( program.GLuint, location.GLint, v0.GLuint )
  ; PrototypeC           glProgramUniform1uiv                 ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform2i                   ( program.GLuint, location.GLint, v0.GLint, v1.GLint )
  ; PrototypeC           glProgramUniform2iv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform2f                   ( program.GLuint, location.GLint, v0.GLfloat, v1.GLfloat )
  ; PrototypeC           glProgramUniform2fv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform2d                   ( program.GLuint, location.GLint, v0.GLdouble, v1.GLdouble )
  ; PrototypeC           glProgramUniform2dv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform2ui                  ( program.GLuint, location.GLint, v0.GLuint, v1.GLuint )
  ; PrototypeC           glProgramUniform2uiv                 ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform3i                   ( program.GLuint, location.GLint, v0.GLint, v1.GLint, v2.GLint )
  ; PrototypeC           glProgramUniform3iv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform3f                   ( program.GLuint, location.GLint, v0.GLfloat, v1.GLfloat, v2.GLfloat )
  ; PrototypeC           glProgramUniform3fv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform3d                   ( program.GLuint, location.GLint, v0.GLdouble, v1.GLdouble, v2.GLdouble )
  ; PrototypeC           glProgramUniform3dv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform3ui                  ( program.GLuint, location.GLint, v0.GLuint, v1.GLuint, v2.GLuint )
  ; PrototypeC           glProgramUniform3uiv                 ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform4i                   ( program.GLuint, location.GLint, v0.GLint, v1.GLint, v2.GLint, v3.GLint )
  ; PrototypeC           glProgramUniform4iv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform4f                   ( program.GLuint, location.GLint, v0.GLfloat, v1.GLfloat, v2.GLfloat, v3.GLfloat )
  ; PrototypeC           glProgramUniform4fv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform4d                   ( program.GLuint, location.GLint, v0.GLdouble, v1.GLdouble, v2.GLdouble, v3.GLdouble )
  ; PrototypeC           glProgramUniform4dv                  ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniform4ui                  ( program.GLuint, location.GLint, v0.GLuint, v1.GLuint, v2.GLuint, v3.GLuint )
  ; PrototypeC           glProgramUniform4uiv                 ( program.GLuint, location.GLint, count.GLsizei, *value )
  ; PrototypeC           glProgramUniformMatrix2fv            ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix3fv            ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix4fv            ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix2dv            ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix3dv            ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix4dv            ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix2x3fv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix3x2fv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix2x4fv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix4x2fv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix3x4fv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix4x3fv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix2x3dv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix3x2dv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix2x4dv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix4x2dv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix3x4dv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glProgramUniformMatrix4x3dv          ( program.GLuint, location.GLint, count.GLsizei, transpose.GLboolean, *value )
  ; PrototypeC           glValidateProgramPipeline            ( pipeline.GLuint )
  ; PrototypeC           glGetProgramPipelineInfoLog          ( pipeline.GLuint, bufSize.GLsizei, *length, *infoLog )
  ; PrototypeC           glVertexAttribL1d                    ( index.GLuint, x.GLdouble )
  ; PrototypeC           glVertexAttribL2d                    ( index.GLuint, x.GLdouble, y.GLdouble )
  ; PrototypeC           glVertexAttribL3d                    ( index.GLuint, x.GLdouble, y.GLdouble, z.GLdouble )
  ; PrototypeC           glVertexAttribL4d                    ( index.GLuint, x.GLdouble, y.GLdouble, z.GLdouble, w.GLdouble )
  ; PrototypeC           glVertexAttribL1dv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribL2dv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribL3dv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribL4dv                   ( index.GLuint, *v )
  ; PrototypeC           glVertexAttribLPointer               ( index.GLuint, size.GLint, type.GLenum, stride.GLsizei, *pointer )
  ; PrototypeC           glGetVertexAttribLdv                 ( index.GLuint, pname.GLenum, *params )
  ; PrototypeC           glViewportArrayv                     ( first.GLuint, count.GLsizei, *v )
  ; PrototypeC           glViewportIndexedf                   ( index.GLuint, x.GLfloat, y.GLfloat, w.GLfloat, h.GLfloat )
  ; PrototypeC           glViewportIndexedfv                  ( index.GLuint, *v )
  ; PrototypeC           glScissorArrayv                      ( first.GLuint, count.GLsizei, *v )
  ; PrototypeC           glScissorIndexed                     ( index.GLuint, left.GLint, bottom.GLint, width.GLsizei, height.GLsizei )
  ; PrototypeC           glScissorIndexedv                    ( index.GLuint, *v )
  ; PrototypeC           glDepthRangeArrayv                   ( first.GLuint, count.GLsizei, *v )
  ; PrototypeC           glDepthRangeIndexed                  ( index.GLuint, n.GLclampd, f.GLclampd )
  ; PrototypeC           glGetFloati_v                        ( target.GLenum, index.GLuint, *data_ )
  ; PrototypeC           glGetDoublei_v                       ( target.GLenum, index.GLuint, *data_ )
  ; PrototypeC.GLsync    glCreateSyncFromCLeventARB           ( *context, *event, flags.GLbitfield ) ; struct _cl_context* context, struct _cl_event* event
  ; PrototypeC           glDebugMessageControlARB             ( source.GLenum, type.GLenum, severity.GLenum, count.GLsizei, *ids, enabled.GLboolean )
  ; PrototypeC           glDebugMessageInsertARB              ( source.GLenum, type.GLenum, id.GLuint, severity.GLenum, length.GLsizei, *buf )
  ; PrototypeC           glDebugMessageCallbackARB            ( callback.GLDEBUGPROCARB, *userParam )
  ; PrototypeC.GLuint    glGetDebugMessageLogARB              ( count.GLuint, bufsize.GLsizei, *sources, *types, *ids, *severities, *lengths, *messageLog )
  ; PrototypeC.GLenum    glGetGraphicsResetStatusARB          ( void )
  ; PrototypeC           glGetnMapdvARB                       ( target.GLenum, query.GLenum, bufSize.GLsizei, *v )
  ; PrototypeC           glGetnMapfvARB                       ( target.GLenum, query.GLenum, bufSize.GLsizei, *v )
  ; PrototypeC           glGetnMapivARB                       ( target.GLenum, query.GLenum, bufSize.GLsizei, *v )
  ; PrototypeC           glGetnPixelMapfvARB                  ( map_.GLenum, bufSize.GLsizei, *values )
  ; PrototypeC           glGetnPixelMapuivARB                 ( map_.GLenum, bufSize.GLsizei, *values )
  ; PrototypeC           glGetnPixelMapusvARB                 ( map_.GLenum, bufSize.GLsizei, *values )
  ; PrototypeC           glGetnPolygonStippleARB              ( bufSize.GLsizei, *pattern )
  ; PrototypeC           glGetnColorTableARB                  ( target.GLenum, format.GLenum, type.GLenum, bufSize.GLsizei, *table )
  ; PrototypeC           glGetnConvolutionFilterARB           ( target.GLenum, format.GLenum, type.GLenum, bufSize.GLsizei, *image )
  ; PrototypeC           glGetnSeparableFilterARB             ( target.GLenum, format.GLenum, type.GLenum, rowBufSize.GLsizei, *row, columnBufSize.GLsizei, *column, *span )
  ; PrototypeC           glGetnHistogramARB                   ( target.GLenum, reset.GLboolean, format.GLenum, type.GLenum, bufSize.GLsizei, *values )
  ; PrototypeC           glGetnMinmaxARB                      ( target.GLenum, reset.GLboolean, format.GLenum, type.GLenum, bufSize.GLsizei, *values )
  ; PrototypeC           glGetnTexImageARB                    ( target.GLenum, level.GLint, format.GLenum, type.GLenum, bufSize.GLsizei, *img )
  ; PrototypeC           glReadnPixelsARB                     ( x.GLint, y.GLint, width.GLsizei, height.GLsizei, format.GLenum, type.GLenum, bufSize.GLsizei, *data_ )
  ; PrototypeC           glGetnCompressedTexImageARB          ( target.GLenum, lod.GLint, bufSize.GLsizei, *img )
  ; PrototypeC           glGetnUniformfvARB                   ( program.GLuint, location.GLint, bufSize.GLsizei, *params )
  ; PrototypeC           glGetnUniformivARB                   ( program.GLuint, location.GLint, bufSize.GLsizei, *params )
  ; PrototypeC           glGetnUniformuivARB                  ( program.GLuint, location.GLint, bufSize.GLsizei, *params )
  ; PrototypeC           glGetnUniformdvARB                   ( program.GLuint, location.GLint, bufSize.GLsizei, *params )
  ; ;}
  
  
  
  ;----------------------------
  ; Log Graphic Hardware
  ;----------------------------
  Procedure GLDebugHardware()
    Debug "OpenGL Vendor: "    +#TAB$+#TAB$+   OpenGL::GLGETSTRINGOUTPUT(OpenGL::glGetString( #GL_VENDOR ) )
    Debug "OpenGL Renderer: "  +#TAB$+         OpenGL::GLGETSTRINGOUTPUT(OpenGL::glGetString( #GL_RENDERER ))
    Debug "OpenGL Version: "   +#TAB$+         OpenGL::GLGETSTRINGOUTPUT(OpenGL::glGetString( #GL_VERSION ) )
   ; Debug "OpenGL Shader: "    +#TAB$+#TAB$+   GLGETSTRINGOUTPUT(glGetString( #GL_SHADING_LANGUAGE_VERSION) )
  EndProcedure
  
  Procedure GLCheckError(message.s)
    Protected err = OpenGL::glGetError()
    If err
      While err <> #GL_NO_ERROR
        Protected error.s
        Select err
          Case #GL_INVALID_OPERATION
            error = " ---> INVALID OPERATION"
          Case #GL_INVALID_ENUM
            error = " ---> INVALID ENUM"
          Case #GL_INVALID_VALUE
            error = " ---> INVALID VALUE"
          Case #GL_OUT_OF_MEMORY
            error = " ---> OUT OF MEMORY"
          ;Case #GL_INVALID_FRAMEBUFFER_OPERATION
          ;  error = " ---> INVALID FRAMEBUFFER OPERATION"
        EndSelect  
        Debug "[OpenGL Error] "+message+error
        err = OpenGL::glGetError()
      Wend  
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
  EndProcedure
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 918
; FirstLine = 903
; Folding = ------
; EnableXP
; EnableUnicode
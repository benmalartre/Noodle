; ============================================================================
;
;  Copyright (c) 2012, Guy Rabiller, RADFAC.
;  All rights reserved, worldwide.
;
;  Redistribution  and  use  in  source  and  binary  forms,  with or  without
;  modification, are permitted provided that the following conditions are met:
;
;  - Redistributions of  source code  must retain  the above copyright notice,
;    this list of conditions and the following disclaimer.
;  - Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
;  - Neither the name of  RADFAC nor the names of its contributors may be used
;    to  endorse  or  promote  products  derived  from  this  software without
;    specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;  AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT LIMITED TO, THE
;  IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;  ARE DISCLAIMED.  IN NO EVENT SHALL THE  COPYRIGHT HOLDER OR CONTRIBUTORS BE
;  LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
;  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT  LIMITED  TO,  PROCUREMENT OF
;  SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA,  OR PROFITS; OR BUSINESS
;  INTERRUPTION) HOWEVER CAUSED  AND ON ANY  THEORY OF  LIABILITY,  WHETHER IN
;  CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING  NEGLIGENCE OR OTHERWISE)
;  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;
;  For permission, contact copy@radfac.com.
;
; ============================================================================
;  raafal.libs.squirrel.pbi
; ............................................................................
;  Import Squirrel Scripting library
; ============================================================================
;  2012/10/07 | Guy Rabiller
;  - creation
;  - Squirrel v303
; ============================================================================

DeclareModule Squirrel
  ; ============================================================================
  ;  TYPES
  ; ============================================================================
  ;{
  ; ---[ Base ]-----------------------------------------------------------------
  Macro SQInteger
    i
  EndMacro
  Macro SQUnsignedInteger
    i
  EndMacro
  Macro SQHash
    i
  EndMacro
  Macro SQInt32
    l
  EndMacro
  Macro SQUnsignedInteger32
    l
  EndMacro
  Macro SQFloat
    d
  EndMacro
  Macro SQRawObjectVal
    i
  EndMacro
  Macro SQUserPointer
    i
  EndMacro
  Macro SQBool
    i
  EndMacro
  Macro SQRESULT
    i
  EndMacro
  Macro SQTrue
    1
  EndMacro
  Macro SQFalse
    0
  EndMacro
  Macro SQChar
    s
  EndMacro
  Macro SQFILE    ; sqstdio
    i
  EndMacro
  Macro SQRexBool ; sqstdstring
    i
  EndMacro
  Macro SQRex     ; sqstdstring
    i
  EndMacro
  ; ---[ Opaque Structures ]----------------------------------------------------
  Macro SQVM_
    i
  EndMacro
  Macro SQTable
    i
  EndMacro
  Macro SQArray
    i
  EndMacro
  Macro SQString
    i
  EndMacro
  Macro SQClosure
    i
  EndMacro
  Macro SQGenerator
    i
  EndMacro
  Macro SQNativeClosure
    i
  EndMacro
  Macro SQUserData
    i
  EndMacro
  Macro SQFunctionProto
    i
  EndMacro
  Macro SQRefCounted
    i
  EndMacro
  Macro SQClass
    i
  EndMacro
  Macro SQInstance
    i
  EndMacro
  Macro SQDelegable
    i
  EndMacro
  Macro SQOuter
    i
  EndMacro
  ; ---[ Utilities ]------------------------------------------------------------
  Macro _RAW_TYPE( type )
    ( type & #_RT_MASK )
  EndMacro
  Macro ISREFCOUNTED( t )
    ( t & #SQOBJECT_REF_COUNTED )
  EndMacro
  ;}


  ; ============================================================================
  ;  CONSTANTS
  ; ============================================================================
  ;{
  #SQTrue                  = 1
  #SQFalse                 = 0
  ;
  #SQUIRREL_VERSION        = "Squirrel 3.0.3 stable"
  #SQUIRREL_COPYRIGHT      = "Copyright (C) 2003-2012 Alberto Demichelis"
  #SQUIRREL_AUTHOR         = "Alberto Demichelis"
  #SQUIRREL_VERSION_NUMBER = 303
  ;
  #SQ_VMSTATE_IDLE         = 0
  #SQ_VMSTATE_RUNNING      = 1
  #SQ_VMSTATE_SUSPENDED    = 2
  ;
  #SQUIRREL_EOB            = 0
  #SQ_BYTECODE_STREAM_TAG  = $FAFA
  ;
  #SQOBJECT_REF_COUNTED    = $08000000
  #SQOBJECT_NUMERIC        = $04000000
  #SQOBJECT_DELEGABLE      = $02000000
  #SQOBJECT_CANBEFALSE     = $01000000
  ;
  #SQ_MATCHTYPEMASKSTRING  = -99999
  ;
  #_RT_MASK                = $00FFFFFF
  ;
  #_RT_NULL                = $00000001
  #_RT_INTEGER             = $00000002
  #_RT_FLOAT               = $00000004
  #_RT_BOOL                = $00000008
  #_RT_STRING              = $00000010
  #_RT_TABLE               = $00000020
  #_RT_ARRAY               = $00000040
  #_RT_USERDATA            = $00000080
  #_RT_CLOSURE             = $00000100
  #_RT_NATIVECLOSURE       = $00000200
  #_RT_GENERATOR           = $00000400
  #_RT_USERPOINTER         = $00000800
  #_RT_THREAD              = $00001000
  #_RT_FUNCPROTO           = $00002000
  #_RT_CLASS               = $00004000
  #_RT_INSTANCE            = $00008000
  #_RT_WEAKREF             = $00010000
  #_RT_OUTER               = $00020000
  ; sqstdio
  #SQ_SEEK_CUR             = 0
  #SQ_SEEK_END             = 1
  #SQ_SEEK_SET             = 2
  ;}


  ; ============================================================================
  ;  ENUMERATIONS
  ; ============================================================================
  ;{
  ; ---[ SQObjectType ]---------------------------------------------------------
  Macro SQObjectType
    i
  EndMacro
  #OT_NULL          = #_RT_NULL|#SQOBJECT_CANBEFALSE
  #OT_INTEGER       = #_RT_INTEGER|#SQOBJECT_NUMERIC|#SQOBJECT_CANBEFALSE
  #OT_FLOAT         = #_RT_FLOAT|#SQOBJECT_NUMERIC|#SQOBJECT_CANBEFALSE
  #OT_BOOL          = #_RT_BOOL|#SQOBJECT_CANBEFALSE
  #OT_STRING        = #_RT_STRING|#SQOBJECT_REF_COUNTED
  #OT_TABLE         = #_RT_TABLE|#SQOBJECT_REF_COUNTED|#SQOBJECT_DELEGABLE
  #OT_ARRAY         = #_RT_ARRAY|#SQOBJECT_REF_COUNTED
  #OT_USERDATA      = #_RT_USERDATA|#SQOBJECT_REF_COUNTED|#SQOBJECT_DELEGABLE
  #OT_CLOSURE       = #_RT_CLOSURE|#SQOBJECT_REF_COUNTED
  #OT_NATIVECLOSURE = #_RT_NATIVECLOSURE|#SQOBJECT_REF_COUNTED
  #OT_GENERATOR     = #_RT_GENERATOR|#SQOBJECT_REF_COUNTED
  #OT_USERPOINTER   = #_RT_USERPOINTER
  #OT_THREAD        = #_RT_THREAD|#SQOBJECT_REF_COUNTED
  #OT_FUNCPROTO     = #_RT_FUNCPROTO|#SQOBJECT_REF_COUNTED ; internal usage only
  #OT_CLASS         = #_RT_CLASS|#SQOBJECT_REF_COUNTED
  #OT_INSTANCE      = #_RT_INSTANCE|#SQOBJECT_REF_COUNTED|#SQOBJECT_DELEGABLE
  #OT_WEAKREF       = #_RT_WEAKREF|#SQOBJECT_REF_COUNTED
  #OT_OUTER         = #_RT_OUTER|#SQOBJECT_REF_COUNTED     ; internal usage only
  ;
  #OT_UNKOWN        = 0
  ;}

  
  ; ============================================================================
  ;  PROTOTYPES (Callbacks)
  ; ============================================================================
  ;{
  PrototypeC.SQInteger SQFUNCTION     ( *v )
  PrototypeC.SQInteger SQRELEASEHOOK  ( *p, size.SQInteger )
  PrototypeC           SQCOMPILERERROR( *v, *dsc, *src, ln.SQInteger, col.SQInteger )
  PrototypeC           SQPRINTFUNCTION( *v, txt.p-utf8, *p )
  PrototypeC           SQDEBUGHOOK    ( *v, type.SQInteger, sourcename.p-utf8, line.SQInteger, funcname.p-utf8 )
  PrototypeC.SQInteger SQWRITEFUNC    ( *p1, *p2, i.SQInteger )
  PrototypeC.SQInteger SQREADFUNC     ( *p1, *p2, i.SQInteger )
  PrototypeC.SQInteger SQLEXREADFUNC  ( *p )
  ;}

  
  ; ============================================================================
  ;  STRUCTURES
  ; ============================================================================
  ;{
  ; ---[ SQObjectValue ]--------------------------------------------------------
  ;{
  Structure SQObjectValue
    StructureUnion
    	*pTable         
    	*pArray         
    	*pClosure       
    	*pOuter         
    	*pGenerator     
    	*pNativeClosure 
    	*pString        
    	*pUserData      
    	 nInteger       .SQInteger
    	 fFloat         .SQFloat
    	*pUserPointer   
    	*pFunctionProto 
    	*pRefCounted    
    	*pDelegable     
    	*pThread        
    	*pClass         
    	*pInstance      
    	*pWeakRef       .SQWeakRef
    	 raw            .SQRawObjectVal
    EndStructureUnion
  EndStructure
  ;}
  ; ---[ SQObject ]-------------------------------------------------------------
  ;{
  Structure SQObject
    _type  .SQObjectType
    _unVal .SQObjectValue
  EndStructure
  ;}
  ; ---[ SQMemberHandle ]-------------------------------------------------------
  ;{
  Structure SQMemberHandle
    _static .SQBool
    _index  .SQInteger
  EndStructure
  ;}
  ; ---[ SQStackInfos ]---------------------------------------------------------
  ;{
  Structure SQStackInfos
    *funcname  ; utf8
    *source    ; utf8
     line     .SQInteger
  EndStructure
  ;}
  ; ---[ SQRegFunction ]--------------------------------------------------------
  ;{
  Structure SQRegFunction
    *name          ; utf8
     f            .SQFUNCTION
     nparamscheck .SQInteger
    *typemask      ; utf8
  EndStructure
  ;}
  ; ---[ SQFunctionInfo ]-------------------------------------------------------
  ;{
  Structure SQFunctionInfo
     funcid.SQUserPointer
    *name    ; utf8
    *source  ; utf8
  EndStructure
  ;}
  ; ---[ SQRexMatch (sqstdstring) ]---------------------------------------------
  ;{
  Structure SQRexMatch
  	*begin
  	 len.SQInteger
  EndStructure
  ;}
  ;}
  
  
  ; ============================================================================
  ;  UTILITY MACROS
  ; ============================================================================
  ;{
  Macro sq_isnumeric(o)
    ( o\_type & #SQOBJECT_NUMERIC )
  EndMacro
  Macro sq_istable(o)
    ( o\_type = #OT_TABLE )
  EndMacro
  Macro sq_isarray(o)
    ( o\_type = #OT_ARRAY )
  EndMacro
  Macro sq_isfunction(o)
    ( o\_type = #OT_FUNCPROTO )
  EndMacro
  Macro sq_isclosure(o)
    ( o\_type = #OT_CLOSURE )
  EndMacro
  Macro sq_isgenerator(o)
    ( o\_type = #OT_GENERATOR )
  EndMacro
  Macro sq_isnativeclosure(o)
    ( o\_type = #OT_NATIVECLOSURE )
  EndMacro
  Macro sq_isstring(o)
    ( o\_type = #OT_STRING )
  EndMacro
  Macro sq_isinteger(o)
    ( o\_type = #OT_INTEGER )
  EndMacro
  Macro sq_isfloat(o)
    ( o\_type = #OT_FLOAT )
  EndMacro
  Macro sq_isuserpointer(o)
    ( o\_type = #OT_USERPOINTER )
  EndMacro
  Macro sq_isuserdata(o)
    ( o\_type = #OT_USERDATA )
  EndMacro
  Macro sq_isthread(o)
    ( o\_type = #OT_THREAD )
  EndMacro
  Macro sq_isnull(o)
    ( o\_type = #OT_NULL )
  EndMacro
  Macro sq_isclass(o)
    ( o\_type = #OT_CLASS )
  EndMacro
  Macro sq_isinstance(o)
    ( o\_type = #OT_INSTANCE )
  EndMacro
  Macro sq_isbool(o)
    ( o\_type = #OT_BOOL )
  EndMacro
  Macro sq_isweakref(o)
    ( o\_type = #OT_WEAKREF )
  EndMacro
  Macro sq_type(o)
    o\_type
  EndMacro
  ;
  Macro sq_createslot(v,n) ; deprecated
    sq_newslot(v,n,#SQFalse)
  EndMacro
  ;
  Macro SQ_OK
    0
  EndMacro
  Macro SQ_ERROR
    -1
  EndMacro
  ;
  Macro SQ_FAILED(res)
    res < 0
  EndMacro
  Macro SQ_SUCCEEDED(res)
    res >= 0
  EndMacro
  ;}
  
  
  ; ============================================================================
  ;  IMPORT (Squirrel) API
  ; ============================================================================
  ;{
  CompilerSelect #PB_Compiler_OS
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_Windows
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "..\..\libs\x64\windows\squirrel.lib"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        ImportC "..\..\libs\x32\windows\squirrel.lib"
      CompilerEndIf
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_Linux
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "../../libs/x64/linux/libsquirrel.a"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        ;CompilerError "*> raafal x32 on Linux is not supported at this time."
        ImportC "../../libs/x32/linux/libsquirrel.a"
      CompilerEndIf
    ;___________________________________________________________________________
    ;  Mac OS/X
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_MacOS
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "../../libs/x64/macosx/libsquirrel.a"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        CompilerError "*> raafal x32 on Mac OS/X is not supported at this time."
        ImportC "../../libs/x64/macosx/libsquirrel.a"
      CompilerEndIf
  CompilerEndSelect
  ;_____________________________________________________________________________
  ;  VM
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_open                    .i                ( initialstacksize.SQInteger )                 ; return *SQVM_
  sq_newthread               .i                ( *friendvm, initialstacksize.SQInteger ) ; return *SQVM_
  sq_seterrorhandler                           ( *v )
  sq_close                                     ( *v )
  sq_setforeignptr                             ( *v, *p )
  sq_getforeignptr               ( *v )
  sq_setprintfunc                              ( *v, printfunc.SQPRINTFUNCTION, errfunc.SQPRINTFUNCTION )
  sq_getprintfunc            .SQPRINTFUNCTION  ( *v )
  sq_geterrorfunc            .SQPRINTFUNCTION  ( *v )
  sq_suspendvm               .SQRESULT         ( *v )
  sq_wakeupvm                .SQRESULT         ( *v, resumedret.SQBool, retval.SQBool, raiseerror.SQBool, throwerror.SQBool )
  sq_getvmstate              .SQInteger        ( *v )
  sq_getversion              .SQInteger        ()
  ;}
  ;_____________________________________________________________________________
  ;  Compiler
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_compile                 .SQRESULT         ( *v, _read.SQLEXREADFUNC, *p, sourcename.p-utf8, raiseerror.SQBool )
  sq_compilebuffer           .SQRESULT         ( *v, buffer.p-utf8, size.SQInteger, sourcename.p-utf8, raiseerror.SQBool )
  sq_enabledebuginfo                           ( *v, enable.SQBool )
  sq_notifyallexceptions                       ( *v, enable.SQBool )
  sq_setcompilererrorhandler                   ( *v, f.SQCOMPILERERROR )
  ;}
  ;_____________________________________________________________________________
  ;  Stack Operations
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_push                                      ( *v, idx.SQInteger )
  sq_pop                                       ( *v, nelemstopop.SQInteger )
  sq_poptop                                    ( *v )
  sq_remove                                    ( *v, idx.SQInteger )
  sq_gettop                  .SQInteger        ( *v )
  sq_settop                                    ( *v, newtop.SQInteger )
  sq_reservestack            .SQRESULT         ( *v, nsize.SQInteger )
  sq_cmp                     .SQInteger        ( *v )
  sq_move                                      ( *dest, *src, idx.SQInteger )
  ;}
  ;_____________________________________________________________________________
  ;  Object Creation Handling
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_newuserdata                 ( *v, size.SQUnsignedInteger )
  sq_newtable                                  ( *v )
  sq_newtableex                                ( *v, initialcapacity.SQInteger )
  sq_newarray                                  ( *v, size.SQInteger )
  sq_newclosure                                ( *v, func.SQFUNCTION, nfreevars.SQUnsignedInteger )
  sq_setparamscheck          .SQRESULT         ( *v, nparamscheck.SQInteger, typemask.p-utf8 )
  sq_bindenv                 .SQRESULT         ( *v, idx.SQInteger )
  sq_pushstring                                ( *v, s.p-utf8, len.SQInteger )
  sq_pushfloat                                 ( *v, f.SQFloat )
  sq_pushinteger                               ( *v, n.SQInteger )
  sq_pushbool                                  ( *v, b.SQBool )
  sq_pushuserpointer                           ( *v, p )
  sq_pushnull                                  ( *v )
  sq_gettype                 .SQObjectType     ( *v, idx.SQInteger )
  sq_typeof                  .SQRESULT         ( *v, idx.SQInteger )
  sq_getsize                 .SQInteger        ( *v, idx.SQInteger )
  sq_gethash                 .SQHash           ( *v, idx.SQInteger )
  sq_getbase                 .SQRESULT         ( *v, idx.SQInteger )
  sq_instanceof              .SQBool           ( *v )
  sq_tostring                .SQRESULT         ( *v, idx.SQInteger )
  sq_tobool                                    ( *v, idx.SQInteger, *b )
  sq_getstring               .SQRESULT         ( *v, idx.SQInteger, *c ) ; *c -> pointer to utf8
  sq_getinteger              .SQRESULT         ( *v, idx.SQInteger, *i )
  sq_getfloat                .SQRESULT         ( *v, idx.SQInteger, *f )
  sq_getbool                 .SQRESULT         ( *v, idx.SQInteger, *b )
  sq_getthread               .SQRESULT         ( *v, idx.SQInteger, *thread ) ; *thread -> pointer to *SQVM_
  sq_getuserpointer          .SQRESULT         ( *v, idx.SQInteger, *p )
  sq_getuserdata             .SQRESULT         ( *v, idx.SQInteger, *p, *typetag )
  sq_settypetag              .SQRESULT         ( *v, idx.SQInteger,  typetag )
  sq_gettypetag              .SQRESULT         ( *v, idx.SQInteger, *typetag )
  sq_setreleasehook                            ( *v, idx.SQInteger, hook.SQRELEASEHOOK )
  sq_getscratchpad           .i                ( *v, minsize.SQInteger ) ; return SQChar* (utf8)
  sq_getfunctioninfo         .SQRESULT         ( *v, level.SQInteger, *fi.SQFunctionInfo )
  sq_getclosureinfo          .SQRESULT         ( *v, idx.SQInteger, *nparams, *nfreevars )
  sq_getclosurename          .SQRESULT         ( *v, idx.SQInteger )
  sq_setnativeclosurename    .SQRESULT         ( *v, idx.SQInteger, name.p-utf8 )
  sq_setinstanceup           .SQRESULT         ( *v, idx.SQInteger,  p )
  sq_getinstanceup           .SQRESULT         ( *v, idx.SQInteger, *p, typetag )
  sq_setclassudsize          .SQRESULT         ( *v, idx.SQInteger, udsize.SQInteger )
  sq_newclass                .SQRESULT         ( *v, hasbase.SQBool )
  sq_createinstance          .SQRESULT         ( *v, idx.SQInteger )
  sq_setattributes           .SQRESULT         ( *v, idx.SQInteger )
  sq_getattributes           .SQRESULT         ( *v, idx.SQInteger )
  sq_getclass                .SQRESULT         ( *v, idx.SQInteger )
  sq_weakref                                   ( *v, idx.SQInteger )
  sq_getdefaultdelegate      .SQRESULT         ( *v, t.SQObjectType )
  sq_getmemberhandle         .SQRESULT         ( *v, idx.SQInteger, *handle.SQMemberHandle )
  sq_getbyhandle             .SQRESULT         ( *v, idx.SQInteger, *handle.SQMemberHandle )
  sq_setbyhandle             .SQRESULT         ( *v, idx.SQInteger, *handle.SQMemberHandle )
  ;}
  ;_____________________________________________________________________________
  ;  Object Manipulation
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_pushroottable                             ( *v )
  sq_pushregistrytable                         ( *v )
  sq_pushconsttable                            ( *v )
  sq_setroottable            .SQRESULT         ( *v )
  sq_setconsttable           .SQRESULT         ( *v )
  sq_newslot                 .SQRESULT         ( *v, idx.SQInteger, bstatic.SQBool )
  sq_deleteslot              .SQRESULT         ( *v, idx.SQInteger, pushval.SQBool )
  sq_set                     .SQRESULT         ( *v, idx.SQInteger )
  sq_get                     .SQRESULT         ( *v, idx.SQInteger )
  sq_rawget                  .SQRESULT         ( *v, idx.SQInteger )
  sq_rawset                  .SQRESULT         ( *v, idx.SQInteger )
  sq_rawdeleteslot           .SQRESULT         ( *v, idx.SQInteger, pushval.SQBool )
  sq_newmember               .SQRESULT         ( *v, idx.SQInteger, bstatic.SQBool )
  sq_rawnewmember            .SQRESULT         ( *v, idx.SQInteger, bstatic.SQBool )
  sq_arrayappend             .SQRESULT         ( *v, idx.SQInteger )
  sq_arraypop                .SQRESULT         ( *v, idx.SQInteger, pushval.SQBool )
  sq_arrayresize             .SQRESULT         ( *v, idx.SQInteger, newsize.SQInteger )
  sq_arrayreverse            .SQRESULT         ( *v, idx.SQInteger )
  sq_arrayremove             .SQRESULT         ( *v, idx.SQInteger, itemidx.SQInteger )
  sq_arrayinsert             .SQRESULT         ( *v, idx.SQInteger, destpos.SQInteger )
  sq_setdelegate             .SQRESULT         ( *v, idx.SQInteger )
  sq_getdelegate             .SQRESULT         ( *v, idx.SQInteger )
  sq_clone                   .SQRESULT         ( *v, idx.SQInteger )
  sq_setfreevariable         .SQRESULT         ( *v, idx.SQInteger, nval.SQUnsignedInteger )
  sq_next                    .SQRESULT         ( *v, idx.SQInteger )
  sq_getweakrefval           .SQRESULT         ( *v, idx.SQInteger )
  sq_clear                   .SQRESULT         ( *v, idx.SQInteger )
  ;}
  ;_____________________________________________________________________________
  ;  Calls
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_call                    .SQRESULT         ( *v, params.SQInteger, retval.SQBool, raiseerror.SQBool )
  sq_resume                  .SQRESULT         ( *v, retval.SQBool, raiseerror.SQBool )
  sq_getlocal                .i                ( *v, level.SQUnsignedInteger, idx.SQUnsignedInteger ) ; return SQChar* (utf8)
  sq_getcallee               .SQRESULT         ( *v )
  sq_getfreevariable         .i                ( *v, idx.SQInteger, nval.SQUnsignedInteger ) ; return SQChar* (utf8)
  sq_throwerror              .SQRESULT         ( *v, err.p-utf8 )
  sq_throwobject             .SQRESULT         ( *v )
  sq_reseterror                                ( *v )
  sq_getlasterror                              ( *v )
  ;}
  ;_____________________________________________________________________________
  ;  Raw Object Handling
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_getstackobj             .SQRESULT         ( *v, idx.SQInteger, *po.SQObject )
  sq_pushobject                                ( *v, *o.SQObject )
  sq_addref                                    ( *v, *o.SQObject )
  sq_release                 .SQBool           ( *v, *o.SQObject )
  sq_getrefcount             .SQUnsignedInteger( *v, *o.SQObject )
  sq_resetobject                               ( *o.SQObject )
  sq_objtostring                               ( *o.SQObject ) ; return SQChar* (utf8)
  sq_objtobool               .SQBool           ( *o.SQObject )
  sq_objtointeger            .SQInteger        ( *o.SQObject )
  sq_objtofloat              .SQFloat          ( *o.SQObject )
  sq_objtouserpointer            ( *o.SQObject )
  sq_getobjtypetag           .SQRESULT         ( *o.SQObject, *typetag )
  ;}
  ;_____________________________________________________________________________
  ;  Garbage Collector
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_collectgarbage          .SQInteger        ( *v )
  sq_resurrectunreachable    .SQRESULT         ( *v )
  ;}
  ;_____________________________________________________________________________
  ;  Serialization
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_writeclosure            .SQRESULT         ( *v, writef.SQWRITEFUNC, up )
  sq_readclosure             .SQRESULT         ( *v,  readf.SQREADFUNC,  up )
  ;}
  ;_____________________________________________________________________________
  ;  Memory Allocation
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_malloc                  .i                ( size.SQUnsignedInteger ) ; return void*
  sq_realloc                 .i                ( *p, oldsize.SQUnsignedInteger, newsize.SQUnsignedInteger ) ; return void*
  sq_free                                      ( *p, size.SQUnsignedInteger )
  ;}
  ;_____________________________________________________________________________
  ;  Debug
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sq_stackinfos              .SQRESULT         ( *v, level.SQInteger, *si.SQStackInfos )
  sq_setdebughook                              ( *v )
  sq_setnativedebughook                        ( *v, hook.SQDEBUGHOOK )
  ;}
  EndImport
  ;}
  
  
  ; ============================================================================
  ;  IMPORT (Sqstdlib) API
  ; ============================================================================
  ;{
  CompilerSelect #PB_Compiler_OS
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_Windows
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "..\..\libs\x64\windows\sqstdlib.lib"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        ImportC "..\..\libs\x32\windows\sqstdlib.lib"
      CompilerEndIf
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_Linux
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "../../libs/x64/linux/libsqstdlib.a"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        ;CompilerError "*> raafal x32 on Linux is not supported at this time."
        ImportC "../../libs/x32/linux/libsqstdlib.a"
      CompilerEndIf
    ;___________________________________________________________________________
    ;  Mac OS/X
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_MacOS
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "../../libs/x64/macosx/libsqstdlib.a"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        CompilerError "*> raafal x32 on Mac OS/X is not supported at this time."
        ImportC "../../libs/x32/macosx/libsqstdlib.a"
      CompilerEndIf
  CompilerEndSelect
  ;_____________________________________________________________________________
  ;  Input/Ouput
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  ; I/O
  sqstd_fopen              .SQFILE        ( filename.p-utf8, mode.p-utf8 )
  sqstd_fread              .SQInteger     ( *p, size.SQInteger, count.SQInteger, f.SQFILE )
  sqstd_fwrite             .SQInteger     ( *p, size.SQInteger, count.SQInteger, f.SQFILE )
  sqstd_fseek              .SQInteger     ( f.SQFILE , offset.SQInteger , origin.SQInteger )
  sqstd_ftell              .SQInteger     ( f.SQFILE )
  sqstd_fflush             .SQInteger     ( f.SQFILE )
  sqstd_fclose             .SQInteger     ( f.SQFILE )
  sqstd_feof               .SQInteger     ( f.SQFILE )
  ; File Object
  sqstd_createfile         .SQRESULT      ( *v, file.SQFILE, own.SQBool )
  sqstd_getfile            .SQRESULT      ( *v, idx.SQInteger, *file )
  ; Script Loading And Serialization
  sqstd_loadfile           .SQRESULT      ( *v, filename.p-utf8, printerror.SQBool )
  sqstd_dofile             .SQRESULT      ( *v, filename.p-utf8, retval.SQBool, printerror.SQBool )
  sqstd_writeclosuretofile .SQRESULT      ( *v, filename.p-utf8 )
  ; Initialization
  sqstd_register_iolib     .SQRESULT      ( *v )
  ;}
  ;_____________________________________________________________________________
  ;  Blob
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sqstd_createblob          ( *v, size.SQInteger )
  sqstd_getblob            .SQRESULT      ( *v, idx.SQInteger, *ptr )
  sqstd_getblobsize        .SQInteger     ( *v, idx.SQInteger )
  ; Initialization
  sqstd_register_bloblib   .SQRESULT      ( *v )
  ;}
  ;_____________________________________________________________________________
  ;  Math
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  ; Initialization
  sqstd_register_mathlib   .SQRESULT      ( *v )
  ;}
  ;_____________________________________________________________________________
  ;  System
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  ; Initialization
  sqstd_register_systemlib .SQInteger     ( *v )
  ;}
  ;_____________________________________________________________________________
  ;  String
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  ; RegEx
  sqstd_rex_compile        .i             ( pattern.p-utf8, *error.p-utf8 ) ; return SQRex*
  sqstd_rex_free                          ( *exp )
  sqstd_rex_match          .SQBool        ( *exp, text.p-utf8 )
  sqstd_rex_search         .SQBool        ( *exp, text.p-utf8, *out_begin.p-utf8, *out_end.p-utf8 )
  sqstd_rex_searchrange    .SQBool        ( *exp, text_begin.p-utf8, text_end.p-utf8, *out_begin.p-utf8, *out_end.p-utf8 )
  sqstd_rex_getsubexpcount .SQInteger     ( *exp )
  sqstd_rex_getsubexp      .SQBool        ( *exp, n.SQInteger, *subexp.SQRexMatch )
  ; Format
  sqstd_format             .SQRESULT      ( *v, nformatstringidx.SQInteger, *outlen, *output )
  ; Initialization
  sqstd_register_stringlib .SQRESULT      ( *v )
  ;}
  ;_____________________________________________________________________________
  ;  Aux
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  sqstd_seterrorhandlers                  ( *v )
  sqstd_printcallstack                    ( *v )
  ;}
  EndImport
  ;}

EndDeclareModule

Module Squirrel
  
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 680
; FirstLine = 704
; Folding = -----------------
; EnableXP
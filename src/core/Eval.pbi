;*
;* Module eval
;*
;* Version: 1.1
;* Date: 2015-09-25
;*
;* Written by GPI
;*
;* Changelog
;* 1.1 
;*    - new functions For d: IsNAN() And IsInfinity()
;*    - log(0) is now -infinity
;*    - 15^16 is now correct for i
;*    - some codeoptimisation
;*    - new: Warning overflow for i *,+,-,<< and >>

;logx= log(a)/log(b) b darf nicht <=0 oder 1 sein

DeclareModule Eval
 
  
  Enumeration error 0 Step -1
    #err_ok
    #err_unknown_operator
    #err_forbidden_operator
    #err_syntax_error
    #err_divison_by_zero
    #err_negative_base
    #err_sqr;Square root of negative number
    #err_log;Logarithm of number <= 0
    #err_bracket
    #err_illegal_character 
    
  EndEnumeration
  Enumeration warning 
    #warning_ok
    #warning_overflow
  EndEnumeration
  
  
  ;- declare 
  Declare.i i(str.s)
  Declare.d d(str.s)
  ;Declare.f f(str.s)
  Declare AddConstantI(str.s,value.i)
  Declare AddConstantD(str.s,value.d)
  ;Declare AddConstantF(str.s,value.f)
  Declare AddFunctionI(str.s,para_count.i,*adr)
  Declare AddFunctionD(str.s,para_count.i,*adr)
  ;Declare AddFunctionF(str.s,para_count.i,*adr)
  Declare GetError()
  Declare SetError(error.i)
  Declare.s ErrorText(err.i)
EndDeclareModule

Module Eval
Macro MacroColon 
:
EndMacro
Macro MacroQuote 
"
EndMacro
Macro MacroSingleQuote
'
EndMacro
Macro JoinMacroParts (P1, P2=, P3=, P4=, P5=, P6=, P7=, P8=) : P1#P2#P3#P4#P5#P6#P7#P8 : EndMacro
Macro CreateMacro (name,macroBody=)
  JoinMacroParts (Macro name, MacroColon, macroBody, MacroColon, EndMacro) : 
EndMacro
Macro CreateQuote (name)
  JoinMacroParts (MacroQuote,name,MacroQuote)
EndMacro
Macro CreateSingleQuote (name)
  JoinMacroParts (MacroSingleQuote,name,MacroSingleQuote)
EndMacro

;maxvalues
#max_a=127
#max_b=255
#max_u=32767
CompilerIf #PB_Unicode
  #max_c=#max_u
CompilerElse 
  #max_c=#max_b
CompilerEndIf
#max_w=32767
#max_l=2147483647
#max_q=9223372036854775807
CompilerIf #PB_Compiler_Processor=#PB_Processor_x86
  #max_i=#max_l
CompilerElse
  #max_i=#max_q
CompilerEndIf


  
  Enumeration operator 1
    #op_plus;1
    #op_minus;2
    #op_mul  ;3
    #op_div  ;4
    #op_bracket;5
    #op_value  ;6
    #op_power  ;7
    #op_function1;8
    #op_function2;9
    #op_function3;10
    #op_bnot     ;11
    #op_minus_sign;12
    #op_plus_sign ;13
    #op_shiftl    ;14
    #op_shiftr    ;15
    #op_mod       ;16
    #op_bxor      ;17
    #op_bor
    #op_band
    #op_morethan
    #op_moreequal
    #op_lessthan
    #op_lessequal
    #op_equal
    #op_notequal
    #op_not
    #op_and
    #op_or
    #op_xor    
  EndEnumeration
  #op_max=#PB_Compiler_EnumerationValue-1
  
  
;   CompilerIf #PB_Compiler_Debugger
;     Global Dim opchar.s(#op_max)
;     opchar(#op_plus)="+"
;     opchar(#op_minus)="-"
;     opchar(#op_mul)="*";3
;     opchar(#op_div)="/";4
;     opchar(#op_bracket)="()";5
;     opchar(#op_value)="#"   ;6
;     opchar(#op_power)="^"   ;7
;     opchar(#op_function1)="func1";8
;     opchar(#op_function2)="func2";9
;     opchar(#op_function3)="func3";10
;     opchar(#op_bnot)="~"         ;11
;     opchar(#op_minus_sign)="-s"  ;12
;     opchar(#op_plus_sign)="+s"   ;13
;     opchar(#op_shiftl)="<<"      ;14
;     opchar(#op_shiftr)=">>"      ;15
;     opchar(#op_mod)="%"          ;16
;     opchar(#op_bxor)="!"         ;17
;     opchar(#op_bor)="|"
;     opchar(#op_band)="&"
;     opchar(#op_morethan)=">"
;     opchar(#op_moreequal)=">="
;     opchar(#op_lessthan)="<"
;     opchar(#op_lessequal)="<="
;     opchar(#op_equal)="="
;     opchar(#op_notequal)="<>"
;     opchar(#op_not)="not"
;     opchar(#op_and)="and"
;     opchar(#op_or)="or"
;     opchar(#op_xor)="xor"
;   CompilerEndIf
  
  ;Prio list
  #op_bracket_prio=10
  
  #op_function1_prio=10
  #op_function2_prio=10
  #op_function3_prio=10
  
  #op_bnot_prio=9
  #op_minus_sign_prio=9
  #op_plus_sign_prio=9
  
  #op_power_prio=8
  
  #op_shiftl_prio=7
  #op_shiftr_prio=7
  #op_mod_prio=7
  #op_bxor_prio=7
  
  #op_bor_prio=6
  #op_band_prio=6
  
  #op_mul_prio=5
  #op_div_prio=5
  
  
  #op_plus_prio=4
  #op_minus_prio=4
  
  #op_morethan_prio=3
  #op_moreequal_prio=3
  #op_lessthan_prio=3
  #op_lessequal_prio=3
  #op_equal_prio=3
  #op_notequal_prio=3
  
  #op_not_prio=2
  
  #op_and_prio=1
  #op_or_prio=1
  #op_xor_prio=1
  
  ;LastElement
  #le_value=1
  #le_operator=2
  #le_bracketopen=3
  #le_bracketclose=4
  
  Structure quadchar
    c.c
    c2.c
    c3.c
    c4.c
  EndStructure
  
  
  Threaded error.i
  
  
  Procedure GetError()
    ProcedureReturn error
  EndProcedure
  Procedure SetError(err.i)
    error=err
  EndProcedure  
  Procedure.s ErrorText(err.i)
    Select err
      Case #err_ok:ProcedureReturn "ok"
      Case #err_unknown_operator:ProcedureReturn "unknown operator"
      Case #err_forbidden_operator:ProcedureReturn "forbidden operator"
      Case #err_syntax_error:ProcedureReturn "syntax error"
      Case #err_divison_by_zero:ProcedureReturn "division by zero"
      Case #err_negative_base:ProcedureReturn "negative base"
      Case #err_sqr:ProcedureReturn "square root of negative number"
      Case #err_log:ProcedureReturn "logarithm of number < 0"
      Case #err_bracket :ProcedureReturn "missing bracket"
      Case #warning_overflow:ProcedureReturn "warning: overflow"        
    EndSelect    
    ProcedureReturn "unkown error"
  EndProcedure
  
  Macro _createMul(type)
    Procedure.type Mul#type(a.type,b.type)      
      Protected ret.type=a*b
      If a<0:a=-a:EndIf
      If b<0:b=-b:EndIf
      If (b>1 Or b<-1) And (a>1 Or a<-1) And #max_#type/b<a And error=0
        error=#warning_overflow
      EndIf
      ProcedureReturn ret    
    EndProcedure  
  EndMacro
  
  Macro _createAdd(type)
    Procedure.type Add#type(a.type,b.type)
      Protected c.type=a+b
      If (b>0 And c<a) Or (b<0 And c>a) And error=0
        error=#warning_overflow
      EndIf
      ProcedureReturn c    
    EndProcedure  
  EndMacro
  
  Macro _createSub(type)
    Procedure.type Sub#type(a.type,b.type)
      Protected c.type=a-b
      If (b>0 And c>a) Or (b<0 And c<a) And error=0
        error=#warning_overflow
      EndIf
      ProcedureReturn c    
    EndProcedure  
  EndMacro
  
  Macro _createSHL(type)
    Procedure.type SHL#type(a.type,b.type)
      If b<0
        ProcedureReturn a>>b
      EndIf       
      While b>0
        If a&(#max_#type+1) And error=0
          error=#warning_overflow
        EndIf
        a<<1
        b-1
      Wend
      ProcedureReturn a
    EndProcedure
  EndMacro
  
  Macro _createSHR(type)
    Procedure.type SHR#type(a.type,b.type)
      If b<0
        ProcedureReturn SHL#type(a,b)
      EndIf
      ProcedureReturn a>>b
    EndProcedure
  EndMacro
  
  Macro isFloat(type)
    ( CreateQuote(type)="d" Or CreateQuote(type)="D" Or CreateQuote(type)="f" Or CreateQuote(type)="F" ) 
  EndMacro
  
  Macro DoOperator1(x,type); x (value)
    If _DoRight#type(calc#type())
      calc#type()\value= x (calc#type()\value)
    EndIf
  EndMacro  
  
  Macro DoOperator2(x,type);  value op value -> op(value,value)
    Right#type=_GetRight#type(calc#type())
    If error>=#err_ok
      calc#type()\value=  x (calc#type()\value,right#type)
    EndIf
  EndMacro
    
  Macro DoOperator(x,type); value x value
    Right#type= _GetRight#type(calc#type())
    If error>=#err_ok
      CompilerIf CreateQuote(x)="/"
        If right#type=0
          error=#err_divison_by_zero
        Else
        CompilerEndIf
        calc#type()\value x right#type
        CompilerIf CreateQuote(x)="/"
        EndIf
      CompilerEndIf
    EndIf
  EndMacro
  
  Macro DoCompare1(x,type); bool(x value)
    If _DoRight#type(calc#type())
      calc#type()\value= Bool(x (calc#type()\value))
    EndIf
  EndMacro  
  
  Macro DoCompare(x,type); bool(value x value)
    Right#type=_GetRight#type(calc#type())
    If error>=#err_ok
      calc#type()\value=Bool(calc#type()\value x right#type)
    EndIf
  EndMacro
  
  Macro DoOperatorFunc1(type); func(value)
    func1=calc#type()\function
    DeleteElement(calc#type())
    If NextElement(calc#type()) And calc#type()\operator=#op_value
      calc#type()\value=func1(calc#type()\value)
    Else
      error=#err_syntax_error
    EndIf
  EndMacro
  
  Macro DoOperatorFunc2(type); func(value,value)
    func2=calc#type()\function
    DeleteElement(calc#type())
    If NextElement(calc#type()) And calc#type()\operator=#op_value And  NextElement(calc#type()) And calc#type()\operator=#op_value
      Right#type=calc#type()\value
      DeleteElement(calc#type()) 
      calc#type()\value=func2(calc#type()\value,right#type)
    Else
      error=#err_syntax_error
    EndIf
  EndMacro
  
  Macro DoOperatorFunc3(type); func(value,value,value)
    func3=calc#type()\function
    DeleteElement(calc#type())
    If NextElement(calc#type()) And calc#type()\operator=#op_value And NextElement(calc#type()) And calc#type()\operator=#op_value And NextElement(calc#type()) And calc#type()\operator=#op_value
      Right#type=calc#type()\value
      DeleteElement(calc#type()) 
      mid#type=calc#type()\value
      DeleteElement(calc#type())
      calc#type()\value=func3(calc#type()\value,mid#type,right#type)
    Else
      error=#err_syntax_error
    EndIf
  EndMacro
  
  Macro AddFunc1(type,f)
    Procedure.type func1_#f#_#type(a.type)
      ProcedureReturn f(a)
    EndProcedure  
    AddFunction#type(createquote(f),1,@func1_#f#_#type())
  EndMacro
  
  Macro AddFunc2(type,f)
    Procedure.type func2_#f#_#type(a.type,b.type)
      ProcedureReturn f(a,b)
    EndProcedure  
    AddFunction#type(createquote(f),2,@func2_#f#_#type())
  EndMacro
    
  Macro AddCalc(op,type)    
    AddElement(calc#type())
    calc#type()\operator=op
    calc#type()\prio=prio+op#_prio
    LastElement=#le_operator
  EndMacro
  
  CompilerIf #PB_Compiler_Thread
    Macro Lock(type):LockMutex(Mutex#type):EndMacro
    Macro UnLock(type):UnlockMutex(Mutex#type):EndMacro
  CompilerElse
    Macro Lock(type):EndMacro
    Macro UnLock(type):EndMacro
  CompilerEndIf
    
  ;-  
  Macro EvalIt(type)
    ;--- ** Definitions/Declares
    Structure Calc#type
      operator.i
      value.type
      prio.i
      *function
    EndStructure
    
    Structure functions#type
      type.i;0=constant,1-3 parameter count
      StructureUnion
        value.type
        *function
      EndStructureUnion
    EndStructure
    
    Prototype.type prot_func1#type(a.type)
    Prototype.type prot_func2#type(a.type,b.type)
    Prototype.type prot_func3#type(a.type,b.type,c.type)
    
    Global NewMap functions#type.functions#type()
    
    CompilerIf #PB_Compiler_Thread
      Global Mutex#type=CreateMutex()
    CompilerEndIf

    
    
    
    Procedure.type _GetRight#type(List  calc#type.calc#type());--- _getRight()
      Protected Right#type.type
      If (NextElement(calc#type()) And calc#type()\operator=#op_value)
        Right#type=calc#type()\value
        If DeleteElement(calc#type()) And DeleteElement(calc#type()) And calc#type()\operator=#op_value
          ProcedureReturn Right#type
        EndIf
      EndIf      
      error=#err_syntax_error        
      ProcedureReturn #False
    EndProcedure
    
    Procedure _DoRight#type(List  calc#type.calc#type());--- _DoRight()
      DeleteElement(calc#type())
      If NextElement(calc#type()) And calc#type()\operator=#op_value
        ProcedureReturn #True
      EndIf      
      error=#err_syntax_error
      ProcedureReturn #False
    EndProcedure
    
    Procedure AddConstant#type(str.s,value.type);--- AddConstant()
      Protected c
      str=LCase(str)
      c=Asc(str)
      If (c>='a' And c<='z') Or c='_'
        Lock(type)
        functions#type(LCase(str))\type=0
        functions#type()\value=value
        UnLock(type)
        ProcedureReturn #True
      EndIf
      ProcedureReturn #False
    EndProcedure     
    Procedure AddFunction#type(str.s,count,*function);--- AddFunction()
      Protected c
      str=LCase(str)
      c=Asc(str)
      If count>0 And count<4 And ((c>='a' And c<='z') Or c='_')
        Lock(type)
        functions#type(LCase(str))\type=count
        functions#type()\function=*function
        UnLock(type)
        ProcedureReturn #True
      EndIf      
      ProcedureReturn #False
    EndProcedure
    
    ;--- ** Add functions & constants
    CompilerIf isFloat(type)
      AddConstant#type("pi",#PI)
      AddConstant#type("infinity",Infinity())
      AddConstant#type("nan",NaN())
      AddConstant#type("e",#E)
      
      AddFunc1(type,acos)
      AddFunc1(type,acosh)
      AddFunc1(type,asin)
      AddFunc1(type,asinh)
      AddFunc1(type,atan)
      AddFunc2(type,atan2)
      AddFunc1(type,atanh)
      AddFunc1(type,cos)
      AddFunc1(type,cosh)
      AddFunc1(type,degree)
      AddFunc1(type,int)
      AddFunc1(type,radian)
      AddFunc1(type,sin)
      AddFunc1(type,sinh)
      AddFunc1(type,tan)
      AddFunc1(type,tanh)
      AddFunc1(type,isinfinity)
      AddFunc1(type,isnan)
      
      Procedure.type Round#type(a.type) ;--- Round()
        ProcedureReturn Round(a,#PB_Round_Nearest)
      EndProcedure
      AddFunctionD("round",1,@round#type())
      
    CompilerElse
      _CreateMul(type)
      _CreateAdd(type)
      _CreateSub(type)
      _CreateSHL(type)
      _CreateSHR(type)
    CompilerEndIf
      
    AddFunc1(type,abs)
    AddFunc1(type,exp)
    AddFunc2(type,mod)
    AddFunc1(type,sign)
    
    
    Procedure.type rnd#type(a.type) ;--- Random()
      ProcedureReturn Random(a)
    EndProcedure
    AddFunction#type("random",1,@rnd#type())
    
    Procedure.type rnd2#type(a.type,b.type);--- Random2()
      ProcedureReturn Random(b,a)
    EndProcedure
    AddFunction#type("random2",2,@rnd2#type())
    
    Procedure.type sqr#type(a.type);--- sqr()
      If a<0
        error=#err_sqr
      Else
        ProcedureReturn Sqr(a)
      EndIf      
    EndProcedure
    AddFunction#type("sqr",1,@sqr#type())
    
    Procedure.type pow#type(a.type,b.type);--- pow()
      If a<0 And b<>Int(b)
        error=#err_negative_base
      ElseIf a=0 And b<0
        error=#err_divison_by_zero
      ElseIf b=0
        ProcedureReturn 1
      Else        
        CompilerIf isFloat(type)        
          ProcedureReturn Pow(a,b)
        CompilerElse
          Protected i,ret.type
          ret=a
          For i=2 To b
            ret=mul#type(ret,a)
          Next
          ProcedureReturn ret
        CompilerEndIf
        
      EndIf
    EndProcedure
    AddFunction#type("pow",2,@pow#type())
    
    Procedure.type log#type(a.type);--- log()
      If a<0
        error=#err_log
      Else
        ProcedureReturn Log(a)
      EndIf
    EndProcedure
    AddFunction#type("log",1,@log#type())
    
    Procedure.type log10#type(a.type);--- log10()
      If a<=0
        error=#err_log
      Else
        ProcedureReturn Log10(a)
      EndIf
    EndProcedure
    AddFunction#type("log10",1,@log10#type())
    
    Procedure.type type(str.s) ;--- type.type()
      Protected func1.prot_func1#type
      Protected func2.prot_func2#type
      Protected func3.prot_func3#type
      Protected maxprio.i
      Protected prio
      Protected poweradd.i
      Protected name.s
      Protected mid#type.type
      Protected right#type.type
      Protected *pos.quadchar
      Protected *posstart.quadchar
      Protected isNumeric
      Protected isBinary
      Protected isHex
      Protected LastElement
      
      error=#err_ok      
      
      NewList calc#type.calc#type()
      
      
      ;------lcase and charcheck
      *pos=@str
      While *pos\c<>0
        If *pos\c>='A' And *pos\c<='Z'
          *pos\c+'a'-'A'
        ElseIf *pos\c>127
          error=#err_illegal_character
          Break
        EndIf
        *pos+SizeOf(character)
      Wend
      
      If error <0
        CompilerIf IsFloat(type)
          ProcedureReturn NaN()
        CompilerElse
          ProcedureReturn 0
        CompilerEndIf
      EndIf
      
      ;------scan
      *pos=@str
      While *pos\c=' '
        *pos+SizeOf(character)
      Wend
      *posstart=*pos
      
      isNumeric=0
      isBinary=0
      isHex=0
      prio=0
      LastElement=0
      
      Repeat
        
        Select *pos\c
          Case '0' To '9', 'a' To 'z', '_','.';----- no operator
            
            Select *pos\c
              Case '0','1'
                If isHex=1
                  isHex=2
                EndIf
                If isBinary=1
                  isBinary=2
                EndIf            
                If isNumeric=0
                  isNumeric=2
                ElseIf isNumeric=3
                  isNumeric=4
                EndIf        
              Case '2' To '9'
                If isNumeric=0
                  isNumeric=2
                ElseIf isNumeric=3
                  isNumeric=4
                EndIf
                If isHex=1
                  isHex=2
                EndIf
                isBinary=-1
                
              Case 'a' To 'd','f'
                If isHex=1
                  isHex=2
                EndIf
                isNumeric=-1
                isBinary=-1
              Case 'e'
                If isNumeric=2
                  CompilerIf isFloat(type)
                    If *pos\c2='-' Or *pos\c2='+'
                      *pos+SizeOf(character)
                    EndIf
                    isNumeric=3
                  CompilerElse
                    error=#err_syntax_error
                  CompilerEndIf                  
                Else
                  isNumeric=-1
                EndIf
                isBinary=-1
                If isHex=1
                  isHex=2
                EndIf
                
              Case '.'
                CompilerIf isFloat(type)
                  If isNumeric=2
                    isNumeric=3
                  Else
                    isNumeric=-1
                    error=#err_syntax_error
                  EndIf
                  isBinary=-1
                  isHex=-1            
                CompilerElse
                  error=#err_syntax_error
                CompilerEndIf              
                
              Default
                isNumeric=-1
                isHex=-1
                isBinary=-1
                
            EndSelect
            
            
            
          Default;----- operator
            
            ;----- first check the name/value
            If *posstart<*pos  
              name=PeekS(*posstart, (*pos-*posstart)/SizeOf(character) )
              If (isNumeric=2 Or isNumeric=4 Or isBinary=2 Or isHex=2) And LastElement=#le_bracketclose
                error=#err_syntax_error
              ElseIf isNumeric=2 Or isNumeric=4
                AddElement(calc#type())
                calc#type()\operator=#op_value
                CompilerIf isFloat(type)
                  calc#type()\value=Val#type(name)
                CompilerElse
                  calc#type()\value=Val(name)
                CompilerEndIf
                LastElement=#le_value
              ElseIf isHex=2
                AddElement(calc#type())
                calc#type()\operator=#op_value
                calc#type()\value=Val("$"+name)
                LastElement=#le_value
              ElseIf isBinary=2
                AddElement(calc#type())
                calc#type()\operator=#op_value
                calc#type()\value=Val("%"+name)
                LastElement=#le_value
              Else
                
                If name="or"
                  AddCalc(#op_or,type)
                ElseIf name="not"
                  AddCalc(#op_not,type)
                ElseIf name="xor"
                  AddCalc(#op_xor,type)
                ElseIf name="and"
                  AddCalc(#op_and,type)
                ElseIf (*posstart\c>='a' And *posstart\c<='z') Or *posstart\c='_'
                  Lock(type)
                  If FindMapElement(functions#type(),name)
                    If functions#type()\type=0
                      AddElement(calc#type())
                      calc#type()\operator=#op_value
                      calc#type()\value= functions#type()\value
                      LastElement=#le_value                
                    Else
                      While *pos\c=' ' 
                        *pos+SizeOf(character)
                      Wend
                      If *pos\c='('                       
                        Select functions#type()\type
                          Case 1
                            AddElement(calc#type())
                            calc#type()\operator=#op_function1
                            calc#type()\function=functions#type()\function
                            calc#type()\prio=prio+#op_function1_prio
                            LastElement=#le_operator
                          Case 2
                            AddElement(calc#type())
                            calc#type()\operator=#op_function2
                            calc#type()\function=functions#type()\function
                            calc#type()\prio=prio+#op_function2_prio
                            LastElement=#le_operator
                          Case 3
                            
                            AddElement(calc#type())
                            calc#type()\operator=#op_function3
                            calc#type()\function=functions#type()\function
                            calc#type()\prio=prio+#op_function3_prio
                            LastElement=#le_operator
                          Default
                            error=#err_unknown_operator
                            
                        EndSelect
                      Else
                        error=#err_bracket
                      EndIf

                    EndIf
                  Else
                    error=#err_unknown_operator
                    ;Debug "UNKNOWN:"+name+"###"
                  EndIf
                  UnLock(type)
                Else
                  error=#err_syntax_error
                EndIf        
              EndIf   
            Else
              If isHex=1 Or isBinary=1 Or isNumeric=3
                error=#err_syntax_error
              EndIf        
              
            EndIf 
            isNumeric=0
            isBinary=0
            isHex=0
            
            Select *pos\c
              Case '|'            
                AddCalc(#op_bor,type)
              Case '&'
                AddCalc(#op_band,type)  
              Case '<'
                If *pos\c2='<'
                  AddCalc(#op_shiftl,type)
                  *pos+SizeOf(character)
                ElseIf *pos\c2='>'
                  AddCalc(#op_notequal,type)
                  *pos+SizeOf(character)
                ElseIf *pos\c2='='
                  AddCalc(#op_lessequal,type)
                  *pos+SizeOf(character)
                Else
                  AddCalc(#op_lessthan,type)              
                EndIf
              Case '>'
                If *pos\c2='>'
                  AddCalc(#op_shiftr,type)
                  *pos+SizeOf(character)
                ElseIf *pos\c2='<'
                  AddCalc(#op_notequal,type)
                  *pos+SizeOf(character)
                ElseIf *pos\c2='='
                  AddCalc(#op_moreequal,type)
                  *pos+SizeOf(character)
                Else
                  AddCalc(#op_morethan,type)
                EndIf
              Case '='
                If *pos\c2='<'
                  AddCalc(#op_lessequal,type)
                  *pos+SizeOf(character)
                ElseIf *pos\c2='>'
                  AddCalc(#op_moreequal,type)
                  *pos+SizeOf(character)
                Else
                  AddCalc(#op_equal,type)
                EndIf            
              Case '!'
                AddCalc(#op_bxor,type)
              Case '~'
                AddCalc(#op_bnot,type)
              Case '*'
                AddCalc(#op_mul,type)
              Case '/'
                AddCalc(#op_div,type)
              Case '^'
                AddCalc(#op_power,type)          
              Case '('
                If LastElement=#le_bracketclose
                  error=#err_syntax_error
                Else              
                  prio+#op_bracket_prio
                  LastElement=#le_bracketopen
                EndIf
              Case ')'
                If prio<=0
                  error=#err_bracket
                Else                  
                  prio-#op_bracket_prio
                  LastElement=#le_bracketclose
                EndIf                
              Case ','
                If LastElement=#le_operator
                  error=#err_syntax_error
                Else              
                  LastElement=#le_bracketopen ;same handling!
                EndIf            
              Case '-'       
                If LastElement=0 And *pos=*posstart
                  AddElement(calc#type())
                  calc#type()\operator=#op_value
                  calc#type()\value=0
                  AddCalc(#op_minus,type)
                ElseIf LastElement=#le_bracketclose Or LastElement=#le_value Or *pos<>*posstart 
                  AddCalc(#op_minus,type)
                Else
                  AddCalc(#op_minus_sign,type)
                EndIf      
              Case '+'   
                If LastElement=0 And *pos=*posstart
                  *posstart=*pos+SizeOf(character)
                ElseIf LastElement=#le_bracketclose Or LastElement=#le_value Or *pos<>*posstart              
                  AddCalc(#op_plus,type)
                Else
                  ;AddCalc(#op_plus_sign,type)
                EndIf             
                
              Case '%'
                If LastElement=#le_value Or LastElement=#le_bracketclose Or *pos<>*posstart
                  AddCalc(#op_mod,type)
                Else
                  If isBinary=0
                    isBinary=1
                  EndIf
                  isNumeric=-1
                  isHex=-1
                EndIf
                
              Case '$'
                If LastElement=#le_value Or LastElement=#le_bracketclose Or *pos<>*posstart
                  isHex=-1
                  error=#err_syntax_error
                ElseIf isHex=0
                  isHex=1
                EndIf            
                isBinary=-1
                isNumeric=-1
              Case 0
                Break
                
            EndSelect  
            
            *posstart=*pos+SizeOf(character)
            
            
        EndSelect
        
        
        
        *pos+SizeOf(character)
        
        If error<0
          Break
        EndIf
        
        
      Until error<0
      
      ;Debug "---"+str
      ;ForEach calc#type()
      ;  If calc#type()\operator=#op_value
      ;    Debug "Value:"+calc#type()\value
      ;  Else
     ;     Debug "Op:"+calc#type()\operator+" prio:"+calc#type()\prio
     ;   EndIf
     ; Next
     ; Debug "---"
      
      If prio
        error=#err_bracket
        
      EndIf 
      
      
      If error<0
        ;Debug "here"
        CompilerIf isfloat(type)
          ProcedureReturn NaN()
        CompilerElse
          ProcedureReturn 0
        CompilerEndIf
      EndIf
      
      
      ;----- find first maxprio
      maxprio=0
      ForEach calc#type()
        If calc#type()\operator <> #op_value 
          If maxprio<calc#type()\prio
            maxprio=calc#type()\prio
            poweradd=0
          EndIf
          If calc#type()\operator=#op_power
            poweradd+1
          EndIf
        EndIf        
      Next
      
      
      ;----- operate
      Repeat
        
        ;         CompilerIf #PB_Compiler_Debugger
        ;           Protected _all.s
        ;           _all=""
        ;           ForEach calc()
        ;             If calc()\operator=#op_value
        ;               _all+""+calc()\value+" "
        ;             Else
        ;               _all+opchar(calc()\operator)+"["+calc()\prio+"] "
        ;             EndIf
        ;           Next
        ;           Debug _all
        ;         CompilerEndIf
        
        
        
        prio=0
        If poweradd>1 And LastElement(calc#type())
          Repeat
            If calc#type()\operator=#op_power And calc#type()\prio=maxprio
              DoOperator2(pow,type)
            ElseIf prio<calc#type()\prio 
              prio=calc#type()\prio
              poweradd=0
            EndIf
            If calc#type()\operator=#op_power And calc#type()\prio=prio
              poweradd+1
            EndIf
          Until PreviousElement(calc#type())=0 Or error<0
        Else
          ForEach calc#type()
            If calc#type()\operator<>#op_value
              If calc#type()\prio=maxprio
                Select calc#type()\operator
                    CompilerIf Not isFloat(type)
                    Case #op_bnot
                      DoOperator1(~,type)
                    Case #op_shiftl
                      DoOperator2(shl#type,type)
                    Case #op_shiftr
                      DoOperator2(shr#type,type)
                    Case #op_bxor
                      DoOperator(!,type)
                    Case #op_mod
                      DoOperator(%,type)
                    Case #op_bor
                      DoOperator(|,type)
                    Case #op_band
                      DoOperator(&,type)
                    CompilerEndIf
                    
                  Case #op_minus_sign
                    DoOperator1(-,type)
                  Case #op_plus_sign
                    DoOperator1(0+,type)
                    
                    CompilerIf isFloat(type)
                    Case #op_minus
                      DoOperator(-,type)
                    Case #op_plus
                      DoOperator(+,type)
                    Case #op_mul                    
                      DoOperator(*,type)
                    CompilerElse
                    Case #op_minus
                      DoOperator2(sub#type,type)
                    Case #op_plus
                      DoOperator2(add#type,type)
                    Case #op_mul
                      DoOperator2(mul#type,type)
                    CompilerEndIf  
                    
                  Case #op_div
                    DoOperator(/,type)
                  Case #op_power
                    DoOperator2(pow#type,type)
                  Case #op_function1
                    DoOperatorFunc1(type)
                  Case #op_function2
                    DoOperatorFunc2(type)
                  Case #op_function3
                    DoOperatorFunc3(type)
                    
                  Case #op_morethan
                    DoCompare(>,type)
                  Case #op_moreequal
                    DoCompare(>=,type)
                  Case #op_lessthan
                    DoCompare(<,type)
                  Case #op_lessequal
                    DoCompare(<=,type)
                  Case #op_equal
                    DoCompare(=,type)
                  Case #op_notequal
                    DoCompare(<>,type)
                  Case #op_not
                    DoCompare1(Not,type)
                  Case #op_or
                    DoCompare(Or,type)
                  Case #op_xor
                    DoCompare(XOr,type)
                  Case #op_and
                    DoCompare(And,type)
                    
                  Default 
                    error=#err_forbidden_operator
                EndSelect
                
              Else
                If prio<calc#type()\prio 
                  prio=calc#type()\prio
                  poweradd=0
                EndIf
                If calc#type()\operator=#op_power And calc#type()\prio=prio
                  poweradd+1
                EndIf
              EndIf
              
            EndIf
            
            
            If error <0
              Break
            EndIf    
          Next
        EndIf
        
        maxprio=prio
        
      Until prio=0  Or error<0
      
      ;If error
      ;  Debug "  ERROR:"+ErrorText(error)
      ;EndIf
      
      If error>=0
        If ListSize(calc#type())=1 And FirstElement(calc#type()) And calc#type()\operator=#op_value
          ProcedureReturn calc#type()\value
        EndIf
        error=#err_syntax_error
      EndIf
      CompilerIf isFloat(type)
        ProcedureReturn NaN()
      CompilerElse
        ProcedureReturn 0
      CompilerEndIf
    EndProcedure
  EndMacro
  ;--- expand eval-macros
  evalit(i)
  evalit(d)
  ;evalit(f)
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 19
; FirstLine = 16
; Folding = -------
; EnableXP
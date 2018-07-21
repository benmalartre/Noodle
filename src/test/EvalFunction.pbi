XIncludeFile "../core/Eval.pbi"
DeclareModule Func
  Macro MacroColon 
    :
  EndMacro
  Macro MacroQuote 
    "
  EndMacro
  Macro JoinMacroParts (P1, P2=, P3=, P4=, P5=, P6=, P7=, P8=) : P1#P2#P3#P4#P5#P6#P7#P8 : EndMacro
  Macro CreateMacro (name,macroBody=)
    Func::JoinMacroParts (Macro name, Func::MacroColon, macroBody, Func::MacroColon, EndMacro) : 
  EndMacro
  Macro CreateQuote (name)
    Func::JoinMacroParts (Func::MacroQuote,name,Func::MacroQuote)
  EndMacro
  
  Declare finish()
  
  Define __aa.i,__cc.i
  Define __aad.d,__ccd.d
  Define __aaf.f,__ccf.f
  Define __aas.s,__ccs.s
  
  Macro i(a,ss,c)
    Func::__aa=a
    Func::__cc=c
    Func::t(#PB_Compiler_Procedure,Bool(Func::__aa ss Func::__cc),Func::CreateQuote(a ss c),Str(Func::__aa),Str(Func::__cc),Func::CreateQuote(ss))
  EndMacro
  Macro d(a,ss,c,xxx=2)
    Func::__aad=a
    Func::__ccd=c
    Func::t(#PB_Compiler_Procedure,Bool(Func::__aad ss Func::__ccd),Func::CreateQuote(a ss c),StrD(Func::__aad,xxx),StrD(Func::__ccd,xxx),Func::CreateQuote(ss))
  EndMacro
  Macro f(a,ss,c)
    Func::__aaf=a
    Func::__ccf=c
    Func::t(#PB_Compiler_Procedure,Bool(Func::__aaf ss Func::__ccf),Func::CreateQuote(a ss c),StrD(Func::__aaf),StrD(Func::__ccf),Func::CreateQuote(ss))
  EndMacro
  Macro s(a,ss,c)
    Func::__aas=a
    Func::__ccs=c
    Func::t(#PB_Compiler_Procedure,Bool(Func::__aas ss Func::__ccs),Func::CreateQuote(a ss )+" "+Func::__ccs,"",""," ")
  EndMacro
  
  
  Declare T(p.s,bool.i,sa.s,a.s,c.s,s.s)
  Declare finish()
  Declare Set(name.s)
EndDeclareModule
Module test
  Global TestName.s
  Global TestResult=#True  
  
  Procedure Set(name.s)
    TestName=name
  EndProcedure
  
  
  Procedure finish()
    PrintN("")
    PrintN("")
    If TestResult
      ConsoleColor(10,0)
      PrintN( "Test OK!")
    Else
      ConsoleColor(12,0)
      PrintN( "Test Fail!")  
    EndIf
    PrintN("")
    PrintN("")
    PrintN("Press [Return]")
    Input()
    CloseConsole()
    End
  EndProcedure
  
  Procedure T(p.s,bool.i,sa.s,a.s,c.s,s.s)
    If s="<>":s="!":EndIf
    Static back,lastp$,lastTestName$
    Define fc,cok,cfail
    
    If lastTestName$<>TestName
      lastTestName$=TestName
      ConsoleColor(8,0)
      PrintN(TestName+":")
      lastp$=""
    EndIf
    
    If lastp$<>p
      lastp$=p
      ConsoleColor(8,0)
      If lastp$<>""
        PrintN("  ("+lastp$+")")
      Else
        PrintN("  (Main)")
      EndIf    
    EndIf
    
    Print ("     ")
    back!1
    If back
      fc=15
      cfail=12
      cok=10
    Else
      fc=7
      cfail=4
      cok=2    
    EndIf
    
    Define state.s
    ConsoleColor(fc,0)
    
    Print(Left(sa+Space(35+24-10),35+24-10) )
    
    Print(Left(Right(Space(5+5)+a,5+5)+s.s+Left(c+Space(5+5),5+5),11+10))
    If bool
      ConsoleColor(cok,0)
      PrintN("ok  ")
      ConsoleColor(fc,0)
    Else
      ConsoleColor(cfail,0)
      PrintN("FAIL")
      ConsoleColor(fc,0)
      Debug "Fail:"+sa
      TestResult=#False
    EndIf  
    ConsoleColor(7,0)
  EndProcedure
EndModule

EnableExplicit
OpenConsole()
PrintN("Start")
PrintN("")

Define str.s
  Macro evald(x,value,er=#err_ok)
    str=x
    Func::set("str="+x)
    Func::d(eval::d(str),=,value)
    Func::i(eval::GetError(),=,eval:: er)
  EndMacro
  Macro evali(x,value,er=#err_ok)
    str=x
    Func::set("str="+x)
    Func::i(eval::i(str),=,value)
    Func::i(eval::GetError(),=,eval:: er)
  EndMacro
  Macro evalx(x,value,er=#err_ok)
    evali(x,value,er)
    evald(x,value,er)
  EndMacro
  
  
  Macro fasti(y)
    evali(Func::CreateQuote(y),y)
  EndMacro
  
  
  
  evald("1+3*$7f+(33+ -22)*-5 + sqr( pow(2,5))",1+3*$7f+(33+-22)*-5+Sqr(Pow(2,5)))
  evali("1+3*$7f+(33+ -22)*-5 + sqr( pow(2,5))",333)
  
  evald("atan2(10,10)",ATan2(10,10))
  evald("pow(10,3)",Pow(10,3))
  evald("cos(pi)",Cos(#PI))
  evalx("2^2^(1+1)^2*2",Pow(2,Pow(2,Pow(2,2)))*2)
  
  Procedure.i mini(a.i,b.i)
    If a>b
      ProcedureReturn b
    EndIf
    ProcedureReturn a
  EndProcedure
  eval::AddFunctionI("min",2,@mini())
  evali("min(10,99)",10)
  evali("min(88,22)",22)
  fasti(~%1001)
  
  fasti(15%2)
  fasti(%111<<4)
  fasti(%10101010>>4)
  fasti(%1100 ! %1010 )
  fasti(%1100 | %1010 )
  fasti(%1100 & %1010)
  evalx("1>2",Bool(1>2))
  evalx("1<2",Bool(1<2))
  evalx("1>=2",Bool(1>=2))
  evalx("1<=2",Bool(1<=2)) 
  evalx("1=2",Bool(1=2))  
  evalx("1<>2",Bool(1<>2))  
  evalx("2>1",Bool(2>1))    
  evalx("2<1",Bool(2<1))    
  evalx("2>=1",Bool(2>=1))  
  evalx("2<=1",Bool(2<=1)) 
  evalx("2=1",Bool(2=1))  
  evalx("2<>1",Bool(2<>1))    
  evalx("1>1",Bool(1>1))  
  evalx("1<1",Bool(1<1)) 
  evalx("1>=1",Bool(1>=1)) 
  evalx("1<=1",Bool(1<=1)) 
  evalx("1=1",Bool(1=1))
  evalx("1<>1",Bool(1<>1))
  evalx("not 123",0)    
  evalx("not 0",1)           
  evald("Log(e)",Log(#E))
  evalx("$123+-$50*-$12",$123+- $50*-$12)
  evalx("(10+2)+5",(10+2)+5)
  evalx("10+ -5",10+ -5)
  evald(" 0.5 + 1.2",0.5+1.2)
  
  evald("1<<3",NaN(),#err_forbidden_operator)
  evald("*10e-3",NaN(),#err_syntax_error)
  evali("1/0",0,#err_divison_by_zero)
  evald("1/0",NaN(),#err_divison_by_zero)
  evali("sqr(-2)",0,#err_sqr)
  evald("sqr(-2)",NaN(),#err_sqr)
  evald("sqr(2,2)",NaN(),#err_syntax_error)
  fasti(10+-$a)
  fasti(10+-%1001)
  
  
  
  evalx("-1 <  7",   1)
  evalx(" 1 > -7",   1)
  evalx(" 4 =  5",   0)
  evalx(" 4 <> 5",   1)
  evalx(" 4 <= 5",   1)
  evalx(" 4 >= 5",   0)
  evalx("(4+2) = 6", 1)
  evalx(" 4+2  = 6", 1)
  evalx("6 = (4+2)", 1)
  evalx("6 =  4+2",  1)
  
  evalx(" 2+3+4",     9)
  evalx(" 2-3*4",   -10)
  evalx("+2+3*4",    14)
  evalx("-2+3*4",    10)
  evalx("  12*2",    24)
  evalx("  -3*4",   -12)
  evalx(" (2+3)*4",  20)
  evalx("(-2+3)*4",   4)
  evald("1.27+4.73", 6)
  evald("7/(10-1)", 7/(10-1))
  evalx("6-(2+7)*4+5", -25)
  evalx("2*(3+4)/((5-6)*7)", -2)
  evald("(7*(5-6))/2*(3+4)", (7*(5-6))/2*(3+4))
  evalx("+(2+3)*4",  20)
  evalx("-(2+3)*4", -20)
  
  evalx("(2^3)^2",   64)
  evalx("2^(3^2)",  512)
  evalx("2^3^2",    512)
  evald("0^0.5",      0)
  evalx("0^2",        0)
  evalx("2^0",        1)
  evald("2^(-3)", 0.125)
  evalx("0^0",        1)
  evald("-9^0.5",    -3)
  evald("-3^2",-9)
  evald("(-3)^2",9)
  evald("2^-3",0.125) 
  
  evalx("1+(2+(3+(4+(5+(6+(7+(8+(9-(10+(11+(12+(13+(14+(15+(16-(17+(18+(19+(20)))))))))))))))))))", 28)
  
  evalx("$FF",  255)
  evalx("-$1C", -28)
  
  evald("pi", #PI)
  evald("e",  #E)
  evalx(" sqr(9)", 3)
  evalx(" sqr(9)+4-5", 2)
  evalx("-sqr(9)+4*5", 17)
  evalx("6-sqr(2+7)*4+5", -1)
  evalx("2+3*(sqr(4)+5)", 2+3*(Sqr(4)+5))
  evald("2+3/(sqr(4)*5)", 2.3)
  
  evald("log(e)", 1)             ; function with default parameter
  
  evald("sqr",       NaN(),#err_bracket)
  evald("sqr 9",     NaN(),#err_bracket)
  evald("sqr9",      NaN(),#err_unknown_operator)
  evald("sqr_9()",   NaN(),#err_bracket)
  evald("sin()",     NaN(),#err_syntax_error)
  evald("sin()10",   NaN(),#err_syntax_error)
  evald("sin()(10)", NaN(),#err_syntax_error)
  evald("sqr(9,10)", NaN(),#err_syntax_error)
  evald("1<<10"    , NaN(),#err_forbidden_operator)
  
  
  evald("7/0",       NaN(),#err_divison_by_zero)
  evald("0^(-2)",    NaN(),#err_divison_by_zero)
  evald("sqr(2-7)",  NaN(),#err_sqr)
  evald("log(-2)",   NaN(),#err_log)
  
  evald("2)3",       NaN(),#err_bracket)
  evald("3*(2+5))",  NaN(),#err_bracket)
  evald("3*(2+5",    NaN(),#err_bracket)
  
  evald("1 2",        NaN(),#err_syntax_error)
  evald("27$A",       NaN(),#err_syntax_error)
  evald("(27+3)$A",   NaN(),#err_syntax_error)
  
  evald("3sqr",       NaN(),#err_syntax_error)
  evald("(2)sqr",     NaN(),#err_bracket)
  evald("(2)3",       NaN(),#err_syntax_error)
  evald("(3+4)5",     NaN(),#err_syntax_error)
  evald("2(3",        NaN(),#err_bracket)
  evald("(2)(3)",     NaN(),#err_syntax_error)
  evald("(3+2)(7-5)", NaN(),#err_syntax_error)
  evald("5(3+4)",     NaN(),#err_syntax_error)
  
  evald("1+4.", NaN(),#err_syntax_error)
  evald("1.+4", NaN(),#err_syntax_error)
  evald("$-3",  NaN(),#err_syntax_error)
  evald("$",    NaN(),#err_syntax_error)
  
  evali("4 =! 5",   0,#err_syntax_error)
  evald("2+)3(",    NaN(),#err_bracket)
  
  evald("3+*2",     NaN(),#err_syntax_error)
  evald("3*/2",     NaN(),#err_syntax_error)
  evald("0-^2",     NaN(),#err_syntax_error)
  evald("2+.3",     NaN(),#err_syntax_error)
  evald("2+,3",     NaN(),#err_syntax_error)
  evald("3+",       NaN(),#err_syntax_error)
  evald("3*",       NaN(),#err_syntax_error)
  evald("*58+6",    NaN(),#err_syntax_error)
  evald("/62-9",    NaN(),#err_syntax_error)
  evald("^4+3",     NaN(),#err_syntax_error)
  evald("/",        NaN(),#err_syntax_error)
  evald("()",       NaN(),#err_syntax_error)
  evald("2,3",      NaN(),#err_syntax_error)
  
  evald("1.4.2.3",NaN(),#err_syntax_error)
  
  evald("äöü", NaN(),#err_illegal_character)
  
  ;test and or xor
  
  Procedure.i ifi(a.i,b.i,c.i)
    If a
      ProcedureReturn b
    EndIf
    ProcedureReturn c
  EndProcedure
  Eval::AddFunctionI("if",3,@ifi())
  
  evali("10*if(2>1,3*3,1+4)+4",10*(3*3)+4)
  evali("10*if(2<1,3*3,1+4)+4",10*(1+4)+4)
  evalx("99 and 123",1)
  evalx("0 and 123",0)
  evalx("99 and 0",0)
  evalx("0 and 0",0)
  evalx("99 or 123",1)
  evalx("0 or 123",1)
  evalx("99 or 0",1)
  evalx("0 or 0",0)
  evalx("99 xor 123",0)
  evalx("0 xor 123",1)
  evalx("99 xor 0",1)
  
  
  evali("10* if ( 10*3+4>0 and 123*32^5+88,2,3)+3",10*2+3)
  
  evald("2/3*(sqr((1+4)/5))", 2/3*(Sqr((1+4)/5)) )
  
  evalx("20 * - $50",20 * - $50)
  
  evalx("0 xor 0",0)
  
  evald("pi 9",       NaN(),#err_syntax_error)
  
  evald("(-9)^0.5",  NaN(),#err_negative_base)
  
  evald("1e3",1000)
  evali("1e3",0,#err_syntax_error)
  
  
  evald("log(0)",-Infinity())
  
  CompilerIf #PB_Compiler_Processor=#PB_Processor_x64
    evali("15^16",6568408355712890625)
  CompilerEndIf
  
  evald("2^^2",0,#err_syntax_error)  
  evali("2^^2",0,#err_syntax_error)
  evali("15^18",2152354138636261345,#warning_overflow)
  evali("9223372036854775807+10",9223372036854775807+10,#warning_overflow)
  evali("-9223372036854775807+-10",-9223372036854775807+-10,#warning_overflow)
  evali("-9223372036854775807-10",-9223372036854775807-10,#warning_overflow)
  evali("9223372036854775807--10",9223372036854775807--10,#warning_overflow)
  evali("%11111111111111111111111111111111111111111111111111111<<20",-1048576,#warning_overflow)

  Func::finish()
; IDE Options = PureBasic 5.62 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 347
; FirstLine = 316
; Folding = ----
; EnableXP